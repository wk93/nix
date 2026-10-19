{
  config,
  pkgs,
  lib,
  ...
}: {
  hardware.graphics = {
    enable = true;
    extraPackages = [pkgs.intel-media-driver];
  };

  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";

  boot.blacklistedKernelModules = ["nouveau"];

  # Default boot entry: dGPU powered down and removed from the PCI bus
  services.udev.extraRules = lib.mkIf (config.specialisation != {}) ''
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
  '';

  specialisation.nvidia.configuration = {
    system.nixos.tags = ["nvidia"];

    services.xserver.videoDrivers = ["nvidia"];

    hardware.nvidia = {
      modesetting.enable = true;
      open = false;
      nvidiaSettings = true;

      # MX150 (Pascal) is dropped from the 590+ drivers
      package = config.boot.kernelPackages.nvidiaPackages.legacy_580;

      powerManagement.enable = true;

      prime = {
        offload.enable = true;
        offload.enableOffloadCmd = true;

        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };
}
