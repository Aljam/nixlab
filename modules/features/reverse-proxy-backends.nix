{ lib, subnets, ... }:

let
  # HAProxy runs on the gateway
  proxy = "${subnets.lan}.1";

  backendPorts = [
    8096   # jellyfin
    8989   # sonarr
    7878   # radarr
    9696   # prowlarr
    6767   # bazarr
    8686   # lidarr
    8787   # readarr
    8111   # shoko
    5055   # jellyseerr
    13378  # audiobookshelf
    7474   # autobrr
    8080   # qbittorrent webui
    8222   # vaultwarden
    3000   # grafana
    8082   # homepage-dashboard
  ];
in
{
  networking.firewall.extraInputRules = ''
    ip saddr ${proxy} tcp dport { ${lib.concatMapStringsSep ", " toString backendPorts} } accept
  '';
}
