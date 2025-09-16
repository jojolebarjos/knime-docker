FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --fix-missing wget apt-transport-https ca-certificates software-properties-common && \
    wget -O "/usr/share/keyrings/xpra.asc" https://xpra.org/xpra.asc && \
    wget -O "/etc/apt/sources.list.d/xpra.sources" https://raw.githubusercontent.com/Xpra-org/xpra/master/packaging/repos/jammy/xpra.sources && \
    apt-get update && \
    apt-get install -y --fix-missing xpra && \
    apt-get install -y --fix-missing xfce4 xfce4-goodies

RUN apt install -y debian-keyring debian-archive-keyring apt-transport-https curl && \
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg && \
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list && \
    apt update && \
    apt install caddy tini

# --- KNIME-specific

RUN wget --no-verbose https://download.knime.org/analytics-platform/linux/knime_5.5.1.linux.gtk.x86_64.tar.gz -O /opt/knime.tar.gz && \
    mkdir -p /opt/knime && \
    tar -xzf /opt/knime.tar.gz -C /opt/knime --strip-components=1


# ---

COPY ./xpra.conf /etc/xpra/xpra.conf
COPY ./Caddyfile /etc/caddy/Caddyfile
COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
COPY ./background.png /usr/share/xpra/www/background.png

RUN chmod +x /usr/local/bin/entrypoint.sh

RUN useradd -m -s /bin/bash user

RUN chown -R user:user /opt/knime

# If knime.desktop is in your build context
COPY knime.desktop /usr/share/applications/knime.desktop
RUN apt-get update && apt-get install -y --no-install-recommends desktop-file-utils && \
    chmod 644 /usr/share/applications/knime.desktop && \
    update-desktop-database

RUN ln -s /opt/knime/knime /usr/local/bin/knime

USER user
WORKDIR /home/user

EXPOSE 8888

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/entrypoint.sh"]
