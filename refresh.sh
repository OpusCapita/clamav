#!/bin/bash

while true; do
  freshclam --stdout 2>&1
  rs=$?
  if (( $rs > 1 )) ; then
    echo "error updating db: $rs"
  else if (( $rs == 1 )) ; then 
      echo "update check ok, nothing updated"
      touch updated.txt
    else 
      echo "update check ok, update performed"
      touch updated.txt
    fi
  fi
  sleep 30
done
