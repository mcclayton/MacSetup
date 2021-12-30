#!/bin/bash

# Set desktop wallpaper
function runSection {
  promptNewSection "SETTING DESKTOP WALLPAPER"
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if isMacOs; then
      PS3='   => Choose Wallpaper: '
      options=("C Street Surf" "Tiki" "Cancel")
      select opt in "${options[@]}"
      do
        case $opt in
          "C Street Surf")
            cp "$(scriptDirectory)/wallpapers/c_street.jpg" ~/wallpaper.jpg
            assertFileExists ~/wallpaper.jpg "Copied over wallpaper.jpg asset" "Failed to copy over wallpaper.jpg asset"
            open ~/
            manualAction "Right click wallpaper.jpg and select 'Set Desktop Picture'"
            break
            ;;
          "Tiki")
            cp "$(scriptDirectory)/wallpapers/tiki.jpg" ~/wallpaper.jpg
            assertFileExists ~/wallpaper.jpg "Copied over wallpaper.jpg asset" "Failed to copy over wallpaper.jpg asset"
            open ~/
            manualAction "Right click wallpaper.jpg and select 'Set Desktop Picture'"
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
