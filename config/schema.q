// schema.q - Core table definitions for event-driven backtesting

// Level 1 Quotes (Best Bid/Offer)
quotes: ([] time:`timespan$(); sym:`symbol$(); bid:`float$(); ask:`float$(); bsize:`long$(); asize:`long$());

// Executed Trades (Tape)
trades: ([] time:`timespan$(); sym:`symbol$(); price:`float$(); size:`long$(); cond:`symbol$());

// Level 2 Order Book Depth (Top 5 levels)
depth: ([] time:`timespan$(); sym:`symbol$(); 
    bids:`float$(); bsizes:`long$(); 
    asks:`float$(); asizes:`long$());

// Internal State: Portfolio & Position Tracking
portfolio: ([sym:`symbol$()] 
    pos:`long$(); 
    vwap:`float$(); 
    unrealized:`float$(); 
    realized:`float$());