{ config, pkgs, ... }:

{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting ""
    '';
    shellAliases = {
      ls = "eza --icons";
      cat = "bat";
      ssh = "kitty +kitten ssh";
    };
  };
}
