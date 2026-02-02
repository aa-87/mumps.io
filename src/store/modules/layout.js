/* src/store/modules/layout.js
   VS Code-like docked panels (no floating windows).

   - Resizable split panes (left sidebar width, right sidebar width, bottom panel height)
   - Activity Bar + (Left) Sidebar with collapse/expand
   - Optional Right Sidebar (Secondary Side Bar)
   - Tabbed bottom panel (Output + Terminal) with reorder
   - Views saved in localStorage (offline)
*/
const LS_KEY = 'mioide.views.v3'
const LS_PREF = 'mioide.prefs.v1'

function clamp (v, min, max) {
  if (typeof v !== 'number' || Number.isNaN(v)) return min
  return Math.max(min, Math.min(max, v))
}

function defaultLayout () {
  return {
    splits: {
      leftWidth: 260,
      rightWidth: 260,
      bottomHeight: 220
    },

    dock: {
      theme: 'dark',

      // Backend connection profile for IDE services (WebSocket).
      // Stored in layout prefs so the UI can be deployed independently.
      backend: {
        name: '',
        host: '',
        port: '',
        path: '/ws',
        secure: false,
        autoConnect: true
      },

      sidebarActive: 'explorer',
      sidebarCollapsed: false,

      rightSidebarActive: 'outline',
      rightSidebarVisible: false,

      bottomTabs: {
        tabs: ['output', 'terminal'],
        active: 'output'
      }
    },

    views: []
  }
}

function deepClone (o) { return JSON.parse(JSON.stringify(o)) }

