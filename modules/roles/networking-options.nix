# modules/roles/networking-options.nix
# Custom networking options for fleet management
{ lib, domains, ... }:
{
  options.networking = {
    fleet = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Fleet configuration for proxy and hosts";
    };

    subnets = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Subnet definitions for the fleet";
    };

    domain = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = domains.primary;
      description = "Primary domain for the host";
    };
  };
}
