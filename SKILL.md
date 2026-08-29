---
name: mml
description: >
  Build, edit, debug, and run MML (Metaverse Markup Language, mml.io) documents: HTML files that
  describe multi-user 3D scenes using m-cube, m-sphere, m-model, m-label, m-group, m-attr-anim,
  m-position-probe and friends, with server-side script logic that every connected user sees
  at once. Use this skill any time the user mentions MML, mml.io, mmleditor, "networked DOM",
  m-* tags, the MML CLI (mml serve / mml validate), the MML starter project, or wants a
  multiplayer 3D object, interactive 3D web scene, metaverse widget, or a 3D version of a small
  game or simulation (Game of Life, dice, tic tac toe, clock, weather board). Also use it when
  a file contains m-cube, m-model, or similar tags, even if the user never says "MML".
  Covers local dev setup, the element and event reference, animation, collisions, user
  presence, composing documents with m-frame, and React usage.
---

# MML: multi-user 3D documents written as HTML

## What MML actually is

MML is HTML with a set of extra tags that describe 3D things. `<m-cube>` is a box,
`<m-model src="...">` is a glTF model, `<m-label>` is a text panel floating in space. Attributes
are plain strings: `x="2"` moves something two meters along X, `ry="45"` rotates it 45 degrees
around Y, `color="skyblue"` paints it.

The part that makes MML different from A-Frame or three.js is where the script runs. In a normal
web page, JavaScript runs in each visitor's browser, so two people looking at the same page each
have their own private copy. In an interactive MML document the `<script>` runs once, on a
server, against one DOM. Browsers connect over a WebSocket and receive a live mirror of that DOM.
When the script calls `cube.setAttribute("color", "red")`, the server diffs the DOM and pushes
the change to everyone connected. Everyone sees the same red cube at the same moment.

A useful analogy: a normal web page is a printed handout, one copy per person. An MML document is
a whiteboard at the front of the room. One person (the server) holds the marker. Anyone can shout
"click!" or walk up to it, and the server decides what to draw, but there is only ever one board.

Consequences that drive everything else in this skill:

- User actions arrive as events with a `connectionId` in `event.detail`. That id is how you tell
  users apart.
- Script state lives in the document's JavaScript variables on the server. Users can join late
  and see the current DOM, but they do not replay history.
- Browser-only APIs do not exist in the script. There is no `window.innerWidth`, no canvas, no
  `localStorage`, no `requestAnimationFrame`. `setTimeout`, `setInterval`, `fetch`, and the
  standard DOM API do exist.
- The clock is `document.timeline.currentTime`, milliseconds since the document started. Every
  time-based attribute (`start-time`, `pause-time`) is measured on that clock.

## Two kinds of document

**Static**: no `<script>` tag. Just tags. Host it anywhere as a plain `.html` file over
`https://`. Good for props, furniture, signage.

**Interactive**: has a `<script>`. Must run on a server (the MML CLI, the starter project, or
mmleditor.com) and clients connect over `ws://` or `wss://`. Anything that reacts to users or
changes over time is interactive.

Pick static when nothing needs to change. Pick interactive otherwise. Do not add a script to a
document that does not need one, because it forces a server where a CDN would have done.

## Workflow

1. **Read the reference you need before writing tags.** Attribute names are specific (`font-color`
   not `text-color`, `cast-shadows` not `shadow`, `rx` not `rotation-x`) and guessing produces
   documents that validate but render nothing. Open `references/elements.md` for the element you
   are about to use. Open `references/events.md` for anything involving clicks, collisions,
   prompts, or user position.
