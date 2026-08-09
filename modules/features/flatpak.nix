{ config, pkgs, ... }:

{
  services.flatpak = {
    enable = true;
    update = {
      onActivation = true;
      auto = {
        enable = false;
      };
    };
    remotes = [
      {
        name = "flathub";
        location = "https://flathub.org/repo/flathub.flatpakrepo";
      }
      {
        name = "appcenter";
        location = "https://flatpak.elementary.io/repo";
      }
    ];
    packages = [
      {
        appId = "org.vinegarhq.Sober";
        origin = "flathub";
      }
      "com.fightcade.Fightcade"
    ];
  };
  services.flatpak.overrides = {
    settings = {
      global = {
        Context.sockets = [ "!wayland" "x11" "fallback-x11" ];
      };
    };
  };
}
