{ config, pkgs, ... }:

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      vulkan-validation-layers
    ];
  };

  # Explicitly force SDDM as the display manager and disable any conflicting defaults
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = false; # Keeps the stable X11 greeter backend
  };

  # Add KDE Plasma so SDDM detects the desktop session files
  services.desktopManager.plasma6.enable = true;
}
