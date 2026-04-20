{ config, pkgs, ... }:

{
  programs.mpv = {
    enable = true;
    config = {
      # Качество видео
      profile = "gpu-hq";
      vo = "gpu";
      gpu-context = "wayland";
      hwdec = "auto-safe";
      
      # Поведение
      save-position-on-quit = true;
      sub-auto = "fuzzy"; # Автозагрузка похожих субтитров
      
      # Настройки для UOSC (отключаем стандартный интерфейс)
      osc = "no";
      osd-bar = "no";
      border = "no";

      # Настройки MPRIS для работы с главами (таймкодами)
      script-opts = "mpris-report_chapters=yes";
    };

    bindings = {
      # Громкость и перемотка
      "WHEEL_UP" = "add volume 2";
      "WHEEL_DOWN" = "add volume -2";
      "UP" = "add volume 2";
      "DOWN" = "add volume -2";
      "RIGHT" = "seek 5";
      "LEFT" = "seek -5";
      "Shift+RIGHT" = "seek 30";
      "Shift+LEFT" = "seek -30";
      
      # Плейлист и повтор
      "l" = "cycle-values loop-file \"inf\" \"no\"";
      "n" = "playlist-next";
      "p" = "playlist-prev";
      "PGUP" = "playlist-prev";
      "PGDWN" = "playlist-next";
      
      # Магия UOSC
      "m" = "script-binding uosc/menu";
      "s" = "script-binding uosc/subtitles";
      "a" = "script-binding uosc/audio";
      "v" = "script-binding uosc/video";
      "alt+p" = "script-binding uosc/playlist";
      "ctrl+s" = "async screenshot";
    };

    scripts = with pkgs.mpvScripts; [
      uosc          # Современный UI
      thumbfast     # Превью при перемотке
      autoload      # Авто-плейлист папки
      mpris         # Управление через систему/клавиатуру
      sponsorblock  # Пропуск рекламы в YouTube
      quality-menu  # Выбор качества YouTube
    ];
  };
}
