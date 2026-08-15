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
      default = [ 80 443 3000 5055 7474 7878 8000 8080 8082 8096 8111 8686 8787 8989 9090 9093 9094 9100 9696 13378 ];
      description = "Public backend ports";
    };
    sensitivePorts = lib.mkOption {
      type = lib.types.listOf lib.types.port;
      default = [ 22 3306 5432 ];
      description = "Sensitive ports to exclude from public access";
    };
  };

  config = lib.mkIf config.modules.features.reverse-proxy-backends.enable {
    networking.nftables = {
      extraRules = [{
        table = "inet filter";
        chain = "input";
        rule = "ip saddr ${config.modules.features.reverse-proxy-backends.lanSubnet} tcp dport { ${lib.concatMapStringsSep ", " toString (lib.filter (p: !(lib.elem p config.modules.features.reverse-proxy-backends.sensitivePorts)) config.modules.features.reverse-proxy-backends.publicBackendPorts)} } accept comment \"Allow LAN to backend ports\"";
      }];
    };
  };
}
