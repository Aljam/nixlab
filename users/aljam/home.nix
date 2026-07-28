{ config, pkgs, ... }:

{
  home.username = "aljam";
  home.homeDirectory = "/home/aljam";
  home.stateVersion = "23.11";

  # Your Common Dev Tools & GUI Applications
  home.packages = with pkgs; [
    # CLI / Dev Tools
    bat
    eza
    fzf
    ripgrep
    jq
    tldr

    # GUI Applications & Software
    ungoogled-chromium
    kdePackages.kate
    deadbeef-with-plugins
    discord
    betterdiscordctl
    telegram-desktop
    mpv
    kitty
    obsidian
    librewolf
    gimp
    krita
    blender
    qbittorrent
    inkscape
    audacity
    super-slicer
    davinci-resolve
    element-desktop
    libreoffice-qt
    hunspell
    hunspellDicts.en_US
    hyphenDicts.en_US
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
      ssh = "kitty +kitten ssh"; 
    };
  };

  # Git Configuration
  programs.git = {
    enable = true;
    userName  = "Aljam";
    userEmail = "aljam@live.ca";
    
    extraConfig = {
      commit.gpgsign = true;
      gpg.format = "ssh";
      user.signingkey = "~/.ssh/id_ed25519.pub"; 
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  # OBS Studio Configuration
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
      obs-gstreamer
      obs-vkcapture
      input-overlay
      obs-command-source
      obs-retro-effects
    ];
  };

  programs.home-manager.enable = true;
}
