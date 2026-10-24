#!/usr/bin/env bash
set -Eeuo pipefail
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
CTL="$ROOT_DIR/zapret-linux"

pause() { read -r -p 'Нажмите Enter, чтобы продолжить...' _; }

while true; do
    clear || true
    "$CTL" status || true
    printf '\nZAPRET SERVICE MANAGER (Linux)\n'
    printf '  1. Запустить / перезапустить\n'
    printf '  2. Остановить\n'
    printf '  3. Выбрать стратегию\n'
    printf '  4. Game Filter\n'
    printf '  5. IPSet Filter\n'
    printf '  6. Обновить IPSet\n'
    printf '  7. Диагностика\n'
    printf '  0. Выход\n\n'
    read -r -p 'Выберите пункт: ' choice
    case "$choice" in
        1) sudo -- "$CTL" restart; pause ;;
        2) sudo -- "$CTL" stop; pause ;;
        3)
            "$CTL" list
            read -r -p 'Имя стратегии: ' strategy
            sudo -- "$CTL" select "$strategy"
            pause
            ;;
        4)
            read -r -p 'Режим (disabled/all/tcp/udp): ' mode
            read -r -p 'TCP-порты [1024-65535]: ' tcp
            read -r -p 'UDP-порты [1024-65535]: ' udp
            sudo -- "$CTL" game-filter "$mode" "${tcp:-1024-65535}" "${udp:-1024-65535}"
            pause
            ;;
        5)
            read -r -p 'Режим (none/loaded/any): ' mode
            sudo -- "$CTL" ipset-mode "$mode"
            pause
            ;;
        6) sudo -- "$CTL" update-ipset; pause ;;
        7) "$CTL" diagnose; pause ;;
        0) exit 0 ;;
    esac
done
