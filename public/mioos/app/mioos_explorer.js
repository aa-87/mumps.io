(function () {
  function clone(value) {
    return JSON.parse(JSON.stringify(value || {}));
  }

  function nextWindowId(vm, prefix) {
    vm._mioosWindowSeq = (vm._mioosWindowSeq || 0) + 1;
    return (prefix || 'win') + '-' + vm._mioosWindowSeq;
  }

  function detectTextLike(entry) {
    var mime = ((entry || {}).mime || '').toLowerCase();
    var name = ((entry || {}).name || (entry || {}).title || '').toLowerCase();
    return mime.indexOf('text/') === 0 || mime.indexOf('json') >= 0 || /\.(txt|md|m|json|js|css|html|xml|log|csv)$/i.test(name);
  }

  function detectPdfLike(entry) {
    var mime = ((entry || {}).mime || '').toLowerCase();
    var name = ((entry || {}).name || (entry || {}).title || '').toLowerCase();
    return mime.indexOf('application/pdf') === 0 || /\.pdf$/i.test(name);
  }

  function detectStructuredLike(entry) {
    var mime = ((entry || {}).mime || '').toLowerCase();
    var name = ((entry || {}).name || (entry || {}).title || '').toLowerCase();
    return mime.indexOf('json') >= 0 || mime.indexOf('markdown') >= 0 || /\.(json|md|markdown|yml|yaml|xml|csv)$/i.test(name);
  }

  function detectImageLike(entry) {
    var mime = ((entry || {}).mime || '').toLowerCase();
    var name = ((entry || {}).name || (entry || {}).title || '').toLowerCase();
    return mime.indexOf('image/') === 0 || /\.(png|jpg|jpeg|gif|bmp|webp|svg)$/i.test(name);
  }

  function detectAudioLike(entry) {
    var mime = ((entry || {}).mime || '').toLowerCase();
    var name = ((entry || {}).name || (entry || {}).title || '').toLowerCase();
    return mime.indexOf('audio/') === 0 || /\.(mp3|wav|ogg|m4a|aac|flac|weba)$/i.test(name);
  }

  function detectVideoLike(entry) {
    var mime = ((entry || {}).mime || '').toLowerCase();
    var name = ((entry || {}).name || (entry || {}).title || '').toLowerCase();
    return mime.indexOf('video/') === 0 || /\.(mp4|webm|ogv|mov|m4v)$/i.test(name);
  }

  function makeDownloadHref(data, mime) {
    var blob;
    if (!data) return '';
    if (typeof data === 'string' && data.indexOf('data:') === 0) return data;
    blob = new window.Blob([data], { type: mime || 'application/octet-stream' });
    return window.URL.createObjectURL(blob);
  }

  function stringToBytes(raw) {
    var value = String(raw || '');
    var bytes = new Uint8Array(value.length);
    var i;
    for (i = 0; i < value.length; i += 1) bytes[i] = value.charCodeAt(i) & 255;
    return bytes;
  }

  function bytesToHex(bytes) {
    var out = '';
    var i;
    for (i = 0; i < bytes.length; i += 1) out += bytes[i].toString(16).padStart(2, '0');
    return out;
  }

  function sha256Hex(raw) {
    if (!window.crypto || !window.crypto.subtle) return Promise.resolve('');
    return window.crypto.subtle.digest('SHA-256', stringToBytes(raw)).then(function (hash) {
      return bytesToHex(new Uint8Array(hash));
    }).catch(function () {
      return '';
    });
  }

  function normalizeStructuredContent(content, mime) {
    var out = content || '';
    if (!out) return '';
    if ((mime || '').toLowerCase().indexOf('json') >= 0) {
      try { return JSON.stringify(JSON.parse(out), null, 2); } catch (err) {}
    }
    return out;
  }

  function payloadRoot(msg) {
    return (msg && (msg.vfs || msg.fs || msg.download || msg.result || msg)) || {};
  }

  function extractItems(payload) {
    var raw = clone((payload && (payload.entries || payload.items || payload.children || (payload.folder || {}).entries)) || []);
    var out = [];
    var keys;
    if (Array.isArray(raw)) return raw;
    if (!raw || typeof raw !== 'object') return [];
    keys = Object.keys(raw).sort(function (a, b) {
      var an = +a;
      var bn = +b;
      if (!isNaN(an) && !isNaN(bn)) return an - bn;
      return a < b ? -1 : (a > b ? 1 : 0);
    });
    keys.forEach(function (key) {
      if (raw[key] && typeof raw[key] === 'object') out.push(raw[key]);
    });
    return out;
  }

  function extractFolder(payload, folderId) {
    var folder = clone((payload && (payload.folder || payload.entry || payload.meta)) || {});
    if (!folder.id && folderId) folder.id = folderId;
    if (!folder.name) folder.name = folder.title || 'Folder';
    if (!folder.path) folder.path = folder.name || '/';
    return folder;
  }

  function textFromPayload(payload) {
    return String(payload.text || payload.content || payload.data || '');
  }

  function createUploadInput(onchange) {
    var input = document.createElement('input');
    input.type = 'file';
    input.style.position = 'fixed';
    input.style.left = '-9999px';
    input.style.top = '-9999px';
    input.addEventListener('change', onchange, { once: true });
    document.body.appendChild(input);
    input.click();
  }

  function fileToText(file) {
    return new Promise(function (resolve, reject) {
      var reader = new FileReader();
      reader.onload = function (evt) { resolve(String((evt.target && evt.target.result) || '')); };
      reader.onerror = function () { reject(new Error('file_read_failed')); };
      reader.readAsText(file);
    });
  }

  function blobToArrayBuffer(blob) {
    return new Promise(function (resolve, reject) {
      var reader = new FileReader();
      reader.onload = function (evt) { resolve((evt.target && evt.target.result) || new ArrayBuffer(0)); };
      reader.onerror = function () { reject(new Error('file_read_failed')); };
      reader.readAsArrayBuffer(blob);
    });
  }

  function fileChunkToBase64(file, start, end) {
    return blobToArrayBuffer(file.slice(start, end)).then(function (buffer) {
      return uint8ToBase64(new Uint8Array(buffer));
    });
  }

  function xhrJsonRequest(url, payload, onCreate) {
    return new Promise(function (resolve, reject) {
      var xhr = new window.XMLHttpRequest();
      if (onCreate) onCreate(xhr);
      xhr.open('POST', url, true);
      xhr.withCredentials = true;
      xhr.responseType = 'json';
      xhr.setRequestHeader('Accept', 'application/json');
      xhr.setRequestHeader('Content-Type', 'application/json');
      xhr.addEventListener('load', function () {
        var body = xhr.response;
        if (!body && xhr.responseText) {
          try { body = JSON.parse(xhr.responseText); } catch (err) { body = null; }
        }
        if (xhr.status < 200 || xhr.status >= 300 || !body) {
          var e = new Error(((body || {}).detail) || ((body || {}).reason) || ((body || {}).error) || 'request_failed');
          e.status = xhr.status;
          e.detail = (body || {}).detail || '';
          e.reason = (body || {}).reason || '';
          e.code = (body || {}).error || '';
          reject(e);
          return;
        }
        resolve(body);
      });
      xhr.addEventListener('error', function () { reject(new Error('request_failed')); });
      xhr.addEventListener('abort', function () { reject(new Error('transfer_cancelled')); });
      xhr.send(JSON.stringify(payload || {}));
    });
  }

  function xhrArrayBufferRequest(url, headers, onCreate) {
    return new Promise(function (resolve, reject) {
      var xhr = new window.XMLHttpRequest();
      if (onCreate) onCreate(xhr);
      xhr.open('GET', url, true);
      xhr.withCredentials = true;
      xhr.responseType = 'arraybuffer';
      xhr.setRequestHeader('Accept', '*/*');
      Object.keys(headers || {}).forEach(function (key) { xhr.setRequestHeader(key, headers[key]); });
      xhr.addEventListener('load', function () {
        if (xhr.status === 401) { reject(new Error('unauthorized')); return; }
        if (xhr.status === 416) { reject(new Error('range_not_satisfiable')); return; }
        if (xhr.status < 200 || xhr.status >= 300) { reject(new Error('download_failed')); return; }
        resolve({ status: xhr.status, buffer: xhr.response || new ArrayBuffer(0), headers: xhr.getAllResponseHeaders(), xhr: xhr });
      });
      xhr.addEventListener('error', function () { reject(new Error('download_failed')); });
      xhr.addEventListener('abort', function () { reject(new Error('transfer_cancelled')); });
      xhr.send();
    });
  }

  function openTransferFileDb() {
    return new Promise(function (resolve, reject) {
      var req;
      if (!window.indexedDB) { reject(new Error('indexeddb_unavailable')); return; }
      req = window.indexedDB.open('mioos-transfer-files', 1);
      req.onupgradeneeded = function (event) {
        var db = event.target.result;
        if (!db.objectStoreNames.contains('files')) db.createObjectStore('files', { keyPath: 'id' });
      };
      req.onsuccess = function () { resolve(req.result); };
      req.onerror = function () { reject(req.error || new Error('indexeddb_open_failed')); };
    });
  }

  function idbPutTransferFile(id, file) {
    return openTransferFileDb().then(function (db) {
      return new Promise(function (resolve, reject) {
        var tx = db.transaction('files', 'readwrite');
        tx.objectStore('files').put({ id: id, file: file, name: file.name || '', type: file.type || 'application/octet-stream', lastModified: file.lastModified || 0, size: file.size || 0, updatedAt: Date.now() });
        tx.oncomplete = function () { try { db.close(); } catch (err) {} resolve(); };
        tx.onerror = function () { try { db.close(); } catch (err) {} reject(tx.error || new Error('indexeddb_put_failed')); };
      });
    });
  }

  function idbGetTransferFile(id) {
    return openTransferFileDb().then(function (db) {
      return new Promise(function (resolve, reject) {
        var tx = db.transaction('files', 'readonly');
        var req = tx.objectStore('files').get(id);
        req.onsuccess = function () {
          var rec = req.result;
          var blob;
          try { db.close(); } catch (err) {}
          if (!rec || !rec.file) { resolve(null); return; }
          if (typeof window.File === 'function' && !(rec.file instanceof window.File)) {
            blob = rec.file;
            try {
              resolve(new window.File([blob], rec.name || 'upload.bin', { type: rec.type || 'application/octet-stream', lastModified: rec.lastModified || Date.now() }));
              return;
            } catch (err2) {}
          }
          resolve(rec.file);
        };
        req.onerror = function () { try { db.close(); } catch (err) {} reject(req.error || new Error('indexeddb_get_failed')); };
      });
    });
  }

  function idbDeleteTransferFile(id) {
    return openTransferFileDb().then(function (db) {
      return new Promise(function (resolve, reject) {
        var tx = db.transaction('files', 'readwrite');
        tx.objectStore('files').delete(id);
        tx.oncomplete = function () { try { db.close(); } catch (err) {} resolve(); };
        tx.onerror = function () { try { db.close(); } catch (err) {} reject(tx.error || new Error('indexeddb_delete_failed')); };
      });
    });
  }

  function createChunkUploadWorker(task) {
    var worker = new window.Worker('/public/mioos/app/mioos_upload_worker.js');
    var settled = false;
    var promise = new Promise(function (resolve, reject) {
      worker.onmessage = function (event) {
        var msg = (event && event.data) || {};
        if (settled) return;
        if (msg.type === 'result') {
          settled = true;
          resolve(msg);
          try { worker.terminate(); } catch (err) {}
          return;
        }
        if (msg.type === 'error') {
          settled = true;
          reject(new Error(msg.error || 'worker_upload_failed'));
          try { worker.terminate(); } catch (err2) {}
        }
      };
      worker.onerror = function () {
        if (settled) return;
        settled = true;
        reject(new Error('worker_upload_failed'));
        try { worker.terminate(); } catch (err) {}
      };
      worker.postMessage(task);
    });
    return {
      worker: worker,
      promise: promise,
      cancel: function () {
        if (settled) return;
        settled = true;
        try { worker.terminate(); } catch (err) {}
      }
    };
  }

  function uint8ToBase64(uint8) {
    var binary = '';
    var i;
    for (i = 0; i < uint8.length; i += 1) binary += String.fromCharCode(uint8[i]);
    return window.btoa(binary);
  }

  function useChunkedUpload(file, isText) {
    var limit = 32768;
    if (!file) return false;
    if (file.size > limit) return true;
    return !isText;
  }


  function uploadSocketPath(vm) {
    var root = window.MIOOSState && window.MIOOSState.getRootNode ? window.MIOOSState.getRootNode() : null;
    return ((vm.boot || {}).routes || {}).websocket || (root ? root.dataset.mioosWs : '');
  }

  function socketPoolConfig(vm) {
    var conf = (vm.boot || {}).websocket || {};
    return {
      maxSocketsPerSession: Math.max(1, +(conf.maxSocketsPerSession || 4)),
      fsSockets: Math.max(1, +(conf.fsSockets || 3)),
      uploadBatchSize: Math.max(1, Math.min(2, +(conf.uploadBatchSize || 1)))
    };
  }

  function uploadTimeoutConfig(vm) {
    var conf = (vm.boot || {}).websocket || {};
    return {
      requestTimeoutMs: Math.max(8000, +(conf.requestTimeoutMs || 15000)),
      uploadBeginTimeoutMs: Math.max(10000, +(conf.uploadBeginTimeoutMs || 20000)),
      uploadChunkTimeoutMs: Math.max(15000, +(conf.uploadChunkTimeoutMs || 30000)),
      uploadCommitTimeoutMs: Math.max(30000, +(conf.uploadCommitTimeoutMs || 120000)),
      uploadAbortTimeoutMs: Math.max(8000, +(conf.uploadAbortTimeoutMs || 15000)),
      uploadSocketOpenTimeoutMs: Math.max(8000, +(conf.uploadSocketOpenTimeoutMs || 15000))
    };
  }

  function createUploadSocket(vm, ordinal) {
    var protocol = window.location.protocol === 'https:' ? 'wss://' : 'ws://';
    var path = uploadSocketPath(vm);
    var ws;
    var client;
    var seq = 0;
    var pending = {};
    var timeouts = uploadTimeoutConfig(vm);
    var socketId = 'fs-' + ordinal + '-' + Date.now() + '-' + Math.floor(Math.random() * 1000);
    if (!path || !window.WebSocket) throw new Error('socket_unavailable');
    ws = new window.WebSocket(protocol + window.location.host + path);
    if (vm.setSocketTelemetry) vm.setSocketTelemetry(socketId, { role: 'fs', ordinal: ordinal, label: 'FS Worker ' + ordinal, state: 'connecting', pendingCount: 0, openedAt: 0, helloAt: 0, lastMessageAt: 0, lastEvent: 'connect', lastError: '' });
    client = {
      socket: ws,
      ready: false,
      closed: false,
      helloReady: false,
      openPromise: null,
      close: function () {
        this.closed = true;
        if (vm.setSocketTelemetry) vm.setSocketTelemetry(socketId, { state: 'closing', lastEvent: 'close_request' });
        try {
          if (ws && ws.readyState === window.WebSocket.CONNECTING) return;
          if (ws && ws.readyState < window.WebSocket.CLOSING) ws.close();
        } catch (err) {}
      },
      command: function (command, payload) {
        var self = this;
        return self.openPromise.then(function () {
          return new Promise(function (resolve, reject) {
            var requestId = 'up-' + ordinal + '-' + Date.now() + '-' + (++seq);
            var payloadChars = (((payload || {}).data && (payload || {}).data.length) || 0);
            var timeoutMs = Math.max(timeouts.uploadChunkTimeoutMs, Math.min(180000, timeouts.uploadChunkTimeoutMs + Math.floor(payloadChars / 2048) * 250));
            var timer = window.setTimeout(function () {
              if (pending[requestId]) delete pending[requestId];
              if (vm.setSocketTelemetry) vm.setSocketTelemetry(socketId, { pendingCount: Object.keys(pending || {}).length, lastError: 'worker_command_timeout', lastEvent: 'timeout' });
              reject(new Error('worker_command_timeout'));
            }, timeoutMs);
            pending[requestId] = { resolve: function (msg) { window.clearTimeout(timer); if (vm.setSocketTelemetry) vm.setSocketTelemetry(socketId, { pendingCount: Math.max(0, Object.keys(pending || {}).length - 1), lastMessageAt: Date.now(), lastEvent: command }); resolve(msg); }, reject: function (err) { window.clearTimeout(timer); if (vm.setSocketTelemetry) vm.setSocketTelemetry(socketId, { pendingCount: Math.max(0, Object.keys(pending || {}).length - 1), lastMessageAt: Date.now(), lastError: (err && err.message) || 'worker_reject', lastEvent: 'reject' }); reject(err); } };
            try {
              if (vm.setSocketTelemetry) vm.setSocketTelemetry(socketId, { pendingCount: Object.keys(pending || {}).length, lastEvent: command });
              ws.send(JSON.stringify(Object.assign({ event: 'desktop.command', command: command, requestId: requestId }, payload || {})));
            } catch (err) {
              delete pending[requestId];
              window.clearTimeout(timer);
              reject(err);
            }
          });
        });
      }
    };
    client.openPromise = new Promise(function (resolve, reject) {
      var settled = false;
      var timer = window.setTimeout(function () {
        if (settled) return;
        settled = true;
        reject(new Error('socket_open_timeout'));
      }, timeouts.uploadSocketOpenTimeoutMs);
      ws.addEventListener('open', function () {
        client.ready = true;
        if (vm.setSocketTelemetry) vm.setSocketTelemetry(socketId, { state: 'open', openedAt: Date.now(), lastEvent: 'open', lastError: '' });
        try { ws.send(JSON.stringify({ event: 'hello', role: 'fs', socketOrdinal: ordinal })); } catch (err) {}
        window.setTimeout(function () {
          if (settled || client.helloReady) return;
          settled = true;
          window.clearTimeout(timer);
          resolve();
        }, 1000);
      });
      ws.addEventListener('error', function () {
        if (vm.setSocketTelemetry) vm.setSocketTelemetry(socketId, { state: 'error', lastEvent: 'error', lastError: 'socket_error', lastMessageAt: Date.now() });
        if (settled) return;
        settled = true;
        window.clearTimeout(timer);
        reject(new Error('socket_error'));
      });
      ws.addEventListener('close', function () {
        var keys = Object.keys(pending);
        if (vm.setSocketTelemetry) vm.setSocketTelemetry(socketId, { state: 'closed', pendingCount: 0, lastEvent: 'close', lastError: 'socket_closed', lastMessageAt: Date.now() });
        client.ready = false;
        client.closed = true;
        keys.forEach(function (key) {
          try { pending[key].reject(new Error('socket_closed')); } catch (err) {}
          delete pending[key];
        });
      });
      ws.addEventListener('message', function (evt) {
        var msg;
        var ref;
        try { msg = JSON.parse(evt.data); } catch (err) { return; }
        if (vm.setSocketTelemetry) vm.setSocketTelemetry(socketId, { lastMessageAt: Date.now(), lastEvent: msg.event || 'message', lastError: (msg.event === ((vm.boot.routes || {}).commandErrorEvent || 'desktop.error')) ? (msg.detail || msg.error || 'desktop.error') : '' });
        if (msg.event === 'hello') {
          client.helloReady = true;
          if (vm.setSocketTelemetry) vm.setSocketTelemetry(socketId, { state: 'ready', helloAt: Date.now(), lastEvent: 'hello' });
          if (!settled) {
            settled = true;
            window.clearTimeout(timer);
            resolve();
          }
          return;
        }
        if (msg.event === 'pong') return;
        ref = msg.requestId && pending[msg.requestId];
        if (ref) {
          delete pending[msg.requestId];
          if (msg.ok === 0 || msg.error) {
            ref.reject(new Error(msg.detail || msg.error || 'command_failed'));
          } else {
            ref.resolve(msg);
          }
        }
      });
    });
    return client;
  }

  window.MIOOSExplorer = {
    methods: {

      resetExplorerUpload: function (state) {
        if (!state) return;
        state.upload = { active: false, name: '', totalBytes: 0, sentBytes: 0, progress: 0, stage: '', error: '', uploadId: '' };
      },
      setExplorerUploadProgress: function (state, patch) {
        var next;
        if (!state) return;
        next = Object.assign({ active: true, name: '', totalBytes: 0, sentBytes: 0, progress: 0, stage: '', error: '', uploadId: '' }, state.upload || {}, patch || {});
        if (next.totalBytes > 0) {
          next.progress = Math.max(0, Math.min(100, Math.round((next.sentBytes / next.totalBytes) * 100)));
        }
        state.upload = next;
      },
      uploadChunkedSegments: function (uploadId, segments, state, transferControl, fileName, concurrency, batchSize) {
        var self = this;
        var workers = [];
        var nextIndex = 0;
        var completed = 0;
        var sentBytes = 0;
        var pool = socketPoolConfig(this);
        var active = Math.max(1, Math.min(pool.maxSocketsPerSession, Math.min(pool.fsSockets, +(concurrency || pool.fsSockets || 2))));
        var batchWidth = 1;
        var frameBudget = 128000;
        return new Promise(function (resolve, reject) {
          function cancelled() {
            return !!(transferControl && transferControl.cancelled);
          }
          function cleanup() {
            workers.forEach(function (worker) {
              if (worker && worker.close) worker.close();
            });
            if (transferControl) transferControl.workers = [];
          }
          function maybeDone() {
            if (cancelled()) {
              cleanup();
              reject(new Error('transfer_cancelled'));
              return 1;
            }
            if (completed >= segments.length) {
              cleanup();
              resolve();
              return 1;
            }
            return 0;
          }
          function nextBatch() {
            var batch = [];
            var localIndex;
            var chars = 0;
            while (nextIndex < segments.length && batch.length < batchWidth) {
              localIndex = nextIndex;
              if (batch.length && (chars + ((segments[localIndex] && segments[localIndex].data && segments[localIndex].data.length) || 0)) > frameBudget) break;
              batch.push({ index: localIndex + 1, data: segments[localIndex].data, bytes: segments[localIndex].bytes });
              chars += ((segments[localIndex] && segments[localIndex].data && segments[localIndex].data.length) || 0);
              nextIndex += 1;
            }
            return batch;
          }
          function sendSingle(worker, item) {
            var payload = { uploadId: uploadId, index: item.index, data: item.data, bytes: item.bytes || 0 };
            if (cancelled()) return Promise.reject(new Error('transfer_cancelled'));
            return worker.command('fs.upload.chunk', payload).catch(function () {
              var retryWorker;
              try {
                retryWorker = createUploadSocket(self, (workers.length % Math.max(1, active)) + 1);
                workers.push(retryWorker);
              } catch (err) {
                retryWorker = null;
              }
              if (retryWorker) {
                return retryWorker.openPromise.then(function () {
                  return retryWorker.command('fs.upload.chunk', payload);
                }).catch(function () {
                  return self.socketRequest((self.boot.routes || {}).commandEvent || 'desktop.command', Object.assign({ command: 'fs.upload.chunk' }, payload), { command: 'fs.upload.chunk', dedupeKey: 'fs.upload.chunk|' + item.index + '|' + uploadId, timeoutMs: uploadTimeoutConfig(self).uploadChunkTimeoutMs });
                });
              }
              return self.socketRequest((self.boot.routes || {}).commandEvent || 'desktop.command', Object.assign({ command: 'fs.upload.chunk' }, payload), { command: 'fs.upload.chunk', dedupeKey: 'fs.upload.chunk|' + item.index + '|' + uploadId, timeoutMs: uploadTimeoutConfig(self).uploadChunkTimeoutMs });
            });
          }
          function sendBatch(worker, batch) {
            if (cancelled()) return Promise.reject(new Error('transfer_cancelled'));
            if (batch.length <= 1) return sendSingle(worker, batch[0]);
            return worker.command('fs.upload.batch', {
              uploadId: uploadId,
              chunks: batch.map(function (item) {
                return { index: item.index, data: item.data, bytes: item.bytes || 0 };
              })
            }).catch(function () {
              var chain = Promise.resolve();
              batch.forEach(function (item) {
                chain = chain.then(function () { return sendSingle(worker, item); });
              });
              return chain;
            });
          }
          function launchWorker(slot) {
            var worker;
            function pump() {
              var batch = nextBatch();
              var batchBytes = 0;
              if (cancelled()) {
                cleanup();
                reject(new Error('transfer_cancelled'));
                return;
              }
              if (!batch.length) return;
              batch.forEach(function (item) { batchBytes += (item.bytes || 0); });
              sendBatch(worker, batch).then(function () {
                completed += batch.length;
                sentBytes += batchBytes;
                self.setExplorerUploadProgress(state, {
                  active: true,
                  name: fileName,
                  totalBytes: state.upload.totalBytes,
                  sentBytes: sentBytes,
                  stage: 'Uploading ' + completed + ' / ' + segments.length
                });
                if (state.upload && state.upload.transferId && self.updateTransfer) self.updateTransfer(state.upload.transferId, { status: 'uploading', stage: 'Uploading ' + completed + ' / ' + segments.length, processedBytes: sentBytes, totalBytes: state.upload.totalBytes });
                if (!maybeDone()) pump();
              }).catch(function (err) {
                cleanup();
                reject(err);
              });
            }
            try {
              worker = createUploadSocket(self, slot + 1);
              workers.push(worker);
              if (transferControl) transferControl.workers = workers;
              worker.openPromise.then(function () {
                pump();
              }).catch(function (err) {
                cleanup();
                reject(err);
              });
            } catch (err) {
              cleanup();
              reject(err);
            }
          }
          if (!segments.length) { resolve(); return; }
          for (var i = 0; i < active; i += 1) launchWorker(i);
        });
      },
      explorerItemGlyph: function (item) {
        if (detectImageLike(item)) return '🖼';
        if (detectAudioLike(item)) return '🎵';
        if (detectVideoLike(item)) return '🎬';
        return ((item || {}).kind || (item || {}).type) === 'folder' ? '📁' : '📄';
      },
      explorerCanPreviewInline: function (item) {
        return detectTextLike(item) || detectImageLike(item) || detectAudioLike(item) || detectVideoLike(item);
      },
      ensureExplorerWindowState: function (win) {
        if (!win) return null;
        if (!win.explorerState) {
          win.explorerState = {
            initialized: false,
            loading: false,
            folderId: (win.meta || {}).folderId || ((this.boot.vfs || {}).homeId || (this.boot.vfs || {}).rootId || 'root'),
            folder: { id: '', name: '', path: '' },
            items: [],
            selection: null,
            error: '',
            preview: { title: '', content: '', mime: 'text/plain', imageSrc: '', mediaSrc: '', mediaKind: '' },
            upload: { active: false, name: '', totalBytes: 0, sentBytes: 0, progress: 0, stage: '', error: '', uploadId: '' },
            contextMenu: { open: false, type: 'folder', left: 0, top: 0, item: null }
          };
        }
        return win.explorerState;
      },
      bootstrapExplorerWindow: function (windowId, force) {
        var win = this.windows.find(function (item) { return item.id === windowId; });
        var state;
        if (!win || (win.appKey !== 'my-computer' && win.appKey !== 'documents' && win.appKey !== 'explorer')) return;
        state = this.ensureExplorerWindowState(win);
        if (state.initialized && !force) return;
        state.initialized = true;
        if (win.appKey === 'documents' && (this.boot.vfs || {}).homeId) {
          state.folderId = (win.meta && win.meta.folderId) || this.boot.vfs.homeId;
        }
        this.loadExplorerFolder(win.id, state.folderId, { selectFirst: true });
      },
      loadExplorerFolder: function (windowId, folderId, options) {
        var self = this;
        var win = this.windows.find(function (item) { return item.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        if (!win || !state || !folderId || !this.command) return Promise.resolve();
        state.loading = true;
        state.error = '';
        return this.command('fs.list', { id: folderId, parent: folderId }).then(function (msg) {
          var payload = payloadRoot(msg);
          var folder = extractFolder(payload, folderId);
          var items = extractItems(payload);
          items.sort(function (a, b) {
            var ak = (a.kind || a.type || '').toLowerCase();
            var bk = (b.kind || b.type || '').toLowerCase();
            if (ak !== bk) {
              if (ak === 'folder') return -1;
              if (bk === 'folder') return 1;
            }
            var an = (a.name || a.title || '').toLowerCase();
            var bn = (b.name || b.title || '').toLowerCase();
            return an < bn ? -1 : (an > bn ? 1 : 0);
          });
          state.folderId = folder.id || folderId;
          state.folder = folder;
          state.items = items;
          state.loading = false;
          state.selection = null;
          state.preview = { title: '', content: '', mime: 'text/plain', imageSrc: '', mediaSrc: '', mediaKind: '' };
          if ((options || {}).selectFirst && items.length) self.selectExplorerItem(win.id, items[0]);
          win.title = folder.name || win.title;
          return msg;
        }).catch(function (err) {
          state.loading = false;
          state.error = (err && err.message) || 'fs_list_failed';
          if (self.showAlert) self.showAlert(self.t('alerts.shellEventError.title', 'Explorer'), state.error);
        });
      },
      selectExplorerItem: function (windowId, item) {
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        if (!state) return;
        state.selection = clone(item || null);
        if (state.selection && detectTextLike(state.selection)) {
          this.previewTextFile(windowId, state.selection);
        } else if (state.selection && detectImageLike(state.selection)) {
          this.previewImageFile(windowId, state.selection);
        } else {
          state.preview = { title: '', content: '', mime: 'text/plain', imageSrc: '', mediaSrc: '', mediaKind: '' };
        }
      },
      previewTextFile: function (windowId, item) {
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        var limit = this.explorerInlineTextLimit();
        if (!win || !state || !item || !this.command) return Promise.resolve();
        if (+((item || {}).size || 0) > limit) {
          state.preview = {
            title: item.name || item.title || '',
            content: 'Large file preview is available in the viewer window over HTTP.',
            mime: item.mime || 'text/plain',
            imageSrc: '',
            mediaSrc: '',
            mediaKind: ''
          };
          return Promise.resolve();
        }
        state.preview = { title: item.name || item.title || '', content: '', mime: item.mime || 'text/plain', imageSrc: '', mediaSrc: '', mediaKind: '' };
        return this.command('fs.read', { id: item.id || item.key || item.fileId }).then(function (msg) {
          var payload = payloadRoot(msg);
          state.preview = {
            title: item.name || item.title || '',
            content: detectStructuredLike(item) ? normalizeStructuredContent(textFromPayload(payload), payload.mime || item.mime || 'text/plain') : textFromPayload(payload),
            mime: item.mime || payload.mime || 'text/plain',
            imageSrc: '',
            mediaSrc: '',
            mediaKind: ''
          };
          return msg;
        }).catch(function (err) {
          state.preview = {
            title: item.name || item.title || '',
            content: (err && err.message) || 'Unable to load preview.',
            mime: item.mime || 'text/plain',
            imageSrc: '',
            mediaSrc: '',
            mediaKind: ''
          };
        });
      },
      previewImageFile: function (windowId, item) {
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        var url = this.buildExplorerFileUrl(item, 'preview');
        if (!win || !state || !item) return Promise.resolve();
        if (url) {
          state.preview = { title: item.name || item.title || '', content: '', mime: item.mime || 'image/*', imageSrc: url, mediaSrc: '', mediaKind: '' };
          return Promise.resolve();
        }
        if (!this.command) return Promise.resolve();
        state.preview = { title: item.name || item.title || '', content: '', mime: item.mime || 'image/*', imageSrc: '', mediaSrc: '', mediaKind: '' };
        return this.command('fs.read', { id: item.id || item.key || item.fileId }).then(function (msg) {
          var payload = payloadRoot(msg);
          state.preview = {
            title: item.name || item.title || '',
            content: '',
            mime: item.mime || payload.mime || 'image/*',
            imageSrc: textFromPayload(payload),
            mediaSrc: '',
            mediaKind: ''
          };
          return msg;
        }).catch(function (err) {
          state.preview = {
            title: item.name || item.title || '',
            content: (err && err.message) || 'Unable to load image preview.',
            mime: item.mime || 'image/*',
            imageSrc: '',
            mediaSrc: '',
            mediaKind: ''
          };
        });
      },
      previewMediaFile: function (windowId, item) {
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        var mediaKind = detectVideoLike(item) ? 'video' : 'audio';
        var url = this.buildExplorerFileUrl(item, 'preview');
        if (!win || !state || !item) return Promise.resolve();
        if (url) {
          state.preview = { title: item.name || item.title || '', content: '', mime: item.mime || (mediaKind + '/*'), imageSrc: '', mediaSrc: url, mediaKind: mediaKind };
          return Promise.resolve();
        }
        if (!this.command) return Promise.resolve();
        state.preview = { title: item.name || item.title || '', content: '', mime: item.mime || (mediaKind + '/*'), imageSrc: '', mediaSrc: '', mediaKind: mediaKind };
        return this.command('fs.read', { id: item.id || item.key || item.fileId }).then(function (msg) {
          var payload = payloadRoot(msg);
          state.preview = {
            title: item.name || item.title || '',
            content: '',
            mime: item.mime || payload.mime || (mediaKind + '/*'),
            imageSrc: '',
            mediaSrc: textFromPayload(payload),
            mediaKind: mediaKind
          };
          return msg;
        }).catch(function (err) {
          state.preview = {
            title: item.name || item.title || '',
            content: (err && err.message) || ('Unable to load ' + mediaKind + ' preview.'),
            mime: item.mime || (mediaKind + '/*'),
            imageSrc: '',
            mediaSrc: '',
            mediaKind: mediaKind
          };
        });
      },
      explorerOpenSelected: function (windowId) {
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        var item = state && state.selection;
        if (!item) return;
        this.explorerOpenItem(windowId, item);
      },
      explorerOpenItem: function (windowId, item) {
        var kind = ((item || {}).kind || (item || {}).type || '').toLowerCase();
        if (kind === 'folder') {
          this.loadExplorerFolder(windowId, item.id || item.key || item.folderId, { selectFirst: true });
          return;
        }
        if (detectImageLike(item)) {
          this.openImageViewerWindow(item);
          return;
        }
        if (detectAudioLike(item) || detectVideoLike(item)) {
          this.openMediaViewerWindow(item);
          return;
        }
        if (detectPdfLike(item)) {
          this.openPdfViewerWindow(item);
          return;
        }
        if (detectStructuredLike(item)) {
          this.openStructuredViewerWindow(item);
          return;
        }
        if (detectTextLike(item)) {
          this.openTextViewerWindow(item);
        }
      },
      explorerGoUp: function (windowId) {
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        var parentId = (((state || {}).folder || {}).parentId) || (((win || {}).meta || {}).parentId);
        if (!parentId && (this.boot.vfs || {}).rootId && state && state.folderId !== this.boot.vfs.rootId) parentId = this.boot.vfs.rootId;
        if (!parentId) return;
        this.loadExplorerFolder(windowId, parentId, { selectFirst: true });
      },
      refreshExplorerWindow: function (windowId) {
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        if (!state) return Promise.resolve();
        return this.loadExplorerFolder(windowId, state.folderId, { selectFirst: false });
      },
      refreshAllExplorerWindows: function () {
        var self = this;
        var tasks = (this.windows || []).filter(function (win) { return ['my-computer','documents','explorer'].indexOf(win.appKey) >= 0; }).map(function (win) { return self.refreshExplorerWindow(win.id); });
        return Promise.all(tasks);
      },
      closeExplorerContextMenus: function () {
        (this.windows || []).forEach(function (win) {
          if (win && win.explorerState && win.explorerState.contextMenu) win.explorerState.contextMenu.open = false;
        });
      },
      explorerContextMenuStyle: function (state) {
        return { left: ((state || {}).contextMenu || {}).left + 'px', top: ((state || {}).contextMenu || {}).top + 'px' };
      },
      openExplorerContextMenu: function (windowId, item, event) {
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        if (!state) return;
        state.contextMenu = { open: true, type: 'item', left: event.clientX, top: event.clientY, item: clone(item || null) };
        if (item) state.selection = clone(item);
      },
      explorerDragStart: function (windowId, item, event) {
        if (!event || !event.dataTransfer || !item) return;
        event.dataTransfer.effectAllowed = 'copyMove';
        event.dataTransfer.setData('application/x-mioos-entry', JSON.stringify({ windowId: windowId, item: item }));
      },
      explorerDragOver: function (windowId, target, event) {
        if (event && event.dataTransfer) event.dataTransfer.dropEffect = event.ctrlKey ? 'copy' : 'move';
      },
      explorerHandleDrop: function (windowId, target, event) {
        var data, parsed, destId, action, self = this;
        if (!event || !event.dataTransfer) return Promise.resolve();
        data = event.dataTransfer.getData('application/x-mioos-entry');
        if (!data) return Promise.resolve();
        try { parsed = JSON.parse(data); } catch (err) { parsed = null; }
        if (!parsed || !parsed.item) return Promise.resolve();
        destId = (target && target.kind === 'folder') ? (target.id || target.key) : ((this.ensureExplorerWindowState(this.windows.find(function (entry) { return entry.id === windowId; })) || {}).folderId);
        action = event.ctrlKey ? 'copy' : 'move';
        if (action === 'copy') {
          return this.command('fs.copy', { id: parsed.item.id || parsed.item.key || '', parent: destId }).then(function () { return self.refreshAllExplorerWindows(); });
        }
        return this.command('fs.move', { id: parsed.item.id || parsed.item.key || '', parent: destId }).then(function () { return self.refreshAllExplorerWindows(); });
      },
      explorerContextAction: function (windowId, action) {
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        var item = ((state || {}).contextMenu || {}).item || (state || {}).selection;
        if (state && state.contextMenu) state.contextMenu.open = false;
        if (action === 'open') return this.explorerOpenSelected(windowId);
        if (action === 'download') return this.explorerDownloadSelected(windowId);
        if (action === 'rename') return this.explorerRenameSelected(windowId);
        if (action === 'copy') return this.explorerCopySelected(windowId);
        if (action === 'move') return this.explorerMoveSelected(windowId);
        if (action === 'delete') return this.explorerDeleteSelected(windowId);
        if (action === 'new-folder') return this.explorerCreateFolder(windowId);
        if (action === 'refresh') return this.refreshExplorerWindow(windowId);
        return Promise.resolve(item);
      },
      explorerCopySelected: function (windowId) {
        var self = this;
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        var item = state && state.selection;
        var destination = '';
        if (!item || !this.command) return Promise.resolve();
        destination = ((this.boot.vfs || {}).homeId || (this.boot.vfs || {}).rootId || 'root');
        return this.command('fs.copy', { id: item.id || item.key || '', parent: destination }).then(function () { return self.refreshAllExplorerWindows(); });
      },
      ensureFreshUploadAuth: function () {
        var auth = ((this.boot || {}).auth || {});
        if (!auth.enabled || !auth.required) return Promise.resolve();
        if (this.refreshAuthSession) return this.refreshAuthSession().catch(function () { return null; });
        return Promise.resolve();
      },
      handleUploadAuthFailure: function (err) {
        var reason = (err && (err.detail || err.reason || err.code || err.message)) || '';
        if (reason === 'jwt_expired' || reason === 'login_required' || reason === 'auth_refresh_failed') {
          if (this.handleExpiredAuth) return this.handleExpiredAuth('Your session expired before the upload completed. Please sign in again.');
        }
        return Promise.resolve();
      },
      explorerUploadRoute: function () {
        return ((this.boot.routes || {}).fsUpload) || '/api/mioos/fs/upload';
      },
      explorerUploadBeginRoute: function () { return ((this.boot.routes || {}).fsUploadBegin) || '/api/mioos/fs/upload/begin'; },
      explorerUploadChunkRoute: function () { return ((this.boot.routes || {}).fsUploadChunk) || '/api/mioos/fs/upload/chunk'; },
      explorerUploadStatusRoute: function () { return ((this.boot.routes || {}).fsUploadStatus) || '/api/mioos/fs/upload/status'; },
      explorerUploadCommitRoute: function () { return ((this.boot.routes || {}).fsUploadCommit) || '/api/mioos/fs/upload/commit'; },
      explorerUploadAbortRoute: function () { return ((this.boot.routes || {}).fsUploadAbort) || '/api/mioos/fs/upload/abort'; },
      explorerUploadMode: function () {
        var mode = ((((this.boot || {}).vfs || {}).uploadMode) || 'resumable-chunk-session');
        mode = String(mode || '').toLowerCase();
        if (mode === 'single' || mode === 'single-request-http' || mode === 'single-request-multipart') return 'single-request';
        return mode === 'single-request' ? mode : 'resumable-chunk-session';
      },
      explorerUploadWorkerEnabled: function () {
        return !!+((((this.boot || {}).vfs || {}).uploadWorkerEnabled) ? 1 : 0);
      },
      saveTransferFileBlob: function (transferId, file) {
        if (!transferId || !file || !this.transferPersistenceEnabled || !this.transferPersistenceEnabled()) return Promise.resolve();
        return idbPutTransferFile(transferId, file).catch(function () { return null; });
      },
      loadTransferFileBlob: function (transferId) {
        if (!transferId || !this.transferPersistenceEnabled || !this.transferPersistenceEnabled()) return Promise.resolve(null);
        return idbGetTransferFile(transferId).catch(function () { return null; });
      },
      deleteTransferFileBlob: function (transferId) {
        if (!transferId || !this.transferPersistenceEnabled || !this.transferPersistenceEnabled()) return Promise.resolve();
        return idbDeleteTransferFile(transferId).catch(function () { return null; });
      },
      uploadChunkWithWorker: function (file, route, uploadId, idx, start, end) {
        return createChunkUploadWorker({ type: 'uploadChunk', route: route, uploadId: uploadId, index: idx, bytes: Math.max(0, end - start), file: file, start: start, end: end });
      },
      restorePersistedUploadTransfers: function () {
        var self = this;
        (this.transferCenter.items || []).forEach(function (item) {
          var meta = (item || {}).resumeMeta || {};
          if (!item || item.kind !== 'upload' || meta.mode !== 'resumable-chunk-session') return;
          if (self.transferController(item.id)) return;
          if (['uploading','preparing','queued','finalizing','verifying','cancelling'].indexOf(item.status) >= 0) self.updateTransfer(item.id, { status: 'paused', stage: 'Paused after refresh' });
          self.setTransferController(item.id, {
            onResume: function () { return self.resumePersistedUploadTransfer(item.id); },
            onRestart: function () { return self.restartPersistedUploadTransfer(item.id); },
            onCancel: function () { return self.cancelPersistedUploadTransfer(item.id); },
            onRetry: function () { return self.restartPersistedUploadTransfer(item.id); }
          });
        });
      },
      explorerCopyRoute: function () { return ((this.boot.routes || {}).fsCopy) || '/api/mioos/fs/copy'; },
      explorerDownloadRoute: function () {
        return ((this.boot.routes || {}).fsDownload) || '/api/mioos/fs/download';
      },
      explorerPreviewRoute: function () {
        return ((this.boot.routes || {}).fsPreview) || '/api/mioos/fs/preview';
      },
      explorerInlineTextLimit: function () {
        return +((((this.boot || {}).vfs || {}).previewInlineTextMaxBytes) || 262144);
      },
      buildExplorerFileUrl: function (item, kind) {
        var base = kind === 'download' ? this.explorerDownloadRoute() : this.explorerPreviewRoute();
        var id = encodeURIComponent(((item || {}).id || (item || {}).key || (item || {}).fileId || ''));
        if (!base || !id) return '';
        return base + (base.indexOf('?') >= 0 ? '&' : '?') + 'id=' + id;
      },
      isBrowserManagedUrl: function (value) {
        return typeof value === 'string' && (value.indexOf('blob:') === 0 || value.indexOf('data:') === 0);
      },
      httpUploadFilesToExplorer: function (windowId, file, win, state, transferId, transferControl) {
        var self = this;
        return new Promise(function (resolve, reject) {
          var xhr;
          var form;
          if (!window.XMLHttpRequest || !window.FormData) {
            reject(new Error('http_upload_unavailable'));
            return;
          }
          xhr = new window.XMLHttpRequest();
          form = new window.FormData();
          form.append('parent', state.folderId || ((self.boot.vfs || {}).rootId || 'root'));
          form.append('parentTitle', (((state || {}).folder || {}).name) || (((state || {}).folder || {}).path) || '/');
          form.append('file', file, file.name || 'upload.bin');
          transferControl.xhr = xhr;
          xhr.open('POST', self.explorerUploadRoute(), true);
          xhr.withCredentials = true;
          xhr.responseType = 'json';
          xhr.setRequestHeader('Accept', 'application/json');
          xhr.upload.addEventListener('progress', function (evt) {
            var total = evt && evt.total ? evt.total : (file.size || 0);
            var loaded = evt && evt.loaded ? evt.loaded : 0;
            var progress = total > 0 ? Math.min(100, Math.round((loaded / total) * 100)) : 0;
            self.setExplorerUploadProgress(state, {
              active: true,
              name: file.name,
              totalBytes: total || file.size || 0,
              sentBytes: loaded,
              progress: progress,
              stage: progress >= 100 ? 'Finalizing' : 'Uploading via HTTP',
              error: '',
              uploadId: ''
            });
            if (transferId && self.updateTransfer) {
              self.updateTransfer(transferId, {
                status: progress >= 100 ? 'finalizing' : 'uploading',
                stage: progress >= 100 ? 'Finalizing' : 'Uploading via HTTP',
                processedBytes: loaded,
                totalBytes: total || file.size || 0,
                progress: progress
              });
            }
          });
          xhr.addEventListener('abort', function () {
            reject(new Error('transfer_cancelled'));
          });
          xhr.addEventListener('error', function () {
            reject(new Error('fs_upload_failed'));
          });
          xhr.addEventListener('load', function () {
            var body = xhr.response;
            var err;
            if (!body && xhr.responseText) {
              try { body = JSON.parse(xhr.responseText); } catch (parseErr) { body = null; }
            }
            if (xhr.status < 200 || xhr.status >= 300 || !body || body.ok !== 1) {
              err = new Error(((body || {}).detail) || ((body || {}).reason) || ((body || {}).error) || 'fs_upload_failed');
              if (body && typeof body === 'object') {
                if (body.detail) err.detail = body.detail;
                if (body.reason) err.reason = body.reason;
                if (body.error) err.code = body.error;
              }
              reject(err);
              return;
            }
            resolve(body);
          });
          xhr.send(form);
        });
      },
      resumePersistedUploadTransfer: function (transferId) {
        var item = (this.transferCenter.items || []).find(function (entry) { return entry.id === transferId; });
        var meta = (item || {}).resumeMeta || {};
        var self = this;
        if (!item || meta.mode !== 'resumable-chunk-session') return Promise.resolve();
        return this.loadTransferFileBlob(transferId).then(function (file) {
          if (!file) throw new Error('persisted_file_missing');
          return self.startResumableUploadFlow(meta.windowId || item.sourceWindowId || '', file, transferId, item, meta, true, false);
        });
      },
      restartPersistedUploadTransfer: function (transferId) {
        var item = (this.transferCenter.items || []).find(function (entry) { return entry.id === transferId; });
        var meta = (item || {}).resumeMeta || {};
        var self = this;
        if (!item || meta.mode !== 'resumable-chunk-session') return Promise.resolve();
        return this.loadTransferFileBlob(transferId).then(function (file) {
          if (!file) throw new Error('persisted_file_missing');
          return self.startResumableUploadFlow(meta.windowId || item.sourceWindowId || '', file, transferId, item, meta, false, true);
        });
      },
      cancelPersistedUploadTransfer: function (transferId) {
        var item = (this.transferCenter.items || []).find(function (entry) { return entry.id === transferId; });
        var meta = (item || {}).resumeMeta || {};
        var self = this;
        if (meta.uploadId) {
          return xhrJsonRequest(self.explorerUploadAbortRoute(), { uploadId: meta.uploadId }).catch(function () { return null; }).then(function () {
            return self.deleteTransferFileBlob(transferId);
          }).then(function () {
            self.updateTransfer(transferId, { status: 'cancelled', stage: 'Cancelled', resumeMeta: {} });
          });
        }
        return this.deleteTransferFileBlob(transferId).then(function () {
          self.updateTransfer(transferId, { status: 'cancelled', stage: 'Cancelled', resumeMeta: {} });
        });
      },
      startResumableUploadFlow: function (windowId, file, transferId, transferItem, resumeMeta, resumeExisting, forceRestart) {
        var self = this;
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        var mime = (file && file.type) || ((resumeMeta || {}).mime) || 'application/octet-stream';
        var chunkBytes = +((((self.boot || {}).vfs || {}).uploadChunkBytes) || 128000);
        var concurrency = +((((self.boot || {}).vfs || {}).uploadConcurrency) || 4);
        var totalChunks;
        var control;
        var persistedCompleted = {};
        if (!state) return Promise.resolve();
        if (!Number.isFinite(chunkBytes) || chunkBytes < 4096) chunkBytes = 128000;
        if (!Number.isFinite(concurrency) || concurrency < 1) concurrency = 1;
        if (concurrency > 32) concurrency = 32;
        totalChunks = file.size > 0 ? Math.ceil(file.size / chunkBytes) : 0;
        ((resumeMeta || {}).completedIndexes || []).forEach(function (idx) { persistedCompleted[+idx] = 1; });
        function chunkSpan(idx) {
          var start = (idx - 1) * chunkBytes;
          var end = Math.min(start + chunkBytes, file.size);
          return { start: start, end: end, bytes: Math.max(0, end - start) };
        }
        function computeCompletedBytes(map) {
          return Object.keys(map || {}).reduce(function (sum, key) {
            var idx = +key;
            var span = chunkSpan(idx);
            return sum + span.bytes;
          }, 0);
        }
        control = {
          paused: false,
          cancelled: false,
          uploadId: forceRestart ? '' : ((resumeMeta || {}).uploadId || ''),
          active: {},
          completed: persistedCompleted,
          completedBytes: computeCompletedBytes(persistedCompleted),
          retryQueue: ((resumeMeta || {}).retryQueue || []).slice(),
          nextIndex: +((resumeMeta || {}).nextIndex || 1),
          totalChunks: totalChunks,
          commitStarted: false,
          loopResolve: null,
          loopReject: null,
          startedAt: Date.now(),
          workerEnabled: self.explorerUploadWorkerEnabled()
        };
        function completedIndexes() {
          return Object.keys(control.completed).map(function (key) { return +key; }).sort(function (a, b) { return a - b; });
        }
        function persistMeta() {
          if (!transferId || !self.updateTransfer) return;
          self.updateTransfer(transferId, {
            resumeMeta: Object.assign({}, (transferItem || {}).resumeMeta || {}, {
              mode: 'resumable-chunk-session',
              windowId: windowId,
              folderId: state.folderId,
              fileName: file.name,
              mime: mime,
              totalBytes: file.size,
              chunkBytes: chunkBytes,
              concurrency: concurrency,
              totalChunks: totalChunks,
              uploadId: control.uploadId,
              nextIndex: control.nextIndex,
              retryQueue: control.retryQueue.slice(),
              completedIndexes: completedIndexes(),
              workerEnabled: !!control.workerEnabled,
              persistedAt: Date.now()
            })
          });
          transferItem = (self.transferCenter.items || []).find(function (entry) { return entry.id === transferId; }) || transferItem;
        }
        function activeCount() { return Object.keys(control.active).length; }
        function markProgress(stageLabel) {
          if (transferId && self.updateTransfer) {
            self.updateTransfer(transferId, {
              status: control.paused ? 'paused' : 'uploading',
              stage: stageLabel || (control.paused ? 'Paused' : 'Uploading'),
              processedBytes: control.completedBytes,
              totalBytes: file.size,
              progress: file.size > 0 ? Math.round((control.completedBytes / file.size) * 100) : 100,
              activeWorkers: activeCount(),
              parallelWorkers: concurrency
            });
          }
          persistMeta();
        }
        function settlePausedIfIdle() {
          if (control.paused && activeCount() === 0 && control.loopResolve) {
            var resolver = control.loopResolve;
            control.loopResolve = null;
            control.loopReject = null;
            markProgress('Paused');
            resolver();
          }
        }
        function reserveNextIndex() {
          var idx;
          if (control.retryQueue.length) return control.retryQueue.shift();
          while (control.nextIndex <= control.totalChunks) {
            idx = control.nextIndex++;
            if (!control.completed[idx] && !control.active[idx]) return idx;
          }
          return 0;
        }
        function finishCommit() {
          if (control.commitStarted) return;
          control.commitStarted = true;
          persistMeta();
          xhrJsonRequest(self.explorerUploadCommitRoute(), { uploadId: control.uploadId }).then(function () {
            if (transferId && self.finalizeTransfer) {
              self.finalizeTransfer(transferId, true, { processedBytes: file.size, totalBytes: file.size, progress: 100, stage: 'Completed', resumeMeta: {} });
            }
            return self.deleteTransferFileBlob(transferId);
          }).then(function () {
            return self.refreshAllExplorerWindows();
          }).then(function () {
            if (control.loopResolve) {
              var resolver = control.loopResolve;
              control.loopResolve = null;
              control.loopReject = null;
              resolver();
            }
          }).catch(function (err) {
            if (transferId && self.finalizeTransfer) self.finalizeTransfer(transferId, false, { error: (err && err.message) || 'fs_upload_failed', stage: 'Upload failed' });
            if (control.loopReject) {
              var rejecter = control.loopReject;
              control.loopResolve = null;
              control.loopReject = null;
              rejecter(err);
            }
          });
        }
        function maybePump() {
          if (control.cancelled) {
            if (control.loopResolve) {
              var resolver = control.loopResolve;
              control.loopResolve = null;
              control.loopReject = null;
              resolver();
            }
            return;
          }
          if (control.paused) {
            settlePausedIfIdle();
            return;
          }
          while (activeCount() < concurrency) {
            var idx = reserveNextIndex();
            if (!idx) break;
            launchChunk(idx);
          }
          if (!control.paused && !control.cancelled && !control.commitStarted && control.totalChunks === 0) { finishCommit(); return; }
          if (!control.paused && !control.cancelled && !control.commitStarted && Object.keys(control.completed).length >= control.totalChunks && activeCount() === 0) finishCommit();
        }
        function launchChunk(idx) {
          var span = chunkSpan(idx);
          var slot = { index: idx, start: span.start, end: span.end, bytes: span.bytes, xhr: null, workerTask: null };
          control.active[idx] = slot;
          markProgress('Uploading');
          function onSuccess() {
            delete control.active[idx];
            if (!control.completed[idx]) {
              control.completed[idx] = 1;
              control.completedBytes += span.bytes;
            }
            markProgress('Uploading');
            maybePump();
          }
          function onFail(err) {
            delete control.active[idx];
            if (String((err && err.message) || '') === 'transfer_cancelled' || (control.paused && !control.cancelled)) {
              if (!control.cancelled && !control.completed[idx]) control.retryQueue.push(idx);
              persistMeta();
              settlePausedIfIdle();
              if (!control.paused && !control.cancelled) maybePump();
              return;
            }
            if (transferId && self.finalizeTransfer) self.finalizeTransfer(transferId, false, { error: (err && err.message) || 'fs_upload_failed', stage: 'Upload failed' });
            if (control.loopReject) {
              var rejecter = control.loopReject;
              control.loopResolve = null;
              control.loopReject = null;
              rejecter(err);
            }
          }
          if (control.workerEnabled && typeof window.Worker === 'function') {
            slot.workerTask = self.uploadChunkWithWorker(file, self.explorerUploadChunkRoute(), control.uploadId, idx, span.start, span.end);
            slot.workerTask.promise.then(onSuccess).catch(onFail);
            return;
          }
          fileChunkToBase64(file, span.start, span.end).then(function (b64) {
            if (control.cancelled) { delete control.active[idx]; return; }
            if (control.paused) {
              delete control.active[idx];
              if (!control.completed[idx]) control.retryQueue.push(idx);
              persistMeta();
              settlePausedIfIdle();
              return;
            }
            return xhrJsonRequest(self.explorerUploadChunkRoute(), { uploadId: control.uploadId, index: idx, bytes: span.bytes, data: b64 }, function (xhr) { slot.xhr = xhr; });
          }).then(function (result) {
            if (typeof result !== 'undefined') onSuccess();
            else if (!control.paused && !control.cancelled) maybePump();
          }).catch(onFail);
        }
        function run() {
          return new Promise(function (resolve, reject) {
            control.loopResolve = resolve;
            control.loopReject = reject;
            markProgress(control.paused ? 'Paused' : 'Uploading');
            maybePump();
          });
        }
        function beginFresh() {
          control.paused = false;
          control.cancelled = false;
          control.active = {};
          control.completed = {};
          control.completedBytes = 0;
          control.retryQueue = [];
          control.nextIndex = 1;
          control.commitStarted = false;
          persistMeta();
          return xhrJsonRequest(self.explorerUploadBeginRoute(), { parent: state.folderId || ((self.boot.vfs || {}).rootId || 'root'), name: file.name, mime: mime, totalBytes: file.size, encoding: 'base64' }).then(function (body) {
            control.uploadId = body.uploadId;
            persistMeta();
            return run();
          });
        }
        function beginOrResume() {
          if (resumeExisting && control.uploadId) {
            return xhrJsonRequest(self.explorerUploadStatusRoute(), { uploadId: control.uploadId }).catch(function () {
              control.uploadId = '';
              return null;
            }).then(function () {
              if (control.uploadId) return run();
              return beginFresh();
            });
          }
          return beginFresh();
        }
        self.setExplorerUploadProgress(state, { active: true, name: file.name, totalBytes: file.size, sentBytes: control.completedBytes, progress: file.size > 0 ? Math.round((control.completedBytes / file.size) * 100) : 0, stage: resumeExisting ? 'Resuming' : 'Preparing', error: '', uploadId: control.uploadId || '' });
        if (transferId && self.setTransferController) {
          self.setTransferController(transferId, {
            onPause: function () {
              control.paused = true;
              Object.keys(control.active).forEach(function (key) {
                var slot = control.active[key];
                if (slot && slot.xhr) { try { slot.xhr.abort(); } catch (err) {} }
                if (slot && slot.workerTask && slot.workerTask.cancel) slot.workerTask.cancel();
              });
              persistMeta();
            },
            onResume: function () {
              control.paused = false;
              persistMeta();
              return run();
            },
            onRestart: function () {
              control.paused = false;
              control.cancelled = false;
              if (control.uploadId) return xhrJsonRequest(self.explorerUploadAbortRoute(), { uploadId: control.uploadId }).catch(function () { return null; }).then(beginFresh);
              return beginFresh();
            },
            onCancel: function () {
              control.cancelled = true;
              Object.keys(control.active).forEach(function (key) {
                var slot = control.active[key];
                if (slot && slot.xhr) { try { slot.xhr.abort(); } catch (err) {} }
                if (slot && slot.workerTask && slot.workerTask.cancel) slot.workerTask.cancel();
              });
              if (control.uploadId) return xhrJsonRequest(self.explorerUploadAbortRoute(), { uploadId: control.uploadId }).catch(function () { return null; }).then(function () { return self.deleteTransferFileBlob(transferId); });
              return self.deleteTransferFileBlob(transferId);
            },
            onRetry: function () { return beginFresh(); }
          });
        }
        persistMeta();
        return this.ensureFreshUploadAuth().then(function () { return beginOrResume(); });
      },
      uploadFilesToExplorer: function (windowId, filesLike) {
        var self = this;
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        var file = filesLike && filesLike[0];
        var mime;
        if (!state || !file) return Promise.resolve();
        mime = file.type || 'application/octet-stream';
        if ((filesLike || []).length > 1) {
          return Array.prototype.slice.call(filesLike).reduce(function (chain, nextFile) {
            return chain.then(function () { return self.uploadFilesToExplorer(windowId, [nextFile]); });
          }, Promise.resolve());
        }
        if (this.explorerUploadMode() === 'resumable-chunk-session' && (this.boot.routes || {}).fsUploadBegin) {
          var transferId2 = this.registerTransfer ? this.registerTransfer({ kind: 'upload', name: file.name, status: 'preparing', stage: 'Preparing', totalBytes: file.size, processedBytes: 0, sourceWindowId: windowId, resumeMeta: {} }) : '';
          return this.saveTransferFileBlob(transferId2, file).then(function () {
            return self.startResumableUploadFlow(windowId, file, transferId2, null, { mode: 'resumable-chunk-session', windowId: windowId, folderId: state.folderId, fileName: file.name, mime: mime, totalBytes: file.size }, false, false);
          }).catch(function (err) {
            if (transferId2 && self.finalizeTransfer) self.finalizeTransfer(transferId2, false, { error: (err && err.message) || 'fs_upload_failed', stage: 'Upload failed' });
            throw err;
          });
        }
        var transferId = self.registerTransfer ? self.registerTransfer({ kind: 'upload', name: file.name, status: 'preparing', stage: 'Preparing', totalBytes: file.size, processedBytes: 0, sourceWindowId: windowId }) : '';
        var transferControl = { cancelled: false, workers: [], uploadId: '', windowId: windowId, xhr: null };
        if (transferId && self.setTransferController) {
          self.setTransferController(transferId, {
            onRetry: function () { return self.uploadFilesToExplorer(windowId, [file]); },
            onRestart: function () { return self.uploadFilesToExplorer(windowId, [file]); },
            onCancel: function () {
              transferControl.cancelled = true;
              if (transferControl.xhr) {
                try { transferControl.xhr.abort(); } catch (err) {}
              }
              (transferControl.workers || []).forEach(function (worker) {
                if (worker && worker.close) worker.close();
              });
              return Promise.resolve();
            }
          });
        }
        self.setExplorerUploadProgress(state, {
          active: true,
          name: file.name,
          totalBytes: file.size,
          sentBytes: 0,
          progress: 0,
          stage: 'Preparing',
          error: '',
          uploadId: ''
        });
        function finalize() {
          transferControl.cancelled = false;
          transferControl.xhr = null;
          return self.refreshExplorerWindow(windowId).then(function () {
            if (self.refreshView) self.refreshView();
            self.setExplorerUploadProgress(state, {
              active: false,
              name: file.name,
              totalBytes: file.size,
              sentBytes: file.size,
              progress: 100,
              stage: 'Complete',
              error: '',
              uploadId: ''
            });
            if (transferId && self.finalizeTransfer) self.finalizeTransfer(transferId, true, { processedBytes: file.size, totalBytes: file.size, progress: 100, stage: 'Completed' });
            window.setTimeout(function () { self.resetExplorerUpload(state); }, 1200);
          });
        }
        function fail(err, fallback) {
          var detail = (err && (err.detail || err.reason || err.code)) || '';
          var message = detail || (err && err.message) || fallback;
          transferControl.xhr = null;
          if (message === 'transfer_cancelled') {
            self.setExplorerUploadProgress(state, { active: false, stage: 'Cancelled', error: '', uploadId: '' });
            if (transferId && self.updateTransfer) self.updateTransfer(transferId, { status: 'cancelled', stage: 'Cancelled', processedBytes: ((state.upload || {}).sentBytes || 0), totalBytes: file.size });
            return Promise.resolve();
          }
          self.setExplorerUploadProgress(state, { active: false, stage: 'Failed', error: message, uploadId: '' });
          if (transferId && self.finalizeTransfer) self.finalizeTransfer(transferId, false, { error: message, processedBytes: ((state.upload || {}).sentBytes || 0), totalBytes: file.size, stage: 'Upload failed' });
          return self.handleUploadAuthFailure(err).then(function () {
            if (detail !== 'jwt_expired' && self.showAlert) self.showAlert(self.t('alerts.shellEventError.title', 'Explorer'), message);
            throw (err || new Error(fallback));
          });
        }
        self.setExplorerUploadProgress(state, { stage: 'Uploading via HTTP' });
        if (transferId && self.updateTransfer) self.updateTransfer(transferId, { status: 'uploading', stage: 'Uploading via HTTP', processedBytes: 0, totalBytes: file.size, progress: 0 });
        if (!window.XMLHttpRequest || !window.FormData) {
          return fail(new Error('http_upload_unavailable'), 'http_upload_unavailable');
        }
        return self.ensureFreshUploadAuth().then(function () {
          return self.httpUploadFilesToExplorer(windowId, file, win, state, transferId, transferControl);
        }).then(finalize).catch(function (err) {
          return fail(err, 'fs_upload_failed');
        });
      },
      explorerPromptUpload: function (windowId) {
        var self = this;
        createUploadInput(function (event) {
          var file = event.target.files && event.target.files[0];
          function cleanup() {
            if (event.target && event.target.parentNode) event.target.parentNode.removeChild(event.target);
          }
          if (!file) { cleanup(); return; }
          self.uploadFilesToExplorer(windowId, [file]).finally(cleanup);
        });
      },
      explorerCreateFolder: function (windowId) {
        var self = this;
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        if (!state || !this.command) return Promise.resolve();
        return new Promise(function (resolve) {
          self.openNamingDialog({
            title: self.t('explorer.promptNewFolder', 'New folder name'),
            label: self.t('explorer.promptNewFolder', 'New folder name'),
            submitLabel: 'Create',
            value: self.t('explorer.defaultFolderName', 'New Folder'),
            onSubmit: function (value) {
              var name = String(value || '').trim();
              if (!name) { resolve(); return; }
              self.command('fs.mkdir', { parent: state.folderId, name: name }).then(function () {
                return self.refreshAllExplorerWindows();
              }).finally(resolve);
            }
          });
        });
      },
      explorerRenameSelected: function (windowId) {
        var self = this;
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        var item = state && state.selection;
        if (!item || !this.command) return Promise.resolve();
        return new Promise(function (resolve) {
          self.openNamingDialog({
            title: self.t('explorer.promptRename', 'Rename item'),
            label: self.t('explorer.promptRename', 'Rename item'),
            submitLabel: 'Rename',
            value: item.name || item.title || '',
            onSubmit: function (value) {
              var name = String(value || '').trim();
              if (!name || name === (item.name || item.title || '')) { resolve(); return; }
              self.command('fs.rename', { id: item.id || item.key || '', name: name }).then(function () {
                return self.refreshAllExplorerWindows();
              }).finally(resolve);
            }
          });
        });
      },
      explorerDeleteSelected: function (windowId) {
        var self = this;
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        var item = state && state.selection;
        if (!item || !this.command) return Promise.resolve();
        if (!window.confirm(this.t('explorer.confirmDelete', 'Delete the selected item?'))) return Promise.resolve();
        return this.command('fs.delete', { id: item.id || item.key || '' }).then(function () {
          state.selection = null;
          state.preview = { title: '', content: '', mime: 'text/plain', imageSrc: '', mediaSrc: '', mediaKind: '' };
          return self.refreshExplorerWindow(windowId).then(function () {
            if (self.refreshView) self.refreshView();
          });
        }).catch(function (err) {
          if (self.showAlert) self.showAlert(self.t('alerts.shellEventError.title', 'Explorer'), (err && err.message) || 'fs_delete_failed');
        });
      },
      explorerMoveSelected: function (windowId) {
        var self = this;
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        var item = state && state.selection;
        var destination = '';
        if (!item || !this.command) return Promise.resolve();
        destination = window.prompt(this.t('explorer.promptMove', 'Move selected item to folder path or id'), ((this.boot.vfs || {}).homeId || (this.boot.vfs || {}).rootId || 'root'));
        if (destination === null) return Promise.resolve();
        destination = String(destination || '').trim();
        if (!destination) return Promise.resolve();
        return this.command('fs.meta', { id: destination, path: destination }).then(function (msg) {
          var payload = payloadRoot(msg);
          var targetId = payload.id || destination;
          return self.command('fs.move', { id: item.id || item.key || '', parent: targetId });
        }).then(function () {
          state.selection = null;
          state.preview = { title: '', content: '', mime: 'text/plain', imageSrc: '', mediaSrc: '', mediaKind: '' };
          return self.refreshExplorerWindow(windowId).then(function () {
            if (self.refreshView) self.refreshView();
          });
        }).catch(function (err) {
          if (self.showAlert) self.showAlert(self.t('alerts.shellEventError.title', 'Explorer'), (err && err.message) || 'fs_move_failed');
        });
      },
      downloadFileEntry: function (item, fallbackData) {
        var anchor;
        var href = fallbackData || '';
        var name = (item && (item.name || item.title)) || 'download';
        var transferId = this.registerTransfer ? this.registerTransfer({ kind: 'download', name: name, status: 'preparing', stage: 'Preparing', totalBytes: +((item || {}).size || 0), processedBytes: 0 }) : '';
        var self = this;
        var httpHref = this.buildExplorerFileUrl(item, 'download');
        function triggerSave(raw) {
          var url = raw;
          if (!url || !self.isBrowserManagedUrl(url)) url = makeDownloadHref(raw, (item && item.mime) || 'application/octet-stream');
          if (!url) return;
          anchor = document.createElement('a');
          anchor.href = url;
          anchor.download = name;
          document.body.appendChild(anchor);
          anchor.click();
          document.body.removeChild(anchor);
          if (url.indexOf('blob:') === 0) window.setTimeout(function () { try { window.URL.revokeObjectURL(url); } catch (err) {} }, 2000);
        }
        function handoffToBrowser(url) {
          anchor = document.createElement('a');
          anchor.href = url;
          anchor.download = name;
          document.body.appendChild(anchor);
          anchor.click();
          document.body.removeChild(anchor);
          if (transferId && self.finalizeTransfer) self.finalizeTransfer(transferId, true, { progress: 100, stage: 'Sent to browser download manager' });
          return Promise.resolve();
        }
        if (!item) return Promise.resolve();
        if (href && self.isBrowserManagedUrl(href)) {
          triggerSave(href);
          if (transferId && this.finalizeTransfer) this.finalizeTransfer(transferId, true, { progress: 100, stage: 'Saved to browser download manager' });
          return Promise.resolve();
        }
        if (httpHref) {
          var chunkBytes = +((((this.boot || {}).vfs || {}).downloadHttpChunkBytes) || 128000);
          var totalBytes = +((item || {}).size || 0);
          var offset = 0;
          var buffers = [];
          var ctrl = { paused: false, cancelled: false, xhr: null };
          if (transferId && this.setTransferController) {
            this.setTransferController(transferId, {
              onPause: function () { ctrl.paused = true; if (ctrl.xhr) try { ctrl.xhr.abort(); } catch (err) {} },
              onResume: function () { ctrl.paused = false; return pump(); },
              onRestart: function () { ctrl.paused = false; ctrl.cancelled = false; offset = 0; buffers = []; return pump(); },
              onCancel: function () { ctrl.cancelled = true; if (ctrl.xhr) try { ctrl.xhr.abort(); } catch (err) {} return Promise.resolve(); }
            });
          }
          function saveBuffers() {
            var blob = new window.Blob(buffers, { type: (item && item.mime) || 'application/octet-stream' });
            var url = window.URL.createObjectURL(blob);
            anchor = document.createElement('a');
            anchor.href = url;
            anchor.download = name;
            document.body.appendChild(anchor);
            anchor.click();
            document.body.removeChild(anchor);
            window.setTimeout(function () { try { window.URL.revokeObjectURL(url); } catch (err) {} }, 2000);
            if (transferId && self.finalizeTransfer) self.finalizeTransfer(transferId, true, { processedBytes: totalBytes, totalBytes: totalBytes, progress: 100, stage: 'Saved to browser download manager' });
          }
          function pump() {
            if (ctrl.cancelled) return Promise.resolve();
            if (ctrl.paused) { if (transferId && self.updateTransfer) self.updateTransfer(transferId, { status: 'paused', stage: 'Paused' }); return Promise.resolve(); }
            if (totalBytes > 0 && offset >= totalBytes) { saveBuffers(); return Promise.resolve(); }
            var end = totalBytes > 0 ? Math.min(offset + chunkBytes - 1, totalBytes - 1) : (offset + chunkBytes - 1);
            return xhrArrayBufferRequest(httpHref, { Range: 'bytes=' + offset + '-' + end }, function (xhr) { ctrl.xhr = xhr; }).then(function (resp) {
              ctrl.xhr = null;
              buffers.push(resp.buffer);
              offset = end + 1;
              if (transferId && self.updateTransfer) self.updateTransfer(transferId, { status: 'downloading', stage: 'Downloading', processedBytes: Math.min(offset, totalBytes || offset), totalBytes: totalBytes || offset, progress: totalBytes > 0 ? Math.round((Math.min(offset, totalBytes) / totalBytes) * 100) : 0 });
              return pump();
            }).catch(function (err) {
              ctrl.xhr = null;
              if (String((err && err.message) || '') === 'transfer_cancelled' && ctrl.paused) return Promise.resolve();
              if (transferId && self.finalizeTransfer) self.finalizeTransfer(transferId, false, { error: (err && err.message) || 'download_failed', stage: 'Download failed' });
              throw err;
            });
          }
          if (transferId && this.updateTransfer) this.updateTransfer(transferId, { status: 'downloading', stage: 'Downloading', progress: 0, processedBytes: 0, totalBytes: totalBytes });
          return pump();
        }
        if (!this.command) return Promise.resolve();
        if (transferId && this.updateTransfer) this.updateTransfer(transferId, { status: 'downloading', stage: 'Downloading' });
        return this.command('fs.download.begin', { id: item.id || item.key || item.fileId }).then(function (msg) {
          var begin = payloadRoot(msg);
          var totalBytes = +begin.transferBytes || +begin.size || 0;
          var logicalBytes = +begin.size || totalBytes;
          var chunkSize = +begin.chunkSize || 32768;
          var offset = 0;
          var pieces = [];
          function nextChunk() {
            if (totalBytes > 0 && offset >= totalBytes) return Promise.resolve(pieces.join(''));
            return self.command('fs.download.chunk', { downloadId: begin.downloadId, offset: offset, size: chunkSize }).then(function (chunkMsg) {
              var chunk = payloadRoot(chunkMsg);
              var data = chunk.data || '';
              var nextOffset = +chunk.nextOffset || (offset + data.length);
              pieces.push(data);
              if (nextOffset <= offset && !(+chunk.eof === 1 || chunk.eof === true)) throw new Error('download_offset_stalled');
              offset = nextOffset;
              if (transferId && self.updateTransfer) self.updateTransfer(transferId, { processedBytes: offset, totalBytes: +chunk.totalBytes || totalBytes, progress: totalBytes > 0 ? Math.round((offset / totalBytes) * 100) : 0, stage: (+chunk.eof === 1 || chunk.eof === true) ? 'Finalizing' : 'Downloading' });
              if (+chunk.eof === 1 || chunk.eof === true) return pieces.join('');
              return nextChunk();
            });
          }
          return nextChunk().then(function (raw) {
            if (+begin.verifyHash === 1 || begin.verifyHash === true) {
              if (transferId && self.updateTransfer) self.updateTransfer(transferId, { status: 'verifying', stage: 'Verifying download', processedBytes: totalBytes || raw.length, totalBytes: totalBytes || raw.length, progress: 100 });
              return sha256Hex(raw).then(function (actualHash) {
                var expectedHash = String(begin.sha256 || '').toLowerCase();
                if (expectedHash && actualHash && expectedHash !== actualHash) throw new Error('download_hash_mismatch');
                return raw;
              });
            }
            return raw;
          }).then(function (raw) {
            triggerSave(raw);
            if (transferId && self.finalizeTransfer) self.finalizeTransfer(transferId, true, { processedBytes: totalBytes || raw.length, totalBytes: totalBytes || raw.length, logicalBytes: logicalBytes, progress: 100, stage: 'Saved to browser download manager' });
          });
        }).catch(function (err) {
          var code = (err && err.message) || 'download_failed';
          if (transferId && self.finalizeTransfer) self.finalizeTransfer(transferId, false, { error: code, stage: 'Download failed' });
          throw err;
        });
      },
      explorerDownloadSelected: function (windowId) {
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        var item = state && state.selection;
        if (!item) return Promise.resolve();
        return this.downloadFileEntry(item, '');
      },
      downloadViewerFile: function (win) {
        var fallback = '';
        if (!win) return Promise.resolve();
        if (this.isBrowserManagedUrl((win.fileView || {}).content || '')) fallback = (win.fileView || {}).content || '';
        return this.downloadFileEntry({ id: (win.meta || {}).fileId, name: (win.meta || {}).fileName || win.title, mime: (win.meta || {}).mime || ((win.fileView || {}).mime), size: (win.meta || {}).size || 0 }, fallback);
      },
      openTextViewerWindow: function (item) {
        var id = nextWindowId(this, 'win-text');
        var httpUrl = this.buildExplorerFileUrl(item, 'preview');
        var limit = this.explorerInlineTextLimit();
        var win = {
          id: id,
          appKey: 'text-viewer',
          title: item.name || item.title || 'Text file',
          state: 'normal',
          left: 130,
          top: 90,
          width: 660,
          height: 480,
          z: this.zCounter + 1,
          meta: { fileId: item.id || item.key || '', mime: item.mime || 'text/plain', fileName: item.name || item.title || 'Text file', size: +((item || {}).size || 0) },
          fileView: { loading: true, content: '', mime: item.mime || 'text/plain', sourceUrl: '' }
        };
        this.windows.push(win);
        this.focusWindow(id);
        if (httpUrl && +((item || {}).size || 0) > limit) {
          win.fileView.loading = false;
          win.fileView.sourceUrl = httpUrl;
          return;
        }
        if (!this.command) return;
        this.command('fs.read', { id: item.id || item.key || item.fileId }).then(function (msg) {
          var payload = payloadRoot(msg);
          win.fileView.loading = false;
          win.fileView.content = textFromPayload(payload);
          win.fileView.mime = payload.mime || win.fileView.mime;
        }).catch(function (err) {
          win.fileView.loading = false;
          win.fileView.content = (err && err.message) || 'Unable to open file.';
        });
      },
      openImageViewerWindow: function (item) {
        var id = nextWindowId(this, 'win-image');
        var httpUrl = this.buildExplorerFileUrl(item, 'preview');
        var win = {
          id: id,
          appKey: 'image-viewer',
          title: item.name || item.title || 'Image file',
          state: 'normal',
          left: 150,
          top: 110,
          width: 700,
          height: 520,
          z: this.zCounter + 1,
          meta: { fileId: item.id || item.key || '', mime: item.mime || 'image/*', fileName: item.name || item.title || 'Image file', size: +((item || {}).size || 0) },
          fileView: { loading: true, content: '', mime: item.mime || 'image/*' }
        };
        this.windows.push(win);
        this.focusWindow(id);
        if (httpUrl) {
          win.fileView.loading = false;
          win.fileView.content = httpUrl;
          return;
        }
        if (!this.command) return;
        this.command('fs.read', { id: item.id || item.key || item.fileId }).then(function (msg) {
          var payload = payloadRoot(msg);
          win.fileView.loading = false;
          win.fileView.content = textFromPayload(payload);
          win.fileView.mime = payload.mime || win.fileView.mime;
        }).catch(function (err) {
          win.fileView.loading = false;
          win.fileView.content = '';
          win.fileView.error = (err && err.message) || 'Unable to open image.';
        });
      },
      openMediaViewerWindow: function (item) {
        var mediaKind = detectVideoLike(item) ? 'video' : 'audio';
        var id = nextWindowId(this, 'win-media');
        var httpUrl = this.buildExplorerFileUrl(item, 'preview');
        var win = {
          id: id,
          appKey: 'media-viewer',
          title: item.name || item.title || (mediaKind === 'video' ? 'Video file' : 'Audio file'),
          state: 'normal',
          left: 170,
          top: 120,
          width: mediaKind === 'video' ? 760 : 560,
          height: mediaKind === 'video' ? 560 : 260,
          z: this.zCounter + 1,
          meta: { fileId: item.id || item.key || '', mime: item.mime || (mediaKind + '/*'), fileName: item.name || item.title || 'Media file', mediaKind: mediaKind, size: +((item || {}).size || 0) },
          fileView: { loading: true, content: '', mime: item.mime || (mediaKind + '/*'), mediaKind: mediaKind }
        };
        this.windows.push(win);
        this.focusWindow(id);
        if (httpUrl) {
          win.fileView.loading = false;
          win.fileView.content = httpUrl;
          return;
        }
        if (!this.command) return;
        this.command('fs.read', { id: item.id || item.key || item.fileId }).then(function (msg) {
          var payload = payloadRoot(msg);
          win.fileView.loading = false;
          win.fileView.content = textFromPayload(payload);
          win.fileView.mime = payload.mime || win.fileView.mime;
        }).catch(function (err) {
          win.fileView.loading = false;
          win.fileView.content = '';
          win.fileView.error = (err && err.message) || 'Unable to open media.';
        });
      },
      openPdfViewerWindow: function (item) {
        var id = nextWindowId(this, 'win-pdf');
        var httpUrl = this.buildExplorerFileUrl(item, 'preview');
        var win = {
          id: id,
          appKey: 'pdf-viewer',
          title: item.name || item.title || 'PDF file',
          state: 'normal',
          left: 160,
          top: 100,
          width: 820,
          height: 600,
          z: this.zCounter + 1,
          meta: { fileId: item.id || item.key || '', mime: item.mime || 'application/pdf', fileName: item.name || item.title || 'PDF file', size: +((item || {}).size || 0) },
          fileView: { loading: true, content: '', mime: item.mime || 'application/pdf' }
        };
        this.windows.push(win);
        this.focusWindow(id);
        if (httpUrl) {
          win.fileView.loading = false;
          win.fileView.content = httpUrl;
          return;
        }
        if (!this.command) return;
        this.command('fs.read', { id: item.id || item.key || item.fileId }).then(function (msg) {
          var payload = payloadRoot(msg);
          var raw = textFromPayload(payload);
          win.fileView.loading = false;
          win.fileView.mime = payload.mime || win.fileView.mime;
          win.fileView.content = makeDownloadHref(raw, win.fileView.mime);
        }).catch(function (err) {
          win.fileView.loading = false;
          win.fileView.error = (err && err.message) || 'Unable to open PDF.';
        });
      },
      openStructuredViewerWindow: function (item) {
        var id = nextWindowId(this, 'win-structured');
        var httpUrl = this.buildExplorerFileUrl(item, 'preview');
        var limit = this.explorerInlineTextLimit();
        var win = {
          id: id,
          appKey: 'structured-viewer',
          title: item.name || item.title || 'Structured file',
          state: 'normal',
          left: 150,
          top: 95,
          width: 720,
          height: 540,
          z: this.zCounter + 1,
          meta: { fileId: item.id || item.key || '', mime: item.mime || 'text/plain', fileName: item.name || item.title || 'Structured file', size: +((item || {}).size || 0) },
          fileView: { loading: true, content: '', mime: item.mime || 'text/plain', sourceUrl: '' }
        };
        this.windows.push(win);
        this.focusWindow(id);
        if (httpUrl && +((item || {}).size || 0) > limit) {
          win.fileView.loading = false;
          win.fileView.sourceUrl = httpUrl;
          return;
        }
        if (!this.command) return;
        this.command('fs.read', { id: item.id || item.key || item.fileId }).then(function (msg) {
          var payload = payloadRoot(msg);
          var raw = textFromPayload(payload);
          win.fileView.loading = false;
          win.fileView.mime = payload.mime || win.fileView.mime;
          win.fileView.content = normalizeStructuredContent(raw, win.fileView.mime);
        }).catch(function (err) {
          win.fileView.loading = false;
          win.fileView.content = (err && err.message) || 'Unable to open file.';
        });
      }
    }
  };
})();
