# MML events reference

Source: `events.d.ts` in the official `@mml-io/schema` package, plus the collision events guide on
mml.io. Everything below runs in the document's server-side script.

## How events reach your script

A user clicks, walks into range, or types into a prompt in their browser. The client sends that
action over the WebSocket to the server. The server dispatches a normal DOM `Event` on the
element (or on `window` for connection events). You handle it with `addEventListener` or an
`on*` attribute, exactly like browser HTML.

Two ways to listen, both fine:

```html
<m-cube onclick="handleClick(event)"></m-cube>
<script>
  function handleClick(e) { /* ... */ }
  // or
  document.getElementById("x").addEventListener("click", (e) => { /* ... */ });
</script>
```

Every user-originated event extends `RemoteEvent`, so `event.detail` always includes:

| field | type | meaning |
|---|---|---|
| `connectionId` | number | Unique numeric id of the connection that sent the event. Stable for the life of that connection. This is your user key. |
| `connectionToken` | string or null | Optional token the user supplied when connecting. Depends on the hosting world; often null. |

## Connection lifecycle (on `window`)

| event | when |
|---|---|
| `connected` | A client connected. `detail.connectionId` is the new id. |
| `disconnected` | A client went away. Clean up anything you stored under that `connectionId`. |

```js
const users = new Map();
window.addEventListener("connected", (e) => users.set(e.detail.connectionId, {}));
window.addEventListener("disconnected", (e) => users.delete(e.detail.connectionId));
```

A user who is already in range when the document restarts can produce `positionmove` or
`collisionmove` without a preceding enter event. Write handlers so that move creates state if it
is missing.

## Element events

### `click` (MMLClickEvent)

Fires on elements with the `clickable` group: cube, sphere, cylinder, plane, model, character,
image, video, label, and anything wrapped in `m-link` or `m-prompt`.

`detail.position`: `{x, y, z}` where the click hit, relative to the element's origin. Useful for
"which part of the board did they click".

Set `clickable="false"` to let clicks pass through an element.

### `collisionstart`, `collisionmove`, `collisionend`

Only fire if the element has `collision-interval="<ms>"` set. Without it, no collision events
are sent at all. The interval controls how often the client reports while colliding; 100ms is a
common value. Smaller means more messages.

- `collisionstart` and `collisionmove`: `detail.position` `{x, y, z}` relative to the element.
- `collisionend`: only `connectionId`.

Attribute forms: `oncollisionstart`, `oncollisionmove`, `oncollisionend`.

`collide="false"` removes an element from physics entirely (users walk through it and it never
reports collisions).

### `positionenter`, `positionmove`, `positionleave` (m-position-probe)

`<m-position-probe range="10" interval="1000">` asks clients within `range` meters to report
their position every `interval` ms.

`detail.elementRelative` and `detail.documentRelative` each contain
`{ position: {x,y,z}, rotation: {x,y,z} }`. Rotation is Euler XYZ in degrees. Use
`elementRelative` when placing markers inside the probe's parent group; use `documentRelative`
when you need world coordinates.

Attribute forms: `onpositionenter`, `onpositionmove`, `onpositionleave`.

### `prompt` (MMLPromptEvent)

`<m-prompt message="..." placeholder="..." prefill="...">` wraps clickable children. When a user
clicks a child, their client opens a text input. On submit: `detail.value` is the string.

Attribute form: `onprompt`.

### `interact` (MMLInteractionEvent)

`<m-interaction prompt="Open door" range="5">` is a point in space the user can trigger with an
interaction key (E in the reference client) when within `range`. No position payload, just
`connectionId`. Attributes `in-focus` and `line-of-sight` restrict when it is offered.

Attribute form: `oninteract`.

### `chat` (MMLChatEvent)

`<m-chat-probe range="1">` receives chat messages from users within `range`, if the hosting
world forwards chat. `detail.message` is the text. Attribute form: `onchat`.

## Event to element cheat sheet

| you want | element | event |
|---|---|---|
| click / tap | any clickable element | `click` |
| stood on / touched | element with `collision-interval` | `collisionstart` etc. |
| nearby, with position | `m-position-probe` | `positionenter` etc. |
| press E to use | `m-interaction` | `interact` |
| type text | `m-prompt` | `prompt` |
| said something in chat | `m-chat-probe` | `chat` |
| joined / left | `window` | `connected` / `disconnected` |
