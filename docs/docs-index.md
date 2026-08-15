# Documentation Index

Welcome to the nixlab documentation. This index provides an overview of all available documentation.

## Quick Links

| Document | Purpose | For |
|----------|---------|-----||
| [README](../README.md) | Overview and quick start | Everyone |
| [Getting Started](GETTING-STARTED.md) | Setup and deployment guide | New users |
| [Architecture](ARCHITECTURE.md) | System design and modules | Developers, maintainers |
| [Roles](ROLES.md) | Role system documentation | All users |
| [Secrets](SECRETS.md) | Secrets management | All users |
| [Backup & Recovery](BACKUP-RECOVERY.md) | Backup strategies and DR | Administrators |

## Documentation Structure

```
nixlab/
├── README.md                 # Main entry point
└── docs/                     # Documentation directory
    ├── docs-index.md         # This file
    ├── GETTING-STARTED.md    # Setup guide
    ├── ARCHITECTURE.md       # System design
    ├── ROLES.md              # Role documentation
    ├── SECRETS.md            # Secrets management
    ├── BACKUP-RECOVERY.md    # Backup and recovery
    └── DEPLOYMENT-CHECKLIST.md # Deployment checklist
```

## By Use Case

### I'm New to nixlab

Start here:
1. [README](../README.md) - Overview and repository structure
2. [Getting Started](GETTING-STARTED.md) - Step-by-step setup
3. [Roles](ROLES.md) - Understand available roles
4. Deploy your first host!

### I'm Adding a New Host

Read these:
1. [Getting Started - Adding a New Host](GETTING-STARTED.md#adding-a-new-host)
2. [Roles](ROLES.md) - Choose the right role
3. [Secrets](SECRETS.md) - If host needs secrets
4. [Architecture](ARCHITECTURE.md) - Understand the module system

### I'm Managing Secrets

Essential reading:
1. [Secrets](SECRETS.md) - Complete secrets guide
2. [Getting Started - Prerequisites](GETTING-STARTED.md#prerequisites) - GPG setup
3. [Backup & Recovery](BACKUP-RECOVERY.md) - Backup your GPG keys

### I'm Setting Up Backups

Focus on:
1. [Backup & Recovery](BACKUP-RECOVERY.md) - Comprehensive backup guide
2. [Secrets](SECRETS.md) - Backup your GPG keys
3. [Architecture](ARCHITECTURE.md) - Understand what to backup

### I'm Troubleshooting

Check these sections:
1. [Getting Started - Troubleshooting](GETTING-STARTED.md#troubleshooting)
2. [Roles - Troubleshooting](ROLES.md#troubleshooting-roles)
3. [Secrets - Troubleshooting](SECRETS.md#troubleshooting)
4. [Backup & Recovery - Disaster Recovery](BACKUP-RECOVERY.md#disaster-recovery)

### I'm Contributing or Maintaining

Must read:
1. [Architecture](ARCHITECTURE.md) - System design decisions
2. [Roles](ROLES.md) - Role system details
3. Review existing modules in `modules/`

## Document Summaries

### [README](../README.md)

**Purpose**: Main entry point and overview

**Contents**:
- Quick start commands
- Repository structure
- Available roles and features
- Hosts inventory
- Common operations

**When to use**: First time visiting the repo, quick reference

---

### [Getting Started](GETTING-STARTED.md)

**Purpose**: Step-by-step setup and deployment guide

**Contents**:
- Prerequisites and requirements
- Quick start walkthrough
- Adding a new host (detailed)
- Common scenarios (desktop, server, media)
- Build and deploy commands
- Troubleshooting guide

**When to use**: Setting up nixlab for the first time, adding new hosts

---

### [Architecture](ARCHITECTURE.md)

**Purpose**: System design and technical documentation

**Contents**:
- Three-layer modular architecture
- Module system (hardware, roles, features)
- Dependency graphs
- Design decisions and rationale
- Security model
- Performance considerations
- Future improvements

**When to use**: Understanding how nixlab works, making architectural changes

---

### [Roles](ROLES.md)

**Purpose**: Documentation of the role system

**Contents**:
- Role system overview
- Detailed documentation for each role
- Role comparison table
- Combining roles
- Best practices
- Troubleshooting

**When to use**: Choosing a role, understanding role behavior, creating custom roles

---

### [Secrets](SECRETS.md)

**Purpose**: Secrets management with SOPS and GPG

**Contents**:
- SOPS architecture and flow
- Prerequisites and setup
- Using secrets in NixOS
- Common operations (add, update, remove)
- Best practices
- Troubleshooting
- Security considerations

**When to use**: Managing secrets, setting up SOPS, troubleshooting decryption

---

### [Backup & Recovery](BACKUP-RECOVERY.md)

**Purpose**: Backup strategies and disaster recovery

**Contents**:
- Backup philosophy (3-2-1 rule)
- Backup solutions (Borg, Restic, Sanoid)
- Database backup (PostgreSQL, etc.)
- Service-specific backup
- Disaster recovery scenarios
- Monitoring and testing
- Backup schedules
- Checklists

**When to use**: Setting up backups, recovering from failures, planning DR

## Quick Reference

### Common Commands

```bash
# Build and deploy
nixos-rebuild switch --flake .#hostname

# Test build
nixos-rebuild build --flake .#hostname

# Rollback
nixos-rebuild switch --rollback

# Update flake inputs
nix flake update

# Check flake
nix flake check

# Manage secrets
sops secrets/secrets.yaml
sops -d secrets/secrets.yaml

# Backup GPG keys
gpg --export-secret-keys --armor KEY_ID > backup.asc
```

### Important Paths

```
nixlab/
├── hosts/<hostname>/       # Host configurations
├── modules/
│   ├── roles/              # Role modules
│   ├── hardware/           # Hardware modules
│   └── features/           # Feature modules
├── secrets/                # SOPS secrets
├── users/<user>/           # User configurations
└── docs/                   # Documentation
```

### Key Files

- `flake.nix` - Main flake entry point
- `hosts/<hostname>/configuration.nix` - Host configuration
- `modules/roles/common.nix` - Base configuration
- `secrets/secrets.yaml` - Encrypted secrets
- `.sops.yaml` - SOPS encryption policy

## Getting Help

### Documentation Issues

If you find errors or missing information:
1. Check if it's covered in another document
2. Open an issue in the repository
3. Submit a PR with corrections

### Technical Issues

If you encounter problems:
1. Check [Troubleshooting](GETTING-STARTED.md#troubleshooting) sections
2. Review NixOS documentation: https://nixos.org/manual/nixos/stable/
3. Search NixOS community: https://nixos.org/community/
4. Check existing issues in the repository

### Contributing

To contribute to documentation:
1. Fork the repository
2. Make changes in `docs/`
3. Submit a pull request
4. Update this index if adding new documents

## Document Maintenance

### When to Update

Update documentation when:
- Adding new roles or features
- Changing architecture
- Modifying workflows
- Fixing errors
- Adding new hosts with unique requirements

### Review Schedule

- **Monthly**: Check for broken links
- **Quarterly**: Review for accuracy
- **Annually**: Major documentation overhaul

---

**Last Updated**: August 2026
