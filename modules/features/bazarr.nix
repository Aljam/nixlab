{ config, pkgs, domains, fleet, subnets, ... }:
{
  services.bazarr = {
    enable = true;
    user = "media";
    group = "media";
    dataDir = "/var/lib/bazarr";
    openFirewall = false;
  };
  networking.firewall.extraInputRules = ''
    ip saddr ${subnets.lan}.1 tcp dport 6767 accept
  '';
}
