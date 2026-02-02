// src/monaco/mumps.js
// Monaco language support for MUMPS / M.
// Goal: VS Code-like baseline (highlighting, completion, symbols, folding, hovers).
//
// This is intentionally "front-end only" for now.
// Later we can connect completion/hover/signature help to the YottaDB backend over WS/POST.

const LANG_ID = 'mumps'

// --- Dictionaries (starter set; can be expanded over time) ---
const COMMANDS = [
  'b', 'break',
  'c', 'close',
  'd', 'do',
  'e', 'else',
  'f', 'for',
  'g', 'goto',
  'h', 'halt', 'hang',
  'i', 'if',
  'j', 'job',
  'k', 'kill',
  'l', 'lock',
  'm', 'merge',
  'n', 'new',
  'o', 'open',
  'q', 'quit',
  'r', 'read',
  's', 'set',
  't', 'tcommit', 'trestart', 'trollback', 'tstart',
  'u', 'use',
  'v', 'view',
  'w', 'write',
  'x', 'xecute'
]

const INTRINSICS = [
  '$A', '$ASCII',
  '$C', '$CHAR',
  '$D', '$DATA',
  '$E', '$EXTRACT',
  '$F', '$FIND',
  '$G', '$GET',
  '$J', '$JUSTIFY',
  '$L', '$LENGTH',
  '$N', '$NEXT',
  '$NA', '$NAME',
  '$O', '$ORDER',
  '$P', '$PIECE',
  '$QL', '$QUERYLENGTH',
  '$QS', '$QUERYSTRING',
  '$R', '$RANDOM',
  '$RE', '$REVERSE',
  '$S', '$SELECT',
  '$T', '$TEXT',
  '$TR', '$TRANSLATE',
  '$V', '$VIEW',
  '$ZDATE', '$ZDATETIME', '$ZTIMESTAMP'
]

// Rough "specials" / system vars (starter)
const SYSVARS = [
  '$H', '$HOROLOG',
  '$I', '$IO',
  '$J', '$JOB',
  '$K', '$KEY',
  '$P', '$PRINCIPAL',
  '$Q', '$QUIT',
  '$R', '$REFERENCE',
  '$S', '$STORAGE',
  '$T', '$TEST',
  '$X', '$X',
  '$Y', '$Y',
  '$ZB', '$ZBREAK', '$ZE', '$ZERROR', '$ZEOF', '$ZPOS', '$ZSTATUS'
]

// Simple docs (hover)
const HOVERS = {
  '$GET': 'Returns the value of a variable; optional default if undefined.\nExample: $GET(x,0)',
  '$ORDER': 'Iterates subscripts of a global/local array.\nExample: set s=$order(^G(s))',
  '$DATA': 'Returns definedness of a variable/global node.',
  '$PIECE': 'Extracts delimited piece(s) from a string.\nExample: $PIECE(str,"^",2)'
}

function uniqLower (arr) {
  const s = new Set()
  const out = []
  for (const a of arr) {
    const k = String(a).toLowerCase()
    if (s.has(k)) continue
    s.add(k)
    out.push(a)
  }
  return out
}

function normalizeIntrinsic (s) {
  // Ensure $ prefix; remove spaces
  const t = (s || '').trim()
  return t.startsWith('$') ? t : ('$' + t)
}

