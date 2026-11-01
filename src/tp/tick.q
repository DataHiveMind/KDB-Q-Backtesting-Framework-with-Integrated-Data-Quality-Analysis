/ src/tp/tick.q - Standard kdb+ Tickerplant logic

system "l config/schema.q"

/ Initialize tickerplant state
.u.d: .z.D;       / Current date
.u.l: `symbol$(); / Log handle
.u.w: ()!();      / Dictionary of subscribers (tables -> handles)

/ Subscribe function for RDBs
.u.sub: {[t;s]
    if[not t in keys .u.w; .u.w[t]: ()];
    .u.w[t],: .z.w;
    (t; value t) / Return table schema to RDB
 };

/ Update function: Write to log, then broadcast
.u.upd: {[t;x]
    if[not type x; x: enlist x];
    
    / Append exact ingestion timestamp
    x: (.z.N; x[1]; x[2]; x[3]; x[4]; x[5]); 
    
    / Write to Tickerplant Log (.tpl)
    if[not null .u.l; .u.l enlist (`upd; t; x)];
    
    / Broadcast to subscribers
    if[count .u.w[t]; (neg .u.w[t])@\: (`upd; t; x)];
 };