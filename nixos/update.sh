#!/usr/bin/env bash
op inject -f -i "./modules/shared/default.nix.tpl" -o "./modules/shared/default.nix"
op inject -f -i "./modules/shared/configs/sing-box.nix.tpl" -o "./modules/shared/configs/sing-box.nix"

sudo nix flake update --flake "$(dirname $(readlink -f $0))"
sudo nix flake update --flake "/etc/nixos"
