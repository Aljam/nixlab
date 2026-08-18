# Networking

## Tailscale subnet routes

Desktop hosts intentionally use:

```bash
tailscale up --accept-routes=true
```

This allows the desktop to accept subnet routes advertised by approved Tailscale subnet routers. On Linux, advertised subnet routes are not accepted by default, so this setting is required when a desktop needs access to resources on those routed networks. [web:194][web:197]

### Trust boundary

Accepting routes expands the desktop's routing trust boundary. A route advertised through the tailnet can become reachable from the desktop when it is approved and accepted. This is intentional for desktop access to trusted homelab and remote networks; it is not a blanket declaration that every routed network is trusted.

### Operational policy

- Advertise only the subnets that are required.
- Use trusted subnet routers and approve route advertisements deliberately.
- Keep Tailscale ACLs or grants restrictive.
- Review route advertisements when adding or approving devices.
- Do not enable route acceptance on servers unless they require routed subnet access.
- Treat an approved route as a network-access change, not merely a Tailscale client preference.

### Verification

Inspect Tailscale preferences and the kernel routing table:

```bash
tailscale debug prefs
ip route
```

Confirm that only expected subnet routes are present and that traffic reaches the intended subnet router.

### Change procedure

Before accepting a new route:

1. Identify the subnet and its owner.
2. Confirm the advertising node is trusted.
3. Confirm the route is approved in the Tailscale admin policy.
4. Verify the desktop actually needs access to that subnet.
5. Test connectivity and review the resulting route table.

If the route is no longer needed, remove the advertisement or disable route acceptance:

```bash
tailscale set --accept-routes=false
```

**Intent:** `--accept-routes=true` is enabled on desktops for deliberate routed-network access. Keep the setting disabled on servers unless a documented service dependency requires it.

