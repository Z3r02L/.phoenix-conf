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
          function fish_prompt
              string join "" -- (set_color red) "[" (set_color yellow) $USER (set_color green) "@" (set_color blue) $hostname (set_color magenta) " " $(prompt_pwd) (set_color red) ']' (set_color normal) "\$ "
          end

          set fish_greeting
          fish_vi_key_bindings

          ${getExe pkgs.zoxide} init fish | source

          function lf --wraps="lf" --description="lf - Terminal file manager (changing directory on exit)"
              cd "$(command lf -print-last-dir $argv)"
          end
        ''}";
      };
    };
  };
}
