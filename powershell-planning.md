# PowerShell Support Planning

## Context

Discussion started 2025-12-05 about adding PowerShell profile management to the chezmoi dotfiles repository.

## The PowerShell Landscape

**Three environments to consider:**

1. **PowerShell Core** (pwsh.exe)
   - Version 7+
   - Cross-platform (Windows, Linux, macOS)
   - Modern, actively developed
   - Profile: `~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`

2. **Windows PowerShell** (powershell.exe)
   - Version 5.1
   - Windows-only, legacy
   - Still default on many Windows systems
   - Profile: `~\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1`

3. **Git Bash launched from PowerShell**
   - Can be launched from either PowerShell Core or Windows PowerShell
   - May inherit environment variables from parent shell
   - Currently auto-launches zsh via `.bashrc`
   - Detection of parent shell might be complex

## Key Challenges

### 1. Profile Location Management

- Two different profile paths to manage
- Both might exist on the same system
- Need to decide: separate files or shared template with version detection?

### 2. Detection in Chezmoi Templates

**Cannot use `osRelease`:**
- Windows doesn't have `/etc/os-release`
- Must rely on other chezmoi variables

**Available detection:**
- `{{ .chezmoi.os }}` - will be "windows"
- PowerShell version detection must happen at runtime within the profile itself
- Could use `$PSVersionTable.PSVersion` in PowerShell profiles

### 3. Git Bash Parent Shell Detection

**Challenge:** Git Bash might need to know if it was launched from PowerShell

**Possible approaches:**
- Check `$PPID` or process tree
- Check for PowerShell-specific environment variables
- May not be worth the complexity if zsh setup is already shell-agnostic

### 4. Integration Strategy

**Questions to answer:**

1. **Profile behavior:**
   - Auto-launch zsh from PowerShell (like current `.bashrc` does with `exec zsh`)?
   - Set up PowerShell environment and stay in PowerShell?
   - Conditional behavior based on context (interactive vs script, terminal type, etc.)?

2. **Template structure:**
   - Single template that adapts to PowerShell version at runtime?
   - Two separate profile files managed independently?
   - Shared configuration sourced by both?

3. **Use case priority:**
   - Primary use: PowerShell as launcher for Git Bash/zsh?
   - Primary use: Working directly in PowerShell?
   - Equal support for both scenarios?

## Technical Considerations

### Chezmoi File Naming for PowerShell Profiles

**PowerShell Core:**
```
Documents/PowerShell/Microsoft.PowerShell_profile.ps1
```
Chezmoi path: `Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl`

**Windows PowerShell:**
```
Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1
```
Chezmoi path: `Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1.tmpl`

### Runtime Version Detection Example

```powershell
# In PowerShell profile
if ($PSVersionTable.PSVersion.Major -ge 7) {
    # PowerShell Core specific configuration
} else {
    # Windows PowerShell specific configuration
}
```

### Potential Template Pattern

```go
{{- if eq .chezmoi.os "windows" }}
# Windows-specific PowerShell configuration
# This will be in both profile files, but can adapt at runtime
{{- end }}
```

## Questions for User

Before implementing, need to clarify:

1. **What should PowerShell profiles do?**
   - Auto-launch zsh?
   - Set up their own environment?
   - Hybrid approach?

2. **Git Bash detection needs:**
   - Should Git Bash behave differently based on parent PowerShell version?
   - Or is current zsh setup sufficient once in Git Bash?

3. **Profile management approach:**
   - Manage both profiles separately?
   - Use shared template with runtime adaptation?

4. **Primary use case:**
   - How much time spent in PowerShell itself vs using it to launch Git Bash?

## Next Steps

1. Clarify use case and requirements with user
2. Design template structure based on answers
3. Implement profile templates
4. Test on system with both PowerShell versions
5. Document PowerShell-specific patterns in CLAUDE.md

## Notes

- This is a saved analysis for future reference
- User wants to return to this topic later
- No implementation decisions made yet
