{ config, lib, ... }: {
  options = {
    networking.proxyBackendPorts = lib.mkOption {
      type = lib.types.listOf lib.types.port;
      default = [];
      description = "Ports that HAProxy/proxy IP is allowed to access on backend services.";
    };
  };

  config = {
    networking.firewall.extraInputRules = lib.mkIf (config.networking.proxyBackendPorts != []) ''
      ip saddr ${config.fleet.proxy.ip} tcp dport { ${lib.concatStringsSep ", " (map toString config.networking.proxyBackendPorts)} } accept comment "HAProxy backend access"
    '';
  };
}
