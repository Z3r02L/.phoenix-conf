{ config, pkgs, inputs, lib, ... }: {
  imports = [
    ./niri.nix
    ./hyprland.nix
    ../llm.nix
    ../greetd.nix
    ../stylix.nix
  ];

  programs.hyprland.enable = true;

  programs.mango.enable = true;

  environment.systemPackages = with pkgs; [
    fuzzel

    inputs.mangowm.packages.${pkgs.stdenv.hostPlatform.system}.default

    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default

    brave
    ungoogled-chromium
    librewolf

    pcmanfm

    xdg-utils
    xdg-desktop-portal
    xdg-desktop-portal-gnome
    xdg-desktop-portal-gtk

    gnome-settings-daemon
    gsettings-desktop-schemas

    telegram-desktop

    tmux
    alacritty kitty
    zsh fish nushell
    zed-editor-fhs vscode-fhs antigravity-fhs
  ];
}
