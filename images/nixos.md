# download https://nixos.org/download/

https://www.technicalsourcery.net/posts/nixos-in-libvirt/
https://channels.nixos.org/nixos-25.05/latest-nixos-minimal-x86_64-linux.iso

https://discourse.nixos.org/t/solved-how-to-install-nixos-text-only-in-libvirt/14343

```
virt-install --name=nixos \
--memory=8196 --vcpus=2 \
--cdrom=images/latest-nixos-minimal-x86_64-linux.iso \
--disk /tmp/nixos.qcow2,device=disk,bus=virtio,size=8 \
--os-type=generic  \
--nographics \
--console pty,target_type=serial
```

```
virsh dumpxml --domain nixos > nixos.xml
```
