#!/bin/bash

# Script to disconnect all external displays while keeping eDP-1 (main display) active
# Author: Claude
# Date: February, 2025

# Set the main display that should remain active
MAIN_DISPLAY="eDP-1"

echo "Identifying connected displays..."

# Get all connected displays
CONNECTED_DISPLAYS=$(xrandr --query | grep " connected" | cut -d" " -f1)

# Check if main display exists
if ! echo "$CONNECTED_DISPLAYS" | grep -q "$MAIN_DISPLAY"; then
  echo "Warning: Main display $MAIN_DISPLAY not found. Available displays:"
  echo "$CONNECTED_DISPLAYS"
  echo "Script will still disconnect external displays, but may leave you without any active display."
  read -p "Continue? (y/n): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 1
  fi
fi

# Ensure main display is set to auto (optimal resolution)
echo "Setting $MAIN_DISPLAY to optimal resolution..."
xrandr --output "$MAIN_DISPLAY" --auto

# Turn off all other displays
for DISPLAY in $CONNECTED_DISPLAYS; do
  if [ "$DISPLAY" != "$MAIN_DISPLAY" ]; then
    echo "Disconnecting $DISPLAY..."
    xrandr --output "$DISPLAY" --off
  fi
done

echo "Operation completed. All external displays have been disconnected."
echo "Only $MAIN_DISPLAY should be active now."

# List final display configuration
echo
echo "Current display configuration:"
xrandr --query | grep " connected"
