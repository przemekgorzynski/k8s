#!/bin/bash

NAMESPACE="monitoring"
SERVICE="prometheus"
PORT=9090

echo "🔍 Checking if port $PORT is in use..."

PID=$(lsof -ti tcp:$PORT)

if [ -n "$PID" ]; then
  echo "⚠️ Port $PORT is in use by PID $PID. Killing it..."
  kill -9 $PID
  sleep 1
else
  echo "✅ Port $PORT is free."
fi

echo "🚀 Starting port-forward to Prometheus..."
kubectl port-forward -n "$NAMESPACE" svc/"$SERVICE" "$PORT:$PORT"
