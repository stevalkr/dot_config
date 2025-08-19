{
  pkgs,
  user,
  osConfig,
  inputs,
  ...
}:

{
  nix.gc = {
    automatic = true;
    frequency = "weekly";
    options = "--delete-older-than 30d";
  };

  home = {
    username = user;
    homeDirectory = osConfig.users.users.${user}.home;

    file = { };
    packages = with pkgs; [
      gh
      git
      wget
      curl

      fd
      tree
      htop
      ripgrep

      pixi
      gemini-cli

      clang-tools
      cmake-format

      rustfmt

      black

      stylua
      lua-language-server

      nixd
      nixfmt-rfc-style

      codespell
      tree-sitter
      markdownlint-cli

      (runCommand "multiplexer-nvim" { } ''
        script_path=${
          pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/stevalkr/multiplexer.nvim/refs/heads/main/scripts/multiplexer";
            hash = "sha256-AsDLb8uX3XF9n94cDK04QKbTHf6SVcdkI59bHsqCVzc=";
          }
        }
        mkdir -p $out/bin
        cp $script_path $out/bin/multiplexer
        chmod +x $out/bin/multiplexer
      '')
    ];

    enableNixpkgsReleaseCheck = false;

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "25.05";
  };

  programs = {
    nix-index.enable = true;
    man.generateCaches = true;

    fish = import ./configs/fish.nix { inherit pkgs; };

    tmux = import ./configs/tmux.nix;

    wezterm = import ./configs/wezterm.nix;

    fzf = import ./configs/fzf.nix {
      package = inputs.nixpkgs-stevalkr.legacyPackages.${pkgs.system}.fzf;
    };

    direnv = {
      enable = true;
    };

    neovim = import ./configs/neovim.nix {
      inherit pkgs;
      package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
    };
  };
}
