# Niri + Vesktop + NVIDIA: Fix Black Screen On Screen Share

## Симптомы

- В `Vesktop` при шаринге экрана был черный экран
- Иногда picker открывался, но видеопоток не появлялся
- В логах встречалось:
  - `No such interface "org.freedesktop.portal.ScreenCast"`
  - `Video was requested, but no video stream was provided`
  - `GDK backend forced via env var, portal dialogs will not work properly`
  - `Non-compatible display server, exposing settings only`

## Корень проблемы

Проблема оказалась составной:

1. `niri` запускался через `greetd` как просто `niri`, а не как `niri-session`
2. `Vesktop` иногда запускался без нужных Wayland/PipeWire флагов
3. Глобальный `GDK_BACKEND` ломал `xdg-desktop-portal-gnome`
4. `xdg-desktop-portal-gnome` под `niri` не экспортировал `ScreenCast`, пока для portal-сервисов не был выставлен `XDG_CURRENT_DESKTOP=GNOME`
5. Для стабильного появления окна `Vesktop` на `NVIDIA + Wayland` понадобился `--disable-gpu`

## Что изменили

### 1. Запуск `niri` как session

Файл: [modules/profiles/desktop/greetd.nix](/home/zerg/.phoenix-conf/modules/profiles/desktop/greetd.nix:1)

Используется:

```nix
command = "${pkgs.tuigreet}/bin/tuigreet --time --asterisks --user-menu --cmd '${config.programs.niri.package}/bin/niri-session'";
```

Это важно для корректной работы screencast/portal в `niri`.

### 2. Убрали глобальный `GDK_BACKEND`

Файл: [hosts/zerg/nvidia.nix](/home/zerg/.phoenix-conf/hosts/zerg/nvidia.nix:1)

Удалена строка:

```nix
GDK_BACKEND = "wayland,x11";
```

Она ломала `xdg-desktop-portal-gnome`.

### 3. Упростили набор portal-backend'ов

Файл: [modules/profiles/desktop/wm/wms.nix](/home/zerg/.phoenix-conf/modules/profiles/desktop/wm/wms.nix:1)

Убрали `xdg-desktop-portal-wlr`, оставили:

```nix
extraPortals = with pkgs; [
  xdg-desktop-portal-gtk
  xdg-desktop-portal-gnome
];
```

### 4. Для portal-сервисов выставили `GNOME`

Файл: [modules/profiles/desktop/wm/wms.nix](/home/zerg/.phoenix-conf/modules/profiles/desktop/wm/wms.nix:1)

Добавили:

```nix
systemd.user.services.xdg-desktop-portal.environment = {
  XDG_CURRENT_DESKTOP = "GNOME";
  XDG_SESSION_DESKTOP = "GNOME";
};

systemd.user.services.xdg-desktop-portal-gnome.environment = {
  XDG_CURRENT_DESKTOP = "GNOME";
  XDG_SESSION_DESKTOP = "GNOME";
};
```

После этого в DBus появился:

```text
interface org.freedesktop.portal.ScreenCast
```

### 5. `Vesktop` завернули в wrapper с нужными флагами

Файл: [users/zerg/home.nix](/home/zerg/.phoenix-conf/users/zerg/home.nix:1)

Используется wrapper:

```nix
vesktopWrapped = pkgs.writeShellScriptBin "vesktop" ''
  exec ${pkgs.vesktop}/bin/vesktop \
    --ozone-platform=wayland \
    --use-gl=egl \
    --disable-gpu \
    --disable-gpu-sandbox \
    --enable-features=UseOzonePlatform,WaylandWindowDecorations,WebRTCPipeWireCapturer \
    "$@"
'';
```

Именно он оказался самым надежным способом заставить `Vesktop` всегда стартовать в правильном режиме.

### 6. Обновили `.desktop` launcher'ы

Файлы:

- [dotfiles/vesktop/vesktop.desktop](/home/zerg/.phoenix-conf/dotfiles/vesktop/vesktop.desktop:1)
- [dotfiles/vesktop/vesktop-wayland.desktop](/home/zerg/.phoenix-conf/dotfiles/vesktop/vesktop-wayland.desktop:1)

Они тоже запускают `vesktop` с Wayland/PipeWire-флагами.

### 7. Импорт окружения в `niri`

Файл: [dotfiles/niri/config.kdl](/home/zerg/.phoenix-conf/dotfiles/niri/config.kdl:122)

Оставили:

```kdl
spawn-at-startup "dbus-update-activation-environment" "--systemd" "--all"
spawn-at-startup "systemctl" "--user" "import-environment" "WAYLAND_DISPLAY" "DISPLAY" "XDG_CURRENT_DESKTOP" "XDG_SESSION_TYPE" "NIRI_SOCKET"
spawn-at-startup "systemd-run" "--user" "--on-active=8s" "--unit=niri-portal-restart" "sh" "-lc" "systemctl --user restart xdg-desktop-portal-gnome.service && systemctl --user restart xdg-desktop-portal.service"
```

Это помогает user-session и portal-сервисам увидеть нужное окружение после старта `niri`.

## Как проверить, что все починилось

### Проверка 1: `ScreenCast` появился в portal

```bash
gdbus introspect --session \
  --dest org.freedesktop.portal.Desktop \
  --object-path /org/freedesktop/portal/desktop | grep ScreenCast
```

Ожидаемый результат:

```text
interface org.freedesktop.portal.ScreenCast
```

### Проверка 2: `Vesktop` стартует с нужными feature

В логе `Vesktop` должно быть:

```text
Enabled Chromium features: UseOzonePlatform, WaylandWindowDecorations, WebRTCPipeWireCapturer
```

### Проверка 3: `niri` видит окно

```bash
niri msg windows
```

Если окна `vesktop` нет, обычно это значит, что приложение стартовало без окна из-за проблем с GPU/Wayland.

## Как применять изменения

```bash
sudo nixos-rebuild switch --flake .#zerg
```

После этого лучше сделать полный logout/login в `niri`.

## Итог

Рабочая схема для этого хоста:

- `niri-session`
- `xdg-desktop-portal-gnome`
- `XDG_CURRENT_DESKTOP=GNOME` только для portal-сервисов
- без глобального `GDK_BACKEND`
- `Vesktop` через wrapper с:
  - `--ozone-platform=wayland`
  - `--use-gl=egl`
  - `--disable-gpu`
  - `--disable-gpu-sandbox`
  - `--enable-features=UseOzonePlatform,WaylandWindowDecorations,WebRTCPipeWireCapturer`

В таком виде screen share в `Vesktop` заработал.
