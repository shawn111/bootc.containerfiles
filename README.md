# Shawn's personal pc image

- orignal: https://fedoraproject.org/atomic-desktops/silverblue/
  - rpm-ostree rebase fedora:fedora/42/x86_64/silverblue
  - bootc
    - bootc switch quay.io/fedora/fedora-silverblue:44
    - bootc switch quay.io/fedora/fedora-bootc:44
    - bootc switch --transport containers-storage quay.io/fedora/fedora-bootc:local

## Plan
- bootc support for soft reboots
  - https://github.com/bootc-dev/bootc/issues/1350

- virsh

## Need to fix
- systemd-remount-fs.service

```
Oct 08 21:47:13 fedora systemd-remount-fs[938]: mount: /: fsconfig() failed: overlay: No changes allowed in reconfigure.
Oct 08 21:47:13 fedora systemd-remount-fs[938]:        dmesg(1) may have more information after failed mount system call.
Oct 08 21:47:13 fedora systemd[1]: Starting systemd-remount-fs.service - Remount Root and Kernel File Systems...
Oct 08 21:47:13 fedora systemd[1]: systemd-remount-fs.service: Main process exited, code=exited, status=1/FAILURE
Oct 08 21:47:13 fedora systemd[1]: systemd-remount-fs.service: Failed with result 'exit-code'.
Oct 08 21:47:13 fedora systemd[1]: Failed to start systemd-remount-fs.service - Remount Root and Kernel File Systems.
```

- systemd-sysusers.service

```
Oct 08 21:47:13 fedora systemd-sysusers[940]: Creating group 'qat' with GID 974.
Oct 08 21:47:13 fedora systemd-sysusers[940]: Creating group 'dnsmasq' with GID 973.
Oct 08 21:47:13 fedora systemd-sysusers[940]: Creating user 'dnsmasq' (Dnsmasq DHCP and DNS server) with UID 973 and GID 9>
Oct 08 21:47:13 fedora systemd-sysusers[940]: Creating group 'gluster' with GID 972.
Oct 08 21:47:13 fedora systemd-sysusers[940]: Creating user 'gluster' (GlusterFS daemons) with UID 972 and GID 972.
Oct 08 21:47:13 fedora systemd-sysusers[940]: Creating user 'qemu' (qemu user) with UID 107 and GID 107.
Oct 08 21:47:13 fedora systemd-sysusers[940]: /etc/gshadow: Group "brlapi" already exists.
Oct 08 21:47:13 fedora systemd[1]: systemd-sysusers.service: Main process exited, code=exited, status=1/FAILURE
Oct 08 21:47:13 fedora systemd[1]: systemd-sysusers.service: Failed with result 'exit-code'.
Oct 08 21:47:13 fedora systemd[1]: Failed to start systemd-sysusers.service - Create System Users.
```
