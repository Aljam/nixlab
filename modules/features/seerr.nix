{ config, ... }:
{
  networking.proxyBackendPorts = [ 5055 ];

  services.seerr = {
    enable = true;
    openFirewall = false;
  };
}
