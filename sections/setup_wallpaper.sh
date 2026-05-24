#!/bin/bash

# Set desktop wallpaper
function runSection {
  promptNewSection "SETTING DESKTOP WALLPAPER"
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if isMacOs; then
      options=("Sushi Keyboard Key" "Samurai Cat" "Heroku" "Cancel")
      chooseOption "Choose Wallpaper:" "${options[@]}"
      case "$MACSETUP_UI_CHOICE" in
        "Sushi Keyboard Key")
          cp "$MACSETUP_ASSETS_DIR/wallpapers/sushi_key.png" ~/wallpaper.png
          assertFileExists ~/wallpaper.png "Copied over wallpaper.png asset" "Failed to copy over wallpaper.png asset"
          open ~/
          manualAction "Right click wallpaper.png and select 'Set Desktop Picture'"
          ;;
        "Samurai Cat")
          cp "$MACSETUP_ASSETS_DIR/wallpapers/samurai_cat.png" ~/wallpaper.png
          assertFileExists ~/wallpaper.png "Copied over wallpaper.png asset" "Failed to copy over wallpaper.png asset"
          open ~/
          manualAction "Right click wallpaper.png and select 'Set Desktop Picture'"
          ;;
        "Heroku")
          cp "$MACSETUP_ASSETS_DIR/wallpapers/heroku.png" ~/wallpaper.png
          assertFileExists ~/wallpaper.png "Copied over wallpaper.png asset" "Failed to copy over wallpaper.png asset"
          open ~/
          manualAction "Right click wallpaper.png and select 'Set Desktop Picture'"
          ;;
        "Cancel")
          info "No desktop wallpaper set"
          ;;
      esac
    else
      warn "This is a MacOS specific step, skipping due to invalid OS..."
    fi
  else
    # Skip this installation section
    info "Skipping..."
  fi
}
