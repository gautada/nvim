ARG ALPINE_VERSION=3.23
FROM docker.io/gautada/alpine:$ALPINE_VERSION as CONTAINER

ARG IMAGE_NAME=neovim

# ╭――――――――――――――――――――╮
# │ METADATA           │
# ╰――――――――――――――――――――╯
LABEL org.opencontainers.image.title="${IMAGE_NAME}"
LABEL org.opencontainers.image.description="A host for neovim server."
LABEL org.opencontainers.image.url="https://hub.docker.com/r/gautada/neovim"
LABEL org.opencontainers.image.source="https://github.com/gautada/neovim"
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
# COPY entrypoint.sh /usr/bin/container-entrypoint

# ╭――――――――――――――――――――╮
# │ PRIVILEGES         │
# ╰――――――――――――――――――――╯
COPY privileges /etc/container/privileges

# ╭――――――――――――――――――――╮
# │ CONTAINER          │
# ╰――――――――――――――――――――╯
COPY neovim.s6 /etc/services.d/neovim/run
RUN /bin/sed -i 's|dl-cdn.alpinelinux.org/alpine/|mirror.math.princeton.edu/pub/alpinelinux/|g' /etc/apk/repositories \
 && /sbin/apk add --no-cache neovim stow
EXPOSE 6074/tcp
USER ${USER}
WORKDIR /home/${USER}/.local/share/dotfiles
RUN git clone https://github.com/gautada/dotfiles.git public
WORKDIR /home/${USER}
USER root
RUN chown ${USER}:${USER} -R /home/${USER}
