{
  description = "NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-stevalkr.url = "github:stevalkr/nixpkgs?ref=stevalkr-patch-fzf";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs =
    { nixpkgs, home-manager, ... }@inputs:
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
    };
}
