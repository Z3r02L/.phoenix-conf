{ config, pkgs, inputs, lib, ... }: {
  imports = [
    ./niri.nix
    ./hyprland.nix
    ../llm.nix
    ../greetd.nix
    ../stylix.nix
  ];

  # Сообщаем системе (и XWayland) о наших раскладках
  services.xserver.xkb = {
    layout = "us,ru";
    options = "grp:lalt_lshift_toggle"; # укажите свою комбинацию
  };

  programs.hyprland.enable = true;

  programs.mango.enable = true;

  environment.systemPackages = with pkgs; [
    inputs.mangowm.packages.${pkgs.stdenv.hostPlatform.system}.default

    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default

    pcmanfm

    xdg-utils
    xdg-desktop-portal
    xdg-desktop-portal-gnome
    xdg-desktop-portal-gtk
    xdg-desktop-portal-wlr

    gnome-settings-daemon
    gsettings-desktop-schemas
  ];
}
