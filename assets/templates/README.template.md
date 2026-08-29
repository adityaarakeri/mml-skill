# __PROJECT__

An MML (Metaverse Markup Language) project. MML documents are HTML files with 3D tags like
`<m-cube>` and `<m-model>`. If a document has a `<script>`, that script runs on a server and
every connected user sees the same scene change at the same time. Think of it as a shared
whiteboard rather than a per-person web page.

## Run it

```bash
npm install
npm run dev
```

Then open http://localhost:7079. Edit `documents/scene.html` and the scene reloads on save.
Open the page in a second tab to see the multi-user behaviour.

Script errors show up in the terminal, not the browser.

## Files

- `documents/scene.html`: the main document. Scene tags first, one `<script>` at the end.
- `assets/`: models (`.glb`), images, audio. Reference them from a document as `/assets/name.glb`.
- `package.json`: `dev` (serve the main document), `serve-all` (serve every document in
  `documents/` with a dashboard), `validate` (check against the MML schema).

## Check your work

```bash
npm run validate
```

Unknown tags or attributes are real bugs in MML, not warnings. Fix everything it reports.

## Deploy

- No `<script>` in the document: it is static. Upload the `.html` to any static host and load it
  by `https://` URL in an MML viewer or world.
- Has a `<script>`: it needs a WebSocket-capable server. The simplest is the official starter
  project (https://github.com/mml-io/mml-starter-project), which is a small Express app. Copy
  your document over `src/mml-document.html` and deploy that.

Preview any hosted document at `https://viewer.mml.io/main/v1/?url=<your url>`.

## Where things are

- Coordinates are meters, Y is up, rotations are degrees (`rx`, `ry`, `rz`), scale is `sx`, `sy`, `sz`.
- A default cube is 1m and centred on its position, so `y="0.5"` sits it on the floor.
- Element and attribute reference: https://mml.io/docs
