<template>
  <transition name="fade">
    <div v-if="open" class="overlay" @mousedown.self="$emit('close')">
      <div class="box" @mousedown.stop>
        <div class="row">
          <MioIcon name="command" />
          <input
            ref="inp"
            class="inp"
            v-model="q"
            placeholder="Type a command…"
            @keydown.esc.prevent="$emit('close')"
            @keydown.enter.prevent="runHighlighted"
          />
          <span class="kbd">Esc</span>
        </div>

        <div class="list">
          <div
            v-for="(c, i) in filtered"
            :key="c.id"
            class="item"
            :class="{ hi: i === hi }"
            @mouseenter="hi = i"
            @mousedown.prevent="run(c)"
          >
            <span class="label">{{ c.label }}</span>
            <span class="hint">{{ c.hint }}</span>
          </div>

          <div v-if="filtered.length === 0" class="empty">
            No matching commands.
          </div>
        </div>
      </div>
    </div>
  </transition>
</template>

<script>
import MioIcon from 'components/Icon.vue'

export default {
  name: 'CommandPalette',
  components: { MioIcon },
  props: { open: { type: Boolean, default: false } },
  data () {
    return { q: '', hi: 0 }
  },
  computed: {
    commands () {
      return [
        { id: 'toggleTheme', label: 'Toggle Theme', hint: 'UI' },
        { id: 'toggleSidebar', label: 'Toggle Sidebar', hint: 'Layout' },
        { id: 'toggleRight', label: 'Toggle Secondary Side Bar', hint: 'Layout' },
        { id: 'focusTerminal', label: 'Focus Terminal', hint: 'Panel' },
        { id: 'focusOutput', label: 'Focus Output', hint: 'Panel' },
        { id: 'run', label: 'Run', hint: 'Actions' },
        { id: 'debug', label: 'Debug', hint: 'Actions' },
        { id: 'stop', label: 'Stop', hint: 'Actions' }
      ]
    },
    filtered () {
      const q = this.q.trim().toLowerCase()
      if (!q) return this.commands
      return this.commands.filter(c => (c.label + ' ' + c.hint).toLowerCase().includes(q))
    }
  },
  watch: {
    open (v) {
      if (v) {
        this.q = ''
        this.hi = 0
        this.$nextTick(() => this.$refs.inp?.focus())
      }
    }
  },
  methods: {
    run (c) {
      this.$emit('run', c.id)
      this.$emit('close')
    },
    runHighlighted () {
      const c = this.filtered[this.hi]
      if (c) this.run(c)
    }
  }
}
</script>

<style scoped>
.overlay{
  position: absolute;
  inset: 0;
  background: rgba(0,0,0,0.45);
  backdrop-filter: blur(10px);
  display:flex;
  align-items:flex-start;
  justify-content:center;
  padding-top: 90px;
  z-index: 12000;
}
.box{
  width: min(720px, calc(100% - 24px));
  border-radius: 16px;
  border: 1px solid var(--mio-border);
  background: color-mix(in srgb, var(--mio-panel) 90%, transparent);
  box-shadow: 0 18px 55px rgba(0,0,0,0.45);
  overflow:hidden;
  animation: drop 160ms ease-out;
}
@keyframes drop { from { transform: translateY(-6px); opacity:0; } to { transform: translateY(0); opacity:1; } }
.row{
  height: 44px;
  display:flex;
  align-items:center;
  gap: 10px;
  padding: 0 12px;
  border-bottom: 1px solid var(--mio-border);
  background: color-mix(in srgb, var(--mio-panel2) 75%, transparent);
}
.inp{
  flex:1;
  height: 30px;
  border-radius: 10px;
  border: 1px solid var(--mio-border);
  background: color-mix(in srgb, var(--mio-panel2) 60%, transparent);
  color: var(--mio-fg);
  padding: 0 10px;
  outline:none;
  font-size: 13px;
}
.kbd{
  font-size: 11px;
  opacity: 0.7;
  border: 1px solid var(--mio-border);
  border-bottom-width: 2px;
  border-radius: 8px;
  padding: 4px 8px;
  background: color-mix(in srgb, var(--mio-panel2) 55%, transparent);
}
.list{ max-height: 340px; overflow:auto; }
.item{
  display:flex;
  justify-content: space-between;
  gap: 10px;
  padding: 10px 12px;
  cursor:pointer;
  transition: background 120ms ease;
}
.item:hover, .item.hi{
  background: color-mix(in srgb, var(--mio-accent) 12%, transparent);
}
.label{ font-size: 13px; }
.hint{ font-size: 12px; opacity: 0.65; }
.empty{ padding: 12px; opacity: 0.7; }
.fade-enter-active, .fade-leave-active { transition: opacity 140ms ease; }
.fade-enter-from, .fade-leave-to { opacity: 0; }
</style>
