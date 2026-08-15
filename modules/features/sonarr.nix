{ config, pkgs, domains, fleet, subnets ... }:
{
  services.sonarr = {
    enable = true;
    user = "media";
    group = "media";
    dataDir = "/var/lib/sonarr";
    openFirewall = false;
  };
  networking.firewall.extraInputRules = ''
    ip saddr ${subnets.lan}.1 tcp dport 8989 accept
  '';
}
