#!/bin/sh

echo "******************************************************************"
echo " HELIOS2010"
echo " National Institute of Advanced Industrial Science and Technology"
echo " Created by Hidehisa Akiyama and Hiroki Shimora"
echo " Copyright 2000-2007.  Hidehisa Akiyama"
echo " Copyright 2007-2010.  Hidehisa Akiyama and Hiroki Shimora"
echo " All rights reserved."
echo "******************************************************************"

DIR=`dirname $0`

player="${DIR}/helios_player"
coach="${DIR}/helios_coach"
teamname="HELIOS2010"
host="localhost"
port=6000
coach_port=""

player_conf="${DIR}/player.conf"
config_dir="${DIR}/formations-4231"
param_file="${DIR}/parameters/params"

coach_conf="${DIR}/coach.conf"

sleepprog=sleep
goaliesleep=1
sleeptime=0

usage()
{
  (echo "Usage: $0 [options]"
   echo "Available options:"
   echo "      --help                   prints this"
   echo "  -h, --host HOST              specifies server host (default: localhost)"
   echo "  -p, --port PORT              specifies server port (default: 6000)"
   echo "  -P  --coach-port PORT        specifies server port for online coach (default: 6002)"
   echo "  -t, --teamname TEAMNAME      specifies team name") 1>&2
}

while [ $# -gt 0 ]
do
  case $1 in

    --help)
      usage
      exit 0
      ;;

    -h|--host)
      if [ $# -lt 2 ]; then
        usage
        exit 1
      fi
      host="${2}"
      shift 1
      ;;

    -p|--port)
      if [ $# -lt 2 ]; then
        usage
        exit 1
      fi
      port="${2}"
      shift 1
      ;;

    -P|--coach-port)
      if [ $# -lt 2 ]; then
        usage
        exit 1
      fi
      coach_port="${2}"
      shift 1
      ;;

    -t|--teamname)
      if [ $# -lt 2 ]; then
        usage
        exit 1
      fi
      teamname="${2}"
      shift 1
      ;;

    *)
      echo 1>&2
      echo "invalid option \"${1}\"." 1>&2
      echo 1>&2
      usage
      exit 1
      ;;
  esac

  shift 1
done

if [ X"${coach_port}" = X'' ]; then
  coach_port=`expr ${port} + 2`
fi

playeropt="--player-config ${player_conf} --config_dir ${config_dir}"
playeropt="${playeropt} --param-file ${param_file}"
playeropt="${playeropt} -h ${host} -p ${port} -t ${teamname}"

$player ${playeropt} -g &
$sleepprog $goaliesleep

i=2
while [ $i -le 11 ] ; do
  $player ${playeropt} &
  $sleepprog $sleeptime

  i=`expr $i + 1`
done

coachopt="--coach-config ${coach_conf}"
coachopt="${coachopt} -h ${host} -p ${coach_port} -t ${teamname}"

$coach ${coachopt} &
