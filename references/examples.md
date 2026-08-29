# Official MML examples, annotated

These are the examples from mml.io/examples and the mml.io docs, with notes on what each one
teaches. Copy the shapes, not just the code. All of them are interactive documents (they have a
script), so they need `mml serve` or another Networked DOM host.

Table of contents

1. Game of Life (grid state, create/remove per tick)
2. Basic scene (models, m-attr-anim, click)
3. Clock (wall-clock time into rotations)
4. Dice (one-shot animations from script)
5. Tic tac toe (board state, labels as cells, win check)
6. Weather board (fetch from an API on an interval)
7. Collision platform and user counter (from the collisions guide)
8. Position probe (user presence markers)
9. Prompt, interaction, lerp, frame (small element demos)
10. Bundled skill examples: parkour and disco floor (assets/templates/)

## 1. Game of Life

Source: https://mml.io/examples?example=Game%20of%20Life

```html
<m-group></m-group>
<script>
  let world = [];
  const worldSize = 20,
    cellSize = 0.5;

  for (let x = 0; x < worldSize; x++) {
    world[x] = [];
    for (let y = 0; y < worldSize; y++) {
      world[x][y] = Math.random() < 0.25 ? 1 : 0;
      if (world[x][y]) createCube(x, y);
    }
  }

  function createCube(x, y) {
    const cube = document.createElement("m-cube");
    cube.setAttribute("x", (x - worldSize / 2) * cellSize);
    cube.setAttribute("y", y * cellSize + 1);
    cube.setAttribute("z", 0);
    cube.setAttribute("color", "skyblue");
    cube.setAttribute("id", x + ":" + y);
    document.body.appendChild(cube);
  }

  function update() {
    const newWorld = [];

    for (let x = 0; x < worldSize; x++) {
      newWorld[x] = [];
      for (let y = 0; y < worldSize; y++) {
        const nn = countNeighbours(x, y);
        const alive = world[x][y] === 1;

        if (alive && (nn < 2 || nn > 3)) {
          newWorld[x][y] = 0;
        } else if (!alive && nn === 3) {
          newWorld[x][y] = 1;
        } else {
          newWorld[x][y] = world[x][y];
        }

        if (newWorld[x][y]) {
          if (!alive) createCube(x, y);
        } else if (alive) document.getElementById(x + ":" + y).remove();
      }
    }

    world = newWorld;
  }

  function countNeighbours(x, y) {
    let count = 0;

    for (let dx = -1; dx <= 1; dx++) {
      for (let dy = -1; dy <= 1; dy++) {
        if (dx === 0 && dy === 0) continue;
        const nx = (x + dx + worldSize) % worldSize;
        const ny = (y + dy + worldSize) % worldSize;
        count += world[nx][ny];
      }
    }
    return count;
  }

  window.setInterval(update, 200);
</script>
```

What it teaches:

- **State lives in a plain array** (`world[x][y]`), not in the DOM. The DOM is a projection of
  the state. Read from the array, write to the DOM.
- **One element per live cell, id derived from coordinates** (`"x:y"`). That makes lookup
  trivial: `document.getElementById(x + ":" + y)`.
- Only touch what changed: a cell that was alive and stays alive is left alone. A cell that
  becomes alive gets `createCube`. A cell that dies gets `.remove()`. With a 20x20 grid at 25%
  density that is a few dozen DOM operations per tick instead of 400.
- **Tick rate**: 200ms. Fast enough to look alive, slow enough not to flood clients.
- **Layout math**: `(x - worldSize / 2) * cellSize` centres the grid on x=0.
  `y * cellSize + 1` stands it up vertically starting one meter off the ground, so it faces the
  default camera like a wall display.
- **Wrap-around neighbours** via `(x + dx + worldSize) % worldSize` so the edges behave like a
  torus and gliders never get stuck.
- The empty `<m-group>` at the top is not used by the script; it is a leftover you can drop or
  use as the parent instead of `document.body` if you want to move the whole grid.

Variations users often ask for, and how to do them:

- Click a cell to toggle it: give each cube a click listener in `createCube`, and also render
  dim "dead" cubes (`opacity="0.1"`) so there is something to click. Then the create/remove
  logic becomes "set color/opacity" instead.
- Pause / play: wrap a clickable `<m-label content="Pause">` and toggle a boolean the interval
  checks.
- Bigger grids: keep total live cubes under a few hundred. Past that, switch to a single
  `m-image` you regenerate server-side, or accept a slower tick.

## 2. Basic scene

