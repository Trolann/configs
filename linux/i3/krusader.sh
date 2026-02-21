#!/bin/bash

# Check if Krusader is running
if pgrep -x "krusader" >/dev/null; then
  # If running, kill it
  killall krusader
else
  # If not running, start it
  krusader &
fi
