# nixlab/modules/features/reverse-proxy-backends.nix
# Reverse proxy backends configuration with firewall isolation

{ config, lib, pkgs, ... }:

{
  options.modules.features.reverse-proxy-backends = {
    enable = lib.mkEnableOption "reverse proxy backends firewall rules";
    lanSubnet = lib.mkOption {
      type = lib.types.str;
      default = "192.168.1.0/24";
      description = "LAN subnet for firewall rules";
    };
    publicBackendPorts = lib.mkOption {
      type = lib.types.listOf lib.types.port;
      default = [ 80 443 ];
      description = "Public backend ports";
    };
    sensitivePorts = lib.mkOption {
      type = lib.types.listOf lib.types.port;
      default = [ 22 3306 5432 ];
      description = "Sensitive ports to exclude from public access";
    };
  };

  config = lib.mkIf config.modules.features.reverse-proxy-backends.enable {
    networking.firewall = {
      extraCommands = lib.mkBefore ''
        # Allow LAN subnet to access public backend ports (excluding sensitive ports)
        ip saddr ${config.modules.features.reverse-proxy-backends.lanSubnet} tcp dport {
          ${lib.concatMapStringsSep ", " toString (lib.filter (p: !(lib.elem p config.modules.features.reverse-proxy-backends.sensitivePorts)) config.modules.features.reverse-proxy-backends.publicBackendPorts)}
        } accept
      '';
    };
  };
}
