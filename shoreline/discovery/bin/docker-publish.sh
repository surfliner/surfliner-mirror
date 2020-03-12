#!/bin/sh
# publish a Shapefile in geoserver
usage()
{
    echo "usage: ./bin/docker-publish [-f | -h]"
    echo "Options:"
    echo " -f, --file    Local Filepath"
    echo " -h, --help    Help information you're reading now"
}

compose_env="./docker/dev/"
file_path=""

while [ "$1" != "" ]; do
    case $1 in
      -f | --file )           file_path="$2"
                              ;;
      -h | --help )           usage
                              exit
                              ;;
    esac
    shift
done

docker-compose -f "${compose_env}docker-compose.yml" exec app bundle exec rake shoreline:publish["${file_path}"]
