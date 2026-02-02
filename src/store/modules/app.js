export default {
  namespaced: true,
  state: () => ({
    ready: false,
    title: 'MIO IDE',
    status: 'Ready'
  }),
  mutations: {
    setReady (state, v) { state.ready = v },
    setStatus (state, v) { state.status = v }
  },
  actions: {
    init ({ commit }) {
      commit('setReady', true)
      commit('setStatus', 'Ready')
    }
  }
}
