{ config, lib, pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
    powerManagement.enable = true;
    open = false;
    nvidiaSettings = true;

    # Обязательно для Wayland-композиторов (niri)
    forceFullCompositionPipeline = true;
  };

  # Переменные окружения для Nvidia + Wayland
environment.sessionVariables = {
  NIXOS_OZONE_WL = "1";
  LIBVA_DRIVER_NAME = "nvidia";
  __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  GBM_BACKEND = "nvidia-drm";
  NVD_BACKEND = "direct";
  
  # Для стриминга и порталов
  NGX_DISABLE_IMAGE_SHARING = "1";
  XDG_CURRENT_DESKTOP = "niri";

  # Отключаем G-Sync/VRR, так как они могут вызывать мерцание при захвате
  __GL_GSYNC_ALLOWED = "0";
  __GL_VRR_ALLOWED = "0";

  # Если курсор пропадет — раскомментируй:
  # WLR_NO_HARDWARE_CURSORS = "1";
};

  # Параметры ядра для Nvidia
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
  ];

  # Фикс высокого потребления VRAM для niri (GLVidHeapReuseRatio = 0)
  # https://github.com/niri-wm/niri/wiki/Nvidia
environment.etc."nvidia/nvidia-application-profiles-rc.d/50-niri.json".text = builtins.toJSON {
  rules = [
    {
      pattern = { feature = "procname"; matches = "niri"; };
      profile = "Limit Free Buffer Pool On Wayland Compositors";
    }
  ];
  profiles = [
    {
      name = "Limit Free Buffer Pool On Wayland Compositors";
      settings = [ { key = "GLVidHeapReuseRatio"; value = 0; } ];
    }
  ];
};
}
