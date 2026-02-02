<template>
  <div
    class="splitter"
    :class="orientation"
    @mousedown.prevent="onDown"
    role="separator"
    aria-orientation="horizontal"
  />
</template>

<script>
export default {
  name: 'SplitterBar',
  props: {
    orientation: { type: String, default: 'vertical' } // vertical = left/right split, horizontal = top/bottom split
  },
  methods: {
    onDown (e) {
      const startX = e.clientX
      const startY = e.clientY
      this.$emit('dragstart')
      const onMove = (ev) => {
        this.$emit('drag', { dx: ev.clientX - startX, dy: ev.clientY - startY, x: ev.clientX, y: ev.clientY })
      }
      const onUp = () => {
        window.removeEventListener('mousemove', onMove)
        window.removeEventListener('mouseup', onUp)
        this.$emit('dragend')
      }
      window.addEventListener('mousemove', onMove)
      window.addEventListener('mouseup', onUp)
    }
  }
}
</script>

<style scoped>
.splitter {
  background: rgba(255,255,255,0.03);
  transition: background 120ms ease;
  position: relative;
  z-index: 2;
}
.splitter:hover { background: rgba(0,122,204,0.18); }
.splitter.vertical { width: 6px; cursor: col-resize; }
.splitter.horizontal { height: 6px; cursor: row-resize; }

.splitter::after {
  content: '';
  position: absolute;
  inset: 0;
}
</style>
