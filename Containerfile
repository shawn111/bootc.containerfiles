# Build bootc from the current git into a c9s-bootc container image.
# Use e.g. --build-arg=base=quay.io/fedora/fedora-bootc:40 to target
# Fedora instead.
#
# You can also generate an image with cloud-init and other dependencies
# with `--build-arg=tmt` which is intended for use particularly via
# https://tmt.readthedocs.io/en/stable/
ARG base=quay.io/centos-bootc/centos-bootc:stream9
ARG target=quay.io/openeuler/openeuler:24.03-lts


#############################
# Prepare ostree/composefs rpms
#############################

FROM $target as rpms
RUN dnf install -y 'dnf-command(download)' 'dnf-command(builddep)' rpm-build rpmdevtools
RUN dnf download -y --source ostree

RUN mkdir -p /root/rpmbuild/SOURCES


#############################
## Collect source rpm
#############################
RUN curl -L -O  https://download.fedoraproject.org/pub/fedora/linux/development/rawhide/Everything/source/tree/Packages/c/composefs-1.0.6-1.fc42.src.rpm
### rpm --noplugins for ima 
# error: ima: could not apply signature on '/root/rpmbuild/SOURCES/composefs-1.0.6.tar.xz;67050ad9': Operation not permitted
RUN rpm --noplugins -ihv composefs-1.0.6-1.fc42.src.rpm
RUN rpm -ihv ostree*.src.rpm


#############################
## Install builddep
#############################
RUN dnf -y builddep --skip-unavailable /root/rpmbuild/SPECS/composefs.spec
RUN dnf -y builddep /root/rpmbuild/SPECS/ostree.spec


#############################
## Patch specs
#############################

# Force patch ostree version
RUN sed -i s/^Version:.\*/Version:\ 2024\.8/ /root/rpmbuild/SPECS/ostree.spec
RUN sed -i s/^Release:.\*/Release:\ 1%{dist}/ /root/rpmbuild/SPECS/ostree.spec

# Force disable composefs man that require go-md2man
RUN sed -i s/-Dman=enabled/-Dman=disabled/   /root/rpmbuild/SPECS/composefs.spec 

#############################
## Download required SOURCES, could prepare as _sources/*
#############################
COPY ./_sources/* /root/rpmbuild/SOURCES
WORKDIR /root/rpmbuild/SOURCES
RUN spectool -g -R  ../SPECS/ostree.spec

#############################
## rpmbuild -ba
#############################
RUN rpmbuild --without=man -ba /root/rpmbuild/SPECS/composefs.spec
RUN dnf -y install /root/rpmbuild/RPMS/*/composefs*.rpm
RUN rpmbuild -ba /root/rpmbuild/SPECS/ostree.spec


#############################
# Prepare kernel/initrd
#############################
FROM $target as kernel

#############################
## install kernel dracut
#############################
RUN dnf install -y kernel systemd
RUN dnf install -y dracut

#############################
## install required ostree/composefs
#############################
COPY --from=rpms /root/rpmbuild/RPMS/*/*.rpm /tmp
RUN dnf install -y /tmp/ostree-*.*.rpm /tmp/composefs-*.*.rpm
RUN rm /tmp/*.rpm

#############################
## prepare dracut modules (ostree) for prepare-sysroot
#############################
RUN mkdir -p /usr/lib/dracut/modules.d/98ostree
COPY 98ostree-module-setup.sh /usr/lib/dracut/modules.d/98ostree/module-setup.sh

#############################
## rebuild dracut
#############################
RUN dracut --force -a ostree -N --install-optional "/usr/sbin/pivot_root" --kver $(rpm -q kernel --queryformat "%{VERSION}-%{RELEASE}.%{ARCH}\n")

#############################
## relocate ostree kernel/initrd path
#############################
RUN mv /boot/vmlinuz-* /usr/lib/modules/$(rpm -q kernel --queryformat "%{VERSION}-%{RELEASE}.%{ARCH}")/vmlinuz
RUN mv /boot/initramfs-* /usr/lib/modules/$(rpm -q kernel --queryformat "%{VERSION}-%{RELEASE}.%{ARCH}")/initramfs.img


#############################
# Prepare target OS
#############################
FROM $target as target

# kernel/initrd/modules
COPY --from=kernel /usr/lib/modules/ /usr/lib/modules/

# prepare etc
RUN cp -r /etc /usr/etc
RUN cp -f /etc/os-release /usr/lib/os-release

# prepare ostree / composefs
COPY --from=rpms /root/rpmbuild/RPMS/*/*.rpm /tmp
RUN dnf install -y /tmp/ostree-*-1.*.rpm /tmp/composefs-*.*.rpm
RUN rm /tmp/*.rpm

# prepare os required
RUN dnf install -y cloud-init sudo \
    iputils openssh \
    dhclient

## mkdir /var/log/audit << to avoid auditd issue
RUN dnf install -y NetworkManager

RUN sed -i '/Restart=on-failure/d' /usr/lib/systemd/system/NetworkManager.service
RUN sed -i '/RestartSec=10s/d' /usr/lib/systemd/system/NetworkManager.service
RUN dnf install -y passwd 
RUN dnf install -y podman netavark

## for rpmdb
RUN mv /var/lib/rpm /usr/share/rpm
RUN ln -s /usr/share/rpm /var/lib/rpm
RUN mkdir -p /var/roothome
RUN mkdir -p /var/lib/selinux/targeted/

## bootc kargs
RUN mkdir -p /usr/lib/bootc/kargs.d
RUN echo 'kargs = ["console=ttyS0", "selinux=0"]' > /usr/lib/bootc/kargs.d/99-console.toml

## sysuser.d
### user: dbus
RUN echo '#Type  Name  ID  GECOS                 Home directory  Shell' > /usr/lib/sysusers.d/dbus.conf
RUN echo 'u      dbus  81  "System Message Bus"  -               -'    >> /usr/lib/sysusers.d/dbus.conf


#############################
##### bootc (ostree based image) for OStree requirement
#############################
FROM $base

RUN rm -rf /var
RUN rm -rf /etc || true
RUN mv /usr /usr_
COPY --from=target /usr /usr
COPY --from=target /etc /etc
COPY --from=target /var /var
RUN rm -rf /usr_
