#!/bin/sh
name="hello"
program="program_1"
stop_timeout=10
need_build=false
need_start=false

if [ "$1" = "--force" ] || [ "$1" == "-f" ] ; then
  need_pull=true
else
  need_pull=$(git fetch --dry-run 2>&1)
fi

if [ -n "$need_pull" ] ; then
  git reset --hard
  git pull
  need_build=true
else
  image_exists=$(docker images | grep $name)
  if [ -z "$image_exists" ] ; then
    need_build=true
  fi
fi

if [ "$need_build" = true ] ; then
  docker build -t "$name" .
  docker-compose stop -t $stop_timeout
  need_start=true
else
  is_running=$(docker ps | grep $name_$program)
  if [ -z "$is_running" ] ; then
    echo "is not running"
    need_start=true
  fi
fi

if [ "$need_start" = true ] ; then
  docker-compose up -d program
else
  echo "No changes found. Container is already running."
fi