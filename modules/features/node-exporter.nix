# modules/features/node-exporter.nix
# DRY: Use shared proxy IP from flake.nix
{ config, lib, pkgs, ... }:

{
  services.prometheus.exporters.node = {
    enable = true;
    port = 9100;
  };

  # Firewall: Handled centrally by reverse-proxy-backends.nix
}
