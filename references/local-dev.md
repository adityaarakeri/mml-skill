# Local development with MML

## Fastest path: the MML CLI

`@mml-io/mml-cli` (0.26.x at the time this skill was written; check `npm view @mml-io/mml-cli
version`) gives you a server, a viewer, and a validator with no project setup.

```bash
npx @mml-io/mml-cli serve documents/scene.html
# open http://localhost:7079
```

- Watches the file and reloads the running document on save. Script variables reset on reload.
- WebSocket endpoint is `ws://127.0.0.1:7079/ws`. Paste that into viewer.mml.io or another
  world to connect from elsewhere on the machine.
- Script errors print in this terminal.

Options:

| flag | meaning | default |
|---|---|---|
| `-p, --port <n>` | port | 7079 |
| `--host <addr>` | listen address (use `0.0.0.0` to reach from another device on the LAN) | 127.0.0.1 |
| `--no-watch` | disable live reload | |
| `--no-client` | do not serve the built-in viewer | |
| `--assets <path>` | serve a folder as static files | |
| `--assets-url-path <path>` | URL prefix for those files | `/assets/` |

Reference assets from the document as `/assets/whatever.glb`.

Serve a whole folder of documents (top-level `.html` files only, subfolders are ignored):

```bash
npx @mml-io/mml-cli serve-dir ./documents
```

The dashboard at http://localhost:7079 lists each document, its connection count, and its
WebSocket URL. Idle documents stop after 60s (`--idle-timeout 0` to disable).

Validate against the official schema:

```bash
npx @mml-io/mml-cli validate documents/*.html
npx @mml-io/mml-cli validate --json documents/scene.html   # machine-readable
```

Exit code 1 on any error, so it slots into CI or a pre-commit hook.

Install globally if you prefer `mml serve` over `npx`: `npm install -g @mml-io/mml-cli`.

## Recommended project layout

This is what `scripts/new-mml-project.sh` produces.

```
my-mml-project/
  package.json          dev / validate / serve-all scripts
  README.md
  documents/
    scene.html          your MML document(s)
  assets/
    (models, images, audio)
  .gitignore
```

`package.json` scripts:

```json
{
  "scripts": {
    "dev": "mml serve documents/scene.html --assets ./assets",
    "serve-all": "mml serve-dir ./documents --assets ./assets",
    "validate": "mml validate documents/*.html"
  },
  "devDependencies": {
    "@mml-io/mml-cli": "^0.26.1"
  }
}
```

Keep documents as fragments (no `<html>`/`<body>` wrapper) unless you need `<head>`. Both forms
are valid; fragments are shorter and match the official examples.

## Owning the server: the starter project

When you need to deploy an interactive document somewhere real, or customise the server (auth,
extra routes, multiple documents), use https://github.com/mml-io/mml-starter-project. It is
about 90 lines of Express:

```js
import { EditableNetworkedDOM, LocalObservableDOMFactory } from "@mml-io/networked-dom-server";

const document = new EditableNetworkedDOM(url.pathToFileURL(filePath).toString(), LocalObservableDOMFactory);
document.load(fs.readFileSync(filePath, "utf8"));

// chokidar watches the file and calls document.load(...) again on change

app.ws("/", (ws) => {
  document.addWebSocket(ws);
  ws.on("close", () => document.removeWebSocket(ws));
});

app.get("/", (req, res) => {
  res.send(`<html><script src="/client/index.js?url=${wsUrl}"></script></html>`);
});
app.use("/client/", express.static("node_modules/@mml-io/mml-web-client/build/"));
app.use("/assets/", cors(), express.static("assets/"));
```

`EditableNetworkedDOM` is the networked document. `addWebSocket` attaches a client.
`load(html)` replaces the document contents and is what live reload calls. The web client is a
prebuilt bundle that takes the WebSocket URL as a query param.

Run: `npm install && npm start`, open http://localhost:8080. `PORT` env var changes the port.

Hosting notes from the mml.io starter project hosting guide: the host must support WebSockets
(plain static hosting will not do). The guide lists CodeSandbox, Glitch, and container hosts as
verified options. Behind a proxy, `x-forwarded-host` / `x-forwarded-port` are used to build the
`wss://` URL the page hands to the client.

## Static documents

