# modules/features/readarr.nix
{ config, lib, pkgs, ... }:

let
  bindAddr = config.servicesHostIP or "127.0.0.1";
in
{
  services.readarr = {
    enable = true;
    # Bind to host IP for HAProxy
    settings = {
      Server = {
        BindAddress = bindAddr;
        Port = 8787;
      };
    };
  };
}
