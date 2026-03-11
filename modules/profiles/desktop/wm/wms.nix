{ config, pkgs, inputs, lib, ... }: {
  imports = [
    ./niri.nix
    ./hyprland.nix
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
      xdg-desktop-portal-wlr

      vesktop
      telegram-desktop

      tmux
      alacritty kitty
      zsh fish nushell
      zed-editor-fhs vscode-fhs antigravity-fhs # antigravity-fhs

      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.eca # plugin for any editor
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.forge
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.nanocoder

      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omp # opencode multi-agent
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode

      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.cc-sdd
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.openspec
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.openskills

      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.code # codex opencode-source fork any provider
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code-router # claude code with any provider
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.vibe-kanban # vibe-kanban

      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.qwen-code # ?
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.gemini-cli # ?
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.kilocode-cli # ?

      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.rtk # token consumption by 60-90% on common dev commands

      # inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.zeroclaw # best openclaw (on rust)
      # ... other tools

    ];
  };
}
