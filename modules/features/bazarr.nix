{ config, lib, pkgs, ... }:

{
  networking.proxyBackendPorts = [ 6767 ];

  config = lib.mkIf config.modules.features.bazarr.enable {
    services.bazarr = {
      enable = true;
      openFirewall = false;
    };
  };
}
