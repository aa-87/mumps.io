<template>
  <transition name="fly">
    <div v-if="open" class="panel">
      <header class="head">
        <span>Notifications</span>
        <button class="x" @click="$emit('close')">×</button>
      </header>

      <div class="list">
        <div class="item" v-for="n in items" :key="n.id">
          <div class="t">{{ n.title }}</div>
          <div class="d">{{ n.detail }}</div>
        </div>
      </div>
    </div>
  </transition>
</template>

<script>
export default {
  name: 'NotificationCenter',
  props: { open: { type: Boolean, default: false } },
  computed: {
    items () {
      return [
        { id: 1, title: 'Workspace loaded', detail: 'Layout view applied.' },
        { id: 2, title: 'WebSocket connected', detail: 'Ready for RPC calls.' },
        { id: 3, title: 'Terminal ready', detail: 'Use Output/Terminal tabs.' }
      ]
    }
  }
}
</script>

<style scoped>
.panel{
  position: absolute;
  right: 10px;
  bottom: 36px;
  width: 320px;
  max-height: 320px;
  border-radius: 14px;
  border: 1px solid var(--mio-border);
  background: color-mix(in srgb, var(--mio-panel) 92%, transparent);
  box-shadow: 0 18px 45px rgba(0,0,0,0.45);
  overflow:hidden;
  z-index: 11000;
}
.head{
  height: 34px;
  display:flex;
  align-items:center;
  justify-content: space-between;
  padding: 0 10px;
  background: var(--mio-panel2);
  border-bottom: 1px solid var(--mio-border);
  font-size: 12px;
  opacity: 0.95;
}
.x{
  width: 26px;
  height: 26px;
  border-radius: 8px;
  border: 1px solid var(--mio-border);
  background: color-mix(in srgb, var(--mio-panel2) 60%, transparent);
  color: var(--mio-fg);
  cursor:pointer;
  transition: transform 120ms ease, background 120ms ease;
}
.x:hover{ background: color-mix(in srgb, var(--mio-panel2) 40%, transparent); transform: translateY(-1px); }
.list{ max-height: 286px; overflow:auto; }
.item{
  padding: 10px;
  border-bottom: 1px solid var(--mio-border);
}
.t{ font-size: 12px; margin-bottom: 4px; }
.d{ font-size: 12px; opacity: 0.7; }
.fly-enter-active, .fly-leave-active{ transition: transform 160ms ease, opacity 160ms ease; }
.fly-enter-from, .fly-leave-to{ transform: translateY(6px); opacity: 0; }

/* polish */
.panel{
  box-shadow: var(--mio-shadow2);
  border-radius: 16px;
  border: 1px solid var(--mio-hairline);
}
.item{
  border-radius: 12px;
  transition: background 140ms var(--mio-ease);
}
.item:hover{
  background: color-mix(in srgb, var(--mio-panel2) 45%, transparent);
}

</style>
