##
## PRE BUILD
##

ARG REGISTRY
FROM ${REGISTRY}/dropbear:0.0.1

##
## MAIN
##

LABEL maintainer="Max Woelfing (ff0x@this-is-fine.io)"
LABEL name="gitolite" version="0.0.1"
LABEL description="Alpine Linux running gitolite with support for S3 backups using jgit"

##
## CONFIGURATION
##

ARG ARCH
ARG JGIT_VERSION="5.7.0.202003110725-r"

ENV DAEMON_USER="git" \
    DAEMON_GROUP="git"
ENV DAEMON_UID="${DAEMON_UID:-10000}" \
    DAEMON_GID="${DAEMON_GID:-10000}"

##
## ROOTFS
##

COPY ["rootfs", "/"]

##
## PREPARATION
##

ADD ["https://repo.eclipse.org/content/groups/releases//org/eclipse/jgit/org.eclipse.jgit.pgm/${JGIT_VERSION}/org.eclipse.jgit.pgm-${JGIT_VERSION}.sh", "/usr/bin/jgit"]
RUN addgroup -g 10000 -S ${DAEMON_GROUP} && adduser -u 10000 -S -h /var/lib/${DAEMON_USER} -G ${DAEMON_GROUP} -s /bin/sh ${DAEMON_USER} \
&& chmod 755 /usr/bin/jgit && apk add --update --no-cache gitolite openjdk10-jre-headless python \
&& mkdir -p /var/lib/git/.gitolite/logs

##
## RUNTIME
##

#USER ${DAEMON_USER}
WORKDIR /var/lib/${DAEMON_USER}

##
## VOLUMES
##

# Volume used to store all Gitolite data (keys, config and repositories), initialized on first run
VOLUME ["/var/lib/git"]

##
## PORTS
##

EXPOSE 22

##
## INIT
##

ENTRYPOINT ["/sbin/tini", "--", "/init"]
