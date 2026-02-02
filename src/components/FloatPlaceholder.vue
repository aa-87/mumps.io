<template>
  <div class="pad">
    <div class="hint">Floating: {{ title }}</div>
    <div class="mini">Dock this panel back or save as a view.</div>
  </div>
</template>

<script>
export default {
  name: 'FloatPlaceholder',
  props: {
    title: { type: String, required: true }
  }
}
</script>

<style scoped>
.pad { padding: 10px; }
.hint { font-size: 12px; opacity: 0.9; margin-bottom: 8px; }
.mini { font-size: 12px; opacity: 0.7; }
</style>
