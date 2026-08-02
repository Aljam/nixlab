{ config, pkgs, ... }:

{
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
  ];

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting "${c1}
                      .@hpp
                      "KKP
            ,      ,+;n@nnw,    ,,
         ,||ppKN|||p##KKNpp|LKp!L@|IN,
       ;L##KKPL|$#KKM"````"TE|IKm`"K@LKp
     ||#KKM` ||#KKP .*||hw,  T|I#N   T||Km
    ||$#K`   |I#KP | |||$##N  @I#KH   ||$#N
    '|I8N    |I#Kb Y@@p##KBKP |I#KN  ,@$#KM
      TPLKm, Y|I8N  "KKKKKK* ||##KL,@$#KKP
        "Kp@bp$p@LKp,     .||p##KH@p#KK*
     U@#Kp`*KKK*Tb@@I#m |.{#KKKM*KKKPT@#Kp
      `*"         `PK#K HI#KM`        `**`
                   IK#K $K#B
           ,Kpp    I#BB IhKKp   p#p,
           "KKKKmp##KKK TKKKKp##KKKM
             `TKKKKKKP`  `*KKKKKKM`

"
    '';
    shellAliases = {
      ls = "eza --icons";
      cat = "bat";
      ssh = "kitty +kitten ssh";
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Aljam";
        email = "aljam@live.ca";
        signingkey = "~/.ssh/id_ed25519.pub";
      };
      commit.gpgsign = true;
      gpg.format = "ssh";
    };
  };

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
