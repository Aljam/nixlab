# Roles

This document defines the service roles available in nixlab and how to compose them into host configurations.

## What is a Role?

A **role** is a self-contained NixOS module that defines a specific service or capability. Roles encapsulate:
- Service definitions (`services.*`)
- Package installations (`environment.systemPackages`)
- Firewall rules (`networking.firewall`)
- User/group creation
- Secret management
- Systemd service configuration

## Available Roles

### `database`

**Purpose**: Database server (PostgreSQL, optional Redis, MariaDB)  
**Location**: `modules/roles/database/`

**Options**:
```nix
roles.database = {
  enable = true;
  postgres = {
    enable = true;
    version = 15;
    port = 5432;
  };
  redis = {
    enable = false;
    port = 6379;
  };
};
```

**Ports**:
| Service   | Port  | Protocol |
|-----------|-------|----------|
| PostgreSQL| 5432  | TCP      |
| Redis     | 6379  | TCP      |

---

### `media`

**Purpose**: Media server stack (Jellyfin, Sonarr, Radarr, Lidarr, Readarr, Prowlarr)  
**Location**: `modules/roles/media/`

**Options**:
```nix
roles.media = {
  enable = true;
  jellyfin = {
    enable = true;
    port = 8096;
    hardwareAcceleration = "vaapi";
  };
  sonarr = {
    enable = true;
    port = 8989;
  };
  radarr = {
    enable = true;
    port = 7878;
  };
};
```

**Ports**:
| Service   | Port  | Protocol |
|-----------|-------|----------|
| Jellyfin  | 8096  | TCP      |
| Sonarr    | 8989  | TCP      |
| Radarr    | 7878  | TCP      |
| Lidarr    | 8686  | TCP      |
| Readarr   | 8787  | TCP      |
| Prowlarr  | 9696  | TCP      |

---

### `proxy`

**Purpose**: Reverse proxy and load balancer (HAProxy, optional Nginx)  
**Location**: `modules/roles/proxy/`

**Options**:
```nix
roles.proxy = {
  enable = true;
  haproxy = {
    enable = true;
    port = 80;
    sslPort = 443;
  };
  acme = {
    enable = true;
    email = "admin@example.com";
    domains = [ "example.com" ];
  };
};
```

---

### `storage`

**Purpose**: Network storage (NFS, Samba, ZFS management)  
**Location**: `modules/roles/storage/`

**Options**:
```nix
roles.storage = {
  enable = true;
  zfs = {
    enable = true;
    poolName = "tank";
  };
  nfs = {
    enable = true;
    shares = [
      {
        path = "/mnt/tank/media";
        clients = [ "192.168.1.0/24" ];
      }
    ];
  };
};
```

---

### `monitoring`

**Purpose**: System monitoring and metrics (Prometheus, Grafana, Node Exporter)  
**Location**: `modules/roles/monitoring/`

**Options**:
```nix
roles.monitoring = {
  enable = true;
  prometheus = {
    enable = true;
    port = 9090;
  };
  grafana = {
    enable = true;
    port = 3000;
  };
  nodeExporter = {
    enable = true;
    port = 9100;
  };
};
```

**Ports**:
| Service       | Port  | Protocol |
|---------------|-------|----------|
| Prometheus    | 9090  | TCP      |
| Grafana       | 3000  | TCP      |
| Node Exporter | 9100  | TCP      |

---

### `ci`

**Purpose**: CI/CD infrastructure (GitHub Actions runners, build agents)  
**Location**: `modules/roles/ci/`

**Options**:
```nix
roles.ci = {
  enable = true;
  githubActions = {
    enable = true;
    runnerName = "nixlab-runner";
    url = "https://github.com/Aljam/nixlab";
  };
};
```

## Role Composition

### Example: Database + Storage + Monitoring

```nix
# hosts/r820/default.nix
{
  imports = [
    ../../modules/roles/database
    ../../modules/roles/storage
    ../../modules/roles/monitoring
  ];
  
  roles.database.enable = true;
  roles.storage.enable = true;
  roles.monitoring.enable = true;
}
```

### Example: Full Media Server

```nix
# hosts/r730xd/default.nix
{
  imports = [
    ../../modules/roles/media
    ../../modules/roles/storage
    ../../modules/roles/proxy
  ];
  
  roles.media.enable = true;
  roles.storage.enable = true;
  roles.proxy.enable = true;
}
```

## Creating a New Role

### 1. Create Directory Structure

```bash
mkdir -p modules/roles/newrole
```

### 2. Define Module

```nix
# modules/roles/newrole/default.nix
{ config, pkgs, lib, ... }: {
  options.roles.newrole = {
    enable = lib.mkEnableOption "newrole service";
    port = lib.mkOption {
      type = types.int;
      default = 8000;
    };
  };
  
  config = lib.mkIf config.roles.newrole.enable {
    services.newrole.enable = true;
    networking.firewall.allowedTCPPorts = [ config.roles.newrole.port ];
  };
}
```

## Best Practices

### 1. Keep Roles Focused

Each role should do one thing well. Don't combine unrelated services.

### 2. Use Options for Configuration

Expose all configurable values as options.

### 3. Document Secrets

List all required secrets in the role documentation.

### 4. Handle Dependencies

If a role needs another role, document it.

---

**Last Updated**: August 2026