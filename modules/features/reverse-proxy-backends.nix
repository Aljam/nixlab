{ config, lib, ... }:

let
  proxyIP = config.networking.fleet.proxy.ip or "192.168.1.1";
  backendPorts = lib.concatStringsSep ", " (map toString config.networking.proxyBackendPorts);
in
{
  networking.firewall = {
    extraInputRules = ''
      ip saddr ${proxyIP} tcp dport { ${backendPorts} }
        accept comment "HAProxy backend access"
    '';
  };
}