2. **Decide static vs interactive** (above).
3. **Scaffold a local project** if the user does not already have one. Run
   `scripts/new-mml-project.sh <dir>` or follow `references/local-dev.md`. The scaffold gives them
   `npm run dev` (live-reloading server at http://localhost:7079), `npm run validate`, a
   `documents/` folder, an `assets/` folder for models and images, and a README.
4. **Write the document.** Wrap everything in a single `<body>` root, scene tags first, one
   `<script>` at the end. Give every element you will touch from script an `id`. Wrap related
   elements in `<m-group>` so you can move or rotate them as one unit. Open the script with
   `<script>//<![CDATA[` and close it with `//]]></script>`. Reason: `mml validate` parses the
   file as XML, so a bare `<` or `&&` inside the script is a parse error, while the CDATA
   wrapper is invisible to the JavaScript engine because of the `//` comments. The templates in
   `assets/templates/` already have this shape.
5. **Validate**: `npx @mml-io/mml-cli validate documents/<file>.html`. Fix every error. The
   validator checks tags and attributes against the official schema, so an unknown attribute is a
   real bug, not a style nit.
6. **Serve and look at it**: `npx @mml-io/mml-cli serve documents/<file>.html`, then open
   http://localhost:7079. Open a second tab to confirm multi-user behaviour (a click in one tab
   should show in the other).
7. **Hand it over with a README** that explains how to run it, what each file is, and how to
   deploy (static file, or `mml serve` / starter project behind a WebSocket-capable host).

## Coordinate system and units, memorise these

- Y is up. The ground plane is y=0. A default cube is 1m on each side and centred on its
  position, so a cube at `y="0"` is half buried. Use `y="0.5"` to sit it on the floor.
- Positions are meters. Rotations are degrees, applied as Euler XYZ. Scale is a multiplier.
- `m-label` `font-size` and `padding` are in centimeters, not meters.
- Children are positioned relative to their parent. An `<m-group x="5">` shifts every child by 5.
- Default camera in the viewer is at `0,5,10` looking toward the origin, so put your scene near
  the origin, roughly between x -5..5, y 0..5, z -5..5, or it will be off screen.
- Positive Z points toward the default camera (out of the screen). Negative Z is "away".
- Always include an `<m-light>`. Shapes use lit materials, and the CLI's built-in client adds
  no light of its own, so an unlit document renders as black silhouettes there. (viewer.mml.io
  adds an ambient light, which is why the official examples look fine without one.)
  `type="point"` and `type="spotlight"` are the two options; something like
  `<m-light type="point" intensity="400" x="6" y="12" z="10">` is a reasonable default.

## Patterns you will reuse

**Change something on click**

```html
<m-cube id="btn" y="0.5" color="red"></m-cube>
<script>//<![CDATA[
  // (CDATA wrapper omitted in the shorter snippets below; keep it in real files)
  document.getElementById("btn").addEventListener("click", (e) => {
    // e.detail.connectionId tells you who clicked
    e.currentTarget.setAttribute("color", "green");
  });
//]]></script>
```

`onclick="fn()"` as an attribute also works and is what the official examples use.

**Grid or board of cells (the Game of Life shape)**

Keep the game state in a plain array. Keep one element per visible cell, with an `id` derived
from its coordinates. On each tick, compute the next state, then create elements for cells that
became alive and `.remove()` elements for cells that died. Never rebuild the whole grid every
tick: removing and re-adding hundreds of nodes each frame floods every client with DOM diffs.
Full annotated version in `references/examples.md`.

```js
function createCube(x, y) {
  const cube = document.createElement("m-cube");
  cube.setAttribute("x", (x - worldSize / 2) * cellSize);
  cube.setAttribute("y", y * cellSize + 1);
  cube.setAttribute("id", x + ":" + y);
  document.body.appendChild(cube);
}
```

**Smooth motion without a tick loop**

Do not animate by calling `setAttribute("ry", angle)` every 16ms. Each call is a network message
to every client. Instead use `<m-attr-anim>` (document-time animation, runs on each client) or
`<m-attr-lerp>` (smoothly transitions any attribute change you make from script):

```html
<m-model src="/assets/duck.glb">
  <m-attr-anim attr="ry" start="0" end="360" duration="3000"></m-attr-anim>
</m-model>

<m-cube id="mover">
  <m-attr-lerp attr="x,y" duration="500" easing="easeInOutCubic"></m-attr-lerp>
</m-cube>
```

