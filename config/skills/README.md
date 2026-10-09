# Personal skills

Store each skill in its own directory, including `SKILL.md` and any `scripts/`,
`references/`, `assets/`, or `agents/` it needs:

```text
config/skills/
  shared/my-skill/SKILL.md
  claude/claude-only-skill/SKILL.md
  codex/codex-only-skill/SKILL.md
```

The directories start empty. Adding installer support does not import or change
any existing skills on your Mac.

Each `SKILL.md` must begin with YAML frontmatter containing a `name` matching its
directory name and a nonempty `description`. Use lowercase letters, numbers, and
single hyphens in names. Keep supporting file references relative to the skill
directory and commit the complete skill directory to Git.

```markdown
---
name: my-skill
description: Explain the task this skill handles and when to use it.
---

Write the skill instructions here.
```

## Installation

Run `./start.sh` and choose the **SKILLS** section. It offers Both, Claude, Codex,
or Skip. Shared skills are linked for every selected agent; agent-specific skills
are linked only for that agent:

| Agent | Personal skill directory |
| --- | --- |
| Claude Code | `~/.claude/skills/<name>` |
| Codex | `~/.agents/skills/<name>` |

The installer creates individual absolute symlinks to this checkout. Keep the
checkout on disk. Edits through an installed link update the version-controlled
source; review and commit them here. If you move the checkout, rerun the section.
Start a new agent session to verify discovery.

Existing correct links are left alone. Conflicting files, directories, and
symlinks are moved intact into unique folders under
`~/.mac_setup/backups/<date>/skills-<agent>-<name>.*` before replacement. Unrelated
skills are preserved. Removing a source skill does not automatically delete its
installed link; inspect obsolete links manually.

Use distinct names within each agent's installed set. A name appearing in both
`shared/` and that agent's directory is reported as a conflict. Existing skills
in legacy locations such as `~/.codex/skills` are not migrated or removed; inspect
those separately to avoid duplicate discovery.

To use a private checkout with the same shared/claude/codex structure, set
`MACSETUP_SKILLS_DIR` to its root before running the installer. Avoid placing
credentials or confidential work material in a public repository.

## Verification

The installer checks required frontmatter fields and readable link targets; it
does not fully parse YAML or guarantee that agent-specific instructions are
portable. It never executes skill scripts or installs their dependencies.

`bash ci/test_setup_skills.sh` exercises the installer with an isolated home and
temporary skills. These checks also run through `./test.sh checks`.

Supported local discovery locations:
[Claude Code](https://code.claude.com/docs/en/skills) and
[Codex](https://learn.chatgpt.com/docs/build-skills).
