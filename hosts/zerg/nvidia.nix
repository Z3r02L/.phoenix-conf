{ config, lib, pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    modesetting.enable = true;
    powerManagement.enable = true;
    open = false;
    nvidiaSettings = true;

    # Отключаем, так как на Wayland это может мешать захвату
    forceFullCompositionPipeline = false;
  };

  # Переменные окружения для Nvidia + Wayland
environment.sessionVariables = {
  NIXOS_OZONE_WL = "1";
  ELECTRON_OZONE_PLATFORM_HINT = "wayland";
  LIBVA_DRIVER_NAME = "nvidia";
  __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  NVD_BACKEND = "direct";
  
  # Для стриминга и порталов
  NGX_DISABLE_IMAGE_SHARING = "1";
  XDG_CURRENT_DESKTOP = "niri";
  WLR_NO_HARDWARE_CURSORS = "1";
  
  # Wayland backends
  QT_QPA_PLATFORM = "wayland;xcb";
  GDK_BACKEND = "wayland,x11";
  SDL_VIDEODRIVER = "wayland";
  CLUTTER_BACKEND = "wayland";

  # Отключаем G-Sync/VRR, так как они могут вызывать мерцание при захвате
  __GL_GSYNC_ALLOWED = "0";
  __GL_VRR_ALLOWED = "0";
  __GL_MaxFramesAllowed = "1";
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
      pattern = { feature = "procname"; matches = "niri|mango"; };
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
