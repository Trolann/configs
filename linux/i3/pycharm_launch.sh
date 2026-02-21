#!/bin/bash
# Load layout
i3-msg "workspace $ws2; append_layout ~/.config/i3/pycharm_layout.json"

# Launch applications
pycharm &
i3-msg 'workspace $ws2; exec terminal'
i3-msg 'workspace $ws2; exec terminal'
