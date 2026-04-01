(function () {
  window.MIOOSWM = {
    methods: {
      appIcon: function (appKey) {
        var entry = this.desktopEntries.find(function (item) { return item.key === appKey; });
        return entry ? entry.icon : '□';
      },
      openApp: function (appKey) {
        if (this.requiresSignin) {
          this.showAlert(this.t('alerts.signinRequired.title'), this.t('alerts.signinRequired.open'));
          return;
        }
        if (appKey === 'terminal' && this.createTerminalWindow) {
          this.menuOpen = false;
          this.createTerminalWindow();
          return;
        }
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
        if (win.appKey === 'terminal' && this.closeTerminalWindow) {
          this.closeTerminalWindow(windowId);
          return;
        }
        win.state = 'closed';
        if (this.activeWindowId === windowId) this.activeWindowId = '';
      },
      taskbarToggle: function (windowId) {
        var win = this.windows.find(function (item) { return item.id === windowId; });
        if (!win) return;
        if (this.requiresSignin) {
          this.showAlert(this.t('alerts.signinRequired.title'), this.t('alerts.signinRequired.use'));
          return;
        }
        if (win.state === 'minimized' || win.state === 'closed') {
          var wasTerminal = win.appKey === 'terminal';
          win.state = 'normal';
          this.focusWindow(windowId);
          if (wasTerminal) {
            var self = this;
            this.$nextTick(function () {
              if (self.mountTerminalWindow) self.mountTerminalWindow(windowId);
              if (self.requestTerminalOpen) self.requestTerminalOpen(windowId);
            });
          }
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
          if (win.appKey === 'terminal') {
            var self = this;
            this.$nextTick(function () {
              if (self.mountTerminalWindow) self.mountTerminalWindow(windowId);
              if (self.requestTerminalOpen) self.requestTerminalOpen(windowId);
            });
          }
          return;
        }
        win.restore = { left: win.left, top: win.top, width: win.width, height: win.height };
        win.left = 0;
        win.top = 0;
        win.width = window.innerWidth;
        win.height = window.innerHeight - 40;
        win.state = 'maximized';
        this.focusWindow(windowId);
        if (win.appKey === 'terminal' && this.syncTerminalWindow) this.syncTerminalWindow(windowId);
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
        var self = this;
        if (!this.dragState.active) return;
        var win = this.windows.find(function (item) { return item.id === self.dragState.windowId; });
        if (!win) return;
        win.left = this.dragState.left + (event.clientX - this.dragState.startX);
        win.top = this.dragState.top + (event.clientY - this.dragState.startY);
      },
      endDrag: function () {
        this.dragState.active = false;
        this.dragState.windowId = '';
      },
      windowToggleLabel: function (win) {
        return this.t(win && win.state === 'maximized' ? 'action.restore' : 'action.maximize');
      }
    }
  };
})();
