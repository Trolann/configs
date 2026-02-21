#!/bin/bash
sleep 10
#rclone mount gdrive: ~/gdrive --daemon
rclone mount gdrive: ~/gdrive \
  --daemon \
  --vfs-cache-mode full \
  --vfs-cache-max-age 24h \
  --buffer-size 256M \
  --dir-cache-time 24h \
  --poll-interval 15s \
  --vfs-read-ahead 100G \
  --transfers 32 \
  --fast-list #  --vfs-read-ahead 128M \
