/ src/engine/pnl.q - Vectorized Position and PnL Accounting

\d .pnl

/ Update portfolio state given a batch of executions
/ executions: ([] time; sym; side; filled_qty; exec_price)
updatePortfolio: {[executions; portfolio]
    
    / Aggregate net executions per symbol
    net_exec: select 
        net_qty: sum ?[side=`buy; filled_qty; neg filled_qty],
        total_value: sum filled_qty * exec_price 
        by sym from executions;
        
    / Join against existing portfolio state
    updated: aj[`sym; portfolio; net_exec];
    
    / Calculate new position and VWAP
    updated: update 
        new_pos: pos + net_qty,
        / VWAP calculation logic: retain previous VWAP if position flips/closes, else weighted average
        vwap: ?[(pos * new_pos) > 0; 
                ((pos * vwap) + total_value) % (pos + net_qty); 
                total_value % (1 ^ abs net_qty)] 
        from updated;
        
    / Calculate Realized PnL for closed/reduced positions
    updated: update 
        realized: realized + ?[signum[pos] <> signum[net_qty]; 
                               abs[net_qty] * (exec_price - vwap); 
                               0.0]
        from updated;
        
    select sym, pos:new_pos, vwap, unrealized, realized from updated
 };

/ Mark-to-Market against latest Level 1 quotes
markToMarket: {[portfolio; quotes]
    / Get the latest mid-price per symbol
    latest_px: select last mid_price:(bid+ask)%2.0 by sym from quotes;
    
    mtm: aj[`sym; portfolio; latest_px];
    
    update unrealized: pos * (mid_price - vwap) from mtm
 };

\d .