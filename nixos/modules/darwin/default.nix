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
      interval = { Weekday = 0; };
      options = "--delete-older-than 30d";
    };
  };

  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users = {
    ${user} = {
      isHidden = false;
      description = "Steve Walker";
      home = "/Users/${user}";
    };
  };

  environment.systemPackages = with pkgs; [ neovim ];

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

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;
}
