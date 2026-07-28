{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  networking.hostName = "navi";

  ### Bootloader (GRUB)
  boot.loader = {
    timeout = 10;
    systemd-boot.enable = false;
    efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = false;
      device = "nodev";
      gfxmodeEfi = "3440x1440";
      gfxmodeBios = "3440x1440";
      gfxpayloadEfi = "keep";
      configurationLimit = 10;
      timeoutStyle = "menu";
    };
  };

  ### External USB Enclosure Quirks
  boot.extraModprobeConfig = "options usb-storage use_uas=0";
  boot.kernelParams = [ 
    "usb-storage.quirks=152d:0551:u"
    "usbcore.autosuspend=-1"
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  ### GUI (KDE Plasma)
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  ### Virtualisation & Networking Scripts
  programs.virt-manager.enable = true;
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu.swtpm.enable = true;
    };
    spiceUSBRedirection.enable = true;
  };

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

  ### NAS CIFS Mount
  fileSystems."/run/media/aljam/share" = {
    device = "//192.168.2.12/share";
    fsType = "cifs";
    options = let
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
    in ["${automount_opts},credentials=/etc/nixos/smb-secrets,uid=1000,gid=100"];
  };

  users.users.aljam = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "libvirtd" ];
  };

  system.stateVersion = "23.11";
}
