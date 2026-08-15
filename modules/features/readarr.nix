{ config, pkgs, domains, fleet, ... }:
{
  services.readarr = {
    enable = true;
    user = "media";
    group = "media";
    dataDir = "/var/lib/readarr";
    openFirewall = false;
  };
  networking.firewall.extraInputRules = ''
    ip saddr ${fleet.r730xd.ip} tcp dport 8787 accept
  '';
}
