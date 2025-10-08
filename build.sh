#!/bin/sh

TAG=service

sudo podman build . -t  quay.io/fedora/fedora-bootc:$TAG
sudo bootc switch --transport containers-storage quay.io/fedora/fedora-bootc:$TAG
#sudo bootc switch --soft-reboot auto --transport containers-storage quay.io/fedora/fedora-bootc:$TAG
#  && reboot

