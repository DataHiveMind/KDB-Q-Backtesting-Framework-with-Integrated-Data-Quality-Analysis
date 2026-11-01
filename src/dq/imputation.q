/ src/dq/imputation.q - Time-Bar Regularization and Forward Filling

\d .dq

/ Aggregate ticks into fixed time-bars (e.g., 1 minute)
/ bar_size: timespan (e.g., 00:01:00.000)
createTimeBars: {[tbl; bar_size]
    / Group by symbol and time buckets, extract OHLCV
    select 
        open: first exec_price, 
        high: max exec_price, 
        low: min exec_price, 
        close: last exec_price, 
        volume: sum filled_qty
    by sym, bar_size xbar time 
    from tbl
 };

/ Forward-fill (LOCF) missing time-bars to maintain continuous sequence for ML models
forwardFillBars: {[bars; start_time; end_time; bar_size]
    / Generate a continuous timeline
    timeline: start_time + bar_size * til `long$(end_time - start_time) % bar_size;
    
    / Create a grid of all symbols and all time buckets
    syms: exec distinct sym from bars;
    grid: timeline cross syms;
    grid_tbl: flip `time`sym ! flip grid;
    
    / As-of join the actual bars onto the perfect grid, filling missing values with previous
    aj[`sym`time; grid_tbl; bars]
 };

\d .