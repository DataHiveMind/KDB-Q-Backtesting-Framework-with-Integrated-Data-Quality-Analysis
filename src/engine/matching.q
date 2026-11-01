/ src/engine/matching.q - Vectorized Order Execution Simulation

\d .match

/ Execute a batch of strategy orders against a table of clean quotes
/ orders: ([] time; sym; side; qty)
/ quotes: ([] time; sym; bid; ask; bsize; asize)
executeMarketOrders: {[orders; quotes]
    
    / As-of join (aj) to find the prevailing quote at the exact nanosecond of the order
    fills: aj[`sym`time; orders; quotes];
    
    / Calculate execution price and slippage based on order side and quote side
    fills: update 
        exec_price: ?[side=`buy; ask; bid],
        available_liquidity: ?[side=`buy; asize; bsize] 
        from fills;
    
    / Determine if the order exceeded available top-of-book liquidity (Partial Fill simulation)
    fills: update 
        filled_qty: qty & available_liquidity,
        unfilled_qty: 0 ^ (qty - available_liquidity)
        from fills;
        
    / Tag executions that require walking the book (slippage penalty applied later)
    fills: update walked_book: unfilled_qty > 0 from fills;
    
    select time, sym, side, requested_qty:qty, filled_qty, exec_price, walked_book from fills
 };

\d .