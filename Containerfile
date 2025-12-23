ARG ALPINE_VERSION=3.22
FROM docker.io/gautada/alpine:$ALPINE_VERSION as CONTAINER

ARG IMAGE_NAME=neovim
ARG IMAGE_VERSION=0.11.5
ARG PACKAGE_VERSION=r0

# ╭――――――――――――――――――――╮
# │ METADATA           │
# ╰――――――――――――――――――――╯
LABEL org.opencontainers.image.title="${IMAGE_NAME}"
LABEL org.opencontainers.image.description="A host for neovim server."
LABEL org.opencontainers.image.url="https://hub.docker.com/r/gautada/neovim"
LABEL org.opencontainers.image.source="https://github.com/gautada/neovim"
LABEL org.opencontainers.image.version="${IMAGE_VERSION}"
LABEL org.opencontainers.image.license="Upstream"

# ╭――――――――――――――――――――╮
# │ USER               │
# ╰――――――――――――――――――――╯
ARG USER=nvim
RUN /usr/sbin/usermod -l $USER alpine \
&& /usr/sbin/usermod -d /home/$USER -m $USER \ 
&& /usr/sbin/groupmod -n $USER alpine \
&& /bin/echo "$USER:$USER" | /usr/sbin/chpasswd 

# ╭――――――――――――――――――――╮
# │ BACKUP             │
# ╰――――――――――――――――――――╯
# COPY backup /etc/container/backup

# ╭――――――――――――――――――――╮
# │ ENTRYPOINT         │
# ╰――――――――――――――――――――╯
# Overwrite upstream entrypoint
COPY entrypoint.sh /usr/bin/container-entrypoint

# ╭――――――――――――――――――――╮
# │ APPLICATION        │
# ╰――――――――――――――――――――╯
RUN /bin/sed -i 's|dl-cdn.alpinelinux.org/alpine/|mirror.math.princeton.edu/pub/alpinelinux/|g' /etc/apk/repositories \
 && /sbin/apk add --no-cache neovim s6

COPY nvim-run /etc/services.d/nvim/run

# ╭――――――――――――――――――――╮
# │ CONTAINER          │
# ╰――――――――――――――――――――╯
USER $USER
VOLUME /mnt/volumes/backup
VOLUME /mnt/volumes/configmaps
VOLUME /mnt/volumes/container
VOLUME /mnt/volumes/secrets
EXPOSE 8080/tcp
WORKDIR /home/$USER

# ENTRYPOINT ["/sbin/tini", "--"]
# CMD ["nvim", "--headless", "--listen", "0.0.0.0:6074"]
# s6 init is PID 1
ENTRYPOINT ["/init"]
