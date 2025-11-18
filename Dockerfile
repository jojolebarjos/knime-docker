FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# System + Xpra + XFCE + Caddy + Tini in as few layers as possible
RUN apt-get update && \
    apt-get install -y \
        wget curl ca-certificates apt-transport-https gnupg software-properties-common && \
    # Xpra repo
    wget -O "/usr/share/keyrings/xpra.asc" https://xpra.org/xpra.asc && \
    wget -O "/etc/apt/sources.list.d/xpra.sources" https://raw.githubusercontent.com/Xpra-org/xpra/master/packaging/repos/jammy/xpra.sources && \
    apt-get update && \
    apt-get install -y \
        xpra xfce4 xfce4-goodies && \
    # Caddy repo
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' \
        | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg && \
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' \
        | tee /etc/apt/sources.list.d/caddy-stable.list && \
    apt-get update && \
    apt-get install -y caddy tini && \
    # Clean apt caches
    rm -rf /var/lib/apt/lists/*


# RUN apt-get update && \
#     apt-get install -y --fix-missing wget apt-transport-https ca-certificates software-properties-common && \
#     wget -O "/usr/share/keyrings/xpra.asc" https://xpra.org/xpra.asc && \
#     wget -O "/etc/apt/sources.list.d/xpra.sources" https://raw.githubusercontent.com/Xpra-org/xpra/master/packaging/repos/jammy/xpra.sources && \
#     apt-get update && \
#     apt-get install -y --fix-missing xpra && \
#     apt-get install -y --fix-missing xfce4 xfce4-goodies

# RUN apt install -y debian-keyring debian-archive-keyring apt-transport-https curl && \
#     curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg && \
#     curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list && \
#     apt update && \
#     apt install caddy tini


# KNIME - download to /tmp and remove archive after extraction
RUN wget --no-verbose \
        https://download.knime.org/analytics-platform/linux/knime_5.5.2.linux.gtk.x86_64.tar.gz \
        -O /tmp/knime.tar.gz && \
    mkdir -p /opt/knime && \
    tar -xzf /tmp/knime.tar.gz -C /opt/knime --strip-components=1 && \
    rm -f /tmp/knime.tar.gz

COPY ./xpra.conf /etc/xpra/xpra.conf
COPY ./Caddyfile /etc/caddy/Caddyfile
COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
COPY ./background.png /usr/share/xpra/www/background.png
COPY ./extensions.sh /usr/local/bin/extensions.sh

RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/extensions.sh && \
    useradd -m -s /bin/bash user && \
    chown -R user:user /opt/knime && \
    ln -s /opt/knime/knime /usr/local/bin/knime

# Install KNIME extensions (if this script is heavy it will still add size)
RUN /usr/local/bin/extensions.sh

USER user
WORKDIR /home/user

EXPOSE 8888

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/entrypoint.sh"]
