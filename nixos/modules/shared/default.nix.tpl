{ pkgs, inputs, ... }:

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

  environment = {
    shells = with pkgs; [
      fish
    ];

    systemPackages = with pkgs; [
      fish
      sccache
    ];

    pathsToLink = [
      "/share/zsh"
      "/share/fish"
    ];
  };

  programs =
    let
      activateFishShell =
        if pkgs.stdenv.isLinux then
          ''
            source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh

            if [[ -z "''$__NO_AUTO_FISH" && $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
            then
              shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
              exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
            fi
          ''
        else
          ''
            if [[ -z "''$__NO_AUTO_FISH" && $(${pkgs.procps}/bin/ps -o command= -p "$PPID" | ${pkgs.gawk}/bin/awk '{print $1}') != 'fish' ]]
            then
                exec fish --login
            fi
          '';
    in
    {
      zsh = {
        interactiveShellInit = activateFishShell;
      };

      bash = {
        interactiveShellInit = activateFishShell;
      };

      _1password.enable = true;
      _1password-gui.enable = true;
    };
}
