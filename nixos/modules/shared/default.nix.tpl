{ pkgs, ... }:

{
  nixpkgs = {
    overlays = [ ];
    config.allowUnfree = true;
  };

  nix.channel.enable = false;
  nix.optimise.automatic = true;

  nix.settings = {
    keep-outputs = true;
    keep-derivations = true;
    experimental-features = [
      "flakes"
      "nix-command"
    ];
    extra-substituters = [
      "https://ros.cachix.org"
      "https://nix-community.cachix.org"
      "https://cuda-maintainers.cachix.org"
    ];
    extra-trusted-public-keys = [
      "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    ];
    access-tokens = "github.com={{ op://Private/GitHub/Nixpkgs Token }}";
  };

  fonts.packages = with pkgs; [
    monaspace
  ];
}
