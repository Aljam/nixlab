{ config, pkgs, ... }:

{
  # Allow unfree packages fleet-wide
  nixpkgs.config.allowUnfree = true;

  # Set your global timezone and locale
  time.timeZone = "America/Toronto"; # Adjust to your timezone
  i18n.defaultLocale = "en_US.UTF-8";

  # Essential system packages needed on all machines
  environment.systemPackages = with pkgs; [
    git
    htop
    kitty.terminfo # Fixes SSH terminal issues when connecting from Kitty
  ];

  # Enable Flakes globally on all systems
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
