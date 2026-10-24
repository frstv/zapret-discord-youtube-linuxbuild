# zapret-discord-youtube для Linux

Linux-порт актуальной сборки [Flowseal/zapret-discord-youtube](https://github.com/Flowseal/zapret-discord-youtube). Все 22 стратегии версии **1.10.4** перенесены без изменения параметров DPI. Вместо Windows-драйвера WinDivert используется штатный для Linux обработчик **nfqws v72.13** и отдельная таблица `nftables`.

Сборка рассчитана на обычный Linux-компьютер с архитектурой **x86_64**, `systemd` и `nftables`. Приложенный `nfqws` статически скомпилирован, поэтому дополнительные библиотеки ему не нужны.

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

Если Discord или YouTube не открывается, сначала включите Secure DNS, затем пробуйте другие стратегии. Результат зависит от провайдера и используемого DPI; универсальной стратегии для всех сетей нет.

## Состав и происхождение файлов

- стратегии, списки и fake-пакеты: Flowseal `1.10.4`, commit `176f56dc3f11ce5915c26abcdde903f93d835b64`;
- `bin/nfqws`: официальный релиз bol-van/zapret `v72.13`, commit `87e058624c72863db53bdaf7fb6f16576dddb6ab`;
- SHA-256 `bin/nfqws`: `f34615964d7321650197cd69d3f7cbfdaabe8118b5a0d57c6e41dccdff658999`;
- SHA-256 официального архива zapret v72.13: `25c74e6c5f48963fa244c2955e76694a07c39447245a0457e2efdc74b3317e68`.

Лицензия исходной сборки находится в `LICENSE.txt`.