```html
<!-- Battle Damaged Sci-fi Helmet - PBR by theblueturtle_
https://sketchfab.com/models/b81008d513954189a063ff901f7abfe4 -->
<m-model x="-2" collide="true" src="https://public.mml.io/damaged-helmet.glb" z="-2" y="1.2" sx="0.5" sy="0.5" sz="0.5"></m-model>

<m-cube id="clickable-cube" y="1" color="red" collide="true" z="-2"></m-cube>

<m-model x="2" z="-2" id="duck" src="https://public.mml.io/duck.glb" y="0.37872010769124587" collide="true">
  <m-attr-anim attr="ry" start="0" end="360" duration="3000"></m-attr-anim>
</m-model>

<m-cube id="color-cube" x="4" y="1" width="1" color="green" collide="true" z="-2" castshadow="true"></m-cube>

<script>
  const clickableCube = document.getElementById("clickable-cube");
  clickableCube.addEventListener("click", () => {
    clickableCube.setAttribute("color", `#${Math.floor(Math.random() * 16777215).toString(16)}`);
  });
</script>
```

What it teaches: loading `.glb` models from a URL, `collide="true"` so avatars walk on them,
`m-attr-anim` on `ry` for a continuous spin (no script needed for that part), and a click
handler that sets a random hex color. Note `sx/sy/sz` for scaling a model that is too big.

## 3. Clock

```html
<m-group y="4">
  <m-cylinder color="lightgrey" radius="4" height="0.1" rx="90"></m-cylinder>
  <m-group id="hour" rz="0" z="0.1">
    <m-cube sx="0.14" sy="1.2" sz="0.08" z="0.04" color="#000000" y="0.2"></m-cube>
  </m-group>
  <m-group id="minute" rz="0" z="0.11">
    <m-cube sx="0.1" sy="2.4" sz="0.08" z="0.04" color="#000000" y="0.3"></m-cube>
  </m-group>
  <m-group id="second" rz="0" z="0.12">
    <m-cube sx="0.08" sy="3.2" sz="0.08" z="0.04" color="#ff0000" y="0.8"></m-cube>
  </m-group>
</m-group>

<script>
  function setTime() {
    const d = new Date();
    document.getElementById("hour").setAttribute("rz", (d.getHours() / 12) * -360);
    document.getElementById("minute").setAttribute("rz", (d.getMinutes() / 60) * -360);
    document.getElementById("second").setAttribute("rz", (d.getSeconds() / 60) * -360);
  }

  setTime();

  setInterval(setTime, 1000); // update every second
</script>
```

What it teaches: nesting `m-group`s so each hand rotates around its own pivot. The hand cube is
offset in `y` inside the group, and the group is rotated with `rz`, so the cube sweeps like a
hand instead of spinning in place. `rx="90"` on the cylinder turns it from a standing can into
a flat clock face. `new Date()` is wall-clock time from the server. Once per second is a fine
update rate.

## 4. Dice

```html
<m-model id="dice" src="https://public.mml.io/dice.glb" y="1" collide="true" onclick="rollDice()">
  <m-attr-anim id="rx" attr="rx" ping-pong="false" easing="linear" start="0" end="0" loop="false" start-time="0" duration="1"></m-attr-anim>
  <m-attr-anim id="ry" attr="ry" ping-pong="false" easing="linear" start="0" end="0" loop="false" start-time="0" duration="1"></m-attr-anim>
  <m-attr-anim id="rz" attr="rz" ping-pong="false" easing="linear" start="0" end="0" loop="false" start-time="0" duration="1"></m-attr-anim>
  <m-attr-anim id="y" attr="y" ping-pong="false" easing="linear" start="1" end="1" loop="false" start-time="0" duration="1"></m-attr-anim>
