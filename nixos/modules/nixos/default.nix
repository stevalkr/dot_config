{
  pkgs,
  user,
  ...
}:

{
  # Bootloader
  boot = {
    loader.systemd-boot.enable = true;
    loader.systemd-boot.configurationLimit = 5;
    loader.efi.canTouchEfiVariables = true;
    kernelPackages = pkgs.linuxPackages_latest;
  };

  # Set your time zone
  time.timeZone = "Asia/Singapore";

  i18n.defaultLocale = "en_US.UTF-8";

  # Networking
  networking = {
    hostName = "nixos";

    # Enable networking
    networkmanager.enable = true;

    # Open ports in the firewall
    # firewall.allowedTCPPorts = [ ... ];
    # firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether
    firewall.enable = false;

    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  };

  # Nix settings
  nix = {
    settings.trusted-users = [
      "root"
      "@wheel"
    ];

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users = {
    ${user} = {
      isNormalUser = true;
      description = "Steve Walker";
      home = "/home/${user}";
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
    };
  };

  # Enable documentation
  documentation = {
    dev.enable = true;
    man.generateCaches = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    gcc
    clang
    xclip
    xdotool
    firefox
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions
  programs = {
    mtr.enable = true;
    command-not-found.enable = false;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    _1password.enable = true;
    _1password-gui.enable = true;
  };

  # List services that you want to enable
  services = {
    # Enable automatic login for the user
    getty.autologinUser = user;

    # Enable the OpenSSH daemon.
    openssh.enable = true;

    # Enable resolved for TUN mode
    resolved.enable = true;

    # Better support for general peripherals
    libinput.enable = true;

    # Enable sing-box
    sing-box = {
      enable = true;
      settings = builtins.fromJSON (builtins.readFile ../shared/configs/sing-box.json);
    };

    # Enable X11
    xserver = {
      enable = true;
      windowManager.i3.enable = true;

      # Enable Nvidia GPU support
      # videoDrivers = [ "nvidia" ];

      # Configure keymap in X11
      xkb = {
        layout = "us";
        variant = "";
      };
    };

    displayManager = {
      defaultSession = "none+i3";
      autoLogin = {
        enable = true;
        user = user;
      };
    };
  };

  # Hardware settings
  hardware = {
    graphics.enable = true;
    # nvidia.open = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
