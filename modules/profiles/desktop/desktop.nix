{
  imports = [
    ./wm/wms.nix
    ./greetd.nix
    ./stylix.nix
  ];
  services.pipewire.enable = true;
}
