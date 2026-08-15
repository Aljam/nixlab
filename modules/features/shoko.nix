{ config, pkgs, domains, fleet, ... }:
{
  services.shoko = {
    enable = true;
    user = "media";
    group = "media";
    dataDir = "/var/lib/shoko";
    openFirewall = false;
  };
  networking.firewall.extraInputRules = ''
    ip saddr ${fleet.r730xd.ip} tcp dport 8111 accept
  '';
}
