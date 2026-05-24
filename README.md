```
 __  __              ____       _
|  \/  | __ _  ___  / ___|  ___| |_ _   _ _ __
| |\/| |/ _` |/ __| \___ \ / _ \ __| | | | '_ \
| |  | | (_| | (__   ___) |  __/ |_| |_| | |_) |
|_|  |_|\__,_|\___| |____/ \___|\__|\__,_| .__/
                                        |_|
```

[![CI](https://github.com/mcclayton/MacSetup/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/mcclayton/MacSetup/actions/workflows/ci.yml)

**🚀 Complete Automated Mac Development Environment Setup 🚀**

## About

This repository contains an [install script](./install.sh) which, when run, will completely
set up a Macintosh machine configured to [Michael Clayton](https://github.com/mcclayton)'s preferred and opinionated development environment.
It will configure and install dot files, applications, packages, et cetera.

The script is designed to be interactive so users can still pick and choose what they want
to install/configure, however, you may still want to look through individual Dot Files and
pick/choose what you want at a more granular level.

This script is designed to be safe and can be run multiple times.

## Usage

Simply run the [install script](./install.sh) via the command:

```bash
$ ./start.sh
```

This will present the user with a choice to run the installer in one of two modes.
```
╭─ Choose Execution Environment: ─╮
│  > Sandbox (Docker)             │
│    Current Machine              │
│    Quit                         │
╰─────────────────────────────────╯
```

Interactive terminals use Bash-native arrow-key menus. Non-interactive runs,
including CI and piped Docker smoke tests, fall back to numeric prompts so the
installer remains scriptable and portable.

1. **Sandbox Environment**
      Installation/Setup changes are made in a dockerized sandbox environment and will not affect the current actual machine.
      The sandbox can run either an old Vim compatibility profile or a modern Vim + Node profile so Vim plugin fallback and full IDE flows can both be tested.
2. **Current Machine**
      Installation/Setup changes made in this environment will modify and affect the current actual machine.

## Repository Layout

- `lib/macsetup/` contains the installer framework: shared constants, helpers, logging, prompts, backups, and application configuration helpers.
- `sections/` contains the ordered installation sections that call into the framework.
- `config/` contains desired machine configuration such as dotfiles, Git config, VSCode settings, terminal preferences, app preferences, and asdf tool versions.
- `assets/` contains copied/static payloads such as fonts, wallpapers, Vim runtime files, the Aerial screensaver, splash images, and demo media.
- `tools/` contains read-only utility scripts for inspecting local machine state against repo-managed configuration.

## Diagnostics

Installer runs write a summary log to `~/.mac_setup/log`. Interactive output is
kept concise, while failed command details such as command text, exit code,
stdout, and stderr are written to the log for debugging.

To compare the current machine's managed top-level dotfiles against the repo
configuration, run:

```bash
$ ./tools/diff-dotfiles.sh
```

The diff tool reports missing live dotfiles and exits non-zero when it detects
config drift.

## Demo

![Demo](./assets/public/demo.gif)
