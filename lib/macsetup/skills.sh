#!/bin/bash

# Lightweight checks for the shared frontmatter fields; not a full YAML parser.
validateSkill() {
  local skill_dir="$1"
  local name="${skill_dir##*/}"

  if [[ ! $name =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || [ ! -r "$skill_dir/SKILL.md" ]; then
    fail "Invalid skill $skill_dir: expected a valid directory name and readable SKILL.md"
    return 1
  fi

  if ! awk -v expected="$name" '
    { sub(/\r$/, "") }
    NR == 1 { if ($0 != "---") exit 1; next }
    $0 == "---" { closed = 1; exit }
    /^name:[[:space:]]*/ {
      value = $0
      sub(/^name:[[:space:]]*/, "", value)
      sub(/[[:space:]]+$/, "", value)
      gsub(/^[\047\042]|[\047\042]$/, "", value)
      named = (value == expected)
    }
    /^description:[[:space:]]*/ {
      value = $0
      sub(/^description:[[:space:]]*/, "", value)
      sub(/[[:space:]]+$/, "", value)
      described = (value != "" && value != "\042\042" && value != "\047\047" && value !~ /^#/)
    }
    END { if (!closed || !named || !described) exit 1 }
  ' "$skill_dir/SKILL.md"; then
    fail "Invalid frontmatter in $skill_dir/SKILL.md: require matching name and description"
    return 1
  fi
}

linkSkill() {
  local source_dir="$1"
  local destination="$2"
  local agent="$3"
  local backup_dir=""

  if [ -L "$destination" ] && [ "$(readlink "$destination")" = "$source_dir" ]; then
    info "Skill unchanged: $agent/${destination##*/}"
    SKILLS_UNCHANGED=$((SKILLS_UNCHANGED + 1))
    return 0
  fi

  if [ -e "$destination" ] || [ -L "$destination" ]; then
    if ! mkdir -p "$BACKUP_DIRECTORY/$(date +'%m_%d_%Y')"; then
      fail "Cannot create backup directory for $destination"
      return 1
    fi
    backup_dir="$(mktemp -d "$BACKUP_DIRECTORY/$(date +'%m_%d_%Y')/skills-$agent-${destination##*/}.XXXXXX")" || {
      fail "Cannot allocate backup for $destination"
      return 1
    }
    if ! mv "$destination" "$backup_dir/"; then
      fail "Cannot back up $destination; leaving it untouched"
      return 1
    fi
    success "Backed up $destination to $backup_dir"
  fi

  if ! ln -s "$source_dir" "$destination"; then
    fail "Cannot link skill $destination"
    return 1
  fi
  if [ ! -r "$destination/SKILL.md" ]; then
    fail "Installed skill is not readable: $destination/SKILL.md"
    return 1
  fi
  success "Skill installed: $agent/${destination##*/}"
  SKILLS_INSTALLED=$((SKILLS_INSTALLED + 1))
}

setupSkillsForAgent() {
  local root="$1"
  local agent="$2"
  local destination_root="$HOME/.claude/skills"
  local group=""
  local skill_dir=""
  local name=""

  if [ "$agent" = codex ]; then
    destination_root="$HOME/.agents/skills"
  fi
  if ! mkdir -p "$destination_root"; then
    fail "Cannot create $agent skill directory: $destination_root"
    SKILLS_FAILED=$((SKILLS_FAILED + 1))
    return 1
  fi

  for group in shared "$agent"; do
    for skill_dir in "$root/$group"/*; do
      [ -d "$skill_dir" ] || continue
      name="${skill_dir##*/}"
      if [ "$group" != shared ] && [ -d "$root/shared/$name" ]; then
        fail "Duplicate $agent skill $name in shared/ and $agent/; keeping the shared skill"
        SKILLS_FAILED=$((SKILLS_FAILED + 1))
        continue
      fi
      if ! validateSkill "$skill_dir" || ! linkSkill "$skill_dir" "$destination_root/$name" "$agent"; then
        SKILLS_FAILED=$((SKILLS_FAILED + 1))
      fi
    done
  done
}

setupSkills() {
  local selection="$1"
  local root="${MACSETUP_SKILLS_DIR:-$MACSETUP_CONFIG_DIR/skills}"
  SKILLS_INSTALLED=0
  SKILLS_UNCHANGED=0
  SKILLS_FAILED=0

  case "$selection" in
    both|claude|codex) ;;
    *) fail "Unknown skills selection: $selection"; return 1 ;;
  esac
  if ! root="$(cd "$root" 2>/dev/null && pwd -P)"; then
    fail "Skills source directory does not exist"
    return 1
  fi

  if [ "$selection" = both ] || [ "$selection" = claude ]; then
    setupSkillsForAgent "$root" claude || true
  else
    info "Skipping Claude skills"
  fi
  if [ "$selection" = both ] || [ "$selection" = codex ]; then
    setupSkillsForAgent "$root" codex || true
  else
    info "Skipping Codex skills"
  fi
  info "Skills summary: $SKILLS_INSTALLED installed, $SKILLS_UNCHANGED unchanged, $SKILLS_FAILED failed"
  [ "$SKILLS_FAILED" -eq 0 ]
}
