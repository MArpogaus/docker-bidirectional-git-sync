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

if [ ${GIT_SYNC_GITLAB_WEBHOOK} != nil ]; then
  echo "INFO: Registering webhook for remote updates"
  cat > /etc/webhook.yaml <<-EOF
- id: "${GIT_SYNC_GITLAB_WEBHOOK}"
  execute-command: "/usr/local/bin/git-sync"
  response-message: "Syncronizing changes"
  command-working-directory: "${GIT_SYNC_ROOT}/${GIT_SYNC_DEST}"
EOF
  if [ ${GIT_SYNC_GITLAB_WEBHOOK_TOKEN} != nil ]; then
  cat >> /etc/webhook.yaml <<-EOF
  trigger-rule:
    match:
      type: value
      value: "${GIT_SYNC_GITLAB_WEBHOOK_TOKEN}"
      parameter:
        source: header
        name: X-Gitlab-Token
EOF
  fi
elif [ ${GIT_SYNC_CUSTOM_WEBHOOK} != true ]; then
  echo "*/${GIT_SYNC_WAIT} * * * * sh -c ${CRON_CMD}" | crontab -
fi

echo "INFO: Registering incron job to push any changes"
CRON_CMD="export HOME='${HOME}' GIT_SYNC_ROOT='${GIT_SYNC_ROOT}' GIT_SYNC_BRANCH='${GIT_SYNC_BRANCH}'; git-sync"
echo "${GIT_SYNC_ROOT}/${GIT_SYNC_DEST}/.git IN_MODIFY,IN_NO_LOOP,IN_MOVE sh -c git-sync" | incrontab -
incrontab -l

(git-sync) &

# Possible Commands:
# crond -f -d 0) &
# webhook -hooks /etc/webhook.yaml -verbose
# incrond --foreground
exec $@
