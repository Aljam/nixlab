{ config, pkgs, ... }:

{
  # Enable Flatpak service system-wide
  services.flatpak.enable = true;

  # Optionally add Flathub remote automatically on activation
  system.activationScripts.flathub-repo = ''
    ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  '';
}
