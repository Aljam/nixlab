{ config, pkgs, ... }:

{
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

    # Search & Navigation
    ripgrep    # Blazing fast replacement for grep ('rg')
    fd         # Simple, fast alternative to 'find'
    jq         # Command-line JSON processor (essential for API debugging)
    
    # Git & Workflow
    lazygit    # Stunning terminal UI for Git commands
    fzf        # Command-line fuzzy finder (pairs great with zoxide & fish)
  
    # System Inspection & Monitoring
    btop       # Gorgeous resource monitor for CPU, memory, disks, and network
    ncdu       # NCurses disk usage analyzer (crucial for finding what's eating your ZFS space)
    fastfetch  # Modern replacement for neofetch to show system specs on shell boot
  ];

  # Fish Shell Configuration
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

  # Git Configuration
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Aljam";
        email = "aljam@live.ca";
        signingkey = "~/.ssh/id_ed25519.pub";
      };

      commit = {
        gpgsign = true;
      };

      gpg = {
        format = "ssh";
      };
    };
  };

  # Smart directory jumping
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  # Automatic Nix development environments
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.home-manager.enable = true;
}
