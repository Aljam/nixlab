# nixlab/modules/features/recyclarr.nix
# Recyclarr - Automated TRaSH-Guides config for Radarr/Sonarr

{ config, lib, pkgs, ... }:

{
  options.modules.features.recyclarr = {
    enable = lib.mkEnableOption "Recyclarr TRaSH-Guides automation";
  };

  config = lib.mkIf config.modules.features.recyclarr.enable {
    services.recyclarr = {
      enable = true;
    };

    systemd.timers.recyclarr = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
    };
  };
}
