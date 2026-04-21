{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    socat # Нужен для работы thumbfast в некоторых режимах
  ];

  # Ссылки на "живые" конфиги для редактирования без пересборки
  xdg.configFile."mpv/mpv.conf".source = config.lib.file.mkOutOfStoreSymlink "/home/zerg/.phoenix-conf/dotfiles/mpv/mpv.conf";
  xdg.configFile."mpv/script-opts/uosc.conf".source = config.lib.file.mkOutOfStoreSymlink "/home/zerg/.phoenix-conf/dotfiles/mpv/uosc.conf";
  xdg.configFile."mpv/input.conf".source = config.lib.file.mkOutOfStoreSymlink "/home/zerg/.phoenix-conf/dotfiles/mpv/input.conf";

  # Системный файл темы (управляется Stylix)
  xdg.configFile."mpv/stylix.conf".text = with config.lib.stylix.colors; ''
    # Настройки шрифтов
    osd-font='${config.stylix.fonts.sansSerif.name}'
    osd-font-size=30
    
    # Настройки цветов OSD
    osd-color='#${base05}'
    osd-border-color='#${base00}'
    osd-shadow-color='#${base00}'
    
    # Объединенные настройки всех скриптов (чтобы не затирали друг друга)
    script-opts=mpris-report_chapters=yes,thumbfast-network=yes,thumbfast-hwdec=yes,thumbfast-spawn_first=yes,uosc-color=foreground=${base05},foreground_text=${base00},background=${base00},background_text=${base05}
  '';

  programs.mpv = {
    enable = true;

    scripts = with pkgs.mpvScripts; [
      (uosc.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          find . -name Timeline.lua -exec sed -i 's/cursor.y - chapter_y/0/g' {} +
        '';
      }))
      thumbfast     # Превью кадров
      autoload      # Авто-плейлист
      mpris         # Интеграция с системой
      sponsorblock  # Пропуск рекламы
      quality-menu  # Выбор качества YouTube
      mpv-playlistmanager # Удобное управление плейлистом
    ];
  };
}
