#!/bin/bash
res=$(echo "PING" | nc localhost 3310)
if [[ "$res" != "PONG" ]] ; then
  echo "no PONG received on PING"
  exit 1
fi

if [[ -f "updated.txt" ]] ; then
  lastUpdate=$(stat -c "%Y" updated.txt)
  rightNow=$(date -u "+%s")
  secondsSinceUpdate=$((rightNow-lastUpdate))
  if (( $secondsSinceUpdate < 4*3600)) ; then
    echo "update status ok"
    #exit 0;
  else
    echo "virus db not updated more than 4 hours"
    exit 2;
  fi
else
  echo "no updated.txt -> refresh.sh not running?"
  exit 3;
fi

res=$(curl -f localhost:8080)
if (( $? > 0 )) ; then
  echo "failed accessign REST endpoint: $res"
  exit 4;
fi

echo "$res" | grep "Clamd responding: true"
if (( $? > 0 )) ; then
  echo "REST endpoint not connected to clamd: $res"
  exit 5;
fi

exit 0;
