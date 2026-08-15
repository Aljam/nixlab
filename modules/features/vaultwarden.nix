{ config, pkgs, domains, fleet, subnets, ... }:
{
  services.vaultwarden = {
    enable = true;
    config = {
      ROCKET_ADDRESS = "0.0.0.0";
      ROCKET_PORT = 8000;
    };
    openFirewall = false;
  };
  networking.firewall.extraInputRules = ''
    ip saddr ${subnets.lan}.1 tcp dport 8000 accept
  '';
}
