/ src/engine/state.q - Risk Limits and Capital Allocation

\d .risk

/ Load constraints (simulated dict load from JSON config)
max_gross_exposure: 5000000.0;
max_drawdown_pct: 0.04;
initial_capital: 1000000.0;

/ Validate if a new order breaches risk limits
/ order: (sym; side; qty; expected_price)
checkLimits: {[order; portfolio_mtm; current_capital]
    
    sym: order[0]; side: order[1]; qty: order[2]; expected_price: order[3];
    
    / Calculate current gross exposure
    current_gross: exec sum abs[pos * vwap] from portfolio_mtm;
    proposed_exposure: qty * expected_price;
    
    if[(current_gross + proposed_exposure) > max_gross_exposure;
        show "RISK REJECT: Max Gross Exposure Breached for ", string[sym];
        :0b;
    ];
    
    / Check Drawdown
    peak_capital: max initial_capital, current_capital;
    drawdown: (peak_capital - current_capital) % peak_capital;
    
    if[drawdown > max_drawdown_pct;
        show "RISK REJECT: Max Drawdown Circuit Breaker Hit.";
        :0b;
    ];
    
    :1b; / Order approved
 };

\d .