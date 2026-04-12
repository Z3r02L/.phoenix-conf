{ pkgs, self, inputs, ... }: {
 imports = [
    # Remove direct import since it's handled at flake level
    # ../../nix.nix
    inputs.stylix.nixosModules.stylix # Добавляем импорт модуля stylix
    # inputs.sops-nix.nixosModules.sops # Управление секретами — ЗАКОММЕНТИРОВАНО до настройки SOPS
    inputs.zapret-discord-youtube.nixosModules.default
    ../../modules/profiles/desktop/desktop.nix # Профиль рабочего стола (greetd, niri, pipewire)

    ./dev-tools.nix
    ./configuration.nix
    ./hardware-configuration.nix
    ./nvidia.nix
    ./amd-cpu.nix
  ];

  networking.hostName = "zerg";
  system.stateVersion = "25.05";

  # Бинарный кеш numtide для пакетов из llm-agents.nix
  nix.settings = {
    extra-substituters = [ "https://cache.numtide.com" ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };

  # SOPS — управление секретами (API-ключи и т.д.)
  # ЗАКОММЕНТИРОВАНО до первой сборки и шифрования секретов
  # Инструкция: см. SETUP.md
  # sops = {
  #   defaultSopsFile = ../../secrets/zerg.yaml;
  #   age = {
  #     sshKeyPaths = [];
  #     keyFile = "/var/lib/sops-nix/key.txt";
  #     generateKey = true;
  #   };
  #   secrets = {
  #     "llm/openai-api-key" = { owner = "zerg"; mode = "0400"; };
  #     "llm/anthropic-api-key" = { owner = "zerg"; mode = "0400"; };
  #     "llm/google-api-key" = { owner = "zerg"; mode = "0400"; };
  #     "llm/openai-base-url" = { owner = "zerg"; mode = "0400"; neededForUsers = true; };
  #   };
  # };


  boot.kernelPackages = pkgs.linuxPackages_6_18;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable fish shell for users that use it
  programs.fish.enable = true;
  programs.amnezia-vpn.enable = true;

  services.cloudflare-warp = {
    enable = true;
  };

  services.zerotierone = {
    enable = true;
  };

  services.v2ray = {
    enable = true;
    config = {
      # ... здесь содержимое конфига как Nix-структура ...
    };
    # configFile не указан!
  };

  # Zapret - обход блокировок
  services.zapret-discord-youtube = {
    enable = true;
    config = "general(ALT)";
    
    # Game Filter: "null" (отключен), "all" (TCP+UDP), "tcp" (только TCP), "udp" (только UDP)
    gameFilter = "null";
    
    # Кастомные домены в list-general-user.txt
    listGeneral = [
      # "example.com"
      # "test.org"
    ];
    
    # Домены в list-exclude-user.txt (исключения)
    listExclude = [
      "ubisoft.com"
      "origin.com"
    ];
    
    # IP адреса в ipset-all.txt
    ipsetAll = [
      "192.168.1.0/24"
    ];
    
    # IP адреса в ipset-exclude-user.txt (исключения)
    ipsetExclude = [
      "203.0.113.0/24"
    ];
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;

    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];

    config.common.default = "*";
    config.niri = {
      "org.freedesktop.impl.portal.ScreenCast" = "gnome";
      "org.freedesktop.impl.portal.Screenshot" = "gnome";
    };
  };


  # Enable podman
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;  # Create docker alias
    defaultNetwork.settings.dns_enabled = true;
  };

  # System packages
  environment.systemPackages = with pkgs; [
    zerotierone

    file
    eza              # Better ls
    zoxide           # Better cd
    yazi             # Terminal file manager
    bat              # Better cat
    fd               # Better find
    ripgrep-all      # Better grep
    fzf              # Fuzzy finder
    wget
    curl
    killall
    zip
    unzip
    jq
    rsync
    borgbackup
    coreutils
    ydotool
    gnupg
    age
    tree

    # Nix workflow
    nixd  # Nix LSP
    nh # nix helper
    statix alejandra
    direnv
    devenv
    nix-output-monitor

    # Git tools
    lazygit          # Git TUI
    lazyjj

    # Networking tools
    nmap

    # Pass
    (pass-wayland.withExtensions (exts: with exts; [
        pass-otp
        pass-import
        pass-audit
    ]))

    # System tools
    btop             # Better top
    trash-cli        # Safe rm
    tldr             # Simplified man pages
    fastfetch        # System info
    microfetch

    # Development containers
    podman           # Container runtime
    podman-compose   # Docker-compose for podman
 ];

  environment.variables = {
    EDITOR = "${pkgs.neovim}/bin/nvim";
  };

  # Enable home-manager for the system
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users = { };
    extraSpecialArgs = { };
 };
}
