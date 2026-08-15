{ config, pkgs, domains, fleet, subnets, ... }:
{
  services.shoko = {
    enable = true;
    openFirewall = false;
  };
  networking.firewall.extraInputRules = ''
    ip saddr ${subnets.lan}.1 tcp dport 44555 accept
  '';
}
