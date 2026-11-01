# tests/pytest/test_pykx_bridge.py
import pytest
import pandas as pd
import numpy as np
import pykx as kx
from src.pykx_gateway.python_api import KDBBacktestGateway

@pytest.fixture(scope="module")
def gateway():
    """Initializes the kdb+ gateway once for all tests in this module."""
    return KDBBacktestGateway()

@pytest.fixture
def sample_data():
    """Generates synthetic quotes and RL agent signals for testing."""
    quotes_df = pd.DataFrame({
        "time": pd.to_timedelta(["09:30:00.000", "09:30:01.000", "09:30:02.000"]),
        "sym": ["AAPL", "AAPL", "AAPL"],
        "bid": [150.0, 150.1, 150.0],
        "ask": [150.1, 150.2, 150.1],
        "bsize": [1000, 1000, 1000],
        "asize": [1000, 1000, 1000]
    })
    
    signals_df = pd.DataFrame({
        "time": pd.to_timedelta(["09:30:00.500", "09:30:01.500"]),
        "sym": ["AAPL", "AAPL"],
        "side": ["buy", "sell"],
        "qty": [100, 200]
    })
    
    return signals_df, quotes_df

def test_vectorized_backtest_execution(gateway, sample_data):
    signals_df, quotes_df = sample_data
    
    # Run the bridge method
    executions_df = gateway.run_vectorized_backtest(signals_df, quotes_df)
    
    # Assertions on return type and shape
    assert isinstance(executions_df, pd.DataFrame), "Execution result must be a Pandas DataFrame"
    assert len(executions_df) == 2, "Expected exactly two executions"
    
    # Assertions on execution logic translated back from q
    assert executions_df.iloc[0]["exec_price"] == 150.1, "First buy order should execute at the 09:30:00 ask"
    assert executions_df.iloc[1]["exec_price"] == 150.1, "Second sell order should execute at the 09:30:01 bid"
    assert executions_df.iloc[0]["filled_qty"] == 100, "Buy order qty should be fully filled"
    assert not executions_df.iloc[0]["walked_book"], "Fully filled order should not trigger walked_book flag"

def test_q_schema_validation(gateway):
    """Ensures that the PyKX embedded instance correctly loaded the schemas."""
    tables = kx.q("tables `.")
    tables_list = [str(x) for x in tables]
    assert "quotes" in tables_list, "Schema 'quotes' failed to load into q memory space"
    assert "trades" in tables_list, "Schema 'trades' failed to load into q memory space"