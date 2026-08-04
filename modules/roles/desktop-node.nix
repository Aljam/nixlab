{ config, pkgs, ... }:

{
  imports = [
    ../../modules/features/audio.nix
    ../../modules/features/bluetooth.nix
    ../../modules/features/graphics.nix
    ../../modules/features/hyprland.nix
    ../../modules/features/emulation.nix
    ../../modules/features/nas-mount.nix
    ../../modules/features/networking-tools.nix
    ../../modules/features/gaming.nix
    ../../modules/features/libvirt.nix
    ../../modules/features/flatpak.nix
    ../../modules/features/remote-builder.nix
    ../../modules/features/restic-client.nix
  ];
  
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client"; # or "both" if advertising routes, but keep local safe
    extraUpFlags = [
      "--accept-routes=false" # Prevents Tailscale from overriding your local gateway
    ];
  };
}
