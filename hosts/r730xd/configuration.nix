{ config, pkgs, ... }:

{
  imports = [
    ../../modules/hardware/dell-r730xd.nix
    ../../modules/roles/server-core.nix
    ../../modules/roles/storage-node.nix
    ../../modules/roles/media-node.nix
    ../../modules/features/nvidia-headless.nix
    ../../modules/features/prometheus-server.nix
  ];
}