</m-model>
<script>
  let rolling = false;
  let rollResult = 1;
  let rollDuration = 750;
  let rollHeight = 3.1;

  function radToDeg(radians) {
    return radians * (180 / Math.PI);
  }

  function animate(attr, easing, targetRotation, duration) {
    rolling = true;
    const mAttrAnim = document.getElementById(attr);
    const newStart = mAttrAnim.getAttribute("end");
    mAttrAnim.setAttribute("easing", easing);
    mAttrAnim.setAttribute("start", newStart);
    mAttrAnim.setAttribute("end", targetRotation);
    mAttrAnim.setAttribute("loop", "false");
    mAttrAnim.setAttribute("duration", duration);
    mAttrAnim.setAttribute("start-time", document.timeline.currentTime);
    setTimeout(() => {
      rolling = false;
    }, duration + 10);
  }

  function rollDice() {
    if (rolling) return;
    const rollMap = {
      1: {
        rx: 0,
        ry: 0,
        rz: 0
      },
      2: {
        rx: 0,
        ry: 0,
        rz: radToDeg(-Math.PI / 2)
      },
      3: {
        rx: radToDeg(-Math.PI / 2),
        ry: 0,
        rz: 0
      },
      4: {
        rx: radToDeg(Math.PI / 2),
        ry: 0,
        rz: 0
      },
      5: {
        rx: 0,
        ry: 0,
        rz: radToDeg(Math.PI / 2)
      },
      6: {
        rx: radToDeg(Math.PI),
        ry: 0,
        rz: 0
      },
    };
    const diceElement = document.getElementById("dice");

    let newRoll = Math.floor(Math.random() * 6) + 1;
    while (newRoll === rollResult) {
      newRoll = Math.floor(Math.random() * 6) + 1;
    }
    rollResult = newRoll;

    const targetRotation = rollMap[rollResult];
    const startRotation = {
      rx: parseFloat(diceElement.getAttribute("rx")),
      ry: parseFloat(diceElement.getAttribute("ry")),
      rz: parseFloat(diceElement.getAttribute("rz")),
    };

    animate("rx", "easeOutCubic", targetRotation.rx, rollDuration);
    animate("ry", "easeOutCubic", targetRotation.ry, rollDuration);
    animate("rz", "easeOutCubic", targetRotation.rz, rollDuration);
    animate("y", "easeOutQuint", rollHeight, rollDuration * 0.35);
    setTimeout(() => {
      animate("y", "easeOutBounce", 1, rollDuration * 0.65);
    }, rollDuration * 0.35);
  }
</script>
```

Note: `easing="linear"` in this example fails `mml validate` (not in the schema enum). Omit
the attribute to get linear. The example runs because the server does not validate.

What it teaches: **driving `m-attr-anim` from script**. Each animation element is pre-declared
with `loop="false"` and a `duration="1"` placeholder. To play one, the script sets `start`,
`end`, `easing`, `duration`, and `start-time = document.timeline.currentTime`. Setting a new
`start-time` restarts the animation; clients interpolate locally, so the server sends a handful
of attributes per roll and nothing per frame. The `rolling` flag prevents overlapping rolls.
The two-phase `y` animation (up with `easeOutQuint`, down with `easeOutBounce`) is chained with
`setTimeout`. The starter project's `mml-document.html` does the same thing with cleaner
separate up/down animation elements.

## 5. Tic tac toe

```html
<m-group id="board" z="-20" y="0">
  <m-label id="winner" width="22" y="-5" height="5" content="" font-size="200" alignment="center"></m-label>

  <!--  horizontal lines -->
  <m-cube id="line-horizontal-1" width="22" z="1" y="21.5" color="black"></m-cube>
  <m-cube id="line-horizontal-2" width="22" z="1" y="14.5" color="black"></m-cube>
  <m-cube id="line-horizontal-3" width="22" z="1" y="7.5" color="black"></m-cube>
  <m-cube id="line-horizontal-4" width="22" z="1" y="0.5" color="black"></m-cube>

  <!--  vertical lines -->
  <m-cube id="line-vertical-1" height="22" z="1" x="-10.5" y="11" color="black"></m-cube>
  <m-cube id="line-vertical-2" height="22" z="1" x="-3.5" y="11" color="black"></m-cube>
  <m-cube id="line-vertical-3" height="22" z="1" x="3.5" y="11" color="black"></m-cube>
  <m-cube id="line-vertical-4" height="22" z="1" x="10.5" y="11" color="black"></m-cube>

  <!--  interactive cubes -->
  <!--  first row -->
  <m-label id="cell-1" width="6" height="6" x="-7" y="18" z="1" font-size="450" color="#ffffff" alignment="center"></m-label>
  <m-label id="cell-2" width="6" height="6" x="0" y="18" z="1" font-size="450" color="#ffffff" alignment="center"></m-label>
  <m-label id="cell-3" width="6" height="6" x="7" y="18" z="1" font-size="450" color="#ffffff" alignment="center"></m-label>

  <!--  second row -->
  <m-label id="cell-4" width="6" height="6" x="-7" y="11" z="1" font-size="450" color="#ffffff" alignment="center"></m-label>
  <m-label id="cell-5" width="6" height="6" x="0" y="11" z="1" font-size="450" color="#ffffff" alignment="center"></m-label>
  <m-label id="cell-6" width="6" height="6" x="7" y="11" z="1" font-size="450" color="#ffffff" alignment="center"></m-label>

  <!--  third row -->
  <m-label id="cell-7" width="6" height="6" x="-7" y="4" z="1" font-size="450" color="#ffffff" alignment="center"></m-label>
  <m-label id="cell-8" width="6" height="6" x="0" y="4" z="1" font-size="450" color="#ffffff" alignment="center"></m-label>
  <m-label id="cell-9" width="6" height="6" x="7" y="4" z="1" font-size="450" color="#ffffff" alignment="center"></m-label>
