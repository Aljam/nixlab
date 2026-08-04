Nix

{ config, pkgs, ... }:

{
  imports = [
    ../../modules/features/audio.nix
    ../../modules/features/graphics.nix
    ../../modules/features/hyprland.nix
  ];

  # Explicitly enable X11 and SDDM for the desktop/laptop role
  services.xserver.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = false; # Enforces stable X11 greeter backend to avoid hybrid-graphics crashes
  };
}
