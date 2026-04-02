(function () {
  function buildPayload(kind, payload) {
    var body = Object.assign({}, payload || {});
    body.event = kind;
    return body;
  }

  function transferPath(vm) {
    return (((vm || {}).boot || {}).routes || {}).transferWebsocket || (((vm || {}).boot || {}).transfer || {}).websocketPath || '/ws/mioos/transfer';
  }

  function transferUrl(vm) {
    var protocol = window.location.protocol === 'https:' ? 'wss://' : 'ws://';
    return protocol + window.location.host + transferPath(vm);
  }

  function createSocket(vm) {
    return new window.WebSocket(transferUrl(vm));
  }

  function waitOpen(socket, timeoutMs) {
    return new Promise(function (resolve, reject) {
      var done = false;
      var timer = window.setTimeout(function () {
        if (done) return;
        done = true;
        reject(new Error('transfer_open_timeout'));
      }, Number(timeoutMs || 10000) || 10000);
      function finish(fn, value) {
        if (done) return;
        done = true;
        window.clearTimeout(timer);
        try { socket.removeEventListener('open', onOpen); } catch (err) {}
        try { socket.removeEventListener('error', onError); } catch (err) {}
        fn(value);
      }
      function onOpen() { finish(resolve, socket); }
      function onError() { finish(reject, new Error('socket_closed')); }
      if (socket.readyState === 1) return finish(resolve, socket);
      socket.addEventListener('open', onOpen, { once: true });
      socket.addEventListener('error', onError, { once: true });
    });
  }

  function request(socket, eventName, payload, timeoutMs) {
    return new Promise(function (resolve, reject) {
      var requestId = 'trx-' + Date.now() + '-' + Math.floor(Math.random() * 1000000);
      var done = false;
      var timer = window.setTimeout(function () {
        if (done) return;
        done = true;
        try { socket.removeEventListener('message', onMessage); } catch (err) {}
        reject(new Error('transfer_timeout'));
      }, Number(timeoutMs || 15000) || 15000);
      function finish(fn, value) {
        if (done) return;
        done = true;
        window.clearTimeout(timer);
        try { socket.removeEventListener('message', onMessage); } catch (err) {}
        fn(value);
      }
      function onMessage(evt) {
        var msg;
        try { msg = JSON.parse(evt.data); } catch (err) { return; }
        if ((msg.requestId || '') !== requestId) return;
        if (msg.ok === 1) finish(resolve, msg);
        else finish(reject, new Error(msg.error || msg.detail || 'transfer_error'));
      }
      socket.addEventListener('message', onMessage);
      try {
        socket.send(JSON.stringify(Object.assign({}, payload || {}, { event: eventName, requestId: requestId })));
      } catch (err) {
        finish(reject, err);
      }
    });
  }

  function decodeDataUrl(dataUrl) {
    var match, mime, data, binary, i, out;
    match = /^data:([^;,]+)?(;base64)?,(.*)$/i.exec(String(dataUrl || ''));
    if (!match) return null;
    mime = match[1] || 'application/octet-stream';
    data = match[3] || '';
    if (match[2]) {
      binary = window.atob(data);
      out = new Uint8Array(binary.length);
      for (i = 0; i < binary.length; i += 1) out[i] = binary.charCodeAt(i) & 255;
      return { mime: mime, bytes: out };
    }
    return { mime: mime, text: decodeURIComponent(data) };
  }



  function transferGlyph(direction, state) {
    if (state === 'failed') return '⚠';
    if (direction === 'download') return '↓';
    return '↑';
  }

  function ensureTransferScaffold(vm) {
    var hasApp, hasWindow;
    if (!vm.launcherEntries) vm.launcherEntries = [];
    hasApp = vm.launcherEntries.some(function (entry) { return entry.key === 'transfers'; });
    if (!hasApp) {
      vm.launcherEntries.push({ key: 'transfers', icon: '⇅', title: 'Transfers', subtitle: 'Active uploads and downloads', kind: 'system' });
    }
    if (!vm.windows) vm.windows = [];
    hasWindow = vm.windows.some(function (win) { return win.appKey === 'transfers'; });
    if (!hasWindow) {
      vm.windows.push({ id: 'win-transfers', appKey: 'transfers', title: 'Transfers', left: 220, top: 120, width: 560, height: 360, state: 'closed', z: ((vm.zCounter || 10) + 1) });
    }
    if (!Array.isArray(vm.transferItems)) vm.transferItems = [];
  }

  function touchTransfer(vm, meta) {
    var item, now;
    ensureTransferScaffold(vm);
    now = Date.now();
    item = (vm.transferItems || []).find(function (entry) { return entry.id === meta.id; });
    if (!item) {
      item = { id: meta.id, name: meta.name || 'Transfer', direction: meta.direction || 'upload', stage: meta.stage || 'Queued', progress: Number(meta.progress || 0) || 0, active: meta.active !== false, failed: !!meta.failed, complete: !!meta.complete, bytesDone: Number(meta.bytesDone || 0) || 0, sizeBytes: Number(meta.sizeBytes || 0) || 0, workerCount: Number(meta.workerCount || 1) || 1, updatedAt: now, glyph: transferGlyph(meta.direction || 'upload', meta.failed ? 'failed' : (meta.complete ? 'complete' : 'active')) };
      vm.transferItems.unshift(item);
    }
    Object.assign(item, meta || {});
    item.active = meta.active !== false;
    item.failed = !!meta.failed;
    item.complete = !!meta.complete;
    item.updatedAt = now;
    item.glyph = transferGlyph(item.direction, item.failed ? 'failed' : (item.complete ? 'complete' : 'active'));
    return item;
  }

  function triggerDownload(name, mime, joined) {
    var a, blob, url, parsed;
    parsed = decodeDataUrl(joined);
    if (parsed && parsed.bytes) blob = new Blob([parsed.bytes], { type: parsed.mime || mime || 'application/octet-stream' });
    else if (parsed && Object.prototype.hasOwnProperty.call(parsed, 'text')) blob = new Blob([parsed.text], { type: parsed.mime || mime || 'text/plain' });
    else blob = new Blob([String(joined || '')], { type: mime || 'application/octet-stream' });
    url = window.URL.createObjectURL(blob);
    a = document.createElement('a');
    a.href = url;
    a.download = name || 'download';
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    window.setTimeout(function () { window.URL.revokeObjectURL(url); }, 1000);
  }

  function downloadWithWorkers(vm, spec, state) {
    var helpers = (window.MIOOSTransfer && window.MIOOSTransfer.helpers) || {};
    var createSocket = helpers.createSocket;
    var waitOpen = helpers.waitOpen;
    var request = helpers.request;
    var bootTransfer = (((vm || {}).boot || {}).transfer || {});
    if (!createSocket || !waitOpen || !request) return Promise.reject(new Error('transfer_helpers_missing'));
    return new Promise(function (resolve, reject) {
      var coordinator = createSocket(vm);
      var sockets = [];
      var transferId = '';
      var chunkSize = Math.max(1024, Math.min(32768, +(bootTransfer.chunkSize || 24576)));
      var workerCount = Math.max(1, Math.min(7, +(bootTransfer.downloadWorkers || 2)));
      var chunkTotal = 0;
      var completed = 0;
      var nextIndex = 1;
      var pieces = [];
      var failed = false;
      function setProgress(stage) {
        var progress;
        progress = chunkTotal > 0 ? Math.min(100, Math.round((completed / chunkTotal) * 100)) : 0;
        if (!state) return;
        state.download = {
          active: true,
          name: spec.name || 'Download',
          stage: stage || 'Downloading',
          progress: progress
        };
        if (vm && vm.transferBeginOrUpdate) {
          vm.transferBeginOrUpdate({ id: transferId || ('download-' + (spec.id || spec.name || 'file')), direction: 'download', name: spec.name || 'Download', stage: stage || 'Downloading', progress: progress, active: true, complete: false, failed: false, sizeBytes: Number((spec && spec.sizeBytes) || 0) || 0, workerCount: workerCount || 1, bytesDone: completed * chunkSize });
        }
      }
      function cleanup() {
        sockets.forEach(function (socket) { try { socket.close(); } catch (err) {} });
        sockets = [];
        try { coordinator.close(); } catch (err) {}
      }
      function fail(err) {
        if (failed) return;
        failed = true;
        if (state) state.download = { active: false, name: spec.name || 'Download', stage: 'Failed', progress: chunkTotal > 0 ? Math.min(100, Math.round((completed / chunkTotal) * 100)) : 0, error: (err && err.message) || 'transfer_download_failed' };
        if (vm && vm.transferBeginOrUpdate) vm.transferBeginOrUpdate({ id: transferId || ('download-' + (spec.id || spec.name || 'file')), direction: 'download', name: spec.name || 'Download', stage: 'Failed', progress: chunkTotal > 0 ? Math.min(100, Math.round((completed / chunkTotal) * 100)) : 0, active: false, failed: true, complete: false, workerCount: workerCount || 1 });
        if (transferId) request(coordinator, 'transfer.download.abort', { transferId: transferId }, 10000).catch(function () {});
        cleanup();
        reject(err || new Error('transfer_download_failed'));
      }
      function nextChunk() {
        if (failed) return 0;
        if (nextIndex > chunkTotal) return 0;
        return nextIndex++;
      }
      function workerLoop(socket, workerId) {
        var idx = nextChunk();
        if (!idx) return Promise.resolve();
        return request(socket, 'transfer.download.chunk', { transferId: transferId, chunkIndex: idx, workerId: workerId }, 30000).then(function (msg) {
          var tr = (msg && (msg.transfer || msg.result || msg)) || {};
          pieces[idx - 1] = String(tr.data || '');
          completed += 1;
          setProgress('Downloading');
          return workerLoop(socket, workerId);
        });
      }
      function finishDownload(meta) {
        var joined = pieces.join('');
        triggerDownload((meta && meta.name) || spec.name, (meta && meta.mime) || spec.mime, joined);
        if (state) {
          state.download = { active: false, name: (meta && meta.name) || spec.name || 'Download', stage: 'Complete', progress: 100 };
          window.setTimeout(function () { if (state.download && state.download.progress === 100) state.download = null; }, 1200);
        }
        if (vm && vm.transferBeginOrUpdate) vm.transferBeginOrUpdate({ id: transferId || ('download-' + ((meta && meta.name) || spec.name || 'file')), direction: 'download', name: (meta && meta.name) || spec.name || 'Download', stage: 'Complete', progress: 100, active: false, complete: true, failed: false, workerCount: workerCount || 1 });
        cleanup();
        resolve({ ok: 1, transferId: transferId, name: (meta && meta.name) || spec.name });
      }
      waitOpen(coordinator, 10000).then(function () {
        setProgress('Starting');
        return request(coordinator, 'transfer.download.begin', { id: spec.id || '', path: spec.path || '' }, 15000);
      }).then(function (msg) {
        var tr = (msg && (msg.transfer || msg.result || msg)) || {};
        var opens = [];
        var i;
        transferId = tr.transferId || '';
        chunkSize = Math.max(1024, Math.min(32768, +(tr.chunkSize || chunkSize)));
        workerCount = Math.max(1, Math.min(7, +(tr.workerCount || workerCount)));
        chunkTotal = Math.max(0, +(tr.chunkTotal || 0));
        pieces = new Array(chunkTotal);
        if (chunkTotal < 1) {
          finishDownload(tr.meta || tr);
          return null;
        }
        setProgress('Downloading');
        for (i = 1; i <= workerCount; i += 1) {
          (function (workerNo) {
            var socket = createSocket(vm);
            sockets.push(socket);
            opens.push(waitOpen(socket, 10000).then(function () { return workerLoop(socket, 'd' + workerNo); }));
          })(i);
        }
        return Promise.all(opens).then(function () {
          return request(coordinator, 'transfer.download.end', { transferId: transferId }, 10000).then(function (endMsg) {
            var endTr = (endMsg && (endMsg.transfer || endMsg.result || endMsg)) || {};
            finishDownload(endTr.meta || tr.meta || tr);
          });
        });
      }).catch(fail);
    });
  }

window.MIOOSTransfer = {
    helpers: {
      buildPayload: buildPayload,
      path: transferPath,
      url: transferUrl,
      createSocket: createSocket,
      waitOpen: waitOpen,
      request: request
    },
    methods: {
      ensureTransferScaffold: function () {
        ensureTransferScaffold(this);
      },
      openTransferManager: function () {
        var win;
        ensureTransferScaffold(this);
        win = this.windows.find(function (entry) { return entry.appKey === 'transfers'; });
        if (!win) return;
        win.state = 'normal';
        if (this.focusWindow) this.focusWindow(win.id);
      },
      transferBeginOrUpdate: function (meta) {
        var item = touchTransfer(this, meta || {});
        if (item && item.active && this.openTransferManager) this.openTransferManager();
        return item;
      },
      transferClearCompleted: function () {
        this.transferItems = (this.transferItems || []).filter(function (item) { return item.active || item.failed; });
      },
      transferRetryPlaceholder: function () {
        if (this.showAlert) this.showAlert('Transfers', 'Retry/resume arrives in a later ROI.');
      },
      transferUploadBegin: function (payload) {
        return this.socketRequest('transfer.upload.begin', buildPayload('transfer.upload.begin', payload || {}), { command: 'transfer.upload.begin', dedupeKey: 'transfer.upload.begin|' + JSON.stringify(payload || {}), timeoutMs: 12000 });
      },
      transferUploadStatus: function (transferId) {
        return this.socketRequest('transfer.upload.status', { transferId: transferId }, { command: 'transfer.upload.status', dedupeKey: 'transfer.upload.status|' + String(transferId || ''), timeoutMs: 12000 });
      },
      transferDownloadBegin: function (payload) {
        return this.socketRequest('transfer.download.begin', buildPayload('transfer.download.begin', payload || {}), { command: 'transfer.download.begin', dedupeKey: 'transfer.download.begin|' + JSON.stringify(payload || {}), timeoutMs: 12000 });
      },
      transferDownloadStatus: function (transferId) {
        return this.socketRequest('transfer.download.status', { transferId: transferId }, { command: 'transfer.download.status', dedupeKey: 'transfer.download.status|' + String(transferId || ''), timeoutMs: 12000 });
      },
      transferActiveItems: function () {
        return (this.transferItems || []).filter(function (item) { return item.active; });
      },
      transferHistoryItems: function () {
        return (this.transferItems || []).filter(function (item) { return !item.active; });
      },
      transferDownloadFile: function (spec, state) {
        return downloadWithWorkers(this, spec || {}, state || null);
      }
    }
  };
})();
