{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    disko.url = "github:nix-community/disko";
    flake-utils.url = "github:numtide/flake-utils";
    vim.url = "github:wk93/vim";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    disko,
    home-manager,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    formatter = pkgs.nixpkgs-fmt;

    nixosConfigurations.t480 = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        {nixpkgs.config.allowUnfree = true;}
        ./hosts/t480
        disko.nixosModules.disko
        home-manager.nixosModules.default
      ];
    };

    homeConfigurations = {
      "wojtek@t480" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit inputs system;
        };
        modules = [
          ./home.nix
        ];
      };
    };
  };
}
