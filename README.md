# KDB+/Q Backtesting Framework with Integrated Data Quality Analysis

An institutional-grade, high-performance backtesting engine built natively in kdb+/q. This framework is designed for quantitative researchers to simulate trading strategies on tick-level market data while enforcing strict, automated data quality (DQ) checks. By integrating the DQ layer directly into the backtesting pipeline, the engine ensures that generated alpha and PnL metrics are not artifacts of anomalous data, structural breaks, or missing ticks.

## Core Features

* **High-Performance Event-Driven Engine:** Simulates order matching, execution slippage, and portfolio state updates across microsecond-resolution tick data.
* **Integrated Data Quality (DQ) Layer:** Automatically filters and flags stale prices, bid-ask anomalies (e.g., crossed books), and statistical outliers before they pollute strategy logic.
* **Production-Ready Architecture:** Mirrors live trading environments by supporting Tickerplant (TP), Real-Time Database (RDB), and Historical Database (HDB) architectures.
* **Extensible Schema Design:** Standardized `schema.q` for Level 1/Level 2 order book snapshots, trades, and quotes.

## Repository Structure

```text
KDB-Q-Backtesting-Framework/
├── .vscode/
│   ├── launch.json           # Debug configurations for q processes
│   └── settings.json         # Workspace settings
├── src/
│   ├── core/
│   │   ├── engine.q          # Order matching, PnL calculation, state management
│   │   └── schema.q          # Table schemas (quotes, trades, order book)
│   ├── dq/
│   │   ├── checks.q          # Data quality rules (outliers, missing ticks, stale prices)
│   │   └── metrics.q         # Statistical aggregations of data quality
│   └── utils/
│       └── helpers.q         # Date/time conversions, I/O wrappers
├── scripts/
│   ├── start_tickerplant.sh  # Spin up TP/RDB architecture for live simulation
│   └── start_hdb.sh          # Mount historical data
├── data/
│   ├── hdb/                  # Date-partitioned historical data
│   └── tplog/                # Tickerplant transaction logs
├── tests/
│   ├── test_engine.q         # Unit tests for matching logic
│   └── test_dq.q             # Edge-case tests for the data quality module
└── README.md

Prerequisites
kdb+ (>= 4.1): 64-bit version required for memory-intensive tick data processing.

License: A valid kc.lic or k4.lic must be present in your QHOME directory (e.g., C:\q\kc.lic for Windows environments).

VS Code: Recommended with the kdb+ language extension for IPC connection and syntax highlighting.

Installation & Setup
Clone the repository:

Bash
git clone [https://github.com/DataHiveMind/KDB-Q-Backtesting-Framework-with-Integrated-Data-Quality-Analysis.git](https://github.com/DataHiveMind/KDB-Q-Backtesting-Framework-with-Integrated-Data-Quality-Analysis.git)
cd KDB-Q-Backtesting-Framework-with-Integrated-Data-Quality-Analysis
Configure QHOME:
Ensure your environment variables are correctly set so the framework can locate the q executable and license.

Initialize the Database:
Construct the historical data partitions (HDB) using the provided schemas:

Bash
q src/core/schema.q -p 5050

Usage
1. Running Data Quality Checks
Before executing a backtest, run the historical data through the DQ pipeline to generate clean data views and metrics:

Code snippet
q src/dq/checks.q -hdb data/hdb -sym AAPL -date 2026.10.29
2. Executing a Backtest
Spin up the backtesting engine on the validated data:

Code snippet
q src/core/engine.q -strategy MyMeanReversion -start 2026.01.01 -end 2026.10.01 -port 5001
3. Simulating Live Market Conditions
To test the strategy under live, streaming conditions, utilize the provided shell scripts to spin up a mock Tickerplant:

Bash
./scripts/start_tickerplant.sh
Contributing