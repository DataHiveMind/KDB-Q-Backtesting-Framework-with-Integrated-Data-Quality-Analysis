# src/pykx_gateway/python_api.py
import pykx as kx
import pandas as pd
import numpy as np

class KDBBacktestGateway:
    def __init__(self, q_port: int = 5012):
        """
        Initializes the PyKX connection to the kdb+ HDB/Engine.
        Alternatively, can run q natively within the Python process.
        """
        # Load the kdb+ scripts into the embedded PyKX q instance
        kx.q.system("l config/schema.q")
        kx.q.system("l src/dq/checks.q")
        kx.q.system("l src/engine/matching.q")
        
    def run_vectorized_backtest(self, signals_df: pd.DataFrame, quotes_df: pd.DataFrame) -> pd.DataFrame:
        """
        Converts Python Pandas DataFrames to kdb+ tables, executes the
        vectorized matching engine, and returns the execution ledger.
        """
        # 1. Convert Pandas DataFrames to PyKX Tables (Zero-copy if using PyArrow underneath)
        kx_orders = kx.toq(signals_df)
        kx_quotes = kx.toq(quotes_df)
        
        # 2. Push tables into the q memory space
        kx.q["orders"] = kx_orders
        kx.q["raw_quotes"] = kx_quotes
        
        # 3. Execute the q pipeline: Clean quotes -> Match Orders
        kx.q("clean_quotes: .dq.cleanQuotes[raw_quotes]")
        kx.q("executions: .match.executeMarketOrders[orders; clean_quotes]")
        
        # 4. Pull the results back to a Pandas DataFrame
        executions_df = kx.q["executions"].pd()
        
        return executions_df

if __name__ == "__main__":
    # Example usage for unit testing the bridge
    gateway = KDBBacktestGateway()
    print("PyKX Gateway initialized successfully. Ready for ML signals.")