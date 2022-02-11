#!/bin/bash

PWD=$(pwd)

docker run -it -v "$PWD":/home/ansible rabbitmq /bin/bash
