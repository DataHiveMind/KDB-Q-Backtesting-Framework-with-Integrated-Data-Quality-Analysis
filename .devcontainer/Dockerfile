# Use Python 3.13 as the base image for PyKX compatibility
FROM mcr.microsoft.com/devcontainers/python:3.13-bullseye

# Install system dependencies required for kdb+ and network debugging
RUN apt-get update && apt-get install -y \
    rlwrap \
    runit \
    net-tools \
    iputils-ping \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Set up environment variables for kdb+
ENV QHOME=/opt/q
ENV PATH="${PATH}:${QHOME}/l64"
ENV QINIT=/opt/q/q.k

# Upgrade pip and install baseline data science packages
RUN pip install --no-cache-dir --upgrade pip && \
    pip install numpy pandas pytest pykx