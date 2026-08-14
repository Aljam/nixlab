{ config, pkgs, lib, inputs, ... }:

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
    ../../modules/features/fonts.nix
  ];

  nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ]
  
  hardware.enableRedistributableFirmware = true;
  boot.kernelPackages = inputs.nix-cachyos-kernel.legacyPackages.x86_64-linux.linuxPackages-cachyos-lts;

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
    extraUpFlags = [
      "--accept-routes=true"
    ];
  };

  programs.kdeconnect.enable = true;
}
