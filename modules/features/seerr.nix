# nixlab/modules/features/seerr.nix
# Overseerr - Media request management

{ config, lib, pkgs, ... }:

{
  options.modules.features.seerr = {
    enable = lib.mkEnableOption "Overseerr media request management";
  };

  config = lib.mkIf config.modules.features.seerr.enable {
    services.seerr = {
      enable = true;
    };

    # Firewall: seerr accessible only from HAProxy
    networking.firewall.allowedTCPPorts = [ 5055 ];
  };
}
