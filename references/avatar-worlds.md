# Avatar worlds: 3d-web-experience and playable MML games

Read this when the user wants a controllable character (an "action figure"), a playable game,
or avatar-based multiplayer — anything beyond the MML CLI's fly-camera viewer.

## The quick path: the published CLI

`@mml-io/3d-web-experience` ships a CLI that serves a full avatar world (rigged humanoid with
idle/jog/run/jump/double-jump animations, WASD + Space + Shift controls, mouse-look, optional
text chat) from a single JSON config. No monorepo build needed:

```bash
mkdir world && cd world
npm init -y && npm install @mml-io/3d-web-experience
mkdir mml-documents            # auto-detected; put your MML documents here
npx 3d-web-experience serve world.json --port 8085
```

`world.json`:

```json
{
  "chat": true,
  "auth": { "allowAnonymous": true },
  "loadingScreen": {
    "title": "My World", "subtitle": "Powered by MML",
    "background": "linear-gradient(135deg, #0b0e14, #16213e)", "color": "#ffffff"
  },
  "hud": false,
  "mmlDocuments": {
    "game.html": {
      "url": "ws:///mml-documents/game.html",
      "position": { "x": 0, "y": 0, "z": 0 }
    }
  }
}
```

- `ws:///mml-documents/<file>` (empty host) means "this same server"; the server runs its own
  Networked DOM host for each document in `mml-documents/`.
- The server watches `world.json` AND the documents; edits hot-reload (script state resets).
- Every browser tab is a separate avatar and a separate `connectionId`. Two tabs = two players.
- `--host 0.0.0.0` exposes it on the LAN for real multiplayer across devices.
- The full monorepo (`mml-io/3d-web-experience` on GitHub) has richer examples:
  `example/multi-user-3d-web-experience` (client+server you own), `local-only` variant, and
  `bridge-bots` (a headless programmatic avatar client — useful for NPC/ghost runners).

## Designing MML courses for avatars (measured, not guessed)

The reference avatar's movement envelope (defaults, 0.28.x):

- Single jump: reliably clears ~0.6m of height gain per platform step.
- Horizontal gap: keep consecutive platform centers within ~2–3m; the avatar jog + jump covers
  that comfortably. Sprint extends it slightly.
- Platforms sized 1.2m+ square are landable; smaller gets frustrating.
- A course written for the fly-camera viewer (where users click, not jump) will usually be
  UNPLAYABLE by an avatar. Retune spacing when moving a scene into a world.

Gameplay wiring that works:

- Detect "stood on" with `collision-interval="150"` + `collisionstart` per platform. Also add a
  `click` listener on the same platform so the document remains testable in the fly-camera
  viewer (no avatar there, so no collisions — clicks are the fallback).
- Time runs with `document.timeline.currentTime`; per-player state in a `Map` keyed by
  `event.detail.connectionId`; clean up in a `window` `disconnected` handler.
- The camera/avatar position is encoded in the page URL hash in the reference client — handy
  for debugging "where am I".

## Pointer lock caveat (embedded webviews)

The avatar camera uses the Pointer Lock API. Embedded webviews (in-app preview panes, some
iframes) often deny pointer lock: WASD works but mouse-look does not. That is an environment
limitation, not a bug. Open the world in a real browser tab for full controls.

## Testing interactive documents without a browser

A Networked DOM server speaks a simple JSON protocol over WebSocket (subprotocol
`networked-dom-v0.1`). You can connect as a fake client to smoke-test game logic:

1. Connect to `ws://host:port/<document>` with subprotocol `networked-dom-v0.1`.
2. First messages are JSON arrays; one contains `{"type":"snapshot","snapshot":...}` — the
   whole DOM tree with `nodeId`s and attributes. Walk it to map element ids to nodeIds.
3. Send events: `{"type":"event","nodeId":<n>,"name":"click","bubbles":true,"params":{...}}`.
   `collisionstart` etc. work the same way (`params.position` = `{x,y,z}`).
4. The server answers with `{"type":"attributeChange",...}` diffs — assert on those.

This is how to verify "player finishes course -> leaderboard updates" in CI without a 3D
client. Python stdlib is enough (raw socket + RFC6455 framing) if websocket libs are absent.

## Windows notes

- cmd.exe does not expand globs: `mml validate documents/*.html` fails. List files explicitly.
- Killing a backgrounded `npx ... serve` often kills only the wrapper; the node child keeps
  the port. Find it with `netstat -ano | grep :PORT`, kill the tree with
  `taskkill -F -T -PID <pid>`, verify with curl.
- The 3d-web-experience monorepo pins pnpm via devEngines; npm commands run from inside that
  repo tree fail with EBADDEVENGINES. Run npm elsewhere (the published package needs no build).