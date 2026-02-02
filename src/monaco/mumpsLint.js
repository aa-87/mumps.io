// src/monaco/mumpsLint.js
// Fast, local-only diagnostics for MUMPS (no backend yet).
// Heuristic rules:
//  - Unmatched parentheses () and brackets []
//  - Unclosed string quotes (")
// Notes:
//  - M strings escape by doubling quotes: ""
//  - We ignore anything after a comment ; (unless inside a string).
export function lintMumps (text, monaco) {
  const markers = []
  if (!text) return markers
  const lines = String(text).split(/\r?\n/)

  let paren = 0
  let brack = 0
  let inStr = false

  for (let i = 0; i < lines.length; i++) {
    const lineNum = i + 1
    const line = lines[i] || ''

    for (let c = 0; c < line.length; c++) {
      const ch = line[c]

      if (ch === '"') {
        const next = line[c + 1]
        if (next === '"') { c++; continue }
        inStr = !inStr
        continue
      }

      if (!inStr && ch === ';') break

      if (!inStr) {
        if (ch === '(') paren++
        else if (ch === ')') paren--
        else if (ch === '[') brack++
        else if (ch === ']') brack--
      }

      if (paren < 0) {
        markers.push({
          severity: monaco.MarkerSeverity.Error,
          message: 'Unmatched closing parenthesis )',
          startLineNumber: lineNum,
          startColumn: c + 1,
          endLineNumber: lineNum,
          endColumn: c + 2
        })
        paren = 0
      }
      if (brack < 0) {
        markers.push({
          severity: monaco.MarkerSeverity.Error,
          message: 'Unmatched closing bracket ]',
          startLineNumber: lineNum,
          startColumn: c + 1,
          endLineNumber: lineNum,
          endColumn: c + 2
        })
        brack = 0
      }
    }
  }

  if (inStr) {
    const last = lines[lines.length - 1] || ''
    markers.push({
      severity: monaco.MarkerSeverity.Error,
      message: 'Unclosed string (missing closing ")',
      startLineNumber: lines.length,
      startColumn: Math.max(1, last.length),
      endLineNumber: lines.length,
      endColumn: Math.max(2, last.length + 1)
    })
  }
  if (paren > 0) {
    markers.push({
      severity: monaco.MarkerSeverity.Warning,
      message: 'Possible missing closing parenthesis )',
      startLineNumber: 1,
      startColumn: 1,
      endLineNumber: 1,
      endColumn: 2
    })
  }
  if (brack > 0) {
    markers.push({
      severity: monaco.MarkerSeverity.Warning,
      message: 'Possible missing closing bracket ]',
      startLineNumber: 1,
      startColumn: 1,
      endLineNumber: 1,
      endColumn: 2
    })
  }
  return markers
}
