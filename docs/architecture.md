# MacSetup Architecture

MacSetup is organized around a split between installer framework code and the
desired machine state it applies.

## Framework

`lib/macsetup/` contains reusable installer mechanics:

- `constants.sh` defines terminal colors, log/backup locations, and repository
  path constants.
- `ui.sh` owns portable terminal UI primitives, including boxed arrow-key menus
  for interactive terminals and plain numeric prompts for non-interactive runs.
- `helperFunctions.sh` is the compatibility entrypoint that sources focused
  helper modules.
- `logging.sh`, `prompts.sh`, `backup.sh`, `assertions.sh`, `platform.sh`, and
  `installers.sh` own shared framework responsibilities.
- `dotfiles.sh` owns the managed top-level dotfile inventory shared by install
  sections and diagnostic tools.
- `configDiff.sh` owns reusable read-only comparison helpers for detecting
  drift between repo-managed config and current-machine files.
- `sectionRegistry.sh` owns the ordered section list and section metadata.
- `appConfigUtil.sh` owns app-specific configuration functions used by install
  sections.

Framework code should avoid knowing the details of a specific machine
preference unless it is needed to apply or verify configuration.

### Command Logging

Shell-outs should use the command helpers in `lib/macsetup/logging.sh` instead
of running commands directly. The installer should keep terminal output concise
while writing detailed command diagnostics to `~/.mac_setup/log` when something
fails.

- `runCommand "Description" command args...`
  Use for non-interactive commands whose normal output is not useful unless the
  command fails, such as `cp`, `git clone`, `brew install`, and `asdf install`.
  On failure, the terminal shows a short failure line and the log captures the
  command, exit code, stdout, and stderr.
- `runCommandCapture "Description" "$output_file" command args...`
  Use when a later step needs stdout in a file. The failure logging behavior is
  the same as `runCommand`.
- `runCommandOutputVariable variable_name "Description" command args...`
  Use instead of command substitution when stdout should be assigned to a
  variable, such as `brew --prefix` or `ssh-agent -s`. This preserves detailed
  failure logging.
- `runProbeCommandOutputVariable variable_name "Description" command args...`
  Use for exploratory path probes where failure should not print to the
  terminal or count toward the final failure summary because a later candidate
  may succeed. Failed probes still write command details to the log.
- `runInteractiveCommand "Description" command args...`
  Use for commands that may prompt, consume stdin, or manage their own terminal
  output, such as native installers or `ssh-keygen`. Failure logs include the
  command and exit code, but stdout/stderr are not captured.
- `runOptionalCommand "Description" command args...`
  Use for cleanup or advisory commands where failure should be a warning, not a
  section failure. Captured stdout/stderr still go to the log when the command
  fails.

If a command is purely a local predicate and its output is intentionally
discarded, direct execution is acceptable. Examples include `cmdExists`,
`grep -q`, and package-installed checks.

## Sections

`sections/` contains the installer workflow. Each section defines `runSection`
and is sourced by `install.sh` in a fixed order.

Sections should stay focused on orchestration: prompt for the step, call shared
helpers, copy config from `config/`, copy static payloads from `assets/`, and
verify the result.

## Tools

`tools/` contains utility scripts for inspecting or comparing local machine
state. These scripts should be read-only by default and should not be part of
the primary installation path.

`tools/diff-dotfiles.sh` compares the repo-managed top-level dotfiles against
the current user's home directory and reports missing files or content drift.

## Configuration

`config/` contains desired machine configuration:

- `config/dotfiles/mac/` contains shell, Vim, tmux, splash, alias, and global
  ignore files copied into the user's home directory.
- `config/git/` contains Git configuration files.
- `config/asdf/` contains asdf tool version configuration.
- `config/vscode/` contains VSCode settings and extension lists.
- `config/terminal/` contains terminal emulator preferences.
- `config/apps/` contains application preference files.
- `config/templates/` contains miscellaneous reusable config templates.

## Assets

`assets/` contains copied/static payloads:

- `assets/fonts/`
- `assets/wallpapers/`
- `assets/screensavers/`
- `assets/splash/`
- `assets/vim/`
- `assets/bat/`
- `assets/public/`

Assets may be copied into place by sections, but they should not contain
installer framework logic.
