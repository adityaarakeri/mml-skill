# MML concepts: the networked DOM, time, and performance

Read this when you need to reason about *why* something behaves the way it does, or when the
user asks how MML works under the hood.

## The pieces

MML is really two things stacked on top of each other.

1. **The tags.** A schema of `m-*` elements and attributes (`@mml-io/schema`). A renderer
   (`@mml-io/mml-web` with a three.js or PlayCanvas adapter) turns those tags into 3D objects.
   This part is engine-agnostic: game engines can implement the same tags.
2. **Networked DOM.** A server runs the document's HTML plus script in a headless DOM
   (`@mml-io/networked-dom-server`, using `@mml-io/observable-dom`). It watches that DOM for
   mutations, serialises them, and streams them over WebSockets to any number of clients
   (`@mml-io/networked-dom-web`). Clients hold a read-only mirror and forward user events back.

You can use the tags without the network (a static file rendered by the client) and you can use
Networked DOM with plain HTML that has no `m-*` tags at all. MML is the combination.

## Analogy: a shared whiteboard, not a handout

A regular web page is a handout. Every visitor gets their own copy and can scribble on it
without affecting anyone else. That is fine for a blog. It is useless for a game of chess.

An interactive MML document is a whiteboard at the front of a room. One person holds the
marker (the server). Visitors can call out actions ("I clicked the red square", "I walked over
here") and the marker-holder decides what to draw in response. Everybody looks at the same
board, so nobody can be out of sync. Late arrivals see whatever is currently on the board.

The script you write is the marker-holder's rulebook.

## What the script environment actually has

It is a DOM, so:

- `document.getElementById`, `querySelector`, `createElement`, `appendChild`, `remove`,
  `setAttribute`, `getAttribute`, `addEventListener` all work as expected.
- `setTimeout`, `setInterval`, `clearInterval` work.
- `fetch` works, so a document can call external APIs (the weather example does this).
- `document.timeline.currentTime` is the document clock in ms.
- `window` exists and receives `connected` / `disconnected`.

It is not a browser, so:

- No rendering APIs (canvas, WebGL, CSS, layout).
- No `localStorage`, `sessionStorage`, cookies.
- No `requestAnimationFrame`. Use `setInterval` for ticks or, better, `m-attr-anim`.
- No access to the user's screen, input devices, or browser globals.
- Script errors are printed by the server process, not shown in any browser.

State that must survive a document restart has to go somewhere external (a database, a file the
server reads, an API). Variables in the script are reset when the document reloads, which also
happens on every file save during `mml serve` live reload.

## Time

Every client may have joined at a different moment, so "now" is not a wall-clock. The document
clock starts at 0 when the document loads and counts up in milliseconds.
`document.timeline.currentTime` reads it.

Attributes that mention time use this clock:

- `m-attr-anim`: `start-time`, `pause-time`, `duration`
- `m-animation`, `m-model`, `m-character`: `start-time` / `anim-start-time`, `pause-time`
- `m-audio`, `m-video`: `start-time`, `pause-time`

Because clients know the document clock, they can compute an animation's current frame locally.
That is why `m-attr-anim` is cheap: the server sends a handful of attributes once and each
client runs the interpolation itself. Setting `start-time` to `document.timeline.currentTime`
means "start now" for everyone.

If you need wall-clock time (a clock face, a countdown to a real date), use `new Date()` in the
script and push the result into attributes on a `setInterval`. The clock example does exactly
this once per second, which is a fine rate.

## Performance model

Every attribute change and every node add or remove becomes a message to every connected client.
Think in messages per second per client.

Fine:

- A few dozen attribute updates per second across the whole document.
- Adding or removing nodes when state genuinely changes (a cell dies, a player joins).
- `m-attr-anim` / `m-attr-lerp` for anything continuous. Zero ongoing messages.

Bad:

- `setInterval(update, 16)` that touches many elements. That is a 60Hz broadcast.
- Tearing down and rebuilding a grid every tick. Diff your state and only touch what changed.
- Position probes with `interval="10"` on a busy document. Every user reports 100 times a
  second.

The Game of Life example ticks at 200ms and only creates or removes the cubes that changed.
That is a good template for any grid or board.

## Composability

`<m-frame src="...">` embeds another MML document at a position, rotation, and scale. The child
document can be static (https) or interactive (wss) and can be hosted by someone else entirely.
The `min-x` / `max-x` (etc.) bounds clip what the child may render, and `load-range` unloads
distant frames to save resources. This is how a "world" can be made of many independently
owned, independently scaled objects.

## Where documents can run

- **mmleditor.com**: in-browser editor, publishes static documents to an https URL and runs
  interactive ones from your browser tab with a public wss address. Fastest way to share a demo.
- **MML CLI** (`@mml-io/mml-cli`): local server with live reload and a built-in viewer. Use for
  development.
- **Starter project** (`mml-io/mml-starter-project`): a small Express + `express-ws` server you
  own and deploy. Use for production hosting of interactive documents.
- **Any static host**: for documents with no script.
- **Inside a world**: 3D web experiences, game engines, and mml-playground load documents by
  URL. Your document does not need to know about the world; it only sees connections and events.
