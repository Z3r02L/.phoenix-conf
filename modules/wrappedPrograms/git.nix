{inputs, ...}: {
  perSystem = {pkgs, ...}: let
  in {
    packages.git = inputs.wrappers.lib.makeWrapper {
      inherit pkgs;
      package = pkgs.git;
      env = rec {
        GIT_AUTHOR_NAME = "zerg";
        GIT_AUTHOR_EMAIL = "zerg@goxore.com";
        GIT_COMMITTER_NAME = GIT_AUTHOR_NAME;
        GIT_COMMITTER_EMAIL = GIT_AUTHOR_EMAIL;
      };
    };
  };
}
