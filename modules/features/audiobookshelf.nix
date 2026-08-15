{ config, pkgs, domains, fleet, subnets, lib, ... }:
{
  services.audiobookshelf = {
    enable = true;
    user = "media";
    group = "media";
    dataDir = "/var/lib/audiobookshelf";
    openFirewall = false;
  };

  # Override broken WorkingDirectory in audiobookshelf systemd service
  systemd.services.audiobookshelf.serviceConfig.WorkingDirectory = lib.mkForce "/var/lib/audiobookshelf";

  networking.firewall.extraInputRules = ''
    ip saddr ${subnets.lan}.1 tcp dport 13378 accept
  '';
}
