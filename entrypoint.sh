#!/bin/sh
set -eu

if [ ! ${GIT_SYNC_REPO} ]; then
  echo "ERROR: GIT_SYNC_REPO undefined"
  exit 1
fi

# configure git
echo "INFO: Configuring git"
git config --global pull.rebase false
git config --global user.name ${GIT_SYNC_USER}
git config --global user.email ${GIT_SYNC_EMAIL}

# Authorization
if [ ${GIT_SYNC_USERNAME} != nil ] && [ ${GIT_SYNC_PASSWORD} != nil ]; then
  echo "INFO: Storing provided credentials"
  git config --global credential.helper store
  printf 'url=%s\nusername=%s\npassword=%s\n' ${GIT_SYNC_REPO} ${GIT_SYNC_USERNAME} ${GIT_SYNC_PASSWORD} | git credential approve
fi

cd ${GIT_SYNC_ROOT}

# clone repo
if [ ! -d $GIT_SYNC_DEST ]; then
  echo "INFO: Cloning ${GIT_SYNC_BRANCH} into ${GIT_SYNC_DEST}"
  git clone -b ${GIT_SYNC_BRANCH} ${GIT_SYNC_REPO} ${GIT_SYNC_DEST}
else
  git-sync
fi

echo "INFO: Registering cron job"
echo "*/${GIT_SYNC_WAIT} * * * * sh -c 'export HOME=$HOME; git-sync'" | crontab -
crontab -l
exec $@