No script means no server. Put the `.html` file on any static host (GitHub Pages, S3, Netlify,
Cloudflare Pages). Make sure the host sends permissive CORS headers if other origins will load it.
mmleditor.com will also publish a static document and hand back an https URL.

## Looking at a document without your own client

https://viewer.mml.io/main/v1/?url=<document url>

Works with `https://` (static) and `wss://` (interactive) URLs. Useful query params:

- `renderer=threejs|playcanvas|tags`
- `backgroundColor=%23111827`
- `cameraMode=drag-fly|orbit|none`
- `cameraPosition=0,5,10`
- `cameraFitContents=true`
- `noUI=true` (for iframes)

Embed:

```html
<iframe src="https://viewer.mml.io/main/v1/?url=https://example.com/scene.html&noUI=true"
        width="600" height="400" style="border:0" allowtransparency="true"></iframe>
```

Note: the hosted viewer cannot reach `ws://localhost`, so for local work use the CLI's built-in
client or the starter project page.

## React

https://github.com/mml-io/mml-react-starter-project. Clone, `npm install`, `npm run dev`, open
http://localhost:20205. Entry point is `mml-document/src/index.tsx`.

- MML tags go straight into JSX: `<m-cube x={-4} y={5} width={1} color="red" />`. Attribute
  names stay kebab-case as in HTML (`font-size`, not `fontSize`), and strings are fine for
  numbers.
- Event props use React naming: `onClick`, and the handler gets the MML event.
- `useState` / `useEffect` work as usual. An interval in `useEffect` that calls a state setter
  will re-render and push attribute changes to clients.
- `@mml-io/mml-react-types` provides the JSX typings.
- The React tree still renders on the server into the networked DOM. Nothing about the
  multi-user model changes; React is just a nicer way to produce the tags.

## Avatar world: the `@mml-io/3d-web-experience` CLI

When the user wants a controllable character (WASD + jump) walking through MML content — a
platformer, parkour course, anything needing real `collision*` events — the published npm CLI is
the fastest path. No monorepo clone or build needed:

```bash
mkdir world && cd world
npm init -y && npm install @mml-io/3d-web-experience
mkdir mml-documents            # put your .html documents here (auto-detected)
npx 3d-web-experience serve world.json --port 8085
```

Minimal `world.json` (watched for changes; documents hot-reload on save too):

```json
{
  "chat": true,
  "auth": { "allowAnonymous": true },
  "loadingScreen": { "title": "My World", "subtitle": "Powered by MML" },
  "hud": false,
  "mmlDocuments": {
    "course.html": {
      "url": "ws:///mml-documents/course.html",
      "position": { "x": 0, "y": 0, "z": 0 }
    }
  }
}
```

- The `ws:///mml-documents/<file>` URL (no host) means "this server's own copy"; the CLI
  auto-detects the `mml-documents/` directory next to `world.json`.
- Ships a rigged animated avatar (idle/jog/run/jump, double-jump). Controls: WASD run, Space
  jump, Shift sprint, mouse look via pointer lock.
- Every browser tab is a separate avatar and a separate `connectionId` — instant multiplayer.
- Keep the fly-camera `mml serve` running on its own port during development; the same document
  can be served by both simultaneously (they are independent server-side instances with
  independent state).

Design platforms for avatar physics, not for clicking: an avatar jump clears roughly 1–1.5 m of
height and 2–3 m of horizontal gap. A course laid out for the fly-camera (big rises, wide gaps)
is unplayable on foot — keep per-platform rises around 0.6 m and gaps 2 m or less, and make the
first/last platforms generous (2–3 m wide).

Mouse look needs pointer lock, which embedded webviews (in-app preview panes, iframes) usually
deny — WASD works there but the camera will not turn. Test avatar worlds in a real browser tab.

## Testing ideas

- `mml validate` in CI.
- Open two browser tabs against the same document and confirm a click in one appears in the
  other. That is the whole point of MML and the cheapest way to catch "I accidentally kept state
  per client" mistakes.
- For logic-heavy documents, pull the pure functions (next-generation calculation, win check)
  into a separate `.js` file you can unit test, and inline or bundle it into the document for
  serving. `mml-io/esbuild-plugin-mml` exists for bundling if the project grows.
