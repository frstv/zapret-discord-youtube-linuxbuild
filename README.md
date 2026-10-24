# zapret-discord-youtube для Linux

Linux-порт [Flowseal/zapret-discord-youtube](https://github.com/Flowseal/zapret-discord-youtube). Сборка рассчитана на обычный Linux-компьютер с архитектурой **x86_64**, `systemd` и `nftables`


## Быстрый запуск

После клонирования один раз назначьте исполняемые права:

```bash
chmod +x zapret-linux service.sh install.sh uninstall.sh bin/nfqws tools/import-strategies.pl
```

Установите `nftables`, если его ещё нет:

```bash
# Debian / Ubuntu
sudo apt install nftables

# Fedora
sudo dnf install nftables

# Arch Linux
sudo pacman -S nftables
```

Проверьте сборку и запустите стандартную стратегию:

```bash
./zapret-linux diagnose
sudo ./zapret-linux start
./zapret-linux status
```

Остановка:

```bash
sudo ./zapret-linux stop
```

Как и в оригинальной сборке, рекомендуется включить Secure DNS / DNS over HTTPS в браузере или системе.

## Стратегии

Посмотреть полный список и выбрать стратегию:

```bash
./zapret-linux list
./zapret-linux select alt11
sudo ./zapret-linux restart
```

Для ручной проверки без фонового запуска:

```bash
sudo ./zapret-linux run alt11
```

Процесс работает в текущем терминале до нажатия `Ctrl+C`. Если одна стратегия не подходит вашему провайдеру, последовательно проверьте `general`, `alt`, `alt2` … `alt13`, затем `fake-tls-auto*` и `simple-fake*`.

Интерактивный менеджер, похожий на `service.bat`:

```bash
./service.sh
```

## Автозапуск через systemd

```bash
./install.sh
```

Установщик копирует сборку в `/opt/zapret-flowseal`, создаёт и запускает `zapret-flowseal.service`.

```bash
systemctl status zapret-flowseal
sudo systemctl restart zapret-flowseal
sudo journalctl -u zapret-flowseal -b
```

Удалить сервис:

```bash
./uninstall.sh
```

Каталог `/opt/zapret-flowseal` при удалении сохраняется, чтобы не потерять пользовательские списки.

## Game Filter и IPSet

Режимы Game Filter соответствуют Windows-сборке:

```bash
./zapret-linux game-filter disabled
./zapret-linux game-filter all
./zapret-linux game-filter tcp 1024-1934,1936-65535
./zapret-linux game-filter udp 1024-65535 1024-65535
sudo ./zapret-linux restart
```

Режимы IPSet:

```bash
./zapret-linux ipset-mode none
./zapret-linux ipset-mode loaded
./zapret-linux ipset-mode any
./zapret-linux update-ipset
```

- `none` — IP-адреса не включаются в обход;
- `loaded` — используется список `lists/ipset-all.txt.backup`;
- `any` — IP-фильтр совпадает с любым адресом.

`any` и широкий Game Filter могут затронуть посторонние сайты и приложения. Для постоянной работы лучше дополнять пользовательские файлы:

- `lists/list-general-user.txt` — дополнительные домены;
- `lists/list-exclude-user.txt` — исключённые домены;
- `lists/ipset-exclude-user.txt` — исключённые IP и подсети.

## Диагностика

```bash
./zapret-linux diagnose
./zapret-linux test
sudo nft list table inet zapret_flowseal
journalctl -u zapret-flowseal -b
```

