#!/bin/sh
# Build a docker-compose environment. Choose from dev(default) or test
usage()
{
    echo "usage: ./bin/docker-build [-e | -h]"
    echo "Options:"
    echo " -e, --env     Choose environment (dev/test)"
    echo " -h, --help    Help information you're reading now"
}

compose_env="./docker/dev/"

while [ "$1" != "" ]; do
    case $1 in
      -e | --env )            compose_env="./docker/$2/"
                              ;;
      -h | --help )           usage
                              exit
                              ;;
    esac
    shift
done
docker-compose -f "${compose_env}docker-compose.yml" build
