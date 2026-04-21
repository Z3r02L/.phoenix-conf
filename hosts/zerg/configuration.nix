{ config, pkgs, inputs, ... }: {
  imports = [
    inputs.zapret-discord-youtube.nixosModules.default
  ];

  networking.hostName = "zerg";
  system.stateVersion = "25.05";

  time.timeZone = "Europe/Moscow";

  hardware.enableRedistributableFirmware = true;

  # Бинарный кеш numtide и настройки доступа
  nix.settings = {
    trusted-users = [ "root" ];
    extra-substituters = [ 
      "https://cache.numtide.com"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];

    # Используем GitHub Token для обхода лимитов API, если файл существует
    access-tokens = [ "github.com=${pkgs.lib.optionalString (builtins.pathExists "/home/zerg/.config/nix/github-token") (pkgs.lib.replaceStrings ["\n" " "] ["" ""] (builtins.readFile "/home/zerg/.config/nix/github-token"))}" ];
  };

  boot.kernelPackages = pkgs.linuxPackages_6_18;

  # Настройка виртуальной камеры для OBS и Vesktop
  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
  boot.kernelModules = [ "v4l2loopback" ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=10 card_label="OBS Virtual Camera" exclusive_caps=1 max_buffers=2
  '';

  # Правила udev для обеспечения прав доступа к видеоустройствам
  services.udev.extraRules = ''
    KERNEL=="video[0-9]*", GROUP="video", MODE="0660"
  '';

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.enable = true;

  # Безопасность ядра
  boot.kernel.sysctl = {
    "kernel.unprivileged_userns_clone" = 1; # Нужно для песочниц браузеров
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;
    "net.ipv4.icmp_echo_ignore_all" = 1; # Игнорировать пинг (стелс-режим)
  };

  # Enable fish shell
  programs.fish.enable = true;
  programs.amnezia-vpn.enable = true;

  # Оптимизация памяти (ZRAM)
  zramSwap.enable = true;

  # Поддержка игр
  programs.steam.enable = true;
  programs.gamemode.enable = true;

  # Обслуживание Btrfs
  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
  };

  services.flatpak = {
    enable = true;
    remotes = [{
      name = "flathub";
      location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    }];
    update.onActivation = true;
    packages = [
      "io.github.diegopvlk.Tomatillo"
      "org.inkscape.Inkscape"
    ];
  };

  services.xremap = {
    withWlroots = true;
    userName = "zerg";
    config = {
      keymap = [
        {
          name = "Global Layout-independent Hotkeys";
          remap = {
            "C-Cyrillic_es" = "C-c";  # Ctrl+С -> Ctrl+C
            "C-Cyrillic_em" = "C-v";  # Ctrl+М -> Ctrl+V
            "C-Cyrillic_che" = "C-x"; # Ctrl+Ч -> Ctrl+X
            "C-Cyrillic_ef" = "C-a";  # Ctrl+Ф -> Ctrl+A

            "M-Cyrillic_ef" = "M-a";  # Alt+Ф -> Alt+a (наш префикс!)
          };
        }
      ];
    };
  };

  services.cloudflare-warp.enable = true;

  services.zerotierone.enable = true;

  services.v2ray = {
    enable = true;
    config = {
      # ... здесь содержимое конфига как Nix-структура ...
    };
  };

  # Zapret - обход блокировок
  services.zapret-discord-youtube = {
    enable = true;
    configName = "general(ALT)";
    gameFilter = "null";

    listExclude = [
      "ubisoft.com"
      "origin.com"
    ];

    ipsetAll = [
      "192.168.1.0/24"
    ];

    ipsetExclude = [
      "203.0.113.0/24"
    ];
  };

  services.gnome.gnome-keyring.enable = true;
  programs.dconf.enable = true;
  xdg.mime.enable = true;

  security = {
    apparmor.enable = true;
    protectKernelImage = true;
    forcePageTableIsolation = true; # Защита от Meltdown
    rtkit.enable = true;
    chromiumSuidSandbox.enable = true; # Позволяет браузерам иметь песочницу без лишних прав пользователя
    sudo.execWheelOnly = true; # Только пользователи в wheel могут запускать sudo
  };

  networking.firewall = {
    enable = true;
    allowPing = false;
  };

  # PipeWire для screencast
  services.pipewire.enable = true;
  services.pipewire.wireplumber.enable = true;

  # Enable podman
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # SSH server configuration
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      PubkeyAuthentication = true;
    };
  };

  # Отключаем документацию
  documentation.man.enable = false;
  documentation.doc.enable = false;

  # GITHUB_TOKEN
  environment.variables.GITHUB_TOKEN = pkgs.lib.mkIf (builtins.pathExists "/home/zerg/.config/nix/github-token") (builtins.readFile "/home/zerg/.config/nix/github-token");

  # System packages
  environment.systemPackages = with pkgs; [
    nh
    nixd

    v4l-utils

    podman
    podman-compose
  ];

  environment.variables = {
    EDITOR = "${pkgs.neovim}/bin/nvim";
    VISUAL = "zed-editor";
  };

  fonts.fontconfig = {
    enable = true;
    antialias = true;
    hinting = {
      enable = true;
      autohint = false;
      style = "slight"; # Самый современный и мягкий режим четкости
    };
    subpixel = {
      rgba = "rgb"; # Оптимально для ЖК-мониторов
      lcdfilter = "default";
    };
    # Указываем системе приоритетные шрифты для подмены
    defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font Mono" ];
      sansSerif = [ "Inter" ];
      serif     = [ "Noto Serif" ];
    };
  };
}