export function registerMumps (monaco) {
  if (!monaco) return
  const already = monaco.languages.getLanguages().some(l => l.id === LANG_ID)
  if (already) return

  monaco.languages.register({ id: LANG_ID, aliases: ['MUMPS', 'M'], extensions: ['.m', '.int', '.rou'] })

  // --- Tokenizer (Monarch) ---
  // MUMPS line anatomy (high-level):
  //   [label] [offset] [space] [commands] [; comment]
  // Special tokens:
  //   globals: ^NAME(...)
  //   indirection: @expr
  //   postconditional: :expr
  //   strings: "..."
  //   numbers: 123, 12.3
  //   operators: +-*/\#_=<> etc.
  monaco.languages.setMonarchTokensProvider(LANG_ID, {
    defaultToken: '',
    tokenPostfix: '.mumps',
    ignoreCase: true,

    keywords: uniqLower(COMMANDS),
    intrinsics: uniqLower(INTRINSICS.map(normalizeIntrinsic)),
    sysvars: uniqLower(SYSVARS.map(normalizeIntrinsic)),

    brackets: [
      { open: '(', close: ')', token: 'delimiter.parenthesis' },
      { open: '[', close: ']', token: 'delimiter.square' }
    ],

    tokenizer: {
      root: [
        // full-line comment
        [/^\s*;.*/, 'comment'],

        // label at line start (LABEL or %LABEL). Optional offset like LABEL+1
        [/^([A-Za-z%][A-Za-z0-9%]*)(\+[0-9]+)?(\s+)/, [
          'type.identifier', 'number', 'white'
        ]],

        // comment from ; to end
        [/;.*$/, 'comment'],

        // strings
        [/"/, { token: 'string.quote', bracket: '@open', next: '@string' }],

        // globals: ^NAME or ^("dynamic") are complex; handle common form
        [/\^[A-Za-z%][A-Za-z0-9%]*/, 'variable.global'],

        // local vars
        [/[A-Za-z%][A-Za-z0-9%]*/, {
          cases: {
            '@keywords': 'keyword',
            '@intrinsics': 'keyword',
            '@sysvars': 'variable.predefined',
            '@default': 'identifier'
          }
        }],

        // $ functions (general)
        [/\$[A-Za-z][A-Za-z0-9]*/, {
          cases: {
            '@intrinsics': 'keyword',
            '@sysvars': 'variable.predefined',
            '@default': 'keyword'
          }
        }],

        // numbers
        [/[0-9]+(\.[0-9]+)?/, 'number'],

        // postconditional operator :
        [/:/, 'operator'],

        // indirection
        [/@/, 'operator'],

        // delimiters
        [/[(),\[\]]/, '@brackets'],
        [/[,\.]/, 'delimiter'],

        // operators (subset)
        [/[\+\-\*\/\\#_=<>!&\|]/, 'operator'],

        // whitespace
        [/\s+/, 'white']
      ],

      string: [
        [/[^\\"]+/, 'string'],
        [/\\./, 'string.escape'],
        [/""/, 'string'], // doubled quote in MUMPS strings
        [/"/, { token: 'string.quote', bracket: '@close', next: '@pop' }]
      ]
    }
  })

  // --- Language configuration ---
  monaco.languages.setLanguageConfiguration(LANG_ID, {
    comments: { lineComment: ';' },
    brackets: [['(', ')'], ['[', ']']],
    autoClosingPairs: [
      { open: '"', close: '"' },
      { open: '(', close: ')' },
      { open: '[', close: ']' }
    ],
    surroundingPairs: [
      { open: '"', close: '"' },
      { open: '(', close: ')' },
      { open: '[', close: ']' }
    ],
    indentationRules: {
      // Indent when line ends with a DO block hint (common patterns: "do", "d", "for", "f") with no arguments.
      increaseIndentPattern: /^\s*([A-Za-z%][A-Za-z0-9%]*(\+[0-9]+)?)?\s*(do|d|for|f)\s*($|;)/i,
      // Decrease indent on a plain QUIT with no args
      decreaseIndentPattern: /^\s*([A-Za-z%][A-Za-z0-9%]*(\+[0-9]+)?)?\s*(quit|q)\s*($|;)/i
    }
  })

  // --- Completion (keywords, intrinsics, snippets) ---
  const mkKeywordItem = (label) => ({
    label,
    kind: monaco.languages.CompletionItemKind.Keyword,
    insertText: label,
    sortText: '1' + label.toLowerCase()
  })
  const mkFuncItem = (label) => ({
    label,
    kind: monaco.languages.CompletionItemKind.Function,
    insertText: label,
    sortText: '2' + label.toLowerCase()
  })
  const mkSnippet = (label, insertText, doc) => ({
    label,
    kind: monaco.languages.CompletionItemKind.Snippet,
    insertText,
    insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
    documentation: doc,
    sortText: '0' + label.toLowerCase()
  })

  const SNIPPETS = [
    mkSnippet('set', 'set ${1:var}=${2:value}', 'Set variable'),
    mkSnippet('kill', 'kill ${1:var}', 'Kill variable'),
    mkSnippet('new', 'new ${1:var}', 'Localize variable'),
    mkSnippet('write', 'write ${1:"text"}', 'Write output'),
    mkSnippet('read', 'read ${1:var}', 'Read input'),
    mkSnippet('if', 'if ${1:cond} ${2:do}', 'If statement'),
    mkSnippet('for', 'for ${1:i}=1:1:${2:n} ${3:do}', 'For loop'),
    mkSnippet('do', 'do ${1:label}', 'Do call'),
    mkSnippet('quit', 'quit ${1:value}', 'Quit'),
    mkSnippet('gbl', 'set ${1:val}=$get(^${2:GLOBAL}(${3:sub}),${4:0})', 'Read global with default'),
    mkSnippet('order', 'set ${1:s}=$order(^${2:GLOBAL}(${3:s}))', '$ORDER loop seed')
  ]

  const keywordItems = uniqLower(COMMANDS).map(mkKeywordItem)
  const funcItems = uniqLower(INTRINSICS.map(normalizeIntrinsic)).map(mkFuncItem)

  monaco.languages.registerCompletionItemProvider(LANG_ID, {
    triggerCharacters: ['$', '^', '%', '@'],
    provideCompletionItems: () => ({
      suggestions: [
        ...SNIPPETS,
        ...keywordItems,
        ...funcItems
      ]
    })
  })

  // --- Hover provider (intrinsics quick docs) ---
  monaco.languages.registerHoverProvider(LANG_ID, {
    provideHover: (model, pos) => {
      const w = model.getWordAtPosition(pos)
      if (!w) return null
      const raw = model.getValueInRange({
        startLineNumber: pos.lineNumber,
        startColumn: w.startColumn,
        endLineNumber: pos.lineNumber,
        endColumn: w.endColumn
      })
      const key = raw.toUpperCase()
      const doc = HOVERS[key] || HOVERS[normalizeIntrinsic(key)]
      if (!doc) return null
      return {
        range: new monaco.Range(pos.lineNumber, w.startColumn, pos.lineNumber, w.endColumn),
        contents: [
          { value: `**${key}**` },
          { value: doc }
        ]
      }
    }
  })

  // --- Document symbols (labels) for outline ---
  monaco.languages.registerDocumentSymbolProvider(LANG_ID, {
    provideDocumentSymbols: (model) => {
      const out = []
      const n = model.getLineCount()
      for (let i = 1; i <= n; i++) {
        const line = model.getLineContent(i)
        // label at start of line: LABEL or %LABEL
        const m = /^([A-Za-z%][A-Za-z0-9%]*)(\+[0-9]+)?\b/.exec(line)
        if (!m) continue
        // Ignore if it's indented (not a routine label)
        if (/^\s+/.test(line)) continue
        const label = m[1] + (m[2] || '')
        out.push({
          name: label,
          kind: monaco.languages.SymbolKind.Function,
          range: new monaco.Range(i, 1, i, Math.min(line.length + 1, 200)),
          selectionRange: new monaco.Range(i, 1, i, Math.min(label.length + 1, 200)),
          children: []
        })
      }
      return out
    }
  })

  // --- Folding (indentation-based) ---
  // M has no braces; indentation is the best cheap heuristic.
  monaco.languages.registerFoldingRangeProvider(LANG_ID, {
    provideFoldingRanges: (model) => {
      const ranges = []
      const n = model.getLineCount()
      const indents = new Array(n + 1).fill(0)
      for (let i = 1; i <= n; i++) {
        const line = model.getLineContent(i)
        if (!line.trim() || line.trim().startsWith(';')) {
          indents[i] = indents[i - 1]
          continue
        }
        indents[i] = line.match(/^\s*/)[0].length
      }
      const stack = []
      for (let i = 1; i <= n; i++) {
        const cur = indents[i]
        while (stack.length && cur <= stack[stack.length - 1].indent) {
          const top = stack.pop()
          const end = i - 1
          if (end > top.start) {
            ranges.push({ start: top.start, end })
          }
        }
        // start fold when next line is more indented
        const next = (i < n) ? indents[i + 1] : 0
        if (next > cur) stack.push({ start: i, indent: cur })
      }
      // close remaining
      while (stack.length) {
        const top = stack.pop()
        if (n > top.start) ranges.push({ start: top.start, end: n })
      }
      return ranges
    }
  })

  // --- Go to Definition (labels in current routine) ---
  // Supports: DO TAG, GOTO TAG, and TAG^ROUTINE (same-file only for now).
  // Cross-file definitions will be added later via backend indexing.
  function currentRoutineName (model) {
    try {
      const p = (model && model.uri && model.uri.path) ? model.uri.path : ''
      const f = p.split('/').pop() || ''
      return f.replace(/\.(m|int|rou)$/i, '').toUpperCase()
    } catch (e) { return '' }
  }

  function findLabelLocation (model, label) {
    if (!model || !label) return null
    const n = model.getLineCount()
    const reLabel = new RegExp('^' + label.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&') + '(\\+[0-9]+)?\\b', 'i')
    for (let i = 1; i <= n; i++) {
      const line = model.getLineContent(i)
      if (!line || /^\s+/.test(line)) continue // ignore indented lines
      const m = reLabel.exec(line)
      if (m) {
        return {
          uri: model.uri,
          range: new monaco.Range(i, 1, i, Math.min(line.length + 1, 200))
        }
      }
    }
    return null
  }

  function parseTargetAt (model, pos) {
    const line = model.getLineContent(pos.lineNumber) || ''
    // Example patterns:
    //   do TAG
    //   d TAG^ROU
    //   goto TAG
    //   g TAG+3^ROU
    const re = /\b(do|d|goto|g)\b\s+([A-Za-z%][A-Za-z0-9%]*)(\+[0-9]+)?(\^([A-Za-z%][A-Za-z0-9%]*))?/ig
    let m
    while ((m = re.exec(line))) {
      const full = m[0]
      const tag = m[2]
      const off = m[3] || ''
      const rou = m[5] || ''
      // Compute columns (1-based)
      const startCol = m.index + full.indexOf(tag) + 1
      const endCol = startCol + tag.length + off.length + (rou ? (1 + rou.length) : 0)
      if (pos.column >= startCol && pos.column <= endCol + 1) {
        return { tag, routine: rou }
      }
    }

    // Fallback: if cursor is on a word, treat it as a label in same file
    const w = model.getWordAtPosition(pos)
    if (w && w.word) return { tag: w.word, routine: '' }
    return null
  }

  monaco.languages.registerDefinitionProvider(LANG_ID, {
    provideDefinition: (model, pos) => {
      try {
        const t = parseTargetAt(model, pos)
        if (!t || !t.tag) return null

        const targetRoutine = (t.routine || '').toUpperCase()
        const here = currentRoutineName(model)
        if (targetRoutine && here && targetRoutine !== here) {
          // Cross-file goto/DO not supported yet (requires project index/back-end).
          return null
        }
        return findLabelLocation(model, t.tag)
      } catch (e) {
        return null
      }
    }
  })


  // --- Find References (labels in current routine) ---
  // Finds occurrences of:
  //  - label definitions at line start
  //  - do/goto TAG (and TAG^ROU same-file)
  // This enables "Find All References" and improves Peek Definition navigation.
  function escapeRe (s) {
    return String(s).replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&')
  }

  function findReferencesInModel (model, label) {
    const out = []
    if (!model || !label) return out
    const n = model.getLineCount()
    const lab = escapeRe(label)
    const reDef = new RegExp('^' + lab + '(\\+[0-9]+)?\\b', 'i')
    const reCall = new RegExp('\\b(do|d|goto|g)\\b\\s+(' + lab + ')(\\+[0-9]+)?(\\^([A-Za-z%][A-Za-z0-9%]*))?', 'ig')

    for (let i = 1; i <= n; i++) {
      const line = model.getLineContent(i) || ''
      if (!line) continue

      if (!/^\s+/.test(line) && reDef.test(line)) {
        out.push({
          uri: model.uri,
          range: new monaco.Range(i, 1, i, Math.min(line.length + 1, 200))
        })
      }

      let m
      while ((m = reCall.exec(line))) {
        const tag = m[2]
        const startCol = m.index + m[0].indexOf(tag) + 1
        const endCol = startCol + tag.length
        out.push({
          uri: model.uri,
          range: new monaco.Range(i, startCol, i, endCol)
        })
      }
    }
    return out
  }

  monaco.languages.registerReferenceProvider(LANG_ID, {
    provideReferences: (model, pos) => {
      try {
        const w = model.getWordAtPosition(pos)
        if (!w || !w.word) return []
        return findReferencesInModel(model, w.word)
      } catch (e) { return [] }
    }
  })

  // --- Document Highlights (same-file) ---
  monaco.languages.registerDocumentHighlightProvider(LANG_ID, {
    provideDocumentHighlights: (model, pos) => {
      try {
        const w = model.getWordAtPosition(pos)
        if (!w || !w.word) return []
        const refs = findReferencesInModel(model, w.word)
        return refs.map(r => ({ range: r.range, kind: monaco.languages.DocumentHighlightKind.Text }))
      } catch (e) { return [] }
    }
  })

}

export const mumpsLanguageId = LANG_ID
