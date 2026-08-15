{ config, pkgs, domains, fleet, subnets, ... }:
{
  services.radarr = {
    enable = true;
    user = "media";
    group = "media";
    dataDir = "/var/lib/radarr";
    openFirewall = false;  # Handled by reverse-proxy-backends
  };

  # Firewall: Only HAProxy (pfSense) can access
  networking.firewall.extraInputRules = ''
    ip saddr ${subnets.lan}.1 tcp dport 7878 accept
  '';
}
