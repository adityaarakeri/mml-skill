# mml skill

A skill that teaches coding agents (Claude Code, Codex CLI, Antigravity, OpenCode) how to build
and run MML documents. MML is Metaverse Markup Language from mml.io: HTML with 3D tags, plus a
server-side script model that makes every document multi-user by default.

A skill is just a folder with a `SKILL.md` in it. The agent reads the `description` in the
frontmatter to decide when the skill applies, then reads the body and the `references/` files
when it does. All four agents read the same format. They only differ in which folder they look
in, which is what `scripts/install.sh` handles.

## What is in here

```
mml/
  SKILL.md                     the instructions the agent follows
  README.md                    this file
  references/
    elements.md                every element and attribute, generated from the official XSD schema
    events.md                  event types, event.detail payloads, connection lifecycle
    concepts.md                the networked DOM model, document time, performance
    examples.md                the official examples (Game of Life, dice, clock, ...) annotated
    local-dev.md               MML CLI, starter project server, React, viewer, deployment
  scripts/
    new-mml-project.sh         scaffold a local project with dev / validate scripts and a README
    install.sh                 symlink or copy this skill into each agent's skills folder
    check-upstream.sh          detect and absorb upstream MML changes
    generate-elements-reference.py   rebuild elements.md from mml.xsd
  upstream.lock                pinned upstream commit + file hashes
  .github/workflows/           weekly drift check
  assets/templates/
    scene.html                 minimal interactive starter document
    game-of-life.html          Conway's Game of Life, adapted from mml.io/examples
    README.template.md         README written into scaffolded projects
    gitignore
```

`references/elements.md` was produced by `scripts/generate-elements-reference.py` from
`packages/schema/src/schema-src/mml.xsd` in https://github.com/mml-io/mml. Re-run it against a
newer checkout when MML adds elements.

## Install

Clone or copy this folder somewhere permanent (for example `~/skills/mml`), then:

```bash
cd ~/skills/mml
scripts/install.sh            # global: available in every project
scripts/install.sh --project  # only in the current repo (run from the repo root)
scripts/install.sh --copy     # copy instead of symlink
```

That creates a `mml/` entry in each of these:

| agent | global | project |
|---|---|---|
| Claude Code | `~/.claude/skills/` | `.claude/skills/` |
| Codex CLI | `~/.codex/skills/` | `.codex/skills/` |
| Antigravity | `~/.gemini/antigravity/skills/` | `.agent/skills/` |
| OpenCode | `~/.config/opencode/skills/` | `.opencode/skills/` |
| shared | `~/.agents/skills/` | `.agents/skills/` |

The shared `.agents/skills` path is scanned by several tools as well, so it is included as a
fallback. Restart the agent after installing so it re-scans.

If you would rather install by hand, copy the folder into any of those locations. If an agent
uses an `AGENTS.md` or `CLAUDE.md` instead of a skills folder, add a line like
"For MML work, read `<path>/mml/SKILL.md` first."

### Claude.ai

Upload the packaged `mml.skill` file (or the bare `SKILL.md`) in a chat and press "Save skill".

## Using it

Ask the agent for anything MML-related and it should pick the skill up on its own:

- "Make me a Game of Life in MML I can run locally"
- "Add a scoreboard label to this m-group that updates when someone steps on the platform"
- "Why does my m-model not show up?"

To force it: "Use the mml skill to ...".

The scaffold script can also be run directly:

```bash
scripts/new-mml-project.sh ~/code/my-scene --example game-of-life
cd ~/code/my-scene && npm run dev
```

## Keeping it current

MML is 0.x, so any minor release can change tags, attributes, or CLI flags. The skill pins the
exact upstream commit it was built from in `upstream.lock` and ships a drift check:

```bash
scripts/check-upstream.sh            # report; exit 1 if anything upstream changed
scripts/check-upstream.sh --accept   # regenerate elements.md, rewrite upstream.lock
```

It fetches the newest `@mml-io/mml-cli` release, then:

1. Diffs `mml.xsd` and regenerates `references/elements.md` if it changed. Fully automatic.
2. Diffs `events.d.ts` and the CLI README and prints the diff. These feed hand-written files
   (`events.md`, `local-dev.md`, the workflow in `SKILL.md`), so a person reads the diff and
   edits.
3. Reports if the starter project moved.
4. Validates the bundled templates with the new CLI, which catches behavioural changes (like
   the XML root and CDATA rules) that no file diff would show.

`.github/workflows/check-upstream.yml` runs this every Monday and opens an issue with the
output when it fails. Copy it into whatever repo holds the skill.

At runtime the agent also compares the npm version against `upstream.lock` before using the
reference files, and warns the user if they have diverged.

## Prior art

There is an unrelated `mml` skill on skills.sh (from `skills.volces.com/skills/clawhub/honeybee1130`).
It is a single-file cheat sheet whose main reference points at a path on its author's machine.
If you install both, the folder names collide; rename one.

## Sources

- https://mml.io/docs (guides, element and event reference)
- https://mml.io/examples (Game of Life and the other examples)
- https://github.com/mml-io/mml (schema, CLI, web client)
- https://github.com/mml-io/mml-website (source of the docs and examples)
- https://github.com/mml-io/mml-starter-project (Express + WebSocket host)
- https://github.com/mml-io/mml-react-starter-project
