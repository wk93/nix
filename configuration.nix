{ config, lib, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  imports =
    [ 
      "${builtins.fetchTarball "https://github.com/nix-community/disko/archive/master.tar.gz"}/module.nix"
      ./hardware-configuration.nix
      ./disko.nix
    ];

  # Basic config
  networking.hostName = "t480";
  networking.networkmanager.enable = true;  
  time.timeZone = "Europe/Warsaw";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    earlySetup = true;
    packages = with pkgs; [ terminus_font ];
    font = "${pkgs.terminus_font}/share/consolefonts/ter-132n.psf.gz";
    keyMap = lib.mkForce "pl2";
    useXkbConfig = true; 
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Force load videocard driver for tty
  boot.initrd.kernelModules = [ "i915" ];

  # Hibernation with LUKS
  boot.resumeDevice = "/dev/mapper/cryptroot";
  boot.kernelParams = [ "resume=/dev/mapper/cryptroot" ];

  # Define a user account
  users.users.wojtek = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    hashedPassword = "$6$rFEKCWBXwA.62ha/$APg2bkmM/X7Ei50IYIu6SKN0SfCPC2ZlF/Dni2AZxTbo9FhGE809ifqffmRtmGf1XcKYk38sjbMni2MgQxq1g/"; 
  };

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    neovim
    wget
    lazygit
    git
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  system.stateVersion = "24.11"; 
}

