<template>
  <div class="tabs">
    <div class="left">
      <div class="tablist">
        <div
          v-for="t in tabs"
          :key="t.id"
          class="tab mio-hover"
          :class="{ active: t.id === active }"
          @mousedown.prevent="$emit('select', t.id)"
        >
          <span class="dot" v-if="t.dirty" />
          <span class="name">{{ t.title }}</span>

          <MioTooltip text="Close Tab" kbd="⌘W">
            <button class="x" @click.stop="$emit('close', t.id)">×</button>
          </MioTooltip>
        </div>
      </div>
    </div>

    <div class="right">
      <MioTooltip text="Command Palette" kbd="⌘⇧P">
        <button class="mini" @click="$emit('command')">
          <MioIcon name="search" />
        </button>
      </MioTooltip>
    </div>
  </div>
</template>



<script>
import MioIcon from 'components/Icon.vue'
import MioTooltip from 'components/MioTooltip.vue'

export default {
  name: 'EditorTabs',
  components: { MioIcon, MioTooltip },
  props: {
    tabs: { type: Array, required: true },
    active: { type: String, required: true },
    theme: { type: String, default: 'dark' }
  },
  data () {
    return { dragFrom: null }
  },
  computed: {
    themeIcon () { return this.theme === 'light' ? 'moon' : 'sun' },
    themeTitle () { return this.theme === 'light' ? 'Switch to dark theme' : 'Switch to light theme' }
  },
  methods: {
    onDragStart (i) { this.dragFrom = i },
    onDrop (to) {
      if (this.dragFrom === null) return
      this.$emit('reorder', { from: this.dragFrom, to })
      this.dragFrom = null
    }
  }
}
</script>

<style scoped>
.tabs {
  height: 34px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: var(--mio-panel2);
  border-bottom: 1px solid var(--mio-border);
  user-select: none;
}
.strip { display: flex; align-items: center; gap: 6px; padding: 0 8px; overflow: auto; }
.tab {
  height: 26px;
  border-radius: 8px;
  border: 1px solid var(--mio-border);
  background: color-mix(in srgb, var(--mio-panel2-inactive) 70%, transparent);
  color: var(--mio-fg);
  font-size: 12px;
  padding: 0 10px;
  display: inline-flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  transition: transform 120ms ease, background 120ms ease, border-color 120ms ease;
  white-space: nowrap;
}
.tab:hover { background: color-mix(in srgb, var(--mio-panel2) 55%, transparent); transform: translateY(-1px); }
.tab.active {
   border-color: color-mix(in srgb, var(--mio-accent) 45%, transparent);
  background: color-mix(in srgb, var(--mio-accent) 20%, transparent);

  }
.dot { width: 7px; height: 7px; border-radius: 999px; background: color-mix(in srgb, var(--mio-accent) 70%, transparent); }
.name { opacity: 0.95; }
.x {
  width: 18px;
  height: 18px;
  border-radius: 6px;
  border: 1px solid var(--mio-border);
  background: color-mix(in srgb, var(--mio-panel2) 60%, transparent);
  color: var(--mio-fg);
  cursor: pointer;
  line-height: 16px;
  text-align: center;
  transition: transform 120ms ease, background 120ms ease;
}
.x:hover { background: color-mix(in srgb, var(--mio-panel2) 40%, transparent); transform: scale(1.03); }
.actions { display: inline-flex; align-items: center; gap: 6px; padding: 0 8px; }
.btn {
  width: 30px;
  height: 26px;
  border-radius: 8px;
  border: 1px solid var(--mio-border);
  background: color-mix(in srgb, var(--mio-panel2) 70%, transparent);
  color: var(--mio-fg);
  cursor: pointer;
  transition: transform 120ms ease, background 120ms ease;
}
.btn:hover { background: color-mix(in srgb, var(--mio-panel2) 50%, transparent); transform: translateY(-1px); }
.btn:active { transform: translateY(0) scale(0.98); }

/* polish */
.tab{
  transition: background 140ms var(--mio-ease), transform 140ms var(--mio-ease);
}
.tab:hover{ background: color-mix(in srgb, var(--mio-panel2) 45%, transparent); transform: translateY(-1px); }
.tab.active{
  box-shadow: inset 0 -2px 0 color-mix(in srgb, var(--mio-accent) 70%, transparent);
}
.close{
  opacity: 0.7;
  transform: scale(0.92);
  transition: opacity 120ms var(--mio-ease), transform 120ms var(--mio-ease), background 120ms var(--mio-ease);
}
.tab:hover .close{ opacity: 1; transform: scale(1); }
.close:hover{ background: color-mix(in srgb, var(--mio-panel2) 55%, transparent); }

</style>
