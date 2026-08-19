# Networking

This document describes the network architecture, firewall configuration, and service routing in nixlab.

## Network Topology

```
                    ┌─────────────────┐
                    │   Internet      │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │   pfSense       │
                    │   (Firewall)    │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
       ┌──────▼──────┐ ┌─────▼─────┐ ┌──────▼──────┐
       │    navi     │ │   r820    │ │   r730xd    │
       │  (Proxy)    │ │ (Database)│ │  (Storage)  │
       │ 192.168.1.5 │ │192.168.1.10│ │192.168.1.15 │
       └─────────────┘ └───────────┘ └─────────────┘
```

## IP Addressing

### Host Assignments

| Host    | IP Address     | Role              |
|---------|----------------|-------------------|
| `navi`  | 192.168.1.5    | Edge proxy        |
| `r820`  | 192.168.1.10   | Database server   |
| `r730xd`| 192.168.1.15   | Storage/Media     |
| `r730`  | 192.168.1.20   | Application/CI    |
| `oryx`  | 192.168.1.25   | Development       |

### Network Configuration

```nix
# hosts/r730/default.nix
{
  networking = {
    hostName = "r730";
    
    interfaces.eno1 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "192.168.1.20";
          prefixLength = 24;
        }
      ];
    };
    
    defaultGateway = "192.168.1.1";
    nameservers = [ "192.168.1.1" "1.1.1.1" ];
  };
}
```

## Firewall Configuration

### nftables Rules

nixlab uses **nftables** for host-based firewall protection.

```nix
# modules/features/hardening/default.nix
{
  networking.firewall = {
    enable = true;
    defaultInputPolicy = "drop";
    defaultOutputPolicy = "accept";
    
    allowedTCPPorts = [ 22 80 443 ];
    allowedUDPPorts = [ 53 123 ];
    allowPing = true;
  };
}
```

### Role-Specific Firewall Rules

```nix
# modules/roles/database/default.nix
{
  networking.firewall.allowedTCPPorts = [ 5432 ];
}

# modules/roles/media/default.nix
{
  networking.firewall.allowedTCPPorts = [ 8096 8989 7878 ];
}

# modules/roles/monitoring/default.nix
{
  networking.firewall.allowedTCPPorts = [ 9090 3000 9100 ];
}
```

## HAProxy Reverse Proxy

### Configuration

```nix
# modules/roles/proxy/default.nix
{
  services.haproxy = {
    enable = true;
    
    frontends = [
      {
        name = "https";
        bind = "*:443 ssl crt /var/lib/acme/example.com/fullchain.pem";
        mode = "http";
        extraConfig = ''
          acl is_jellyfin hdr(host) -i jellyfin.example.com
          use_backend jellyfin if is_jellyfin
        '';
      }
    ];
    
    backends = [
      {
        name = "jellyfin";
        mode = "http";
        extraConfig = ''
          server jellyfin 192.168.1.15:8096
        '';
      }
    ];
  };
}
```

## DNS Configuration

### Local DNS (pfSense)

```
Host Overrides:
- navi.lab.local → 192.168.1.5
- r820.lab.local → 192.168.1.10
- r730xd.lab.local → 192.168.1.15
- r730.lab.local → 192.168.1.20
```

### NixOS DNS Settings

```nix
# hosts/common.nix
{
  networking = {
    nameservers = [ "192.168.1.1" "1.1.1.1" ];
    search = [ "lab.local" ];
  };
}
```

## Service Discovery

### Internal Service URLs

| Service   | Internal URL              | External URL                  |
|-----------|---------------------------|-------------------------------|
| Jellyfin  | http://192.168.1.15:8096  | https://jellyfin.example.com  |
| Sonarr    | http://192.168.1.15:8989  | https://sonarr.example.com    |
| Radarr    | http://192.168.1.15:7878  | https://radarr.example.com    |
| Grafana   | http://192.168.1.10:3000  | https://grafana.example.com   |
| Prometheus| http://192.168.1.10:9090  | https://prometheus.example.com|

## Security

### SSH Access

```nix
# hosts/common.nix
{
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "prohibit-password";
    allowUsers = [ "aljam" "admin" ];
  };
}
```

### Rate Limiting

```nix
# modules/features/hardening/default.nix
{
  networking.firewall.extraRules = [
    {
      interface = "eno1";
      port = 22;
      protocol = "tcp";
      extraOpts = "-m recent --name SSH --set --rsource";
    }
  ];
}
```

## Troubleshooting

### Check Network Connectivity

```bash
# Test connectivity
ping -c 4 192.168.1.1

# Check routing
ip route show

# Check DNS resolution
dig jellyfin.example.com

# Check open ports
ss -tulpn | grep LISTEN
```

### Firewall Debugging

```bash
# View nftables rules
sudo nft list ruleset

# Check blocked connections
sudo journalctl -u nftables -f
```

---

**Last Updated**: August 2026