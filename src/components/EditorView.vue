<template>
  <div class="editor-root">
    <MonacoEditor
      v-if="activeId"
      :doc-id="activeId"
      :filename="activeTitle"
      :value="content"
      :view-state="viewState"
      @input="onInput"
      @cursor="onCursor"
      @view-state="onViewState"
    />
  </div>
</template>

<script>
import MonacoEditor from 'components/MonacoEditor.vue'

export default {
  name: 'EditorView',
  components: { MonacoEditor },
  computed: {
    activeId () { return this.$store.getters['editor/active'] },
    activeTitle () {
      const t = this.$store.getters['editor/activeTab']
      return t?.title || ''
    },
    content () {
      const docs = this.$store.state.editor.docs || {}
      return docs[this.activeId] || ''
    },
    viewState () {
      const vs = this.$store.state.editor.viewState || {}
      return vs[this.activeId] || null
    }
  },
  methods: {
    onInput (v) {
      const id = this.activeId
      this.$store.commit('editor/setDoc', { id, content: v })
      this.$store.commit('editor/setDirty', { id, dirty: true })
    },
    onCursor (pos) {
      this.$store.commit('editor/setCursor', { id: this.activeId, ...pos })
    },
    onViewState (vs) {
      this.$store.commit('editor/setViewState', { id: this.activeId, viewState: vs })
    }
  }
}
</script>


<style scoped>
.editor-root{
  height:100%;
  width:100%;
  overflow:hidden;
}
</style>
