{ config, pkgs, domains, fleet, subnets, ... }:
{
  services.readarr = {
    enable = true;
    user = "media";
    group = "media";
    dataDir = "/var/lib/readarr";
    openFirewall = false;
  };
  networking.firewall.extraInputRules = ''
    ip saddr ${subnets.lan}.1 tcp dport 8787 accept
  '';
}
