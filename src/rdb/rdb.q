/ src/rdb/rdb.q - Real-Time Database (In-Memory Intraday State)

system "l config/schema.q"

/ Connect to Tickerplant and subscribe to all tables
initRDB: {[tp_host; tp_port]
    h: hopen `$":",string[tp_host],":",string[tp_port];
    / Subscribe to all tables (`), from all symbols (`)
    schemas: h(`.u.sub; `; `);
    
    / Initialize local tables with TP schemas
    {.[x; (); :; y]}'[first schemas; last schemas];
    show "RDB Subscribed to TP successfully.";
 };

/ Update function triggered by Tickerplant broadcast
upd: {[t;x]
    t insert x;
 };

/ End of Day process: Save to HDB, apply attributes, clear memory
.u.end: {[date]
    hdb_path: `:data/hdb;
    
    / Iterate through all tables in the root namespace
    tbls: tables `.;
    
    / Write each table to the date partition and apply grouped attribute (`g#) to sym
    { .Q.dpft[hdb_path; date; `sym; x] } each tbls;
    
    / Clear tables from RAM for the next day
    { @[x; (); :; 0#value x] } each tbls;
    
    show "EOD save-down complete for date: ", string[date];
 };

/ Auto-initialize if ports are provided via command line (e.g., q rdb.q localhost 5010)
if[count .z.x; initRDB[.z.x 0; .z.x 1]];