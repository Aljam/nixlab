{ config, pkgs, ... }:

{
  xdg.enable = true;

  # Heavy Desktop Applications & Media Tools
  home.packages = with pkgs; [
    ungoogled-chromium
    kdePackages.kate
    deadbeef-with-plugins
    discord
    betterdiscordctl
    telegram-desktop
    mpv
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

    # --- Gaming Essentials ---

    lutris
    heroic
    protonup-qt
    mangohud
    
    # --- AMD GPU Management (Navi) ---
    corectrl

    # --- dev tools ---
    vscodium
    jetbrains.idea-oss

    # --- Rhythm Games ---
    unnamed-sdvx-clone # Native Linux Sound Voltex (USC)
    qjackctl # GUI to manage low-latency audio for rhythm games

    # --- Upgraded Wine for Sound Voltex (EAC) ---
    wineWow64Packages.stagingFull # Replaces 'stable' - has the multilib + staging patches
    winetricks

    # File Management & Media
    yazi       # Blazing-fast terminal file manager written in Rust (with image previews)
    mpv        # Lightweight, infinitely scriptable media player
    imv        # Lightweight Wayland image viewer
  
    # Audio & Volume Management
    pavucontrol # Graphical PulseAudio/PipeWire volume control panel
    pamixer     # Command-line audio mixer for keybind integration
  
    # Clipboard & Utility Applets
    cliphist    # History manager for your Wayland clipboard
    libnotify   # Desktop notification CLI tools (notify-send)  
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
}
