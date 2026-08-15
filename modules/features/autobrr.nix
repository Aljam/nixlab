{ config, pkgs, domains, fleet, ... }:
{
  services.autobrr = {
    enable = true;
    user = "media";
    group = "media";
    dataDir = "/var/lib/autobrr";
    openFirewall = false;
  };
  networking.firewall.extraInputRules = ''
    ip saddr ${fleet.r730xd.ip} tcp dport 7474 accept
  '';
}
