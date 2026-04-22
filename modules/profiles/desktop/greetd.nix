{ config, pkgs, ... }: {
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --asterisks --user-menu --cmd '${config.programs.niri.package}/bin/niri-session'";
        user = "greeter";
      };
    };
  };
}
