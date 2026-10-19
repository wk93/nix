{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    extra-substituters = ["https://nix-community.cachix.org"];
    extra-trusted-public-keys = ["nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="];
  };

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
    (writeShellScriptBin "rebuild" ''
      [ "$EUID" -eq 0 ] || exec sudo "$0" "$@"
      action=''${1:-switch}
      spec=()
      if [[ $action =~ ^(switch|test)$ && $(readlink /run/current-system) == *-nvidia-* ]]; then
        spec=(--specialisation nvidia)
      fi
      exec nixos-rebuild "$action" --flake /home/wojtek/nixos-config#t480 "''${spec[@]}" "''${@:2}"
    '')
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
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
