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
        var path = (this.boot.routes || {}).websocket || (root ? root.dataset.mioosWs : '');
        if (!path || !window.WebSocket) return;
        var protocol = window.location.protocol === 'https:' ? 'wss://' : 'ws://';
        try {
          this.socket = new window.WebSocket(protocol + window.location.host + path);
        } catch (err) {
          this.showAlert(this.t('alerts.socketError.title'), this.t('alerts.socketError.message'));
          return;
        }
        this.socket.addEventListener('open', function () {
          self.socketConnected = true;
          self.sendSocket({ event: 'hello' });
          if (self.pingTimer) window.clearInterval(self.pingTimer);
          self.pingTimer = window.setInterval(function () {
            self.sendSocket({ event: 'ping' });
          }, 15000);
        });
        this.socket.addEventListener('close', function () {
          self.socketConnected = false;
          if (self.pingTimer) window.clearInterval(self.pingTimer);
          rejectPending(self.socketPending || {}, 'socket_closed');
        });
        this.socket.addEventListener('message', function (evt) {
          self.handleSocketMessage(evt.data);
        });
      },
      ensureSocketReady: function (timeoutMs) {
        var self = this;
        var waitMs = Number(timeoutMs || 5000) || 5000;
        if (this.socket && this.socket.readyState === 1) return Promise.resolve(true);
        this.initSocket();
        return new Promise(function (resolve, reject) {
          var stopAt = Date.now() + waitMs;
          (function waitForSocket() {
            if (self.socket && self.socket.readyState === 1) return resolve(true);
            if (Date.now() >= stopAt) return reject(new Error('socket_timeout'));
            window.setTimeout(waitForSocket, 75);
          })();
        });
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
        if (!this.socket || this.socket.readyState !== 1) return false;
        this.socket.send(JSON.stringify(payload));
        return true;
      },
      socketRequest: function (eventName, payload, options) {
        var self = this;
        var opts = options || {};
        var key = opts.dedupeKey || ((opts.command || eventName || 'socket.request') + '|' + JSON.stringify(payload || {}));
        var timeoutMs = Number(opts.timeoutMs || 8000) || 8000;
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
                reject(new Error('socket_request_timeout'));
              }, timeoutMs);
              self.socketPending[requestId] = pending;
              if (!self.sendSocket(Object.assign({}, payload || {}, {
                event: eventName,
                requestId: requestId
              }))) {
                if (pending.timer) window.clearTimeout(pending.timer);
                delete self.socketPending[requestId];
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
        var root = window.MIOOSState.getRootNode();
        var path = (this.boot.routes || {}).view || (root ? root.dataset.mioosView : '');
        if (!path || !window.fetch) return;
        window.fetch(path, { headers: { Accept: 'application/json' }, credentials: 'same-origin' })
          .then(function (resp) { return resp.json(); })
          .then(function (json) {
            self.view = window.MIOOSState.normalizeView(json || {});
          })
          .catch(function () {
            self.showAlert(self.t('alerts.viewRefreshFailed.title'), self.t('alerts.viewRefreshFailed.message'));
          });
      }
    }
  };
})();
