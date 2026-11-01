#!/bin/bash
# start_cluster.sh - Spins up the kdb+ tick architecture

echo "Starting Historical Database (HDB) on port 5012..."
nohup q data/hdb -p 5012 -T 60 > logs/hdb.log 2>&1 &
HDB_PID=$!

echo "Starting Tickerplant (TP) on port 5010..."
# TP args: schema file, log directory, port
nohup q src/tp/tick.q config/schema data/tplog -p 5010 -t 1000 > logs/tp.log 2>&1 &
TP_PID=$!

# Give the TP a moment to bind to the port
sleep 2

echo "Starting Real-Time Database (RDB) on port 5011..."
# RDB args: TP host:port, HDB host:port, port
nohup q src/rdb/rdb.q localhost:5010 localhost:5012 -p 5011 > logs/rdb.log 2>&1 &
RDB_PID=$!

echo "Cluster running."
echo "HDB PID: $HDB_PID"
echo "TP PID: $TP_PID"
echo "RDB PID: $RDB_PID"