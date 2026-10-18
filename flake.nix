{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vim.url = "github:wk93/nvim";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
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
    formatter.${system} = pkgs.alejandra;

    devShells.${system}.native = pkgs.mkShell {
      packages = with pkgs; [
        pkg-config
        openssl
        vips
        cairo
        pango
        libpng
        libjpeg_turbo
        giflib
        pixman
      ];
      npm_config_sharp_libvips_local = "1";
    };

    nixosConfigurations.t480 = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {inherit inputs;};
      modules = [
        {
          nixpkgs.config.allowUnfree = true;
          nixpkgs.overlays = [
            inputs.vim.overlays.default
            (final: prev: {
              neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${system}.default;
            })
          ];
        }
        ./hosts/t480
        disko.nixosModules.disko
        home-manager.nixosModules.default
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "hm-backup";
            extraSpecialArgs = {inherit inputs system;};
            users.wojtek = import ./home.nix;
          };
        }
      ];
    };
  };
}
