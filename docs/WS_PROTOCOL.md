# MIO IDE WebSocket Protocol (v1)

This IDE speaks JSON over WebSockets using a tiny **request/response RPC** envelope.

## Envelope

### Request

```json
{ "type": "rpc", "id": "r...", "method": "mumps/diagnostics", "params": { ... } }
```

### Response

Success:

```json
{ "type": "rpc", "id": "r...", "ok": 1, "result": { ... } }
```

Error:

```json
{ "type": "rpc", "id": "r...", "ok": 0, "error": { "message": "...", "code": "..." } }
```

## Methods

The frontend currently calls these methods when a `.m/.int/.rou` editor is active:

* `ping`
* `mumps/diagnostics`
* `mumps/completion`
* `mumps/hover`
* `mumps/documentSymbols`
* `mumps/definition`
* `mumps/references`
* `mumps/format`

All methods operate on the **text sent by the client**. This keeps the backend stateless and easy to integrate with any filesystem/workspace scheme.

### `ping`
Result: `{ "pong": 1 }`

### `mumps/diagnostics`
Input:

```json
{ "file": "ROU.m", "text": "..." }
```

Output:

```json
{ "markers": [ { "severity": 8, "message": "...", "startLineNumber": 1, "startColumn": 1, "endLineNumber": 1, "endColumn": 2 } ] }
```

Severity follows Monaco: `1=Hint, 2=Info, 4=Warning, 8=Error`.

### `mumps/completion`
Input:

```json
{ "file": "ROU.m", "text": "...", "position": { "line": 10, "column": 5 } }
```

Output:

```json
{ "suggestions": [ { "label": "set", "kind": 14, "insertText": "set" } ] }
```

`kind` uses Monaco `CompletionItemKind` numeric values.
