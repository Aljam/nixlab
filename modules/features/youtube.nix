{ config, pkgs, inputs, ... }:

{
  environment.systemPackages =  with pkgs; [
    ytdl-sub
    yt-dlp
    deno
    python314Packages.bgutil-ytdlp-pot-provider
  ];

  systemd.tmpfiles.rules = [
    "d /mnt/media/youtube 0770 media media -"
    "d /var/lib/ytdl-sub 0700 media media -"
  ];

  systemd.services.bgutil-pot = {
    description = "bgutil YouTube Proof-of-Origin token provider";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      Type = "simple";
      DynamicUser = true;
      ExecStart =
        "${bgutil}/bin/bgutil-ytdlp-pot-provider "
        + "server --host 127.0.0.1 --port 4416";
      Restart = "always";
      RestartSec = 5;
    };
  };

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
            youtube:
              player_client:
                - "ios"
                - "tv"
            youtubepot-bgutilhttp:
              base_url:
                - "http://127.0.0.1:4416"
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
    wants = [ "network-online.target" "bgutil-pot.service" ];
    after = [ "network-online.target" "bgutil-pot.service" ];

    serviceConfig = {
      Type = "oneshot";
      User = "media";
      Group = "media";
      WorkingDirectory = "/var/lib/ytdl-sub";
      StateDirectory = "ytdl-sub";
      ExecStart = "${ytdl-sub}/bin/ytdl-sub --config /etc/ytdl-sub/config.yaml sub /etc/ytdl-sub/subscriptions.yaml";
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
