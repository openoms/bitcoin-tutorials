#!/bin/bash

# https://openclaw.ai
# https://github.com/openclaw/openclaw

# id string of your app
APPID="openclaw"

# the dedicated user for the app
APP_USER="claw"

# clean human readable version
VERSION="1.0"

# the data directory on the HDD
APP_DATA_DIR="/mnt/hdd/app-data/${APPID}"

# BASIC COMMANDLINE OPTIONS
if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "-help" ]; then
  echo "# bonus.${APPID}.sh status    -> status information (key=value)"
  echo "# bonus.${APPID}.sh on        -> install the app"
  echo "# bonus.${APPID}.sh off       -> uninstall the app"
  echo "# bonus.${APPID}.sh menu      -> SSH menu dialog"
  echo "# bonus.${APPID}.sh update    -> update openclaw to latest version"
  exit 1
fi

echo "# Running: 'bonus.${APPID}.sh $*'"

# check & load raspiblitz config
source /mnt/hdd/app-data/raspiblitz.conf

ensureUserSystemdSession() {
  local uid
  uid="$(id -u "${APP_USER}" 2>/dev/null)"
  if [ -z "${uid}" ]; then
    return 1
  fi

  # keep a user-level systemd manager running without an interactive login
  sudo loginctl enable-linger "${APP_USER}" >/dev/null 2>&1 || true
  sudo systemctl start "user@${uid}.service" >/dev/null 2>&1 || true

  echo "${uid}"
  return 0
}

runUserSystemctl() {
  local uid
  uid="$(id -u "${APP_USER}" 2>/dev/null)"
  if [ -z "${uid}" ] || ! [ -d "/run/user/${uid}" ]; then
    return 1
  fi
  sudo -u ${APP_USER} env XDG_RUNTIME_DIR="/run/user/${uid}" systemctl --user "$@"
}

#########################
# INFO
#########################

openclawBin="/home/${APP_USER}/.npm-global/bin/openclaw"
isInstalled=$([ -x "${openclawBin}" ] && echo 1 || echo 0)
if runUserSystemctl is-active ${APPID}.service >/dev/null 2>&1; then
  isRunning=1
else
  isRunning=0
fi
if runUserSystemctl is-active claude-api-proxy.service >/dev/null 2>&1; then
  isProxyRunning=1
else
  isProxyRunning=0
fi

if [ "$1" = "status" ]; then
  echo "appID='${APPID}'"
  echo "version='${VERSION}'"
  echo "isInstalled=${isInstalled}"
  echo "isRunning=${isRunning}"
  echo "isProxyRunning=${isProxyRunning}"
  if [ "${isInstalled}" == "1" ]; then
    openclawVersion=$(sudo -u ${APP_USER} ${openclawBin} --version 2>/dev/null | head -n1)
    echo "openclawVersion='${openclawVersion}'"
  fi
  exit
fi

##########################
# MENU
#########################

if [ "$1" = "menu" ]; then

  dialogTitle=" OpenClaw "
  dialogText="OpenClaw is installed.\n
Switch to the claw user to run commands:\n
  sudo su - ${APP_USER}\n
  openclaw --help\n
\nService mode: user-level systemd\n
\nGateway service status:\n
  systemctl --user status ${APPID}\n
\nClaude API proxy status:\n
  systemctl --user status claude-api-proxy\n
  Endpoint: http://127.0.0.1:3456/v1/chat/completions\n
\nService logs:\n
  journalctl --user -f -u ${APPID}\n
  journalctl --user -f -u claude-api-proxy\n

\nData directory: ${APP_DATA_DIR}\n
Config: /home/${APP_USER}/.openclaw (symlink)\n
"

  whiptail --title "${dialogTitle}" --msgbox "${dialogText}" 20 67
  echo "please wait ..."
  exit 0
fi

##########################
# UPDATE
##########################

if [ "$1" = "update" ]; then

  if [ ${isInstalled} -eq 0 ]; then
    echo "# ${APPID} is not installed - cannot update"
    exit 1
  fi

  echo "# Updating ${APPID} ..."
  sudo -u ${APP_USER} bash -c 'export PATH="$HOME/.npm-global/bin:$PATH" && npm install -g openclaw@latest'
  if [ $? -eq 0 ]; then
    echo "# OK - ${APPID} updated successfully"
    echo "# new version: $(sudo -u ${APP_USER} ${openclawBin} --version 2>/dev/null | head -n1)"

    # ensure the app user has a user-level systemd manager available
    clawUid="$(ensureUserSystemdSession)"

    # run openclaw update tasks (plugin updates, doctor, restart, etc.)
    if [ -n "${clawUid}" ] && [ -d "/run/user/${clawUid}" ]; then
      sudo -u ${APP_USER} env XDG_RUNTIME_DIR="/run/user/${clawUid}" bash -c 'export PATH="$HOME/.npm-global/bin:$PATH" && openclaw update --yes'
    else
      echo "# FAIL - could not initialize user systemd runtime for ${APP_USER}"
      exit 1
    fi
  else
    echo "# FAIL - ${APPID} update failed"
    exit 1
  fi
  exit 0
