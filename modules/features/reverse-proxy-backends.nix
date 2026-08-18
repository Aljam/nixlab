{ config, ... }:

let
  proxyIP = config.networking.fleet.proxy.ip or "192.168.1.1";
in
{
  networking.firewall = {
    extraInputRules = ''
      ip saddr ${proxyIP} tcp dport {
        3000, 5050, 5055, 6767, 7474, 8082, 8111, 9090, 9093,
        9100, 13378, 8222, 8989, 8686, 8787, 7878, 9696, 8080,
        8081, 8096
      } accept comment "HAProxy backend access"
    '';
  };
}
