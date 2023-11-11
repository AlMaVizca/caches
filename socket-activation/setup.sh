#!/usr/bin/env bash

#Define paths to use
CACHE_PATH=$(git rev-parse --show-toplevel 2>/dev/null)
SA_PATH=${CACHE_PATH}/socket-activation
USER_SYSTEMD_PATH=${HOME}/.config/systemd/user


. ${CACHE_PATH}/.env

# Regular expressions definitions
REGEXP_CACHE_PATH="s!CACHE_PATH!${CACHE_PATH}!g"
REGEXP_GLOBAL_IP="s/GLOBAL_IP/${GLOBAL_IP}/g"
REGEXP_SERVICE="s/EXAMPLE/$1/g"
REPLACE_PORT=PORT_${1}
REGEXP_SERVICE_PORT="s/${REPLACE_PORT}/${!REPLACE_PORT}/g"

mkdir -p ${USER_SYSTEMD_PATH}
cd ${SA_PATH}
for template in $(ls templates); do
    CACHE_SERVICE=$(echo ${template} | sed ${REGEXP_SERVICE})
    cp -f templates/${template} ${USER_SYSTEMD_PATH}/${CACHE_SERVICE}
    sed -i ${REGEXP_SERVICE} ${USER_SYSTEMD_PATH}/${CACHE_SERVICE}
    sed -i ${REGEXP_GLOBAL_IP} ${USER_SYSTEMD_PATH}/${CACHE_SERVICE}
    if [[ $template == *"socket" ]]; then
        sed -i ${REGEXP_SERVICE_PORT} ${USER_SYSTEMD_PATH}/${CACHE_SERVICE}
        systemctl --user enable --now $CACHE_SERVICE
    fi
    sed -i ${REGEXP_CACHE_PATH} ${USER_SYSTEMD_PATH}/${CACHE_SERVICE}
done

if [[ -f ${USER_SYSTEMD_PATH}/cache-$1.socket ]]; then
    systemctl --user daemon-reload
    echo "Socket activation for $1 cache done"
else
    echo "There was an error, please debug it ;)"
    echo "... or report it"
fi
