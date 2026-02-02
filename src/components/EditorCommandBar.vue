<template>
  <div class="bar">
    <MioTooltip text="Run" kbd="F5">
      <button class="btn" @click="$emit('run')"><MioIcon name="play" /><span>Run</span></button>
    </MioTooltip>

    <MioTooltip text="Debug" kbd="⇧F5">
      <button class="btn" @click="$emit('debug')"><MioIcon name="debug" /><span>Debug</span></button>
    </MioTooltip>

    <MioTooltip text="Stop" kbd="⌘.">
      <button class="btn danger" @click="$emit('stop')"><MioIcon name="stop" /><span>Stop</span></button>
    </MioTooltip>

    <div class="sep" />

    <MioTooltip text="Format" kbd="⇧⌥F">
      <button class="btn" @click="$emit('format')"><MioIcon name="format" /><span>Format</span></button>
    </MioTooltip>

    <MioTooltip text="Save" kbd="⌘S">
      <button class="btn" @click="$emit('save')"><MioIcon name="save" /><span>Save</span></button>
    </MioTooltip>

    <div class="spacer" />

    <span class="pill" :class="{ busy }"><span class="dot" /><span>{{ busy ? 'Running…' : 'Idle' }}</span></span>
  </div>
</template>

<script>
import MioIcon from 'components/Icon.vue'
import MioTooltip from 'components/MioTooltip.vue'

export default {
  name: 'EditorCommandBar',
  components: { MioIcon, MioTooltip },
  props: { busy: { type: Boolean, default: false } }
}
</script>

<style scoped>
.bar{ height: 34px; display:flex; align-items:center; gap: 8px; padding: 0 10px; border-bottom: 1px solid var(--mio-border); background: color-mix(in srgb, var(--mio-panel2) 70%, transparent); }
.btn{ height: 26px; border-radius: 10px; border: 1px solid var(--mio-border); background: color-mix(in srgb, var(--mio-panel2) 60%, transparent); color: var(--mio-fg); cursor:pointer; display:inline-flex; align-items:center; gap: 8px; padding: 0 10px; font-size: 12px; transition: transform 120ms ease, background 120ms ease; }
.btn:hover{ background: color-mix(in srgb, var(--mio-panel2) 45%, transparent); transform: translateY(-1px); }
.btn:active{ transform: translateY(0) scale(0.98); }
.btn.danger{ border-color: color-mix(in srgb, rgba(255,60,60,0.8) 60%, var(--mio-border)); background: color-mix(in srgb, rgba(255,60,60,0.22) 60%, transparent); }
.sep{ width: 1px; height: 18px; background: var(--mio-border); opacity: 0.8; }
.spacer{ flex:1; }
.pill{ height: 22px; border-radius: 999px; border: 1px solid var(--mio-border); background: color-mix(in srgb, var(--mio-panel2) 55%, transparent); padding: 0 10px; display:inline-flex; align-items:center; gap: 8px; font-size: 12px; opacity: 0.9; }
.dot{ width: 7px; height: 7px; border-radius: 999px; background: rgba(110,110,110,0.8); }
.pill.busy .dot{ background: color-mix(in srgb, var(--mio-accent) 70%, transparent); box-shadow: 0 0 0 2px color-mix(in srgb, var(--mio-accent) 22%, transparent); animation: pulse 1.2s ease-in-out infinite; }
@keyframes pulse { 0%,100%{ transform: scale(0.92); opacity: 0.65; } 50%{ transform: scale(1); opacity: 1; } }
</style>
