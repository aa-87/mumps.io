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

  function sanitizeUrl(value) {
    var raw = String(value || '').trim();
    if (!raw) return '';
    if (/^(javascript|data|vbscript):/i.test(raw)) return '';
    return raw;
  }

  function sanitizeInlineHtml(html) {
    var raw = String(html || '');
    var parser, doc, root, blocked;
    if (global.DOMParser) {
      parser = new global.DOMParser();
      doc = parser.parseFromString('<div data-mioos-markdown-inline-root="1">' + raw + '</div>', 'text/html');
      root = doc.body && doc.body.firstElementChild;
      if (!root) return '';
      blocked = root.querySelectorAll('script,style,iframe,object,embed,link,meta,base,form,input,button,textarea,select,option,frame,frameset');
      Array.prototype.slice.call(blocked).forEach(function (node) { if (node && node.parentNode) node.parentNode.removeChild(node); });
      Array.prototype.slice.call(root.querySelectorAll('*')).forEach(function (node) {
        Array.prototype.slice.call(node.attributes || []).forEach(function (attr) {
          var name = String(attr.name || '').toLowerCase();
          var value = String(attr.value || '');
          if (name.indexOf('on') === 0 || name === 'style' || name === 'srcdoc' || name === 'sandbox') { node.removeAttribute(attr.name); return; }
          if (name === 'href' || name === 'src' || name === 'xlink:href' || name === 'action') {
            value = sanitizeUrl(value);
            if (!value) node.removeAttribute(attr.name);
            else node.setAttribute(attr.name, value);
          }
        });
        if (String(node.tagName || '').toLowerCase() === 'a') {
          node.setAttribute('target', '_blank');
          node.setAttribute('rel', 'noopener noreferrer');
        }
        if (String(node.tagName || '').toLowerCase() === 'img') {
          node.setAttribute('loading', 'lazy');
          node.setAttribute('decoding', 'async');
        }
      });
      return root.innerHTML;
    }
    return raw
      .replace(/<script[\s\S]*?<\/script>/gi, '')
      .replace(/<style[\s\S]*?<\/style>/gi, '')
      .replace(/<iframe[\s\S]*?<\/iframe>/gi, '')
      .replace(/\son[a-z]+=("[^"]*"|'[^']*'|[^\s>]+)/gi, '')
      .replace(/\s(srcdoc|style|sandbox)=("[^"]*"|'[^']*'|[^\s>]+)/gi, '')
      .replace(/(href|src)=("|')\s*(javascript|data|vbscript):[^"']*\2/gi, '');
  }

  function inlineMarkdownHtml(bodyHtml) {
    return '<div class="mioos-markdown-preview-content" data-markdown-inline-render="1">' + sanitizeInlineHtml(bodyHtml) + '</div>';
  }

  function plainTextDocument(text) {
    return '<pre class="mioos-markdown-preview-fallback">' + escapeHtml(text) + '</pre>';
  }

  function htmlPreviewDocument(html) {
    var raw = String(html || '');
    if (/<!doctype|<html[\s>]/i.test(raw)) return raw;
    return '<!doctype html><html><head><meta charset="utf-8"><base target="_blank"></head><body>' + raw + '</body></html>';
  }

  function renderMarkdownDocument(markdown) {
    return load().then(function (marked) {
      var html = marked.parse(String(markdown || ''));
      return { ok: 1, html: inlineMarkdownHtml(html), strategy: 'inline-sanitized-markdown-no-iframe' };
    }).catch(function (err) {
      return { ok: 0, html: plainTextDocument(markdown), strategy: 'inline-plain-text-fallback-no-iframe', error: (err && err.message) || 'marked_unavailable' };
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
    sanitizeInlineHtml: sanitizeInlineHtml,
    inlineMarkdownHtml: inlineMarkdownHtml,
    sandboxStrategy: 'html-only-sandboxed-iframe-markdown-inline-sanitized',
    noDataUrl: true,
    getLastError: function () { return lastError; }
  };
}(window));
