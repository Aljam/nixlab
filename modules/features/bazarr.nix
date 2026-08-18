# Bazarr - Subtitle management

{ config, lib, pkgs, ... }:

{
  options.modules.features.bazarr = {
    enable = lib.mkEnableOption "Bazarr subtitle management" // { default = true; };
  };

  config = lib.mkIf config.modules.features.bazarr.enable {
    networking.proxyBackendPorts = [ 6767 ];

    services.bazarr = {
      enable = true;
    };

    # Firewall: bazarr accessible only from HAProxy (192.168.1.1)
    networking.firewall.extraInputRules = ''
      ip saddr 192.168.1.1 tcp dport 6767 accept
    '';
  };
}
