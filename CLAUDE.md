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
- `.tmpl` suffix → processed as a Go template

Files can combine prefixes: `private_dot_ssh_config` → `~/.ssh/config` with mode 0600

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
- **Currently managed**: `.zshrc`

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
