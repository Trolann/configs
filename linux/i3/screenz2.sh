#!/bin/bash

# Function to check dependencies
check_dependencies() {
  for cmd in rofi xrandr; do
    if ! command -v $cmd &>/dev/null; then
      echo "Error: $cmd is not installed. Please install it to use this script."
      exit 1
    fi
  done
}

# Function to disconnect all external monitors
disconnect_monitors() {
  for display in $(xrandr | grep " connected" | grep -v "eDP-1" | cut -d " " -f1); do
    xrandr --output $display --off
  done
  xrandr --output eDP-1 --auto --pos 0x0
}

# Function to set up standing desk configuration
setup_standing_desk() {
  xrandr --output DVI-I-2-1 --mode 1920x1080 --pos 0x-1080 --output DVI-I-3-2 --mode 1920x1080 --pos 1920x-1080 --output eDP-1 --mode 1920x1080 --pos 960x0
}

# Function to set up garage configuration (single monitor to the east)
setup_garage() {
  xrandr --output $(xrandr | grep " connected" | grep -v "eDP-1" | cut -d " " -f1) --auto --pos 1920x0 --output eDP-1 --auto --pos 0x0
}

# Function to set up single monitor configuration
setup_single_monitor() {
  local direction=$(echo -e "n\ns\ne\nw\nne\nse\nnw\nsw" | rofi -dmenu -i -p "Select monitor position" -theme-str '
    window {
      width: 200px;
      padding: 20px;
      border: 2px;
      border-color: @foreground;
      border-radius: 10px;
    }
    listview {
      lines: 8;
      spacing: 0.5em;
    }
    element-text {
      horizontal-align: 0.5;
    }
  ' -kb-cancel "Escape")
  if [[ -n $direction ]]; then
    local x_pos=0
    local y_pos=0
    case $direction in
    n) y_pos=-1080 ;;
    s) y_pos=1080 ;;
    e) x_pos=1920 ;;
    w) x_pos=-1920 ;;
    ne)
      x_pos=1920
      y_pos=-1080
      ;;
    se)
      x_pos=1920
      y_pos=1080
      ;;
    nw)
      x_pos=-1920
      y_pos=-1080
      ;;
    sw)
      x_pos=-1920
      y_pos=1080
      ;;
    esac
    xrandr --output $(xrandr | grep " connected" | grep -v "eDP-1" | cut -d " " -f1) --auto --pos ${x_pos}x${y_pos} --output eDP-1 --auto --pos 0x0
  fi
}

# Main menu
main_menu() {
  local options="Standing Desk\nGarage\nSingle Monitor\nDisconnect Monitors\nExit"
  echo -e $options | rofi -dmenu -i -p "Display Setup" -theme-str '
    window {
      width: 250px;
      padding: 25px;
      border: 2px;
      border-color: @foreground;
      border-radius: 10px;
    }
    listview {
      lines: 5;
      spacing: 0.5em;
    }
    element-text {
      horizontal-align: 0.5;
    }
  ' -kb-cancel "Escape"
}

# Main script logic
check_dependencies
while true; do
  choice=$(main_menu)
  case $choice in
  "Standing Desk")
    setup_standing_desk
    ;;
  "Garage")
    setup_garage
    ;;
  "Single Monitor")
    setup_single_monitor
    ;;
  "Disconnect Monitors")
    disconnect_monitors
    ;;
  "Exit" | "")
    exit 0
    ;;
  esac
done
