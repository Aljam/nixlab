{ config, pkgs, domains, fleet, subnets ... }:
{
  services.lidarr = {
    enable = true;
    user = "media";
    group = "media";
    dataDir = "/var/lib/lidarr";
    openFirewall = false;
  };
  networking.firewall.extraInputRules = ''
    ip saddr ${subnets.lan}.1 tcp dport 8686 accept
  '';
}
