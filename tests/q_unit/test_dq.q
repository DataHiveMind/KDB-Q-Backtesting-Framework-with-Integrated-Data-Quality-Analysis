/ tests/q_unit/test_dq.q - Unit tests for Data Quality rules

system "l src/dq/checks.q"

/ Simple assertion function
assert: {[condition; message] if[not condition; '"Assertion Failed: ", message]};

show "Running DQ Unit Tests...";

/ 1. Test flagCrossed
mock_quotes: ([] 
    time: (.z.N; .z.N+1000; .z.N+2000); 
    sym: `AAPL`AAPL`AAPL; 
    bid: 150.0 150.5 150.6; 
    ask: 150.1 150.4 150.7; / Middle row is crossed (bid 150.5 > ask 150.4)
    bsize: 100 100 100; 
    asize: 100 100 100
 );

res_crossed: .dq.flagCrossed[mock_quotes];
assert[exec dq_crossed[1] from res_crossed; "Crossed book not flagged"];
assert[not exec dq_crossed[0] from res_crossed; "Valid book incorrectly flagged as crossed"];

/ 2. Test flagWideSpread
res_wide: .dq.flagWideSpread[mock_quotes; 3.0];
/ Assuming rolling median of 3 rows is around 0.1, the second row spread is -0.1 (crossed), third is 0.1. 
/ Let's add a specifically wide row for an accurate test.
mock_quotes_wide: mock_quotes uj ([] time:enlist .z.N+3000; sym:enlist `AAPL; bid:enlist 140.0; ask:enlist 160.0; bsize:enlist 100; asize:enlist 100);
res_wide: .dq.flagWideSpread[mock_quotes_wide; 3.0];
assert[exec dq_wide_spread[3] from res_wide; "Wide spread anomaly not flagged"];

/ 3. Test cleanQuotes integration
clean_tbl: .dq.cleanQuotes[mock_quotes_wide];
assert[2 = count clean_tbl; "cleanQuotes failed to drop exact number of anomalous ticks"];

show "All DQ Unit Tests Passed.";
exit 0;