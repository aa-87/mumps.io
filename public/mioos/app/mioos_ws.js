(function () {
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
          self.pingTimer = window.setInterval(function () {
            self.sendSocket({ event: 'ping' });
          }, 15000);
        });
        this.socket.addEventListener('close', function () {
          self.socketConnected = false;
          if (self.pingTimer) window.clearInterval(self.pingTimer);
        });
        this.socket.addEventListener('message', function (evt) {
          self.handleSocketMessage(evt.data);
        });
      },
      handleSocketMessage: function (raw) {
        var msg;
        try {
          msg = JSON.parse(raw);
        } catch (err) {
          return;
        }
        if (msg.event === 'view.refresh' && msg.view) {
          this.view = window.MIOOSState.normalizeView(msg.view);
          return;
        }
        if (msg.event === 'error') {
          this.showAlert(this.t('alerts.shellEventError.title'), msg.detail || msg.error || this.t('alerts.shellEventError.message'));
        }
      },
      sendSocket: function (payload) {
        if (!this.socket || this.socket.readyState !== 1) return;
        this.socket.send(JSON.stringify(payload));
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
