#!/usr/bin/env bash
op inject -f -i "./sing-box.nix.tpl" -o "./sing-box.nix"
op inject -f -i "./configuration.nix.tpl" -o "./configuration.nix"

nix flake update --flake "$(dirname $(readlink -f $0))"
sudo nix flake update --flake "/etc/nixos"
