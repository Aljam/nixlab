# Testing Checklist - Security Hardening Complete

**Date**: 2026-08-16  
**Status**: ✅ Ready for Testing

---

## ✅ Completed Fixes

- [x] All services bind to 127.0.0.1
- [x] Config wiring (fleet/subnets/domain)
- [x] Firewall restricted to proxy IP only
- [x] common.nix properly restored (no conflicts)
- [x] server-core.nix fixed (no broken options)
- [x] PostgreSQL databases restored (webscraper + grafana)
- [x] Duplicate firewall rules removed
- [x] Secrets syntax correct (.path)
- [x] Secrets exist in secrets.yaml

---

## 🧪 Run These Tests

### 1. Flake Evaluation

```bash
# Check flake evaluates without errors
nix flake check

# Should pass with no errors
```

### 2. Dry Activation (One Server)

```bash
# Test on r730 or r730xd
cd /path/to/nixlab
sudo nixos-rebuild dry-activate --flake .#r730

# Check for:
# - No evaluation errors
# - No option conflicts
# - All services recognized
```

### 3. Dry Activation (One Desktop)

```bash
# Test on navi or oryx
sudo nixos-rebuild dry-activate --flake .#navi

# Verify desktop modules work correctly
```

### 4. Verify Service Bindings

```bash
# After actual rebuild, check bindings
ss -tlnp | grep -E ':(3000|7878|8989|8000|5432|5050|9090|9100)'

# Should show:
# 127.0.0.1:3000  (Grafana)
# 127.0.0.1:8000  (Vaultwarden)
# 127.0.0.1:5432  (PostgreSQL)
# 127.0.0.1:5050  (pgAdmin)
# etc.
```

### 5. Verify Firewall Rules

```bash
# Check firewall configuration
sudo nft list ruleset

# Should show:
# - Only proxy IP (192.168.1.1) can reach backend ports
# - No broad 192.168.1.0/24 rules
# - Management subnet rules for PostgreSQL/pgAdmin
```

### 6. Test Secrets Decryption

```bash
# Verify sops can decrypt
sudo sops -d secrets/secrets.yaml | grep -E 'grafana|vaultwarden|pgadmin'

# Should show decrypted values
```

### 7. Test Database Access

```bash
# After deployment, test PostgreSQL
sudo -u postgres psql -c '\l'

# Should show:
# - webscraper database
# - grafana database
```

### 8. Test Reverse Proxy Access

```bash
# From the host itself (should work)
curl -I http://127.0.0.1:3000  # Grafana
curl -I http://127.0.0.1:8000  # Vaultwarden

# Via reverse proxy (should work)
curl -I https://grafana.derezzed.info
curl -I https://vault.derezzed.info

# Direct LAN access (should FAIL)
# From another machine on LAN:
curl -I http://<server-ip>:3000  # Should timeout/refused
```

---

## ✅ Expected Results

| Test | Expected Result |
|------|-----------------|
| `nix flake check` | ✅ No errors |
| `dry-activate` (server) | ✅ No evaluation errors |
| `dry-activate` (desktop) | ✅ No evaluation errors |
| Service bindings | ✅ All show 127.0.0.1 |
| Firewall rules | ✅ Proxy IP only |
| Secrets decryption | ✅ Shows decrypted values |
| PostgreSQL databases | ✅ webscraper + grafana |
| Reverse proxy access | ✅ Works |
| Direct LAN access | ❌ Fails (as intended) |

---

## 🐛 If Tests Fail

### Evaluation Errors

```bash
# Check specific error
nix flake check --show-trace

# Common fixes:
# - Missing secret key: Add to secrets/secrets.yaml
# - Option mismatch: Check module API
# - Import error: Verify file paths
```

### Service Not Binding to 127.0.0.1

```bash
# Check module configuration
cat modules/features/<service>.nix

# Verify bindAddress/listenAddress = "127.0.0.1"
```

### Firewall Too Permissive

```bash
# Check reverse-proxy-backends.nix
cat modules/features/reverse-proxy-backends.nix

# Should show proxy IP only, no 192.168.1.0/24
```

---

## 📊 Final Checklist

- [ ] `nix flake check` passes
- [ ] `dry-activate` on one server passes
- [ ] `dry-activate` on one desktop passes
- [ ] Services bind to 127.0.0.1
- [ ] Firewall rules correct
- [ ] Secrets decrypt successfully
- [ ] PostgreSQL databases exist
- [ ] Reverse proxy access works
- [ ] Direct LAN access blocked

---

## 🎉 Success Criteria

**All tests pass** = Security hardening complete!  

**Commits**: https://github.com/Aljam/nixlab/commits/main/
