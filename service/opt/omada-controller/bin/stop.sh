#!/usr/bin/env bash

echo "Stopping omada-controller"
docker stop omada-controller && docker rm -f omada-controller

