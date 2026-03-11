{ config, pkgs, ... }: {
  imports = [
    # Добавим сюда необходимые импорты, если они существуют в других местах
 ];

  users.users.zerg = { # Предполагаем, что config.preferences.user не определен в этом контексте
    isNormalUser = true;
    description = "zerg's account";
    extraGroups = ["wheel" "networkmanager"];
    shell = pkgs.bash; # используем стандартную оболочку, так как self.packages не доступен
  };
}
