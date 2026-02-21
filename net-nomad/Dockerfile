FROM ghcr.io/elmariovi/alpine:latest

RUN apk add --no-cache iptables nftables iproute2 libnatpmp

COPY ./rootfs/ /

ENTRYPOINT [ "/entrypoint.sh" ]
