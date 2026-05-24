#!/bin/bash

# Set up vim
function runSection {
  runPromptedSection "SETTING UP VIM" setupVim
}

setupVim() {
  # Set up .vim folder
  info "Backing up .vim folder"
  # Backup .vim folder
  backupDir ~/.vim vim

  # Set .vim folder
  info "Setting up .vim folder"
  runCommand "Remove existing ~/.vim directory" rm -rf ~/.vim || return 1
  runCommand "Copy vim assets" cp -r "$MACSETUP_ASSETS_DIR/vim" ~/.vim || return 1
  assertDirectoryExists ~/.vim "~/.vim directory set" "Failed to set ~/.vim directory"
  assertFileExists ~/.vim/autoload/pathogen.vim "pathogen.vim set" "Failed to set pathogen.vim"
  assertFileExists ~/.vim/colors/atom_one_dark.vim "Atom One Dark colorscheme set" "Failed to set Atom One Dark colorscheme"
  runCommand "Create vim bundle directory" mkdir -p ~/.vim/bundle || return 1

  # Backup .vimrc
  info "Backing up .vimrc"
  backupFile ~/.vimrc vimrc

  # Set .vimrc
  info "Setting up .vimrc"
  runCommand "Copy vimrc" cp "$MACSETUP_CONFIG_DIR"/dotfiles/mac/vimrc.sh ~/.vimrc || return 1
  assertFileExists ~/.vimrc "~/.vimrc set" "Failed to set ~/.vimrc"

  # Clone all vim plugins
  vimPlugins=(
    "https://github.com/vim-airline/vim-airline.git"
    "https://github.com/preservim/nerdtree.git"
    "https://github.com/ervandew/supertab.git"
    "https://github.com/tpope/vim-fugitive.git"
    "https://github.com/airblade/vim-gitgutter.git"
    "https://github.com/junegunn/fzf.git"
    "https://github.com/ryanoasis/vim-devicons.git"
    "https://github.com/rstacruz/vim-closer.git"
    "https://github.com/Eliot00/git-lens.vim.git"
    "https://github.com/Yggdroot/indentLine.git"
    "https://github.com/wfxr/minimap.vim.git" # Requires https://github.com/wfxr/code-minimap
    "https://github.com/bagrat/vim-buffet.git"
    "https://github.com/neoclide/coc.nvim.git"
    "https://github.com/osyo-manga/vim-anzu.git"
    "https://github.com/haya14busa/is.vim.git"
  )

  info "Cloning vim plugins"
  for pluginUrl in "${vimPlugins[@]}"; do
    repoName=$(repoName "$pluginUrl")
    cloneToPath=~/".vim/bundle/$repoName"
    runCommand "Remove existing vim plugin $repoName" rm -rf "$cloneToPath" || continue
    if [ "$repoName" = "coc.nvim" ]; then
      runCommand "Clone vim plugin $repoName" git clone --branch release "$pluginUrl" "$cloneToPath" || continue
    else
      runCommand "Clone vim plugin $repoName" git clone "$pluginUrl" "$cloneToPath" || continue
    fi
    # Invoke installation script if exists (i.e. for fzf)
    installPath="$cloneToPath/install"
    if [ -f "$installPath" ]; then
      echo -e "\n\nInvoking installation for $repoName\n"
      runInteractiveCommand "Run vim plugin installer for $repoName" "$installPath" || continue
    fi
    assertDirectoryExists "$cloneToPath" "$repoName plugin added to $cloneToPath" "Failed to add plugin $repoName to $cloneToPath"
  done
}
