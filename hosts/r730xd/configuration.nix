{ config, pkgs, lib, fleet, ... }:

{
  imports = [
    # Fleet config
    fleet.hardware.dell.r730xd
    fleet.hardware.gpu.amd.mi50
    fleet.hardware.gpu.amd.mi50.amdgpu
    fleet.hardware.gpu.amd.mi50.rocm
    fleet.hardware.gpu.amd.mi50.opencl
    fleet.hardware.network.bcm5720
    fleet.software.containers
    fleet.software.virtualisation
    fleet.services.monitoring
    fleet.services.openssh
    fleet.services.sops
    # Local config
    ../../modules/features/grafana.nix
    ../../modules/features/monitoring.nix
    ../../modules/features/immich.nix
    ../../modules/features/immich-ai.nix
    ../../modules/features/nextcloud.nix
    ../../modules/features/plex.nix
    ../../modules/features/ha.nix
    ../../modules/features/arr.nix
    ../../modules/features/scanarr.nix
    ../../modules/features/nginx.nix
    ../../modules/features/zerotier.nix
    ../../modules/features/scanmyphotos.nix
    ../../modules/features/scanmyphotos-mapi.nix
    ../../modules/features/syncthing.nix
    ../../modules/features/it-tools.nix
    ../../modules/features/ollama.nix
    ../../modules/features/open-webui.nix
    ../../modules/features/uptime-kuma.nix
    ../../modules/features/haproxy.nix
    ../../modules/features/gitea.nix
    ../../modules/features/atuin.nix
    ../../modules/features/atuin-server.nix
    ../../modules/features/atuin-client.nix
    ../../modules/features/forgejo.nix
    ../../modules/features/forgejo-runner.nix
    ../../modules/features/forgejo-runner-docker.nix
    ../../modules/features/forgejo-runner-kubernetes.nix
    ../../modules/features/forgejo-runner-podman.nix
    ../../modules/features/forgejo-runner-qemu.nix
    ../../modules/features/forgejo-runner-shell.nix
    ../../modules/features/forgejo-runner-custom.nix
    ../../modules/features/forgejo-runner-custom-docker.nix
    ../../modules/features/forgejo-runner-custom-kubernetes.nix
    ../../modules/features/forgejo-runner-custom-podman.nix
    ../../modules/features/forgejo-runner-custom-qemu.nix
    ../../modules/features/forgejo-runner-custom-shell.nix
    ../../modules/features/forgejo-runner-custom-docker-custom.nix
    ../../modules/features/forgejo-runner-custom-kubernetes-custom.nix
    ../../modules/features/forgejo-runner-custom-podman-custom.nix
    ../../modules/features/forgejo-runner-custom-qemu-custom.nix
    ../../modules/features/forgejo-runner-custom-shell-custom.nix
  ];

  # Declare the SOPS secrets
  sops.secrets."grafana-secret-key" = { };
  sops.secrets."grafana-admin-password" = { };
  
  # Use the secret for Grafana
  services.grafana.settings.security.secret_key_file = config.sops.secrets."grafana-secret-key".path;

  boot.kernelPackages = pkgs.linuxPackages_6_1;  
  boot.kernelParams = [ 
    "amd_iommu=pt" 
    "iommu=pt" 
  ];

  # AMD MI50 GPU config
  hardware.amdgpu.opencl.enable = true;
  hardware.amdgpu.initrd.enable = true;
  hardware.amdgpu.roc.enable = true;
  hardware.amdgpu.vaapi.enable = true;

  # BCM5720 NIC config
  hardware.bcm5720.enable = true;

  # ZFS config
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.devNodes = "/dev/disk/by-id";
  boot.zfs.requestEncryptionCredentials = true;
  services.zfs.autoScrub.enable = true;

  # Containers config
  virtualisation.containers.enable = true;
  virtualisation.containers.storage.settings = {
    storage = {
      driver = "overlay";
    };
  };

  # Virtualisation config
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf.enable = true;
    };
  };

  # Monitoring config
  services.prometheus = {
    enable = true;
    port = 9090;
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          {
            targets = [ "localhost:9100" ];
          }
        ];
      }
    ];
  };

  services.node_exporter = {
    enable = true;
    port = 9100;
  };

  # OpenSSH config
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # SOPS config
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    secrets = {
      "grafana-secret-key" = { };
      "grafana-admin-password" = { };
    };
  };

  # System config
  system.stateVersion = 24.11;
  nixpkgs.config.allowUnfree = true;

  # User config
  users.users.jamie = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "libvirtd" "video" "render" ];
  };

  # Network config
  networking = {
    hostName = "r730xd";
    interfaces = {
      eno1 = {
        useDHCP = true;
      };
      eno2 = {
        useDHCP = true;
      };
    };
  };

  # Timezone config
  time.timeZone = "America/New_York";

  # Locale config
  i18n.defaultLocale = "en_US.UTF-8";
}
