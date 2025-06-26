{ config, lib, pkgs, inputs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ./boot.nix
    ./network.nix
    ./locale.nix
    ./user.nix
  ];

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "wojtek" = import ./home.nix;
    };
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

