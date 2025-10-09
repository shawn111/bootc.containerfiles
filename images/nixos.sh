#!/bin/sh

virt-install --name=nixos \
--memory=8196 --vcpus=2 \
--cdrom=images/latest-nixos-minimal-x86_64-linux.iso \
--disk /tmp/nixos.qcow2,device=disk,bus=virtio,size=8 \
--os-type=generic  \
--nographics \
--console pty,target_type=serial
