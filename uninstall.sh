#!/usr/bin/env bash
set -Eeuo pipefail

if (( EUID != 0 )); then
    command -v sudo >/dev/null 2>&1 || { echo 'Запустите uninstall.sh от root.' >&2; exit 1; }
    exec sudo -- "$0" "$@"
fi

systemctl disable --now zapret-flowseal.service 2>/dev/null || true
rm -f /etc/systemd/system/zapret-flowseal.service
systemctl daemon-reload
echo 'Сервис удалён. Каталог /opt/zapret-flowseal оставлен, чтобы сохранить пользовательские списки.'
