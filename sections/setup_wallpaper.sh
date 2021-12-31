#!/bin/bash

# Set desktop wallpaper
function runSection {
  promptNewSection "SETTING DESKTOP WALLPAPER"
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if isMacOs; then
      PS3='   => Choose Wallpaper: '
      options=("Sushi Keyboard Key" "Samurai Cat" "Heroku" "Cancel")
      select opt in "${options[@]}"
      do
        case $opt in
          "Sushi Keyboard Key")
            cp "$(scriptDirectory)/wallpapers/sushi_key.png" ~/wallpaper.png
            assertFileExists ~/wallpaper.png "Copied over wallpaper.png asset" "Failed to copy over wallpaper.png asset"
            open ~/
            manualAction "Right click wallpaper.png and select 'Set Desktop Picture'"
            break
            ;;
          "Samurai Cat")
            cp "$(scriptDirectory)/wallpapers/samurai_cat.png" ~/wallpaper.png
            assertFileExists ~/wallpaper.png "Copied over wallpaper.png asset" "Failed to copy over wallpaper.png asset"
            open ~/
            manualAction "Right click wallpaper.png and select 'Set Desktop Picture'"
            break
            ;;
          "Heroku")
            cp "$(scriptDirectory)/wallpapers/heroku.png" ~/wallpaper.png
            assertFileExists ~/wallpaper.png "Copied over wallpaper.png asset" "Failed to copy over wallpaper.png asset"
            open ~/
            manualAction "Right click wallpaper.png and select 'Set Desktop Picture'"
            break
            ;;
          "Cancel")
            info "No desktop wallpaper set"
            break
            ;;
          *) warn "Invalid option $REPLY";;
          esac
      done
    else
      warn "This is a MacOS specific step, skipping due to invalid OS..."
    fi
  else
    # Skip this installation section
    info "Skipping..."
  fi
}
