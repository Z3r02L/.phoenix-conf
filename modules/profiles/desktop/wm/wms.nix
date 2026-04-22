{ config, pkgs, inputs, lib, ... }: {
  imports = [
    ./niri.nix
    ../llm.nix
    ../greetd.nix
    ../stylix.nix
  ];

  # Сообщаем системе (и XWayland) о наших раскладках
  services.xserver.xkb = {
    layout = "us,ru";
    options = "grp:lalt_lshift_toggle"; # укажите свою комбинацию
  };
  
  fonts.fontconfig = {
    enable = true;
    antialias = true;
    hinting = {
      enable = true;
      style = "slight"; # "slight" обычно лучше всего для современных шрифтов
    };
    subpixel = {
      rgba = "rgb";
      lcdfilter = "default";
    };
  };


  environment.systemPackages = with pkgs; [

    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default

    # WM Utilities
    brightnessctl
    playerctl
    grim
    slurp
    wl-clipboard
    swaylock

    pcmanfm

    xdg-utils

    gnome-settings-daemon
    gsettings-desktop-schemas
  ];

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
      xdg-desktop-portal-wlr
    ];
    config = {
      common.default = [ "gnome" ];
      niri = {
        "org.freedesktop.impl.portal.Screencast" = [ "gnome" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
        default = lib.mkForce [ "gtk" ];
      };
    };
  };
}