</m-group>

<script>
  let isGameOver = false;
  // Create tic-tac-toe board status
  let board = [
    ["", "", ""],
    ["", "", ""],
    ["", "", ""],
  ];
  
  const label = document.querySelector("#winner");
  
  // Track current player
  let currentPlayer = "X";
  
  const setMove = (selectedCell) => {
    selectedCell.setAttribute("content", currentPlayer);
  }
  
  // Function to update board status
  function updateBoard(x, y, player) {
    board[y][x] = player;
  }
  
  // Function to check for a win
  function checkForWin() {
    const winConditions = [
      [[0, 0], [1, 0], [2, 0]], // rows
      [[0, 1], [1, 1], [2, 1]],
      [[0, 2], [1, 2], [2, 2]],
      [[0, 0], [0, 1], [0, 2]], // columns
      [[1, 0], [1, 1], [1, 2]],
      [[2, 0], [2, 1], [2, 2]],
      [[0, 0], [1, 1], [2, 2]], // diagonals
      [[0, 2], [1, 1], [2, 0]],
    ];
  
    return winConditions.some(condition =>
      condition.every(([x, y]) => board[y][x] === currentPlayer)
    );
  }
  
  function resetBoard() {
    isGameOver = false;
    board = [
      ["", "", ""],
      ["", "", ""],
      ["", "", ""],
    ];
    const boardNode = document.getElementById("board");
    const labels = boardNode.querySelectorAll("m-label");
    labels.forEach((child) => {
        child.setAttribute("content", "");
    });
  }
  
  // Add click event listeners to cubes
  for (let y = 0; y < 3; y++) {
    for (let x = 0; x < 3; x++) {
      const cell = document.getElementById(`cell-${y * 3 + x + 1}`);
      cell.addEventListener("click", () => {
        if (isGameOver) return;
        
        if (board[y][x] === "") {
          // Update board status
          updateBoard(x, y, currentPlayer);
          setMove(cell)
  
          // Visualize move
          cell.textContent = currentPlayer;
  
          // Check for win
          if (checkForWin()) {
            isGameOver = true;          
            label.setAttribute("content", `${currentPlayer} wins!\nClick to restart!`);
            label.addEventListener("click", () => {
              resetBoard();
            });
            return;
          }
          
          // Check for tie
          if (board.every(row => row.every(cell => cell !== ""))) {
            isGameOver = true;
            label.setAttribute("content", "It's a tie!\\nClick to restart!");
            label.addEventListener("click", () => {
              resetBoard();
            });
            return;
          }
  
          // Switch players
          currentPlayer = currentPlayer === "X" ? "O" : "X";
         
        }
      });
    }
  }
</script>
<m-light type="point" intensity="500" x="10" y="10" z="10"></m-light>
```

What it teaches: `m-label` elements double as clickable cells. Board state is a 2D array,
rendering is `setAttribute("content", ...)`. The `label.addEventListener("click", resetBoard)`
inside the win branch is added again every game (a small bug in the original); register it once
at startup instead. Everything is scaled large (`width="22"`) and pushed back to `z="-20"` so it
fills the viewer's default camera.

## 6. Weather board

Five `m-label`s stacked vertically, then:

```js
  async function fetchAPIData() {
    const latitude = 51.5;
    const longitude = 0.11;
    const res = await fetch(
      `https://api.open-meteo.com/v1/forecast?latitude=${latitude}&longitude=${longitude}&current_weather=true&hourly=temperature_2m,relativehumidity_2m,windspeed_10m`,
    );
    const json = await res.json();
    latLabel.setAttribute("content", `Latitude: ${latitude}°N`);
    longLabel.setAttribute("content", `Longitude: ${longitude}°W`);
    const floatTemp = parseFloat(json["current_weather"].temperature);
    const color = floatTemp > 15 ? (floatTemp > 25 ? "#ffcccc" : "#ccffcc") : "#ccccff";
    const temperature = `${floatTemp}°C`;
    temperatureLabel.setAttribute("content", `Temp: ${temperature}`);
    temperatureLabel.setAttribute("color", color);
    const windSpeed = `${json["current_weather"].windspeed} km/h`;
    windSpeedLabel.setAttribute("content", `Wind: ${windSpeed}`);
    const weather = parseInt(json["current_weather"].weathercode);
    weatherLabel.setAttribute("content", weatherCode[weather]);
  }

  fetchAPIData();

  setInterval(() => {
    fetchAPIData();
  }, 5 * 60 * 1000);
