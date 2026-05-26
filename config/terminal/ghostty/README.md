# Ghostty

This folder contains the Ghostty terminal configuration.

## Wiring Status

`configureGhostty` in `lib/macsetup/appConfigUtil.sh`.

## Installed By

`install_applications.sh` installs the `ghostty` Homebrew cask and copies this
config into Ghostty's application support directory.

## Files

- `config` - Ghostty terminal settings, including the Catppuccin Macchiato palette.

## Destination

MacSetup copies the config to:

```sh
~/Library/Application Support/com.mitchellh.ghostty/config
```
