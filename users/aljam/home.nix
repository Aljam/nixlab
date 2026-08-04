{ config, pkgs, ... }:

{              
  home.enableNixpkgsReleaseCheck = false;
  home.username = "aljam";
  home.homeDirectory = "/home/aljam";
  home.stateVersion = "26.05";
  
  imports = [ ./modules/core/git.nix
              ./modules/core/shell.nix
              ./modules/core/nvim.nix
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
