FROM quay.io/fedora/fedora-bootc:44

RUN dnf install -y --setopt=install_weak_deps=False \
     pciutils \
     evtest \ 
     wget \ 
     curl \ 
     libvirt \
     virt-install \
     git \
     qemu-kvm

# replace systemd-networkd to NetworkManager
# https://hesamyan.medium.com/switching-from-networkmanager-to-systemd-networkd-dcbda0b15056
# https://wiki.archlinux.org/title/Systemd-networkd
RUN dnf install -y --setopt=install_weak_deps=False \
     systemd-networkd
RUN dnf remove -y NetworkManager
RUN systemctl enable systemd-networkd

# glibc-langpack-en to fix "locale: Cannot set LC_CTYPE to default locale: No such file or directory"
RUN dnf install -y glibc-langpack-en

# for laptop
COPY logind.conf /usr/lib/systemd/logind.conf

### k8s kind
RUN curl -Lo /usr/bin/kind https://kind.sigs.k8s.io/dl/v0.30.0/kind-linux-amd64 && chmod +x /usr/bin/kind
RUN curl -Lo /usr/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && chmod +x /usr/bin/kubectl
RUN curl -Lo /usr/bin/kubie https://github.com/sbstp/kubie/releases/download/v0.26.0/kubie-linux-amd64 && chmod +x /usr/bin/kubie
RUN curl -Lo /usr/bin/clusterctl https://github.com/kubernetes-sigs/cluster-api/releases/download/v1.11.2/clusterctl-linux-amd64 && chmod +x /usr/bin/clusterctl
RUN curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | HELM_INSTALL_DIR=/usr/bin bash


### bootc best practice
# https://docs.fedoraproject.org/en-US/bootc/building-containers
#RUN ln -s ../sshd.conf /usr/lib/systemd/system/multi-user.target.wants/sshd.conf
RUN systemctl enable sshd podman libvirtd

####################################################################################

RUN dnf5 install -y 'dnf5-command(copr)'
RUN dnf copr -y enable varlad/zellij
RUN dnf install -y --setopt=install_weak_deps=False \
     atuin \
     fish \
     zellij

### ngrok
# https://ngrok.com/docs/guides/device-gateway/linux
RUN wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
RUN tar xvzf ./ngrok-v3-stable-linux-amd64.tgz -C /usr/bin
RUN rm ./ngrok-v3-stable-linux-amd64.tgz
COPY ngrok.service /usr/lib/systemd/system/ngrok.service
RUN ln -s ../ngrok.service /usr/lib/systemd/system/multi-user.target.wants/ngrok.service

### npm & gemini
RUN dnf install -y --setopt=install_weak_deps=False \
     nodejs-npm

ENV NPM_CONFIG_CACHE=/tmp/.npm_cache
ENV NPM_CONFIG_LOGFILE=/tmp/.npm_logs/npm-debug.log
RUN mkdir -p /tmp/.npm_cache /tmp/.npm_logs
RUN npm cache clean --force
RUN npm install --loglevel=verbose -y -g @google/gemini-cli

########## clean env
RUN rm -rf /tmp/*
RUN dnf clean all
