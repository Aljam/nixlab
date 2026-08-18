{ config, lib, ... }:
{
  networking.proxyBackendPorts = [ 6767 ];

  services.bazarr = {
    enable = true;
    openFirewall = false;
  };
}
