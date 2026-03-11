{self, ...}: {
  flake.nixosModules.general = {
    pkgs,
    config,
    ...
  }: {
    imports = [
      self.nixosModules.home-manager
      self.nixosModules.gtk
      self.nixosModules.nix
    ];

    users.users.${config.preferences.user} = { # ${config.preferences.user}
      isNormalUser = true;
      description = "${config.preferences.user}'s account"; # ${config.preferences.user}
      extraGroups = ["wheel" "networkmanager"];
      shell = self.packages.${pkgs.stdenv.hostPlatform.system}.environment;

    #  hashedPasswordFile = "/persist/passwd";
    #  initialPassword = "12345";
    };

  #  persistance.data.directories = [
  #    "nixconf"

  #    "Videos"
  #    "Documents"
  #    "Projects"

  #    ".ssh"
  #  ];

  #  # todo: remove
  #  persistance.cache.directories = [
  #    ".local/share/nvim"
  #    ".local/share/fish"
  #    ".config/nvim"
  #  ];
  };
}
