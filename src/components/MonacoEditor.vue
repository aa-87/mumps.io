<template>
  <div class="mio-monaco">
    <CodeEditor
      v-model:value="code"
      :language="lang"
      :theme="theme"
      :options="options"
      @editor-mounted="editorMounted"
    />
  </div>
</template>

<script>
import { CodeEditor } from 'monaco-editor-vue3'
import * as monaco from 'monaco-editor'

import { registerMumps, mumpsLanguageId } from 'src/monaco/mumps'
import { registerMumpsBackend } from 'src/monaco/mumpsBackend'

function debounce (fn, ms) {
  let t
  return (...args) => {
    clearTimeout(t)
    t = setTimeout(() => fn(...args), ms)
  }
}

export default {
  name: 'MonacoEditor',
  components: { CodeEditor },
  props: {
    // Back-compat with existing EditorView wiring
    docId: { type: String, default: '' },
    value: { type: String, default: '' },
    filename: { type: String, default: 'untitled.m' },
    viewState: { type: [Object, null], default: null },
    theme: { type: String, default: 'vs-dark' }
  },
  emits: ['input', 'cursor', 'view-state'],
  data () {
    return {
      code: this.value,
      editor: null,
      options: {
        minimap: { enabled: false },
        fontFamily: 'var(--mio-mono)',
        fontSize: 13,
        lineHeight: 18,
        scrollBeyondLastLine: false,
        renderWhitespace: 'selection',
        smoothScrolling: true,
        cursorSmoothCaretAnimation: 'on',
        wordWrap: 'off'
      }
    }
  },
  computed: {
    lang () {
      const f = (this.filename || '').toLowerCase()
      if (f.endsWith('.m') || f.endsWith('.int') || f.endsWith('.rou')) return mumpsLanguageId
      return 'plaintext'
    }
  },
  watch: {
    value (v) {
      if (v !== this.code) this.code = v
    },
    code (v) {
      this.$emit('input', v)
    }
  },
  methods: {
    editorMounted (editor) {
      this.editor = editor

      // Ensure language + providers are registered.
      registerMumps(monaco)
      registerMumpsBackend(monaco)

      // Set the model language (some wrappers default to JS).
      try {
        const model = editor.getModel()
        if (model && this.lang === mumpsLanguageId) {
          monaco.editor.setModelLanguage(model, mumpsLanguageId)
        }
      } catch (e) {}

      // Restore view state (cursor/scroll) when available.
      try {
        if (this.viewState) editor.restoreViewState(this.viewState)
      } catch (e) {}

      // Cursor -> status bar
      try {
        editor.onDidChangeCursorPosition((ev) => {
          const p = ev.position
          this.$emit('cursor', { line: p.lineNumber, column: p.column })
        })
      } catch (e) {}

      // Persist view state (EditorView stores it keyed by doc id).
      try {
        editor.onDidBlurEditorText(() => {
          const vs = editor.saveViewState()
          this.$emit('view-state', vs)
        })
      } catch (e) {}

      // Backend diagnostics (debounced). If backend is down, this is a no-op.
      const lintNow = async () => {
        try {
          if (this.lang !== mumpsLanguageId) return
          const model = editor.getModel()
          if (!model) return
          if (typeof registerMumpsBackend.lint === 'function') {
            await registerMumpsBackend.lint(monaco, model)
          }
        } catch (e) {}
      }
      const lintDebounced = debounce(lintNow, 350)
      try {
        editor.onDidChangeModelContent(() => lintDebounced())
        lintDebounced()
      } catch (e) {}

    }
  },
  beforeUnmount () {
    try { this.editor?.dispose() } catch (e) {}
  }
}
</script>

<style scoped>
.mio-monaco{
  height: 100%;
  width: 100%;
  position: relative;
  background: var(--mio-editor-bg);
}
</style>
