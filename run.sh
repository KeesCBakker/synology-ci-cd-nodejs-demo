#!/bin/sh
tag="hello" # tag of your container
service="web" # docker-compose section to start

stop_timeout=10
need_build=false
need_start=false
full_docker_name="$tag$service1"
set -e;

function echo_title {
  echo ""
  echo "$1" | sed -r 's/./-/g'
  echo "$1"
  echo "$1" | sed -r 's/./-/g'
  echo ""
}

# goto script directory
pushd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ "$1" = "--force" ] || [ "$1" == "-f" ] ; then
  need_pull=true
else
  need_pull=$(git fetch --dry-run 2>&1)
fi

if [ -n "$need_pull" ] ; then
  echo_title "PULLING LATEST SOURCE CODE"
  git reset --hard
  git pull
  need_build=true
else
  image_exists=$(docker images | grep $tag || true)
  if [ -z "$image_exists" ] ; then
    need_build=true
  fi
fi

if [ "$need_build" = true ] ; then
  echo_title "BUILDING CONTAINER"
  docker build -t "$tag" .
  echo_title "STOPPING RUNNING CONTAINER"
  docker-compose stop -t $stop_timeout
  need_start=true
else
  is_running=$(docker ps | grep $full_docker_name || true)
  if [ -z "$is_running" ] ; then
    need_start=true
  fi
fi

if [ "$need_start" = true ] ; then
  echo_title "STARTING CONTAINER"
  docker-compose up -d $service
  printf "\nContainer is up and running.\n\n"
else
  echo "No changes found. Container is already running."
fi
