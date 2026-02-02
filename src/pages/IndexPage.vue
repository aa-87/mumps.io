<template>
  <q-page class="mio-page">
    <div class="layout mio-fade-in">
      <TitleBar />
      <MainLayout />
    </div>

    <BackendConnectDialog
      v-model="showBackendDialog"
      :value="backend"
      :persistent="backendRequired"
      @connect="onBackendConnect"
      @cancel="onBackendCancel"
    />
  </q-page>
</template>

<script>
import TitleBar from 'components/TitleBar.vue'
import MainLayout from 'components/MainLayout.vue'
import BackendConnectDialog from 'components/BackendConnectDialog.vue'

export default {
  name: 'IndexPage',
  components: {
    TitleBar,
    MainLayout,
    BackendConnectDialog
  },
  data () {
    return {
      showBackendDialog: false,
      backendRequired: false
    }
  },
  computed: {
    backend () {
      return (this.$store && this.$store.state && this.$store.state.layout && this.$store.state.layout.dock)
        ? this.$store.state.layout.dock.backend
        : {}
    }
  },
  mounted () {
    // Prompt if no backend profile configured.
    const b = this.backend || {}
    const has = String(b.host || '').trim() && String(b.port || '').trim() && String(b.name || '').trim()
    if (!has) {
      this.backendRequired = true
      this.showBackendDialog = true
    }
  },
  methods: {
    onBackendConnect (cfg) {
      this.backendRequired = false
      this.$store.dispatch('layout/setBackend', cfg)
      // Connect using the configured backend.
      this.$store.dispatch('ws/connectFromLayout')
    },
    onBackendCancel () {
      // If the dialog is not persistent (there was an existing config), leave it.
      this.showBackendDialog = false
    }
  }
}
</script>

<style scoped>
/*
  Quasar's <q-page> can add its own padding/min-height.
  We run a fully custom VS Code-like shell, so force a
  deterministic viewport-sized flex column.
*/
.mio-page{
  padding: 0;
  height: 100vh;
  min-height: 100vh;
  overflow: hidden;
}

.layout{
  height: 100%;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}
</style>
