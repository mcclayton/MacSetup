# AGENTS.md

## Repository Tenets

This repository is an opinionated macOS development environment bootstrapper.
Changes should preserve the following goals.

1. **Idempotent installation**
   Running `./start.sh` or `./install.sh` multiple times should not duplicate PATH
   entries, aliases, SSH config blocks, app config, plugins, package state, or
   other generated setup.

2. **Interactive but automatable**
   The installer should remain friendly for a human setting up a real Mac, while
   also supporting predictable sandbox and non-interactive flows for testing.

3. **Portable Bash-first implementation**
   The setup flow should stay highly portable. Prefer Bash and standard Unix
   tools for installer logic, and avoid adding heavier runtime dependencies
   unless they clearly improve reliability or maintainability.

4. **Failure-tolerant execution**
   A failed section should be recorded clearly and should not unexpectedly hide
   later failures. When practical, the installer should continue through
   independent sections.

5. **Clear final reporting**
   At completion, the user should know what succeeded, what failed, what was
   skipped, what requires manual action, and where the log can be reviewed.

6. **Backup before overwrite**
   Existing dotfiles, app configs, Vim directories, shell configs, and other
   user-owned files should be backed up before replacement.

7. **Safe by default**
   The installer should not run as root, should avoid broad destructive actions,
   and should make the difference between sandbox changes and current-machine
   changes explicit.

8. **Sandbox parity**
   Docker mode should test meaningful installer behavior without touching the
   host, especially shell, Vim, editor, and package setup paths.

9. **Modular install sections**
   Each setup concern should stay in a focused section file with a single
   `runSection`, so steps can be reasoned about, skipped, reordered, or tested
   independently.

10. **Opinionated personal environment**
   This is not a generic Mac bootstrapper. It should install and configure
   Michael's preferred terminal, editor, shell, Git, app, font, wallpaper, and
   utility workflow.

11. **Verifiable actions**
    After installing, copying, or configuring something, the installer should
    assert that the expected command, file, directory, app, or config exists.

12. **Explicit manual actions**
    Anything that cannot be automated reliably, such as granting macOS app
    permissions or using a native installer UI, should be called out explicitly
    and pause for user confirmation.

13. **Config drift visibility**
    The repo should make it easy to compare live machine config against
    repo-managed config, especially dotfiles and terminal configuration.

14. **Compatibility-aware editor setup**
    Vim and terminal setup should degrade gracefully across older Vim builds,
    modern Vim builds, missing Node, missing `rg`, missing `bat`, missing
    `code-minimap`, and sandbox environments.

15. **Single-command onboarding**
    The happy path should stay simple: clone the repo, run `./start.sh`, choose
    an environment, and proceed through the prompts.

16. **Discoverable logs and backups**
    Install state should be inspectable after the fact through
    `~/.mac_setup/log` and `~/.mac_setup/backups`.
