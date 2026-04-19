{ config, pkgs, inputs, ... }: {
  imports = [
    inputs.zapret-discord-youtube.nixosModules.default
  ];

  networking.hostName = "zerg";
  system.stateVersion = "25.05";

  # Бинарный кеш numtide
  nix.settings = {
    extra-substituters = [ "https://cache.numtide.com" ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };

  boot.kernelPackages = pkgs.linuxPackages_6_18;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable fish shell
  programs.fish.enable = true;
  programs.amnezia-vpn.enable = true;

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

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;

    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];

    config = {
      common.default = "gtk";
      niri = {
        "org.freedesktop.impl.portal.Screencast" = "gnome";
        "org.freedesktop.impl.portal.Screenshot" = "gnome";
        default = pkgs.lib.mkForce "gtk";
      };
    };
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

    podman
    podman-compose
  ];

  environment.variables = {
    EDITOR = "${pkgs.neovim}/bin/nvim";
    VISUAL = "zed-editor";
  };
}
