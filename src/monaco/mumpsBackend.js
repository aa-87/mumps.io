// src/monaco/mumpsBackend.js
// Backend-powered Monaco features for MUMPS over WebSocket RPC.
//
// This augments (not replaces) the front-end-only language support.
// If the backend is unavailable, these providers fail silently and Monaco
// falls back to the local providers.

import ideRpc from 'src/services/ideRpc'
import { mumpsLanguageId } from './mumps'

function modelText (model) {
  try { return model.getValue() } catch (e) { return '' }
}

function fileHint (model) {
  try {
    const p = model?.uri?.path || ''
    const f = (p.split('/').pop() || '').trim()
    return f || 'untitled.m'
  } catch (e) { return 'untitled.m' }
}

export function registerMumpsBackend (monaco) {
  if (!monaco) return
  const KEY = '__mio_mumps_backend_registered__'
  if (monaco[KEY]) return
  monaco[KEY] = true

  function pushMarkers (model, markers) {
    try {
      monaco.editor.setModelMarkers(model, mumpsLanguageId, markers || [])
    } catch (e) {}
  }

  monaco.languages.registerCompletionItemProvider(mumpsLanguageId, {
    triggerCharacters: ['$', '^', '%', '@', ' '],
    provideCompletionItems: async (model, position) => {
      try {
        const res = await ideRpc.call('mumps/completion', {
          file: fileHint(model),
          text: modelText(model),
          position: { line: position.lineNumber, column: position.column }
        }, 1500)
        return { suggestions: Array.isArray(res?.suggestions) ? res.suggestions : [] }
      } catch (e) {
        return { suggestions: [] }
      }
    }
  })

  monaco.languages.registerHoverProvider(mumpsLanguageId, {
    provideHover: async (model, position) => {
      try {
        const res = await ideRpc.call('mumps/hover', {
          file: fileHint(model),
          text: modelText(model),
          position: { line: position.lineNumber, column: position.column }
        }, 1500)
        if (!res || !res.contents) return null
        const r = res.range
        const range = r
          ? new monaco.Range(r.startLineNumber, r.startColumn, r.endLineNumber, r.endColumn)
          : undefined
        return { range, contents: res.contents }
      } catch (e) { return null }
    }
  })

  monaco.languages.registerDefinitionProvider(mumpsLanguageId, {
    provideDefinition: async (model, position) => {
      try {
        const res = await ideRpc.call('mumps/definition', {
          file: fileHint(model),
          text: modelText(model),
          position: { line: position.lineNumber, column: position.column }
        }, 2000)
        const loc = res?.location
        if (!loc) return null
        const rr = loc.range
        return {
          uri: model.uri,
          range: new monaco.Range(rr.startLineNumber, rr.startColumn, rr.endLineNumber, rr.endColumn)
        }
      } catch (e) { return null }
    }
  })

  monaco.languages.registerReferenceProvider(mumpsLanguageId, {
    provideReferences: async (model, position) => {
      try {
        const res = await ideRpc.call('mumps/references', {
          file: fileHint(model),
          text: modelText(model),
          position: { line: position.lineNumber, column: position.column }
        }, 2500)
        const refs = res?.references || []
        return refs.map(r => ({
          uri: model.uri,
          range: new monaco.Range(r.range.startLineNumber, r.range.startColumn, r.range.endLineNumber, r.range.endColumn)
        }))
      } catch (e) { return [] }
    }
  })

  monaco.languages.registerDocumentSymbolProvider(mumpsLanguageId, {
    provideDocumentSymbols: async (model) => {
      try {
        const res = await ideRpc.call('mumps/documentSymbols', {
          file: fileHint(model),
          text: modelText(model)
        }, 2000)
        return res?.symbols || []
      } catch (e) { return [] }
    }
  })

  monaco.languages.registerDocumentFormattingEditProvider(mumpsLanguageId, {
    provideDocumentFormattingEdits: async (model) => {
      try {
        const res = await ideRpc.call('mumps/format', {
          file: fileHint(model),
          text: modelText(model)
        }, 3000)
        if (!res || typeof res.text !== 'string') return []
        return [{ range: model.getFullModelRange(), text: res.text }]
      } catch (e) { return [] }
    }
  })

  // Expose a helper for MonacoEditor to trigger backend lint.
  registerMumpsBackend.lint = async (monacoInstance, model) => {
    try {
      const res = await ideRpc.call('mumps/diagnostics', {
        file: fileHint(model),
        text: modelText(model)
      }, 2000)
      pushMarkers(model, res?.markers || [])
    } catch (e) {}
  }
}
