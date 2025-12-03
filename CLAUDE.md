# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a chezmoi dotfiles repository that manages system configuration files. Chezmoi is a dotfile manager that tracks configuration files in a Git repository and applies them to the home directory.

## Chezmoi Basics

### File Naming Convention

Chezmoi uses special prefixes to determine how files are processed:

- `dot_` → becomes `.` (e.g., `dot_zshrc` → `~/.zshrc`)
- `private_` → file mode 0600
- `executable_` → file mode 0755
- `symlink_` → creates a symlink
- `encrypted_` → encrypted with age (requires `~/.config/chezmoi/key.txt`)
- `.tmpl` suffix → processed as a Go template

Files can combine prefixes: `private_dot_ssh/encrypted_private_id_ed25519.age` → `~/.ssh/id_ed25519` with mode 0600, encrypted

### Common Commands

```bash
# View current state
chezmoi status              # Show differences between source and target
chezmoi diff                # Detailed diff of changes
chezmoi managed             # List all managed files

# Make changes
chezmoi edit <file>         # Edit file in source directory
chezmoi add <file>          # Add a new file to be managed
chezmoi apply               # Apply changes to home directory
chezmoi apply --dry-run -v  # Preview changes without applying

# Update from repo
chezmoi update              # Pull from git and apply changes
chezmoi git pull            # Pull changes from remote
chezmoi git -- <args>       # Run git commands in source directory

# Working with source files
chezmoi cd                  # Change to source directory
```

### Development Workflow

1. **Edit files**: Either edit directly in the source directory (`~/.local/share/chezmoi`) or use `chezmoi edit <file>`
2. **Test changes**: Use `chezmoi diff` or `chezmoi apply --dry-run -v` to preview
3. **Apply changes**: Run `chezmoi apply` to update the actual dotfiles
4. **Commit**: Git commit and push from the source directory

## Current Configuration

- **Source directory**: `~/.local/share/chezmoi`
- **Target directory**: `~/.home/aubrey` (user's home directory)
- **Encryption**: Age encryption enabled for secrets
- **Cross-platform**: Works on Linux (Arch, Ubuntu) and Windows (Git Bash with zsh)
- **Currently managed**:
  - `.zshrc` (with cross-platform template support)
  - `.zsharch` (Arch Linux only, via `.chezmoiignore`)
  - `.vimrc` (with chezmoi filetype detection)
  - SSH keys (encrypted with age)

### Age Encryption

This repository uses [age](https://age-encryption.org/) to encrypt sensitive files like SSH keys.

**Key locations:**
- **Private key (identity)**: `~/.config/chezmoi/key.txt` - **NEVER commit, keep secure backup**
- **Public key (recipient)**: `age1vten8ylla4zqxs905wpz5gascm5t4gyvnuldyw4x8e80kqp8354s625stz` - safe in `.chezmoi.toml.tmpl`

**Encrypted files:**
- `private_dot_ssh/encrypted_private_id_ed25519.age` - SSH private key
- `private_dot_ssh/id_ed25519.pub` - SSH public key (not encrypted)

**Bootstrap on new machine:**
```bash
# Option 1: Use GitHub PAT for initial clone
git clone https://github.com/zzxyz/chezmoi.git ~/.local/share/chezmoi
# Copy age key from secure backup
cp /path/to/backup/key.txt ~/.config/chezmoi/key.txt
chezmoi apply

# Option 2: Manually copy SSH key first, then clone via SSH
```

**Working without the age key:**
```bash
# Apply only non-encrypted files
chezmoi apply --exclude=encrypted
```

## Cross-Platform Support

This repository now supports both Linux and Windows environments:

**Linux (Primary):**
- Arch Linux and Ubuntu with distro-specific paths for zsh plugins
- Full kitty terminal integration
- Native zsh shell

**Windows (Git Bash):**
- Requires zsh installed via MSYS2/Git Bash
- Templates check for `osRelease` existence before accessing Linux-specific features
- Add `exec zsh` to `.bashrc` to auto-launch zsh in Git Bash
- Some features unavailable: kitty integration, certain zsh plugins

**Template Strategy:**
- All templates use defensive checks: `{{- if and (hasKey .chezmoi "osRelease") (hasKey .chezmoi.osRelease "id") }}`
- This allows the same templates to work across platforms without errors
- Linux systems proceed with distro-specific configuration
- Windows systems skip Linux-only sections gracefully

## Architecture Notes

### .zshrc Configuration

The zsh configuration includes:
- Custom prompt with exit status indicator
- Directory stack management (PUSHD_MINUS, AUTO_PUSHD)
- Zsh completions and syntax highlighting
- Custom keybindings for navigation (Home, End, Delete, Ctrl+Arrow for word movement)
- History search bound to up/down arrows
- Custom functions: `settitle()`, `chpwd()`, `man()` (with colors)
- Kitty terminal integration with image display on startup
- Sources additional configuration from `~/.zsharch`

The zshrc references a user named "tyler" in some paths and comments, suggesting this configuration may have been migrated from another user's setup.

## Important Notes

- Always use `chezmoi apply` to deploy changes to the home directory
- Never edit dotfiles directly in the home directory; edit them in the source directory
- Use `chezmoi status` before committing to ensure all changes are tracked
- **Security**: The age private key (`~/.config/chezmoi/key.txt`) must be kept secure and never committed to git
- **Conditional files**: `.chezmoiignore` controls which files are applied based on system characteristics (OS, distro, hostname)
- **Cross-platform templates**: When accessing `.chezmoi.osRelease`, always check existence first with `hasKey` to support Windows
- always go full perl