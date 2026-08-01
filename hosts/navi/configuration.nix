{ config, pkgs, lib, inputs, ... }:

{
    imports = [
    	./hardware-configuration.nix
    	../../modules/roles/desktop-node.nix
    	../../modules/features/graphics.nix
    	../../modules/features/libvirt.nix
        ../../modules/hardware/navi-desktop.nix
      ];
    
    networking.hostName = "navi";
}