With the lerp in place, `mover.setAttribute("x", 3)` glides instead of jumping.

**One-shot animation from script (dice roll, door open)**

Set `start-time` to `document.timeline.currentTime`, set `start` and `end`, set `loop="false"`.
Restarting an animation means setting a new `start-time`. See the dice example in
`references/examples.md`.

**Know who is standing where**

`<m-position-probe range="7" interval="100">` fires `positionenter`, `positionmove`,
`positionleave` with the user's position relative to the probe. For "stepped on a platform" use
`collision-interval="100"` on a solid element and listen for `collisionstart` / `collisionend`.

Caveat: collision events come from a client that has an avatar walking on things. The MML CLI's
built-in preview client is a fly-camera with no avatar, so `collision*` never fires there (only
in avatar worlds like 3d-web-experience). For anything that must also work in the local preview
— platform games, floor triggers — register a `click` listener on the same element as a
fallback, and say so in the UI ("click the pad"). Same script path, both clients playable.

Always also listen for `window` `disconnected` and clean up anything keyed by that
`connectionId`, otherwise ghosts accumulate.

**Ask the user for text**

`<m-prompt message="Your name?">` wraps a clickable child. Clicking opens a text box on the
client; the answer arrives as a `prompt` event with `e.detail.value`.

**Reuse another document**

`<m-frame src="wss://host/doc">` embeds a whole other MML document, static or interactive, and
transforms it as a unit. This is how large worlds are assembled from independently hosted parts.

## Things that go wrong

- Nothing renders: Usually the scene is outside the camera's view, or a model URL is wrong
  and the asset never loads. Add a `<m-cube color="red" y="0.5">` at the origin as a sanity
  check. Check the browser devtools network tab for 404s on `.glb` files.
- Attribute silently ignored: Misspelled attribute. Run `mml validate`.
- Everything is half underground: Cubes are centred on their origin. Lift by half the height.
- Clicks do nothing on a model: The click listener is on the wrong element, or the element
  has `clickable="false"`. Attach to the element the user actually hits.
- Users leave but their marker stays: Missing `disconnected` handler.
- Script errors: They show up in the terminal running `mml serve`, not in the browser.
- CORS on assets: Serve local assets through `--assets ./assets` (they appear at `/assets/`).
- Jitter: Too many `setAttribute` calls per second. Switch to `m-attr-anim` or `m-attr-lerp`,
  or lower the tick rate.
- `npm run validate` fails on Windows with "File not found: documents\\*.html": cmd.exe does
  not expand globs, so `mml validate documents/*.html` passes the literal `*` through. List the
  files explicitly (`mml validate documents/scene.html documents/other.html`) or run the command
  from git-bash. The scaffold's package.json has this problem on Windows.
- `mml validate` says "Extra content at the end of the document": More than one top-level
  element. Wrap the whole file in `<body>...</body>` (or one `<m-group>`). If you use `<html>`,
  the validator also insists on a `<head>` before `<body>`.
- `mml validate` rejects `easing="linear"`: The schema enum has no "linear" value; leave the
  attribute off for linear (that is the default). The official dice example uses it anyway and
  runs, because the server ignores the validator. Do not copy that.
- Self-closing tags: `<m-cube y="1"/>` passes the validator (XML) but the HTML parser on the
  server does not close it, so every element after it becomes its child and inherits its
  transform. Always write `<m-cube></m-cube>`.
- `mml validate` says "StartTag: invalid element name" or "xmlParseEntityRef": A `<`, `>`
  or `&` inside the script. Use the `//<![CDATA[` ... `//]]>` wrapper.
- The document runs but validate fails, or vice versa: The server parses as HTML, the
  validator as XML. Documents that satisfy both are the ones shaped like the templates: one
  root, CDATA-wrapped script, every tag closed explicitly.

## Wider ecosystem, when the user asks

