{ config, pkgs, lib, inputs, ... }:

{
    imports = [
    	./hardware-configuration.nix
    	../../modules/roles/desktop-node.nix
    	../../modules/features/graphics.nix
    	../../modules/features/libvirt.nix
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
