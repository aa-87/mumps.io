<template>
  <span class="mio-tipwrap">
    <slot />

    <q-tooltip
      v-if="text"
      class="mio-qtip"
      anchor="top middle"
      self="bottom middle"
      :offset="[0, 10]"
      transition-show="jump-down"
      transition-hide="jump-up"
    >
      <div class="tiprow">
        <span class="t">{{ text }}</span>
        <span v-if="kbd" class="kbd">{{ kbd }}</span>
      </div>
    </q-tooltip>
  </span>
</template>

<script>
export default {
  name: 'MioTooltip',
  props: {
    text: { type: String, default: '' },
    kbd: { type: String, default: '' }
  }
}
</script>

<style scoped>
.mio-tipwrap{ display:inline-flex; align-items:center; }

/* QTooltip content styling */
.mio-qtip{
  font-size: 12px;
  border-radius: 10px;
  border: 1px solid color-mix(in srgb, var(--mio-border) 70%, transparent);
  background: color-mix(in srgb, var(--mio-panel) 92%, rgba(0,0,0,0.25));
  color: var(--mio-fg);
  box-shadow: var(--mio-shadow-md);
  padding: 8px 10px;
}
.tiprow{ display:flex; align-items:center; gap: 10px; white-space: nowrap; }
.kbd{
  font-family: var(--mio-mono);
  font-size: 11px;
  opacity: 0.9;
  border: 1px solid color-mix(in srgb, var(--mio-border) 65%, transparent);
  border-bottom-width: 2px;
  border-radius: 8px;
  padding: 2px 8px;
  background: color-mix(in srgb, var(--mio-panel2) 70%, transparent);
}
</style>
