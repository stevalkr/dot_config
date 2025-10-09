{
  pkgs,
  user,
  inputs,
  osConfig,
  ...
}:

let
  getExeInPath =
    x:
    pkgs.lib.findFirst (p: builtins.pathExists p) null (
      map (p: /. + p + "/${x}") (pkgs.lib.splitString ":" (builtins.getEnv "PATH"))
    );

  os =
    if pkgs.stdenv.isDarwin then
      "darwin"
    else if (builtins.getEnv "WSLENV") != "" then
      "wsl"
    else
      "linux";

  osSpecific = {
    darwin = {
      homeDirectory = "/Users/${user}";
      ssh-agent = "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
      ssh-signer = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
    };

    linux = {
      homeDirectory = "/home/${user}";
      ssh-agent = "~/.1password/agent.sock";
      ssh-signer = pkgs.lib.getExe' pkgs._1password-gui "op-ssh-sign";
    };

    wsl = {
      homeDirectory = "/home/${user}";
      ssh-agent = null;
      ssh-signer = toString (getExeInPath "op-ssh-sign-wsl.exe");
    };
  };

  osSpecificConfigs = osSpecific.${os} or { };
in
{
  nix.gc = {
    automatic = true;
    frequency = "weekly";
    options = "--delete-older-than 30d";
  };

  home = {
    username = user;
    homeDirectory = osConfig.users.users.${user}.home or osSpecificConfigs.homeDirectory;

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

      treefmt

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

      inputs.devkit.packages.${pkgs.system}.sk

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
    home-manager.enable = osConfig == null;

    ssh = import ./configs/ssh.nix {
      inherit (osSpecificConfigs) ssh-agent;
    };

    git = import ./configs/git.nix {
      inherit (osSpecificConfigs) ssh-signer;
    };

    fish = import ./configs/fish.nix { inherit pkgs; };

    tmux = import ./configs/tmux.nix {
      package = pkgs.tmux.overrideAttrs (oldAttrs: {
        src = inputs.tmux-src;
      });
    };

    zoxide = import ./configs/zoxide.nix;

    wezterm = import ./configs/wezterm.nix;

    # TODO: https://github.com/NixOS/nixpkgs/pull/433661
    fzf = import ./configs/fzf.nix {
      package = pkgs.fzf.overrideAttrs (oldAttrs: {
        postInstall = ''
          install bin/fzf-tmux $out/bin

          installManPage man/man1/fzf.1 man/man1/fzf-tmux.1

          install -D plugin/* -t $out/share/vim-plugins/fzf/plugin
          mkdir -p $out/share/nvim
          ln -s $out/share/vim-plugins/fzf $out/share/nvim/site

          # Install shell integrations
          install -D shell/* -t $out/share/fzf/

          cat <<SCRIPT > $out/bin/fzf-share
          #!${pkgs.runtimeShell}
          # Run this script to find the fzf shared folder where all the shell
          # integration scripts are living.
          echo $out/share/fzf
          SCRIPT
          chmod +x $out/bin/fzf-share
        '';
      });
    };

    direnv = {
      enable = true;
    };

    neovim = import ./configs/neovim.nix {
      inherit pkgs;
      inherit (inputs) neovim-src;
    };
  };
}
