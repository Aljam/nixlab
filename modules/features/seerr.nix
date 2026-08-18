{ config, pkgs, ... }:
{
  networking.proxyBackendPorts = [ 5055 ];

  services.seerr = {
    enable = true;
    openFirewall = false;
  };
  networking.firewall.extraInputRules = ''
    ip saddr ${config.networking.subnets.lan}.1 tcp dport 5055 accept
  '';
}
