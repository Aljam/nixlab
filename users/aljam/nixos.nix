{ config, pkgs, ... }:

{
  programs.fish.enable = true;

  # secrets.yaml: aljam_password = output of `mkpasswd -m yescrypt`
  sops.secrets.aljam_password.neededForUsers = true; # required — decrypt before user
    
  users.users.aljam = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHzrMiro1XD8krk5Kb4EWQ+rGjmgKXha/OuOmUZcopRL navi-desktop"
    ];
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "docker" "wireshark" "video" "render" "media" "input" ];
    shell = pkgs.fish; # Or whichever shell you use
    hashedPasswordFile = config.sops.secrets.aljam_password.path;
  };
}
