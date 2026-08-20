{ config, pkgs, inputs, ... }:

let
  unstable = import inputs.nixpkgs {
    system = pkgs.stdenv.hostPlatform.system;
    config = pkgs.config;
  };
in
{
  environment.systemPackages = [
    unstable.ytdl-sub
    unstable.yt-dlp
    unstable.deno
  ];

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
          format: "bv*+ba/b"
          live_from_start: true
          js_runtimes:
            deno: {}
          remote_components:
            - "ejs:github"
          extractor_args:
            youtube: "player_client=default,-android_vr,-android_sdkless"
          sleep_requests: 5
          sleep_interval: 60
          max_sleep_interval: 180
          retries: 3
          fragment_retries: 3
          ignoreerrors: true

        output_options:
          output_directory: "/mnt/media/youtube"
          file_name: "{channel}/{upload_date}_{title}.{ext}"
  '';

  environment.etc."ytdl-sub/subscriptions.yaml".text = ''
    igotno_username:
      preset:
        - default
      download:
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
      StateDirectory = "ytdl-sub";
      ExecStart =
        "${unstable.ytdl-sub}/bin/ytdl-sub "
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
      OnUnitActiveSec = "30min";
      Persistent = true;
    };
  };
}

