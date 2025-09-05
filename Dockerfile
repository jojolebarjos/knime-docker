FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --fix-missing apt-transport-https ca-certificates software-properties-common wget && \
    wget -O "/usr/share/keyrings/xpra.asc" https://xpra.org/xpra.asc && \
    wget -O "/etc/apt/sources.list.d/xpra.sources" https://raw.githubusercontent.com/Xpra-org/xpra/master/packaging/repos/jammy/xpra.sources && \
    apt-get update && \
    apt-get install -y --fix-missing xpra && \
    apt-get install -y --fix-missing xfce4 xfce4-goodies

# --- KNIME-specific

RUN wget --no-verbose https://download.knime.org/analytics-platform/linux/knime_5.4.4.linux.gtk.x86_64.tar.gz -O /opt/knime.tar.gz && \
    mkdir -p /opt/knime && \
    tar -xzf /opt/knime.tar.gz -C /opt/knime --strip-components=1

# ---

COPY ./xpra.conf /etc/xpra/xpra.conf
COPY ./background.png /usr/share/xpra/www/background.png

RUN useradd -m -s /bin/bash user
USER user
WORKDIR /home/user

EXPOSE 14500

ENTRYPOINT  ["/usr/bin/tini", "--" ]

CMD ["xpra", "seamless", "--daemon=no", "--mdns=no", "--http=yes", "--systemd-run=no", "--webcam=no", "--no-audio", "--printing=no", "--clipboard=yes", "--clipboard-direction=both", "--exit-with-children=no", "--notifications=no", "--bind-tcp=0.0.0.0:14500", "--start=xterm"]