- `@mml-io/mml-web-runner`: runs an interactive document entirely in the browser (no server),
  useful for demos and for mmleditor-style live previews. Multi-user needs the real server.
- `mml-io/3d-web-experience`: a full avatar-based world (client + server) that loads MML
  documents by URL. Use it when the user wants people walking around, not just a viewer.
  Setup, world.json format, avatar movement envelope (jump ~0.6m rise, ~2-3m gaps), and a
  no-browser protocol testing recipe are in `references/avatar-worlds.md`.
  The published `@mml-io/3d-web-experience` npm package includes a CLI
  (`npx 3d-web-experience serve world.json --port 8085`) that serves a complete avatar world
  from a small `world.json` — no repo clone or build. Setup, world.json shape, avatar-scale
  course design (jump ≈ 1–1.5 m up / 2–3 m across), and the pointer-lock caveat for embedded
  webviews are in `references/local-dev.md`.
- `mml-io/mml-playground`: a hosted world with slots where anyone can plug in a document by its
  WebSocket URL. Good for showing work to others.
- Documents can call any HTTP API with `fetch`, including LLM APIs; the mml.io blog has an
  AI-powered NPC example built this way. Keep keys server-side (env vars in the starter
  project), never in the document source.
- Unreal Engine and PlayCanvas renderers exist; the tags are the same, so a document written
  for the web viewer works there.

## When the user is using React

Point them at `mml-io/mml-react-starter-project`. MML tags are used directly in JSX
(`<m-cube x={1} color="red" onClick={fn} />`), state goes in hooks, and the same server-side
model applies: the React tree is rendered into the networked DOM on the server, not in the
browser. Details in `references/local-dev.md`.

## Before trusting this skill's reference files

This skill was written against MML `0.26.1` (see `upstream.lock`). MML is a 0.x project, so a
minor version bump may rename or remove attributes. At the start of any MML task, run
`npm view @mml-io/mml-cli version` and compare with `cli_npm_version` in `upstream.lock`. If
they differ, tell the user the skill may be stale, prefer `npx @mml-io/mml-cli validate` over
`references/elements.md` as the source of truth for attribute names, and suggest they run
`scripts/check-upstream.sh --accept` to refresh the generated reference.

## Reference files

- `references/elements.md`: every element with every attribute, generated from the official
  schema. Read the section for each element you use.
- `references/events.md`: event types, what is in `event.detail`, connection lifecycle.
- `references/concepts.md`: the networked DOM model in more depth, timing, performance notes.
- `references/examples.md`: the official examples (Game of Life, dice, clock, tic tac toe,
  weather, video player, collisions, position probe) with commentary on what each teaches.
- `references/local-dev.md`: MML CLI, starter project server, React project, the hosted viewer,
  deployment notes.
- `references/avatar-worlds.md`: 3d-web-experience avatar worlds (world.json, controls,
  course design for real jumps), Networked DOM wire-protocol testing, Windows pitfalls.
- `references/headless-testing.md`: verify a running document without a browser — raw
  `networked-dom-v0.1` WebSocket client (stdlib Python included), synthetic events, asserting
  on `attributeChange` diffs. Use it to prove game logic and multi-user state actually work.
- `assets/templates/`: files the scaffold script copies into a new project. Includes
  `parkour.html` — a validated timed-course game (ordered checkpoints, per-connectionId runs
  and personal bests, top-5 leaderboard, dual collision+click triggers, avatar-scale platform
  spacing). Copy and reshape it for any race/checkpoint/score-by-time game.
- `upstream.lock` and `scripts/check-upstream.sh`: which upstream commit this was built from,
  and a script that detects and (with `--accept`) absorbs upstream changes.

## When handing code to the user

The user has a standing preference: any code you produce should be treated as the start of real
local development, and it should ship with a README. So do not paste a bare snippet and stop.
Produce the `.html` document, a `package.json` with `dev` and `validate` scripts, and a README
that explains what the document does, how to run it locally, how to deploy it, and where the
knobs are (grid size, tick rate, colors). The scaffold script does most of this for you.
