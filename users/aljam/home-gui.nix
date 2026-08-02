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
    wineWowPackages.stable
    winetricks
    protonup-qt
    mangohud
    
    # --- AMD GPU Management (Navi) ---
    corectrl

    # --- dev tools ---
    vscodium
    jetbrains.idea-community

    # --- Emulation & Arcade ---
    fightcade
    fbneo # The backend emulator Fightcade uses

    # --- Rhythm Games ---
    unnamed-sdvx-clone # Native Linux Sound Voltex (USC)
    qjackctl # GUI to manage low-latency audio for rhythm games

    # --- Upgraded Wine for Sound Voltex (EAC) ---
    wineWowPackages.stagingFull # Replaces 'stable' - has the multilib + staging patches
    winetricks
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
