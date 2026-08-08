{ config, pkgs, lib, ... }:

{
  environment.systemPackages = [ pkgs.ytdl-sub ];
  users.users.media = { isSystemUser = true; group = "media"; };

  environment.etc."ytdl-sub/config.yaml".text = ''
    configuration:
      working_directory: "/var/lib/ytdl-sub"
    presets:
      default:
        output_options:
          output_directory: "/mnt/media/youtube"
  '';

  environment.etc."ytdl-sub/subscriptions.yaml".text = ''
    Channels:
      igotno_username:
        preset:
          - default
        url: "https://www.youtube.com/@igotno_username"
  '';

  systemd.services.ytdl-sub = {
    description = "ytdl-sub YouTube automation daemon";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      User = "media"; 
      Group = "media";
      StateDirectory = "ytdl-sub";
      ExecStart = "${pkgs.ytdl-sub}/bin/ytdl-sub --config /etc/ytdl-sub/config.yaml sub /etc/ytdl-sub/subscriptions.yaml";
      ProtectSystem = "strict";
      ReadWritePaths = [ "/mnt/pool/media/youtube" ];
    };
  };

  systemd.timers.ytdl-sub = {
    description = "Timer for ytdl-sub YouTube automation";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*:0/5";
      Persistent = true;
    };
  };
}
