{ config, pkgs, lib, ... }:

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
          # Required for starting a live recording at the beginning.
          live_from_start: true

          # Do not skip a livestream just because it is currently live.
          live_from_start: true

          # Polling the channel itself is handled by the systemd timer.
          sleep_requests: 1.5
          sleep_interval: 10
          max_sleep_interval: 20

          cookiefile: "/var/lib/ytdl-sub/cookies.txt"

          # Scan the channel's live/upcoming videos rather than only
          # relying on the normal uploads feed.
          extractor_args:
            youtube:
              player_client:
                - web
                - android

        output_options:
          output_directory: "/mnt/media/youtube"
          file_name: "{channel}/{upload_date}_{title}.{ext}"
          maintain_download_archive: true

  '';

  environment.etc."ytdl-sub/subscriptions.yaml".text = ''
    igotno_username:
      preset:
        - default
      download:
        # /streams discovers live and upcoming broadcasts.
        url: "https://www.youtube.com/@igotno_username/streams"
  '';

  systemd.services.ytdl-sub = {
    description = "ytdl-sub YouTube automation daemon";
    after = [
      "network-online.target"
    ];
    wants = [
      "network-online.target"
    ];

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

      ReadWritePaths = [
        "/mnt/media/youtube"
      ];

      # Do not start a second run while a long livestream is recording.
      TimeoutStartSec = "infinity";
    };
  };

  systemd.timers.ytdl-sub = {
    description = "Poll YouTube for livestreams";
    wantedBy = [
      "timers.target"
    ];

    timerConfig = {
      # Check every five minutes, with a small randomized offset.
      OnBootSec = "2min";
      OnUnitActiveSec = "5min";
      RandomizedDelaySec = "30s";
      Persistent = true;
    };
  };
}
