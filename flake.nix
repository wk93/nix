{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    disko.url = "github:nix-community/disko";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, disko, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in {
        formatter = pkgs.nixpkgs-fmt;
      }) // {
        nixosConfigurations.t480 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/t480/configuration.nix
            ./hosts/t480/hardware-configuration.nix
            ./hosts/t480/disko.nix
            disko.nixosModules.disko
          ];
        };
      };
}
