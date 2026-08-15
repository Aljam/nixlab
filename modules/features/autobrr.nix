{ config, pkgs, domains, fleet, subnets, ... }:
{
  services.autobrr = {
    enable = true;
    openFirewall = false;
  };
  networking.firewall.extraInputRules = ''
    ip saddr ${subnets.lan}.1 tcp dport 7777 accept
  '';
}
