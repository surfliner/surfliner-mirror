#!/bin/sh
docker run --rm --volume "`pwd`:/data" --entrypoint "bin/pandoc.sh" --user `id -u`:`id -g` pandoc/latex:2.6
