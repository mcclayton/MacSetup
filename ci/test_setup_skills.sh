#!/bin/bash

set -euo pipefail

repo_root="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd "$repo_root"
tmp_root="$(mktemp -d)"
trap 'rm -rf "$tmp_root"' EXIT
export HOME="$tmp_root/home"
export MACSETUP_SKILLS_DIR="$tmp_root/Skills With Spaces"
mkdir -p "$HOME" "$MACSETUP_SKILLS_DIR"/{shared,claude,codex}
MACSETUP_SKILLS_DIR="$(cd "$MACSETUP_SKILLS_DIR" && pwd -P)"
source ./lib/macsetup/constants.sh
source ./lib/macsetup/helperFunctions.sh
source ./sections/setup_skills.sh

makeSkill() {
  local path="$MACSETUP_SKILLS_DIR/$1"
  mkdir -p "$path/references"
  printf '%s\n' '---' "name: ${path##*/}" 'description: A test skill.' '---' 'Instructions.' > "$path/SKILL.md"
  printf '%s\n' 'Supporting content' > "$path/references/guide.md"
}

echo "Checking empty skills installation..."
setupSkills both
test "$SKILLS_INSTALLED" -eq 0

makeSkill shared/example
makeSkill claude/claude-only
makeSkill codex/codex-only
mkdir -p "$HOME/.claude/skills/unrelated"
printf 'keep me\n' > "$HOME/.claude/skills/unrelated/file"

echo "Checking shared and agent-specific skills..."
setupSkills both
test "$SKILLS_INSTALLED" -eq 4
test -r "$HOME/.claude/skills/example/references/guide.md"
test -r "$HOME/.agents/skills/example/references/guide.md"
test -L "$HOME/.claude/skills/claude-only"
test -L "$HOME/.agents/skills/codex-only"
test ! -e "$HOME/.claude/skills/codex-only"
test ! -e "$HOME/.agents/skills/claude-only"
test "$(cat "$HOME/.claude/skills/unrelated/file")" = 'keep me'

echo "Checking edits reach both agents and reruns create no backups..."
printf 'updated\n' >> "$HOME/.claude/skills/example/references/guide.md"
cmp "$MACSETUP_SKILLS_DIR/shared/example/references/guide.md" "$HOME/.agents/skills/example/references/guide.md"
setupSkills both
test "$SKILLS_INSTALLED" -eq 0
test "$SKILLS_UNCHANGED" -eq 4
test ! -e "$BACKUP_DIRECTORY"

echo "Checking backups preserve directories, files, and dangling links..."
makeSkill claude/directory-conflict
makeSkill claude/file-conflict
makeSkill claude/link-conflict
mkdir -p "$HOME/.claude/skills/directory-conflict/nested"
printf original > "$HOME/.claude/skills/directory-conflict/nested/file"
printf original > "$HOME/.claude/skills/file-conflict"
ln -s "$tmp_root/missing-target" "$HOME/.claude/skills/link-conflict"
setupSkills claude
test "$SKILLS_INSTALLED" -eq 3
backup_date="$BACKUP_DIRECTORY/$(date +'%m_%d_%Y')"
for backup in "$backup_date"/skills-claude-directory-conflict.*; do
  test "$(cat "$backup/directory-conflict/nested/file")" = original
done
for backup in "$backup_date"/skills-claude-file-conflict.*; do
  test "$(cat "$backup/file-conflict")" = original
done
for backup in "$backup_date"/skills-claude-link-conflict.*; do
  test "$(readlink "$backup/link-conflict")" = "$tmp_root/missing-target"
done

echo "Checking agent selection leaves the other agent untouched..."
makeSkill shared/selected
setupSkills codex
test -L "$HOME/.agents/skills/selected"
test ! -e "$HOME/.claude/skills/selected"

echo "Checking validation failures continue to independent skills..."
mkdir -p "$MACSETUP_SKILLS_DIR/claude/bad"
makeSkill claude/bad-name
printf '%s\n' '---' 'name: wrong-name' 'description: Invalid.' '---' > "$MACSETUP_SKILLS_DIR/claude/bad-name/SKILL.md"
makeSkill claude/bad-description
printf '%s\n' '---' 'name: bad-description' 'description: ""' '---' > "$MACSETUP_SKILLS_DIR/claude/bad-description/SKILL.md"
makeSkill claude/example
makeSkill claude/valid-after-failures
if setupSkills claude; then
  echo 'Expected invalid and duplicate skills to fail' >&2
  exit 1
fi
test "$SKILLS_FAILED" -eq 4
test ! -e "$HOME/.claude/skills/bad"
test ! -e "$HOME/.claude/skills/bad-name"
test ! -e "$HOME/.claude/skills/bad-description"
test "$(readlink "$HOME/.claude/skills/example")" = "$MACSETUP_SKILLS_DIR/shared/example"
test -L "$HOME/.claude/skills/valid-after-failures"

echo "Checking failed backup does not overwrite existing content..."
makeSkill codex/backup-failure
printf original > "$HOME/.agents/skills/backup-failure"
mv() { return 1; }
if setupSkills codex; then
  echo 'Expected backup failure to fail setup' >&2
  exit 1
fi
unset -f mv
test "$(cat "$HOME/.agents/skills/backup-failure")" = original
test ! -L "$HOME/.agents/skills/backup-failure"
test "$SKILLS_FAILED" -eq 1

echo "Checking section menu and skip behavior..."
MACSETUP_UI=plain
runSection <<< $'y\n4' > "$tmp_root/skip-output"
grep -q 'Skipping skills setup' "$tmp_root/skip-output"
runSection <<< 'n' > "$tmp_root/skip-section-output"
grep -q 'Skipping skills setup' "$tmp_root/skip-section-output"

echo "Skills installer checks passed."
