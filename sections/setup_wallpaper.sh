#!/bin/bash

# Set desktop wallpaper
function runSection {
  runPromptedSection "SETTING DESKTOP WALLPAPER" setupWallpaper
}

setupWallpaper() {
  if isMacOs; then
    options=("Sushi Keyboard Key" "Samurai Cat" "Heroku" "Cancel")
    chooseOption "Choose Wallpaper:" "${options[@]}"
    case "$MACSETUP_UI_CHOICE" in
      "Sushi Keyboard Key")
        runCommand "Copy Sushi Keyboard Key wallpaper" cp "$MACSETUP_ASSETS_DIR/wallpapers/sushi_key.png" ~/wallpaper.png || return 1
        assertFileExists ~/wallpaper.png "Copied over wallpaper.png asset" "Failed to copy over wallpaper.png asset"
        runCommand "Open home directory for wallpaper setup" open ~/ || return 1
        manualAction "Right click wallpaper.png and select 'Set Desktop Picture'"
        ;;
      "Samurai Cat")
        runCommand "Copy Samurai Cat wallpaper" cp "$MACSETUP_ASSETS_DIR/wallpapers/samurai_cat.png" ~/wallpaper.png || return 1
        assertFileExists ~/wallpaper.png "Copied over wallpaper.png asset" "Failed to copy over wallpaper.png asset"
        runCommand "Open home directory for wallpaper setup" open ~/ || return 1
        manualAction "Right click wallpaper.png and select 'Set Desktop Picture'"
        ;;
      "Heroku")
        runCommand "Copy Heroku wallpaper" cp "$MACSETUP_ASSETS_DIR/wallpapers/heroku.png" ~/wallpaper.png || return 1
        assertFileExists ~/wallpaper.png "Copied over wallpaper.png asset" "Failed to copy over wallpaper.png asset"
        runCommand "Open home directory for wallpaper setup" open ~/ || return 1
        manualAction "Right click wallpaper.png and select 'Set Desktop Picture'"
        ;;
      "Cancel")
        info "No desktop wallpaper set"
        ;;
    esac
  else
    warn "This is a MacOS specific step, skipping due to invalid OS..."
  fi
}
