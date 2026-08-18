{ pkgs, lib, ... }:

{
  networking.proxyBackendPorts = [ 3000 ];

  imports = [
    ../modules/features/reverse-proxy-backends.nix
  ];

  services.grafana.enable = true;

  networking.firewall.enable = true;
}
