<div align="center">

# mml-skill

### Teach your coding agent to build multiplayer 3D worlds.

**One skill. Four agents. Infinite metaverse.**

[![License: MIT](https://img.shields.io/badge/License-MIT-06d6a0.svg)](LICENSE)
[![MML](https://img.shields.io/badge/MML-0.26.1-4361ee.svg)](https://mml.io)
[![Agents](https://img.shields.io/badge/agents-Claude%20Code%20%7C%20Codex%20%7C%20Antigravity%20%7C%20OpenCode-a78bfa.svg)](#works-with)
[![Upstream drift check](https://img.shields.io/badge/upstream-auto--checked%20weekly-ffd166.svg)](.github/workflows/check-upstream.yml)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-ff5470.svg)](#contributing)

<br>

*"Make me a multiplayer parkour game with a live leaderboard"* → **your agent ships it, validated and running, in one prompt.**

[Quick start](#quick-start) · [What it can do](#what-your-agent-learns-to-build) · [What's inside](#whats-inside) · [How it works](#how-it-works) · [Stay current](#never-goes-stale)

</div>

---

## TL;DR

[MML](https://mml.io) (Metaverse Markup Language) is HTML with 3D tags — `<m-cube>`, `<m-model>`, `<m-label>` — where the `<script>` runs **once, on a server**, and every connected user sees the same live scene. Multiplayer by default. No netcode. Ever.

This skill hands your coding agent everything it needs to build with it: the complete element schema, the event model, battle-tested patterns, scaffolding scripts, and the sharp edges nobody documents.

```bash
git clone https://github.com/adityaarakeri/mml-skill.git
cd mml-skill && scripts/install.sh
```

Restart your agent. Say *"build me a 3D game of life I can run locally."* Done.

---

## Quick start

**1 · Install the skill** (symlinks into every agent's skills folder):

```bash
scripts/install.sh            # global — all projects
scripts/install.sh --project  # just this repo
scripts/install.sh --copy     # copy instead of symlink (Windows-friendly)
```

**2 · Ask your agent for literally anything 3D:**

> - "Make me a Game of Life in MML I can run locally"
> - "Build a parkour course that scores players on completion time"
> - "Add a scoreboard that updates when someone steps on the platform"
> - "Why does my m-model not show up?" *(it knows. it's the light.)*

**3 · Or scaffold by hand:**

```bash
scripts/new-mml-project.sh ~/code/my-scene --example game-of-life
cd ~/code/my-scene && npm run dev     # → http://localhost:7079
```

Open two browser tabs. Click a cube in one. Watch it change in **both**. That's MML.

---

## What your agent learns to build

| You say | Agent ships |
|---|---|
| "a dice I can roll" | GLB model + scripted `m-attr-anim` with bounce easing — physics *feel* with zero physics engine |
| "a shared whiteboard-style game" | Server-authoritative state keyed by `connectionId`, synced to every client automatically |
| "a parkour game with a timer" | Collision-driven checkpoints, `document.timeline` scoring, per-player personal bests, floating leaderboard |
| "a live weather board" | Server-side `fetch` to any API on an interval, pushed into 3D labels |
| "a world people can walk around in" | Full avatar world via `@mml-io/3d-web-experience` — WASD, jump, chat — with jump-distances tuned from **measured** avatar movement |

Every pattern comes from the official examples — annotated with *why* they're shaped that way, including the bugs in the originals (yes, we found them; yes, they're documented).

---

## What's inside

```
mml-skill/
├── SKILL.md                      ← the playbook: workflow, patterns, 13 documented footguns
├── references/
│   ├── elements.md               ← every element & attribute, GENERATED from the official schema
│   ├── events.md                 ← event payloads, connectionId lifecycle, cheat sheet
│   ├── concepts.md               ← the networked DOM model, document time, performance math
│   ├── examples.md               ← all 9 official examples, annotated line by line
│   ├── local-dev.md              ← CLI, starter server, React, viewer, deployment
│   └── avatar-worlds.md          ← avatar worlds, measured jump physics, wire-protocol testing
├── scripts/
│   ├── new-mml-project.sh        ← scaffold: package.json + docs + assets + README
│   ├── install.sh                ← one command, four agents
│   ├── check-upstream.sh         ← drift detector: schema, events, CLI, templates
│   └── generate-elements-reference.py
├── assets/templates/             ← validated starter documents
├── upstream.lock                 ← pinned upstream commit + file hashes
└── .github/workflows/            ← weekly automated drift check
```

### The details that make it world-class

- **Generated, not transcribed** — `elements.md` is built from MML's own `mml.xsd`. Attribute names are *exact* (`font-color`, not `text-color`), because guessing produces scenes that validate and render nothing.
- **13 documented footguns** — the XML-vs-HTML dual-parser trap, the CDATA script wrapper, self-closing tag inheritance bugs, the missing-light black-scene special, Windows glob expansion, orphaned node servers…
- **Measured avatar physics** — jump clears ~0.6 m rise, 2–3 m gaps. Courses designed for a fly-camera are *unplayable* by avatars; this skill knows the difference.
- **Headless game testing** — a recipe for connecting to the Networked DOM wire protocol (`networked-dom-v0.1`) as a fake client: fire events, assert on attribute diffs, CI-test a multiplayer game with no 3D client at all.

---

## How it works

A normal web page is a **handout** — every visitor gets their own copy.
An MML document is a **whiteboard at the front of the room** — one server holds the marker, everyone sees the same board.

```html
<m-cube id="btn" y="0.5" color="red"></m-cube>
<script>//<![CDATA[
  document.getElementById("btn").addEventListener("click", (e) => {
    // runs ON THE SERVER — e.detail.connectionId says who clicked
    e.currentTarget.setAttribute("color", "green");
  });
//]]></script>
```

Click it in Tokyo, it turns green in Toronto. The server diffs the DOM and streams the change to every connected client. **That one idea makes every document multiplayer** — and this skill teaches your agent to think in it natively: state in arrays, DOM as projection, animations as attributes (zero per-frame messages), users as `connectionId`s.

---

## Works with

| Agent | Global install path | Project path |
|---|---|---|
| **Claude Code** | `~/.claude/skills/` | `.claude/skills/` |
| **OpenAI Codex CLI** | `~/.codex/skills/` | `.codex/skills/` |
| **Google Antigravity** | `~/.gemini/antigravity/skills/` | `.agent/skills/` |
| **OpenCode** | `~/.config/opencode/skills/` | `.opencode/skills/` |
| **anything scanning** `~/.agents/skills/` | yes | `.agents/skills/` |

Same `SKILL.md` format everywhere — `install.sh` just puts it in all the right places. Symlinked, so one edit updates every agent.

**Claude.ai**: upload the `SKILL.md` in a chat and hit "Save skill."

---

## Never goes stale

MML is a 0.x project — any minor release can rename attributes. Most skills rot. This one **watches upstream**:

```bash
scripts/check-upstream.sh            # detect drift: schema, events, CLI flags, templates
scripts/check-upstream.sh --accept   # regenerate elements.md, re-pin upstream.lock
```

- Exact upstream commit pinned in [`upstream.lock`](upstream.lock)
- A [GitHub Action](.github/workflows/check-upstream.yml) re-checks **every Monday** and opens an issue on drift
- At runtime, agents compare the live npm version against the lock and warn before trusting the references
- Bundled templates are re-validated against each new CLI — catching *behavioral* changes no file diff would show

---

## The wider MML universe

- [mmleditor.com](https://mmleditor.com) — browser editor, free hosting, community creations to remix
- [`mml-io/3d-web-experience`](https://github.com/mml-io/3d-web-experience) — avatar worlds (the skill covers setup in [`references/avatar-worlds.md`](references/avatar-worlds.md))
- [viewer.mml.io](https://viewer.mml.io) — point it at any document URL, embed anywhere
- Renderers for **three.js**, **PlayCanvas**, and **Unreal Engine** — same tags everywhere

---

## Contributing

Found a footgun that isn't documented? A pattern the skill should teach? A drift the Monday bot missed?

**PRs welcome.** The bar: every claim in the references must be either generated from upstream source or verified by actually running it. No guessed attributes. No untested snippets.

```bash
scripts/check-upstream.sh        # before you PR — make sure you're building on current MML
```

---

## License

[MIT](LICENSE) — take it, ship it, build worlds with it.

<div align="center">
<br>

**Built with the conviction that the open metaverse should be as easy as HTML.**

*If your agent shipped something 3D today, star the repo so others find it.*

</div>
