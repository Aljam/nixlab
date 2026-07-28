{ config, pkgs, lib, inputs, ... }:
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
      gfxmodeEfi = "3440x1440";
      gfxmodeBios = "3440x1440";
      gfxpayloadEfi = "keep";
      configurationLimit = 10;
      timeoutStyle = "menu";
    };
  };
  ### boot params to get hdd enclosure working
  boot.extraModprobeConfig = "options usb-storage use_uas=0";
  boot.kernelParams = [ 
    "usb-storage.quirks=152d:0551:u"
    "usbcore.autosuspend=-1"
  ];

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
  # systemd.services.i2pd.wantedBy = lib.mkForce [ ];

  ### Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  ###virtualisation
  programs.virt-manager.enable = true;
  environment.etc."libvirt/qemu/networks/default.xml" = {
    text = ''
      <network>
        <name>default</name>
        <bridge name="virbr0"/>
        <forward mode='nat'/>
        <ip address='172.16.56.1' netmask='255.255.255.0'>
          <dhcp>
            <range start='172.16.56.2' end='172.16.56.254'/>
            <host mac='52:54:00:12:34:56' name='virtualmachine' ip='172.16.56.10'/>
          </dhcp>
        </ip>
      </network>
    '';
  };
  system.activationScripts.libvirt-network-start = {
    deps = [ "users" ];
    text = ''
      export VIRSH_DEFAULT_CONNECT_URI="qemu:///system"
      /run/current-system/sw/bin/sleep 2
      if ! /run/current-system/sw/bin/virsh net-list --all | grep -q "default"; then
        /run/current-system/sw/bin/virsh net-define /etc/libvirt/qemu/networks/default.xml
      fi
      /run/current-system/sw/bin/virsh net-start default || true
      /run/current-system/sw/bin/virsh net-autostart default || true
    '';
  };
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
      };
    };
    spiceUSBRedirection.enable = true;
  };

  ### Networking
  networking = {
    hostName = "navi";
    networkmanager = {
      enable = true;
    };
  };

  services.tailscale.enable = true;


  #nas settings
  fileSystems."/run/media/aljam/share" = {
    device = "//192.168.2.12/share";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

    in ["${automount_opts},credentials=/etc/nixos/smb-secrets,uid=1000,gid=100"];
  };


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
        "plugdev"
        "input"
        "audio"
        "realtime"
        "render"
        "networkmanager"
        "wheel"
	"libvirtd"
      ];
      packages = with pkgs; [
        ungoogled-chromium
	kdePackages.kate
	deadbeef-with-plugins
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
        libreoffice-qt
        hunspell
        hunspellDicts.en_US
        hyphenDicts.en_US

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
  nixpkgs.config.allowUnfree = true;
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
     neovim
     cifs-utils
     wget
     curl
     git
     fish
     mpv
     kitty
     yt-dlp
     ffmpeg
     _7zip-zstd
  ];

  environment.shellAliases = { vim = "nvim"; };

  ### System Version
  system.stateVersion = "26.05";
}
