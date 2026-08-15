{ config, pkgs, domains, fleet, subnets, lib, ... }:

let
  cfg = config.modules.features.vaultwarden;
in
{
  options.modules.features.vaultwarden = {
    enable = lib.mkEnableOption "Vaultwarden password manager" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    services.vaultwarden = {
      enable = true;
      config = {
        ROCKET_ADDRESS = "0.0.0.0";
        ROCKET_PORT = 8000;
      };
    };
    networking.firewall.extraInputRules = ''
      ip saddr ${subnets.lan}.1 tcp dport 8000 accept
    '';
  };
}
