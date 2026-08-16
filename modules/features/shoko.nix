{ config, pkgs, ... }:
{
  services.shoko = {
    enable = true;
    openFirewall = false;
  };
  networking.firewall.extraInputRules = ''
    ip saddr ${config.networking.subnets.lan}.1 tcp dport 44555 accept
  '';
}
