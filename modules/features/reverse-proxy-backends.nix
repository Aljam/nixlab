{ config, lib, ... }:

{
  networking.firewall.extraInputRules = lib.mkIf (config.networking.proxyBackendPorts != []) ''
    ip saddr ${config.fleet.proxy.ip} tcp dport { ${lib.concatStringsSep ", " (map toString config.networking.proxyBackendPorts)} } accept comment "HAProxy backend access"
  '';
}