```

What it teaches: `fetch` works in the document script, so a document can pull live data. Call
once at load and then on a slow `setInterval` (every five minutes here). Keep
API keys out of the document if it will be published; the document source is visible to
anyone who can load it.

## 7. Collision platform and user counter

From https://mml.io/docs/guides/mml-collide-events-guide

```html
<m-label id="my-label" width="4" y="3" height="0.5" alignment="center"></m-label>
<m-cube id="collision-ground" collision-interval="100" y="0.1" height="0.1" width="3" depth="3" color="green"></m-cube>

<script>
  const collisionGround = document.getElementById("collision-ground");
  const label = document.getElementById("my-label");
  const collidingUsers = new Set();

  function updateLabel() {
    const n = collidingUsers.size;
    label.setAttribute("content", `${n} user${n === 1 ? "" : "s"} colliding`);
  }
  updateLabel();

  collisionGround.addEventListener("collisionstart", (e) => {
    collidingUsers.add(e.detail.connectionId);
    updateLabel();
  });
  collisionGround.addEventListener("collisionend", (e) => {
    collidingUsers.delete(e.detail.connectionId);
    updateLabel();
  });
  window.addEventListener("disconnected", (e) => {
    collidingUsers.delete(e.detail.connectionId);
    updateLabel();
  });
</script>
```

What it teaches: `collision-interval` is required or nothing fires. A `Set` of `connectionId`s
is the right structure for "who is on this". The `disconnected` handler is not optional; a user
who closes the tab while standing on the platform never sends `collisionend`.

The guide also has a version that maps `collisionmove` `detail.position` onto a display panel,
one small cube per user, updated as they walk. Same structure with a `Map` from
`connectionId` to cube element.

## 8. Position probe

```html
<m-group x="3" ry="30" y="4">
  <m-position-probe range="7" debug="true" id="my-probe" interval="100"></m-position-probe>
  <m-group id="user-presence-holder"></m-group>
</m-group>

<script>
  const connectedUsers = new Map();
  const holder = document.getElementById("user-presence-holder");
  const probe = document.getElementById("my-probe");

  function getOrCreateUser(connectionId) {
    let user = connectedUsers.get(connectionId);
    if (user) return user;
    const cube = document.createElement("m-cube");
    cube.setAttribute("collide", false);
    cube.setAttribute("width", 0.25);
    cube.setAttribute("height", 0.25);
    cube.setAttribute("depth", 0.25);
    cube.setAttribute("color", `#${Math.floor(Math.random() * 0xffffff).toString(16).padStart(6, "0")}`);
    holder.append(cube);
    user = { cube };
    connectedUsers.set(connectionId, user);
    return user;
  }

  function place(connectionId, position, rotation) {
    const user = getOrCreateUser(connectionId);
    user.cube.setAttribute("x", position.x / 2);
    user.cube.setAttribute("y", position.y / 2 - 1);
    user.cube.setAttribute("z", position.z / 2);
    user.cube.setAttribute("rx", rotation.x);
    user.cube.setAttribute("ry", rotation.y);
    user.cube.setAttribute("rz", rotation.z);
  }

  function clearUser(connectionId) {
    const user = connectedUsers.get(connectionId);
    if (!user) return;
    user.cube.remove();
    connectedUsers.delete(connectionId);
  }

  probe.addEventListener("positionenter", (e) => {
    const { connectionId, elementRelative } = e.detail;
    place(connectionId, elementRelative.position, elementRelative.rotation);
  });
  probe.addEventListener("positionmove", (e) => {
    // Can arrive without an enter if the user was already in range on reload.
    const { connectionId, elementRelative } = e.detail;
    place(connectionId, elementRelative.position, elementRelative.rotation);
  });
  probe.addEventListener("positionleave", (e) => clearUser(e.detail.connectionId));
  window.addEventListener("disconnected", (e) => clearUser(e.detail.connectionId));
