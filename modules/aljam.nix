{ config, pkgs, ... }:

{
  programs.fish.enable = true;

  users.users.aljam = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHzrMiro1XD8krk5Kb4EWQ+rGjmgKXha/OuOmUZcopRL navi-desktop"
    ];
    extraGroups = [ "networkmanager" "wheel" "docker" "video" "render" "media" ];
    shell = pkgs.fish; # Or whichever shell you use
  };
}
