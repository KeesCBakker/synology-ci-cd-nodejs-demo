#!/bin/sh

stop_timeout=10
tag=$(cat docker-compose.yaml | grep -oP 'cicd:\s+\K\w+')
need_build=false
need_start=false
set -e;

if [ -z "$tag" ] ; then
  printf "\nNo cicd label found in docker-compose file.\n\n"
  exit 1
fi

function echo_title {
  echo ""
  echo "$1" | sed -r 's/./-/g'
  echo "$1"
  echo "$1" | sed -r 's/./-/g'
  echo ""
}

option1="$1"
option2="$2"
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

if [ $(has_option "--force" "-f") == "true" ] ; then
  need_pull=true
else
  need_pull=$(git fetch --dry-run 2>&1)
fi

if [ -n "$need_pull" ] ; then
  echo_title "PULLING LATEST SOURCE CODE"
  git reset --hard
  git pull
  need_build=true
  git log --pretty=oneline -1
elif [ -z "$(docker images | grep $tag || true)" ] ; then
  need_build=true
fi

if [ "$need_build" = true ] ; then
  if [ ! -z "$(docker-compose ps --status running -q)" ] ; then
    echo_title "STOPPING RUNNING CONTAINER"
    docker-compose stop -t $stop_timeout
  fi
  need_start=true
elif [ -z "$(docker-compose ps --status running -q)" ] ; then
  need_start=true
fi

if [ "$need_start" = false ] ; then
  printf "\nNo changes found. Container is already running.\n"

elif [ "$need_build" = true ]; then
  echo_title "BUILDING & STARTING CONTAINER"
  docker-compose up -d --build
  echo ""
else
  echo_title "STARTING CONTAINER"
  docker-compose up -d
  echo ""
fi

if [ $(has_option "--full_cleanup" "-fcu") == "true" ] ; then
  echo_title "FULL CLEAN-UP"
  docker image prune --force
elif [ $(has_option "--cleanup" "-cu") == "true" ] ; then
  echo_title "CLEAN-UP"
  docker image prune --force --filter "label=cicd=$tag"
fi

echo ""