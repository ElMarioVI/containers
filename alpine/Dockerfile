FROM alpine:edge AS base

RUN wget -O /tmp/latest-releases.yaml \
        https://dl-cdn.alpinelinux.org/alpine/edge/releases/x86_64/latest-releases.yaml && \
    export ROOTFS_URL="https://dl-cdn.alpinelinux.org/alpine/edge/releases/x86_64/$(awk '/alpine-minirootfs-/ {print $2}' /tmp/latest-releases.yaml | head -1)" && \
    echo "Descargando rootfs desde ${ROOTFS_URL}" && \
    wget -O /tmp/alpine-minirootfs.tar.gz "${ROOTFS_URL}" && \
    mkdir /rootfs && \
    tar -xzf /tmp/alpine-minirootfs.tar.gz -C /rootfs && \
    echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /rootfs/etc/apk/repositories && \
    apk --root /rootfs --no-cache upgrade -Ua

FROM scratch

COPY --from=base /rootfs /

CMD ["/bin/sh"]
