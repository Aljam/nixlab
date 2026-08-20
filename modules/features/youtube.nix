{ config, pkgs, inputs, ... }:

let
  unstable = import inputs.nixpkgs {
    system = pkgs.stdenv.hostPlatform.system;
    config = pkgs.config;
  };

  bgutil-pot = pkgs.stdenv.mkDerivation {
    pname = "bgutil-pot";
    version = "1.3.1";

    src = pkgs.fetchFromGitHub {
      owner = "brainicism";
      repo = "bgutil-ytdlp-pot-provider";
      rev = "v1.3.1";
      hash = pkgs.lib.fakeHash;
    };

    nativeBuildInputs = [ pkgs.nodejs pkgs.pnpm ];

    buildPhase = ''
      pnpm install --frozen-lockfile
      pnpm build
    '';

    installPhase = ''
      mkdir -p $out/share/bgutil-pot
      cp -r . $out/share/bgutil-pot
    '';
  };

  ytdl-sub = unstable.ytdl-sub;
  yt-dlp = unstable.yt-dlp;
  deno = unstable.deno;
in
{
  environment.systemPackages = [
    ytdl-sub
    yt-dlp
    deno
  ];

  systemd.services.bgutil-pot = {
    description = "bgutil YouTube Proof-of-Origin token provider";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      Type = "simple";
      DynamicUser = true;
      ExecStart = "${bgutil-pot}/bin/bgutil-pot --host 127.0.0.1 --port 4416";
      Restart = "always";
      RestartSec = 5;
    };
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
    wants = [ "network-online.target" bgutil-pot.service ];
    after = [ "network-online.target" bgutil-pot.service ];

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
