/* src/services/ws.js
   Tiny, stable WebSocket client with pub/sub for IDE streams.
   Degrades gracefully when backend is unavailable.
*/
let ws = null
let isOpen = false
let queue = []
const listeners = new Map()
let lastUrl = null
let reconnectTimer = null

function emit (topic, payload) {
  const arr = listeners.get(topic)
  if (!arr) return
  arr.forEach(fn => { try { fn(payload) } catch (e) {} })
}

function defaultUrl () {
  const loc = window.location
  const proto = loc.protocol === 'https:' ? 'wss:' : 'ws:'
  return proto + '//' + loc.host + '/ws'
}

function connect (url) {
  const u = url || defaultUrl()
  // If caller changed the URL, force a clean reconnect.
  if (lastUrl && lastUrl !== u && ws) {
    try { ws.close() } catch (e) {}
  }
  lastUrl = u

  if (ws && (ws.readyState === WebSocket.OPEN || ws.readyState === WebSocket.CONNECTING)) {
    // already connecting/open on the same URL
    return
  }
  try { ws = new WebSocket(u) } catch (e) {
    emit('status', { state: 'error', error: String(e) })
    return
  }
  emit('status', { state: 'connecting', url: u })

  ws.addEventListener('open', () => {
    isOpen = true
    emit('status', { state: 'open', url: u })
    const q = queue; queue = []
    q.forEach(m => { try { ws.send(m) } catch (e) {} })
  })

  ws.addEventListener('message', (ev) => {
    try {
      const obj = JSON.parse(ev.data)
      if (obj && obj.type) return emit(obj.type, obj)
    } catch (e) {}
    emit('text', { type: 'text', data: ev.data })
  })

  ws.addEventListener('close', () => {
    isOpen = false
    emit('status', { state: 'closed' })
    if (reconnectTimer) clearTimeout(reconnectTimer)
    reconnectTimer = setTimeout(() => connect(u), 1200)
  })

  ws.addEventListener('error', () => emit('status', { state: 'error' }))
}

function disconnect () {
  if (reconnectTimer) { clearTimeout(reconnectTimer); reconnectTimer = null }
  lastUrl = null
  try { if (ws) ws.close() } catch (e) {}
  ws = null
  isOpen = false
  emit('status', { state: 'closed' })
}

function send (obj) {
  const msg = typeof obj === 'string' ? obj : JSON.stringify(obj)
  if (isOpen && ws && ws.readyState === WebSocket.OPEN) {
    try { ws.send(msg) } catch (e) {}
  } else queue.push(msg)
}

function on (topic, fn) {
  if (!listeners.has(topic)) listeners.set(topic, [])
  listeners.get(topic).push(fn)
  return () => {
    const arr = listeners.get(topic) || []
    const idx = arr.indexOf(fn)
    if (idx >= 0) arr.splice(idx, 1)
  }
}

export default { connect, disconnect, send, on }
