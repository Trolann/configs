#!/bin/bash

# Options to be displayed
option0="Lock"
option1="Logout"
option2="Suspend"
option3="Reboot"
option4="Shutdown"

# Options passed to rofi
options="$option0\n$option1\n$option2\n$option3\n$option4"

chosen="$(echo -e "$options" | rofi -dmenu -i -theme-str '
    window {
        width: 300px;
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
' -p "Power Menu" -l 5 -width 20 -location 0 -yoffset 0 -fixed-num-lines true)"

case $chosen in
$option0)
  i3lock -c 000000
  ;;
$option1)
  i3-msg exit
  ;;
$option2)
  systemctl suspend
  ;;
$option3)
  systemctl reboot
  ;;
$option4)
  systemctl poweroff
  ;;
esac
