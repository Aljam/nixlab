{ config, lib, ... }: {
  imports = [
    ../roles/service.nix
  ];

  config = {
    services.jellyfin = {
      enable = true;
    };

    networking.proxyBackendPorts = [ 8096 ];
  };
}
