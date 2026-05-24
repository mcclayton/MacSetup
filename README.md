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
1) Sandbox (Docker)
2) Current Machine
3) Quit
    => Choose Execution Environment:
```

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

## Demo

![Demo](./assets/public/demo.gif)