fi

##########################
# ON / INSTALL
##########################

if [ "$1" = "1" ] || [ "$1" = "on" ]; then

  if [ ${isInstalled} -eq 1 ]; then
    echo "# ${APPID} is already installed."
    exit 1
  fi

  echo "# Installing ${APPID} ..."

  # check and install NodeJS
  /home/admin/config.scripts/bonus.nodejs.sh on

  # create a dedicated user for the app
  echo "# create user: ${APP_USER}"
  sudo adduser --system --group --shell /bin/bash --home /home/${APP_USER} ${APP_USER} || exit 1
  sudo -u ${APP_USER} cp -r /etc/skel/. /home/${APP_USER}/

  echo "# enable user-level systemd session (linger): ${APP_USER}"
  ensureUserSystemdSession >/dev/null || true

  # create the persistent app-data directory on the HDD
  if ! [ -d ${APP_DATA_DIR} ]; then
    echo "# create app-data directory: ${APP_DATA_DIR}"
    sudo mkdir -p ${APP_DATA_DIR}
    sudo chown ${APP_USER}:${APP_USER} -R ${APP_DATA_DIR}
  else
    echo "# reuse existing app-data directory"
    sudo chown ${APP_USER}:${APP_USER} -R ${APP_DATA_DIR}
  fi

  # create the symlink: /home/claw/.openclaw -> /mnt/hdd/app-data/openclaw
  # so that all openclaw data (config, workspace, etc.) is stored on the HDD
  echo "# create symlink /home/${APP_USER}/.openclaw -> ${APP_DATA_DIR}"
  sudo rm -rf /home/${APP_USER}/.openclaw
  sudo ln -s ${APP_DATA_DIR} /home/${APP_USER}/.openclaw
  sudo chown ${APP_USER}:${APP_USER} /home/${APP_USER}/.openclaw

  # configure npm for user-local global installs (no sudo needed)
  echo "# configure npm prefix for ${APP_USER}"
  sudo -u ${APP_USER} mkdir -p /home/${APP_USER}/.npm-global
  sudo -u ${APP_USER} npm config set prefix "/home/${APP_USER}/.npm-global"
  # add npm-global/bin to PATH for the user (both .bashrc and .profile)
  if ! sudo -u ${APP_USER} grep -q ".npm-global/bin" /home/${APP_USER}/.bashrc 2>/dev/null; then
    echo 'export PATH="$HOME/.npm-global/bin:$PATH"' | sudo -u ${APP_USER} tee -a /home/${APP_USER}/.bashrc >/dev/null
  fi
  if ! sudo -u ${APP_USER} grep -q ".npm-global/bin" /home/${APP_USER}/.profile 2>/dev/null; then
    echo 'export PATH="$HOME/.npm-global/bin:$PATH"' | sudo -u ${APP_USER} tee -a /home/${APP_USER}/.profile >/dev/null
  fi

  # install openclaw via npm
  echo "# install openclaw via npm"
  sudo -u ${APP_USER} bash -c 'export PATH="$HOME/.npm-global/bin:$PATH" && npm install -g openclaw'
  if ! [ $? -eq 0 ]; then
    echo "# FAIL - npm install openclaw did not run correctly"
    exit 1
  fi

  # verify installation
  if ! [ -x "${openclawBin}" ]; then
    echo "# FAIL - openclaw binary not found at ${openclawBin}"
    exit 1
  fi
  echo "# openclaw installed: $(sudo -u ${APP_USER} ${openclawBin} --version 2>/dev/null | head -n1)"

  # create user-level systemd service for the openclaw gateway daemon
  echo "# create user systemd service: ${APPID}.service"
  sudo -u ${APP_USER} mkdir -p /home/${APP_USER}/.config/systemd/user || exit 1
  cat <<EOF | sudo -u ${APP_USER} tee /home/${APP_USER}/.config/systemd/user/${APPID}.service >/dev/null
[Unit]
Description=OpenClaw Gateway Daemon
Wants=network-online.target
After=network-online.target

