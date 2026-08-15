{ config, pkgs, domains, fleet, ... }:
{
  services.lidarr = {
    enable = true;
    user = "media";
    group = "media";
    dataDir = "/var/lib/lidarr";
    openFirewall = false;
  };
  networking.firewall.extraInputRules = ''
    ip saddr ${fleet.r730xd.ip} tcp dport 8686 accept
  '';
}
