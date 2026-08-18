{ lib, ... }:
let
  subnets = { lan = "192.168.1"; management = "127.0.0.0/8"; };
  domains = {
    primary = "derezzed.info";
    derezzed = "derezzed.info";
    fuwa = "fuwa.space";
    cybal = "cybal.org";
    netrunner = "netrunner.dev";
    glow_net = "glowrunner.network";
    glow_dev = "glowrunner.dev";
    glow_xyz = "glowrunner.xyz";
  };
  fleet = {
    navi = { }; oryx = { };
    r820 = { ip = "${subnets.lan}.4"; };
    r730 = { ip = "${subnets.lan}.3"; zpool = "r730pool"; };
    r730xd = { ip = "${subnets.lan}.2"; zpool = "mediapool"; };
    proxy = { ip = "${subnets.lan}.1"; };
    nas = { ip = "192.168.2.10"; };
  };
in
{
  options.networking = {
    fleet = lib.mkOption { type = lib.types.attrs; };
    subnets = lib.mkOption { type = lib.types.attrs; };
    # Rename to avoid conflict with NixOS's networking.domain
    myDomain = lib.mkOption { type = lib.types.str; };
    domains = lib.mkOption { type = lib.types.attrsOf lib.types.str; };
    proxyBackendPorts = lib.mkOption {
      type = lib.types.listOf lib.types.port;
      default = [
        3000 5050 5055 6767 7474 8082 8111 9090 9093
        9100 13378 8222 8989 8686 8787 7878 9696 8080
        8081 8096
      ];
      description = "TCP ports reachable from the pfSense HAProxy backend.";
    };
  };
  config.networking = {
    fleet = fleet;
    subnets = subnets;
    myDomain = domains.primary;
    domains = domains;
  };
}
