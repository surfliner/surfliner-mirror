#!/bin/sh
# Tear down a docker-compose environment. Choose from dev(default) or test
usage()
{
    echo "usage: ./bin/docker-teardown [-v -e | -h]"
    echo "Options:"
    echo " -e, --env       Choose environment (dev/test)"
    echo " -v, --volumes   Deletes volumes if specified"
    echo " -h, --help      Help information you're reading now"
}

compose_env="./docker/dev/"
volumes="false"

while [ "$1" != "" ]; do
    case $1 in
      -e | --env )            compose_env="./docker/$2/"
                              ;;
      -v | --volumes )        volumes="true"
                              ;;
      -h | --help )           usage
                              exit
                              ;;
    esac
    shift
done

if [ "$volumes" = "true" ]; then
  docker-compose -f "${compose_env}docker-compose.yml" down -v
else
  docker-compose -f "${compose_env}docker-compose.yml" down
fi
