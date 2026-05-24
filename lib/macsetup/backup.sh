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
  local line=""

  line="$(macsetupManagedLine "$text")"

  for file in "${files_arr[@]}"; do
    ensureLineInFile "$line" "$file"
  done
}

macsetupManagedLine() {
  local text="$1"

  if [[ $text =~ ^\# ]]; then
    echo "$text (Added by MacSetup)"
  else
    echo "$text"
  fi
}

ensureLineInFile() {
  local line="$1"
  local file="$2"

  touch "$file"

  if [ -z "$line" ]; then
    return 0
  fi

  if grep -Fqx "$line" "$file"; then
    return 0
  fi

  echo "$line" >> "$file"
}

removeManagedBlock() {
  local block_name="$1"
  local file="$2"
  local tmp_file=""
  local start_marker="# >>> MacSetup: $block_name"
  local end_marker="# <<< MacSetup: $block_name"

  touch "$file"
  tmp_file="$(mktemp)"

  awk -v start="$start_marker" -v end="$end_marker" '
    $0 == start { skipping = 1; next }
    $0 == end { skipping = 0; next }
    !skipping { print }
  ' "$file" > "$tmp_file"

  mv "$tmp_file" "$file"
}

ensureManagedBlock() {
  local block_name="$1"
  local file="$2"
  shift 2
  local line=""

  removeManagedBlock "$block_name" "$file"

  {
    echo "# >>> MacSetup: $block_name"
    for line in "$@"; do
      echo "$line"
    done
    echo "# <<< MacSetup: $block_name"
  } >> "$file"
}
