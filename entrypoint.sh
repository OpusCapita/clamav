#!/bin/bash
# make sure clamd runs
pid=$(ps ax | grep "clamd")
if [[ -z "$pid" ]] ; then
  echo "no process found for clamd"
  exit 1
fi


freshclam -d
nohup tail -f /var/log/clamav/freshclam.log &
clamd
nohup tail -f /var/log/clamav/clamd.log &

#start clamav rest in background
nohup java -jar /var/clamav-rest/clamav-rest-1.0.2.jar --clamd.host=localhost --clamd.port=3310 --clamd.maxfilesize=10737418240 --clamd.maxrequestsize=10737418240 2>&1 &

echo "params: $@"
if [[ -z "$1" ]] ; then 
  echo "waiting for clamd to come up"
  sleep 5
  echo "reading nohup.out..."
  tail -f nohup.out
else
  echo "executing $1..."
  $1
fi

# define shutdown helper
function shutdown() {
    trap "" SIGINT

    for single in $pidlist; do
        if ! kill -0 $single 2>/dev/null; then
            wait $single
            latest_exit=$?
        fi
    done

    kill $pidlist 2>/dev/null
}

# run shutdown
trap shutdown SIGINT
