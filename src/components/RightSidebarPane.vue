<template>
  <section class="side">
    <header class="head">
      <div class="left"><MioIcon name="debug" /></div>
      <MioTooltip text="Pin">
      <button class="hbtn"><MioIcon name="command" /></button>
      </MioTooltip>
      
    </header>

    <div class="body">
      <div class="pad">
        <div class="hint">{{ title }}</div>
        <div class="mini">Secondary side bar placeholder.</div>
      </div>
    </div>
  </section>
</template>

<script>
import MioIcon from 'components/Icon.vue'
import MioTooltip from 'components/MioTooltip.vue'

export default {
  components: { MioIcon, MioTooltip },
  name: 'RightSidebarPane',
  props: {
    active: { type: String, default: 'outline' }
  },
  computed: {
    title () {
      if (this.active === 'outline') return 'OUTLINE'
      if (this.active === 'problems') return 'PROBLEMS'
      if (this.active === 'references') return 'REFERENCES'
      return (this.active || 'PROBLEMS').toUpperCase()
    }
  }
}
</script>

<style scoped>
.side {
  height: 100%;
  display: flex;
  flex-direction: column;
  background: var(--mio-panel);
  border-left: 1px solid var(--mio-border);
}
.head {
  height: 34px;
  display: flex;
  align-items: center;
  padding: 0 10px;
  border-bottom: 1px solid var(--mio-border);
  background: var(--mio-panel2);
  user-select: none;
}
.title { font-size: 12px; letter-spacing: 0.4px; opacity: 0.9; }
.body { flex: 1; min-height: 0; overflow: auto; }
.pad { padding: 10px; }
.hint { font-size: 12px; opacity: 0.9; margin-bottom: 8px; }
.mini { font-size: 12px; opacity: 0.7; }

.left{display:flex;align-items:center;gap:8px;}
.hbtn{width:26px;height:26px;border-radius:8px;border:1px solid var(--mio-border);background:color-mix(in srgb, var(--mio-panel2) 60%, transparent);color:var(--mio-fg);cursor:pointer;transition:transform 120ms ease, background 120ms ease;}
.hbtn:hover{background:color-mix(in srgb, var(--mio-panel2) 40%, transparent);transform:translateY(-1px);}
</style>
