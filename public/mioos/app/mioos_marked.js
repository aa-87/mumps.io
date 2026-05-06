(function (global) {
  var ASSET_BASE = '/public/mioos/vendor/marked/';
  var assetPromises = {};
  var loadPromise = null;
  var lastError = null;

  function assetUrl(path) {
    return ASSET_BASE + String(path || '').replace(/^\/+/, '');
  }

  function escapeHtml(value) {
    return String(value || '').replace(/[&<>"']/g, function (ch) {
      return ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[ch] || ch;
    });
  }

  function waitForExistingAsset(node, url) {
    return new Promise(function (resolve, reject) {
      if (!node) { reject(new Error('marked_asset_missing')); return; }
      if (node.getAttribute('data-mioos-marked-loaded') === '1') { resolve(url); return; }
      if (node.getAttribute('data-mioos-marked-error') === '1') { reject(new Error('marked_asset_failed')); return; }
      node.addEventListener('load', function () { node.setAttribute('data-mioos-marked-loaded', '1'); resolve(url); }, { once: true });
      node.addEventListener('error', function () { node.setAttribute('data-mioos-marked-error', '1'); reject(new Error('marked_asset_failed')); }, { once: true });
    });
  }

  function existingScript(src) {
    var scripts = Array.prototype.slice.call((global.document || {}).querySelectorAll ? global.document.querySelectorAll('script[src]') : []);
    return scripts.find(function (script) { return script.src === src || script.getAttribute('src') === src; }) || null;
  }

  function ensureScript(path) {
    var src = assetUrl(path);
    var doc = global.document;
    var script;
    if (global.marked && global.marked.parse) return Promise.resolve(src);
    if (assetPromises[src]) return assetPromises[src];
    if (!doc || !doc.createElement) return Promise.reject(new Error('marked_loader_document_unavailable'));
    script = existingScript(src);
    if (script) {
      assetPromises[src] = waitForExistingAsset(script, src);
      return assetPromises[src];
    }
    assetPromises[src] = new Promise(function (resolve, reject) {
      var node = doc.createElement('script');
      node.src = src;
      node.async = false;
      node.setAttribute('data-mioos-marked-asset', 'script');
      node.onload = function () { node.setAttribute('data-mioos-marked-loaded', '1'); resolve(src); };
      node.onerror = function () { node.setAttribute('data-mioos-marked-error', '1'); reject(new Error('marked_asset_failed')); };
      (doc.head || doc.documentElement || doc.body).appendChild(node);
    });
    return assetPromises[src];
  }

  function load() {
    if (global.marked && global.marked.parse) return Promise.resolve(global.marked);
    if (loadPromise) return loadPromise;
    loadPromise = ensureScript('lib/marked.umd.js').then(function () {
      if (!global.marked || !global.marked.parse) throw new Error('Marked unavailable after local asset load');
      return global.marked;
    }).catch(function (err) {
      lastError = err;
      loadPromise = null;
      throw err;
    });
    return loadPromise;
  }

  function documentFrame(bodyHtml) {
    return '<!doctype html><html><head><meta charset="utf-8"><base target="_blank">' +
      '<style>body{font-family:system-ui,-apple-system,Segoe UI,sans-serif;line-height:1.55;margin:1rem;color:#172033;background:#fff;}pre,code{font-family:ui-monospace,SFMono-Regular,Consolas,monospace;}img{max-width:100%;height:auto;}table{border-collapse:collapse;}td,th{border:1px solid #d8dee9;padding:.35rem .55rem;}blockquote{border-left:4px solid #d8dee9;margin-left:0;padding-left:1rem;color:#4b5563;}</style>' +
      '</head><body class="mioos-markdown-preview">' + String(bodyHtml || '') + '</body></html>';
  }

  function plainTextDocument(text) {
    return documentFrame('<pre>' + escapeHtml(text) + '</pre>');
  }

  function htmlPreviewDocument(html) {
    var raw = String(html || '');
    if (/<!doctype|<html[\s>]/i.test(raw)) return raw;
    return '<!doctype html><html><head><meta charset="utf-8"><base target="_blank"></head><body>' + raw + '</body></html>';
  }

  function renderMarkdownDocument(markdown) {
    return load().then(function (marked) {
      var html = marked.parse(String(markdown || ''));
      return { ok: 1, html: documentFrame(html), strategy: 'sandboxed-srcdoc-no-scripts' };
    }).catch(function (err) {
      return { ok: 0, html: plainTextDocument(markdown), strategy: 'plain-text-fallback', error: (err && err.message) || 'marked_unavailable' };
    });
  }

  global.MIOOSMarked = {
    VERSION: 'local-marked-umd',
    ASSET_BASE: ASSET_BASE,
    assetPromises: assetPromises,
    ensureScript: ensureScript,
    load: load,
    renderMarkdownDocument: renderMarkdownDocument,
    plainTextDocument: plainTextDocument,
    htmlPreviewDocument: htmlPreviewDocument,
    sandboxStrategy: 'sandboxed-srcdoc-no-scripts',
    noDataUrl: true,
    getLastError: function () { return lastError; }
  };
}(window));
