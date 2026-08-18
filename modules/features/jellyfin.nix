{ config, lib, ... }:

{
  services.jellyfin = {
    enable = true;
  };

  networking.proxyBackendPorts = [ 8096 ];
}
