# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  pkgs,
  inputs,
  ...
}:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    inputs.neovim-nightly-overlay.overlays.default
  ];

  fonts.packages = with pkgs; [
    monaspace
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    gh
    git
    wget
    curl
    firefox

    fd
    fzf
    tree
    htop
    direnv
    ripgrep
    imagemagick

    pixi
    gemini-cli

    nixd
    nixfmt-rfc-style

    black

    rustfmt

    gcc
    clang-tools
    cmake-format

    codespell
    tree-sitter
    markdownlint-cli

    stylua
    lua-language-server

    lua51Packages.lua
    luajitPackages.magick
    luajitPackages.luarocks-nix

    xclip
    xdotool
    wezterm

    (writeShellScriptBin "multiplexer" ''
      #!/usr/bin/env bash

      export MULTIPLEXER=1

      get_vim_direction() {
          case $1 in
              left) echo 'h'
              ;;
              down) echo 'j'
              ;;
              up) echo 'k'
              ;;
              right) echo 'l'
              ;;
              *) return 1
              ;;
          esac
      }

      activate_pane() {
          local dir=$(get_vim_direction "$1")
          if [ -z "$dir" ]; then
              return 1
          fi
          nvim --headless -c ":lua require('multiplexer').activate_pane('$dir')" -c ":qa"
      }

      resize_pane() {
          local dir=$(get_vim_direction "$1")
          if [ -z "$dir" ]; then
              return 1
          fi
          nvim --headless -c ":lua require('multiplexer').resize_pane('$dir')" -c ":qa"
      }

      i3() {
          local windowid=$(xdotool getactivewindow)
          local instance=$(xprop -id "$windowid" WM_CLASS | awk -F '"' '{print $2}')
          case "$instance" in
              "org.wezfurlong.wezterm" | "kitty")
              i3-msg mode passthrough_mode && sleep 0.2 && xdotool key --window "$windowid" "$1" Escape
              ;;
              *)
              MULTIPLEXER_LIST="i3" "$2" "$3"
              ;;
          esac
      }

      main_command="$1"
      if [ -z "$main_command" ]; then
          echo "Usage: $0 [activate_pane|resize_pane] [left|down|up|right]"
          exit 1
      fi
      shift

      "$main_command" "$@"
    '')
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # programs.bash = {
  #   extraInteractiveShellInit = ''
  #     if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && \
  #           -z ''${BASH_EXECUTION_STRING} ]]; then
  #       shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
  #       exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
  #     fi
  #   '';
  # };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withNodeJs = true;
    withPython3 = true;
  };

  programs.fish.enable = true;
  programs.tmux.enable = true;

  programs._1password.enable = true;
  programs._1password-gui.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.xserver = {
    enable = true;
    # videoDrivers = [ "nvidia" ];
    windowManager.i3.enable = true;
  };

  services.displayManager = {
    defaultSession = "none+i3";
    autoLogin = {
      enable = true;
      user = "walker";
    };
  };

  services.sing-box = {
    enable = true;
    settings = ./sing-box.nix;
  };

}
