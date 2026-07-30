{ config, pkgs, lib, inputs, ... }:

{
    imports = [
        ./hardware-configuration.nix
        ../../modules/common.nix
        ../../modules/desktop.nix    # Gets you KDE, Steam, Audio, etc.
        ../../modules/aljam.nix # Gets you your identity
        ../../modules/libvirt.nix    # Gets you VMs!
        ../../modules/nas-mount.nix  # Gets you your network share!
      ];
    
    networking.hostName = "navi";
    
    # --- Navi-Specific Bootloader Overrides (Ultrawide Monitor) ---
    boot.loader.grub.gfxmodeEfi = "3440x1440";
    boot.loader.grub.gfxmodeBios = "3440x1440";
    boot.loader.grub.gfxpayloadEfi = "keep";
    
    ### External USB Enclosure Quirks
    boot.extraModprobeConfig = "options usb-storage use_uas=0";
    boot.kernelParams = [ 
        "usb-storage.quirks=152d:0551:u"
        "usbcore.autosuspend=-1"
    ];
    
    boot.kernelPackages = pkgs.linuxPackages_latest;
}
