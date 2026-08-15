# nixlab/modules/features/lidarr.nix
# Lidarr - Music management

{ config, lib, pkgs, ... }:

{
  options.modules.features.lidarr = {
    enable = lib.mkEnableOption "Lidarr music management";
  };

  config = lib.mkIf config.modules.features.lidarr.enable {
    services.lidarr = {
      enable = true;
    };

    # Firewall: lidarr accessible only from HAProxy (192.168.1.1)
    networking.firewall.extraInputRules = ''
      ip saddr 192.168.1.1 tcp dport 8686 accept
    '';
  };
}
