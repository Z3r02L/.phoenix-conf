{ config, lib, pkgs, ... }:
{
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  boot.kernelModules = [ "kvm-amd" "amd-pstate" ];
  boot.kernelParams = [ "amd_pstate=active" ];
  services.fstrim.enable = true;
}
