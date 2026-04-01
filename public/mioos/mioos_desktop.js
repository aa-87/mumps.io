(function () {
  if (!window.Vue || !window.Vue.createApp) return;

  function deepClone(value) {
    return JSON.parse(JSON.stringify(value || {}));
  }

  var app = window.Vue.createApp({
    data: function () {
      return {
        boot: {},
        view: { summary: {}, documents: [], controlPanel: [], terminal: {} },
        desktopEntries: [],
        windows: [],
        activeWindowId: '',
        menuOpen: false,
        menuFilter: '',
        socket: null,
        socketConnected: false,
        clockText: '',
        alertTitle: '',
        alertMessage: '',
        zCounter: 10,
        dragState: {
          active: false,
          windowId: '',
          startX: 0,
          startY: 0,
          left: 0,
          top: 0
        },
        clockTimer: null,
        pingTimer: null,
        profile: 'dev'
      };
    },
    computed: {
      visibleWindows: function () {
        return this.windows
          .filter(function (win) { return win.state !== 'closed' && win.state !== 'minimized'; })
          .sort(function (a, b) { return (a.z || 0) - (b.z || 0); });
      },
      taskbarWindows: function () {
        return this.windows.filter(function (win) { return win.state !== 'closed'; });
      },
      filteredEntries: function () {
        var needle = (this.menuFilter || '').trim().toLowerCase();
        if (!needle) return this.desktopEntries;
        return this.desktopEntries.filter(function (entry) {
          var hay = ((entry.title || '') + ' ' + (entry.subtitle || '')).toLowerCase();
          return hay.indexOf(needle) !== -1;
        });
      }
    },
    mounted: function () {
      this.bootstrapFromDom();
      this.startClock();
      this.refreshView();
      this.initSocket();
      this._dragMove = this.onDragMove.bind(this);
      this._dragEnd = this.endDrag.bind(this);
      window.addEventListener('mousemove', this._dragMove);
      window.addEventListener('mouseup', this._dragEnd);
    },
    beforeUnmount: function () {
      if (this.clockTimer) window.clearInterval(this.clockTimer);
      if (this.pingTimer) window.clearInterval(this.pingTimer);
      if (this.socket) this.socket.close();
      window.removeEventListener('mousemove', this._dragMove);
      window.removeEventListener('mouseup', this._dragEnd);
    },
    methods: {
      bootstrapFromDom: function () {
        var node = document.getElementById('mioosBootJson');
        if (!node) return;
        try {
          this.boot = JSON.parse(node.textContent || '{}');
        } catch (err) {
          this.showAlert('Boot error', 'Unable to parse the server boot contract.');
          this.boot = {};
        }
        this.profile = ((this.boot.product || {}).profile) || 'dev';
        this.desktopEntries = deepClone(this.boot.apps || []);
        this.windows = deepClone(this.boot.windows || []);
        this.zCounter = this.windows.reduce(function (max, win) { return Math.max(max, win.z || 0); }, 10) + 1;
        if (this.windows.length) this.activeWindowId = this.windows[0].id;
      },
      startClock: function () {
        var self = this;
        function tick() {
          var now = new Date();
          self.clockText = now.toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' });
        }
        tick();
        this.clockTimer = window.setInterval(tick, 1000);
      },
      initSocket: function () {
        var self = this;
        var path = (((this.boot || {}).routes || {}).websocket) || document.getElementById('mioosRoot').dataset.mioosWs;
        if (!path || !window.WebSocket) return;
        var protocol = window.location.protocol === 'https:' ? 'wss://' : 'ws://';
        try {
          this.socket = new window.WebSocket(protocol + window.location.host + path);
        } catch (err) {
          this.showAlert('Socket error', 'Unable to open the primary websocket.');
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
          this.view = msg.view;
          return;
        }
        if (msg.event === 'error') {
          this.showAlert('Shell event error', msg.detail || msg.error || 'Unsupported shell event.');
        }
      },
      sendSocket: function (payload) {
        if (!this.socket || this.socket.readyState !== 1) return;
        this.socket.send(JSON.stringify(payload));
      },
      refreshView: function () {
        var self = this;
        var path = (((this.boot || {}).routes || {}).view) || document.getElementById('mioosRoot').dataset.mioosView;
        if (!path || !window.fetch) return;
        window.fetch(path, { headers: { Accept: 'application/json' } })
          .then(function (resp) { return resp.json(); })
          .then(function (json) {
            self.view = json || {};
          })
          .catch(function () {
            self.showAlert('View refresh failed', 'The shell view model could not be refreshed.');
          });
      },
      showAlert: function (title, message) {
        this.alertTitle = title;
        this.alertMessage = message;
      },
      dismissAlert: function () {
        this.alertTitle = '';
        this.alertMessage = '';
      },
      appIcon: function (appKey) {
        var entry = this.desktopEntries.find(function (item) { return item.key === appKey; });
        return entry ? entry.icon : '□';
      },
      openApp: function (appKey) {
        var win = this.windows.find(function (item) { return item.appKey === appKey; });
        if (!win) return;
        this.menuOpen = false;
        if (win.state === 'closed' || win.state === 'minimized') {
          win.state = 'normal';
        }
        this.focusWindow(win.id);
        this.sendSocket({ event: 'shell.open', appKey: appKey });
      },
      focusWindow: function (windowId) {
        var win = this.windows.find(function (item) { return item.id === windowId; });
        if (!win) return;
        this.zCounter += 1;
        win.z = this.zCounter;
        this.activeWindowId = windowId;
      },
      minimizeWindow: function (windowId) {
        var win = this.windows.find(function (item) { return item.id === windowId; });
        if (!win) return;
        win.state = 'minimized';
        if (this.activeWindowId === windowId) this.activeWindowId = '';
      },
      closeWindow: function (windowId) {
        var win = this.windows.find(function (item) { return item.id === windowId; });
        if (!win) return;
        win.state = 'closed';
        if (this.activeWindowId === windowId) this.activeWindowId = '';
      },
      taskbarToggle: function (windowId) {
        var win = this.windows.find(function (item) { return item.id === windowId; });
        if (!win) return;
        if (win.state === 'minimized' || win.state === 'closed') {
          win.state = 'normal';
          this.focusWindow(windowId);
          return;
        }
        if (this.activeWindowId === windowId) {
          this.minimizeWindow(windowId);
        } else {
          this.focusWindow(windowId);
        }
      },
      toggleMaximize: function (windowId) {
        var win = this.windows.find(function (item) { return item.id === windowId; });
        if (!win) return;
        if (win.state === 'maximized') {
          if (win.restore) {
            win.left = win.restore.left;
            win.top = win.restore.top;
            win.width = win.restore.width;
            win.height = win.restore.height;
          }
          win.state = 'normal';
          return;
        }
        win.restore = { left: win.left, top: win.top, width: win.width, height: win.height };
        win.left = 0;
        win.top = 0;
        win.width = window.innerWidth;
        win.height = window.innerHeight - 40;
        win.state = 'maximized';
        this.focusWindow(windowId);
      },
      toggleMenu: function () {
        this.menuOpen = !this.menuOpen;
      },
      windowClass: function (win) {
        return {
          'is-active': this.activeWindowId === win.id,
          'is-maximized': win.state === 'maximized'
        };
      },
      windowStyle: function (win) {
        return {
          left: (win.left || 0) + 'px',
          top: (win.top || 0) + 'px',
          width: (win.width || 600) + 'px',
          height: (win.height || 420) + 'px',
          zIndex: (win.z || 1)
        };
      },
      beginDrag: function (win, event) {
        if (win.state === 'maximized') return;
        this.focusWindow(win.id);
        this.dragState.active = true;
        this.dragState.windowId = win.id;
        this.dragState.startX = event.clientX;
        this.dragState.startY = event.clientY;
        this.dragState.left = win.left || 0;
        this.dragState.top = win.top || 0;
      },
      onDragMove: function (event) {
        if (!this.dragState.active) return;
        var win = this.windows.find(function (item) { return item.id === this.dragState.windowId; }, this);
        if (!win) return;
        win.left = this.dragState.left + (event.clientX - this.dragState.startX);
        win.top = this.dragState.top + (event.clientY - this.dragState.startY);
      },
      endDrag: function () {
        this.dragState.active = false;
        this.dragState.windowId = '';
      }
    }
  });

  app.config.compilerOptions.delimiters = ['[[', ']]'];
  app.mount('#mioosRoot');
})();
