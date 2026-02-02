/* src/store/modules/editor.js
   Minimal VS Code-like editor tab state (placeholder for Monaco integration).
   Provides tab open/close/reorder and a tiny "openFile" abstraction used by Explorer/Search.
*/
function byId (arr, id) { return arr.findIndex(t => t.id === id) }

export default {
  namespaced: true,
  state: () => ({
    docs: {
      welcome: `# Welcome to MIO IDE\n\nThis is the UI prototype.\n\n- ⌘⇧P: Command Palette (stub)\n- ⌘W: Close Tab\n\nNext: backend wiring for filesystem + YottaDB routines.\n`,
      main: `; main.m\n; Example MUMPS routine\nmain\n  write \"Hello from MIO IDE\",!\n  quit\n`
    },
    // Monaco-related state (lightweight):
    // - cursor positions for status bar
    // - viewState per document so switching tabs feels like VS Code
    cursor: {
      welcome: { line: 1, col: 1 },
      main: { line: 1, col: 1 }
    },
    viewState: {},
    tabs: [
      { id: 'welcome', title: 'Welcome.md', dirty: false },
      { id: 'main', title: 'main.m', dirty: true }
    ],
    active: 'welcome'
  }),

  getters: {
    tabs: (s) => s.tabs,
    active: (s) => s.active,
    activeTab: (s) => s.tabs.find(t => t.id === s.active) || null
  },

  mutations: {
    ensureDoc (s, { id, content }) {
      if (s.docs && s.docs[id] == null) s.docs[id] = content || ''
    },
    setDoc (s, { id, content }) {
      if (!s.docs) s.docs = {}
      s.docs[id] = content || ''
    },
    setCursor (s, { id, line, col }) {
      if (!s.cursor) s.cursor = {}
      s.cursor[id] = { line: line || 1, col: col || 1 }
    },
    setViewState (s, { id, viewState }) {
      if (!s.viewState) s.viewState = {}
      s.viewState[id] = viewState || null
    },
    setActive (s, id) { s.active = id },

    closeTab (s, id) {
      const idx = byId(s.tabs, id)
      if (idx < 0) return
      s.tabs.splice(idx, 1)
      if (s.active === id) s.active = s.tabs[0]?.id || ''
    },

    addTab (s, tab) {
      const idx = byId(s.tabs, tab.id)
      if (idx >= 0) {
        const [t] = s.tabs.splice(idx, 1)
        s.tabs.unshift({ ...t, ...tab })
      } else {
        s.tabs.unshift(tab)
      }
      s.active = tab.id
    },

    setDirty (s, { id, dirty }) {
      const idx = byId(s.tabs, id)
      if (idx >= 0) s.tabs[idx].dirty = !!dirty
    },

    reorderTabs (s, { from, to }) {
      if (from === to) return
      const a = s.tabs.slice()
      const [m] = a.splice(from, 1)
      a.splice(to, 0, m)
      s.tabs = a
    }
  },

  actions: {
    openFile ({ commit }, { id, title, content }) {
      commit('ensureDoc', { id, content })
      commit('addTab', { id, title, dirty: false })
    }
  }
}
