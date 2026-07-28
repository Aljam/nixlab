{ pkgs, config, inputs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  ### Bootloader (SystemD-Boot)
  # boot.loader = {
  #   systemd-boot.enable = true;
  #   efi.canTouchEfiVariables = true;
  # };

  ### Bootloader (GRUB)
  boot.loader = {
    timeout = 10;
    systemd-boot.enable = false;
    # If it doesn't boot, change this to 'false'.
    # \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/
    efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
      efiSupport = true;
      # If it doesn't boot and you changed 'efi.canTouchEfiVariables'
      # to 'false', change this to 'true'.
      # \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/
      efiInstallAsRemovable = false;
      device = "nodev";
      gfxmodeEfi = "1920x1200";
      gfxmodeBios = "1920x1200";
      gfxpayloadEfi = "keep";
      configurationLimit = 10;
      timeoutStyle = "menu";
    };
  };
  ### Bootloader (Rescue Mode Entry >> Fallback Emergency TTY Shell)
  specialisation = {
    rescue-mode.configuration = {
      system.nixos.tags = [
        "rescue"
      ];
      boot.kernelParams = [
        "systemd.unit=rescue.target"
      ];
    };
  };

  ### Nvidia
  hardware.nvidia = {
    open = false;
    modesetting.enable = true;
    nvidiaPersistenced = true;
    powerManagement.enable = true;
    # For Kepler K2100M ThinkPad W540 GPU, use 'legacy_470' Driver.
    prime = {
      sync.enable = true;
      # Check BUS-IDs via 'lspci | grep VGA'.
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  ### Kernel
  # If Nvidia doesn't work, remove all lines below,
  # marked with an '(X)' at the end of the line.
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    blacklistedKernelModules = [ "nouveau" ];
    kernelParams = [
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
      "nvidia.NVreg_EnableGpuFirmware=1"
      "system76_acpi.brightness_hwmon=1"
      "nvidia-drm.modeset=1" # (X)
    ];
    crashDump = {
      enable = true;
      reservedMemory = "512M";
    };
    kernel.sysctl = {
      "kernel.sysrq" = 1;
      "kernel.printk" = "7 4 1 7";
    };
  };
  environment.sessionVariables = { # (X)
    LIBVA_DRIVER_NAME = "nvidia"; # (X)
    GBM_BACKEND = "nvidia-drm"; # (X)
    __GLX_VENDOR_LIBRARY_NAME = "nvidia"; # (X)
  }; # (X)

  ### I2P
  # services = {
  #   i2pd = {
  #     enable = true;
  #     address = "127.0.0.1";
  #     proto = {
  #       # Firefox/LibreWolf Network Settings to access I2P:
  #       # Leave HTTP and HTTPS Proxies blank.
  #       # ---
  #       # Address: 127.0.0.1
  #       # Port: 4447
  #       # SOCKS: SOCKS5
  #       # ---
  #       http.enable = true;
  #       socksProxy.enable = true;
  #       httpProxy.enable = true;
  #       sam.enable = true;
  #     };
  #   };
  # };
  # Option below disables auto-startup of i2p(d) Service,
  # so you need to run 'systemctl start i2pd.service'. Comment
  # out or remove line below to auto-start i2p(d).
  # ---
  # systemd.services.i2pd.wantedBy = lib.mkForce [ ];

  ### System76 (modules/system76/support.nix)
  hardware.system76 = {
    # Fan Monitoring, and EC Communication.
    kernel-modules.enable = true;
    # Firmware Ppdates via FWUpD.
    firmware-daemon.enable = true;
    # Thermal Management, Power Profiles, Battery Thresholds.
    power-daemon.enable = true;
  };
  services.fwupd.enable = true;
  # (modules/system76/services.nix)
  services = {
    # Thermal Management via System76-Power. (hardware.system76.power-daemon)
    thermald.enable = false;
    # Desktop Responsiveness.
    system76-scheduler.enable = true;
    # Conflicts with System76-Power.
    power-profiles-daemon.enable = false;
  };
  powerManagement = {
    cpuFreqGovernor = "performance";
  };
  programs = {
    # Conflicts with EC.
    coolercontrol.enable = false;
  };

  ### Networking
  networking = {
    hostName = "oryx";
    networkmanager = {
      enable = true;
    };
  };
  services.tailscale.enable = true;

  ### Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  ### Locale
  time = {
    timeZone = "America/Toronto";
  };
  i18n = {
    defaultLocale = "en_CA.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_CA.UTF-8";
      LC_IDENTIFICATION = "en_CA.UTF-8";
      LC_MEASUREMENT = "en_CA.UTF-8";
      LC_MONETARY = "en_CA.UTF-8";
      LC_NAME = "en_CA.UTF-8";
      LC_NUMERIC = "en_CA.UTF-8";
      LC_PAPER = "en_CA.UTF-8";
      LC_TELEPHONE = "en_CA.UTF-8";
      LC_TIME = "en_CA.UTF-8";
    };
  };

  ### X11/Wayland
  services = {
    xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
      xkb = {
        layout = "us";
        ### variant = "";
      };
    };
    displayManager = {
      sddm.enable = true;
    };
    desktopManager = {
      plasma6.enable = true;
    };
  };

  ### Printing
  services = {
    printing.enable = true;
  };

  ### Audio
  security = {
    rtkit.enable = true;
  };
  services = {
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };

  ### Users
  users = {
    defaultUserShell = pkgs.fish;
    users.aljam = {
      isNormalUser = true;
      description = "Allen";
      extraGroups = [
        "gamemode"
        "dialout"
        "libvirtd"
        "plugdev"
        "input"
        "audio"
        "realtime"
        "render"
        "networkmanager"
        "wheel"
      ];
      packages = with pkgs; [
        kdePackages.kate
        vim
        wget
        curl
        git
        fish
        discord
        betterdiscordctl
        telegram-desktop
        mpv
        kitty
        obsidian
        librewolf
        gimp
        krita
        obs-studio
        blender
        qbittorrent
        inkscape
        blender
        audacity
        super-slicer
        davinci-resolve
        element-desktop
      ];
    };
  };

  ### Programs
  programs = {
    kdeconnect.enable = true;
    fish.enable = true;
    gamemode.enable = true;
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
      protontricks.enable = true;
    };
    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
        obs-gstreamer
        obs-vkcapture
        input-overlay
        obs-command-source
        obs-retro-effects
      ];
    };
  };

  ### Nix
  nixpkgs.config = {
    allowUnfree = true;
    nvidia.acceptLicense = true;
  };
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  ### System Packages
  environment.systemPackages = with pkgs; [
     vim
     wget
     curl
     git
     fish
     mpv
     kitty
     yt-dlp
     ffmpeg
  ];

  system.stateVersion = "26.05";
}
