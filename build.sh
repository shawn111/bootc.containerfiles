#!/bin/sh

TAG=$(date +%y%m%d.%H%M)

sudo podman build . -t  quay.io/fedora/fedora-bootc:$TAG
sudo bootc switch --transport containers-storage quay.io/fedora/fedora-bootc:$TAG && reboot
