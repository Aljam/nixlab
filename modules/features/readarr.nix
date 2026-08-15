# nixlab/modules/features/readarr.nix
# Readarr - Book management

{ config, lib, pkgs, ... }:

{
  services.readarr = {
    enable = true;
    settings.server.bindAddress = "0.0.0.0"
  };

    # Firewall: readarr accessible only from HAProxy (192.168.1.1)
    networking.firewall.extraInputRules = ''
      ip saddr 192.168.1.1 tcp dport 8787 accept
    '';
  };
}
