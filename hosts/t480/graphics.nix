{
  config,
  pkgs,
  lib,
  ...
}: {
  services.xserver.videoDrivers = ["nvidia"];

  hardware.graphics = {
    enable = true;
    extraPackages = [pkgs.intel-media-driver];
  };

  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";

  hardware.nvidia = {
    modesetting.enable = true;

    open = false;

    nvidiaSettings = true;

    # MX150 (Pascal) is dropped from the 590+ drivers
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;

    powerManagement.enable = true;
    powerManagement.finegrained = true;

    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;

      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
