{ config, pkgs, domains, fleet, ... }:
{
  services.audiobookshelf = {
    enable = true;
    user = "media";
    group = "media";
    dataDir = "/var/lib/audiobookshelf";
    openFirewall = false;
  };
  networking.firewall.extraInputRules = ''
    ip saddr ${fleet.r730xd.ip} tcp dport 13378 accept
  '';
}
