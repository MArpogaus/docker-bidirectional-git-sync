FROM alpine:3.2

ENV LFS_VERSION 1.0.2
ENV GIT_SYNC_BRANCH master

COPY git-sync.sh / 
RUN apk add --update git openssh
RUN apk add --update --virtual build-dependencies curl && \
    curl -sLO https://github.com/github/git-lfs/releases/download/v1.0.2/git-lfs-linux-amd64-${LFS_VERSION}.tar.gz && \
    tar xzf /git-lfs-linux-amd64-${LFS_VERSION}.tar.gz -C / && \
    mv /git-lfs-${LFS_VERSION}/git-lfs /usr/local/bin/ && \
    rm -rf /git-lfs-${LFS_VERSION} && \
    rm -rf /git-lfs-linux-amd64-${LFS_VERSION}.tar.gz && \
    git-lfs init && \
    apk del build-dependencies && \
    rm -rf /var/cache/apk/*
