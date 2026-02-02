import { createStore } from 'vuex'

import app from './modules/app'
import layout from './modules/layout'
import editor from './modules/editor'
import ws from './modules/ws'

// Standalone Vuex store instance.
// We install it into the Quasar app from src/boot/init.js so components can use this.$store.
const Store = createStore({
  modules: { app, layout, editor, ws },
  // Strict mode adds overhead; keep it for dev only
  strict: process.env.DEV === true
})

export default Store
