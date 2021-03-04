#!/bin/sh
set -eu

# Ref.: https://stackoverflow.com/questions/1715137/
LOCKFD=9

# PRIVATE
_lock()             { flock -$1 $LOCKFD; }
_no_more_locking()  { _lock u; _lock xn && rm -f $LOCKFILE; }
_prepare_locking()  { eval "exec $LOCKFD>$LOCKFILE"; trap _no_more_locking EXIT; }

# ON START
_prepare_locking

# PUBLIC
exlock_now()        { _lock xn; }  # obtain an exclusive lock immediately or fail

### BEGIN OF SCRIPT ###

# Simplest example is avoiding running multiple instances of script.
exlock_now || {
  echo "ERROR: Another instance of git-sync already running"
  exit 1
}

if [ ! -d ${GIT_SYNC_ROOT}/$GIT_SYNC_DEST/.git ]; then
  echo "INFO: Cloning ${GIT_SYNC_BRANCH} into ${GIT_SYNC_DEST}"
  git clone -b ${GIT_SYNC_BRANCH} ${GIT_SYNC_REPO} ${GIT_SYNC_ROOT}/$GIT_SYNC_DEST
fi

cd ${GIT_SYNC_ROOT}/${GIT_SYNC_DEST}

echo "INFO: Pulling latest changes"
git pull origin ${GIT_SYNC_BRANCH}

echo "INFO: Pushing local changes"
git push origin ${GIT_SYNC_BRANCH}
