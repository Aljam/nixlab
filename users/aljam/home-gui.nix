{ config, pkgs, pkgs-stable, ... }:

{
  xdg.enable = true;

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
    pkgs-stable.lutris
    heroic
    protonup-qt
    mangohud
    corectrl
    vscodium
    jetbrains.idea
    unnamed-sdvx-clone
    qjackctl
    # Replaces 'stable' - has the multilib + staging patches for Sound Voltex (EAC)
    wineWow64Packages.stagingFull
    winetricks
    yazi
    imv
    pavucontrol
    pamixer
    cliphist
    libnotify
  ];

  programs.kitty = {
    enable = true;
    settings = {
      scrollback_lines = 10000;
      enable_audio_bell = false;
      update_check_interval = 0;
    };
  };

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
