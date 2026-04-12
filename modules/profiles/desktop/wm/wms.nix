{ config, pkgs, inputs, lib, ... }: {
  imports = [
    ./niri.nix
    ./hyprland.nix
    ../llm.nix
  ];

  config = {
    programs.hyprland.enable = true;
    # niri configuration is handled in its own module

    programs.mango.enable = true;


    environment.systemPackages = with pkgs; [

      fuzzel

      inputs.mangowm.packages.${pkgs.stdenv.hostPlatform.system}.default

      inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
      # inputs.dankMaterialShell.nixosModules.dankMaterialShell - это модуль, не пакет!

      brave
      ungoogled-chromium
      librewolf

      pcmanfm # Gui File Manager

      # Additional packages for Wayland support
      xdg-utils
      xdg-desktop-portal
      xdg-desktop-portal-gnome

      telegram-desktop

      tmux
      alacritty kitty
      zsh fish nushell
      zed-editor-fhs vscode-fhs antigravity-fhs

      # LLM-инструменты перенесены в ../llm.nix

    ];
  };
}
