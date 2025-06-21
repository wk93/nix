{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    disko.url = "github:nix-community/disko";
  };

  outputs = { self, nixpkgs, disko, ... }@inputs: {
    nixosConfigurations.t480 = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        ./configuration.nix
        ./hardware-configuration.nix
        ./disko.nix
        disko.nixosModules.disko
      ];
    };
  };
}
