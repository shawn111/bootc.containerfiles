# Shawn's personal pc image

- orignal: https://fedoraproject.org/atomic-desktops/silverblue/
  - rpm-ostree rebase fedora:fedora/42/x86_64/silverblue
  - bootc
    - bootc switch quay.io/fedora/fedora-bootc:44
    - bootc switch --transport containers-storage quay.io/fedora/fedora-bootc:local

## Plan
- bootc support for soft reboots
  - https://github.com/bootc-dev/bootc/issues/1350
