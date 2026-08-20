{ config, pkgs, inputs, ... }:

{
  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    ytdl-sub
    yt-dlp
    deno
    python314Packages.bgutil-ytdlp-pot-provider
  ];

  virtualisation.oci-containers.backend = "docker";

  virtualisation.oci-containers.containers.bgutil-pot = {
    image = "brainicism/bgutil-ytdlp-pot-provider:1.3.1";
    ports = [
      "127.0.0.1:4416:4416"
    ];
    autoStart = true;
    extraOptions = [
      "--init"
    ];
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
    wants = [
      "network-online.target"
      "docker-bgutil-pot.service"
    ];
    after = [
      "network-online.target"
      "docker-bgutil-pot.service"
    ];

    serviceConfig = {
      Type = "oneshot";
      User = "media";
      Group = "media";
      WorkingDirectory = "/var/lib/ytdl-sub";
      StateDirectory = "ytdl-sub";
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
      OnUnitActiveSec = "30min";
      Persistent = true;
    };
  };
}
