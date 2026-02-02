import ws from 'src/services/ws'

export default {
  namespaced: true,
  state: () => ({
    state: 'closed',
    url: null,
    lastError: null
  }),
  mutations: {
    set (s, p) {
      if (p.state != null) s.state = p.state
      if (p.url != null) s.url = p.url
      if (p.error != null) s.lastError = p.error
    }
  },
  actions: {
    connect ({ commit }, url) {
      // one subscription is enough; repeated calls are safe
      ws.on('status', (st) => commit('set', st || {}))
      ws.connect(url)
    },

    connectFromLayout ({ rootState, dispatch }) {
      const b = (rootState && rootState.layout && rootState.layout.dock) ? rootState.layout.dock.backend : null
      if (!b) return
      const host = String(b.host || '').trim()
      const port = String(b.port || '').trim()
      const name = String(b.name || '').trim()
      const path = String(b.path || '/ws').trim() || '/ws'
      if (!host || !port) return

      const proto = b.secure ? 'wss:' : 'ws:'
      const url = proto + '//' + host + ':' + port + path
      dispatch('connect', url)
    }
  }
}
