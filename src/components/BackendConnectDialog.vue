<template>
  <q-dialog v-model="isOpen" :persistent="persistent">
    <q-card class="mio-backend-card">
      <q-card-section>
        <div class="row items-center justify-between">
          <div>
            <div class="mio-backend-title">Backend connection</div>
            <div class="mio-backend-sub">MIOIDE UI connects to a separate MUMPS service over WebSocket.</div>
          </div>
          <q-badge v-if="statusTag" :label="statusTag" class="mio-backend-badge" />
        </div>
      </q-card-section>

      <q-separator />

      <q-card-section class="q-gutter-md">
        <q-input v-model="form.name" dense outlined label="Connection name" placeholder="Local Dev" />

        <div class="row q-col-gutter-sm">
          <div class="col-8">
            <q-input v-model="form.host" dense outlined label="Host / IP" placeholder="127.0.0.1" />
          </div>
          <div class="col-4">
            <q-input v-model="form.port" dense outlined label="Port" placeholder="7040" inputmode="numeric" />
          </div>
        </div>

        <div class="row q-col-gutter-sm">
          <div class="col-8">
            <q-input v-model="form.path" dense outlined label="WebSocket path" placeholder="/ws" />
          </div>
          <div class="col-4">
            <q-toggle v-model="form.secure" label="wss" />
          </div>
        </div>

        <div class="row items-center q-col-gutter-md">
          <div class="col">
            <q-toggle v-model="form.autoConnect" label="Auto-connect on startup" />
          </div>
          <div class="col-auto">
            <div class="mio-backend-url">{{ computedUrl || '—' }}</div>
          </div>
        </div>

        <div v-if="message" class="mio-backend-msg" :class="messageType">{{ message }}</div>
      </q-card-section>

      <q-separator />

      <q-card-actions align="right" class="q-gutter-sm">
        <q-btn flat label="Test" :loading="testing" @click="onTest" />
        <q-btn unelevated label="Connect" color="primary" :disable="!canConnect" :loading="connecting" @click="onConnect" />
        <q-btn v-if="!persistent" flat label="Cancel" @click="onCancel" />
      </q-card-actions>
    </q-card>
  </q-dialog>
</template>

<script>
function normalizePath (p) {
  const s = String(p || '').trim()
  if (!s) return '/ws'
  return s.startsWith('/') ? s : ('/' + s)
}

function buildUrl (b) {
  const host = String(b.host || '').trim()
  const port = String(b.port || '').trim()
  const path = normalizePath(b.path)
  if (!host || !port) return ''
  const proto = b.secure ? 'wss:' : 'ws:'
  return proto + '//' + host + ':' + port + path
}

async function testWebSocket (url, timeoutMs = 1600) {
  return await new Promise((resolve) => {
    let done = false
    let ws
    const finish = (ok, detail) => {
      if (done) return
      done = true
      try { if (ws) ws.close() } catch (e) {}
      resolve({ ok, detail })
    }
    const t = setTimeout(() => finish(false, 'Timeout'), timeoutMs)
    try {
      ws = new WebSocket(url)
    } catch (e) {
      clearTimeout(t)
      return finish(false, String(e))
    }
    ws.addEventListener('open', () => {
      clearTimeout(t)
      finish(true, 'Connected')
    })
    ws.addEventListener('error', () => {
      clearTimeout(t)
      finish(false, 'Error')
    })
  })
}

export default {
  name: 'BackendConnectDialog',
  props: {
    modelValue: { type: Boolean, default: false },
    value: { type: Object, default: () => ({}) },
    persistent: { type: Boolean, default: true }
  },
  emits: ['update:modelValue', 'connect', 'cancel'],
  data () {
    const v = this.value || {}
    return {
      isOpen: this.modelValue,
      form: {
        name: String(v.name || '').trim(),
        host: String(v.host || '').trim(),
        port: String(v.port || '').trim(),
        path: String(v.path || '/ws').trim() || '/ws',
        secure: !!v.secure,
        autoConnect: (v.autoConnect !== false)
      },
      testing: false,
      connecting: false,
      message: '',
      messageType: 'info',
      statusTag: ''
    }
  },
  watch: {
    modelValue (v) { this.isOpen = v },
    isOpen (v) { this.$emit('update:modelValue', v) }
  },
  computed: {
    computedUrl () {
      return buildUrl(this.form)
    },
    canConnect () {
      return !!this.computedUrl && !!String(this.form.name || '').trim()
    }
  },
  methods: {
    async onTest () {
      const url = this.computedUrl
      if (!url) {
        this.messageType = 'warn'
        this.message = 'Enter a valid host and port.'
        this.statusTag = 'Invalid'
        return
      }
      this.testing = true
      this.message = ''
      this.statusTag = 'Testing…'
      const res = await testWebSocket(url)
      this.testing = false
      this.messageType = res.ok ? 'ok' : 'err'
      this.message = res.ok ? 'Test successful.' : ('Test failed: ' + (res.detail || 'unknown'))
      this.statusTag = res.ok ? 'OK' : 'Failed'
    },
    async onConnect () {
      if (!this.canConnect) return
      this.connecting = true
      // Quick test before persisting.
      const res = await testWebSocket(this.computedUrl, 1400)
      if (!res.ok) {
        this.connecting = false
        this.messageType = 'err'
        this.message = 'Cannot connect: ' + (res.detail || 'unknown')
        this.statusTag = 'Failed'
        return
      }
      const payload = {
        name: String(this.form.name || '').trim(),
        host: String(this.form.host || '').trim(),
        port: String(this.form.port || '').trim(),
        path: normalizePath(this.form.path),
        secure: !!this.form.secure,
        autoConnect: (this.form.autoConnect !== false)
      }
      this.$emit('connect', payload)
      this.connecting = false
      this.isOpen = false
    },
    onCancel () {
      this.$emit('cancel')
      this.isOpen = false
    }
  }
}
</script>

<style scoped>
.mio-backend-card{
  width: min(720px, 94vw);
  border: 1px solid var(--mio-border);
  background: var(--mio-panel-bg);
}
.mio-backend-title{
  font-size: 14px;
  font-weight: 600;
}
.mio-backend-sub{
  font-size: 12px;
  opacity: 0.75;
  margin-top: 2px;
}
.mio-backend-url{
  font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace;
  font-size: 12px;
  opacity: 0.8;
}
.mio-backend-msg{
  font-size: 12px;
  padding: 8px 10px;
  border-radius: 6px;
  border: 1px solid var(--mio-border);
  background: rgba(255,255,255,0.03);
}
.mio-backend-msg.ok{ border-color: rgba(0, 180, 100, 0.35); }
.mio-backend-msg.warn{ border-color: rgba(255, 190, 0, 0.35); }
.mio-backend-msg.err{ border-color: rgba(255, 80, 80, 0.35); }
.mio-backend-badge{
  border: 1px solid var(--mio-border);
  background: rgba(255,255,255,0.06);
}
</style>
