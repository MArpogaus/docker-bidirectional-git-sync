FROM alpine

ENV LFS_VERSION 1.0.2
ENV GIT_SYNC_BRANCH master

RUN apk add --update git openssh busybox-suid

RUN apk add --update --virtual build-dependencies curl && \
    curl -sLO https://github.com/github/git-lfs/releases/download/v${LFS_VERSION}/git-lfs-linux-amd64-${LFS_VERSION}.tar.gz && \
    tar xzf /git-lfs-linux-amd64-${LFS_VERSION}.tar.gz -C / && \
    mv /git-lfs-${LFS_VERSION}/git-lfs /usr/local/bin/ && \
    git-lfs init && \
    apk del build-dependencies && \
    rm -rf /git-lfs-${LFS_VERSION} && \
    rm -rf /git-lfs-linux-amd64-${LFS_VERSION}.tar.gz && \
    rm -rf /var/cache/apk/*

ENV HOME=/tmp
ENV GIT_SYNC_ROOT=$HOME

RUN mkdir -p ${GIT_SYNC_ROOT}

WORKDIR ${GIT_SYNC_ROOT}

ENV GIT_SYNC_REPO=${GIT_SYNC_REPO:-}
ENV GIT_SYNC_WAIT=${GIT_SYNC_WAIT:-15}
ENV GIT_SYNC_BRANCH=${GIT_SYNC_BRANCH:-}
ENV GIT_SYNC_DEST=${GIT_SYNC_DEST:-git}
ENV GIT_SYNC_USER=${GIT_SYNC_USER:-git-sync}
ENV GIT_SYNC_EMAIL=${GIT_SYNC_EMAIL:-git-sync@example.com}

COPY entrypoint.sh /
COPY git-sync.sh /usr/bin/git-sync
 
ENTRYPOINT ["/entrypoint.sh"]
CMD ["crond -f -d 0"]
