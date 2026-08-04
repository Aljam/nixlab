{
  description = "Aljam's Unified Homelab Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    nix-flatpak.url = "github:gmodena/nix-flatpak";
  };

  outputs = { self, nixpkgs, nixpkgs-stable, home-manager, disko, sops-nix, mailserver, ... }@inputs:
  let
    system = "x86_64-linux";
    
    pkgs-stable = import nixpkgs-stable {
      inherit system;
      config.allowUnfree = true;
    };

    # Centralized Fleet Domains
    domains = {
      primary    = "derezzed.info";       # Media server & stats
      fuwa       = "fuwa.space";
      cybal      = "cybal.org";
      netrunner  = "netrunner.dev";
      
      # Glowrunner variants
      glow_net   = "glowrunner.network";
      glow_dev   = "glowrunner.dev";
      glow_xyz   = "glowrunner.xyz";
    };
    
    mkHost = { hostname, extraModules ? [] }: nixpkgs.lib.nixosSystem {
      inherit system;
      
      # Added 'domains' here to pass to standard NixOS modules
      specialArgs = { inherit inputs pkgs-stable hostname domains; }; 
      
      modules = [
        ./hosts/${hostname}/configuration.nix
        ./modules/roles/common.nix
        ./users/aljam/nixos.nix
        sops-nix.nixosModules.sops
        
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.users.aljam = import ./users/aljam/home.nix;
          
          # Added 'domains' here so your Home Manager configurations can use them too
          home-manager.extraSpecialArgs = { inherit inputs pkgs-stable domains; };
        }
      ] ++ extraModules;
    };

    desktopGUI = { home-manager.users.aljam.imports = [ ./users/aljam/home-gui.nix ]; };
    serverDisko = disko.nixosModules.disko;
    flatpakModule = inputs.nix-flatpak.nixosModules.nix-flatpak;

  in {
    nixosConfigurations = {
      
      navi = mkHost { 
        hostname = "navi";
        extraModules = [ desktopGUI flatpakModule ]; 
      };
      
      oryx = mkHost { 
        hostname = "oryx";
        extraModules = [ 
          desktopGUI 
          flatpakModule 
          inputs.nixos-hardware.nixosModules.system76 
        ];
      };
      
      r820 = mkHost { 
        hostname = "r820"; 
      };
      
      r730 = mkHost { 
        hostname = "r730";
        extraModules = [ serverDisko ]; 
      };
      
      r730xd = mkHost { 
        hostname = "r730xd";
        extraModules = [ serverDisko ];
      };
      
    };
  };
}
