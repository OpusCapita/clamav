#!/bin/bash
# make sure clamd runs
pid=$(ps ax | grep "clamd")
if [[ -z "$pid" ]] ; then
  echo "no process found for clamd"
  exit 1
fi

sed -i 's/UpdateLogFile \/var\/log\/clamav\/freshclam.log/#\/dev\/stdout\//g' /etc/freshclam.conf
sed -i 's/LogFile \/var\/log\/clamav\/clamd.log/#\/dev\/stdout\//g' /etc/clamd.conf

echo "starting clamd in foreground..."
clamd --foreground=true &

while true ; do

  res=$(echo "PING" | nc localhost 3310)
  if [[ "$res" != "PONG" ]] ; then
    echo "clamd not responding with PONG yet"
    sleep 5;
  else
    echo "received PONG from clamd"
    break;
  fi
done

# start refresh loop
echo "starting refresh via freshclam"
./refresh.sh &

while true ; do

  if [[ -f "updated.txt" ]] ; then
    lastUpdate=$(stat -c "%Y" updated.txt)
    rightNow=$(date -u "+%s")
    secondsSinceUpdate=$((rightNow-lastUpdate))
    if (( $secondsSinceUpdate < 4*3600)) ; then
      echo "last update less than 4 hours ago, we are fine"
      break;
    else
      echo "last update too long ago"
      exit 2;
    fi
  else
    echo "virus db not updatedy yet, waitin 5s"
    sleep 5
  fi
done


#echo "params: $@"
#if [[ -z "$1" ]] ; then 
#  echo "waiting 5s"
#  sleep 5
#  echo "reading nohup.out..."
#  tail -f nohup.out
#else
#  echo "executing $1..."
#  $1
#fi

# define shutdown helper
function shutdown() {
    echo "SIGINT received"
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
echo "adding shutdown trap to SIGINT"
trap shutdown SIGINT

#start clamav rest in background
echo "starting rest api"
java -jar /var/clamav-rest/clamav-rest-1.0.2.jar --clamd.host=localhost --clamd.port=3310 --clamd.maxfilesize=10737418240 --clamd.maxrequestsize=10737418240 2>&1


