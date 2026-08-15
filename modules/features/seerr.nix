{ config, pkgs, domains, fleet, subnets, ... }:
{
  services.seerr = {
    enable = true;
    openFirewall = false;
  };
  networking.firewall.extraInputRules = ''
    ip saddr ${subnets.lan}.1 tcp dport 5055 accept
  '';
}
