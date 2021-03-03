#!/bin/sh
set -eu

cd ${GIT_SYNC_ROOT}/${GIT_SYNC_DEST}

# pull remote orignin
echo "INFO: Pulling latest changes"
git pull origin ${GIT_SYNC_BRANCH}

echo "INFO: Pushing local changes"
git push origin ${GIT_SYNC_BRANCH}