</script>
```

What it teaches: `debug="true"` draws the probe's range so you can see it. `elementRelative`
coordinates are already in the probe's frame, which is why placing the marker cubes inside a
sibling group of the probe just works. Halving the coordinates makes a miniature map.

## 9. Small element demos

**Prompt** (ask for text):

```html
<m-prompt message="What is your favourite color?" placeholder="Write a color" prefill="orange" id="my-prompt" y="2">
  <m-cube id="color-cube" color="blue"></m-cube>
</m-prompt>
<script>
  document.getElementById("my-prompt").addEventListener("prompt", (e) => {
    document.getElementById("color-cube").setAttribute("color", e.detail.value);
  });
</script>
```

**Interaction** (press E near it):

```html
<m-interaction prompt="Toggle Color" debug="true" id="my-interaction">
  <m-cube y="1" id="color-cube" color="blue"></m-cube>
</m-interaction>
<script>
  let on = false;
  document.getElementById("my-interaction").addEventListener("interact", () => {
    on = !on;
    document.getElementById("color-cube").setAttribute("color", on ? "red" : "blue");
  });
</script>
```

**Lerp** (smooth any attribute change):

```html
<m-cube id="lerped-cube" y="5" color="red">
  <m-attr-lerp attr="x,y" duration="2000" easing="easeInOutCubic"></m-attr-lerp>
</m-cube>
<script>
  const cube = document.getElementById("lerped-cube");
  setInterval(() => {
    cube.setAttribute("x", Math.random() * 10 - 5);
    cube.setAttribute("y", Math.random() * 5 + 2);
  }, 2000);
</script>
```

**Frame** (embed another document):

```html
<m-frame src="https://public.mml.io/rgb-cubes.html" y="1" ry="45"></m-frame>
```

Public test assets that the official examples use and that are safe to reference in demos:
`https://public.mml.io/duck.glb`, `https://public.mml.io/dice.glb`,
`https://public.mml.io/damaged-helmet.glb`, `https://public.mml.io/charge.mp4`,
`https://public.mml.io/rgb-cubes.html`.

## 10. Bundled skill examples (assets/templates/)

Two complete, validated games written with this skill. Scaffold either with
`scripts/new-mml-project.sh <dir> --example parkour` (or `--example disco-floor`), or copy them
out of `assets/templates/` directly.

### Parkour (`parkour.html`) - a full timed game

A 10-platform climbing course: start pad, 8 checkpoints that must be hit in order, finish pad.
Time-based scoring against a par time, per-player personal bests, and a floating top-5
leaderboard. Demonstrates, in one document:

- **Per-player state**: `runs` and `best` are `Map`s keyed by `event.detail.connectionId`.
  Multiple users race simultaneously without interfering.
- **Dual input**: every platform listens for BOTH `collisionstart` (avatar worlds; requires
  `collision-interval`) and `click` (fly-camera viewers have no avatar). Same handler.
- **Document-time scoring**: run duration is `document.timeline.currentTime` deltas - the one
  clock all clients agree on.
- **Ordered progression**: checkpoints are validated against a precomputed `cpOrder` array;
  touching the finish with checkpoints missing is rejected (anti-cheat).
- **Data-driven layout**: the whole course is a `COURSE` array of `{x,y,z,w,d,kind}` at the top
  of the script. Platform spacing follows the avatar movement envelope in
  `references/avatar-worlds.md` (~0.6m rises, ~2-3m gaps) so it is jumpable by a real avatar.
- **Cleanup**: a `window` `disconnected` handler drops mid-run state for leavers.
- **Cheap ticking**: one 200ms interval updates a single HUD label, and only while someone is
  mid-run.

### Disco floor (`disco-floor.html`) - dynamic DOM + lerp polish

A 6x6 grid of clickable tiles; each click cycles a tile through a 6-color palette, a counter
label tracks lit tiles, and a reset button clears the board with a springy scale pulse.
Demonstrates:

- **Grid built from script**: tiles are `document.createElement("m-cube")` with ids derived
  from coordinates (the Game of Life shape) and state in a plain object, DOM as projection.
- **`m-attr-lerp` for free polish**: each tile carries a lerp on `y` so `setAttribute("y", ...)`
  glides; the reset button lerps `sx,sy,sz` with `easeOutBack` for a press animation. Zero
  per-frame messages.
- **Shared state**: every connected user sees the same floor; a click in one tab lights the
  tile in all tabs.
