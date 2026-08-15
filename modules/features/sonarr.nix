{ config, pkgs, domains, fleet, ... }:
{
  services.sonarr = {
    enable = true;
    user = "media";
    group = "media";
    dataDir = "/var/lib/sonarr";
    openFirewall = false;
  };
  networking.firewall.extraInputRules = ''
    ip saddr ${fleet.r730xd.ip} tcp dport 8989 accept
  '';
}
