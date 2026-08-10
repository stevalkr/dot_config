{
  pkgs,
  user,
  ...
}:

{
  # Set your time zone
  time.timeZone = "Asia/Singapore";

  # Nix settings
  nix = {
    settings.trusted-users = [
      "root"
      "@admin"
    ];

    gc = {
      automatic = true;
      interval = {
        Weekday = 0;
      };
      options = "--delete-older-than 30d";
    };
  };

  users.users = {
    ${user} = {
      isHidden = false;
      description = "Steve Walker";
      home = "/Users/${user}";
    };
  };

  environment.systemPackages = with pkgs; [
    mtr
  ];

  services = {
    openssh.enable = true;
  };

  system = {
    primaryUser = user;

    defaults = {
      NSGlobalDomain = {
        KeyRepeat = 3;
        InitialKeyRepeat = 16;
        AppleShowAllExtensions = true;
        AppleSpacesSwitchOnActivate = false;
        AppleInterfaceStyleSwitchesAutomatically = true;
      };
    };
  };

  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";

    taps = [
      {
        name = "brewforge/chinese";
        trusted = true;
      }
      {
        name = "brewforge/extras";
        trusted = true;
      }
    ];

    brews = [
      "sccache"
      "libomp"
    ];

    casks = [
      "visual-studio-code"
      "docker-desktop"
      "1password-cli"
      "1password"
      "raycast"
      "xquartz"
      "v2rayn"
      "codex"
    ];
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;
}
