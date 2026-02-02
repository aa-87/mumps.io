<template>
  <transition-group name="toast" tag="div" class="toasts">
    <div v-for="t in toasts" :key="t.id" class="toast">
      <MioIcon :name="t.icon||'info'" />
      <span>{{ t.msg }}</span>
    </div>
  </transition-group>
</template>

<script>
import MioIcon from 'components/Icon.vue'
export default {
  name: 'ToastComponent',
  components: { MioIcon },
  props: { toasts: { type:Array, default:()=>[] } }
}
</script>

<style scoped>
.toasts {
  position: fixed;
  right: 16px;
  bottom: 40px;
  display:flex;
  flex-direction:column;
  gap:8px;
  z-index:9999;
}
.toast {
  display:flex;
  gap:8px;
  padding:8px 12px;
  background: var(--mio-panel);
  border:1px solid var(--mio-border);
  border-radius:10px;
  box-shadow:0 8px 24px rgba(0,0,0,.35);
}
.toast-enter-active,.toast-leave-active{transition:all .2s}
.toast-enter-from{opacity:0; transform:translateY(6px)}
.toast-leave-to{opacity:0; transform:translateY(6px)}
</style>
