{ config, pkgs, domains, fleet, subnets, ... }:
{
  services.audiobookshelf = {
    enable = true;
    user = "media";
    group = "media";
    dataDir = "/var/lib/audiobookshelf";
    openFirewall = false;
    serviceOverrides = {
      Service.WorkingDirectory = "/var/lib/audiobookshelf";
    };
  };
  networking.firewall.extraInputRules = ''
    ip saddr ${subnets.lan}.1 tcp dport 13378 accept
  '';
}
