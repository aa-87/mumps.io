(function (global) {
  var document = global.document;
  var ASSET_BASE = '/public/mioos/vendor/codemirror/';
  var assetPromises = {};
  var nonFatalAssetErrors = {};

  var MODE_FILES = {
    mumps: 'modes/mumps.js',
    markdown: 'modes/markdown.js',
    xml: 'modes/xml.js',
    sql: 'modes/sql.js',
    spreadsheet: 'modes/spreadsheet.js'
  };

  var THEME_FILES = {
    'xq-light': 'themes/xq-light.css',
    'xq-dark': 'themes/xq-dark.css'
  };

  var EXTENSION_MODE_MAP = {
    m: 'mumps',
    rou: 'mumps',
    mumps: 'mumps',
    int: 'mumps',
    mac: 'mumps',
    md: 'markdown',
    markdown: 'markdown',
    html: 'xml',
    htm: 'xml',
    xml: 'xml',
    sql: 'sql',
    csv: 'spreadsheet'
  };

  function assetUrl(path) {
    return ASSET_BASE + String(path || '').replace(/^\/+/, '');
  }

  function markLoaded(node) {
    if (node && node.setAttribute) node.setAttribute('data-mioos-codemirror-loaded', '1');
  }

  function findExistingAsset(tag, attr, src) {
    if (!document || !document.querySelectorAll) return null;
    var nodes = document.querySelectorAll(tag + '[' + attr + ']');
    var i;
    for (i = 0; i < nodes.length; i += 1) {
      if (nodes[i].getAttribute(attr) === src) return nodes[i];
    }
    return null;
  }

  function existingAssetLooksLoaded(existing, src) {
    var state = existing && existing.readyState;
    var tag = String((existing && existing.tagName) || '').toLowerCase();
    if (!existing) return false;
    if (existing.getAttribute('data-mioos-codemirror-loaded') === '1') return true;
    if (tag === 'link' && existing.sheet) return true;
    if (tag === 'script' && (state === 'loaded' || state === 'complete')) return true;
    if (/lib\/codemirror\.js$/.test(src) && global.CodeMirror) return true;
    return false;
  }

  function waitForExistingAsset(existing, src) {
    if (existingAssetLooksLoaded(existing, src)) {
      markLoaded(existing);
      return Promise.resolve(src);
    }
    if (assetPromises[src]) return assetPromises[src];
    assetPromises[src] = new Promise(function (resolve, reject) {
      function cleanup() {
        existing.removeEventListener('load', onLoad);
        existing.removeEventListener('error', onError);
      }
      function onLoad() {
        cleanup();
        markLoaded(existing);
        resolve(src);
      }
      function onError() {
        cleanup();
        reject(new Error('CodeMirror asset failed: ' + src));
      }
      existing.addEventListener('load', onLoad, { once: true });
      existing.addEventListener('error', onError, { once: true });
    });
    return assetPromises[src];
  }

  function ensureStyle(path) {
    var src = assetUrl(path);
    var existing;
    if (!document) return Promise.reject(new Error('document unavailable'));
    if (assetPromises[src]) return assetPromises[src];
    existing = findExistingAsset('link', 'href', src);
    if (existing) return waitForExistingAsset(existing, src);
    assetPromises[src] = new Promise(function (resolve, reject) {
      var link = document.createElement('link');
      link.rel = 'stylesheet';
      link.href = src;
      link.setAttribute('data-mioos-codemirror-asset', src);
      link.addEventListener('load', function () {
        markLoaded(link);
        resolve(src);
      }, { once: true });
      link.addEventListener('error', function () {
        reject(new Error('CodeMirror stylesheet failed: ' + src));
      }, { once: true });
      (document.head || document.documentElement).appendChild(link);
    });
    return assetPromises[src];
  }

  function ensureScript(path) {
    var src = assetUrl(path);
    var existing;
    if (!document) return Promise.reject(new Error('document unavailable'));
    if (assetPromises[src]) return assetPromises[src];
    existing = findExistingAsset('script', 'src', src);
    if (existing) return waitForExistingAsset(existing, src);
    assetPromises[src] = new Promise(function (resolve, reject) {
      var script = document.createElement('script');
      script.src = src;
      script.async = false;
      script.setAttribute('data-mioos-codemirror-asset', src);
      script.addEventListener('load', function () {
        markLoaded(script);
        resolve(src);
      }, { once: true });
      script.addEventListener('error', function () {
        reject(new Error('CodeMirror script failed: ' + src));
      }, { once: true });
      (document.head || document.documentElement).appendChild(script);
    });
    return assetPromises[src];
  }

  function filenameExtension(filename) {
    var name = String(filename || '').toLowerCase().split(/[?#]/)[0];
    var idx = name.lastIndexOf('.');
    return idx >= 0 ? name.slice(idx + 1) : '';
  }

  function resolveMode(filename, mime) {
    var ext = filenameExtension(filename);
    var type = String(mime || '').toLowerCase();
    if (EXTENSION_MODE_MAP[ext]) return EXTENSION_MODE_MAP[ext];
    if (type.indexOf('markdown') >= 0) return 'markdown';
    if (type.indexOf('xml') >= 0 || type.indexOf('html') >= 0) return 'xml';
    if (type.indexOf('sql') >= 0) return 'sql';
    if (type.indexOf('csv') >= 0 || type.indexOf('spreadsheet') >= 0) return 'spreadsheet';
    return 'text/plain';
  }

  function isDarkTheme() {
    if (!document || !document.querySelector) return false;
    return !!document.querySelector('.theme-dark-mode');
  }

  function themeForCurrentMioos() {
    return isDarkTheme() ? 'xq-dark' : 'xq-light';
  }

  function load(options) {
    var opts = options || {};
    var mode = resolveMode(opts.filename, opts.mime);
    var theme = opts.theme || themeForCurrentMioos();
    var coreCss = ensureStyle('lib/codemirror.css').catch(function (err) {
      nonFatalAssetErrors['lib/codemirror.css'] = err;
      return null;
    });
    return coreCss.then(function () {
      return ensureScript('lib/codemirror.js');
    }).then(function () {
      if (!global.CodeMirror) throw new Error('CodeMirror core unavailable after local asset load');
      return ensureStyle(THEME_FILES[theme] || THEME_FILES['xq-light']).catch(function (err) {
        nonFatalAssetErrors['theme load failed'] = err;
        return null;
      });
    }).then(function () {
      if (mode === 'text/plain' || !MODE_FILES[mode]) return 'text/plain';
      return ensureScript(MODE_FILES[mode]).then(function () { return mode; }).catch(function (err) {
        nonFatalAssetErrors['mode load failed'] = err;
        return 'text/plain';
      });
    }).then(function (loadedMode) {
      return {
        CodeMirror: global.CodeMirror,
        mode: loadedMode || 'text/plain',
        requestedMode: mode,
        theme: theme,
        nonFatalAssetErrors: nonFatalAssetErrors
      };
    });
  }

  function createTextEditor(container, options) {
    var opts = options || {};
    if (!container) return Promise.reject(new Error('CodeMirror container missing'));
    return load(opts).then(function (info) {
      var silent = false;
      var cm;
      container.innerHTML = '';
      cm = info.CodeMirror(container, {
        value: String(opts.value || ''),
        mode: info.mode || 'text/plain',
        theme: info.theme || themeForCurrentMioos(),
        readOnly: opts.readOnly ? 'nocursor' : false,
        lineNumbers: opts.lineNumbers !== false,
        lineWrapping: opts.lineWrapping !== false,
        viewportMargin: opts.viewportMargin || 20,
        indentUnit: 2,
        tabSize: 2
      });
      if (opts.fontSize) cm.getWrapperElement().style.fontSize = opts.fontSize;
      cm.on('change', function () {
        if (!silent && typeof opts.onChange === 'function') opts.onChange(cm.getValue());
      });
      return {
        cm: cm,
        requestedMode: info.requestedMode,
        loadedMode: info.mode,
        getValue: function () { return cm.getValue(); },
        setValue: function (value, noChange) {
          var text = String(value || '');
          if (cm.getValue() === text) return;
          silent = !!noChange;
          cm.setValue(text);
          silent = false;
        },
        setReadOnly: function (readOnly) { cm.setOption('readOnly', readOnly ? 'nocursor' : false); },
        setLineWrapping: function (lineWrapping) { cm.setOption('lineWrapping', lineWrapping !== false); },
        setTheme: function (themeName) { cm.setOption('theme', themeName || themeForCurrentMioos()); },
        setMode: function (modeName) { cm.setOption('mode', modeName || 'text/plain'); },
        setFontSize: function (fontSize) {
          cm.getWrapperElement().style.fontSize = fontSize || '';
          cm.refresh();
        },
        refresh: function () { cm.refresh(); },
        destroy: function () {
          var wrapper = cm.getWrapperElement();
          if (wrapper && wrapper.parentNode) wrapper.parentNode.removeChild(wrapper);
          container.innerHTML = '';
        }
      };
    });
  }

  global.MIOOSCodeMirror = {
    VERSION: '5.65.21-local',
    ASSET_BASE: ASSET_BASE,
    MODE_FILES: MODE_FILES,
    THEME_FILES: THEME_FILES,
    EXTENSION_MODE_MAP: EXTENSION_MODE_MAP,
    assetPromises: assetPromises,
    nonFatalAssetErrors: nonFatalAssetErrors,
    resolveMode: resolveMode,
    themeForCurrentMioos: themeForCurrentMioos,
    ensureStyle: ensureStyle,
    ensureScript: ensureScript,
    load: load,
    createTextEditor: createTextEditor
  };
}(window));
