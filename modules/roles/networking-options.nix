# modules/roles/networking-options.nix
# Custom networking options for fleet management
{ lib, ... }:
{
  options.networking = {
    fleet = {
      navi = { };
      oryx = { };
      r820 = { ip = "${subnets.lan}.4"; };
      r730 = { ip = "${subnets.lan}.3"; zpool = "r730pool"; };
      r730xd = { ip = "${subnets.lan}.2"; zpool = "mediapool"; };
      proxy = { ip = "${subnets.lan}.1"; };
    };

    subnets = lib.mkOption {
      type = lib.types.attrs;
      default = {
        lan = "192.168.1";
        management = "127.0.0.0/8";
      };
      description = "Subnet definitions for the fleet";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = "derezzed.info";
      description = "Primary domain for the host";
    };

    domains = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {
        derezzed = "derezzed.info";
        fuwa = "fuwa.space";
        cybal = "cybal.org";
        netrunner = "netrunner.dev";
        glow_net = "glowrunner.network";
        glow_dev = "glowrunner.dev";
        glow_xyz = "glowrunner.xyz";
      };
      description = "All available domains for the fleet";
    };
  };
}
