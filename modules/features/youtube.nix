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
    "d /var/lib/ytdl-sub 0700 media media -"
  ];

  environment.etc."ytdl-sub/config.yaml".text = ''
    configuration:
      working_directory: "/var/lib/ytdl-sub"

    presets:
      default:
        ytdl_options:
          live_from_start: true
          cookiefile: "/var/lib/ytdl-sub/cookies.txt"
          sleep_requests: 5
          sleep_interval: 60
          max_sleep_interval: 180
          retries: 3
          fragment_retries: 3
          ignoreerrors: true
          limit_rate: "2M"

        output_options:
          output_directory: "/mnt/media/youtube"
          file_name: "{channel}/{upload_date}_{title}.{ext}"
  '';

  environment.etc."ytdl-sub/subscriptions.yaml".text = ''
    igotno_username:
      preset: default
      overrides:
        url: "https://www.youtube.com/@igotno_username"
  '';

  systemd.services.ytdl-sub = {
    description = "ytdl-sub YouTube automation";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];

    serviceConfig = {
      Type = "oneshot";
      User = "media";
      Group = "media";
      WorkingDirectory = "/var/lib/ytdl-sub";
      ExecStart =
        "${pkgs.ytdl-sub}/bin/ytdl-sub "
        + "--config /etc/ytdl-sub/config.yaml "
        + "sub /etc/ytdl-sub/subscriptions.yaml";
      ReadWritePaths = [
        "/var/lib/ytdl-sub"
        "/mnt/media/youtube"
      ];
      TimeoutStartSec = "infinity";
    };
  };

  systemd.timers.ytdl-sub = {
    wantedBy = [ "timers.target" ];

    timerConfig = {
      OnBootSec = "2min";
      OnUnitActiveSec = "15min";
      Persistent = true;
    };
  };
}
