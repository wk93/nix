{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  nix.settings.experimental-features = ["nix-command" "flakes"];

  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ./boot.nix
    ./network.nix
    ./graphics.nix
    ./sound.nix
    ./bluetooth.nix
    ./maintenance.nix
    ./locale.nix
    ./shell.nix
    ./greetd.nix
    ./desktop.nix
    ./user.nix
  ];

  security.polkit.enable = true;
  services.dbus.enable = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    neovim
    wget
    git
    android-tools
    foot
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
    (writeShellScriptBin "rebuild" ''
      [ "$EUID" -eq 0 ] || exec sudo "$0" "$@"
      exec nixos-rebuild "''${1:-switch}" --flake /home/wojtek/nixos-config#t480 "''${@:2}"
    '')
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = false;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  system.stateVersion = "24.11";
}