export default {
  namespaced: true,
  state: () => defaultLayout(),

  getters: {
    bottomTabs: (s) => s.dock.bottomTabs,
    bottomActive: (s) => s.dock.bottomTabs.active,
    sidebarActive: (s) => s.dock.sidebarActive,
    sidebarCollapsed: (s) => s.dock.sidebarCollapsed,
    rightSidebarActive: (s) => s.dock.rightSidebarActive,
    rightSidebarVisible: (s) => s.dock.rightSidebarVisible,
    backend: (s) => s.dock.backend || {},
    backendName: (s) => (s.dock.backend && s.dock.backend.name) ? String(s.dock.backend.name) : ''
  },

  mutations: {
    setLeftWidth (s, px) { s.splits.leftWidth = clamp(px, 180, 520) },
    setRightWidth (s, px) { s.splits.rightWidth = clamp(px, 180, 520) },
    setBottomHeight (s, px) { s.splits.bottomHeight = clamp(px, 120, 520) },

    setSidebarActive (s, id) { s.dock.sidebarActive = id },
    toggleSidebarCollapsed (s) { s.dock.sidebarCollapsed = !s.dock.sidebarCollapsed },

    setRightSidebarActive (s, id) { s.dock.rightSidebarActive = id },
    toggleRightSidebarVisible (s) { s.dock.rightSidebarVisible = !s.dock.rightSidebarVisible },

    setTheme (s, theme) {
      s.dock.theme = (theme === 'light') ? 'light' : 'dark'
    },

    setBackend (s, backend) {
      const b = backend || {}
      if (!s.dock.backend) s.dock.backend = {}
      s.dock.backend.name = String(b.name || '').trim()
      s.dock.backend.host = String(b.host || '').trim()
      s.dock.backend.port = String(b.port || '').trim()
      s.dock.backend.path = String(b.path || '/ws').trim() || '/ws'
      s.dock.backend.secure = !!b.secure
      s.dock.backend.autoConnect = (b.autoConnect !== false)
    },
    toggleTheme (s) {
      s.dock.theme = (s.dock.theme === 'light') ? 'dark' : 'light'
    },

    setBottomActive (s, id) {
      if (!s.dock.bottomTabs.tabs.includes(id)) return
      s.dock.bottomTabs.active = id
    },
    ensureBottomTab (s, id) {
      if (!s.dock.bottomTabs.tabs.includes(id)) s.dock.bottomTabs.tabs.push(id)
    },
    reorderBottomTabs (s, { from, to }) {
      if (from === to) return
      const a = s.dock.bottomTabs.tabs.slice()
      const [m] = a.splice(from, 1)
      a.splice(to, 0, m)
      s.dock.bottomTabs.tabs = a
    },

    setViews (s, views) { s.views = Array.isArray(views) ? views : [] },

    saveView (s, name) {
      const trimmed = String(name || '').trim()
      if (!trimmed) return

      const state = { splits: deepClone(s.splits), dock: deepClone(s.dock) }

      const existingIdx = s.views.findIndex(v => v.name.toLowerCase() === trimmed.toLowerCase())
      const entry = { name: trimmed, state }
      if (existingIdx >= 0) s.views.splice(existingIdx, 1, entry)
      else s.views.unshift(entry)
    },

    deleteView (s, name) {
      const n = String(name || '').trim().toLowerCase()
      s.views = s.views.filter(v => v.name.toLowerCase() !== n)
    },

    applyView (s, name) {
      const n = String(name || '').trim().toLowerCase()
      const found = s.views.find(v => v.name.toLowerCase() === n)
      if (!found) return

      s.splits = deepClone(found.state.splits)
      s.dock = deepClone(found.state.dock)

      // ensure defaults
      if (!s.dock.bottomTabs || !Array.isArray(s.dock.bottomTabs.tabs)) {
        s.dock.bottomTabs = { tabs: ['output', 'terminal'], active: 'output' }
      }
      if (!s.dock.bottomTabs.tabs.includes('output')) s.dock.bottomTabs.tabs.unshift('output')
      if (!s.dock.bottomTabs.tabs.includes('terminal')) s.dock.bottomTabs.tabs.push('terminal')
      if (!s.dock.bottomTabs.active) s.dock.bottomTabs.active = 'output'
      if (!s.dock.sidebarActive) s.dock.sidebarActive = 'explorer'
      if (typeof s.dock.sidebarCollapsed !== 'boolean') s.dock.sidebarCollapsed = false
      if (!s.dock.rightSidebarActive) s.dock.rightSidebarActive = 'outline'
      if (typeof s.dock.rightSidebarVisible !== 'boolean') s.dock.rightSidebarVisible = false
      if (s.dock.theme !== 'light' && s.dock.theme !== 'dark') s.dock.theme = 'dark'

      // ensure backend defaults
      if (!s.dock.backend) {
        s.dock.backend = { name: '', host: '', port: '', path: '/ws', secure: false, autoConnect: true }
      }
      if (typeof s.dock.backend.path !== 'string' || !s.dock.backend.path.trim()) s.dock.backend.path = '/ws'
      if (typeof s.dock.backend.secure !== 'boolean') s.dock.backend.secure = false
      if (typeof s.dock.backend.autoConnect !== 'boolean') s.dock.backend.autoConnect = true
    }
  },

  actions: {
    loadPrefs ({ commit }) {
      try {
        const raw = localStorage.getItem(LS_PREF)
        if (!raw) return
        const parsed = JSON.parse(raw)
        if (parsed && (parsed.theme === 'light' || parsed.theme === 'dark')) commit('setTheme', parsed.theme)

        if (parsed && parsed.backend) commit('setBackend', parsed.backend)
      } catch (e) {}
    },
    persistPrefs ({ state }) {
      try {
        localStorage.setItem(LS_PREF, JSON.stringify({
          theme: state.dock.theme,
          backend: state.dock.backend
        }))
      } catch (e) {}
    },

    loadViews ({ commit }) {
      try {
        const raw = localStorage.getItem(LS_KEY)
        if (!raw) return
        const parsed = JSON.parse(raw)
        if (Array.isArray(parsed)) commit('setViews', parsed)
      } catch (e) {}
    },
    persistViews ({ state }) {
      try {
        localStorage.setItem(LS_KEY, JSON.stringify(state.views))
      } catch (e) {}
    },
    saveView ({ commit, dispatch }, name) {
      commit('saveView', name)
      dispatch('persistViews')
    },
    deleteView ({ commit, dispatch }, name) {
      commit('deleteView', name)
      dispatch('persistViews')
    },
    applyView ({ commit }, name) { commit('applyView', name) },

    toggleTheme ({ commit, dispatch }) {
      commit('toggleTheme')
      dispatch('persistPrefs')
    },
    setTheme ({ commit, dispatch }, theme) {
      commit('setTheme', theme)
      dispatch('persistPrefs')
    }
    ,
    setBackend ({ commit, dispatch }, backend) {
      commit('setBackend', backend)
      dispatch('persistPrefs')
    }
  }
}
