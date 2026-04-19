{ ... }: {
  imports = [ ../features/desktop/stylix.nix ];
  services.logind.settings.Login.HandleLidSwitch = "suspend";
}
