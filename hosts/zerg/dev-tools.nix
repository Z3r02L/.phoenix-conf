# modules/development/default.nix
{ config, pkgs, ... }:
let
  # unstable = pkgs.unstable;
in
{
  imports = [
    # ./languages.nix
    # ./tools.nix
    # ./ides.nix
  ];

  # Установить инструменты разработки
  environment.systemPackages = with pkgs; [
    # Compilers
    gcc clang

    rustc rust-analyzer # Rust

    go gopls # Golang

    python311 uv # Python
    python3.pkgs.python-lsp-server

    # JavaScript
    nodejs_24 bun pnpm
    typescript-language-server
    biome


    # Build tools
    cmake meson ninja

    lua-language-server

    # Version control
    git-crypt
    git-lfs
    gh

    # Testing
    # pytest # ошибка
    cargo
    cargo-watch
  ];
}
