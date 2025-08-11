#!/usr/bin/env bash
op inject -f -i "./sing-box.nix.tpl" -o "./sing-box.nix"
op inject -f -i "./configuration.nix.tpl" -o "./configuration.nix"

if [[ -f "/etc/nixos/flake.nix" ]]; then
  echo "NixOS configuration already exists at /etc/nixos/flake.nix, backing it up."
  sudo mv "/etc/nixos/flake.nix" "/etc/nixos/flake.nix.bak"
fi

sudo bash -c "cat <<EOF > '/etc/nixos/flake.nix'
{
  inputs = {
    nixos-config.url = \"path:$(dirname $(readlink -f $0))\";
  };
  outputs = { self, nixos-config, ... }:
    {
      nixosConfigurations.nixos = nixos-config.nixosConfigurations.nixos.extendModules {
        modules = [
          ./hardware-configuration.nix
        ];
      };
    };
}
EOF"
