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
- `sectionRegistry.sh` owns the ordered section list and section metadata.
- `appConfigUtil.sh` owns app-specific configuration functions used by install
  sections.

Framework code should avoid knowing the details of a specific machine
preference unless it is needed to apply or verify configuration.

## Sections

`sections/` contains the installer workflow. Each section defines `runSection`
and is sourced by `install.sh` in a fixed order.

Sections should stay focused on orchestration: prompt for the step, call shared
helpers, copy config from `config/`, copy static payloads from `assets/`, and
verify the result.

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
