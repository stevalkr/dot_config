{
  description = "NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-stevalkr.url = "github:stevalkr/nixpkgs?ref=stevalkr-patch-fzf";

    devkit = {
      url = "github:stevalkr/devkit";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs =
    {
      nixpkgs,
      nix-darwin,
      home-manager,
      ...
    }@inputs:
    let
      user = "walker";

      linuxSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      darwinSystems = [
        "x86_64-darwin"
        "aarch64-darwin"
      ];
    in
    {
      nixosConfigurations = nixpkgs.lib.genAttrs linuxSystems (
        system:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit user; };
          modules = [
            ./modules/nixos
            ./modules/shared
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit user inputs; };
                users.${user} = ./modules/shared/home.nix;
              };
            }
          ];
        }
      );

      darwinConfigurations = nixpkgs.lib.genAttrs darwinSystems (
        system:
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = { inherit user; };
          modules = [
            ./modules/darwin
            ./modules/shared
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit user inputs; };
                users.${user} = ./modules/shared/home.nix;
              };
            }
          ];
        }
      );

      homeConfigurations = nixpkgs.lib.genAttrs (linuxSystems ++ darwinSystems) (
        system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
          };
          extraSpecialArgs = { inherit user inputs; };
          modules = [
            ./modules/shared/home.nix
          ];
        }
      );
    };
}
