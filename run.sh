#!/bin/sh
export DOCKER_SCAN_SUGGEST=false

stop_timeout=10
need_build=false
need_start=false
option1="$1"
option2="$2"
set -e;

function echo_title {
  line=$(echo "$1" | sed -r 's/./-/g')
  printf "\n$line\n$1\n$line\n\n"
}

function has_option {
  if [ "$option1" == "$1" ] || [ "$option2" == "$1" ] ||
     [ "$option1" == "$2" ] || [ "$option2" == "$2" ] ; then
    echo "true"
  else
    echo "false"
  fi
}
# goto script directory
pushd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" > /dev/null

tag=$(cat Dockerfile | grep -oP 'cicd="\K\w+' | tail -1)
if [ -z "$tag" ] ; then
  printf "\nNo cicd LABEL found in Dockerfile.\n\n"
  exit 1
fi

if [ $(has_option "--force" "-f") == "true" ] ; then
  need_pull=true
else
  need_pull=$(git fetch --dry-run 2>&1)
fi

if [ -n "$need_pull" ] ; then
  echo_title "PULLING LATEST SOURCE CODE"
  git reset --hard
  git pull
  git log --pretty=oneline -1
  need_build=true
elif [ -z "$(docker images | grep "$tag" || true)" ] ; then
  need_build=true
fi

status=$(docker-compose ps | grep -E "Up|running" || true)
if [ "$need_build" == "true" ] ; then
  if [ ! -z "$status" ] ; then
    echo_title "STOPPING RUNNING CONTAINER"
    docker-compose stop -t $stop_timeout
  fi
  need_start=true
elif [ -z "$status" ] ; then
  need_start=true
fi

if [ "$need_start" == "false" ] ; then
  printf "\nNo changes found. Container is already running.\n"
elif [ "$need_build" == "true" ]; then
  echo_title "BUILDING & STARTING CONTAINER"
  docker-compose up -d --build
else
  echo_title "STARTING CONTAINER"
  docker-compose up -d
fi

if [ $(has_option "--full_cleanup" "-fcu") == "true" ] ; then
  echo_title "FULL CLEAN-UP"
  docker image prune --force
elif [ $(has_option "--cleanup" "-cu") == "true" ] ; then
  echo_title "CLEAN-UP"
  docker image prune --force --filter "label=cicd=$tag"
fi

echo ""