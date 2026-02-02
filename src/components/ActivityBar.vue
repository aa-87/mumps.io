<template>
  <nav class="act2">
    <div class="top">
      <MioTooltip
        v-for="a in items"
        :key="a.id"
        :text="a.title"
        :kbd="a.kbd"
      >
      <button
        class="btn mio-hover"
        :class="{ active: active === a.id }"
        @click="$emit('select', a.id)"
      >
        <MioIcon :name="a.icon" />
        <span v-if="a.badge" class="badge">{{ a.badge }}</span>
      </button>
    </MioTooltip>
    </div>

    <div class="spacer" />

    <div class="bottom">
      <MioTooltip text="Accounts" kbd="⌘⇧A"><button class="btn mini">
        <MioIcon name="account" />
      </button></MioTooltip>
      <MioTooltip text="Manage" kbd="⌘,"><button class="btn mini">
        <MioIcon name="settings" />
      </button>
    </MioTooltip>
    </div>
  </nav>
</template>

<script>
import MioIcon from 'components/Icon.vue'
import MioTooltip from 'components/MioTooltip.vue'

export default {
  name: 'ActivityBar',
  components: { MioIcon, MioTooltip },
  props: { active: { type: String, required: true } },
  computed: {
    items () {
      return [
        { id: 'explorer', title: 'Explorer', icon: 'explorer', badge: 2, kbd: '⌘⇧E' },
        { id: 'search', title: 'Search', icon: 'search', kbd: '⌘⇧F' },
        { id: 'scm', title: 'Source Control', icon: 'git', badge: 1, kbd: '⌃⇧G' },
        { id: 'extensions', title: 'Extensions', icon: 'extensions', kbd: '⌘⇧X' },
        { id: 'settings', title: 'Settings', icon: 'settings', kbd: '⌘,' }
      ]
    }
  }
}
</script>

<style scoped>
.act2{
  width: 48px;
  background: var(--mio-panel2);
  border-right: 1px solid var(--mio-border);
  display: flex;
  flex-direction: column;
  padding: 6px 0;
  gap: 6px;
}

.top, .bottom { display:flex; flex-direction: column; gap: 6px; }
.spacer{ flex: 1; }
.btn {
  position: relative;
  width: 36px;
  height: 36px;
  margin: 0 auto;
  border-radius: 10px;
  border: 1px solid var(--mio-border);
  background: color-mix(in srgb, var(--mio-panel2) 70%, transparent);
  color: var(--mio-fg);
  display: inline-flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: transform 120ms ease, background 120ms ease, border-color 120ms ease;
  overflow:hidden;
}
.btn:hover { background: color-mix(in srgb, var(--mio-panel2) 55%, transparent); transform: translateY(-1px); }
.btn.active { border-color: color-mix(in srgb, var(--mio-accent) 45%, transparent); background: color-mix(in srgb, var(--mio-accent) 22%, transparent); }
.btn:active { transform: translateY(0) scale(0.98); }
.btn::after{
  content:'';
  position:absolute;
  inset:-40%;
  background: radial-gradient(circle at 30% 30%, rgba(255,255,255,0.18), transparent 55%);
  opacity:0;
  transition: opacity 160ms ease;
}
.btn:hover::after{ opacity: 1; }
.btn.mini{ height: 30px; border-radius: 10px; }

.badge{
  position:absolute;
  top:2px;
  right:2px;
  min-width:16px;
  height:16px;
  padding:0 4px;
  border-radius:999px;
  background: color-mix(in srgb, var(--mio-accent) 75%, transparent);
  border:1px solid color-mix(in srgb, var(--mio-accent) 45%, transparent);
  color: #fff;
  font-size:10px;
  line-height:14px;
  display:inline-flex;
  align-items:center;
  justify-content:center;
  box-shadow: 0 6px 14px rgba(0,0,0,0.20);
  animation: pop 220ms ease-out;
}
@keyframes pop{ from{ transform: scale(0.7); opacity:0; } to { transform: scale(1); opacity:1; } }

/* polish */
.rail{
  background: color-mix(in srgb, var(--mio-panel) 96%, transparent);
  box-shadow: inset -1px 0 0 var(--mio-hairline);
}
.btn.active{
  box-shadow: inset 2px 0 0 color-mix(in srgb, var(--mio-accent) 65%, transparent);
  background: color-mix(in srgb, var(--mio-panel2) 55%, transparent);
}
.btn.active::after{
  opacity: 1;
}

</style>
