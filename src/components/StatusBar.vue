<template>
  <footer class="bar">
    <div class="left">
      <MioTooltip text="Git Branch">
        <span class="pill">
          <MioIcon name="git" />
          <span>main</span>
        </span>
      </MioTooltip>

      <MioTooltip text="WebSocket status">
        <span class="pill">
          <span class="dot" :class="{ off: wsLabel !== 'connected' }" />
          <span style="width:100px">WS: {{ wsLabel }}</span>
        </span>
      </MioTooltip>

      <div class="layout">
        <MioTooltip text="Layout" kbd="⌘B">
          <button class="btn2" @click="toggleLayout">
            <MioIcon name="settings" />
            <span>Layout</span>
          </button>
        </MioTooltip>

        <transition name="fly">
          <div v-if="layoutOpen" class="menu" @mousedown.stop>
            <div class="row">
              <span class="h">Layouts</span>
              <button class="x" @click="layoutOpen=false">×</button>
            </div>

            <div class="blk">
              <select class="sel" v-model="localSelected" @change="$emit('apply-view', localSelected)">
                <option value="">(select)</option>
                <option v-for="v in views" :key="v.name" :value="v.name">{{ v.name }}</option>
              </select>
            </div>

            <div class="blk">
              <input class="inp" v-model="newName" placeholder="Save current as…" />
              <button class="act" @click="save">
                <MioIcon name="save" />
                <span>Save</span>
              </button>
            </div>

            <div class="blk">
              <button class="act subtle" :disabled="!localSelected" @click="del">
                <MioIcon name="close" />
                <span>Delete</span>
              </button>
            </div>

            <div class="tip">Saved layouts store panel sizes + visible regions.</div>
          </div>
        </transition>
      </div>
    </div>

    <div class="right">
      <MioTooltip text="Notifications" kbd="⌘⇧M">
        <button class="btn" @click="$emit('notify')">
          <MioIcon name="bell" />
          <span v-if="count" class="n">{{ count }}</span>
        </button>
      </MioTooltip>

      <span class="pill mono">YottaDB</span><span class="sep" />
      <span class="pill mono">UTF-8</span><span class="sep" />
      <span class="pill mono">Ln {{ cursor.line }}, Col {{ cursor.col }}</span>
    </div>
  </footer>
</template>


<script>
import MioIcon from 'components/Icon.vue'
import MioTooltip from 'components/MioTooltip.vue'

export default {
  name: 'StatusBar',
  components: { MioIcon, MioTooltip },
  props: {
    count: { type: Number, default: 0 },
    views: { type: Array, default: () => [] },
    selectedView: { type: String, default: '' },
    wsState: { type: String, default: 'connected' }
  },
  data () {
    return { layoutOpen: false, newName: '', localSelected: this.selectedView }
  },
  computed: {
    cursor () {
      const id = this.$store.getters['editor/active']
      const cur = this.$store.state.editor.cursor || {}
      return cur[id] || { line: 1, col: 1 }
    },
    wsLabel () {
      if (this.wsState === 'open' || this.wsState === 'connected') return 'connected'
      if (this.wsState === 'connecting') return 'connecting'
      if (this.wsState === 'closed') return 'closed'
      return this.wsState || 'unknown'
    }
  },
  watch: {
    selectedView (v) { this.localSelected = v }
  },
  methods: {
    toggleLayout () { this.layoutOpen = !this.layoutOpen },
    save () {
      const n = this.newName.trim()
      if (!n) return
      this.$emit('save-view', n)
      this.localSelected = n
      this.newName = ''
    },
    del () {
      if (!this.localSelected) return
      this.$emit('delete-view', this.localSelected)
      this.localSelected = ''
    }
  }
}
</script>

<style scoped>
.bar{
  height: 26px;
  display:flex;
  align-items:center;
  justify-content: space-between;
  padding: 0 8px;
  border-top: 1px solid var(--mio-border);
  background-color: var(--mio-statusbg);
  color: var(--mio-fg);
  position: relative;
  width: 100%;
  flex: 0 0 auto;
}
.left, .right{ display:flex; align-items:center; gap: 8px; }
.pill{
  height: 20px;
  border-radius: 8px;
  border: 1px solid color-mix(in srgb, var(--mio-border) 80%, transparent);
  background: color-mix(in srgb, var(--mio-panel2) 55%, transparent);
  padding: 0 8px;
  display:inline-flex;
  align-items:center;
  gap: 6px;
  font-size: 12px;
  opacity: 0.95;
}
.mono{ font-family: var(--mio-mono); font-size: 11px; opacity: 0.85; }
.dot{
  width: 7px; height: 7px; border-radius: 999px;
  background: rgba(60, 210, 90, 0.95);
  box-shadow: 0 0 0 2px rgba(60, 210, 90, 0.18);
  animation: pulse 1.8s ease-in-out infinite;
}
.dot.off{
  background: rgba(230, 170, 40, 0.95);
  box-shadow: 0 0 0 2px rgba(230, 170, 40, 0.18);
  animation: none;
}
@keyframes pulse { 0%,100%{ transform: scale(0.95); opacity: 0.75; } 50%{ transform: scale(1); opacity: 1; } }

