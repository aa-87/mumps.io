<template>
  <section class="wrap">
    <div class="tabs">
      <button
        v-for="(id,i) in bottomTabs.tabs"
        :key="id"
        class="tabbtn"
        :class="{ active: id === bottomActive }"
        draggable="true"
        @click="$emit('select', id)"
        @dragstart="onDragStart(i)"
        @dragover.prevent
        @drop="onDrop(i)"
      >
        <span class="lbl">{{ tabTitle(id) }}</span>
      </button>
    </div>

    <div class="body">
      <component
        :is="panelComponent(bottomActive)"
        :title="tabTitle(bottomActive)"
      />
    </div>
  </section>
</template>

<script>
import TerminalPane from './TerminalPane.vue'
import OutputPane from './OutputPane.vue'

export default {
  name: 'BottomPanel',
  props: {
    bottomTabs: {
      type: Object,
      required: true
    },
    bottomActive: {
      type: String,
      required: true
    }
  },
  data () {
    return {
      dragFrom: null
    }
  },
  methods: {
    panelComponent (id) {
      if (id === 'terminal') return TerminalPane
      return OutputPane
    },
    tabTitle (id) {
      return id === 'terminal' ? 'Terminal' : 'Output'
    },
    onDragStart (i) {
      this.dragFrom = i
    },
    onDrop (i) {
      if (this.dragFrom === null || this.dragFrom === i) return
      this.$emit('reorder', { from: this.dragFrom, to: i })
      this.dragFrom = null
    }
  }
}
</script>

<style scoped>
.wrap{
  display:flex;
  flex-direction:column;
  height:100%;
}
.tabs{
  display:flex;
  gap:6px;
  padding:6px;
  border-bottom:1px solid var(--mio-hairline);
  background: var(--mio-panel2);
}
.tabbtn{
  height:26px;
  padding:0 10px;
  border-radius:8px;
  border:1px solid var(--mio-border);
  background: transparent;
  color: var(--mio-fg);
  font-size:12px;
  cursor:pointer;
}
.tabbtn.active{
  background: color-mix(in srgb, var(--mio-accent) 18%, transparent);
}
.body{
  flex:1;
  overflow:hidden;
}
</style>
