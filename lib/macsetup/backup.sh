#!/bin/bash

####################
# Backup Functions #
####################

repoName() {
  local basename_value=""

  basename_value="$(basename "$1")"
  echo "${basename_value%.*}"
}

backupFile() {
  local original_path="$1"
  local new_file_name="$2"
  local date_folder=""
  local suffix=""
  local new_file=""

  mkdir -p "$BACKUP_DIRECTORY"

  if [ ! -f "$original_path" ]; then
    warn "$original_path Does not exist, skipping backup..."
  else
    date_folder="$(date +'%m_%d_%Y')"
    suffix="__$(date +'%s')"
    new_file="$BACKUP_DIRECTORY/$date_folder/$new_file_name$suffix"
    if [ ! -d "$new_file" ]; then
      mkdir -p "$new_file"
    fi

    cp "$original_path" "$new_file"
    if [ -a "$new_file" ]; then
      success "Backed up $original_path to $new_file"
    else
      fail "Failed to backup file $original_path to $new_file"
    fi
  fi
}

backupDir() {
  local original_path="$1"
  local new_directory_name="$2"
  local date_folder=""
  local suffix=""
  local new_dir=""

  mkdir -p "$BACKUP_DIRECTORY"

  if [ ! -d "$original_path" ]; then
    warn "$original_path Does not exist, skipping backup..."
  else
    date_folder="$(date +'%m_%d_%Y')"
    suffix="__$(date +'%s')"
    new_dir="$BACKUP_DIRECTORY/$date_folder/$new_directory_name$suffix"
    if [ ! -d "$new_dir" ]; then
      mkdir -p "$new_dir"
    fi

    cp -r "$original_path" "$new_dir"
    if [ -d "$new_dir" ]; then
      success "Backed up directory $original_path to $new_dir"
    else
      fail "Failed to backup directory $original_path to $new_dir"
    fi
  fi
}

addLineToFiles() {
  local text="$1"
  local files_arr=("${@:2}")
  local file=""

  for file in "${files_arr[@]}"; do
    if [[ $text =~ ^\# ]]; then
      echo "$text (Added by MacSetup)" >> "$file"
    else
      echo "$text" >> "$file"
    fi
  done
}
