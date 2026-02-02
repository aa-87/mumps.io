<template>
  <header class="titlebar">
    <div class="left">
      <div class="dot" />
      <div class="brand">{{ title }}</div>
    </div>

    <div class="center">
      <div class="status">{{ status }}</div>
    </div>

    <div class="right">
      <button class="btn" @click="pulse">Pulse</button>
    </div>
  </header>
</template>

<script>
export default {
  name: 'TitleBar',
  computed: {
    title () {
      return (this.$store && this.$store.state && this.$store.state.app)
        ? this.$store.state.app.title
        : 'MIO IDE'
    },
    status () {
      const backendName = (this.$store && this.$store.getters)
        ? this.$store.getters['layout/backendName']
        : ''
      if (backendName) return backendName
      return (this.$store && this.$store.state && this.$store.state.app)
        ? this.$store.state.app.status
        : ''
    }
  },
  methods: {
    pulse () {
      // tiny animation hook without relying on extra libs
      const el = this.$el
      el.classList.remove('pulse')
      // force reflow
      void el.offsetWidth
      el.classList.add('pulse')
    }
  }
}
</script>

<style scoped>
.titlebar {
  height: 34px;
  display: grid;
  grid-template-columns: 240px 1fr 240px;
  align-items: center;
  background: var(--mio-titlebar-bg);
  border-bottom: 1px solid var(--mio-border);
  user-select: none;
}

.left, .center, .right {
  display: flex;
  align-items: center;
  height: 100%;
}

.left {
  padding: 0 10px;
  gap: 10px;
}

.dot {
  width: 10px;
  height: 10px;
  border-radius: 999px;
  background: var(--mio-accent);
  box-shadow: 0 0 0 2px rgba(0, 122, 204, 0.25);
}

.brand {
  font-size: 12px;
  letter-spacing: 0.3px;
  color: #e6e6e6;
}

.center {
  justify-content: center;
}

.status {
  font-size: 12px;
  opacity: 0.75;
}

.right {
  justify-content: flex-end;
  padding: 0 10px;
}

.btn {
  border: 1px solid var(--mio-border);
  background: #1f1f1f;
  color: var(--mio-fg);
  font-size: 12px;
  padding: 4px 10px;
  border-radius: 6px;
  cursor: pointer;
  transition: transform 120ms ease, background 120ms ease;
}
.btn:hover { background: #232323; transform: translateY(-1px); }
.btn:active { transform: translateY(0px) scale(0.98); }

.titlebar.pulse {
  animation: pulse 220ms ease-out;
}

@keyframes pulse {
  0% { box-shadow: inset 0 0 0 rgba(0,122,204,0); }
  100% { box-shadow: inset 0 -2px 0 rgba(0,122,204,0.65); }
}
</style>
