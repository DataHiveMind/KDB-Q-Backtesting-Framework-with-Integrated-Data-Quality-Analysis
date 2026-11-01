/ src/dq/checks.q - Automated Data Quality and Anomaly Detection

\d .dq

/ Flag Crossed Books: Bid should never be greater than or equal to Ask in a healthy LOB
flagCrossed: {[tbl]
    update dq_crossed: bid >= ask from tbl
 };

/ Flag Wide Spreads: Identify ticks where the spread exceeds a rolling median threshold
flagWideSpread: {[tbl; thresholdMultiplier]
    tbl: update spread: ask - bid from tbl;
    / Calculate 50-tick rolling median spread per symbol
    tbl: update med_spread: 50 mmed spread by sym from tbl;
    update dq_wide_spread: spread > (med_spread * thresholdMultiplier) from tbl
 };

/ Flag Stale Prices: Identify zero-volume periods or broken exchange feeds
/ threshold: timespan (e.g., 00:05:00.000)
flagStale: {[tbl; threshold]
    / Calculate time since last tick per symbol
    tbl: update delta_t: deltas time by sym from tbl;
    update dq_stale: delta_t > threshold from tbl
 };

/ Master DQ Pipeline: Applies all checks and returns a clean, filtered table
cleanQuotes: {[tbl]
    t1: flagCrossed[tbl];
    t2: flagWideSpread[t1; 3.0]; / Flag spreads 3x wider than rolling median
    t3: flagStale[t2; 00:05:00.000]; / 5 minute stale threshold
    
    / Keep only clean ticks (no DQ flags triggered)
    select from t3 where not dq_crossed, not dq_wide_spread, not dq_stale
 };

\d .