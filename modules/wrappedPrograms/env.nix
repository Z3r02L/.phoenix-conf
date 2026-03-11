{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    file
    eza              # Better ls
    zoxide           # Better cd
    yazi             # Terminal file manager
    bat              # Better cat
    fd               # Better find
    ripgrep-all      # Better grep
    fzf              # Fuzzy finder
    wget
    curl
    killall
    zip
    unzip
    jq
    rsync
    borgbackup
    coreutils
    ydotool
    gnupg
    age
    tree

    # Nix workflow
    nixd  # Nix LSP
    nh # nix helper
    statix alejandra
    direnv
    devenv
    nix-output-monitor

    # Git tools
    lazygit          # Git TUI
    lazyjj

    # Networking tools
    nmap

    # Pass
    (pass-wayland.withExtensions (exts: with exts; [
        pass-otp
        pass-import
        pass-audit
    ]))

    # System tools
    btop             # Better top
    trash-cli        # Safe rm
    tldr             # Simplified man pages
    fastfetch        # System info
    microfetch

    # Development containers
    podman           # Container runtime
    podman-compose   # Docker-compose for podman
 ];

  environment.variables = {
    EDITOR = "${pkgs.neovim}/bin/nvim";
  };
}
