# NixOS Tests

This directory contains NixOS integration tests for critical services.

## Running Tests

### Run All Tests

```bash
nix-build tests/default.nix
```

### Run Individual Tests

```bash
# Test PostgreSQL
nix-build tests/default.nix -A postgresql

# Test Jellyfin
nix-build tests/default.nix -A jellyfin

# Test SSH
nix-build tests/default.nix -A ssh

# Test Grafana
nix-build tests/default.nix -A grafana
```

### Run Tests with Build Cache

```bash
nix-build tests/default.nix --max-jobs 4
```

## Test Coverage

### PostgreSQL Test
- ✅ Service starts successfully
- ✅ Database is accessible
- ✅ User authentication works
- ✅ Can create and query databases

### Jellyfin Test
- ✅ Service starts successfully
- ✅ Web interface is accessible on port 8096
- ✅ Health check endpoint responds

### SSH Test
- ✅ SSH daemon is running
- ✅ Password authentication is disabled
- ✅ Root login is disabled
- ✅ Key-based authentication works

### Grafana Test
- ✅ Service starts successfully
- ✅ Web interface is accessible on port 3000
- ✅ Health check API responds

## Adding New Tests

To add a new test:

1. Create a new test in `tests/default.nix`:

```nix
mytest = pkgs.nixosTest {
  name = "mytest";
  
  nodes = {
    machine = { config, pkgs, ... }: {
      imports = [ ../modules/roles/your-role.nix ];
      
      services.yourservice = {
        enable = true;
        # ... configuration
      };
    };
  };
  
  testScript = ''
    machine.start()
    machine.wait_for_unit("yourservice.service")
    
    # Test your service
    machine.succeed("systemctl is-active yourservice.service")
    
    print("Your test passed!")
  '';
};
```

2. Add it to the exports at the top of the file

3. Run with: `nix-build tests/default.nix -A mytest`

## CI Integration

Tests are automatically run in CI on every push and pull request.

## Troubleshooting

### Test Fails to Start

Check if the service configuration is valid:

```bash
nixos-rebuild build --flake .#your-host
```

### Test Times Out

Increase the timeout in the test script or check if the service is hanging.

### Service Not Found

Ensure the module is correctly imported and the service is enabled.

## Resources

- [NixOS Test Documentation](https://nixos.org/manual/nixos/stable/#sec-nixos-tests)
- [NixOS Test Examples](https://github.com/NixOS/nixpkgs/tree/master/nixos/tests)
