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
      # niri screencast works more reliably via the GNOME portal backend.
      xdg-desktop-portal-gnome
    ];
    config = {
      common.default = [ "gnome" ];
      niri = {
        # Force ScreenCast/Screenshot to the GNOME backend so WebRTC/PipeWire
        # apps like Vesktop can discover org.freedesktop.portal.ScreenCast.
        "org.freedesktop.portal.Screencast" = [ "gnome" ];
        "org.freedesktop.portal.Screenshot" = [ "gnome" ];
        # Handy relies on the GlobalShortcuts portal for push-to-talk hotkeys
        # such as Ctrl+Space under Wayland.
        "org.freedesktop.portal.GlobalShortcuts" = [ "gnome" ];
        default = lib.mkForce [ "gtk" ];
      };
    };
  };

  # xdg-desktop-portal-gnome only exposes ScreenCast reliably for this setup
  # when it thinks it is running in a GNOME desktop session.
  systemd.user.services.xdg-desktop-portal.environment = {
    XDG_CURRENT_DESKTOP = "GNOME";
    XDG_SESSION_DESKTOP = "GNOME";
  };

  # Keep the backend service in the same desktop context as the main portal.
  systemd.user.services.xdg-desktop-portal-gnome.environment = {
    XDG_CURRENT_DESKTOP = "GNOME";
    XDG_SESSION_DESKTOP = "GNOME";
  };
}
