{ config, pkgs, pkgs-stable, ... }:

{
  imports = [ ./modules/desktop/apps.nix
              ./modules/desktop/kitty.nix
              ./modules/desktop/obs.nix
            ];

 xdg.enable = true;
}
