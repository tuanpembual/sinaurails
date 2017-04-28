#!/usr/bin/env bash

# Simple move this file into your Rails `script` folder. Also make sure you `chmod +x puma.sh`.
# Please modify the CONSTANT variables to fit your configurations.

# The script will start with config set by $PUMA_CONFIG_FILE by default

APP_NAME=sinaurails
SOCKET_FOLDER=/home/ubuntu/puma
PUMA_PID_FILE=$SOCKET_FOLDER/$APP_NAME.pid
PUMA_SOCKET=$SOCKET_FOLDER/$APP_NAME.sock

# check if puma process is running
puma_is_running() {
  if [ -S $PUMA_SOCKET ] ; then
    if [ -e $PUMA_PID_FILE ] ; then
      if cat $PUMA_PID_FILE | xargs pgrep -P > /dev/null ; then
        return 0
      else
        echo "No puma process found"
      fi
    else
      echo "No puma pid file found"
    fi
  else
    echo "No puma socket found"
  fi

  return 1
}

case "$1" in
  start)
    echo "Starting puma..."
    rm -f $PUMA_SOCKET
    mkdir -p $SOCKET_FOLDER
    bundle exec puma -e production --daemon -b unix://$PUMA_SOCKET --pidfile $PUMA_PID_FILE
    echo "done"
    ;;

  stop)
    echo "Stopping puma..."
      kill -s SIGTERM `cat $PUMA_PID_FILE`
      rm -f $PUMA_PID_FILE
      rm -f $PUMA_SOCKET
      rm -rf $SOCKET_FOLDER

    echo "done"
    ;;
  status) {
    RETVAL=`ps ax | grep puma | grep unix | wc -l`
      if [  "$RETVAL" -ge  1 ];
      then
       echo "puma running"
      else
       echo "puma stopped"
      fi
    };;

  restart)
    if puma_is_running ; then
      echo "Hot-restarting puma..."
      kill -s SIGUSR2 `cat $PUMA_PID_FILE`

      echo "Doublechecking the process restart..."
      sleep 5
      if puma_is_running ; then
        echo "done"
        exit 0
      else
        echo "Puma restart failed :/"
      fi
    fi

    echo "Trying cold reboot"
    script/puma.sh start
    ;;

  *)
    echo "Usage: script/puma.sh {start|stop|status|restart}" >&2
    ;;
esac
