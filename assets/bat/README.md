# Bat

This folder contains configuration assets for `bat`, the syntax-highlighting file previewer used by fzf.

## Installed By

`configureBat` in `lib/macsetup/appConfigUtil.sh`.

## Files

- `themes/Catppuccin Macchiato.tmTheme` - Catppuccin Macchiato syntax theme for bat previews.

## Destination

MacSetup copies the theme to:

```sh
$(bat --config-dir)/themes/Catppuccin Macchiato.tmTheme
```

After copying, MacSetup runs:

```sh
bat cache --build
```

This lets Vim/fzf previews use:

```sh
bat --theme="Catppuccin Macchiato"
```
