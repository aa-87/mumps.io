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

  function navigatorOnline() {
    if (typeof navigator === 'undefined' || typeof navigator.onLine === 'undefined') return true;
    return !!navigator.onLine;
  }

  function isTransientUploadStatus(status) {
    status = +status;
    return status === 408 || status === 409 || status === 425 || status === 429 || (status >= 500 && status < 600);
  }

  function uploadRetryDelay(attempt) {
    attempt = Math.max(1, +attempt || 1);
    return Math.min(2500, 250 * attempt);
  }

  function makeDownloadHref(data, mime) {
    var blob;
    if (!data) return '';
    if (typeof data === 'string' && data.indexOf('data:') === 0) return data;
    blob = new window.Blob([data], { type: mime || 'application/octet-stream' });
    return window.URL.createObjectURL(blob);
  }

  function wsTransportMode(vm) {
    return String(((((vm || {}).boot || {}).transport || {}).mode) || ((((vm || {}).boot || {}).vfs || {}).transport) || 'websocket').toLowerCase();
  }

  function buildFsBlobUrl(vm, item, options) {
    if (wsTransportMode(vm) !== 'http' && !(((((vm || {}).boot || {}).transport || {}).httpFallback) === true && options && options.forceHttp)) return '';
    var route = ((((vm || {}).boot || {}).routes || {}).fsBlob) || '/api/mioos/fs/blob';
    var id = ((item || {}).id || (item || {}).key || (item || {}).fileId || '');
    var path = ((item || {}).path || '');
    var params = [];
    options = options || {};
    if (id) params.push('id=' + encodeURIComponent(id));
    else if (path) params.push('path=' + encodeURIComponent(path));
    else return '';
    if (options.download) params.push('download=1');
    if (options.inline) params.push('inline=1');
    if (options.stream) params.push('stream=' + encodeURIComponent(options.stream));
    return route + (route.indexOf('?') >= 0 ? '&' : '?') + params.join('&');
  }

  function stringToBytes(raw) {
    var value = String(raw || '');
    var bytes = new Uint8Array(value.length);
    var i;
    for (i = 0; i < value.length; i += 1) bytes[i] = value.charCodeAt(i) & 255;
    return bytes;
  }

  function base64ToBytes(raw) {
    var value = String(raw || '');
    var binary = value ? window.atob(value) : '';
    return stringToBytes(binary);
  }

  function concatBytes(chunks) {
    var total = 0;
    var index = 0;
    var out;
    chunks = chunks || [];
    for (index = 0; index < chunks.length; index += 1) total += (chunks[index] && chunks[index].length) || 0;
    out = new Uint8Array(total);
    total = 0;
    for (index = 0; index < chunks.length; index += 1) {
      if (!chunks[index] || !chunks[index].length) continue;
      out.set(chunks[index], total);
      total += chunks[index].length;
    }
    return out;
  }

  function sha256HexBytes(bytes) {
    if (!window.crypto || !window.crypto.subtle) return Promise.resolve('');
    return window.crypto.subtle.digest('SHA-256', bytes instanceof Uint8Array ? bytes : stringToBytes(bytes)).then(function (hash) {
      return bytesToHex(new Uint8Array(hash));
    }).catch(function () {
      return '';
    });
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

  function appendTruncationNotice(content, payload) {
    var text = String(content || '');
    if (!payload || !(+payload.truncated === 1 || payload.truncated === true)) return text;
    return text + '\n\n[Preview truncated at ' + (+payload.nextOffset || text.length) + ' bytes. Download the file to view the full contents.]';
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

  function httpJsonPost(url, payload) {
    return new Promise(function (resolve, reject) {
      var xhr = new XMLHttpRequest();
      var body;
      xhr.open('POST', url, true);
      xhr.setRequestHeader('Content-Type', 'application/json');
      xhr.onreadystatechange = function () {
        if (xhr.readyState !== 4) return;
        if (xhr.status >= 200 && xhr.status < 300) {
          try { body = JSON.parse(xhr.responseText || '{}'); } catch (err) { body = {}; }
          resolve(body);
          return;
        }
        try { body = JSON.parse(xhr.responseText || '{}'); } catch (err2) { body = {}; }
        var error = new Error(body.detail || body.reason || body.error || ('http_' + xhr.status)); error.status = xhr.status; error.body = body; reject(error);
      };
      xhr.onerror = function () { reject(new Error('network_error')); };
      xhr.send(JSON.stringify(payload || {}));
    });
  }

  function pickUploadEntries(vm) {
    if (window.showOpenFilePicker) {
      return window.showOpenFilePicker({ multiple: false }).then(function (handles) {
        handles = Array.isArray(handles) ? handles : [];
        return Promise.all(handles.map(function (handle) {
          return Promise.resolve(handle.getFile()).then(function (file) {
            return { file: file, handle: handle };
          });
        }));
      });
    }
    return new Promise(function (resolve) {
      createUploadInput(function (event) {
        var file = event.target.files && event.target.files[0];
        if (event.target && event.target.parentNode) event.target.parentNode.removeChild(event.target);
        resolve(file ? [{ file: file, handle: null }] : []);
      });
    });
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
      maxSocketsPerSession: Math.max(1, +(conf.maxSocketsPerSession || 6)),
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

      explorerShellInput: function (message, value) { return this.inputDialog ? this.inputDialog('Explorer', message, value) : Promise.resolve(window.prompt(message || 'Input', value || '')); },
      explorerShellConfirm: function (message) { return this.confirmDialog ? this.confirmDialog('Explorer', message) : Promise.resolve(window.confirm(message || 'Continue?')); },

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
        var frameBudget = 65536;
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
      explorerDefaultColumns: function () {
        return [
          { key: 'name', label: 'Name', width: 280, minWidth: 160 },
          { key: 'type', label: 'Type', width: 140, minWidth: 96 },
          { key: 'size', label: 'Size', width: 96, minWidth: 76 },
          { key: 'modified', label: 'Modified', width: 158, minWidth: 118 }
        ];
      },
      explorerColumns: function (state) {
        return this.explorerDetailsColumns(state);
      },
      explorerDetailsColumns: function (state) {
        var existing = Array.isArray((state || {}).detailsColumns) ? state.detailsColumns : [];
        var map = {};
        var defaults = this.explorerDefaultColumns();
        existing.forEach(function (column) {
          if (column && column.key) map[column.key] = column;
        });
        defaults.forEach(function (column, index) {
          var current = map[column.key] || {};
          defaults[index] = Object.assign({}, column, {
            label: current.label || column.label,
            width: Math.max(+(current.minWidth || column.minWidth || 72), +(current.width || column.width || 120)),
            minWidth: +(current.minWidth || column.minWidth || 72)
          });
        });
        if (state) state.detailsColumns = defaults;
        return defaults;
      },
      explorerColumnStyle: function (column) {
        var width = Math.max(+((column || {}).minWidth || 72), +((column || {}).width || 120));
        return { width: width + 'px' };
      },
      explorerColumnHeaderStyle: function (column) {
        var width = Math.max(+((column || {}).minWidth || 72), +((column || {}).width || 120));
        return { width: width + 'px', minWidth: width + 'px', maxWidth: width + 'px' };
      },
      explorerColumnValue: function (item, key) {
        if (key === 'type') return this.explorerItemTypeLabel(item);
        if (key === 'size') return this.explorerFormatSize(item);
        if (key === 'modified') return (item && (item.modifiedLabel || item.modifiedAt || item.mtime || item.updated)) || '';
        return item && (item.name || item.title || '');
      },
      explorerColumnResizeClass: function (state, column) {
        return { 'is-resizing': !!((state || {}).resizingColumn && (column || {}).key === (state || {}).resizingColumn) };
      },
      explorerBeginColumnResize: function (windowId, column, event) {
        var self = this;
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        var columns = this.explorerDetailsColumns(state);
        var target = columns.find(function (entry) { return entry.key === ((column || {}).key || ''); });
        var startX = event && event.clientX;
        var startWidth = +(target && target.width);
        var minWidth = +(target && target.minWidth) || 72;
        if (!state || !target || !event) return;
        state.resizingColumn = target.key;
        function onMove(moveEvent) {
          var nextWidth = Math.max(minWidth, startWidth + ((moveEvent.clientX || startX) - startX));
          target.width = nextWidth;
          state.detailsColumns = columns.slice();
        }
        function onUp() {
          state.resizingColumn = null;
          document.removeEventListener('mousemove', onMove, true);
          document.removeEventListener('mouseup', onUp, true);
        }
        document.addEventListener('mousemove', onMove, true);
        document.addEventListener('mouseup', onUp, true);
        if (event.preventDefault) event.preventDefault();
      },
      ensureExplorerWindowState: function (win) {
        if (!win) return null;
        if (!win.explorerState) {
          win.explorerState = {
            initialized: false,
            loading: false,
            folderId: (win.meta || {}).folderId || (win.appKey === 'home' ? ((this.boot.vfs || {}).desktopId || (this.boot.vfs || {}).homeId) : ((this.boot.vfs || {}).homeId || (this.boot.vfs || {}).rootId)) || 'root',
            folder: { id: '', name: '', path: '' },
            items: [],
            selection: null,
            error: '',
            preview: { title: '', content: '', mime: 'text/plain', imageSrc: '', mediaSrc: '', mediaKind: '' },
            upload: { active: false, name: '', totalBytes: 0, sentBytes: 0, progress: 0, stage: '', error: '', uploadId: '' },
            viewMode: 'details',
            sortKey: 'name',
            sortDir: 'asc',
            detailsColumns: this.explorerDefaultColumns ? this.explorerDefaultColumns() : [],
            resizingColumn: null,
            searchTerm: '',
            history: [],
            future: [],
            contextMenu: { open: false, left: 0, top: 0, targetKey: '', targetType: 'blank' },
            clipboard: null
          };
        }
        return win.explorerState;
      },
      bootstrapExplorerWindow: function (windowId, force) {
        var win = this.windows.find(function (item) { return item.id === windowId; });
        var state;
        if (!win || (win.appKey !== 'home' && win.appKey !== 'my-computer' && win.appKey !== 'documents' && win.appKey !== 'explorer')) return;
        state = this.ensureExplorerWindowState(win);
        if (state.initialized && !force) return;
        state.initialized = true;
        if (win.appKey === 'home' && (this.boot.vfs || {}).desktopId) {
          state.folderId = (win.meta && win.meta.folderId) || this.boot.vfs.desktopId;
        } else if (win.appKey === 'documents' && (this.boot.vfs || {}).homeId) {
          state.folderId = (win.meta && win.meta.folderId) || this.boot.vfs.homeId;
        }
        this.loadExplorerFolder(win.id, state.folderId, { selectFirst: true });
      },
      loadExplorerFolder: function (windowId, folderId, options) {
        var self = this;
        var win = this.windows.find(function (item) { return item.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        if (!win || !state || !folderId || !this.command) return Promise.resolve();
        this.explorerDetailsColumns(state);
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
          if ((options || {}).pushHistory && state.folderId && state.folderId !== (folder.id || folderId)) {
            state.history = Array.isArray(state.history) ? state.history : [];
            state.history.push(state.folderId);
            state.future = [];
          }
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
        } else if (state.selection && (detectAudioLike(state.selection) || detectVideoLike(state.selection))) {
          this.previewMediaFile(windowId, state.selection);
        } else {
          state.preview = { title: '', content: '', mime: 'text/plain', imageSrc: '', mediaSrc: '', mediaKind: '' };
        }
      },
      previewTextFile: function (windowId, item) {
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        var previewBytes = +((((this.boot || {}).vfs || {}).readPreviewBytes) || 16384);
        var self = this;
        if (!win || !state || !item || !this.command) return Promise.resolve();
        state.preview = { title: item.name || item.title || '', content: '', mime: item.mime || 'text/plain', imageSrc: '', mediaSrc: '', mediaKind: '' };
        return this.command('fs.read.range', { id: item.id || item.key || item.fileId, offset: 0, size: previewBytes }).then(function (msg) {
          var payload = payloadRoot(msg);
          state.preview = {
            title: item.name || item.title || '',
            content: appendTruncationNotice(textFromPayload(payload), payload),
            mime: item.mime || payload.mime || 'text/plain',
            imageSrc: '',
            mediaSrc: '',
            mediaKind: ''
          };
          return msg;
        }).catch(function () {
          return self.command('fs.read', { id: item.id || item.key || item.fileId }).then(function (msg) {
            var payload = payloadRoot(msg);
            state.preview = {
              title: item.name || item.title || '',
              content: textFromPayload(payload),
              mime: item.mime || payload.mime || 'text/plain',
              imageSrc: '',
              mediaSrc: '',
              mediaKind: ''
            };
            return msg;
          });
        }).catch(function (err) {
          state.preview = {
            title: item.name || item.title || '',
            content: (err && err.message) || 'Unable to load preview.',
            mime: item.mime || 'text/plain',
            imageSrc: ''
          };
        });
      },
      previewImageFile: function (windowId, item) {
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        var self = this;
        if (!win || !state || !item || !this.command) return Promise.resolve();
        return this.command('fs.read', { id: item.id || item.key || item.fileId }).then(function (msg) {
          var payload = payloadRoot(msg);
          state.preview = { title: item.name || item.title || '', content: '', mime: item.mime || payload.mime || 'image/*', imageSrc: (self.fsReadPayloadObjectUrl ? self.fsReadPayloadObjectUrl(payload.content || '', payload.mime || item.mime || 'image/*', payload.encoding || '') : (payload.content || '')), mediaSrc: '', mediaKind: '' };
          return state.preview.imageSrc;
        }).catch(function () {
          var url = buildFsBlobUrl(self, item, { inline: true, forceHttp: true });
          if (url) state.preview = { title: item.name || item.title || '', content: '', mime: item.mime || 'image/*', imageSrc: url, mediaSrc: '', mediaKind: '' };
          return url;
        });
      },
      previewMediaFile: function (windowId, item) {
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        var mediaKind = detectVideoLike(item) ? 'video' : 'audio';
        var self = this;
        if (!win || !state || !item || !this.command) return Promise.resolve();
        return this.command('fs.read', { id: item.id || item.key || item.fileId }).then(function (msg) {
          var payload = payloadRoot(msg);
          state.preview = { title: item.name || item.title || '', content: '', mime: item.mime || payload.mime || (mediaKind + '/*'), imageSrc: '', mediaSrc: (self.fsReadPayloadObjectUrl ? self.fsReadPayloadObjectUrl(payload.content || '', payload.mime || item.mime || (mediaKind + '/*'), payload.encoding || '') : (payload.content || '')), mediaKind: mediaKind };
          return state.preview.mediaSrc;
        }).catch(function () {
          var url = buildFsBlobUrl(self, item, { inline: true, stream: 'media', forceHttp: true });
          if (url) state.preview = { title: item.name || item.title || '', content: '', mime: item.mime || (mediaKind + '/*'), imageSrc: '', mediaSrc: url, mediaKind: mediaKind };
          return url;
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
          this.loadExplorerFolder(windowId, item.id || item.key || item.folderId, { selectFirst: true, pushHistory: true });
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
        this.loadExplorerFolder(windowId, parentId, { selectFirst: true, pushHistory: true });
      },
      refreshExplorerWindow: function (windowId) {
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        if (!state) return Promise.resolve();
        return this.loadExplorerFolder(windowId, state.folderId, { selectFirst: false });
      },
      explorerQuickPlaces: function () {
        var vfs = ((this.boot || {}).vfs || {});
        var places = [];
        if (vfs.desktopId) places.push({ id: vfs.desktopId, label: 'Desktop', icon: '🖥️' });
        if (vfs.homeId) places.push({ id: vfs.homeId, label: 'Home', icon: '🏠' });
        if (vfs.rootId) places.push({ id: vfs.rootId, label: 'Computer', icon: '💽' });
        return places;
      },
      explorerVisibleItems: function (state) {
        var items = ((state || {}).items || []).slice();
        var needle = String(((state || {}).searchTerm) || '').trim().toLowerCase();
        var key = ((state || {}).sortKey) || 'name';
        var dir = ((state || {}).sortDir) === 'desc' ? -1 : 1;
        if (needle) {
          items = items.filter(function (item) {
            var hay = [item.name, item.title, item.mime, item.kind, item.type].join(' ').toLowerCase();
            return hay.indexOf(needle) >= 0;
          });
        }
        items.sort(function (a, b) {
          var akind = String(a.kind || a.type || '').toLowerCase();
          var bkind = String(b.kind || b.type || '').toLowerCase();
          if (akind !== bkind) {
            if (akind === 'folder') return -1;
            if (bkind === 'folder') return 1;
          }
          var av;
          var bv;
          if (key === 'size') {
            av = +(a.sizeBytes || a.size || 0);
            bv = +(b.sizeBytes || b.size || 0);
            return (av - bv) * dir;
          }
          if (key === 'modified') {
            av = String(a.modifiedAt || a.mtime || a.updated || '');
            bv = String(b.modifiedAt || b.mtime || b.updated || '');
            return (av < bv ? -1 : (av > bv ? 1 : 0)) * dir;
          }
          if (key === 'type') {
            av = String(a.mime || a.kind || a.type || '').toLowerCase();
            bv = String(b.mime || b.kind || b.type || '').toLowerCase();
            return (av < bv ? -1 : (av > bv ? 1 : 0)) * dir;
          }
          av = String(a.name || a.title || '').toLowerCase();
          bv = String(b.name || b.title || '').toLowerCase();
          return (av < bv ? -1 : (av > bv ? 1 : 0)) * dir;
        });
        return items;
      },
      explorerSortBy: function (windowId, key) {
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        if (!state) return;
        if (state.sortKey === key) state.sortDir = state.sortDir === 'asc' ? 'desc' : 'asc';
        else { state.sortKey = key || 'name'; state.sortDir = 'asc'; }
      },
      explorerSetViewMode: function (windowId, mode) {
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        if (!state) return;
        state.viewMode = mode || 'details';
      },
      explorerNavigateToPlace: function (windowId, folderId) {
        if (!folderId) return Promise.resolve();
        return this.loadExplorerFolder(windowId, folderId, { selectFirst: false, pushHistory: true });
      },
      explorerGoBack: function (windowId) {
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        var target;
        if (!state || !Array.isArray(state.history) || !state.history.length) return Promise.resolve();
        target = state.history.pop();
        state.future = Array.isArray(state.future) ? state.future : [];
        if (state.folderId) state.future.push(state.folderId);
        return this.loadExplorerFolder(windowId, target, { selectFirst: false, noHistory: true });
      },
      explorerGoForward: function (windowId) {
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        var target;
        if (!state || !Array.isArray(state.future) || !state.future.length) return Promise.resolve();
        target = state.future.pop();
        state.history = Array.isArray(state.history) ? state.history : [];
        if (state.folderId) state.history.push(state.folderId);
        return this.loadExplorerFolder(windowId, target, { selectFirst: false, noHistory: true });
      },
      explorerFormatSize: function (item) {
        var bytes = +(item && (item.sizeBytes || item.size || 0));
        if (((item || {}).kind || (item || {}).type) === 'folder') return '';
        if (!bytes) return (item && item.sizeLabel) || '';
        if (bytes < 1024) return bytes + ' B';
        if (bytes < 1048576) return (bytes / 1024).toFixed(1) + ' KB';
        if (bytes < 1073741824) return (bytes / 1048576).toFixed(1) + ' MB';
        return (bytes / 1073741824).toFixed(1) + ' GB';
      },
      explorerItemTypeLabel: function (item) {
        if (!item) return '';
        if (((item.kind || item.type || '').toLowerCase()) === 'folder') return 'File folder';
        return item.mime || item.kind || item.type || 'File';
      },
      explorerSelectedKey: function (state) {
        var item = (state || {}).selection || {};
        return item.id || item.key || '';
      },
      openExplorerContextMenu: function (windowId, item, event) {
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        var targetType = item ? 'item' : 'blank';
        if (!state || !event) return;
        if (item) this.selectExplorerItem(windowId, item);
        state.contextMenu = {
          open: true,
          left: event.clientX || 0,
          top: event.clientY || 0,
          targetKey: item ? (item.id || item.key || '') : '',
          targetType: targetType,
          targetKind: item ? String(item.kind || item.type || '').toLowerCase() : 'folder'
        };
      },
      closeExplorerContextMenu: function (windowId) {
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        if (state && state.contextMenu) state.contextMenu.open = false;
      },
      explorerContextMenuStyle: function (state) {
        var menu = ((state || {}).contextMenu || {});
        var width = 230;
        var height = menu.targetType === 'item' ? 280 : 190;
        var left = Math.max(4, Math.min(menu.left || 0, (window.innerWidth || 1024) - width - 8));
        var top = Math.max(4, Math.min(menu.top || 0, (window.innerHeight || 768) - height - 8));
        return { left: left + 'px', top: top + 'px' };
      },
      explorerContextIsItem: function (state) {
        return !!((state || {}).selection && (((state || {}).contextMenu || {}).targetType === 'item'));
      },
      explorerContextIsFolder: function (state) {
        var item = (state || {}).selection || {};
        return this.explorerContextIsItem(state) && String(item.kind || item.type || '').toLowerCase() === 'folder';
      },
      explorerCanPaste: function (windowId) {
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        var clip = (state && state.clipboard) || this._mioosExplorerClipboard;
        return !!(state && clip && clip.item && (clip.item.id || clip.item.key));
      },
      explorerContextOpen: function (windowId) {
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        this.closeExplorerContextMenu(windowId);
        if (state && state.selection) this.explorerOpenItem(windowId, state.selection);
      },
      explorerOpenItemInNewWindow: function (windowId) {
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        var item = state && state.selection;
        this.closeExplorerContextMenu(windowId);
        if (!item) return;
        if (String(item.kind || item.type || '').toLowerCase() === 'folder' && this.openExplorerFolder) {
          this.openExplorerFolder(item.id || item.key || item.folderId, item.name || item.title || 'Folder');
          return;
        }
        this.explorerOpenItem(windowId, item);
      },
      explorerContextProperties: function (windowId) {
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        this.closeExplorerContextMenu(windowId);
        if (state && state.selection && this.openFilePropertiesWindow) {
          this.openFilePropertiesWindow(state.selection);
          return;
        }
        this.openFolderPropertiesWindow(windowId);
      },
      explorerCopySelected: function (windowId) {
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        if (!state || !state.selection) return;
        state.clipboard = { op: 'copy', item: clone(state.selection) };
        this._mioosExplorerClipboard = state.clipboard;
        this.closeExplorerContextMenu(windowId);
      },
      explorerCutSelected: function (windowId) {
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        if (!state || !state.selection) return;
        state.clipboard = { op: 'move', item: clone(state.selection) };
        this._mioosExplorerClipboard = state.clipboard;
        this.closeExplorerContextMenu(windowId);
      },
      explorerPasteIntoWindow: function (windowId) {
        var self = this;
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        var clip = (state && state.clipboard) || this._mioosExplorerClipboard;
        var item = clip && clip.item;
        var op = (clip && clip.op) === 'move' ? 'fs.move' : 'fs.copy';
        if (!state || !item || !this.command) return Promise.resolve();
        this.closeExplorerContextMenu(windowId);
        return this.command(op, { id: item.id || item.key || '', parent: state.folderId }).then(function () {
          if (op === 'fs.move') {
            state.clipboard = null;
            self._mioosExplorerClipboard = null;
          }
          return self.refreshExplorerWindow(windowId).then(function () { if (self.refreshView) self.refreshView(); });
        }).catch(function (err) {
          if (self.showAlert) self.showAlert(self.t('alerts.shellEventError.title', 'Explorer'), (err && err.message) || (op === 'fs.move' ? 'fs_move_failed' : 'fs_copy_failed'));
        });
      },
      /* MIOOST restored explorer helpers for classic folder surfaces and resilient uploads. */
      normalizeUploadEntries: function (filesLike) {
        var out = [], i, entry, list;
        if (!filesLike) return out;
        if (filesLike instanceof window.File || (filesLike.name && typeof filesLike.size !== 'undefined' && !filesLike.length)) list = [filesLike];
        else if (filesLike.files) list = filesLike.files;
        else if (filesLike.items && filesLike.items.length) {
          list = [];
          for (i = 0; i < filesLike.items.length; i += 1) {
            entry = filesLike.items[i];
            if (entry && entry.kind === 'file' && entry.getAsFile) list.push(entry.getAsFile());
          }
        } else list = filesLike;
        for (i = 0; i < (list.length || 0); i += 1) {
          entry = list[i];
          if (!entry) continue;
          out.push(entry && entry.file ? entry : { file: entry, name: entry && entry.name, size: entry && entry.size, type: entry && entry.type });
        }
        return out;
      },
      openFilePropertiesWindow: function (item) {
        var target = clone(item || {});
        var id = nextWindowId(this, 'win-file-properties');
        this.windows.push({
          id: id,
          appKey: 'file-properties',
          title: 'Properties - ' + (target.name || target.title || 'File'),
          state: 'normal',
          left: 240,
          top: 140,
          width: 420,
          height: 340,
          z: this.zCounter + 1,
          meta: { file: target }
        });
        this.focusWindow(id);
      },
      openFolderPropertiesWindow: function (windowId, folder) {
        var source = this.windows.find(function (entry) { return entry.id === windowId; }) || {};
        var state = this.ensureExplorerWindowState ? this.ensureExplorerWindowState(source) : {};
        var target = folder || state.folder || source.meta || {};
        var id = nextWindowId(this, 'win-folder-properties');
        this.windows.push({ id: id, appKey: 'folder-properties', title: 'Properties - ' + (target.name || source.title || 'Folder'), state: 'normal', left: 220, top: 120, width: 520, height: 430, z: this.zCounter + 1, meta: { sourceWindowId: windowId, folderId: target.id || state.folderId || source.folderId || '', folder: target }, folderProperties: { background: (target.customize || {}).background || '', icon: (target.customize || {}).icon || '', viewMode: target.viewMode || 'details' } });
        this.focusWindow(id);
      },
      saveFolderPropertiesWindow: function (win) {
        var payload = { command: 'fs.setmeta', id: (((win || {}).meta || {}).folderId) || '', meta: (win || {}).folderProperties || {} };
        if (!payload.id || !this.command) return Promise.resolve(false);
        return this.command('fs.setmeta', payload).then(function () { return true; });
      },
      uploadFolderCustomizeAsset: function (win, input, field) {
        var self = this;
        var file = input && input.files && input.files[0];
        var parentId = (((win || {}).meta || {}).folderId) || (((this.boot || {}).vfs || {}).desktopId) || 'root';
        if (!file) return Promise.resolve(null);
        return this.uploadFilesToExplorer((((win || {}).meta || {}).sourceWindowId) || '', [file]).then(function (responsePayload) {
          var id = responsePayload && responsePayload.id; /* responsePayload.id */
          if (id && self.command) return self.command('fs.setmeta', { id: parentId, meta: { field: field || 'folderBackground', assetId: id } });
          return responsePayload;
        });
      },
      uploadFilesToExplorer: function (windowId, filesLike) {
        var self = this;
        var normalizedEntries = this.normalizeUploadEntries ? this.normalizeUploadEntries(filesLike) : (filesLike || []);
        if (normalizedEntries.length > 1) {
          return normalizedEntries.reduce(function (chain, entry) {
            return chain.then(function () { return self.uploadFilesToExplorer(windowId, [entry]); });
          }, Promise.resolve());
        }
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        var uploadEntry = normalizedEntries && normalizedEntries[0];
        var file = uploadEntry && uploadEntry.file ? uploadEntry.file : uploadEntry;
        var mime;
        var isText;
        var chunkTransport;
        function httpJson(url, payload) {
          return new Promise(function (resolve, reject) {
            var xhr = new XMLHttpRequest();
            xhr.open('POST', url, true);
            xhr.setRequestHeader('Content-Type', 'application/json');
            xhr.onreadystatechange = function () {
              var body;
              if (xhr.readyState !== 4) return;
              if (xhr.status >= 200 && xhr.status < 300) {
                try { body = JSON.parse(xhr.responseText || '{}'); } catch (err) { body = {}; }
                resolve(body);
                return;
              }
              try { body = JSON.parse(xhr.responseText || '{}'); } catch (err2) { body = {}; }
              var error = new Error(body.detail || body.reason || body.error || ('http_' + xhr.status)); error.status = xhr.status; error.body = body; reject(error);
            };
            xhr.onerror = function () { reject(new Error('network_error')); };
            xhr.send(JSON.stringify(payload || {}));
          });
        }
        if (!state || !this.command || !file) return Promise.resolve();
        mime = file.type || 'application/octet-stream';
        isText = detectTextLike({ name: file.name, mime: mime });
        chunkTransport = (((this.boot || {}).vfs || {}).uploadChunkTransport) || 'websocket';
        var transferId = self.registerTransfer ? self.registerTransfer({ kind: 'upload', name: file.name, status: 'preparing', stage: 'Preparing', totalBytes: file.size, processedBytes: 0, sourceWindowId: windowId, persistent: true, dedupeKey: ['upload', state.folderId || '', file.name || '', file.size || 0, file.lastModified || 0].join('|'), resume: { kind: 'upload', parentId: state.folderId, sourceWindowId: windowId, fileName: file.name, mime: mime, totalBytes: file.size, chunkTransport: chunkTransport, uploadId: '' } }) : '';
        var transferControl = { cancelled: false, paused: false, workers: [], xh: {}, uploadId: '', windowId: windowId, nextIndex: 1, completedBytes: 0, completed: {}, retries: {}, totalChunks: 0, finalizeRetries: 0, serverReadyForCommit: false, commitStarted: false, missing_chunk: false };
        if (transferId && self.setTransferController) {
          self.setTransferController(transferId, {
            onRetry: function () { return self.uploadFilesToExplorer(windowId, [file]); },
            onPause: function () {
              transferControl.paused = true;
              transferControl.disconnectPaused = false;
              Object.keys(transferControl.xh || {}).forEach(function (key) {
                try { if (transferControl.xh[key]) transferControl.xh[key].abort(); } catch (err) {}
              });
              return Promise.resolve();
            },
            onResume: function () {
              transferControl.paused = false;
              transferControl.disconnectPaused = false;
              if (!transferControl.uploadId || chunkTransport !== 'http-binary') return Promise.resolve();
              return httpJson((((self.boot || {}).routes || {}).fsUploadStatus || '/api/mioos/fs/upload/status'), { uploadId: transferControl.uploadId }).then(function (msg) {
                var nextIndex = +(((msg || {}).nextIndex) || ((((msg || {}).vfs || {}).nextIndex) || 1));
                var contiguousBytes = +(((msg || {}).contiguousBytes) || ((((msg || {}).vfs || {}).contiguousBytes) || 0));
                var i;
                transferControl.completed = {};
                transferControl.completedBytes = contiguousBytes;
                transferControl.nextIndex = nextIndex > 0 ? nextIndex : 1;
                for (i = 1; i < transferControl.nextIndex; i += 1) transferControl.completed[i] = 1;
                if (state.upload && state.upload.transferId && self.updateTransfer) self.updateTransfer(state.upload.transferId, { status: 'uploading', stage: 'Resuming upload', processedBytes: contiguousBytes, totalBytes: file.size });
                self.setExplorerUploadProgress(state, { active: true, name: file.name, totalBytes: file.size, sentBytes: contiguousBytes, stage: 'Resuming upload', uploadId: transferControl.uploadId });
                return transferControl.resumePump ? transferControl.resumePump() : Promise.resolve();
              }).catch(function (err) {
                if ((err && err.message) === 'network_error' || !navigatorOnline()) {
                  transferControl.paused = true;
                  if (self.updateTransfer) self.updateTransfer(transferId, { status: 'paused', stage: 'Paused (connection lost)', processedBytes: transferControl.completedBytes || 0, totalBytes: file.size, error: '' });
                  return null;
                }
                throw err;
              });
            },
            onCancel: function () {
              transferControl.cancelled = true;
              transferControl.paused = false;
              Object.keys(transferControl.xh || {}).forEach(function (key) {
                try { if (transferControl.xh[key]) transferControl.xh[key].abort(); } catch (err) {}
              });
              (transferControl.workers || []).forEach(function (worker) {
                if (worker && worker.close) worker.close();
              });
              if (transferControl.uploadId && chunkTransport === 'http-binary') {
                return httpJson((((self.boot || {}).routes || {}).fsUploadAbort || '/api/mioos/fs/upload/abort'), { uploadId: transferControl.uploadId }).catch(function () { return null; });
              }
              if (transferControl.uploadId && self.socketRequest) {
                return self.socketRequest((self.boot.routes || {}).commandEvent || 'desktop.command', { command: 'fs.upload.abort', uploadId: transferControl.uploadId }, { command: 'fs.upload.abort', dedupeKey: 'fs.upload.abort|' + transferControl.uploadId, timeoutMs: uploadTimeoutConfig(self).uploadAbortTimeoutMs }).catch(function () { return null; });
              }
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
          transferControl.paused = false;
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
            if (transferId && self.finalizeTransfer) self.finalizeTransfer(transferId, true, { processedBytes: file.size, totalBytes: file.size, progress: 100, resume: { kind: 'upload', parentId: state.folderId, sourceWindowId: windowId, fileName: file.name, mime: mime, totalBytes: file.size, chunkTransport: chunkTransport, uploadId: transferControl.uploadId || ((state.upload || {}).uploadId) || '', contiguousBytes: file.size, completed: 1 } });
            window.setTimeout(function () { self.resetExplorerUpload(state); }, 1200);
          });
        }
        function fail(err, fallback) {
          var message = (err && err.message) || fallback;
          if (message === 'transfer_cancelled') {
            self.setExplorerUploadProgress(state, { active: false, stage: 'Cancelled', error: '', uploadId: '' });
            if (transferId && self.updateTransfer) self.updateTransfer(transferId, { status: 'cancelled', stage: 'Cancelled', processedBytes: ((state.upload || {}).sentBytes || 0), totalBytes: file.size });
            return Promise.resolve();
          }
          self.setExplorerUploadProgress(state, { active: false, stage: 'Failed', error: message, uploadId: '' });
          if (transferId && self.finalizeTransfer) self.finalizeTransfer(transferId, false, { error: message, processedBytes: ((state.upload || {}).sentBytes || 0), totalBytes: file.size, resume: { kind: 'upload', parentId: state.folderId, sourceWindowId: windowId, fileName: file.name, mime: mime, totalBytes: file.size, chunkTransport: chunkTransport, uploadId: transferControl.uploadId || ((state.upload || {}).uploadId) || '', contiguousBytes: transferControl.completedBytes || ((state.upload || {}).sentBytes || 0) } });
          if (self.showAlert) self.showAlert(self.t('alerts.shellEventError.title', 'Explorer'), message);
          throw (err || new Error(fallback));
        }
        if (!useChunkedUpload(file, isText)) {
          self.setExplorerUploadProgress(state, { stage: 'Uploading' });
          if (isText) {
            return fileToText(file).then(function (result) {
              return self.command('fs.write', {
                parent: state.folderId,
                name: file.name,
                mime: mime,
                data: result,
                content: result,
                text: result
              });
            }).then(finalize).catch(function (err) { return fail(err, 'fs_write_failed'); });
          }
          return blobToArrayBuffer(file).then(function (buffer) {
            var result = 'data:' + mime + ';base64,' + uint8ToBase64(new Uint8Array(buffer));
            return self.command('fs.write', {
              parent: state.folderId,
              name: file.name,
              mime: mime,
              data: result,
              content: result,
              text: result
            });
          }).then(finalize).catch(function (err) { return fail(err, 'fs_write_failed'); });
        }
        if (chunkTransport === 'http-binary') {
          return httpJson((((self.boot || {}).routes || {}).fsUploadBegin || '/api/mioos/fs/upload/begin'), {
            parent: state.folderId,
            name: file.name,
            mime: mime,
            totalBytes: file.size,
            encoding: 'binary'
          }).then(function (msg) {
            var uploadId = (msg && (msg.uploadId || ((msg.vfs || {}).uploadId))) || '';
            var chunkBytes = +((msg && (msg.chunkBytes || ((msg.vfs || {}).chunkBytes))) || ((self.boot && self.boot.vfs && self.boot.vfs.uploadChunkBytes) || 256000));
            var concurrency = +((msg && (msg.concurrencyDefault || ((msg.vfs || {}).concurrencyDefault))) || ((self.boot && self.boot.vfs && self.boot.vfs.uploadConcurrency) || 4));
            var totalChunks = file.size > 0 ? Math.ceil(file.size / chunkBytes) : 0;
            if (!uploadId) throw new Error('upload_begin_failed');
            transferControl.uploadId = uploadId;
            transferControl.nextIndex = 1;
            transferControl.completed = {};
            transferControl.completedBytes = 0;
            transferControl.totalChunks = totalChunks;
            state.upload.uploadId = uploadId;
            state.upload.transferId = transferId || '';
            self.setExplorerUploadProgress(state, { stage: 'Uploading chunks', uploadId: uploadId });
            if (transferId && self.updateTransfer) self.updateTransfer(transferId, { status: 'uploading', stage: 'Uploading chunks', processedBytes: 0, totalBytes: file.size, resume: { kind: 'upload', parentId: state.folderId, sourceWindowId: windowId, fileName: file.name, mime: mime, totalBytes: file.size, chunkTransport: chunkTransport, uploadId: uploadId, contiguousBytes: 0, nextIndex: 1 } });
            function allDone() {
              return transferControl.completedBytes >= file.size && Object.keys(transferControl.xh || {}).length === 0;
            }
            function nextPending() {
              while (transferControl.nextIndex <= transferControl.totalChunks && (transferControl.completed[transferControl.nextIndex] || transferControl.xh[transferControl.nextIndex])) transferControl.nextIndex += 1;
              if (transferControl.nextIndex > transferControl.totalChunks) return 0;
              return transferControl.nextIndex++;
            }
            function markDone(index, bytes) {
              if (!transferControl.completed[index]) {
                transferControl.completed[index] = 1;
                transferControl.completedBytes += bytes;
              }
            }
            function syncProgress(stage, force) {
              var now = Date.now();
              var patch;
              if (!force && transferControl.lastUiAt && (now - transferControl.lastUiAt) < 120 && Math.abs((transferControl.completedBytes || 0) - (transferControl.lastUiBytes || 0)) < chunkBytes) return;
              transferControl.lastUiAt = now;
              transferControl.lastUiBytes = transferControl.completedBytes || 0;
              self.setExplorerUploadProgress(state, { active: true, name: file.name, totalBytes: file.size, sentBytes: transferControl.completedBytes, stage: stage, uploadId: uploadId });
              patch = { status: transferControl.paused ? 'paused' : 'uploading', stage: transferControl.paused ? 'Paused' : stage, processedBytes: transferControl.completedBytes, totalBytes: file.size, resume: { kind: 'upload', parentId: state.folderId, sourceWindowId: windowId, fileName: file.name, mime: mime, totalBytes: file.size, chunkTransport: chunkTransport, uploadId: uploadId, contiguousBytes: transferControl.completedBytes, nextIndex: transferControl.nextIndex } };
              if (transferId && self.updateTransfer) self.updateTransfer(transferId, patch);
            }
            function pauseForDisconnect(stageText) {
              transferControl.paused = true;
              transferControl.disconnectPaused = true;
              Object.keys(transferControl.xh || {}).forEach(function (key) {
                try { if (transferControl.xh[key]) transferControl.xh[key].abort(); } catch (err) {}
              });
              self.setExplorerUploadProgress(state, { active: true, name: file.name, totalBytes: file.size, sentBytes: transferControl.completedBytes, stage: stageText || 'Paused (connection lost)', uploadId: uploadId, error: '' });
              if (transferId && self.updateTransfer) self.updateTransfer(transferId, { status: 'paused', stage: stageText || 'Paused (connection lost)', processedBytes: transferControl.completedBytes, totalBytes: file.size, error: '', resume: { kind: 'upload', parentId: state.folderId, sourceWindowId: windowId, fileName: file.name, mime: mime, totalBytes: file.size, chunkTransport: chunkTransport, uploadId: uploadId, contiguousBytes: transferControl.completedBytes, nextIndex: transferControl.nextIndex } });
              return Promise.resolve();
            }
            function retryChunkLater(index, bytes, stageText) {
              var attempt = (transferControl.retries[index] || 0) + 1;
              transferControl.retries[index] = attempt;
              delete transferControl.xh[index];
              if (attempt > 4) {
                fail(new Error('fs_upload_chunk_failed'), 'fs_upload_chunk_failed');
                return;
              }
              transferControl.nextIndex = Math.min(transferControl.nextIndex || index, index);
              self.setExplorerUploadProgress(state, { active: true, name: file.name, totalBytes: file.size, sentBytes: transferControl.completedBytes, stage: stageText || ('Retrying chunk ' + index), uploadId: uploadId, error: '' });
              if (transferId && self.updateTransfer) self.updateTransfer(transferId, { status: 'uploading', stage: stageText || ('Retrying chunk ' + index), processedBytes: transferControl.completedBytes, totalBytes: file.size, error: '', resume: { kind: 'upload', parentId: state.folderId, sourceWindowId: windowId, fileName: file.name, mime: mime, totalBytes: file.size, chunkTransport: chunkTransport, uploadId: uploadId, contiguousBytes: transferControl.completedBytes, nextIndex: transferControl.nextIndex } });
              window.setTimeout(function () {
                if (!transferControl.paused && !transferControl.cancelled) pump();
              }, uploadRetryDelay(attempt));
            }
            function reconcileMissingChunk(err) {
              transferControl.missing_chunk = true;
              transferControl.commitStarted = false;
              return reconcileCommitFailure(err);
            }
            function reconcileCommitFailure(err) {
              transferControl.commitStarted = false;
              transferControl.finalizeRetries = (transferControl.finalizeRetries || 0) + 1;
              if (transferControl.finalizeRetries > 3) throw err;
              self.setExplorerUploadProgress(state, { active: true, name: file.name, totalBytes: file.size, sentBytes: transferControl.completedBytes, stage: 'Reconciling upload', uploadId: uploadId, error: '' });
              return httpJson((((self.boot || {}).routes || {}).fsUploadStatus || '/api/mioos/fs/upload/status'), { uploadId: uploadId }).then(function (msg) {
                var payload = payloadRoot(msg);
                var nextIndex = +(payload.nextIndex || payload.missingChunk || (((err && err.body) || {}).nextIndex) || (((err && err.body) || {}).missingChunk) || 1);
                var contiguousBytes = +(payload.contiguousBytes || (((err && err.body) || {}).contiguousBytes) || 0);
                var i;
                transferControl.completed = {};
                transferControl.completedBytes = contiguousBytes;
                transferControl.nextIndex = nextIndex > 0 ? nextIndex : 1;
                for (i = 1; i < transferControl.nextIndex; i += 1) transferControl.completed[i] = 1;
                syncProgress('Reconciling upload', true);
                if (contiguousBytes >= file.size && transferControl.nextIndex > transferControl.totalChunks) {
                  return commitUpload();
                }
                return pump();
              });
            }
            function commitUpload() {
              if (transferControl.commitStarted) return Promise.resolve();
              transferControl.commitStarted = true;
              transferControl.serverReadyForCommit = true;
              return httpJson((((self.boot || {}).routes || {}).fsUploadCommit || '/api/mioos/fs/upload/commit'), { uploadId: uploadId }).then(finalize).catch(function (err) {
                var body = (err && err.body) || {};
                transferControl.commitStarted = false;
                if ((err && err.message) === 'network_error' || !navigatorOnline()) return pauseForDisconnect('Paused before finalize');
                if (body.detail === 'missing_chunk' || body.error === 'missing_chunk' || body.detail === 'fs_upload_commit_failed' || (err && err.status) === 409) return reconcileMissingChunk(err).catch(function (innerErr) { fail(innerErr, 'fs_upload_commit_failed'); });
                if (isTransientUploadStatus(err && err.status)) return reconcileCommitFailure(err).catch(function (innerErr) { fail(innerErr, 'fs_upload_commit_failed'); });
                fail(err, 'fs_upload_commit_failed');
                return null;
              });
            }
            function pump() {
              var activeCount;
              if (transferControl.cancelled || transferControl.paused) return Promise.resolve();
              activeCount = Object.keys(transferControl.xh || {}).length;
              while (activeCount < Math.max(1, concurrency)) {
                (function (index) {
                  var start, end, part, xhr, bytes;
                  if (!index) return;
                  start = (index - 1) * chunkBytes;
                  end = Math.min(start + chunkBytes, file.size);
                  bytes = Math.max(0, end - start);
                  part = file.slice(start, end);
                  xhr = new XMLHttpRequest();
                  transferControl.xh[index] = xhr;
                  xhr.open('POST', (((self.boot || {}).routes || {}).fsUploadChunk || '/api/mioos/fs/upload/chunk'), true);
                  xhr.timeout = uploadTimeoutConfig(self).uploadChunkTimeoutMs;
                  xhr.setRequestHeader('Content-Type', 'application/octet-stream');
                  xhr.setRequestHeader('X-MIOOS-Upload-Id', uploadId);
                  xhr.setRequestHeader('X-MIOOS-Upload-Index', String(index));
                  xhr.setRequestHeader('X-MIOOS-Upload-Bytes', String(bytes));
                  xhr.onreadystatechange = function () {
                    var body;
                    if (xhr.readyState !== 4) return;
                    delete transferControl.xh[index];
                    if (xhr.status >= 200 && xhr.status < 300) {
                      transferControl.retries[index] = 0;
                      markDone(index, bytes);
                      syncProgress('Uploading chunks', false);
                      if (allDone()) {
                        commitUpload();
                      } else if (!transferControl.paused && !transferControl.cancelled) {
                        pump();
                      }
                      return;
                    }
                    if (transferControl.paused || transferControl.cancelled) return;
                    if (xhr.status === 0 || !navigatorOnline()) { pauseForDisconnect('Paused (connection lost)'); return; }
                    try { body = JSON.parse(xhr.responseText || '{}'); } catch (errx) { body = {}; }
                    if (isTransientUploadStatus(xhr.status)) {
                      retryChunkLater(index, bytes, 'Retrying chunk ' + index);
                      return;
                    }
                    fail(new Error(body.detail || body.reason || body.error || ('http_' + xhr.status)), 'fs_upload_chunk_failed');
                  };
                  xhr.onerror = function () {
                    delete transferControl.xh[index];
                    if (transferControl.paused || transferControl.cancelled) return;
                    pauseForDisconnect('Paused (connection lost)');
                  };
                  xhr.ontimeout = function () {
                    delete transferControl.xh[index];
                    if (transferControl.paused || transferControl.cancelled) return;
                    if (!navigatorOnline()) { pauseForDisconnect('Paused (connection lost)'); return; }
                    retryChunkLater(index, bytes, 'Retrying chunk ' + index + ' after timeout');
                  };
                  xhr.send(part);
                }(nextPending()));
                activeCount = Object.keys(transferControl.xh || {}).length;
                if (activeCount >= Math.max(1, concurrency)) break;
                if (transferControl.nextIndex > transferControl.totalChunks) break;
              }
              return Promise.resolve();
            }
            transferControl.resumePump = function () { return pump(); };
            if (transferControl.totalChunks < 1) {
              return httpJson((((self.boot || {}).routes || {}).fsUploadCommit || '/api/mioos/fs/upload/commit'), { uploadId: uploadId }).then(finalize);
            }
            return pump();
          }).catch(function (err) {
            var uploadId = transferControl.uploadId || (state.upload && state.upload.uploadId);
            if (uploadId) httpJson((((self.boot || {}).routes || {}).fsUploadAbort || '/api/mioos/fs/upload/abort'), { uploadId: uploadId }).catch(function () {});
            return fail(err, 'fs_upload_failed');
          });
        }
        return self.socketRequest((self.boot.routes || {}).commandEvent || 'desktop.command', {
          command: 'fs.upload.begin',
          parent: state.folderId,
          name: file.name,
          mime: mime,
          totalBytes: file.size,
          encoding: isText ? 'text' : 'base64-dataurl'
        }, { command: 'fs.upload.begin', dedupeKey: 'fs.upload.begin|' + windowId + '|' + file.name + '|' + file.size, timeoutMs: uploadTimeoutConfig(self).uploadBeginTimeoutMs }).then(function (msg) {
          var payload = payloadRoot(msg);
          var uploadId = payload.uploadId;
          var chunkChars = (payload && payload.chunkBytes) || ((self.boot && self.boot.vfs && self.boot.vfs.uploadChunkBytes) || 32768);
          var uploadConcurrency = (payload && payload.concurrencyDefault) || ((self.boot && self.boot.vfs && self.boot.vfs.uploadConcurrency) || 7);
          var uploadBatchSize = (payload && payload.batchSize) || ((self.boot && self.boot.vfs && self.boot.vfs.uploadBatchSize) || ((self.boot && self.boot.websocket && self.boot.websocket.uploadBatchSize) || 1));
          if (!uploadId) throw new Error('upload_begin_failed');
          state.upload.uploadId = uploadId;
          state.upload.transferId = transferId || '';
          transferControl.uploadId = uploadId;
          self.setExplorerUploadProgress(state, { stage: 'Uploading chunks', uploadId: uploadId });
          if (transferId && self.updateTransfer) self.updateTransfer(transferId, { status: 'uploading', stage: 'Uploading chunks', processedBytes: 0, totalBytes: file.size });
          if (isText) {
            return fileToText(file).then(function (textValue) {
              var segments = [];
              var offset = 0;
              while (offset < textValue.length || (textValue.length === 0 && segments.length === 0)) {
                var piece = textValue.slice(offset, offset + chunkChars);
                segments.push({ data: piece, bytes: piece.length });
                offset += chunkChars;
                if (textValue.length === 0) break;
              }
              return self.uploadChunkedSegments(uploadId, segments, state, transferControl, file.name, uploadConcurrency, uploadBatchSize);
            });
          }
          return blobToArrayBuffer(file).then(function (buffer) {
            var bytes = new Uint8Array(buffer);
            var rawChunkBytes = Math.max(131072, Math.floor(chunkChars * 3 / 4));
            var segments = [];
            var offset = 0;
            while (offset < bytes.length || (bytes.length === 0 && segments.length === 0)) {
              var end = Math.min(offset + rawChunkBytes, bytes.length);
              var slice = bytes.slice(offset, end);
              var encoded = uint8ToBase64(slice);
              segments.push({ data: encoded, bytes: encoded.length, rawBytes: Math.max(0, end - offset) });
              offset = end;
              if (bytes.length === 0) break;
            }
            return self.uploadChunkedSegments(uploadId, segments, state, transferControl, file.name, uploadConcurrency, uploadBatchSize);
          });
        }).then(function () {
          self.setExplorerUploadProgress(state, { stage: 'Finalizing', progress: 100, sentBytes: state.upload.totalBytes });
          if (transferId && self.updateTransfer) self.updateTransfer(transferId, { status: 'finalizing', stage: 'Finalizing', processedBytes: state.upload.totalBytes, totalBytes: state.upload.totalBytes });
          return self.socketRequest((self.boot.routes || {}).commandEvent || 'desktop.command', { command: 'fs.upload.commit', uploadId: (state.upload && state.upload.uploadId) }, { command: 'fs.upload.commit', dedupeKey: 'fs.upload.commit|' + ((state.upload && state.upload.uploadId) || ''), timeoutMs: uploadTimeoutConfig(self).uploadCommitTimeoutMs });
        }).then(finalize).catch(function (err) {
          var uploadId = state.upload && state.upload.uploadId;
          if (uploadId) {
            self.socketRequest((self.boot.routes || {}).commandEvent || 'desktop.command', { command: 'fs.upload.abort', uploadId: uploadId }, { command: 'fs.upload.abort', dedupeKey: 'fs.upload.abort|' + uploadId, timeoutMs: uploadTimeoutConfig(self).uploadAbortTimeoutMs }).catch(function () {});
          }
          return fail(err, 'fs_upload_failed');
        });
      },
      resumePersistedUpload: function (item, entry) {
        var self = this;
        var resume = (item && item.resume) || {};
        var file = entry && entry.file ? entry.file : entry;
        var chunkBytes = +resume.chunkBytes || +((((this.boot || {}).vfs || {}).uploadChunkBytes) || 131072);
        var concurrency = +((((this.boot || {}).vfs || {}).uploadConcurrency) || 4);
        var nextIndex = +resume.nextIndex || 1;
        var totalChunks = file.size > 0 ? Math.ceil(file.size / chunkBytes) : 0;
        var completedBytes = +resume.contiguousBytes || 0;
        var active = {};
        var cancelled = false;
        var xh = {};
        if (!item || !resume.uploadId || !file) return Promise.resolve();
        function pauseUpload(stageText) {
          cancelled = false;
          Object.keys(xh).forEach(function (key) { try { if (xh[key]) xh[key].abort(); } catch (err) {} });
          if (self.updateTransfer) self.updateTransfer(item.id, { status: 'paused', stage: stageText || 'Paused', processedBytes: completedBytes, totalBytes: file.size, error: '', resume: Object.assign({}, resume, { contiguousBytes: completedBytes, nextIndex: nextIndex }) });
          return Promise.resolve();
        }
        function abortUpload() {
          cancelled = true;
          Object.keys(xh).forEach(function (key) { try { if (xh[key]) xh[key].abort(); } catch (err) {} });
          return httpJsonPost((((self.boot || {}).routes || {}).fsUploadAbort || '/api/mioos/fs/upload/abort'), { uploadId: resume.uploadId }).catch(function () { return null; });
        }
        function resumeUpload() {
          cancelled = false;
          return httpJsonPost((((self.boot || {}).routes || {}).fsUploadStatus || '/api/mioos/fs/upload/status'), { uploadId: resume.uploadId }).then(function (msg) {
            var payload = payloadRoot(msg);
            nextIndex = +payload.nextIndex || 1;
            completedBytes = +payload.contiguousBytes || 0;
            resume.contiguousBytes = completedBytes;
            resume.nextIndex = nextIndex;
            active = {};
            if (self.updateTransfer) self.updateTransfer(item.id, { status: 'uploading', stage: 'Resuming upload', processedBytes: completedBytes, totalBytes: file.size, resume: Object.assign({}, resume) });
            return pump();
          }).catch(function (err) {
            if ((err && err.message) === 'network_error' || !navigatorOnline()) return pauseUpload('Paused (connection lost)');
            throw err;
          });
        }
        if (self.setTransferController) self.setTransferController(item.id, { onPause: function () { return pauseUpload('Paused'); }, onResume: resumeUpload, onRetry: function () { return self.recoverPersistedUploadTransfer(item, true); }, onCancel: abortUpload });
        if (self.updateTransfer) self.updateTransfer(item.id, { status: 'uploading', stage: 'Resuming upload', processedBytes: completedBytes, totalBytes: file.size, resume: Object.assign({}, resume) });
        function nextPending() {
          while (nextIndex <= totalChunks && active[nextIndex]) nextIndex += 1;
          if (nextIndex > totalChunks) return 0;
          active[nextIndex] = 1;
          return nextIndex++;
        }
        function retryResumeChunk(index, bytes, stageText) {
          resume.retries = resume.retries || {};
          resume.retries[index] = (resume.retries[index] || 0) + 1;
          delete active[index];
          delete xh[index];
          nextIndex = Math.min(nextIndex || index, index);
          if (resume.retries[index] > 4) {
            if (self.finalizeTransfer) self.finalizeTransfer(item.id, false, { error: 'fs_upload_chunk_failed', stage: 'Resume failed', processedBytes: completedBytes, totalBytes: file.size, resume: Object.assign({}, resume, { contiguousBytes: completedBytes }) });
            return;
          }
          if (self.updateTransfer) self.updateTransfer(item.id, { status: 'uploading', stage: stageText || ('Retrying chunk ' + index), processedBytes: completedBytes, totalBytes: file.size, resume: Object.assign({}, resume, { contiguousBytes: completedBytes, nextIndex: nextIndex }) });
          window.setTimeout(function () {
            if (!cancelled) pump();
          }, uploadRetryDelay(resume.retries[index]));
        }
        function reconcileResumeCommit(err) {
          resume.finalizeRetries = (resume.finalizeRetries || 0) + 1;
          if (resume.finalizeRetries > 3) throw err;
          return httpJsonPost((((self.boot || {}).routes || {}).fsUploadStatus || '/api/mioos/fs/upload/status'), { uploadId: resume.uploadId }).then(function (msg) {
            var payload = payloadRoot(msg);
            nextIndex = +(payload.nextIndex || payload.missingChunk || (((err && err.body) || {}).nextIndex) || (((err && err.body) || {}).missingChunk) || 1);
            completedBytes = +(payload.contiguousBytes || (((err && err.body) || {}).contiguousBytes) || 0);
            resume.contiguousBytes = completedBytes;
            resume.nextIndex = nextIndex;
            active = {};
            if (completedBytes >= file.size && nextIndex > totalChunks) {
              return httpJsonPost((((self.boot || {}).routes || {}).fsUploadCommit || '/api/mioos/fs/upload/commit'), { uploadId: resume.uploadId });
            }
            return pump();
          });
        }
        function commitResumeUpload() {
          return httpJsonPost((((self.boot || {}).routes || {}).fsUploadCommit || '/api/mioos/fs/upload/commit'), { uploadId: resume.uploadId }).catch(function (err) {
            var body = (err && err.body) || {};
            if ((err && err.message) === 'network_error' || !navigatorOnline()) return pauseUpload('Paused before finalize');
            if (body.detail === 'missing_chunk' || body.error === 'missing_chunk' || body.detail === 'fs_upload_commit_failed' || (err && err.status) === 409) return reconcileResumeCommit(err);
            if (isTransientUploadStatus(err && err.status)) return reconcileResumeCommit(err);
            throw err;
          });
        }
        function pump() {
          var running = Object.keys(xh).length;
          if (cancelled) return Promise.resolve();
          if (completedBytes >= file.size && running === 0) {
            return commitResumeUpload().then(function () {
              if (self.finalizeTransfer) self.finalizeTransfer(item.id, true, { processedBytes: file.size, totalBytes: file.size, progress: 100, resume: Object.assign({}, resume, { contiguousBytes: file.size, completed: 1 }) });
              if (self.refreshView) self.refreshView();
            }).catch(function (err) {
              if ((err && err.message) === 'network_error' || !navigatorOnline()) return pauseUpload('Paused before finalize');
              throw err;
            });
          }
          while (running < Math.max(1, concurrency)) {
            (function (index) {
              var start, end, xhr, bytes;
              if (!index) return;
              start = (index - 1) * chunkBytes;
              end = Math.min(start + chunkBytes, file.size);
              bytes = Math.max(0, end - start);
              xhr = new XMLHttpRequest();
              xh[index] = xhr;
              xhr.open('POST', (((self.boot || {}).routes || {}).fsUploadChunk || '/api/mioos/fs/upload/chunk'), true);
              xhr.timeout = uploadTimeoutConfig(self).uploadChunkTimeoutMs;
              xhr.setRequestHeader('Content-Type', 'application/octet-stream');
              xhr.setRequestHeader('X-MIOOS-Upload-Id', resume.uploadId);
              xhr.setRequestHeader('X-MIOOS-Upload-Index', String(index));
              xhr.setRequestHeader('X-MIOOS-Upload-Bytes', String(bytes));
              xhr.onreadystatechange = function () {
                if (xhr.readyState !== 4) return;
                delete xh[index];
                if (xhr.status >= 200 && xhr.status < 300) {
                  resume.retries = resume.retries || {};
                  resume.retries[index] = 0;
                  completedBytes += bytes;
                  if (self.updateTransfer) self.updateTransfer(item.id, { status: 'uploading', stage: 'Resuming upload', processedBytes: completedBytes, totalBytes: file.size, resume: Object.assign({}, resume, { contiguousBytes: completedBytes, nextIndex: nextIndex }) });
                  pump();
                  return;
                }
                if (!cancelled) {
                  if (xhr.status === 0 || !navigatorOnline()) { pauseUpload('Paused (connection lost)'); return; }
                  if (isTransientUploadStatus(xhr.status)) { retryResumeChunk(index, bytes, 'Retrying chunk ' + index); return; }
                  if (self.finalizeTransfer) self.finalizeTransfer(item.id, false, { error: 'fs_upload_chunk_failed', stage: 'Resume failed', processedBytes: completedBytes, totalBytes: file.size, resume: Object.assign({}, resume, { contiguousBytes: completedBytes }) });
                }
              };
              xhr.onerror = function () {
                delete xh[index];
                if (!cancelled) pauseUpload('Paused (connection lost)');
              };
              xhr.ontimeout = function () {
                delete xh[index];
                if (!cancelled) {
                  if (!navigatorOnline()) { pauseUpload('Paused (connection lost)'); return; }
                  retryResumeChunk(index, bytes, 'Retrying chunk ' + index + ' after timeout');
                }
              };
              xhr.send(file.slice(start, end));
            }(nextPending()));
            running = Object.keys(xh).length;
            if (nextIndex > totalChunks) break;
          }
          return Promise.resolve();
        }
        return pump();
      },
      recoverPersistedUploadTransfer: function (item, interactive) {
        var self = this;
        var resume = (item && item.resume) || {};
        if (!item || !resume.uploadId) return Promise.resolve();
        if (self.setTransferController) self.setTransferController(item.id, { onPause: function () { if (self.updateTransfer) self.updateTransfer(item.id, { status: 'paused', stage: 'Paused', error: '', resume: Object.assign({}, resume) }); return Promise.resolve(); }, onResume: function () { return self.recoverPersistedUploadTransfer(item, true); }, onRetry: function () { return self.recoverPersistedUploadTransfer(item, true); }, onCancel: function () { return httpJsonPost((((self.boot || {}).routes || {}).fsUploadAbort || '/api/mioos/fs/upload/abort'), { uploadId: resume.uploadId }).catch(function () { return null; }); } });
        return httpJsonPost((((self.boot || {}).routes || {}).fsUploadStatus || '/api/mioos/fs/upload/status'), { uploadId: resume.uploadId }).then(function (msg) {
          var payload = payloadRoot(msg);
          resume.contiguousBytes = +payload.contiguousBytes || 0;
          resume.nextIndex = +payload.nextIndex || 1;
          resume.chunkBytes = +payload.chunkBytes || +resume.chunkBytes || +((((self.boot || {}).vfs || {}).uploadChunkBytes) || 131072);
          resume.totalBytes = +payload.totalBytes || +resume.totalBytes || 0;
          if (self.updateTransfer) self.updateTransfer(item.id, { status: interactive ? 'preparing' : 'paused', stage: interactive ? 'Preparing resume' : 'Ready to resume', processedBytes: resume.contiguousBytes, totalBytes: resume.totalBytes, resume: Object.assign({}, resume) });
          if (!interactive) return null;
          return pickUploadEntries(self).then(function (entries) {
            var entry = entries && entries[0];
            if (!entry || !entry.file) return null;
            if (entry.file.name !== resume.fileName || +entry.file.size !== +resume.totalBytes) throw new Error('resume_file_mismatch');
            return self.resumePersistedUpload(item, entry.file);
          });
        }).catch(function (err) {
          if ((err && err.message) === 'network_error' || !navigatorOnline()) {
            if (self.updateTransfer) self.updateTransfer(item.id, { status: 'paused', stage: 'Paused (connection lost)', processedBytes: resume.contiguousBytes || 0, totalBytes: resume.totalBytes || 0, error: '', resume: Object.assign({}, resume) });
            return null;
          }
          if (self.finalizeTransfer) self.finalizeTransfer(item.id, false, { error: (err && err.message) || 'upload_recovery_failed', stage: 'Upload recovery failed', processedBytes: resume.contiguousBytes || 0, totalBytes: resume.totalBytes || 0, resume: Object.assign({}, resume) });
          return null;
        });
      },
      explorerPromptUpload: function (windowId) {
        var self = this;
        return pickUploadEntries(this).then(function (entries) {
          if (!entries || !entries.length) return null;
          return self.uploadFilesToExplorer(windowId, entries);
        }).catch(function (err) {
          if (err && (err.name === 'AbortError' || err.message === 'The user aborted a request.')) return null;
          throw err;
        });
      },
      explorerCreateFolder: function (windowId) {
        var self = this;
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        if (!state || !this.command) return Promise.resolve();
        return this.explorerShellInput(this.t('explorer.promptNewFolder', 'New folder name'), this.t('explorer.defaultFolderName', 'New Folder')).then(function (name) {
          if (name === null) return null;
          name = String(name || '').trim();
          if (!name) return null;
          return self.command('fs.mkdir', { parent: state.folderId, name: name }).then(function () {
            return self.refreshExplorerWindow(windowId).then(function () {
              if (self.refreshView) {
                return self.refreshView().then(function () {
                  if (state.folderId === self.desktopFolderId() && self.ensureDesktopLayout) {
                    self.ensureDesktopLayout();
                    if (self.persistDesktopLayout) self.persistDesktopLayout();
                  }
                });
              }
              return null;
            });
          });
        }).catch(function (err) {
          if (self.showAlert) self.showAlert(self.t('alerts.shellEventError.title', 'Explorer'), (err && err.message) || 'fs_mkdir_failed');
        });
      },
      explorerRenameSelected: function (windowId) {
        var self = this;
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        var item = state && state.selection;
        var name;
        if (!item || !this.command) return Promise.resolve();
        return this.explorerShellInput(this.t('explorer.promptRename', 'Rename item'), item.name || item.title || '').then(function (nextName) {
          if (nextName === null) return null;
          name = String(nextName || '').trim();
          if (!name || name === (item.name || item.title || '')) return null;
          return self.command('fs.rename', { id: item.id || item.key || '', name: name }).then(function () {
            return self.refreshExplorerWindow(windowId).then(function () {
              if (self.refreshView) self.refreshView();
            });
          });
        }).catch(function (err) {
          if (self.showAlert) self.showAlert(self.t('alerts.shellEventError.title', 'Explorer'), (err && err.message) || 'fs_rename_failed');
        });
      },
      explorerDeleteSelected: function (windowId) {
        var self = this;
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        var item = state && state.selection;
        if (!item || !this.command) return Promise.resolve();
        return this.explorerShellConfirm(this.t('explorer.confirmDelete', 'Delete the selected item?')).then(function (confirmed) {
          if (!confirmed) return null;
          return self.command('fs.delete', { id: item.id || item.key || '' }).then(function () {
            state.selection = null;
            state.preview = { title: '', content: '', mime: 'text/plain', imageSrc: '', mediaSrc: '', mediaKind: '' };
            return self.refreshExplorerWindow(windowId).then(function () {
              if (self.refreshView) self.refreshView();
            });
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
        return this.explorerShellInput(this.t('explorer.promptMove', 'Move selected item to folder path or id'), ((this.boot.vfs || {}).homeId || (this.boot.vfs || {}).rootId || 'root')).then(function (nextDestination) {
          if (nextDestination === null) return null;
          destination = String(nextDestination || '').trim();
          if (!destination) return null;
          return self.command('fs.meta', { id: destination, path: destination });
        }).then(function (msg) {
          if (!msg) return null;
          var payload = payloadRoot(msg);
          var targetId = payload.id || destination;
          return self.command('fs.move', { id: item.id || item.key || '', parent: targetId });
        }).then(function (moved) {
          if (!moved) return null;
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
        var mime = (item && item.mime) || 'application/octet-stream';
        var transferId = this.registerTransfer ? this.registerTransfer({ kind: 'download', name: name, status: 'preparing', stage: 'Preparing', totalBytes: 0, processedBytes: 0 }) : '';
        var self = this;
        var activeDownloadId = '';
        if (transferId && this.setTransferController) {
          this.setTransferController(transferId, {
            onRetry: function () { return self.downloadFileEntry(item, fallbackData); },
            onCancel: function () { return abortDownload(); }
          });
        }
        function triggerSave(raw) {
          var url = makeDownloadHref(raw, mime);
          if (!url) return;
          anchor = document.createElement('a');
          anchor.href = url;
          anchor.download = name;
          document.body.appendChild(anchor);
          anchor.click();
          document.body.removeChild(anchor);
          if (url.indexOf('blob:') === 0) window.setTimeout(function () { try { window.URL.revokeObjectURL(url); } catch (err) {} }, 2000);
        }
        function abortDownload() {
          if (!activeDownloadId || !self.command) return Promise.resolve();
          return self.command('fs.download.abort', { downloadId: activeDownloadId }).catch(function () { return null; }).then(function () {
            activeDownloadId = '';
          });
        }
        if (!item) return Promise.resolve();
        if (href) {
          triggerSave(href);
          if (transferId && this.finalizeTransfer) this.finalizeTransfer(transferId, true, { progress: 100, stage: 'Saved to browser download manager' });
          return Promise.resolve();
        }
        href = buildFsBlobUrl(this, item, { download: true });
        if (href) {
          anchor = document.createElement('a');
          anchor.href = href;
          anchor.download = name;
          document.body.appendChild(anchor);
          anchor.click();
          document.body.removeChild(anchor);
          if (transferId && this.finalizeTransfer) this.finalizeTransfer(transferId, true, { progress: 100, stage: 'Handed off to browser download manager' });
          return Promise.resolve();
        }
        if (!this.command) return Promise.resolve();
        if (transferId && this.updateTransfer) this.updateTransfer(transferId, { status: 'downloading', stage: 'Downloading' });
        return this.command('fs.download.begin', { id: item.id || item.key || item.fileId }).then(function (msg) {
          var begin = payloadRoot(msg);
          var totalBytes = +begin.transferBytes || +begin.size || 0;
          var logicalBytes = +begin.size || totalBytes;
          var chunkSize = +begin.chunkSize || 32768;
          var downloadEncoding = String(begin.encoding || 'text').toLowerCase();
          var offset = 0;
          var pieces = [];
          activeDownloadId = begin.downloadId || '';
          if (transferId && self.updateTransfer) self.updateTransfer(transferId, { totalBytes: totalBytes, logicalBytes: logicalBytes, processedBytes: 0, progress: 0, stage: 'Downloading' });
          function assembledResult() {
            return downloadEncoding === 'base64' ? concatBytes(pieces) : pieces.join('');
          }
          function nextChunk() {
            if (totalBytes > 0 && offset >= totalBytes) return Promise.resolve(assembledResult());
            return self.command('fs.download.chunk', { downloadId: begin.downloadId, offset: offset, size: chunkSize }).then(function (chunkMsg) {
              var chunk = payloadRoot(chunkMsg);
              var data = chunk.data || '';
              var chunkEncoding = String(chunk.encoding || downloadEncoding).toLowerCase();
              var nextOffset = +chunk.nextOffset || (offset + (+chunk.size || 0) || (chunkEncoding === 'base64' ? 0 : String(data).length));
              pieces.push(chunkEncoding === 'base64' ? base64ToBytes(data) : String(data));
              if (nextOffset <= offset && !(+chunk.eof === 1 || chunk.eof === true)) throw new Error('download_offset_stalled');
              offset = nextOffset;
              if (transferId && self.updateTransfer) self.updateTransfer(transferId, { processedBytes: offset, totalBytes: +chunk.totalBytes || totalBytes, progress: totalBytes > 0 ? Math.round((offset / totalBytes) * 100) : 0, stage: (+chunk.eof === 1 || chunk.eof === true) ? 'Finalizing' : 'Downloading' });
              if (+chunk.eof === 1 || chunk.eof === true) return assembledResult();
              return nextChunk();
            });
          }
          return nextChunk().then(function (raw) {
            if (+begin.verifyHash === 1 || begin.verifyHash === true) {
              if (transferId && self.updateTransfer) self.updateTransfer(transferId, { status: 'verifying', stage: 'Verifying download', processedBytes: totalBytes || logicalBytes || 0, totalBytes: totalBytes || logicalBytes || 0, progress: 100 });
              return (downloadEncoding === 'base64' ? sha256HexBytes(raw) : sha256Hex(raw)).then(function (actualHash) {
                var expectedHash = String(begin.sha256 || '').toLowerCase();
                if (expectedHash && actualHash && expectedHash !== actualHash) throw new Error('download_hash_mismatch');
                return raw;
              });
            }
            return raw;
          }).then(function (raw) {
            triggerSave(raw);
            if (transferId && self.finalizeTransfer) self.finalizeTransfer(transferId, true, { processedBytes: totalBytes || logicalBytes || 0, totalBytes: totalBytes || logicalBytes || 0, logicalBytes: logicalBytes, progress: 100, stage: 'Saved to browser download manager' });
            return abortDownload();
          });
        }).catch(function (err) {
          var code = (err && err.message) || 'download_failed';
          var size = +((item && item.size) || 0);
          var canFallbackRead = detectTextLike(item) && size > 0 && size <= 32768;
          return abortDownload().then(function () {
            if (code === 'download_hash_mismatch' || code === 'download_offset_stalled') {
              if (transferId && self.finalizeTransfer) self.finalizeTransfer(transferId, false, { error: code, stage: 'Download verification failed' });
              throw err;
            }
            if (!canFallbackRead) {
              if (transferId && self.finalizeTransfer) self.finalizeTransfer(transferId, false, { error: code, stage: 'Download failed' });
              throw err;
            }
            return self.command('fs.read', { id: item.id || item.key || item.fileId }).then(function (msg) {
              var payload = payloadRoot(msg);
              var data = textFromPayload(payload);
              triggerSave(data);
              if (transferId && self.finalizeTransfer) self.finalizeTransfer(transferId, true, { progress: 100, stage: 'Saved to browser download manager' });
            }).catch(function (fallbackErr) {
              if (transferId && self.finalizeTransfer) self.finalizeTransfer(transferId, false, { error: (fallbackErr && fallbackErr.message) || code, stage: 'Download failed' });
              throw fallbackErr || err;
            });
          });
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
        if (!win) return Promise.resolve();
        return this.downloadFileEntry({ id: (win.meta || {}).fileId, name: (win.meta || {}).fileName || win.title, mime: (win.meta || {}).mime || ((win.fileView || {}).mime || '') }, '');
      },
      openTextViewerWindow: function (item) {
        var id = nextWindowId(this, 'win-text');
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
          meta: { fileId: item.id || item.key || '', mime: item.mime || 'text/plain', fileName: item.name || item.title || 'Text file' },
          fileView: { loading: true, content: '', mime: item.mime || 'text/plain' }
        };
        this.windows.push(win);
        this.focusWindow(id);
        if (!this.command) return;
        this.command('fs.read.range', { id: item.id || item.key || item.fileId, offset: 0, size: +((((this.boot || {}).vfs || {}).readWindowBytes) || 32768) }).then(function (msg) {
          var payload = payloadRoot(msg);
          win.fileView.loading = false;
          win.fileView.content = appendTruncationNotice(textFromPayload(payload), payload);
          win.fileView.mime = payload.mime || win.fileView.mime;
        }).catch(function () {
          return this.command('fs.read', { id: item.id || item.key || item.fileId }).then(function (msg) {
            var payload = payloadRoot(msg);
            win.fileView.loading = false;
            win.fileView.content = textFromPayload(payload);
            win.fileView.mime = payload.mime || win.fileView.mime;
          });
        }.bind(this)).catch(function (err) {
          win.fileView.loading = false;
          win.fileView.content = (err && err.message) || 'Unable to open file.';
        });
      },
      openImageViewerWindow: function (item) {
        var id = nextWindowId(this, 'win-image');
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
          meta: { fileId: item.id || item.key || '', mime: item.mime || 'image/*', fileName: item.name || item.title || 'Image file' },
          fileView: { loading: true, content: '', mime: item.mime || 'image/*' }
        };
        this.windows.push(win);
        this.focusWindow(id);
        var self = this;
        this.command('fs.read', { id: item.id || item.key || item.fileId }).then(function (msg) { var payload = payloadRoot(msg); win.fileView.loading = false; win.fileView.mime = payload.mime || win.fileView.mime; win.fileView.content = self.fsReadPayloadObjectUrl ? self.fsReadPayloadObjectUrl(payload.content || '', win.fileView.mime, payload.encoding || '') : (payload.content || ''); }).catch(function () { win.fileView.loading = false; win.fileView.content = buildFsBlobUrl(this, item, { inline: true, forceHttp: true }); if (!win.fileView.content) win.fileView.error = 'Unable to open image.'; }.bind(this));
      },
      openMediaViewerWindow: function (item) {
        var mediaKind = detectVideoLike(item) ? 'video' : 'audio';
        var id = nextWindowId(this, 'win-media');
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
          meta: { fileId: item.id || item.key || '', mime: item.mime || (mediaKind + '/*'), fileName: item.name || item.title || 'Media file', mediaKind: mediaKind },
          fileView: { loading: true, content: '', mime: item.mime || (mediaKind + '/*'), mediaKind: mediaKind }
        };
        this.windows.push(win);
        this.focusWindow(id);
        var self = this;
        this.command('fs.read', { id: item.id || item.key || item.fileId }).then(function (msg) { var payload = payloadRoot(msg); win.fileView.loading = false; win.fileView.mime = payload.mime || win.fileView.mime; win.fileView.content = self.fsReadPayloadObjectUrl ? self.fsReadPayloadObjectUrl(payload.content || '', win.fileView.mime, payload.encoding || '') : (payload.content || ''); }).catch(function () { win.fileView.loading = false; win.fileView.content = buildFsBlobUrl(this, item, { inline: true, stream: 'media', forceHttp: true }); if (!win.fileView.content) win.fileView.error = 'Unable to open media.'; }.bind(this));
      },
      openPdfViewerWindow: function (item) {
        var id = nextWindowId(this, 'win-pdf');
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
          meta: { fileId: item.id || item.key || '', mime: item.mime || 'application/pdf', fileName: item.name || item.title || 'PDF file' },
          fileView: { loading: true, content: '', mime: item.mime || 'application/pdf' }
        };
        this.windows.push(win);
        this.focusWindow(id);
        var self = this;
        this.command('fs.read', { id: item.id || item.key || item.fileId }).then(function (msg) { var payload = payloadRoot(msg); win.fileView.loading = false; win.fileView.mime = payload.mime || win.fileView.mime; win.fileView.content = self.fsReadPayloadObjectUrl ? self.fsReadPayloadObjectUrl(payload.content || '', win.fileView.mime, payload.encoding || '') : (payload.content || ''); }).catch(function () { win.fileView.loading = false; win.fileView.content = buildFsBlobUrl(this, item, { inline: true, forceHttp: true }); if (!win.fileView.content) win.fileView.error = 'Unable to open PDF.'; }.bind(this));
      },
      openStructuredViewerWindow: function (item) {
        var id = nextWindowId(this, 'win-structured');
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
          meta: { fileId: item.id || item.key || '', mime: item.mime || 'text/plain', fileName: item.name || item.title || 'Structured file' },
          fileView: { loading: true, content: '', mime: item.mime || 'text/plain' }
        };
        this.windows.push(win);
        this.focusWindow(id);
        if (!this.command) return;
        this.command('fs.read.range', { id: item.id || item.key || item.fileId, offset: 0, size: +((((this.boot || {}).vfs || {}).readWindowBytes) || 32768) }).then(function (msg) {
          var payload = payloadRoot(msg);
          var raw = textFromPayload(payload);
          win.fileView.loading = false;
          win.fileView.mime = payload.mime || win.fileView.mime;
          win.fileView.content = appendTruncationNotice(normalizeStructuredContent(raw, win.fileView.mime), payload);
        }).catch(function () {
          return this.command('fs.read', { id: item.id || item.key || item.fileId }).then(function (msg) {
            var payload = payloadRoot(msg);
            var raw = textFromPayload(payload);
            win.fileView.loading = false;
            win.fileView.mime = payload.mime || win.fileView.mime;
            win.fileView.content = normalizeStructuredContent(raw, win.fileView.mime);
          });
        }.bind(this)).catch(function (err) {
          win.fileView.loading = false;
          win.fileView.content = (err && err.message) || 'Unable to open file.';
        });
      }
    }
  };
})();
