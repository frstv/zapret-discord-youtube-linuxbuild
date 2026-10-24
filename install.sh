#!/usr/bin/env bash
set -Eeuo pipefail

SOURCE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
INSTALL_DIR=/opt/zapret-flowseal
UNIT=/etc/systemd/system/zapret-flowseal.service

if (( EUID != 0 )); then
    command -v sudo >/dev/null 2>&1 || { echo 'Запустите install.sh от root.' >&2; exit 1; }
    exec sudo -- "$0" "$@"
fi

command -v nft >/dev/null 2>&1 || { echo 'Не установлен nftables. Установите пакет nftables и повторите.' >&2; exit 1; }
[[ "$(uname -m)" == x86_64 ]] || { echo 'В этой сборке приложен nfqws для x86_64.' >&2; exit 1; }

if systemctl is-active --quiet zapret-flowseal.service 2>/dev/null; then
    systemctl stop zapret-flowseal.service
fi

install -d -m 0755 "$INSTALL_DIR"
cp -a "$SOURCE_DIR/bin" "$SOURCE_DIR/lists" "$SOURCE_DIR/strategies" "$SOURCE_DIR/systemd" "$SOURCE_DIR/tools" "$SOURCE_DIR/state" "$INSTALL_DIR/"
install -m 0755 "$SOURCE_DIR/zapret-linux" "$SOURCE_DIR/service.sh" "$INSTALL_DIR/"
install -m 0644 "$SOURCE_DIR/config.env" "$SOURCE_DIR/LICENSE.txt" "$SOURCE_DIR/README.md" "$INSTALL_DIR/"
sed "s|@INSTALL_DIR@|$INSTALL_DIR|g" "$SOURCE_DIR/systemd/zapret-flowseal.service.in" > "$UNIT"
systemctl daemon-reload
systemctl enable --now zapret-flowseal.service
echo "Установлено в $INSTALL_DIR. Сервис zapret-flowseal запущен."
