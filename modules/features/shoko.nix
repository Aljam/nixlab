{ config, pkgs, ... }:
{
  networking.proxyBackendPorts = [ 8111 ];

  services.shoko = {
    enable = true;
    openFirewall = false;
  };
}
