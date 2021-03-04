FROM alpine

ENV ARCH=amd64

RUN apk add --update --no-cache git openssh incron curl && \
    apk add --no-cache --virtual build-deps libc-dev go gcc libgcc musl-dev

ENV HOME=/tmp
ENV GIT_SYNC_ROOT=$HOME

RUN mkdir -p ${GIT_SYNC_ROOT}

WORKDIR ${GIT_SYNC_ROOT}

# ADD GIT LFS
ENV LFS_VERSION=1.0.2
RUN curl -sLO https://github.com/github/git-lfs/releases/download/v${LFS_VERSION}/git-lfs-linux-${ARCH}-${LFS_VERSION}.tar.gz && \
    tar xzf git-lfs-linux-${ARCH}-${LFS_VERSION}.tar.gz && \
    install git-lfs-${LFS_VERSION}/git-lfs /usr/local/bin/ && \
    git-lfs init && \
    rm -rf git-lfs-${LFS_VERSION} && \
    rm -rf git-lfs-linux-${ARCH}-${LFS_VERSION}.tar.gz

# ADD WEBHOOK
ENV WEBHOOK_VERSION=2.8.0 
RUN curl -sL -o webhook.tar.gz https://github.com/adnanh/webhook/archive/${WEBHOOK_VERSION}.tar.gz && \
    tar xzf webhook.tar.gz && \
    cd webhook-${WEBHOOK_VERSION} && \
    go get -d && \
    go build -o out/webhook && \
    install out/webhook /usr/local/bin/ && \
    cd .. && \
    rm -rf webhook-${WEBHOOK_VERSION} && \
    rm -rf webhook.tar.gz && \
    apk del --purge build-deps

ENV GIT_SYNC_BRANCH=master
ENV GIT_SYNC_REPO=${GIT_SYNC_REPO:-}
ENV GIT_SYNC_WAIT=${GIT_SYNC_WAIT:-15}
ENV GIT_SYNC_BRANCH=${GIT_SYNC_BRANCH:-}
ENV GIT_SYNC_DEST=${GIT_SYNC_DEST:-git}
ENV GIT_SYNC_USER=${GIT_SYNC_USER:-git-sync}
ENV GIT_SYNC_EMAIL=${GIT_SYNC_EMAIL:-git-sync@example.com}
ENV GIT_SYNC_GITLAB_WEBHOOK=${GIT_SYNC_GITLAB_WEBHOOK:-nil}
ENV GIT_SYNC_GITLAB_WEBHOOK_TOKEN=${GIT_SYNC_GITLAB_WEBHOOK_TOKEN:-nil}
ENV GIT_SYNC_CUSTOM_WEBHOOK=${GIT_SYNC_CUSTOM_WEBHOOK:-nil}

ENV LOCKFILE='/var/lock/git-sync.lock'
RUN touch $LOCKFILE

COPY entrypoint.sh /
COPY git-sync.sh /usr/local/bin/git-sync
 
ENTRYPOINT ["/entrypoint.sh"]