.btn{
  position: relative;
  width: 100%;
  flex: 0 0 auto;
  width: 30px;
  height: 22px;
  border-radius: 8px;
  border: 1px solid color-mix(in srgb, var(--mio-border) 80%, transparent);
  background: color-mix(in srgb, var(--mio-panel2) 55%, transparent);
  color: var(--mio-fg);
  cursor: pointer;
  display:inline-flex;
  align-items:center;
  justify-content:center;
  transition: transform 120ms ease, background 120ms ease;
}
.btn:hover{ background: color-mix(in srgb, var(--mio-panel2) 40%, transparent); transform: translateY(-1px); }
.btn:active{ transform: translateY(0) scale(0.98); }
.n{
  position:absolute; top:-5px; right:-5px;
  min-width:16px; height:16px; padding: 0 4px;
  border-radius: 999px;
  background: rgba(255,60,60,0.92);
  color: #fff;
  font-size: 10px;
  display:inline-flex; align-items:center; justify-content:center;
  border: 1px solid rgba(255,255,255,0.25);
}

/* Layout dropdown */
.layout{ position: relative;
  width: 100%;
  flex: 0 0 auto; }
.btn2{
  height: 22px;
  border-radius: 8px;
  border: 1px solid color-mix(in srgb, var(--mio-border) 80%, transparent);
  background: color-mix(in srgb, var(--mio-panel2) 55%, transparent);
  color: var(--mio-fg);
  cursor: pointer;
  display:inline-flex;
  align-items:center;
  gap: 6px;
  padding: 0 8px;
  font-size: 12px;
  transition: transform 120ms ease, background 120ms ease;
}
.btn2:hover{ background: color-mix(in srgb, var(--mio-panel2) 40%, transparent); transform: translateY(-1px); }

.menu{
  position: absolute;
  left: 0;
  bottom: 30px;
  width: 320px;
  border-radius: 14px;
  border: 1px solid var(--mio-border);
  background: color-mix(in srgb, var(--mio-panel) 92%, transparent);
  box-shadow: 0 18px 45px rgba(0,0,0,0.45);
  overflow:hidden;
  z-index: 12000;
}
.row{
  height: 34px;
  display:flex;
  align-items:center;
  justify-content: space-between;
  padding: 0 10px;
  background: var(--mio-panel2);
  border-bottom: 1px solid var(--mio-border);
}
.h{ font-size: 12px; opacity: 0.9; }
.x{
  width: 26px; height: 26px; border-radius: 8px;
  border: 1px solid var(--mio-border);
  background: color-mix(in srgb, var(--mio-panel2) 60%, transparent);
  color: var(--mio-fg);
  cursor:pointer;
}
.blk{ padding: 10px; display:flex; gap: 8px; align-items:center; border-bottom: 1px solid var(--mio-border); }
.sel, .inp{
  height: 28px; border-radius: 10px;
  border: 1px solid var(--mio-border);
  background: color-mix(in srgb, var(--mio-panel2) 60%, transparent);
  color: var(--mio-fg);
  font-size: 12px; padding: 0 10px;
  outline:none; flex: 1;
}
.act{
  height: 28px; border-radius: 10px;
  border: 1px solid var(--mio-border);
  background: color-mix(in srgb, var(--mio-panel2) 60%, transparent);
  color: var(--mio-fg);
  font-size: 12px; padding: 0 10px;
  cursor: pointer;
  transition: transform 120ms ease, background 120ms ease;
  display:inline-flex; align-items:center; gap: 8px;
}
.act:hover{ background: color-mix(in srgb, var(--mio-panel2) 45%, transparent); transform: translateY(-1px); }
.act:active{ transform: translateY(0) scale(0.98); }
.act.subtle{ opacity: 0.85; }
.act:disabled{ opacity: 0.4; cursor:not-allowed; transform:none; }
.tip{ padding: 10px; font-size: 12px; opacity: 0.7; }

.fly-enter-active, .fly-leave-active{ transition: transform 160ms ease, opacity 160ms ease; }
.fly-enter-from, .fly-leave-to{ transform: translateY(6px); opacity: 0; }

.sep{
  width: 1px;
  height: 14px;
  background: var(--mio-hairline2);
  opacity: 0.85;
  border-radius: 1px;
}
.barx{
  background: linear-gradient(180deg,
    color-mix(in srgb, var(--mio-accent) 18%, var(--mio-panel) 82%),
    color-mix(in srgb, var(--mio-accent) 8%, var(--mio-panel) 92%)
  );
}

</style>
