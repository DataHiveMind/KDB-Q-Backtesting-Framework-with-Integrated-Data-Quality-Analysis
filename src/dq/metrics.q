/ src/dq/metrics.q - Data Quality Reporting

\d .dq

/ Generate an audit report of triggered DQ flags from raw quotes
generateAuditReport: {[raw_tbl; clean_tbl]
    
    total_ticks: count raw_tbl;
    clean_ticks: count clean_tbl;
    dropped_ticks: total_ticks - clean_ticks;
    
    / Aggregate flags
    flag_summary: select 
        crossed_books: sum dq_crossed,
        wide_spreads: sum dq_wide_spread,
        stale_prices: sum dq_stale
    by sym from raw_tbl;
    
    audit: `sym xcols update 
        drop_rate: (crossed_books + wide_spreads + stale_prices) % total_ticks 
        from flag_summary;
        
    show "DQ Audit Complete. Total Dropped: ", string[dropped_ticks];
    :audit
 };

\d .