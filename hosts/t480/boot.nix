{
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Force load videocard driver for tty
  boot.initrd.kernelModules = [ "i915" ];

  # Hibernation with LUKS
  boot.resumeDevice = "/dev/mapper/cryptroot";
  boot.kernelParams = [ "resume=/dev/mapper/cryptroot" ];
}
