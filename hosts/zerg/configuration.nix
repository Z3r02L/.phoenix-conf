{ config, pkgs, inputs, ... }:
{
  imports = [
    inputs.self.nixosModules.nix # импорт модуля nix с настройками экспериментальных функций
    inputs.home-manager.nixosModules.home-manager
    ({ config, ... }: {
      home-manager.users.zerg = import ../../users/zerg/home.nix { inherit config pkgs inputs; };
    })
  ];
 networking.hostName = "zerg";

  # Отключаем документацию для обхода бага в Sphinx/nixpkgs
  documentation.man.enable = false;
  documentation.doc.enable = false;
  
  # SSH server configuration
 services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      PubkeyAuthentication = true;
    };
  };
  
 # Установка переменной окружения GITHUB_TOKEN
  environment.variables.GITHUB_TOKEN = pkgs.lib.mkIf (builtins.pathExists "/home/zerg/.config/nix/github-token") (builtins.readFile "/home/zerg/.config/nix/github-token");
  
  # прочие параметры хоста
}
