FROM ghcr.io/swissdatasciencecenter/renku-frontend-buildpacks/base-image:0.0.6

ARG DISTRO="jammy"
ARG REPO="xpra"

USER root

RUN sudo apt-get update && \
    apt-get install -y apt-transport-https ca-certificates software-properties-common && \
    wget -O "/usr/share/keyrings/xpra.asc" https://xpra.org/xpra.asc && \
    wget -O "/etc/apt/sources.list.d/xpra.sources" https://raw.githubusercontent.com/Xpra-org/xpra/master/packaging/repos/$DISTRO/$REPO.sources && \
    apt-get update && \
    apt-get install -y xpra && \
    apt-get install -y xfce4 xfce4-goodies

USER renku

RUN wget https://download.knime.org/analytics-platform/linux/knime_5.4.4.linux.gtk.x86_64.tar.gz -O $HOME/knime.tar.gz && \
    mkdir -p $HOME/knime && \
    tar -xzf $HOME/knime.tar.gz -C $HOME/knime --strip-components=1

CMD ["xpra", "seamless", "--start=xterm", "--ssl=no", "--http=yes", "--daemon=no", "--bind-tcp=0.0.0.0:14500", "--systemd-run=no", "--no-audio", "--webcam=no", "--printing=no", "--clipboard=yes", "--clipboard-direction=yes", "--exit-with-children=no"]
