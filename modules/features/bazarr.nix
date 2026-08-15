{ config, pkgs, domains, fleet, ... }:
{
  services.bazarr = {
    enable = true;
    user = "media";
    group = "media";
    dataDir = "/var/lib/bazarr";
    openFirewall = false;
  };
  networking.firewall.extraInputRules = ''
    ip saddr ${fleet.r730xd.ip} tcp dport 6767 accept
  '';
}
