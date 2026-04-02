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
      }
    }
  };
})();
