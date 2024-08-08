#!/bin/bash

# Set up vim
function runSection {
  promptNewSection "SETTING UP VIM"
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Set up .vim folder
    info "Backing up .vim folder"
    # Backup .vim folder
    backupDir ~/.vim vim

    # Set .vim folder
    info "Setting up .vim folder"
    rm -rf ~/.vim
    cp -r "$(scriptDirectory)/vim" ~/.vim
    assertDirectoryExists ~/.vim "~/.vim directory set" "Failed to set ~/.vim directory"

    # Backup .vimrc
    info "Backing up .vimrc"
    backupFile ~/.vimrc vimrc

    # Set .vimrc
    info "Setting up .vimrc"
    cp "$(scriptDirectory)"/Mac_Dot_Files/vimrc.sh ~/.vimrc
    assertFileExists ~/.vimrc "~/.vimrc set" "Failed to set ~/.vimrc"

    # Clone all vim plugins
    vimPlugins=(
      "git@github.com:vim-airline/vim-airline.git"
      "git@github.com:preservim/nerdtree.git"
      "git@github.com:ervandew/supertab.git"
      "git@github.com:tpope/vim-fugitive.git"
      "git@github.com:airblade/vim-gitgutter.git"
      "git@github.com:junegunn/fzf.git"
      "git@github.com:ryanoasis/vim-devicons.git"
      "git@github.com:rstacruz/vim-closer.git"
      "git@github.com:Eliot00/git-lens.vim.git"
      "git@github.com:Yggdroot/indentLine.git"
      "git@github.com:wfxr/minimap.vim.git" # Requires https://github.com/wfxr/code-minimap
      "git@github.com:bagrat/vim-buffet.git"
    )

    info "Cloning vim plugins"
    for pluginUrl in "${vimPlugins[@]}"; do
      repoName=$(repoName "$pluginUrl")
      cloneToPath=~/".vim/bundle/$repoName"
      rm -rf "$cloneToPath"
      git clone "$pluginUrl" "$cloneToPath"
      # Invoke installation script if exists (i.e. for fzf)
      installPath="$cloneToPath/install"
      if [ -f $installPath ]; then
        echo -e "\n\nInvoking installation for $repoName\n"
        $installPath
      fi
      assertDirectoryExists "$cloneToPath" "$repoName plugin added to $cloneToPath" "Failed to add plugin $repoName to $cloneToPath"
    done
  else
    # Skip this installation section
    info "Skipping..."
  fi
}
