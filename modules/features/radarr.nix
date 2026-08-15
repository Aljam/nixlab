{ config, pkgs, domains, fleet, ... }:
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
    ip saddr ${fleet.r730xd.ip} tcp dport 7878 accept
  '';
}
