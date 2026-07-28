{ config, pkgs, ... }:

{
  home.username = "aljam";
  home.homeDirectory = "/home/aljam";
  home.stateVersion = "23.11"; # Match this to your initial install version

  # Your Common Dev Tools
  home.packages = with pkgs; [
    bat        # Better cat
    eza        # Better ls
    fzf        # Command-line fuzzy finder
    ripgrep    # Better grep
    jq         # JSON processor
    tldr       # Simplified man pages
  ];

  # Kitty Terminal Configuration
  programs.kitty = {
    enable = true;
    settings = {
      scrollback_lines = 10000;
      enable_audio_bell = false;
      update_check_interval = 0;
    };
  };

  # Fish Shell Configuration
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting ""
    '';
    shellAliases = {
      ls = "eza --icons";
      cat = "bat";
      # The Client-Side Kitty SSH Fix
      ssh = "kitty +kitten ssh"; 
    };
  };

# Git Configuration
  programs.git = {
    enable = true;
    userName  = "Aljam";                     # Replace with your actual Git username
    userEmail = "aljam@live.ca";    # Replace with your actual Git email
    
    extraConfig = {
      # Enforce SSH signing for all commits
      commit.gpgsign = true;
      gpg.format = "ssh";
      user.signingkey = "~/.ssh/id_ed25519.pub"; 
      
      # Quality of life settings
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
}
