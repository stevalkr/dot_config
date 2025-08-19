#!/usr/bin/env bash
op inject -f -i "./modules/shared/default.nix.tpl" -o "./modules/shared/default.nix"
op inject -f -i "./modules/shared/configs/sing-box.nix.tpl" -o "./modules/shared/configs/sing-box.nix"

if [[ -f "/etc/nixos/flake.nix" ]]; then
  echo "NixOS configuration already exists at /etc/nixos/flake.nix, backing it up."
  sudo mv "/etc/nixos/flake.nix" "/etc/nixos/flake.nix.bak"
fi

config_url=$(dirname $(readlink -f $0))
hostname=$(hostname)
current_system=$(nix eval --impure --expr 'builtins.currentSystem')

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
