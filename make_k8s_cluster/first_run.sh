#!/bin/bash
DEBIAN_FRONTEND=noninteractive
export DEBIAN_FRONTEND
sudo apt-get --reinstall install linux-headers-`uname -r`
/setup_falco.sh |tee /first_run.log
