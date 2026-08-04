{ config, pkgs, ... }:

{
  services.displayManager.sddm.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      vulkan-validation-layers
    ];
  };

  # Add KDE Plasma so SDDM detects the desktop session files
  services.desktopManager.plasma6.enable = true;
}
