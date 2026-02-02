import { boot } from 'quasar/wrappers'
import store from 'src/store'

export default boot(({ app }) => {
  // Explicitly install Vuex (Quasar CLI defaults to Pinia).
  app.use(store)

  // Fast startup: keep boot synchronous; avoid noisy watchers.
  store.dispatch('app/init')

  // Load persisted UI prefs/views once.
  store.dispatch('layout/loadPrefs')
  store.dispatch('layout/loadViews')

  // Connect to IDE backend (MUMPS) over WebSocket *only* if a backend profile is configured.
  // A startup dialog (IndexPage) can prompt for connection details.
  store.dispatch('ws/connectFromLayout')



})