[Service]
WorkingDirectory=/home/${APP_USER}
Environment=\"HOME=/home/${APP_USER}\"
Environment=\"PATH=/home/${APP_USER}/.npm-global/bin:/usr/local/bin:/usr/bin:/bin\"
ExecStart=${openclawBin} gateway run
Restart=always
TimeoutSec=120
RestartSec=30
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
EOF

  # create user-level systemd service for the Claude API proxy
  echo "# create user systemd service: claude-api-proxy.service"
  cat <<EOF | sudo -u ${APP_USER} tee /home/${APP_USER}/.config/systemd/user/claude-api-proxy.service >/dev/null
[Unit]
Description=Claude Code CLI API Proxy
Wants=network-online.target
After=network-online.target

[Service]
WorkingDirectory=/home/${APP_USER}/claude-max-api-proxy
Environment=\"HOME=/home/${APP_USER}\"
Environment=\"PATH=/home/${APP_USER}/.npm-global/bin:/usr/local/bin:/usr/bin:/bin\"
ExecStart=/usr/bin/node dist/server/standalone.js
Restart=always
TimeoutSec=120
RestartSec=30
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
EOF

  # cleanup legacy system-level unit/sudoers if present
  sudo systemctl stop ${APPID} 2>/dev/null || true
  sudo systemctl disable ${APPID}.service 2>/dev/null || true
  sudo rm -f /etc/systemd/system/${APPID}.service
  sudo rm -f /etc/sudoers.d/${APPID}

  # mark app as installed in raspiblitz config
  /home/admin/config.scripts/blitz.conf.sh set ${APPID} "on"

  # enable & start the user-level service
  clawUid="$(ensureUserSystemdSession)"
  if [ -z "${clawUid}" ] || ! [ -d "/run/user/${clawUid}" ]; then
    echo "# FAIL - could not initialize user systemd runtime for ${APP_USER}"
    exit 1
  fi

  runUserSystemctl daemon-reload || exit 1
  runUserSystemctl enable ${APPID}.service || exit 1
  echo "# OK - the ${APPID}.service is now enabled (user-level)"
  runUserSystemctl enable claude-api-proxy.service || exit 1
  echo "# OK - the claude-api-proxy.service is now enabled (user-level)"

  source <(/home/admin/_cache.sh get state)
  if [ "${state}" == "ready" ]; then
    runUserSystemctl start ${APPID}.service || exit 1
    echo "# OK - the ${APPID}.service is now started (user-level)"
    runUserSystemctl start claude-api-proxy.service || exit 1
    echo "# OK - the claude-api-proxy.service is now started (user-level)"
  fi

  echo "# OK - ${APPID} is installed"
  echo "# Switch to the claw user: sudo su - ${APP_USER}"
  echo "# Then run: openclaw --help"
  echo "# Monitor daemon: sudo -u ${APP_USER} env XDG_RUNTIME_DIR=/run/user/${clawUid} journalctl --user -f -u ${APPID}"
  exit 0
fi

###########################################
# OFF / UNINSTALL
# call with parameter 'delete-data' to also
# delete the persistent data directory
###########################################

if [ "$1" = "0" ] || [ "$1" = "off" ]; then

  echo "# stop & remove user systemd services"
  runUserSystemctl stop claude-api-proxy.service 2>/dev/null || true
  runUserSystemctl disable claude-api-proxy.service 2>/dev/null || true
  sudo -u ${APP_USER} rm -f /home/${APP_USER}/.config/systemd/user/claude-api-proxy.service 2>/dev/null || true
  runUserSystemctl stop ${APPID}.service 2>/dev/null || true
  runUserSystemctl disable ${APPID}.service 2>/dev/null || true
  sudo -u ${APP_USER} rm -f /home/${APP_USER}/.config/systemd/user/${APPID}.service 2>/dev/null || true
  runUserSystemctl daemon-reload 2>/dev/null || true

  echo "# remove legacy systemd service/sudoers (if present)"
  sudo systemctl stop ${APPID} 2>/dev/null || true
  sudo systemctl disable ${APPID}.service 2>/dev/null || true
  sudo rm -f /etc/systemd/system/${APPID}.service
  sudo rm -f /etc/sudoers.d/${APPID}

  echo "# delete user: ${APP_USER}"
  sudo userdel -rf ${APP_USER}

  echo "# mark app as uninstalled in raspiblitz config"
  /home/admin/config.scripts/blitz.conf.sh set ${APPID} "off"

  # only if 'delete-data' is an additional parameter then also the data directory gets deleted
  if [ "$(echo "$@" | grep -c delete-data)" -gt 0 ]; then
    echo "# found 'delete-data' parameter --> also deleting the app-data"
    sudo rm -rf ${APP_DATA_DIR}
  fi

  echo "# OK - ${APPID} should be uninstalled now"
  exit 0
fi

echo "# FAIL - Unknown Parameter $1"
exit 1
