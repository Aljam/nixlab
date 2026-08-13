{ config, pkgs, pkgs-stable, ... }:

{
  programs.kitty = {
    enable = true;
    themeFile = "Tokyo Night Moon"; # Or "Catppuccin-Mocha", "Rosé Pine", "Gruvbox Dark", "Nord"
    settings = {
      scrollback_lines = 10000;
      enable_audio_bell = false;
      update_check_interval = 0;
    };
  };
}
