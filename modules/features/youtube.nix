{ config, pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.ytdl-sub
  ];

  users.groups.media = {};

  users.users.media = {
    isSystemUser = true;
    group = "media";
  };

  systemd.tmpfiles.rules = [
    "d /mnt/media/youtube 0770 media media -"
  ];

  environment.etc."ytdl-sub/config.yaml".text = ''
    configuration:
      working_directory: "/var/lib/ytdl-sub"

    presets:
      default:
        ytdl_options:
          live_from_start: true
          sleep_requests: 1.5
          sleep_interval: 10
          max_sleep_interval: 20
          cookiefile: "/var/lib/ytdl-sub/cookies.txt"

        output_options:
          output_directory: "/mnt/media/youtube"
          file_name: "{channel}/{upload_date}_{title}.{ext}"
  '';

  environment.etc."ytdl-sub/subscriptions.yaml".text = ''
    igotno_username:
      preset:
        - default
      download:
        url: "https://www.youtube.com/@igotno_username/streams"
  '';

  systemd.services.ytdl-sub = {
    description = "ytdl-sub YouTube automation";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      Type = "oneshot";
      User = "media";
      Group = "media";
      StateDirectory = "ytdl-sub";
      WorkingDirectory = "/var/lib/ytdl-sub";
      ExecStart =
        "${pkgs.ytdl-sub}/bin/ytdl-sub "
        + "--config /etc/ytdl-sub/config.yaml "
        + "sub /etc/ytdl-sub/subscriptions.yaml";
      ReadWritePaths = [ "/mnt/media/youtube" ];
      TimeoutStartSec = "infinity";
    };
  };

  systemd.timers.ytdl-sub = {
    wantedBy = [ "timers.target" ];

    timerConfig = {
      OnBootSec = "2min";
      OnUnitActiveSec = "5min";
      Persistent = true;
    };
  };
}
