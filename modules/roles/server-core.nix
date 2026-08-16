# modules/roles/server-core.nix
# Core server configuration
{ config, lib, pkgs, ... }:

{
  # Disable NetworkManager on servers
  networking.networkmanager.enable = false;

  # Disable IPv6 on servers
  boot.kernelParams = [ "ipv6.disable=1" ];

  # Enable nftables
  networking.nftables.enable = true;
}
