FROM debian:13-slim

ARG PROTON_VERSION

ENV PROTON_VERSION=${PROTON_VERSION}

RUN dpkg --add-architecture i386 \
    && apt update \
    && apt install --no-install-recommends -y \
        procps \
        ca-certificates \
        winbind \
        dbus \
        libfreetype6 \
        curl \
        jq \
        locales \
        lib32gcc-s1 \
        python3 \
    && echo 'LANG="en_US.UTF-8"' > /etc/default/locale \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen \
    && rm -f /etc/machine-id \
    && dbus-uuidgen --ensure=/etc/machine-id \
    && rm -rf /var/lib/apt/lists/* \
    && apt clean \
    && apt autoremove -y \
    && mkdir -p "/steamcmd/compatibilitytools.d" \
    && curl -sqL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar zxvf - -C /steamcmd \
    && chmod +x /steamcmd/steamcmd.sh \
    && /steamcmd/steamcmd.sh +quit \
    && mkdir -p /root/.steam \
    && ln -s /steamcmd/linux64 /root/.steam/sdk64 \
    && ln -s /root/.steam/sdk64/steamclient.so /root/.steam/sdk64/steamservice.so \
    && ln -s /steamcmd/linux32 /root/.steam/sdk32 \
    && ln -s /root/.steam/sdk32/steamclient.so /root/.steam/sdk32/steamservice.so \
    && curl -sqL "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton${PROTON_VERSION}/GE-Proton${PROTON_VERSION}.tar.gz" | tar zxvf - -C "/steamcmd/compatibilitytools.d/"

COPY ./rootfs/ /

ENTRYPOINT [ "/entrypoint.sh" ]
