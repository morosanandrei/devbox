#!/bin/bash

set -e

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt dist-upgrade
sudo apt-get install ubuntu-release-upgrader-core
sudo do-release-upgrade