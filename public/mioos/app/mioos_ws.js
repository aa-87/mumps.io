(function () {
  function rejectPending(map, message) {
    Object.keys(map || {}).forEach(function (requestId) {
      var pending = map[requestId];
      if (!pending) return;
      if (pending.timer) window.clearTimeout(pending.timer);
      try {
        pending.reject(new Error(message || 'socket_closed'));
      } catch (err) {}
      delete map[requestId];
    });
  }

  window.MIOOSWSClient = {
    methods: {
      initSocket: function () {
        var self = this;
        var root = window.MIOOSState.getRootNode();
        if (this.requiresSignin) return Promise.reject(new Error('login_required'));
        var path = (this.boot.routes || {}).websocket || (root ? root.dataset.mioosWs : '');
        var protocol = window.location.protocol === 'https:' ? 'wss://' : 'ws://';
        var waitMs = Number((((this.boot || {}).websocket || {}).requestTimeoutMs) || 15000) || 15000;
        if (!path || !window.WebSocket) return Promise.reject(new Error('socket_unavailable'));
        if (this.socket && this.socket.readyState === 1) return Promise.resolve(this.socket);
        if (this.socketOpenPromise) return this.socketOpenPromise;
        this.socketOpenPromise = new Promise(function (resolve, reject) {
          var sock;
          var socketId = 'core-1';
          var settled = false;
          var timer = window.setTimeout(function () {
            if (settled) return;
            settled = true;
            self.socketOpenPromise = null;
            try { if (sock) sock.close(); } catch (err) {}
            reject(new Error('socket_timeout'));
          }, waitMs);
          try {
            sock = new window.WebSocket(protocol + window.location.host + path);
            self.socket = sock;
            if (self.setSocketTelemetry) self.setSocketTelemetry(socketId, { role: 'core', ordinal: 1, label: 'Core Socket', state: 'connecting', openedAt: 0, helloAt: 0, lastMessageAt: 0, lastEvent: 'connect', lastError: '' });
          } catch (err) {
            window.clearTimeout(timer);
            self.socketOpenPromise = null;
            if (self.showAlert) self.showAlert(self.t ? self.t('alerts.socketError.title') : 'Socket Error', self.t ? self.t('alerts.socketError.message') : 'Unable to connect');
            reject(err);
            return;
          }
          sock.addEventListener('open', function () {
            self.socketConnected = true;
            if (self.setSocketTelemetry) self.setSocketTelemetry(socketId, { state: 'open', openedAt: Date.now(), lastEvent: 'open', lastError: '' });
            try { sock.send(JSON.stringify({ event: 'hello' })); } catch (err) {}
            if (self.pingTimer) window.clearInterval(self.pingTimer);
            self.pingTimer = window.setInterval(function () {
              self.sendSocket({ event: 'ping' });
            }, 15000);
            if (!settled) {
              settled = true;
              window.clearTimeout(timer);
              resolve(sock);
            }
          });
          sock.addEventListener('close', function () {
            self.socketConnected = false;
            if (self.setSocketTelemetry) self.setSocketTelemetry(socketId, { state: 'closed', lastEvent: 'close', lastError: 'socket_closed', lastMessageAt: Date.now(), pendingCount: 0 });
            if (self.pingTimer) window.clearInterval(self.pingTimer);
            if (self.socket === sock) self.socket = null;
            self.socketOpenPromise = null;
            rejectPending(self.socketPending || {}, 'socket_closed');
            if (!settled) {
              settled = true;
              window.clearTimeout(timer);
              reject(new Error('socket_closed'));
            }
          });
          sock.addEventListener('error', function () {
            if (self.setSocketTelemetry) self.setSocketTelemetry(socketId, { state: 'error', lastEvent: 'error', lastError: 'socket_error', lastMessageAt: Date.now() });
            if (!settled) {
              settled = true;
              window.clearTimeout(timer);
              self.socketOpenPromise = null;
              reject(new Error('socket_error'));
            }
          });
          sock.addEventListener('message', function (evt) {
            self.handleSocketMessage(evt.data);
          });
        });
        return this.socketOpenPromise;
      },
      ensureSocketReady: function (timeoutMs) {
        var self = this;
        var waitMs = Number(timeoutMs || ((((this.boot || {}).websocket || {}).requestTimeoutMs) || 15000)) || 15000;
        if (this.requiresSignin) return Promise.reject(new Error('login_required'));
        if (this.socket && this.socket.readyState === 1) return Promise.resolve(true);
        return self.initSocket().then(function () { return true; });
      },
      handleSocketMessage: function (raw) {
        var msg;
        var requestId;
        var pending;
        try {
          msg = JSON.parse(raw);
        } catch (err) {
          return;
        }
        if (this.setSocketTelemetry) this.setSocketTelemetry('core-1', { lastMessageAt: Date.now(), lastEvent: msg.event || 'message', lastError: (msg.event === ((this.boot.routes || {}).commandErrorEvent || 'desktop.error')) ? (msg.detail || msg.error || 'desktop.error') : '' });
        if (this.pushDebugEvent) this.pushDebugEvent('socket.message', msg.event || 'message', msg.command || msg.detail || '', { requestId: msg.requestId || '', ok: msg.ok, source: 'core' });
        if (msg.event === 'hello' && this.setSocketTelemetry) this.setSocketTelemetry('core-1', { helloAt: Date.now(), state: 'ready', lastEvent: 'hello' });
        if (msg.event === 'pong' && this.setSocketTelemetry) this.setSocketTelemetry('core-1', { lastEvent: 'pong' });
        if (msg.event === 'view.refresh' && msg.view) {
          this.view = window.MIOOSState.normalizeView(msg.view);
          return;
        }
        requestId = msg.requestId || '';
        if (msg.event === (this.boot.routes.commandResultEvent || 'desktop.result')) {
          pending = (this.socketPending || {})[requestId];
          if (pending) {
            if (pending.timer) window.clearTimeout(pending.timer);
            delete this.socketPending[requestId];
            if (this.setSocketTelemetry) this.setSocketTelemetry('core-1', { pendingCount: Object.keys(this.socketPending || {}).length });
            pending.resolve(msg);
            return;
          }
          if (this.handleTerminalCommandResult) this.handleTerminalCommandResult(msg);
          return;
        }
        if (msg.event === (this.boot.routes.commandErrorEvent || 'desktop.error')) {
          pending = (this.socketPending || {})[requestId];
          if (pending) {
            if (pending.timer) window.clearTimeout(pending.timer);
            delete this.socketPending[requestId];
            if (this.setSocketTelemetry) this.setSocketTelemetry('core-1', { pendingCount: Object.keys(this.socketPending || {}).length, lastError: msg.detail || msg.error || 'desktop.error' });
            pending.reject(msg);
            return;
          }
          if (this.handleTerminalCommandError && this.handleTerminalCommandError(msg)) return;
          this.showAlert(this.t('alerts.shellEventError.title'), msg.detail || msg.error || this.t('alerts.shellEventError.message'));
          return;
        }
        if (msg.event === 'error') {
          this.showAlert(this.t('alerts.shellEventError.title'), msg.detail || msg.error || this.t('alerts.shellEventError.message'));
        }
      },
      sendSocket: function (payload) {
        if (this.requiresSignin) return false;
        if (!this.socket || this.socket.readyState !== 1) return false;
        this.socket.send(JSON.stringify(payload));
        return true;
      },
      socketRequest: function (eventName, payload, options) {
        var self = this;
        var opts = options || {};
        var key = opts.dedupeKey || ((opts.command || eventName || 'socket.request') + '|' + JSON.stringify(payload || {}));
        var timeoutMs = Number(opts.timeoutMs || ((((this.boot || {}).websocket || {}).requestTimeoutMs) || 15000)) || 15000;
        if (this.pendingCommands[key]) return this.pendingCommands[key];
        var requestId = 'ws-' + (++this.socketRequestSeq) + '-' + Date.now();
        var req = this.ensureSocketReady(timeoutMs)
          .then(function () {
            return new Promise(function (resolve, reject) {
              var pending = {
                timer: null,
                resolve: resolve,
                reject: reject
              };
              pending.timer = window.setTimeout(function () {
                if (self.socketPending[requestId]) delete self.socketPending[requestId];
                if (self.setSocketTelemetry) self.setSocketTelemetry('core-1', { pendingCount: Object.keys(self.socketPending || {}).length, lastError: 'socket_request_timeout', lastEvent: 'timeout' });
                reject(new Error('socket_request_timeout'));
              }, timeoutMs);
              self.socketPending[requestId] = pending;
              if (self.setSocketTelemetry) self.setSocketTelemetry('core-1', { pendingCount: Object.keys(self.socketPending || {}).length, lastEvent: 'request:' + (opts.command || eventName || 'socket') });
              if (self.pushDebugEvent) self.pushDebugEvent('socket.request', opts.command || eventName || 'socket.request', JSON.stringify(payload || {}), { requestId: requestId, source: 'core' });
              if (!self.sendSocket(Object.assign({}, payload || {}, {
                event: eventName,
                requestId: requestId
              }))) {
                if (pending.timer) window.clearTimeout(pending.timer);
                delete self.socketPending[requestId];
                if (self.setSocketTelemetry) self.setSocketTelemetry('core-1', { pendingCount: Object.keys(self.socketPending || {}).length, lastError: 'socket_send_failed', lastEvent: 'send_failed' });
                reject(new Error('socket_send_failed'));
              }
            });
          })
          .finally(function () {
            delete self.pendingCommands[key];
          });
        this.pendingCommands[key] = req;
        return req;
      },
      command: function (command, payload) {
        var eventName = (this.boot.routes || {}).commandEvent || 'desktop.command';
        var body = Object.assign({ command: command }, payload || {});
        var key = command + '|' + JSON.stringify(body);
        return this.socketRequest(eventName, body, { command: command, dedupeKey: key });
      },
      sendCommand: function (command, payload) {
        var requestId = 'cmd-' + (++this.commandSeq);
        var body = Object.assign({}, payload || {}, {
          event: (this.boot.routes || {}).commandEvent || 'desktop.command',
          requestId: requestId,
          command: command
        });
        if (!this.sendSocket(body)) return '';
        return requestId;
      },
      refreshView: function () {
        var self = this;
        if (this.requiresSignin) return Promise.resolve();
        return this.socketRequest((this.boot.routes || {}).commandEvent || 'desktop.command', {
          command: 'view.refresh'
        }, {
          command: 'view.refresh',
          dedupeKey: 'view.refresh',
          timeoutMs: Number((((this.boot || {}).websocket || {}).requestTimeoutMs) || 15000) || 15000
        })
          .then(function (msg) {
            var view = (msg && msg.view) ? msg.view : {};
            self.view = window.MIOOSState.normalizeView(view || {});
            return self.view;
          })
          .catch(function (err) {
            self.showAlert(self.t('alerts.viewRefreshFailed.title'), (err && (err.detail || err.error || err.message)) || self.t('alerts.viewRefreshFailed.message'));
            throw err;
          });
      }
    }
  };
})();
