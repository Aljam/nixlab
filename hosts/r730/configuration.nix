{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    ../../modules/hardware/dell-poweredge.nix
    ../../modules/roles/server-core.nix
    ../../modules/roles/storage-node.nix
    # ../../modules/roles/ai-node.nix
    # ../../modules/features/nvidia-headless.nix
  ];

  networking.hostId = "acccc16e"; # Required for ZFS

  boot.kernelPackages = pkgs.linuxPackages_6_1;  

  # hardware.nvidia-container-toolkit.enable = true; # Passes the P40s into Docker

  # hardware.nvidia = {
  #   modesetting.enable = true; # Overrides the headless module default
  #   nvidiaPersistenced = true; # Prevents power-state latency drops during AI training
  # };

  #nixpkgs.config.cudaSupport = true;

  environment.systemPackages = with pkgs; [
    cudatoolkit
    linuxPackages.nvidia_x11
  ];

}
