FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN \
    apt-get update && \
    apt-get install --fix-missing -y \
        xpra \
        xfce4 \
        xserver-xorg-video-dummy \
        xauth \
        wget \
        ca-certificates && \
    apt-get install --fix-missing -y \
        xfce4-terminal && \
    rm -rf /var/lib/apt/lists/*

RUN \
    wget -nv https://download.knime.org/analytics-platform/linux/knime_5.4.4.linux.gtk.x86_64.tar.gz -O /tmp/knime.tar.gz && \
    mkdir -p /opt/knime && \
    tar -xzf /tmp/knime.tar.gz -C /opt/knime --strip-components=1 && \
    rm /tmp/knime.tar.gz

RUN \
    useradd -m -U -s /bin/bash user

USER user

WORKDIR /home/user

EXPOSE 14500

CMD ["xpra", "start", \
    "--start-child=xfce4-session", \
    "--bind-tcp=0.0.0.0:14500", \
    "--html=on", \
    "--exit-with-children", \
    "--daemon=no"]
