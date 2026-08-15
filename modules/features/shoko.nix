# nixlab/modules/features/shoko.nix
# Shoko Server - Anime metadata and library management

{ config, lib, pkgs, ... }:

{
  options.modules.features.shoko = {
    enable = lib.mkEnableOption "Shoko Server anime library management";
  };

  config = lib.mkIf config.modules.features.shoko.enable {
    services.shoko = {
      enable = true;
    };

    # Firewall: shoko accessible only from HAProxy
    networking.firewall.allowedTCPPorts = [ 8111 ];
  };
}
