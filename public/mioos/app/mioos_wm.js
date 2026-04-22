(function () {
  function findWindow(vm, windowId) {
    return vm.windows.find(function (item) { return item.id === windowId; }) || null;
  }
  function taskbarHeight(vm) {
    return +((((vm.boot || {}).desktop || {}).windowing || {}).taskbarHeight || 40);
  }
  function viewportBounds(vm) {
    var padBottom = taskbarHeight(vm);
    return {
      left: 0,
      top: 0,
      width: Math.max(320, window.innerWidth || document.documentElement.clientWidth || 1280),
      height: Math.max(220, (window.innerHeight || document.documentElement.clientHeight || 720) - padBottom)
    };
  }
  function minWidth(vm, win) {
    return Math.max(+(((win || {}).minWidth) || ((((vm.boot || {}).desktop || {}).windowing || {}).minWidth) || 320), 240);
  }
  function minHeight(vm, win) {
    return Math.max(+(((win || {}).minHeight) || ((((vm.boot || {}).desktop || {}).windowing || {}).minHeight) || 220), 180);
  }
  function clampWindow(vm, win) {
    var bounds = viewportBounds(vm);
    var width = Math.max(minWidth(vm, win), +(win.width || 0) || 600);
    var height = Math.max(minHeight(vm, win), +(win.height || 0) || 420);
    if (width > bounds.width) width = bounds.width;
    if (height > bounds.height) height = bounds.height;
    win.width = width;
    win.height = height;
    win.left = Math.max(bounds.left, Math.min(+(win.left || 0), bounds.left + bounds.width - width));
    win.top = Math.max(bounds.top, Math.min(+(win.top || 0), bounds.top + bounds.height - height));
  }
  function scheduleTerminalSync(vm, win) {
    if (!win || win.appKey !== 'terminal' || !vm.syncTerminalWindow) return;
    window.requestAnimationFrame(function () {
      vm.syncTerminalWindow(win.id);
    });
  }
  function saveRestore(win) {
    win.restore = {
      left: +(win.left || 0),
      top: +(win.top || 0),
      width: +(win.width || 600),
      height: +(win.height || 420),
      state: win.state || 'normal'
    };
  }
  function restoreWindow(vm, win) {
    if (!win || !win.restore) return;
    win.left = +(win.restore.left || 0);
    win.top = +(win.restore.top || 0);
    win.width = +(win.restore.width || 600);
    win.height = +(win.restore.height || 420);
    win.state = 'normal';
    clampWindow(vm, win);
    scheduleTerminalSync(vm, win);
  }
  function appRecord(vm, appKey) {
    var pools = [vm.launcherEntries || [], vm.desktopEntries || [], ((vm.boot || {}).apps) || []];
    var i, found;
    for (i = 0; i < pools.length; i += 1) {
      found = (pools[i] || []).find(function (item) { return item && item.key === appKey; });
      if (found) return found;
    }
    return null;
  }
  function nextWindowSeed(vm, appKey) {
    var template = ((vm.boot || {}).windows || []).find(function (item) { return item && item.appKey === appKey; }) || (vm.windows || []).find(function (item) { return item && item.appKey === appKey; });
    var app = appRecord(vm, appKey) || {};
    var count = (vm.windows || []).filter(function (item) { return item && item.appKey === appKey; }).length;
    var title = String((app && app.title) || (template && template.title) || appKey || 'Window');
    return {
      id: 'win-' + String(appKey || 'app') + '-' + Date.now() + '-' + (count + 1),
      appKey: appKey,
      title: count > 0 ? title + ' ' + (count + 1) : title,
      left: +(template && template.left || 96) + (count * 24),
      top: +(template && template.top || 72) + (count * 20),
      width: +(template && template.width || ((app.kind === 'folder' || appKey === 'explorer' || appKey === 'my-computer' || appKey === 'documents') ? 920 : 760)),
      height: +(template && template.height || ((app.kind === 'folder' || appKey === 'explorer' || appKey === 'my-computer' || appKey === 'documents') ? 620 : 520)),
      z: ++vm.zCounter,
      state: 'normal',
      minWidth: +(template && template.minWidth || ((((vm.boot || {}).desktop || {}).windowing || {}).minWidth) || 320),
      minHeight: +(template && template.minHeight || ((((vm.boot || {}).desktop || {}).windowing || {}).minHeight) || 220),
      resizable: template && template.resizable != null ? template.resizable : 1,
      draggable: template && template.draggable != null ? template.draggable : 1,
      snappable: template && template.snappable != null ? template.snappable : 1
    };
  }
  function previewForZone(vm, zone) {
    var b = viewportBounds(vm);
    if (zone === 'maximize') return { left: b.left, top: b.top, width: b.width, height: b.height };
    if (zone === 'left') return { left: b.left, top: b.top, width: Math.floor(b.width / 2), height: b.height };
    if (zone === 'right') return { left: b.left + Math.floor(b.width / 2), top: b.top, width: Math.ceil(b.width / 2), height: b.height };
    if (zone === 'top-left') return { left: b.left, top: b.top, width: Math.floor(b.width / 2), height: Math.floor(b.height / 2) };
    if (zone === 'top-right') return { left: b.left + Math.floor(b.width / 2), top: b.top, width: Math.ceil(b.width / 2), height: Math.floor(b.height / 2) };
    if (zone === 'bottom-left') return { left: b.left, top: b.top + Math.floor(b.height / 2), width: Math.floor(b.width / 2), height: Math.ceil(b.height / 2) };
    if (zone === 'bottom-right') return { left: b.left + Math.floor(b.width / 2), top: b.top + Math.floor(b.height / 2), width: Math.ceil(b.width / 2), height: Math.ceil(b.height / 2) };
    return null;
  }

  window.MIOOSWM = {
    methods: {
      appIcon: function (appKey) {
        var entry = this.desktopEntries.find(function (item) { return item.key === appKey; });
        if (entry) return entry.icon;
        if (appKey === 'text-viewer') return '📄';
        if (appKey === 'image-viewer') return '🖼';
        if (appKey === 'media-viewer') return '🎞';
        return '□';
      },
      ensureWindowFrame: function (win) {
        if (!win) return null;
        if (!win.state) win.state = 'normal';
        if (win.resizable == null) win.resizable = 1;
        if (win.draggable == null) win.draggable = 1;
        if (win.snappable == null) win.snappable = 1;
        if (!win.minWidth) win.minWidth = (((this.boot || {}).desktop || {}).windowing || {}).minWidth || 320;
        if (!win.minHeight) win.minHeight = (((this.boot || {}).desktop || {}).windowing || {}).minHeight || 220;
        clampWindow(this, win);
        return win;
      },
      createWindowForApp: function (appKey) {
        var win = nextWindowSeed(this, appKey);
        var template = ((this.boot || {}).windows || []).find(function (item) { return item && item.appKey === appKey; }) || null;
        if (template && template.moduleWindow) {
          win.moduleWindow = 1;
          win.moduleId = template.moduleId;
          win.moduleCategory = template.moduleCategory;
          win.moduleSurface = template.moduleSurface;
          win.moduleBuiltIn = template.moduleBuiltIn;
          win.moduleSingleton = template.moduleSingleton;
        }
        if (template && template.themeStudioEnabled) win.themeStudioEnabled = 1;
        if (template && template.transferCenterEnabled) win.transferCenterEnabled = 1;
        if (template && template.transportDiagnosticsEnabled) win.transportDiagnosticsEnabled = template.transportDiagnosticsEnabled;
        if (template && template.moduleCatalogEnabled) win.moduleCatalogEnabled = 1;
        if (template && template.securityCenterEnabled) win.securityCenterEnabled = 1;
        if (template && template.debugCenterEnabled) win.debugCenterEnabled = 1;
        this.windows.push(win);
        this.ensureWindowFrame(win);
        return win;
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
        var win = this.windows.find(function (item) { return item.appKey === appKey && item.state !== 'closed'; }) || this.windows.find(function (item) { return item.appKey === appKey; });
        if (!win) win = this.createWindowForApp(appKey);
        if (!win) return;
        this.ensureWindowFrame(win);
        this.menuOpen = false;
        if (win.state === 'closed' || win.state === 'minimized') win.state = 'normal';
        this.focusWindow(win.id);
        if ((appKey === 'my-computer' || appKey === 'documents' || appKey === 'explorer') && this.bootstrapExplorerWindow) {
          this.$nextTick(function () {
            this.bootstrapExplorerWindow(win.id, true);
            if (this.refreshExplorerWindow) this.refreshExplorerWindow(win.id).catch(function () {});
          }.bind(this));
        }
        if (appKey === 'diagnostics' && this.refreshTransportDiagnostics) {
          this.$nextTick(function () { this.refreshTransportDiagnostics().catch(function () {}); }.bind(this));
        }
        if (appKey === 'security-center' && this.refreshSecurityCenter) {
          this.$nextTick(function () { this.refreshSecurityCenter().catch(function () {}); }.bind(this));
        }
        if (appKey === 'debug-center' && this.refreshDebugCenter) {
          this.$nextTick(function () { this.refreshDebugCenter().catch(function () {}); }.bind(this));
        }
        this.sendSocket({ event: 'shell.open', appKey: appKey });
      },
      focusWindow: function (windowId) {
        var win = findWindow(this, windowId);
        if (!win) return;
        this.ensureWindowFrame(win);
        this.zCounter += 1;
        win.z = this.zCounter;
        this.activeWindowId = windowId;
      },
      minimizeWindow: function (windowId) {
        var win = findWindow(this, windowId);
        if (!win) return;
        if (win.state !== 'minimized') saveRestore(win);
        win.state = 'minimized';
        this.clearSnapPreview();
        if (this.activeWindowId === windowId) this.activeWindowId = '';
      },
      closeWindow: function (windowId) {
        var win = findWindow(this, windowId);
        if (!win) return;
        if (win.appKey === 'terminal' && this.closeTerminalWindow) {
          this.closeTerminalWindow(windowId);
          return;
        }
        win.state = 'closed';
        this.clearSnapPreview();
        if (this.activeWindowId === windowId) this.activeWindowId = '';
      },
      taskbarToggle: function (windowId) {
        var win = findWindow(this, windowId);
        if (!win) return;
        this.ensureWindowFrame(win);
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
          } else if ((win.appKey === 'my-computer' || win.appKey === 'documents' || win.appKey === 'explorer') && this.bootstrapExplorerWindow) {
            this.$nextTick(function () {
              this.bootstrapExplorerWindow(windowId, true);
              if (this.refreshExplorerWindow) this.refreshExplorerWindow(windowId).catch(function () {});
            }.bind(this));
          }
          return;
        }
        if (this.activeWindowId === windowId) this.minimizeWindow(windowId); else this.focusWindow(windowId);
      },
      toggleMaximize: function (windowId) {
        var win = findWindow(this, windowId);
        var box;
        if (!win) return;
        this.ensureWindowFrame(win);
        if (win.state === 'maximized' || win.state === 'snapped') {
          restoreWindow(this, win);
          this.focusWindow(windowId);
          return;
        }
        saveRestore(win);
        box = previewForZone(this, 'maximize');
        win.left = box.left; win.top = box.top; win.width = box.width; win.height = box.height;
        win.state = 'maximized';
        this.focusWindow(windowId);
        scheduleTerminalSync(this, win);
      },
      restoreWindow: function (windowId) {
        var win = findWindow(this, windowId);
        if (!win) return;
        restoreWindow(this, win);
        this.focusWindow(windowId);
      },
      toggleMenu: function () {
        this.menuOpen = !this.menuOpen;
      },
      windowClass: function (win) {
        return {
          'is-active': this.activeWindowId === win.id,
          'is-maximized': win.state === 'maximized',
          'is-snapped': win.state === 'snapped',
          'is-dragging': this.dragState.active && this.dragState.windowId === win.id && this.dragState.mode === 'move',
          'is-resizing': this.dragState.active && this.dragState.windowId === win.id && this.dragState.mode === 'resize'
        };
      },
      windowStyle: function (win) {
        this.ensureWindowFrame(win);
        return {
          '--mioos-window-x': (win.left || 0) + 'px',
          '--mioos-window-y': (win.top || 0) + 'px',
          width: (win.width || 600) + 'px',
          height: (win.height || 420) + 'px',
          zIndex: (win.z || 1),
          willChange: ((this.dragState.active && this.dragState.windowId === win.id) ? 'transform' : 'auto')
        };
      },
      snapPreviewStyle: function () {
        return {
          left: (this.snapPreview.left || 0) + 'px',
          top: (this.snapPreview.top || 0) + 'px',
          width: (this.snapPreview.width || 0) + 'px',
          height: (this.snapPreview.height || 0) + 'px'
        };
      },
      clearSnapPreview: function () {
        this.snapPreview.active = false;
        this.snapPreview.zone = '';
      },
      computeSnapZone: function (event) {
        var threshold = +(((((this.boot || {}).desktop || {}).windowing || {}).snapThreshold) || 28);
        var x = event.clientX;
        var y = event.clientY;
        var w = window.innerWidth || document.documentElement.clientWidth || 1280;
        var h = (window.innerHeight || document.documentElement.clientHeight || 720) - taskbarHeight(this);
        if (y <= threshold && x <= threshold) return 'top-left';
        if (y <= threshold && x >= (w - threshold)) return 'top-right';
        if (y >= (h - threshold) && x <= threshold) return 'bottom-left';
        if (y >= (h - threshold) && x >= (w - threshold)) return 'bottom-right';
        if (y <= threshold) return 'maximize';
        if (x <= threshold) return 'left';
        if (x >= (w - threshold)) return 'right';
        return '';
      },
      applySnapZone: function (windowId, zone) {
        var win = findWindow(this, windowId);
        var box;
        if (!win || !zone) return;
        this.ensureWindowFrame(win);
        if (win.state !== 'maximized' && win.state !== 'snapped') saveRestore(win);
        box = previewForZone(this, zone);
        if (!box) return;
        win.left = box.left; win.top = box.top; win.width = box.width; win.height = box.height;
        win.state = zone === 'maximize' ? 'maximized' : 'snapped';
        win.snapZone = zone;
        this.focusWindow(windowId);
        this.clearSnapPreview();
        scheduleTerminalSync(this, win);
      },
      beginDrag: function (win, event) {
        if (!win || +win.draggable !== 1) return;
        this.ensureWindowFrame(win);
        if (event.button !== 0) return;
        if (win.state === 'maximized' || win.state === 'snapped') restoreWindow(this, win);
        this.focusWindow(win.id);
        this.dragState.active = true;
        this.dragState.mode = 'move';
        this.dragState.edge = '';
        this.dragState.windowId = win.id;
        this.dragState.startX = event.clientX;
        this.dragState.startY = event.clientY;
        this.dragState.left = win.left || 0;
        this.dragState.top = win.top || 0;
        this.dragState.width = win.width || 600;
        this.dragState.height = win.height || 420;
      },
      beginResize: function (win, edge, event) {
        if (!win || +win.resizable !== 1) return;
        this.ensureWindowFrame(win);
        if (event.button !== 0) return;
        event.stopPropagation();
        this.focusWindow(win.id);
        this.dragState.active = true;
        this.dragState.mode = 'resize';
        this.dragState.edge = edge || '';
        this.dragState.windowId = win.id;
        this.dragState.startX = event.clientX;
        this.dragState.startY = event.clientY;
        this.dragState.left = win.left || 0;
        this.dragState.top = win.top || 0;
        this.dragState.width = win.width || 600;
        this.dragState.height = win.height || 420;
      },
      onDragMove: function (event) {
        var win = findWindow(this, this.dragState.windowId);
        var dx, dy, nextZone, nextBox, nextLeft, nextTop, nextWidth, nextHeight;
        if (!this.dragState.active || !win) return;
        dx = event.clientX - this.dragState.startX;
        dy = event.clientY - this.dragState.startY;
        if (this.dragState.mode === 'move') {
          win.left = this.dragState.left + dx;
          win.top = this.dragState.top + dy;
          clampWindow(this, win);
          nextZone = this.computeSnapZone(event);
          if (nextZone) {
            nextBox = previewForZone(this, nextZone);
            this.snapPreview = Object.assign({ active: true, zone: nextZone }, nextBox || {});
          } else {
            this.clearSnapPreview();
          }
          return;
        }
        nextLeft = this.dragState.left;
        nextTop = this.dragState.top;
        nextWidth = this.dragState.width;
        nextHeight = this.dragState.height;
        if (this.dragState.edge.indexOf('e') >= 0) nextWidth = this.dragState.width + dx;
        if (this.dragState.edge.indexOf('s') >= 0) nextHeight = this.dragState.height + dy;
        if (this.dragState.edge.indexOf('w') >= 0) {
          nextWidth = this.dragState.width - dx;
          nextLeft = this.dragState.left + dx;
        }
        if (this.dragState.edge.indexOf('n') >= 0) {
          nextHeight = this.dragState.height - dy;
          nextTop = this.dragState.top + dy;
        }
        if (nextWidth < minWidth(this, win)) {
          if (this.dragState.edge.indexOf('w') >= 0) nextLeft -= (minWidth(this, win) - nextWidth);
          nextWidth = minWidth(this, win);
        }
        if (nextHeight < minHeight(this, win)) {
          if (this.dragState.edge.indexOf('n') >= 0) nextTop -= (minHeight(this, win) - nextHeight);
          nextHeight = minHeight(this, win);
        }
        win.left = nextLeft; win.top = nextTop; win.width = nextWidth; win.height = nextHeight;
        clampWindow(this, win);
        this.clearSnapPreview();
      },
      endDrag: function () {
        var win = findWindow(this, this.dragState.windowId);
        var zone = this.snapPreview.zone;
        if (!this.dragState.active) return;
        if (this.dragState.mode === 'move' && win && zone) this.applySnapZone(win.id, zone);
        if (win && this.dragState.mode === 'resize') scheduleTerminalSync(this, win);
        this.dragState.active = false;
        this.dragState.mode = 'move';
        this.dragState.edge = '';
        this.dragState.windowId = '';
        this.clearSnapPreview();
      },
      onWindowTitleDblClick: function (windowId) {
        this.toggleMaximize(windowId);
      },
      windowToggleLabel: function (win) {
        return this.t(win && (win.state === 'maximized' || win.state === 'snapped') ? 'action.restore' : 'action.maximize');
      },
      resizeHandleClass: function (edge) {
        return 'is-' + edge;
      },
      handleViewportResize: function () {
        var self = this;
        if (this.centerAuthWindow && this.requiresSignin) this.centerAuthWindow();
        this.windows.forEach(function (win) {
          var box;
          if (!win || win.state === 'closed') return;
          self.ensureWindowFrame(win);
          if (win.state === 'maximized') {
            box = previewForZone(self, 'maximize');
            win.left = box.left; win.top = box.top; win.width = box.width; win.height = box.height;
          } else if (win.state === 'snapped' && win.snapZone) {
            box = previewForZone(self, win.snapZone);
            if (box) {
              win.left = box.left; win.top = box.top; win.width = box.width; win.height = box.height;
            }
          } else clampWindow(self, win);
          scheduleTerminalSync(self, win);
        });
      },
      onWindowDragOver: function (win, event) {
        if (!win || !(((this.boot || {}).desktop || {}).windowing || {}).dropUpload) return;
        if (win.appKey !== 'my-computer' && win.appKey !== 'documents' && win.appKey !== 'explorer') return;
        event.preventDefault();
      },
      onWindowDrop: function (win, event) {
        var files;
        if (!win || !event) return;
        files = (event.dataTransfer && event.dataTransfer.files) || [];
        if (!files.length) return;
        event.preventDefault();
        if ((win.appKey === 'my-computer' || win.appKey === 'documents' || win.appKey === 'explorer') && this.uploadFilesToExplorer) {
          this.uploadFilesToExplorer(win.id, files);
        }
      }
    }
  };
})();
