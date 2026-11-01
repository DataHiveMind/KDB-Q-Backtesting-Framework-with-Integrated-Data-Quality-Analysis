/ generate_mock_data.q - Synthetic tick generator for testing

system "l config/sym.q"

/ Connect to Tickerplant
h:@[hopen; `::5010; {show "Failed to connect to TP: ",x; exit 1}];

/ Base prices for random walk
prices: universe ! 150.50 330.10 140.25 130.00 450.75;

/ Timer function to push updates to TP
.z.ts: {
    n: 5; / Generate 5 ticks per interval
    
    / Generate random quotes
    s: n?universe;
    p: prices[s] * 1.0 + (n?0.002) - 0.001; / Random walk step
    prices[s]: p; / Update base prices
    
    bids: p - n?0.05;
    asks: p + n?0.05;
    bsizes: 100 * 1 + n?10;
    asizes: 100 * 1 + n?10;
    
    qts: (n#.z.N; s; bids; asks; bsizes; asizes);
    
    / Generate random trades (10% probability per tick)
    trds: ();
    if[0.1 > first 1?1.0;
        ts: 1?s;
        tp: 1?prices[ts];
        tsz: 100 * 1 + 1?5;
        trds: (1#.z.N; ts; tp; tsz; 1#`Reg);
    ];

    / Publish to Tickerplant via async IPC (negated handle)
    neg[h](".u.upd"; `quotes; qts);
    if[count trds; neg[h](".u.upd"; `trades; trds)];
 };

/ Set timer to fire every 100 milliseconds
\t 100
show "Streaming synthetic data to TP on port 5010..."