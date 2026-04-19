{
  inputs,
  lib,
  ...
}: let
  inherit (lib) getExe;
in {
  # NixOS модуль для включения fish
  flake.nixosModules.fish = { config, pkgs, ... }: {
    programs.fish.enable = true;
  };

  # Wrapped пакет fish
  perSystem = { pkgs, ... }: {
    packages.fish = inputs.wrappers.lib.makeWrapper {
      inherit pkgs;
      package = pkgs.fish;
      runtimeInputs = [ pkgs.zoxide ];
      flags = {
        "-C" = "source ${pkgs.writeText "fishy-fishy" ''
          set fish_greeting
          fish_vi_key_bindings

          # Инициализация современных инструментов
          ${getExe pkgs.starship} init fish | source
          ${getExe pkgs.zoxide} init fish | source

          # Умные сокращения (Abbreviations) - расширяются при нажатии пробела
          if status is-interactive
              # Git
              abbr -a g git
              abbr -a gs git status
              abbr -a ga git add
              abbr -a gc git commit
              abbr -a gp git push
              abbr -a gl git log --graph --oneline --all

              # Nix / Phoenix
              abbr -a nrs nh os switch .
              abbr -a nrb nh os boot .
              abbr -a nfu nix flake update
              abbr -a ncg nix-collect-garbage -d

              # Замена стандартных команд на улучшенные версии
              abbr -a ls eza --icons --group-directories-first
              abbr -a ll eza -l --icons --group-directories-first
              abbr -a cat bat
              abbr -a grep rg
              abbr -a top btop
          end
        ''}";
      };
    };
  };
}
