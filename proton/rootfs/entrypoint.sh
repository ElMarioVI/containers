#!/bin/bash

# check environment variables
if [ -z "${APP_ID}" ]; then
  echo "APP_ID environment variable is not set. Exiting."
  exit 1
fi

if [ -z "${EXE_PATH}" ]; then
  echo "EXE_PATH environment variable is not set. Exiting."
  exit 1
fi

if [ -z "${BACKGROUND_PROCESS}" ]; then
  echo "BACKGROUND_PROCESS environment variable is not set. Exiting."
  exit 1
fi

export STEAM_COMPAT_CLIENT_INSTALL_PATH="/steamcmd"
export STEAM_COMPAT_DATA_PATH="/steamcmd/steamapps/compatdata/${APP_ID}"
mkdir -p "${STEAM_COMPAT_DATA_PATH}"

rm -f /game/steamapps/appmanifest_"${APP_ID}".acf

/steamcmd/steamcmd.sh \
  +@sSteamCmdForcePlatformType windows \
  +force_install_dir /game \
  +login anonymous \
  +app_update "${APP_ID}" validate \
  +quit

if [ "${BACKGROUND_PROCESS}" = "true" ]; then
  /steamcmd/compatibilitytools.d/GE-Proton"${PROTON_VERSION}"/proton run "${EXE_PATH}" &
  if [ -n "${READ_LOGS_FILE}" ] && [ -f "${READ_LOGS_FILE}" ]; then
    exec tail -f "${READ_LOGS_FILE}"
  else
    tail -f /dev/null
  fi
else
  /steamcmd/compatibilitytools.d/GE-Proton"${PROTON_VERSION}"/proton run "${EXE_PATH}"
fi
