{ pkgs, self, inputs, ... }: {
 imports = [
    # Remove direct import since it's handled at flake level
    # ../../nix.nix
    inputs.stylix.nixosModules.stylix # Добавляем импорт модуля stylix
    # inputs.sops-nix.nixosModules.sops # Управление секретами — ЗАКОММЕНТИРОВАНО до настройки SOPS

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

  services = {
    cloudflare-warp = { 
      enable = true;
    };

    zerotierone = {
      enable = true;
    };

    v2ray = {
      enable = true;
      config = {
        # ... здесь содержимое конфига как Nix-структура ...
      };
      # configFile не указан!
    };
  };

  # Настройка службы (через systemd)
  systemd.services.zapret = {
    description = "Zapret censorship circumvention tool";
    after = [ "network.target" "nftables.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "forking";
      # Путь к скрипту инициализации в NixStore
      ExecStart = "${pkgs.zapret}/bin/zapret start";
      ExecStop = "${pkgs.zapret}/bin/zapret stop";
      Restart = "on-failure";
    };
  };

  # 3. Важно: Настройка параметров (конфиг лежит в /etc/default/zapret или передается флагами)
  # Для NixOS удобнее создать файл конфигурации:
  environment.etc."default/zapret".text = ''
  # Использовать nftables (рекомендуется для NixOS)
  FWTYPE=nftables
  
  # Метод перехвата трафика
  MODE=nfqueue
  
  # Очередь для обработки (стандартно 1)
  NFQWS_OPT_DESYNC_QUED=1

  # Порты, которые zapret будет перехватывать
  TCP_PORTS=80,443,2053,2083,2087,2096,8443
  UDP_PORTS=443,19294-19344,50000-50100

  # Путь к вашим спискам (измените на реальный)
  LISTS=/etc/zapret/lists
  BIN_FILES=/etc/zapret/bin # положите сюда .bin файлы

  # Основная строка параметров nfqws (адаптация вашего .bat)
  # В Linux аргументы разделяются через --new аналогично winws
  NFQWS_OPT_DESYNC="
  --filter-udp=443 --hostlist=$LISTS/list-general.txt --hostlist=$LISTS/list-general-user.txt --hostlist-exclude=$LISTS/list-exclude.txt --hostlist-exclude=$LISTS/list-exclude-user.txt --ipset-exclude=$LISTS/ipset-exclude.txt --ipset-exclude=$LISTS/ipset-exclude-user.txt --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic=$BIN_FILES/quic_initial_www_google_com.bin --new
  --filter-udp=19294-19344,50000-50100 --filter-l7=discord,stun --dpi-desync=fake --dpi-desync-repeats=6 --new
  --filter-tcp=2053,2083,2087,2096,8443 --hostlist-domains=discord.media --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fooling=ts --dpi-desync-fake-tls=$BIN_FILES/tls_clienthello_www_google_com.bin --new
  --filter-tcp=443 --hostlist=$LISTS/list-google.txt --ip-id=zero --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fooling=ts --dpi-desync-fake-tls=$BIN_FILES/tls_clienthello_www_google_com.bin --new
  --filter-tcp=80,443 --hostlist=$LISTS/list-general.txt --hostlist=$LISTS/list-general-user.txt --hostlist-exclude=$LISTS/list-exclude.txt --hostlist-exclude=$LISTS/list-exclude-user.txt --ipset-exclude=$LISTS/ipset-exclude.txt --ipset-exclude=$LISTS/ipset-exclude-user.txt --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fooling=ts --dpi-desync-fake-tls=$BIN_FILES/stun.bin --dpi-desync-fake-tls=$BIN_FILES/tls_clienthello_www_google_com.bin --dpi-desync-fake-http=$BIN_FILES/tls_clienthello_max_ru.bin --new
  --filter-udp=443 --ipset=$LISTS/ipset-all.txt --hostlist-exclude=$LISTS/list-exclude.txt --hostlist-exclude=$LISTS/list-exclude-user.txt --ipset-exclude=$LISTS/ipset-exclude.txt --ipset-exclude=$LISTS/ipset-exclude-user.txt --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic=$BIN_FILES/quic_initial_www_google_com.bin --new
  --filter-tcp=80,443,8443 --ipset=$LISTS/ipset-all.txt --hostlist-exclude=$LISTS/list-exclude.txt --hostlist-exclude=$LISTS/list-exclude-user.txt --ipset-exclude=$LISTS/ipset-exclude.txt --ipset-exclude=$LISTS/ipset-exclude-user.txt --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fooling=ts --dpi-desync-fake-tls=$BIN_FILES/stun.bin --dpi-desync-fake-tls=$BIN_FILES/tls_clienthello_www_google_com.bin --dpi-desync-fake-http=$BIN_FILES/tls_clienthello_max_ru.bin
  "
'';
  


  # services.xdg-desktop-portal = {
  #   enable = true;
  #   xdgServices = [ "wlr" ];

  # };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;  # Рекомендуется для Wayland

    # Для wlroots (sway/hyprland/river)
    wlr.enable = true;

    # Дополнительные порталы (если нужны)
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
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
