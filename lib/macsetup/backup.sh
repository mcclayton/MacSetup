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

  runCommand "Create backup directory $BACKUP_DIRECTORY" mkdir -p "$BACKUP_DIRECTORY" || return 1

  if [ ! -f "$original_path" ]; then
    warn "$original_path Does not exist, skipping backup..."
  else
    date_folder="$(date +'%m_%d_%Y')"
    suffix="__$(date +'%s')"
    new_file="$BACKUP_DIRECTORY/$date_folder/$new_file_name$suffix"
    if [ ! -d "$new_file" ]; then
      runCommand "Create backup destination $new_file" mkdir -p "$new_file" || return 1
    fi

    runCommand "Back up file $original_path" cp "$original_path" "$new_file" || return 1
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

  runCommand "Create backup directory $BACKUP_DIRECTORY" mkdir -p "$BACKUP_DIRECTORY" || return 1

  if [ ! -d "$original_path" ]; then
    warn "$original_path Does not exist, skipping backup..."
  else
    date_folder="$(date +'%m_%d_%Y')"
    suffix="__$(date +'%s')"
    new_dir="$BACKUP_DIRECTORY/$date_folder/$new_directory_name$suffix"
    if [ ! -d "$new_dir" ]; then
      runCommand "Create backup destination $new_dir" mkdir -p "$new_dir" || return 1
    fi

    runCommand "Back up directory $original_path" cp -r "$original_path" "$new_dir" || return 1
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
    ensureLineInFile "$line" "$file" || return 1
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

  runCommand "Ensure editable file exists at $file" touch "$file" || return 1

  if [ -z "$line" ]; then
    return 0
  fi

  if grep -Fqx "$line" "$file"; then
    return 0
  fi

  runCommand "Append managed line to $file" bash -c 'printf "%s\n" "$1" >> "$2"' _ "$line" "$file"
}

removeManagedBlock() {
  local block_name="$1"
  local file="$2"
  local tmp_file=""
  local start_marker="# >>> MacSetup: $block_name"
  local end_marker="# <<< MacSetup: $block_name"

  runCommand "Ensure editable file exists at $file" touch "$file" || return 1
  tmp_file="$(mktemp)"

  runCommand "Remove managed block $block_name from $file" bash -c 'awk -v start="$1" -v end="$2" '"'"'
    $0 == start { skipping = 1; next }
    $0 == end { skipping = 0; next }
    !skipping { print }
  '"'"' "$3" > "$4"' _ "$start_marker" "$end_marker" "$file" "$tmp_file" || {
    rm -f "$tmp_file"
    return 1
  }

  runCommand "Replace managed block file $file" mv "$tmp_file" "$file" || {
    rm -f "$tmp_file"
    return 1
  }
}

ensureManagedBlock() {
  local block_name="$1"
  local file="$2"
  shift 2
  local line=""

  removeManagedBlock "$block_name" "$file" || return 1

  runCommand "Append managed block $block_name to $file" bash -c '
    file="$1"
    block_name="$2"
    shift 2

    {
      printf "%s\n" "# >>> MacSetup: $block_name"
      for line in "$@"; do
        printf "%s\n" "$line"
      done
      printf "%s\n" "# <<< MacSetup: $block_name"
    } >> "$file"
  ' _ "$file" "$block_name" "$@"
}
