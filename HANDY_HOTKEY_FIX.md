# Handy Hotkey Fix on Niri/Wayland

## Симптом

`Handy` запускался, но глобальная горячая клавиша записи (`Ctrl+Space`) работала нестабильно или не работала совсем.

## Что оказалось не так

Проблема была не в одной вещи, а в нескольких сразу:

1. Под `niri` и `Wayland` нельзя полагаться только на то, что приложение само корректно поймает global shortcut.
2. У `Handy` был включен backend клавиатуры `Tauri`, который в этом окружении инициализировался, но работал нестабильно.
3. В какой-то момент `Handy` запускался дважды:
   - через `~/.config/autostart/Handy.desktop`
   - и дополнительно через `niri` `spawn-at-startup`

Из-за этого два экземпляра могли конфликтовать за один и тот же hotkey.

## Что было проверено

Во время диагностики были найдены такие признаки:

- в `~/.local/share/com.pais.handy/settings_store.json`:
  - `push_to_talk: true`
  - `transcribe: ctrl+space`
- в логах `Handy` были строки вида:
  - `Shortcuts initialized successfully`
  - `TranscribeAction::start called for binding: transcribe`
  - `TranscribeAction::stop called for binding: transcribe`

Это показало, что:

- сама логика push-to-talk в `Handy` есть;
- хоткей в некоторых случаях реально срабатывал;
- проблема была именно в способе захвата клавиш в текущем окружении.

## Что было изменено

### 1. Убран двойной автозапуск `Handy`

Из `dotfiles/niri/config.kdl` был удален запуск:

```kdl
spawn-at-startup "handy" "--start-hidden"
```

Оставлен только обычный автозапуск самого `Handy` через его desktop entry.

### 2. Для портала добавлен `GlobalShortcuts -> gnome`

В `modules/profiles/desktop/wm/wms.nix` добавлено:

```nix
"org.freedesktop.portal.GlobalShortcuts" = [ "gnome" ];
```

Это полезно для приложений, которые используют portal-based global shortcuts под Wayland.

### 3. `Handy` переведен с `Tauri` на `handy_keys`

В `~/.local/share/com.pais.handy/settings_store.json` параметр:

```json
"keyboard_implementation": "tauri"
```

был заменен на:

```json
"keyboard_implementation": "handy_keys"
```

Именно это оказалось финальным рабочим решением.

## Итоговое рабочее состояние

После переключения `keyboard_implementation` на `handy_keys`:

- `Handy` начал нормально реагировать на `Ctrl+Space`;
- push-to-talk заработал как ожидается:
  - зажал `Ctrl+Space` -> запись идет;
  - отпустил -> запись заканчивается.

## Что важно помнить на будущее

Если `Handy` снова перестанет ловить хоткей, сначала проверь:

1. Что не запущено два экземпляра `Handy`.
2. Что в `settings_store.json` стоит:

```json
"keyboard_implementation": "handy_keys"
```

3. Что в логах есть строки про `handy-keys`, а не только про `Tauri`.

Полезные команды:

```bash
pgrep -a handy
tail -n 80 ~/.local/share/com.pais.handy/logs/handy.log
rg -n "handy-keys|shortcut|recording mode|Failed|error" ~/.local/share/com.pais.handy/logs/handy.log | tail -n 60
```
