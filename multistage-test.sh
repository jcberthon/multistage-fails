#!/bin/bash

set -eux

cd baseline
docker build -t jcberthon/baseline:latest .

cd ../level1
docker build -t jcberthon/level1:latest .

cd ../level2
docker build -t jcberthon/level2:latest .

cd ../level3
docker build -t jcberthon/level3:latest .

docker run --rm jcberthon/level3:latest
