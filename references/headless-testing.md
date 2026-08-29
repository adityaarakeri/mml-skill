# Headless testing of MML documents (no browser needed)

Proven technique (verified against `@mml-io/mml-cli` 0.26.x `serve` / `serve-dir`): connect to a
running document as a raw WebSocket client speaking `networked-dom-v0.1`, read the server's DOM
snapshot, inject synthetic user events, and assert on the `attributeChange` diffs the server
broadcasts back. This exercises the REAL server-side script — game logic, multi-user state,
`connectionId` handling — without any WebGL client, so it works from any script or CI job.

## Protocol essentials

- Endpoint: `ws://127.0.0.1:7079/<document>.html` (same path the browser client uses).
- Subprotocol: request `Sec-WebSocket-Protocol: networked-dom-v0.1`. If you omit it the server
  still works but sends a `{"type":"warning"}` message first and assumes v0.1.
- All messages are JSON **arrays** of message objects, text frames. Multiple arrays can arrive
  back-to-back in one read; split with a regex like `\[.*?\](?=\[|$)` (DOTALL) before parsing.
- On connect the server sends `{"type":"snapshot","snapshot":{...}}`: a full element tree with
  `nodeId`, `tag`, `attributes`, `children`. Walk it to map `id` attributes -> `nodeId`s.
- Keepalive: periodic `{"type":"ping","ping":N,"documentTime":ms}` messages. Ignore them (or
  reply pong) — but do not mistake them for silence when waiting for diffs.

## Sending a synthetic user event

```json
{"type": "event", "nodeId": 15, "name": "click", "bubbles": true,
 "params": {"position": {"x": 0, "y": 0.1, "z": 0}}}
```

(sent as a single-message text frame; client-to-server frames must be masked per RFC 6455).
`name` can be any event the element listens for: `click`, `collisionstart`, `prompt` (with
`params.value`), etc. The server assigns the connection a `connectionId` (first client is 1) and
the script sees it in `event.detail.connectionId`, exactly like a real user.

## What comes back

Every DOM mutation the script performs is broadcast as diffs:

```json
[{"type":"attributeChange","nodeId":15,"attribute":"color","newValue":"#ff5470"}]
```

plus `childrenAdded` / `childrenRemoved` for created/removed elements. Assert on these instead
of screenshots. Useful extraction regex:
`\{"type":"attributeChange","nodeId":(\d+),"attribute":"([^"]+)","newValue":"([^"]*)"\}`.

## Python stdlib client (no deps)

If `websocket-client` is unavailable, a hand-rolled client is ~50 lines: HTTP/1.1 Upgrade with a
random `Sec-WebSocket-Key`, then minimal frame codec (opcode 0x1 text, 0x8 close; client frames
masked with 4 random bytes; 126/127 extended lengths). This was written and verified in-session:

```python
import socket, base64, os, struct, json

def ws_connect(host, port, path, subproto="networked-dom-v0.1"):
    s = socket.create_connection((host, port), timeout=10)
    key = base64.b64encode(os.urandom(16)).decode()
    hdrs = [f"GET {path} HTTP/1.1", f"Host: {host}:{port}", "Upgrade: websocket",
            "Connection: Upgrade", f"Sec-WebSocket-Key: {key}",
            "Sec-WebSocket-Version: 13", f"Sec-WebSocket-Protocol: {subproto}"]
    s.sendall(("\r\n".join(hdrs) + "\r\n\r\n").encode())
    resp = b""
    while b"\r\n\r\n" not in resp:
        resp += s.recv(4096)
    return s  # expect 'HTTP/1.1 101' in resp

def ws_recv(s):
    def rd(n):
        b = b""
        while len(b) < n:
            c = s.recv(n - len(b))
            if not c: raise ConnectionError("closed")
            b += c
        return b
    h = rd(2); op = h[0] & 0x0F; ln = h[1] & 0x7F
    if ln == 126: ln = struct.unpack(">H", rd(2))[0]
    elif ln == 127: ln = struct.unpack(">Q", rd(8))[0]
    return op, rd(ln)  # op 8 = close, 1 = text

def ws_send(s, text):
    payload = text.encode(); mask = os.urandom(4); ln = len(payload)
    hdr = b"\x81"
    if ln < 126: hdr += bytes([0x80 | ln])
    elif ln < 65536: hdr += bytes([0x80 | 126]) + struct.pack(">H", ln)
    else: hdr += bytes([0x80 | 127]) + struct.pack(">Q", ln)
    s.sendall(hdr + mask + bytes(b ^ mask[i % 4] for i, b in enumerate(payload)))
```

Workflow: connect -> drain until the snapshot arrives -> walk it into an `id -> nodeId` map ->
`ws_send` events -> drain with a short `settimeout` and assert on the diffs.

## Pitfalls

- Always call `sock.settimeout(...)` before drain loops. A blocking `recv` on a quiet socket
  hangs forever (pings only arrive every ~5s) and will stall whatever runs the test.
- Multiple test connections each get their own `connectionId`; the second client's clicks show
  up as a different user — which is exactly how to test per-user state (scores, ownership).
- Editing the document file makes the CLI reload it: all script state resets and every nodeId
  changes. Reconnect and re-walk the snapshot after any file change; also `touch <file>` is a
  clean way to force a state reset between test scenarios.
- Second-order check: opening the same URL in two browser tabs and clicking in one is the
  low-tech version of this test; the WS client is for when you need assertions or have no GUI.
