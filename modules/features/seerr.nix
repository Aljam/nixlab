{ config, pkgs, domains, fleet, ... }:
{
  services.seerr = {
    enable = true;
    user = "media";
    group = "media";
    dataDir = "/var/lib/seerr";
    openFirewall = false;
  };
  networking.firewall.extraInputRules = ''
    ip saddr ${fleet.r730xd.ip} tcp dport 5055 accept
  '';
}
