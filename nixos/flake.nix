{
  description = "NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devkit = {
      url = "github:stevalkr/devkit";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tmux-src = {
      url = "github:tmux/tmux";
      flake = false;
    };

    neovim-src = {
      url = "github:neovim/neovim";
      flake = false;
    };
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
      packages = nixpkgs.lib.genAttrs (linuxSystems ++ darwinSystems) (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          update = pkgs.writeShellScriptBin "update" ''
            #!/usr/bin/env bash
            ${pkgs._1password-cli}/bin/op inject -f -i "./modules/shared/default.nix.tpl" -o "./modules/shared/default.nix"
            ${pkgs._1password-cli}/bin/op inject -f -i "./modules/shared/configs/sing-box.json.tpl" -o "./modules/shared/configs/sing-box.json"
          '';

          install = pkgs.writeShellScriptBin "install" ''
            #!/usr/bin/env bash
            if [[ -f "/etc/nixos/flake.nix" ]]; then
              echo "NixOS configuration already exists at /etc/nixos/flake.nix, backing it up."
              sudo mv "/etc/nixos/flake.nix" "/etc/nixos/flake.nix.bak"
            fi
            hostname=$(hostname)
            config_url=$(dirname $(readlink -f $0))
            current_system=$(${pkgs.nix}/bin/nix eval --impure --expr 'builtins.currentSystem')
            sudo bash -c "cat <<EOF > '/etc/nixos/flake.nix'
            {
              inputs = {
                nixos-config.url = "path:$config_url";
              };
              outputs =
                { nixos-config, ... }:
                {
                  nixosConfigurations.$hostname = nixos-config.nixosConfigurations.$current_system.extendModules {
                    modules = [
                      ./hardware-configuration.nix
                    ];
                  };
                };
            }
            EOF"
          '';
        }
      );

      nixosConfigurations = nixpkgs.lib.genAttrs linuxSystems (
        system:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit user inputs; };
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
          specialArgs = { inherit user inputs; };
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
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = { inherit user inputs; };
          modules = [
            ./modules/shared/home.nix
          ];
        }
      );
    };
}
