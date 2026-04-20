{ config, pkgs, inputs, ... }: {
  imports = [
    inputs.zapret-discord-youtube.nixosModules.default
  ];

  networking.hostName = "zerg";
  system.stateVersion = "25.05";

  time.timeZone = "Europe/Moscow";

  hardware.enableRedistributableFirmware = true;

  # Бинарный кеш numtide
  nix.settings = {
    extra-substituters = [ 
      "https://cache.numtide.com"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  boot.kernelPackages = pkgs.linuxPackages_6_18;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.enable = true;

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
