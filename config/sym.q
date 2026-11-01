// sym.q - Universe definitions and static reference data

// Define tradable universe
universe: `AAPL`MSFT`GOOGL`AMZN`NVDA;

// Define tick sizes and round lot sizes per symbol for the matching engine
syminfo: ([sym: universe] 
    tickSize: 5#0.01; 
    lotSize: 5#100;
    marginReq: 5#0.15
 );