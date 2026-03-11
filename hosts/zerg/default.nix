{ pkgs, self, inputs, ... }: {
 imports = [
    # Remove direct import since it's handled at flake level
    # ../../nix.nix
    inputs.stylix.nixosModules.stylix # Добавляем импорт модуля stylix

    ./dev-tools.nix
    ./configuration.nix
    ./hardware-configuration.nix
    ./nvidia.nix
    ./amd-cpu.nix
  ];

  networking.hostName = "zerg";
  system.stateVersion = "25.05";


  boot.kernelPackages = pkgs.linuxPackages_6_18;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable fish shell for users that use it
  programs.fish.enable = true;
  programs.amnezia-vpn.enable = true;

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
