// src/services/ideRpc.js
// WebSocket RPC helper (request/response with timeouts).
//
// Protocol (v1):
//   Request:  { type:"rpc", id:"<id>", method:"mumps/diagnostics", params:{...} }
//   Response: { type:"rpc", id:"<id>", ok:1, result:{...} }
//             { type:"rpc", id:"<id>", ok:0, error:{ message, code?, details? } }

import ws from 'src/services/ws'

function uid () {
  // short, collision-resistant enough for UI RPC
  return 'r' + Math.random().toString(16).slice(2) + Date.now().toString(16)
}

const pending = new Map() // id -> {resolve,reject,t}
let wired = false

function wireOnce () {
  if (wired) return
  wired = true
  ws.on('rpc', (msg) => {
    try {
      if (!msg || !msg.id) return
      const p = pending.get(msg.id)
      if (!p) return
      pending.delete(msg.id)
      clearTimeout(p.t)
      if (msg.ok) return p.resolve(msg.result)
      const err = msg.error || { message: 'RPC error' }
      const e = new Error(err.message || 'RPC error')
      e.code = err.code
      e.details = err.details
      return p.reject(e)
    } catch (e) {}
  })
}

/**
 * Call backend RPC method.
 * @param {string} method
 * @param {object} params
 * @param {number} timeoutMs
 */
function call (method, params = {}, timeoutMs = 2000) {
  wireOnce()
  const id = uid()
  const payload = { type: 'rpc', id, method, params }
  return new Promise((resolve, reject) => {
    const t = setTimeout(() => {
      pending.delete(id)
      const e = new Error('RPC timeout')
      e.code = 'timeout'
      reject(e)
    }, Math.max(250, timeoutMs || 0))
    pending.set(id, { resolve, reject, t })
    ws.send(payload)
  })
}

export default { call }
