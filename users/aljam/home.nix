{ config, pkgs, ... }:

{
  imports = [ ./modules/core/git.nix
              ./modules/core/shell.nix ];
              
  home.enableNixpkgsReleaseCheck = false;
  home.username = "aljam";
  home.homeDirectory = "/home/aljam";
  home.stateVersion = "23.11";
  

  # Universal CLI & Dev Tools (Safe for Servers & Desktops)
  home.packages = with pkgs; [
    bat
    eza
    fzf
    ripgrep
    jq
    tldr
    fd
    lazygit
    btop
    ncdu
    fastfetch
    gh
    sops
  ];

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.home-manager.enable = true;
}
