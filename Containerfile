FROM quay.io/fedora/fedora-bootc:44

RUN dnf install -y --setopt=install_weak_deps=False \
     pciutils \
     NetworkManager-wifi \
     evtest \ 
     wget \ 
     curl \ 
     libvirt \
     qemu-kvm

COPY logind.conf /usr/lib/systemd/logind.conf

RUN dnf5 install -y 'dnf5-command(copr)'
RUN dnf copr -y enable varlad/zellij
RUN dnf install -y --setopt=install_weak_deps=False \
     atuin \
     fish \
     zellij


COPY ngrok.service /usr/lib/systemd/system/ngrok.service
RUN ln -s ../ngrok.service /usr/lib/systemd/system/multi-user.target.wants/ngrok.service

RUN ln -s ../sshd.conf /usr/lib/systemd/system/multi-user.target.wants/sshd.conf
# https://ngrok.com/docs/guides/device-gateway/linux
RUN wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
RUN tar xvzf ./ngrok-v3-stable-linux-amd64.tgz -C /usr/bin
RUN rm ./ngrok-v3-stable-linux-amd64.tgz

RUN dnf install -y --setopt=install_weak_deps=False \
     git

RUN dnf clean all
