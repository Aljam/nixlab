# Inside modules/common.nix
environment.systemPackages = with pkgs; [
  kitty.terminfo
  htop
  git
];
