# nixlab/modules/features/autobrr.nix
# autobrr - IRC torrent client automation

{ config, lib, pkgs, ... }:

{
  options.modules.features.autobrr = {
    enable = lib.mkEnableOption "autobrr IRC torrent client automation";
  };

  config = lib.mkIf config.modules.features.autobrr.enable {
    services.autobrr = {
      enable = true;
    };

    # Firewall: autobrr accessible only from HAProxy
    networking.firewall.allowedTCPPorts = [ 7777 ];
  };
}
