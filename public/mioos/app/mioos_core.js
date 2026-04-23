(function () {
  function mount() {
    if (!window.Vue || !window.Vue.createApp || !window.MIOOSState) return;
    var root = window.MIOOSState.getRootNode();
    if (!root || root.__mioosVueMounted) return;
    root.__mioosVueMounted = true;

    var Auth = (window.MIOOSAuth || {}).methods || {};
    var WS = (window.MIOOSWSClient || {}).methods || {};
    var WM = (window.MIOOSWM || {}).methods || {};
    var Terminal = (window.MIOOSTerminal || {}).methods || {};
    var Explorer = (window.MIOOSExplorer || {}).methods || {};
    var I18N = window.MIOOSI18N || {};

    var app = window.Vue.createApp({
      data: function () {
        return {
          boot: window.MIOOSState.defaultBoot(),
          view: window.MIOOSState.defaultView(),
          desktopEntries: [],
          desktopAppEntries: [],
          desktopFolderEntries: [],
          launcherEntries: [],
          windows: [],
          activeWindowId: '',
          menuOpen: false,
          menuFilter: '',
          socket: null,
          socketConnected: false,
          clockText: '',
          clockDateText: '',
          alertTitle: '',
          alertMessage: '',
          shellNotifications: [],
          notificationSeq: 0,
          shellUi: { trayOpen: false, reducedMotion: false, desktopHidden: false, previousWindowId: '', windowSwitcherOpen: false, windowSwitcherIndex: 0, currentWorkspaceKey: 'workspace-main' },
          shellDialog: { open: false, type: '', title: '', message: '', detail: '', confirmText: 'OK', cancelText: 'Cancel', value: '', placeholder: '', resolve: null, reject: null },
          windowMenu: { open: false, windowId: '', source: 'titlebar', left: 0, top: 0 },
          zCounter: 10,
          dragState: {
            active: false,
            windowId: '',
            startX: 0,
            startY: 0,
            left: 0,
            top: 0,
            mode: 'move',
            edge: '',
            width: 0,
            height: 0
          },
          authWindow: { left: 0, top: 0, width: 440 },
          authDrag: { active: false, startX: 0, startY: 0, left: 0, top: 0 },
          snapPreview: { active: false, zone: '', left: 0, top: 0, width: 0, height: 0 },
          clockTimer: null,
          pingTimer: null,
          profile: 'dev',
          authBusy: false,
          authForm: {
            username: 'admin',
            password: 'admin123!'
          },
          authPasswordChange: {
            required: false,
            username: '',
            changeToken: '',
            newPassword: '',
            confirmPassword: '',
            status: {},
            policy: {}
          },
          commandSeq: 0,
          socketRequestSeq: 0,
          socketPending: {},
          pendingCommands: {},
          terminalWindowSeq: 0,
          terminalPollTimer: null,
          appliedThemeProfile: null,
          themeStudioProfilesCache: [],
          themeStudioActiveKey: '',
          themeStyleNodeId: 'mioos-theme-studio-style',
          transferCenter: { items: [], seq: 0, autoOpen: true },
          transferControllers: {},
          transportDiagnostics: { loading: false, refreshedAt: 0, error: '', report: {} },
          securityCenter: { loading: false, refreshedAt: 0, error: '', report: {}, trail: [], sessions: [], accounts: [] },
          debugCenter: { loading: false, refreshedAt: 0, error: '', snapshot: {}, events: [], seq: 0 },
          socketTelemetry: {},
          moduleCatalog: { loading: false, refreshedAt: 0, error: '' },
          desktopUi: {
            iconSize: 'medium',
            sortMode: 'manual',
            positions: {},
            selectedKey: '',
            drag: { armed: false, active: false, moved: false, key: '', startX: 0, startY: 0, left: 0, top: 0 },
            contextMenu: { open: false, type: 'desktop', key: '', left: 0, top: 0 }
          }
        };
      },
      computed: {
        visibleWindows: function () {
          return this.windows
            .filter(function (win) { return win.state !== 'closed' && win.state !== 'minimized' && this.isWindowInCurrentWorkspace(win); }.bind(this))
            .sort(function (a, b) { return (a.z || 0) - (b.z || 0); });
        },
        taskbarWindows: function () {
          return this.windows.filter(function (win) { return win.state !== 'closed' && this.isWindowInTaskbarWorkspace(win); }.bind(this));
        },
        taskbarGroups: function () {
          var groups = {};
          this.taskbarWindows.forEach(function (win) {
            var key = win.appKey || win.id;
            if (!groups[key]) groups[key] = { key: key, appKey: key, title: win.title || key, icon: this.appIcon ? this.appIcon(key, win) : '□', windows: [], activeWindowId: '', hasMinimized: false, hasOpen: false };
            groups[key].windows.push(win);
            if (win.id === this.activeWindowId || win.focused) groups[key].activeWindowId = win.id;
            if (win.state === 'minimized') groups[key].hasMinimized = true;
            else groups[key].hasOpen = true;
          }.bind(this));
          return Object.keys(groups).map(function (key) {
            groups[key].count = groups[key].windows.length;
            groups[key].allMinimized = !groups[key].hasOpen;
            groups[key].windows.sort(function (a, b) { return (a.z || 0) - (b.z || 0); });
            return groups[key];
          }).sort(function (a, b) {
            var az = ((a.windows[a.windows.length - 1] || {}).z || 0);
            var bz = ((b.windows[b.windows.length - 1] || {}).z || 0);
            return az - bz;
          });
        },
        filteredEntries: function () {
          var needle = (this.menuFilter || '').trim().toLowerCase();
          var source = (this.launcherEntries || []).concat(this.desktopFolderEntries || []);
          if (!source.length) source = this.desktopEntries || [];
          if (!needle) return source;
          return source.filter(function (entry) {
            var hay = ((entry.title || '') + ' ' + (entry.subtitle || '') + ' ' + (entry.path || '')).toLowerCase();
            return hay.indexOf(needle) !== -1;
          });
        },
        requiresSignin: function () {
          return !!(this.boot.auth && this.boot.auth.required && !(this.boot.user && this.boot.user.authenticated));
        },
        authEnabled: function () {
          return !!(this.boot.auth && this.boot.auth.enabled);
        },
        localeOptions: function () {
          return I18N.localeOptions ? I18N.localeOptions(this) : [];
        },
        currentLocale: function () {
          return I18N.currentLocale ? I18N.currentLocale(this) : { code: 'en', dir: 'ltr', label: 'English', rtl: false };
        }
      },
      watch: {
        'view.desktopEntries': {
          deep: true,
          handler: function (entries) {
            if (Array.isArray(entries) && entries.length) {
              this.desktopAppEntries = window.MIOOSState.deepClone(entries);
              this.rebuildDesktopEntries();
              this.ensureDesktopLayout();
            }
          }
        }
      },
      mounted: function () {
        var self = this;
        this.bootstrapFromDom();
        this.restorePersistedTransfers();
        this.centerAuthWindow(true);
        this.normalizeDesktopUiState();
        this.ensureDesktopLayout();
        this.normalizeDesktopUiState();
        this.applyBootThemeDefaults();
        this.applyPersistedThemeStudioProfile();
        if (!this.requiresSignin) this.themeStudioLoadRemote();
        this.applyDocumentLocale();
        this.startClock();
        if (!this.requiresSignin) {
          this.refreshView().then(function () { if (self.syncDesktopFolderEntries) return self.syncDesktopFolderEntries(); }).catch(function () {});
          this.initSocket().catch(function () {});
          if (this.startTerminalPolling) this.startTerminalPolling();
        }
        this._dragMove = this.handleGlobalMouseMove.bind(this);
        this._dragEnd = this.handleGlobalMouseUp.bind(this);
        this._viewportResize = this.handleViewportResize.bind(this);
        this._keyDownHandler = this.handleGlobalKeyDown.bind(this);
        this._keyUpHandler = this.handleGlobalKeyUp.bind(this);
        window.addEventListener('mousemove', this._dragMove);
        window.addEventListener('mouseup', this._dragEnd);
        this._persistTransfersOnUnload = this.persistTransferCenter.bind(this);
        this._networkOffline = function () {
          if (self.autoPauseTransfersByReason) self.autoPauseTransfersByReason('Paused (connection lost)', 'upload');
        };
        this._networkOnline = function () {
          if (self.persistTransferCenter) self.persistTransferCenter();
        };
        window.addEventListener('resize', this._viewportResize);
        window.addEventListener('keydown', this._keyDownHandler);
        window.addEventListener('keyup', this._keyUpHandler);
        window.addEventListener('beforeunload', this._persistTransfersOnUnload);
        window.addEventListener('offline', this._networkOffline);
        window.addEventListener('online', this._networkOnline);
        if (this.restoreAuthWindowPosition) this.restoreAuthWindowPosition();
        if (this.restoreShellPreferences) this.restoreShellPreferences();
        if (this.restoreWindowLayout) this.restoreWindowLayout();
        if (!this.requiresSignin) window.setTimeout(function () { if (self.revivePersistedTransfers) self.revivePersistedTransfers(); }, 400);
      },
      beforeUnmount: function () {
        if (this.clockTimer) window.clearInterval(this.clockTimer);
        if (this.pingTimer) window.clearInterval(this.pingTimer);
        if (this.terminalPollTimer) window.clearInterval(this.terminalPollTimer);
        if (this.socket) this.socket.close();
        this.persistTransferCenter();
        window.removeEventListener('mousemove', this._dragMove);
        window.removeEventListener('mouseup', this._dragEnd);
        window.removeEventListener('resize', this._viewportResize);
        window.removeEventListener('keydown', this._keyDownHandler);
        window.removeEventListener('keyup', this._keyUpHandler);
        window.removeEventListener('beforeunload', this._persistTransfersOnUnload);
        window.removeEventListener('offline', this._networkOffline);
        window.removeEventListener('online', this._networkOnline);
        this.windows.forEach(function (win) {
          if (win._term) win._term.dispose();
        });
      },
      methods: Object.assign({
        normalizeDesktopUiState: function () {
          if (!this.desktopUi) this.desktopUi = {};
          if (!this.desktopUi.drag) this.desktopUi.drag = { armed: false, active: false, moved: false, key: '', startX: 0, startY: 0, left: 0, top: 0 };
          if (!this.desktopUi.positions) this.desktopUi.positions = {};
          if (!this.desktopUi.contextMenu) this.desktopUi.contextMenu = { open: false, type: 'desktop', key: '', left: 0, top: 0 };
          if (!this.desktopUi.iconSize) this.desktopUi.iconSize = 'medium';
          if (!this.desktopUi.sortMode) this.desktopUi.sortMode = 'manual';
          if (!this.desktopUi.viewMode) this.desktopUi.viewMode = 'details';
          if (typeof this.desktopUi.selectedKey === 'undefined') this.desktopUi.selectedKey = '';
        },
        desktopContextMenuState: function () {
          this.normalizeDesktopUiState();
          return this.desktopUi.contextMenu || { open: false, type: 'desktop', key: '', left: 0, top: 0 };
        },
        bootstrapFromDom: function () {
          var node = window.MIOOSState.getBootNode();
          if (!node) return;
          try {
            this.boot = window.MIOOSState.normalizeBoot(JSON.parse(node.textContent || '{}'));
          } catch (err) {
            this.showAlert(this.t('alerts.bootError.title'), this.t('alerts.bootError.message'));
            this.boot = window.MIOOSState.defaultBoot();
          }
          this.profile = this.boot.product.profile || 'dev';
          this.launcherEntries = window.MIOOSState.deepClone(this.boot.apps || []);
          this.desktopAppEntries = window.MIOOSState.deepClone((this.view && this.view.desktopEntries) || this.boot.desktopEntries || this.boot.apps || []);
          this.desktopEntries = window.MIOOSState.deepClone(this.desktopAppEntries || []);
          if (this.$el && this.$el.style && (((this.boot || {}).desktop || {}).windowing || {}).titlebarHeight) {
            this.$el.style.setProperty('--mioos-titlebar-height', ((((this.boot || {}).desktop || {}).windowing || {}).titlebarHeight) + 'px');
          }
          this.windows = window.MIOOSState.deepClone(this.boot.windows || []);
          this.ensureModuleWindowState();
          this.normalizeDesktopUiState();
          this.desktopUi.iconSize = ((((this.boot || {}).desktop || {}).icons || {}).size) || 'medium';
          this.desktopUi.sortMode = ((((this.boot || {}).desktop || {}).icons || {}).sortMode) || 'manual';
          this.normalizeDesktopUiState();
          this.zCounter = this.windows.reduce(function (max, win) { return Math.max(max, win.z || 0); }, 10) + 1;
          if (this.windows.length) this.activeWindowId = this.windows[0].id;
          if (!Array.isArray(this.shellNotifications)) this.shellNotifications = [];
          if (!this.shellUi) this.shellUi = { trayOpen: false, reducedMotion: false, desktopHidden: false, previousWindowId: '', windowSwitcherOpen: false, windowSwitcherIndex: 0, currentWorkspaceKey: 'workspace-main' };
          this.shellUi.currentWorkspaceKey = 'workspace-main';
          if (typeof this.shellUi.reducedMotion === 'undefined') this.shellUi.reducedMotion = false;
          if (this.applyReducedMotionPreference) this.applyReducedMotionPreference();
        },

        shellPreferencesKey: function () {
          return 'mioos.shell.prefs.' + ((((this.boot || {}).user || {}).id) || 'guest');
        },
        authWindowStorageKey: function () {
          return 'mioos.auth.window.' + ((((this.boot || {}).user || {}).id) || 'guest');
        },
        windowLayoutStorageKey: function () {
          return 'mioos.window.layout.' + ((((this.boot || {}).user || {}).id) || 'guest');
        },
        restoreShellPreferences: function () {
          var raw = null;
          var prefs = {};
          try { raw = window.localStorage.getItem(this.shellPreferencesKey()); } catch (err) { raw = null; }
          if (raw) {
            try { prefs = JSON.parse(raw) || {}; } catch (err2) { prefs = {}; }
          }
          if (prefs && typeof prefs.reducedMotion !== 'undefined') this.shellUi.reducedMotion = !!prefs.reducedMotion;
          this.applyReducedMotionPreference();
        },
        persistShellPreferences: function () {
          var payload = { reducedMotion: !!((this.shellUi || {}).reducedMotion), currentWorkspaceKey: 'workspace-main' };
          try { window.localStorage.setItem(this.shellPreferencesKey(), JSON.stringify(payload)); } catch (err) {}
        },
        applyReducedMotionPreference: function () {
          var root = window.MIOOSState.getRootNode();
          if (!root) return;
          if ((this.shellUi || {}).reducedMotion) root.setAttribute('data-reduced-motion', '1'); else root.removeAttribute('data-reduced-motion');
        },
        toggleReducedMotion: function () {
          this.shellUi.reducedMotion = !((this.shellUi || {}).reducedMotion);
          this.applyReducedMotionPreference();
          this.persistShellPreferences();
          this.pushNotification('info', 'Accessibility', this.shellUi.reducedMotion ? 'Reduced motion enabled.' : 'Reduced motion disabled.', { timeoutMs: 1800 });
        },
        restoreAuthWindowPosition: function () {
          var raw = null, cached = null;
          try { raw = window.localStorage.getItem(this.authWindowStorageKey()); } catch (err) { raw = null; }
          if (!raw) return;
          try { cached = JSON.parse(raw) || null; } catch (err2) { cached = null; }
          if (!cached) return;
          if (+cached.left >= 0) this.authWindow.left = +cached.left;
          if (+cached.top >= 0) this.authWindow.top = +cached.top;
        },
        persistAuthWindowPosition: function () {
          var payload = { left: +(this.authWindow.left || 0), top: +(this.authWindow.top || 0), width: +(this.authWindow.width || 440) };
          try { window.localStorage.setItem(this.authWindowStorageKey(), JSON.stringify(payload)); } catch (err) {}
        },
        restoreWindowLayout: function () {
          var raw = null, cached = null, self = this;
          try { raw = window.localStorage.getItem(this.windowLayoutStorageKey()); } catch (err) { raw = null; }
          if (!raw) return;
          try { cached = JSON.parse(raw) || null; } catch (err2) { cached = null; }
          if (!cached || !cached.windows) return;
          (this.windows || []).forEach(function (win) {
            var key = String(win.appKey || '') + ':' + String(win.id || '');
            var rec = cached.windows[key] || cached.windows[String(win.appKey || '')] || null;
            if (!rec) return;
            if (+rec.left >= 0) win.left = +rec.left;
            if (+rec.top >= 0) win.top = +rec.top;
            if (+rec.width > 0) win.width = +rec.width;
            if (+rec.height > 0) win.height = +rec.height;
            if (rec.state && rec.state !== 'closed') win.state = rec.state;
            if (self.ensureWindowFrame) self.ensureWindowFrame(win);
          });
          if (cached.activeWindowId) this.activeWindowId = cached.activeWindowId;
        },
        persistWindowLayout: function () {
          var payload = { activeWindowId: this.activeWindowId || '', windows: {} };
          (this.windows || []).forEach(function (win) {
            if (!win || win.appKey === 'terminal' || win.state === 'closed') return;
            payload.windows[String(win.appKey || '') + ':' + String(win.id || '')] = {
              left: +(win.left || 0), top: +(win.top || 0), width: +(win.width || 0), height: +(win.height || 0), state: win.state || 'normal'
            };
            if (!payload.windows[String(win.appKey || '')]) {
              payload.windows[String(win.appKey || '')] = {
                left: +(win.left || 0), top: +(win.top || 0), width: +(win.width || 0), height: +(win.height || 0), state: win.state || 'normal'
              };
            }
          });
          try { window.localStorage.setItem(this.windowLayoutStorageKey(), JSON.stringify(payload)); } catch (err) {}
        },
        workspaceItems: function () {
          return [];
        },
        currentWorkspace: function () {
          return { key: 'workspace-main', title: 'Desktop', icon: '⌂' };
        },
        workspaceEnabled: function () {
          return false;
        },
        isWindowInCurrentWorkspace: function () {
          return true;
        },
        isWindowInTaskbarWorkspace: function () {
          return true;
        },
        switchWorkspace: function () {
          if (!this.shellUi) this.shellUi = {};
          this.shellUi.currentWorkspaceKey = 'workspace-main';
        },
        cycleWorkspace: function () {
          return;
        },
        moveFocusedWindowWorkspace: function () {
          return;
        },
        switcherWindows: function () {
          return (this.taskbarWindows || []).filter(function (win) { return win && win.state !== 'closed'; }).sort(function (a, b) { return (b.z || 0) - (a.z || 0); });
        },
        openWindowSwitcher: function () {
          var rows = this.switcherWindows();
          if (!rows.length) return;
          this.shellUi.windowSwitcherOpen = true;
          this.shellUi.windowSwitcherIndex = rows.findIndex(function (item) { return item.id === this.activeWindowId; }.bind(this));
          if (this.shellUi.windowSwitcherIndex < 0) this.shellUi.windowSwitcherIndex = 0;
        },
        cycleWindowSwitcher: function () {
          var rows = this.switcherWindows();
          if (!rows.length) return;
          if (!this.shellUi.windowSwitcherOpen) this.openWindowSwitcher();
          this.shellUi.windowSwitcherIndex = (this.shellUi.windowSwitcherIndex + 1) % rows.length;
        },
        commitWindowSwitcher: function () {
          var rows = this.switcherWindows();
          var target = rows[this.shellUi.windowSwitcherIndex] || null;
          this.shellUi.windowSwitcherOpen = false;
          if (target) this.taskbarToggle(target.id);
        },
        closeWindowSwitcher: function () {
          this.shellUi.windowSwitcherOpen = false;
        },
        toggleDesktopVisibility: function () {
          var hiding = !((this.shellUi || {}).desktopHidden);
          var wins;
          this.shellUi.desktopHidden = hiding;
          if (hiding) {
            wins = (this.taskbarWindows || []).filter(function (win) { return win && win.state !== 'closed' && win.state !== 'minimized'; });
            this.shellUi.previousWindowId = this.activeWindowId || ((wins[0] || {}).id || '');
          } else if (this.shellUi.previousWindowId) {
            this.taskbarToggle(this.shellUi.previousWindowId);
          }
        },
        handleGlobalKeyDown: function (event) {
          var tag = String(((event.target || {}).tagName) || '').toLowerCase();
          if (!event) return;
          if ((tag === 'input' || tag === 'textarea' || tag === 'select') && !(event.altKey && event.key === 'Tab')) return;
          if ((event.metaKey || event.ctrlKey) && !event.shiftKey && String(event.key || '').toLowerCase() === 'd') {
            event.preventDefault();
            this.toggleDesktopVisibility();
            return;
          }
          if (event.altKey && event.key === 'Tab') {
            event.preventDefault();
            this.cycleWindowSwitcher();
            return;
          }
          if (event.shiftKey && !event.ctrlKey && !event.metaKey && event.key === 'Escape') {
            if (this.activeWindowId) {
              event.preventDefault();
              this.closeWindow(this.activeWindowId);
            }
            return;
          }
          if ((event.ctrlKey || event.metaKey) && event.shiftKey && String(event.key || '').toLowerCase() === 'escape') {
            event.preventDefault();
            this.openApp('transfers');
            return;
          }
          if (this.workspaceEnabled() && event.ctrlKey && event.altKey && !event.metaKey) {
            if (event.shiftKey && event.key === 'ArrowLeft') {
              event.preventDefault();
              this.moveFocusedWindowWorkspace(-1);
              return;
            }
            if (event.shiftKey && event.key === 'ArrowRight') {
              event.preventDefault();
              this.moveFocusedWindowWorkspace(1);
              return;
            }
            if (!event.shiftKey && event.key === 'ArrowLeft') {
              event.preventDefault();
              this.cycleWorkspace(-1);
              return;
            }
            if (!event.shiftKey && event.key === 'ArrowRight') {
              event.preventDefault();
              this.cycleWorkspace(1);
              return;
            }
          }
          if (event.altKey && event.shiftKey && !event.ctrlKey && !event.metaKey && this.activeWindowId) {
            if (event.key === 'ArrowLeft') {
              event.preventDefault();
              this.applySnapZone(this.activeWindowId, 'left');
              return;
            }
            if (event.key === 'ArrowRight') {
              event.preventDefault();
              this.applySnapZone(this.activeWindowId, 'right');
              return;
            }
            if (event.key === 'ArrowUp') {
              event.preventDefault();
              this.applySnapZone(this.activeWindowId, 'maximize');
              return;
            }
            if (event.key === 'ArrowDown') {
              event.preventDefault();
              this.restoreWindowAction(this.activeWindowId);
              return;
            }
          }
        },
        handleGlobalKeyUp: function (event) {
          if (event && event.key === 'Alt' && ((this.shellUi || {}).windowSwitcherOpen)) {
            event.preventDefault();
            this.commitWindowSwitcher();
          }
        },

        startClock: function () {
          var self = this;
          function tick() {
            var now = new Date();
            self.clockText = now.toLocaleTimeString(self.currentLocale.code || undefined, { hour: 'numeric', minute: '2-digit' });
            self.clockDateText = now.toLocaleDateString(self.currentLocale.code || undefined, { month: 'numeric', day: 'numeric', year: 'numeric' });
          }
          tick();
          this.clockTimer = window.setInterval(tick, 1000);
        },
        formatBytesCompact: function (value) {
          var size = Number(value || 0), units = ['B','KB','MB','GB','TB'], idx = 0;
          if (!size) return '0 B';
          while (size >= 1024 && idx < units.length - 1) { size = size / 1024; idx += 1; }
          return (size >= 10 || idx === 0 ? Math.round(size) : size.toFixed(1)) + ' ' + units[idx];
        },
        transferDirectionLabel: function (item) {
          if (!item) return '';
          return (item.sourcePath || 'Local device') + ' → ' + (item.destinationPath || ((item.resume || {}).parentPath) || '/Home');
        },
        transferTimestampLabel: function (item) {
          var value = (item && (item.updatedAt || item.startedAt)) || 0;
          if (!value) return 'Waiting';
          return this.formatTransportTime(value, { month: 'numeric', day: 'numeric', year: 'numeric', hour: 'numeric', minute: '2-digit' });
        },
        transferProgressLabel: function (item) {
          if (!item) return '0%';
          return this.transferPercent(item) + '% · ' + this.formatBytesCompact(item.processedBytes || 0) + ' of ' + this.formatBytesCompact(item.totalBytes || 0);
        },
        transferStatusCaption: function (item) {
          if (!item) return '';
          return (item.stage || item.status || 'Queued') + (item.error ? ' — ' + item.error : '');
        },
        transferActiveCount: function () {
          return this.activeTransfers().filter(function (item) { return item.status !== 'paused'; }).length;
        },
        transferPausedCount: function () {
          return this.activeTransfers().filter(function (item) { return item.status === 'paused'; }).length;
        },
        transferCompletedCount: function () {
          return this.completedTransfers().filter(function (item) { return item.status === 'completed'; }).length;
        },
        transferFailedCount: function () {
          return this.completedTransfers().filter(function (item) { return item.status === 'failed'; }).length;
        },
        transferPrimaryItem: function () {
          return (this.activeTransfers() || [])[0] || (this.completedTransfers() || [])[0] || null;
        },
        transferQueueRows: function (limit) {
          var seen = {};
          var rows = (this.transferCenter.items || []).filter(function (item) {
            var key;
            if (!item) return false;
            key = item.id || [item.kind || "", item.name || "", item.totalBytes || 0, item.status || "", item.resume && item.resume.uploadId || ""].join("|");
            if (seen[key]) return false;
            seen[key] = 1;
            return true;
          });
          rows.sort(function (a, b) { return +((b && (b.updatedAt || b.startedAt || 0)) || 0) - +((a && (a.updatedAt || a.startedAt || 0)) || 0); });
          return rows.slice(0, Math.max(1, +(limit || 8)));
        },
        trayStatusIndicators: function () {
          return [
            { key: 'socket', label: this.socketConnected ? 'Live' : 'Offline', state: this.socketConnected ? 'live' : 'alert' },
            { key: 'transfer', label: this.transferActiveCount() ? 'Transfers active' : 'Transfers idle', state: this.transferActiveCount() ? 'busy' : 'live' },
            { key: 'notify', label: this.unreadNotificationCount() ? 'Unread alerts' : 'No alerts', state: this.unreadNotificationCount() ? 'alert' : 'live' }
          ];
        },
        t: function (key, fallback) {
          return I18N.t ? I18N.t(this, key, fallback) : (fallback || key);
        },
        pushNotification: function (type, title, message, opts) {
          var entry;
          var self = this;
          var limit = +(((((this.boot || {}).desktop || {}).notifications || {}).stackLimit) || 6);
          opts = opts || {};
          entry = {
            id: 'note-' + (++this.notificationSeq),
            type: type || 'info',
            title: title || this.t('alerts.shell.title', 'MIOOS'),
            message: message || '',
            detail: opts.detail || '',
            ts: Date.now(),
            read: false,
            sticky: !!opts.sticky,
            timeoutMs: +opts.timeoutMs || 0
          };
          this.shellNotifications.unshift(entry);
          if (this.shellNotifications.length > limit) this.shellNotifications.splice(limit);
          if (this.shellUi) this.shellUi.trayOpen = true;
          if (!entry.sticky && entry.timeoutMs > 0) {
            window.setTimeout(function () {
              self.dismissNotification(entry.id);
            }, entry.timeoutMs);
          }
          return entry;
        },
        dismissNotification: function (id) {
          this.shellNotifications = (this.shellNotifications || []).filter(function (item) { return item.id !== id; });
        },
        markNotificationRead: function (id) {
          (this.shellNotifications || []).forEach(function (item) {
            if (!id || item.id === id) item.read = true;
          });
        },
        markAllNotificationsRead: function () {
          this.markNotificationRead('');
        },
        unreadNotificationCount: function () {
          return (this.shellNotifications || []).filter(function (item) { return !item.read; }).length;
        },
        notifyInfo: function (title, message, opts) {
          return this.pushNotification('info', title, message, Object.assign({ timeoutMs: 1800 }, opts || {}));
        },
        notifySuccess: function (title, message, opts) {
          return this.pushNotification('success', title, message, Object.assign({ timeoutMs: 1800 }, opts || {}));
        },
        notifyError: function (title, message, opts) {
          return this.pushNotification('error', title, message, Object.assign({ sticky: true }, opts || {}));
        },
        clipboardWriteText: function (text) {
          text = String(text == null ? '' : text);
          if (window.navigator && window.navigator.clipboard && window.navigator.clipboard.writeText) return window.navigator.clipboard.writeText(text);
          return new Promise(function (resolve, reject) {
            try {
              var ta = document.createElement('textarea');
              ta.value = text;
              ta.setAttribute('readonly', 'readonly');
              ta.style.position = 'fixed';
              ta.style.opacity = '0';
              ta.style.left = '-9999px';
              document.body.appendChild(ta);
              ta.focus();
              ta.select();
              if (!document.execCommand('copy')) throw new Error('copy_failed');
              document.body.removeChild(ta);
              resolve(true);
            } catch (err) {
              reject(err);
            }
          });
        },
        copyTextToClipboard: function (text, opts) {
          var self = this;
          opts = opts || {};
          return this.clipboardWriteText(text).then(function () {
            self.notifySuccess(opts.title || 'Clipboard', opts.message || 'Copied to clipboard.', { detail: opts.detail || '' });
            return true;
          }).catch(function (err) {
            self.notifyError(opts.errorTitle || 'Clipboard', opts.errorMessage || 'Unable to copy to clipboard.', { detail: (err && (err.message || err.detail || err.error)) || '' });
            return false;
          });
        },
        toggleTrayPanel: function () {
          this.menuOpen = false;
          this.closeWindowSwitcher();
          this.closeDesktopContextMenu();
          this.shellUi.trayOpen = !((this.shellUi || {}).trayOpen);
          if (this.shellUi.trayOpen) this.markAllNotificationsRead();
        },
        closeTrayPanel: function () {
          if (this.shellUi) this.shellUi.trayOpen = false;
        },
        clearNotifications: function () {
          this.shellNotifications.splice(0, this.shellNotifications.length);
          if (this.dismissAlert) this.dismissAlert();
        },
        overallTransferPercent: function () {
          var rows = this.activeTransfers();
          var total = 0;
          var processed = 0;
          if (!rows.length) return 0;
          rows.forEach(function (item) {
            total += +(item.totalBytes || 0);
            processed += +(item.processedBytes || 0);
          });
          if (total > 0) return Math.max(0, Math.min(100, Math.round((processed / total) * 100)));
          return Math.max(0, Math.min(100, Math.round(rows.reduce(function (sum, item) { return sum + (+(item.progress || 0)); }, 0) / rows.length)));
        },
        showDialog: function (opts) {
          var self = this;
          opts = opts || {};
          if (this.shellDialog && this.shellDialog.open && this.shellDialog.resolve) {
            this.shellDialog.resolve({ action: 'cancel', value: '' });
          }
          this.shellDialog = {
            open: true,
            type: opts.type || 'alert',
            title: opts.title || this.t('alerts.shell.title', 'MIOOS'),
            message: opts.message || '',
            detail: opts.detail || '',
            confirmText: opts.confirmText || this.t('common.ok', 'OK'),
            cancelText: opts.cancelText || this.t('common.cancel', 'Cancel'),
            value: typeof opts.value === 'undefined' ? '' : String(opts.value || ''),
            placeholder: opts.placeholder || '',
            resolve: null,
            reject: null
          };
          return new Promise(function (resolve, reject) {
            self.shellDialog.resolve = resolve;
            self.shellDialog.reject = reject;
          });
        },
        resolveShellDialog: function (action) {
          var dialog = this.shellDialog || {};
          var resolver = dialog.resolve;
          var result = { action: action || 'confirm', value: dialog.value || '' };
          this.shellDialog = { open: false, type: '', title: '', message: '', detail: '', confirmText: 'OK', cancelText: 'Cancel', value: '', placeholder: '', resolve: null, reject: null };
          if (resolver) resolver(result);
        },
        cancelShellDialog: function () {
          this.resolveShellDialog('cancel');
        },
        confirmDialog: function (title, message, opts) {
          opts = opts || {};
          return this.showDialog({
            type: 'confirm',
            title: title,
            message: message,
            detail: opts.detail || '',
            confirmText: opts.confirmText || this.t('common.ok', 'OK'),
            cancelText: opts.cancelText || this.t('common.cancel', 'Cancel')
          }).then(function (result) {
            return !!(result && result.action === 'confirm');
          });
        },
        inputDialog: function (title, message, value, opts) {
          opts = opts || {};
          return this.showDialog({
            type: 'input',
            title: title,
            message: message,
            detail: opts.detail || '',
            value: value || '',
            placeholder: opts.placeholder || '',
            confirmText: opts.confirmText || this.t('common.save', 'Save'),
            cancelText: opts.cancelText || this.t('common.cancel', 'Cancel')
          }).then(function (result) {
            if (!result || result.action !== 'confirm') return null;
            return String(result.value || '').trim();
          });
        },
        refreshSecurityCenter: function () {
          var self = this;
          var auditLimit = ((((this.boot || {}).auth || {}).audit || {}).reportLimit) || 20;
          var management = (((this.boot || {}).auth || {}).management) || {};
          this.securityCenter.loading = true;
          this.securityCenter.error = '';
          return Promise.all([
            this.command('auth.report', {}),
            this.command('auth.audit', { limit: auditLimit }),
            this.command('auth.sessions', { limit: management.sessionLimit || 20 }),
            this.command('auth.accounts', { limit: management.accountLimit || 20 })
          ])
            .then(function (results) {
              var report = (((results[0] || {}).auth) || {});
              var audit = (((results[1] || {}).auth) || {});
              var sessions = (((results[2] || {}).auth) || {});
              var accounts = (((results[3] || {}).auth) || {});
              self.securityCenter.report = report;
              self.securityCenter.trail = Array.isArray(audit.entries) ? audit.entries : [];
              self.securityCenter.sessions = Array.isArray(sessions.entries) ? sessions.entries : [];
              self.securityCenter.accounts = Array.isArray(accounts.entries) ? accounts.entries : [];
              self.securityCenter.refreshedAt = Date.now();
              return report;
            })
            .catch(function (err) {
              self.securityCenter.error = (err && (err.detail || err.error || err.message)) || 'security_center_failed';
              throw err;
            })
            .finally(function () {
              self.securityCenter.loading = false;
            });
        },
        securityReport: function () {
          return (this.securityCenter || {}).report || {};
        },
        securityTrail: function () {
          return Array.isArray((this.securityCenter || {}).trail) ? this.securityCenter.trail : [];
        },
        securitySessions: function () {
          return Array.isArray((this.securityCenter || {}).sessions) ? this.securityCenter.sessions : [];
        },
        securityAccounts: function () {
          return Array.isArray((this.securityCenter || {}).accounts) ? this.securityCenter.accounts : [];
        },
        lockedSecurityAccounts: function () {
          return this.securityAccounts().filter(function (entry) { return !!entry.locked; });
        },
        rotationRequiredSecurityAccounts: function () {
          return this.securityAccounts().filter(function (entry) { return !!entry.requiresChange; });
        },
        expiredSecurityAccounts: function () {
          return this.securityAccounts().filter(function (entry) { return !!entry.passwordExpired; });
        },
        warningSecurityAccounts: function () {
          return this.securityAccounts().filter(function (entry) { return !!entry.passwordExpiresSoon && !entry.passwordExpired; });
        },
        passwordStatusLabel: function (entry) {
          var status = (entry || {}).passwordStatus || 'healthy';
          if (status === 'rotation-required') return 'rotation required';
          if (status === 'expired') return 'expired';
          if (status === 'warning') return 'warning';
          return 'healthy';
        },
        revokeSecuritySession: function (sessionId) {
          var self = this;
          var actions = ((((this.boot || {}).desktop || {}).appActions) || {});
          if (!sessionId) return Promise.resolve();
          return ((actions.confirmBeforeDestructive && this.confirmDialog)
            ? this.confirmDialog('Revoke session', 'Revoke the selected session now?', { detail: sessionId, confirmText: 'Revoke' })
            : Promise.resolve(true)
          ).then(function (confirmed) {
            if (!confirmed) return null;
            self.securityCenter.loading = true;
            return self.command('auth.session.revoke', { sessionId: sessionId }).then(function () {
              if (actions.notifyOnAdminActions && self.notifySuccess) self.notifySuccess('Security Center', 'Session revoked.', { detail: sessionId });
              return self.refreshSecurityCenter();
            }).finally(function () {
              self.securityCenter.loading = false;
            });
          });
        },
        unlockSecurityUser: function (username) {
          var self = this;
          var actions = ((((this.boot || {}).desktop || {}).appActions) || {});
          if (!username) return Promise.resolve();
          return ((actions.confirmBeforeDestructive && this.confirmDialog)
            ? this.confirmDialog('Unlock account', 'Unlock the selected account now?', { detail: username, confirmText: 'Unlock' })
            : Promise.resolve(true)
          ).then(function (confirmed) {
            if (!confirmed) return null;
            self.securityCenter.loading = true;
            return self.command('auth.user.unlock', { username: username }).then(function () {
              if (actions.notifyOnAdminActions && self.notifySuccess) self.notifySuccess('Security Center', 'Account unlocked.', { detail: username });
              return self.refreshSecurityCenter();
            }).finally(function () {
              self.securityCenter.loading = false;
            });
          });
        },
        exportSecurityAudit: function () {
          var path = ((this.boot || {}).routes || {}).auditExport || '/api/mioos/auth/audit/export';
          if (!path) return;
          window.open(path, '_blank');
        },
        copySecuritySummary: function () {
          var payload = {
            report: this.securityReport() || {},
            sessions: this.securitySessions() || [],
            accounts: this.securityAccounts() || [],
            trail: this.securityTrail() || []
          };
          return this.copyTextToClipboard(JSON.stringify(payload, null, 2), {
            title: 'Security Center',
            message: 'Security summary copied.',
            detail: ((payload.sessions || []).length || 0) + ' sessions · ' + ((payload.accounts || []).length || 0) + ' accounts'
          });
        },
        pushDebugEvent: function (kind, name, detail, meta) {
          var limit = +((((this.boot || {}).desktop || {}).debugCenter || {}).eventLimit || 50) || 50;
          var entry = Object.assign({ id: 'dbg-' + (++this.debugCenter.seq), ts: Date.now(), kind: kind || 'event', name: name || '', detail: detail || '' }, meta || {});
          this.debugCenter.events.unshift(entry);
          if (this.debugCenter.events.length > limit) this.debugCenter.events.splice(limit);
          return entry;
        },
        clearDebugEvents: function () {
          var self = this;
          var actions = ((((this.boot || {}).desktop || {}).appActions) || {});
          var run = function () {
            self.debugCenter.events.splice(0, self.debugCenter.events.length);
            if (self.notifySuccess) self.notifySuccess('Debug Center', 'Debug events cleared.');
            return true;
          };
          if (actions.confirmBeforeDestructive && this.confirmDialog) return this.confirmDialog('Clear debug events', 'Clear all captured debug events from this shell session?', { confirmText: 'Clear' }).then(function (confirmed) { return confirmed ? run() : false; });
          return Promise.resolve(run());
        },
        debugSnapshot: function () {
          return (this.debugCenter || {}).snapshot || {};
        },
        debugEvents: function () {
          return Array.isArray((this.debugCenter || {}).events) ? this.debugCenter.events : [];
        },
        debugCommandRows: function () {
          return (((this.debugSnapshot() || {}).debug || {}).commands) || [];
        },
        refreshDebugCenter: function () {
          var self = this;
          this.debugCenter.loading = true;
          this.debugCenter.error = '';
          return this.command((((this.boot || {}).routes || {}).debugSnapshotCommand) || 'debug.snapshot', {}).then(function (msg) {
            self.debugCenter.snapshot = (msg && msg.debug) || {};
            self.debugCenter.refreshedAt = Date.now();
            self.pushDebugEvent('debug', 'snapshot', 'Debug snapshot refreshed', { source: 'server' });
            return self.debugCenter.snapshot;
          }).catch(function (err) {
            self.debugCenter.error = (err && (err.detail || err.error || err.message)) || 'debug_snapshot_failed';
            throw err;
          }).finally(function () {
            self.debugCenter.loading = false;
          });
        },
        exportDebugSnapshot: function () {
          var text = JSON.stringify(this.debugSnapshot() || {}, null, 2);
          this.pushDebugEvent('debug', 'export', 'Snapshot copied to debug buffer', { source: 'client' });
          this.copyTextToClipboard(text, { title: 'Debug Center', message: 'Debug snapshot copied.' });
          return text;
        },
        copyTransportDiagnostics: function () {
          var payload = {
            report: this.transportReport() || {},
            sockets: this.transportSocketRows() || [],
            summary: { session: (((this.transportReport() || {}).sessionId) || ((this.boot.session || {}).id) || 'mioos-shell'), updatedAt: this.transportDiagnostics.refreshedAt || 0 }
          };
          return this.copyTextToClipboard(JSON.stringify(payload, null, 2), { title: 'Transport Diagnostics', message: 'Diagnostics summary copied.' });
        },
        clearTransportTelemetry: function () {
          var self = this;
          var actions = ((((this.boot || {}).desktop || {}).appActions) || {});
          var run = function () {
            self.socketTelemetry = {};
            self.transportDiagnostics.error = '';
            if (self.notifySuccess) self.notifySuccess('Transport Diagnostics', 'Client telemetry cleared.');
            return true;
          };
          if (actions.confirmBeforeDestructive && this.confirmDialog) return this.confirmDialog('Clear telemetry', 'Clear client socket telemetry for this shell session?', { confirmText: 'Clear' }).then(function (confirmed) { return confirmed ? run() : false; });
          return Promise.resolve(run());
        },
        applyDocumentLocale: function () {
          if (I18N.applyDocumentLocale) I18N.applyDocumentLocale(this);
        },
        changeLocale: function (code) {
          if (I18N.changeLocale) I18N.changeLocale(this, code);
        },
        openTransfersWindow: function () {
          this.openApp('transfers');
        },
        transferPercent: function (item) {
          if (!item) return 0;
          if (+item.totalBytes > 0) return Math.max(0, Math.min(100, Math.round(((+item.processedBytes || 0) / (+item.totalBytes || 1)) * 100)));
          return +item.progress || 0;
        },
        activeTransfers: function () {
          return (this.transferCenter.items || []).filter(function (item) {
            return ['queued','preparing','uploading','downloading','finalizing','verifying','cancelling','paused'].indexOf(item.status) >= 0;
          });
        },
        completedTransfers: function () {
          return (this.transferCenter.items || []).filter(function (item) {
            return ['completed','failed','cancelled'].indexOf(item.status) >= 0;
          });
        },
        transferSummaryText: function () {
          var active = this.activeTransfers().filter(function (item) { return item.status !== 'paused'; }).length;
          var paused = this.activeTransfers().filter(function (item) { return item.status === 'paused'; }).length;
          var done = this.completedTransfers().length;
          return active + ' active · ' + paused + ' paused · ' + done + ' finished';
        },
        setSocketTelemetry: function (socketId, patch) {
          var base;
          if (!socketId) return;
          base = this.socketTelemetry[socketId] || { id: socketId, role: 'core', label: socketId, state: 'idle', pendingCount: 0, openedAt: 0, helloAt: 0, lastMessageAt: 0, lastEvent: '', lastError: '', ordinal: 0 };
          this.socketTelemetry[socketId] = Object.assign({}, base, patch || {});
        },
        removeSocketTelemetry: function (socketId) {
          if (!socketId || !this.socketTelemetry) return;
          delete this.socketTelemetry[socketId];
        },
        transportSocketRows: function () {
          return Object.keys(this.socketTelemetry || {}).map(function (key) { return Object.assign({ id: key }, (this.socketTelemetry || {})[key] || {}); }, this).sort(function (a, b) {
            var ar = String(a.role || '');
            var br = String(b.role || '');
            return ar.localeCompare(br) || (+a.ordinal || 0) - (+b.ordinal || 0) || String(a.id || '').localeCompare(String(b.id || ''));
          });
        },
        transportServerSocketRows: function () {
          return (((this.transportReport() || {}).socketPool || {}).sockets || []).slice().sort(function (a, b) {
            var ar = String((a && a.role) || '');
            var br = String((b && b.role) || '');
            return ar.localeCompare(br) || (+((a && a.ordinal) || 0)) - (+((b && b.ordinal) || 0)) || String((a && a.id) || '').localeCompare(String((b && b.id) || ''));
          });
        },
        transportServerPool: function () {
          return ((this.transportReport() || {}).socketPool) || {};
        },
        parseDateValue: function (value) {
          var parts;
          var days;
          var seconds;
          var base;
          if (value == null || value === '') return null;
          if (value instanceof Date) return isNaN(value.getTime()) ? null : value;
          if (typeof value === 'number') {
            if (!isFinite(value)) return null;
            base = new Date(value);
            return isNaN(base.getTime()) ? null : base;
          }
          if (typeof value === 'string') {
            parts = value.split(',');
            if (parts.length === 2 && /^-?\d+$/.test(parts[0]) && /^-?\d+$/.test(parts[1])) {
              days = Number(parts[0]);
              seconds = Number(parts[1]);
              base = new Date(Date.UTC(1840, 11, 31));
              base.setUTCDate(base.getUTCDate() + days);
              base.setUTCSeconds(base.getUTCSeconds() + seconds);
              return isNaN(base.getTime()) ? null : base;
            }
            base = new Date(value);
            return isNaN(base.getTime()) ? null : base;
          }
          return null;
        },
        formatTransportTime: function (value, opts) {
          var date = this.parseDateValue(value);
          opts = opts || { month: 'numeric', day: 'numeric', year: 'numeric', hour: 'numeric', minute: '2-digit' };
          if (!date) return '—';
          try { return date.toLocaleString((this.currentLocale || {}).code || undefined, opts); } catch (err) { return '—'; }
        },
        notificationTimeLabel: function (value) {
          var date = this.parseDateValue(value);
          if (!date) return '—';
          try { return date.toLocaleTimeString((this.currentLocale || {}).code || undefined, { hour: 'numeric', minute: '2-digit' }); } catch (err) { return '—'; }
        },
        transportReport: function () {
          return (this.transportDiagnostics && this.transportDiagnostics.report) || {};
        },
        refreshTransportDiagnostics: function () {
          var self = this;
          this.transportDiagnostics.loading = true;
          this.transportDiagnostics.error = '';
          return this.command('transport.health', {}).then(function (msg) {
            self.transportDiagnostics.loading = false;
            self.transportDiagnostics.refreshedAt = Date.now();
            self.transportDiagnostics.report = (msg && msg.transport) || {};
            return self.transportDiagnostics.report;
          }).catch(function (err) {
            self.transportDiagnostics.loading = false;
            self.transportDiagnostics.error = (err && (err.detail || err.error || err.message)) || 'transport_health_failed';
            throw err;
          });
        },
        ensureModuleWindowState: function () {
          var modules = this.boot.modules || [];
          (this.windows || []).forEach(function (win) {
            if (!win || !win.moduleWindow) return;
            if (!win.moduleState) win.moduleState = {};
            if (win.moduleState.draft == null) win.moduleState.draft = '';
            if (win.moduleState.filter == null) win.moduleState.filter = '';
            if (win.moduleState.lastOpenedAt == null) win.moduleState.lastOpenedAt = 0;
          });
          return modules;
        },
        moduleCatalogRows: function () {
          return (this.boot.modules || []).slice().sort(function (a, b) {
            return String(a.category || '').localeCompare(String(b.category || '')) || String(a.title || a.id || '').localeCompare(String(b.title || b.id || ''));
          });
        },
        moduleRecord: function (moduleId) {
          return (this.boot.modules || []).find(function (item) { return item.id === moduleId || item.appKey === moduleId; }) || null;
        },
        moduleWindowMeta: function (win) {
          if (!win) return null;
          return this.moduleRecord(win.moduleId || win.appKey);
        },
        moduleCards: function (module) {
          var cards = (module && module.cards) || [];
          return Array.isArray(cards) ? cards : [];
        },
        moduleBadges: function (module) {
          var badges = [];
          if (!module) return badges;
          if (module.builtIn) badges.push('Built-in');
          if (module.installed) badges.push('Installed');
          if (module.singleton) badges.push('Singleton');
          if (module.category) badges.push(String(module.category));
          return badges;
        },
        refreshModuleCatalog: function () {
          var self = this;
          this.moduleCatalog.loading = true;
          this.moduleCatalog.error = '';
          return this.command('module.catalog', {}).then(function (msg) {
            self.moduleCatalog.loading = false;
            self.moduleCatalog.refreshedAt = Date.now();
            self.boot.modules = window.MIOOSState.deepClone((((msg || {}).module || {}).modules) || []);
            self.ensureModuleWindowState();
            return self.boot.modules;
          }).catch(function (err) {
            self.moduleCatalog.loading = false;
            self.moduleCatalog.error = (err && (err.detail || err.error || err.message)) || 'module_catalog_failed';
            throw err;
          });
        },
        copyModuleCatalogManifest: function () {
          return this.copyTextToClipboard(JSON.stringify(this.moduleCatalogRows() || [], null, 2), {
            title: 'App Catalog',
            message: 'Module manifest copied.',
            detail: (this.moduleCatalogRows() || []).length + ' modules'
          });
        },
        openModuleCatalog: function () {
          this.openApp('app-catalog');
        },
        openModuleEntry: function (moduleId) {
          var module = this.moduleRecord(moduleId);
          if (!module) return;
          this.openApp(module.appKey || module.id);
        },
        moduleWindowStatus: function (win) {
          var module = this.moduleWindowMeta(win);
          if (!module) return 'Module unavailable';
          if (module.id === 'module-ops-center') return 'Session ' + (this.boot.session.id || 'mioos-shell') + ' · ' + (this.boot.user.displayName || 'Guest');
          if (module.id === 'module-notes') return 'Scratch surface · ' + ((win.moduleState && win.moduleState.draft && win.moduleState.draft.length) || 0) + ' chars';
          return module.description || module.subtitle || 'Ready';
        },
        copyModuleWindowState: function (win) {
          if (!win) return Promise.resolve(false);
          return this.copyTextToClipboard(JSON.stringify({ id: win.id, appKey: win.appKey, moduleId: win.moduleId || '', state: win.moduleState || {} }, null, 2), {
            title: 'Module Window',
            message: 'Module window state copied.',
            detail: win.title || win.id || ''
          });
        },
        clearModuleWindowNotes: function (win) {
          var self = this;
          var actions = ((((this.boot || {}).desktop || {}).appActions) || {});
          if (!win || !win.moduleState) return Promise.resolve(false);
          var run = function () {
            win.moduleState.draft = '';
            if (self.notifySuccess) self.notifySuccess('Module Notes', 'Scratch note cleared.');
            return true;
          };
          if (actions.confirmBeforeDestructive && this.confirmDialog) return this.confirmDialog('Clear module notes', 'Clear the current scratch note for this shell session?', { confirmText: 'Clear' }).then(function (confirmed) { return confirmed ? run() : false; });
          return Promise.resolve(run());
        },
        transferStorageKey: function () {
          var sessionId = (((this.boot || {}).session || {}).id) || 'mioos-shell';
          var userId = ((((this.boot || {}).user || {}).id) || (((this.boot || {}).user || {}).username) || (((this.boot || {}).user || {}).displayName) || 'guest');
          return 'mioos:transfers:' + sessionId + ':' + userId;
        },
        serializeTransferItem: function (item) {
          if (!item) return null;
          return window.MIOOSState.deepClone({ id: item.id, kind: item.kind, name: item.name, status: item.status, stage: item.stage, totalBytes: item.totalBytes, logicalBytes: item.logicalBytes, processedBytes: item.processedBytes, progress: item.progress, startedAt: item.startedAt, updatedAt: item.updatedAt, error: item.error, sourceWindowId: item.sourceWindowId, persistent: item.persistent, resume: item.resume || {} });
        },
        persistTransferCenter: function () {
          var payload;
          if (!window.localStorage) return;
          payload = { seq: (this.transferCenter || {}).seq || 0, items: ((this.transferCenter || {}).items || []).map(this.serializeTransferItem.bind(this)).filter(Boolean) };
          try { window.localStorage.setItem(this.transferStorageKey(), JSON.stringify(payload)); } catch (err) {}
        },
        restorePersistedTransfers: function () {
          var payload = null;
          if (!window.localStorage) return;
          try { payload = JSON.parse(window.localStorage.getItem(this.transferStorageKey()) || 'null'); } catch (err) { payload = null; }
          if (!payload) return;
          this.transferCenter.seq = +payload.seq || 0;
          this.transferCenter.items = Array.isArray(payload.items) ? payload.items : [];
        },
        revivePersistedTransfers: function () {
          var self = this;
          if (this._transferRecoveryRunning) return Promise.resolve();
          this._transferRecoveryRunning = true;
          return Promise.all(((this.transferCenter || {}).items || []).map(function (item) {
            if (!item || ['completed', 'cancelled'].indexOf(item.status) >= 0) return Promise.resolve();
            return self.recoverPersistedTransfer(item).catch(function () { return null; });
          })).finally(function () {
            self._transferRecoveryRunning = false;
            self.persistTransferCenter();
          });
        },
        recoverPersistedTransfer: function (item) {
          if (!item) return Promise.resolve();
          if (item.kind === 'upload' && this.recoverPersistedUploadTransfer) return this.recoverPersistedUploadTransfer(item, false);
          return Promise.resolve();
        },
        setTransferController: function (transferId, controller) {
          if (!transferId) return;
          this.transferControllers[transferId] = Object.assign({}, this.transferControllers[transferId] || {}, controller || {});
        },
        clearTransferController: function (transferId) {
          if (!transferId || !this.transferControllers) return;
          delete this.transferControllers[transferId];
        },
        transferController: function (transferId) {
          if (!transferId || !this.transferControllers) return null;
          return this.transferControllers[transferId] || null;
        },
        canCancelTransfer: function (item) {
          var ctrl = this.transferController(item && item.id);
          return !!(item && ctrl && ctrl.onCancel && ['queued','preparing','uploading','downloading','finalizing','verifying'].indexOf(item.status) >= 0);
        },
        canRetryTransfer: function (item) {
          var ctrl = this.transferController(item && item.id);
          return !!(item && ctrl && ctrl.onRetry && ['failed','cancelled'].indexOf(item.status) >= 0);
        },
        canPauseTransfer: function (item) {
          var ctrl = this.transferController(item && item.id);
          return !!(item && ctrl && ctrl.onPause && ['queued','preparing','uploading','downloading','finalizing','verifying'].indexOf(item.status) >= 0);
        },
        canResumeTransfer: function (item) {
          var ctrl = this.transferController(item && item.id);
          return !!(item && ctrl && ctrl.onResume && item.status === 'paused');
        },
        cancelTransfer: function (item) {
          var self = this;
          var ctrl = this.transferController(item && item.id);
          if (!item || !ctrl || !ctrl.onCancel) return Promise.resolve();
          this.updateTransfer(item.id, { status: 'cancelling', stage: 'Cancelling' });
          return Promise.resolve(ctrl.onCancel()).then(function () {
            self.updateTransfer(item.id, { status: 'cancelled', stage: 'Cancelled' });
          }).catch(function (err) {
            self.updateTransfer(item.id, { status: 'failed', stage: 'Cancel failed', error: (err && err.message) || 'transfer_cancel_failed' });
            throw err;
          });
        },
        retryTransfer: function (item) {
          var ctrl = this.transferController(item && item.id);
          if (!item || !ctrl || !ctrl.onRetry) return Promise.resolve();
          return Promise.resolve(ctrl.onRetry());
        },
        pauseTransfer: function (item) {
          var self = this;
          var ctrl = this.transferController(item && item.id);
          if (!item || !ctrl || !ctrl.onPause) return Promise.resolve();
          this.updateTransfer(item.id, { status: 'paused', stage: 'Pausing' });
          return Promise.resolve(ctrl.onPause()).then(function () {
            self.updateTransfer(item.id, { status: 'paused', stage: 'Paused' });
          }).catch(function (err) {
            self.updateTransfer(item.id, { status: 'failed', stage: 'Pause failed', error: (err && err.message) || 'transfer_pause_failed' });
            throw err;
          });
        },
        resumeTransfer: function (item) {
          var self = this;
          var ctrl = this.transferController(item && item.id);
          if (!item || !ctrl || !ctrl.onResume) return Promise.resolve();
          this.updateTransfer(item.id, { status: item.kind === 'download' ? 'downloading' : 'uploading', stage: 'Resuming' });
          return Promise.resolve(ctrl.onResume()).catch(function (err) {
            self.updateTransfer(item.id, { status: 'failed', stage: 'Resume failed', error: (err && err.message) || 'transfer_resume_failed' });
            throw err;
          });
        },
        autoPauseTransfer: function (item, stage) {
          var self = this;
          var ctrl = this.transferController(item && item.id);
          if (!item || !ctrl || !ctrl.onPause) return Promise.resolve();
          if (['paused','completed','cancelled','failed'].indexOf(item.status) >= 0) return Promise.resolve();
          return Promise.resolve(ctrl.onPause('auto')).catch(function () { return null; }).then(function () {
            self.updateTransfer(item.id, { status: 'paused', stage: stage || 'Paused (connection lost)', error: '' });
          });
        },
        autoPauseTransfersByReason: function (stage, kind) {
          var self = this;
          return Promise.all(((this.transferCenter || {}).items || []).map(function (item) {
            if (!item) return Promise.resolve();
            if (kind && item.kind !== kind) return Promise.resolve();
            if (['queued','preparing','uploading','downloading','finalizing','verifying'].indexOf(item.status) < 0) return Promise.resolve();
            return self.autoPauseTransfer(item, stage);
          })).then(function () {
            self.persistTransferCenter();
          });
        },
        registerTransfer: function (payload) {
          var next = Object.assign({
            id: 'transfer-' + Date.now() + '-' + (++this.transferCenter.seq),
            kind: 'upload',
            name: 'Transfer',
            status: 'queued',
            stage: 'Queued',
            totalBytes: 0,
            processedBytes: 0,
            progress: 0,
            startedAt: Date.now(),
            updatedAt: Date.now(),
            error: '',
            sourceWindowId: ''
          }, payload || {});
          this.transferCenter.items.unshift(next);
          if (this.transferCenter.items.length > 40) this.transferCenter.items = this.transferCenter.items.slice(0, 40);
          if (this.transferCenter.autoOpen && (next.kind === 'upload' || next.kind === 'download')) this.openTransfersWindow();
          this.persistTransferCenter();
          return next.id;
        },
        updateTransfer: function (transferId, patch) {
          var item = (this.transferCenter.items || []).find(function (entry) { return entry.id === transferId; });
          if (!item) return;
          Object.assign(item, patch || {});
          item.updatedAt = Date.now();
          item.progress = this.transferPercent(item);
          this.persistTransferCenter();
        },
        finalizeTransfer: function (transferId, ok, patch) {
          this.updateTransfer(transferId, Object.assign({
            status: ok ? 'completed' : 'failed',
            stage: ok ? 'Completed' : 'Failed'
          }, patch || {}));
          if (ok) this.clearTransferController(transferId);
          this.persistTransferCenter();
        },
        pauseAllTransfers: function () {
          var self = this;
          return Promise.all((this.activeTransfers() || []).map(function (item) {
            return self.canPauseTransfer(item) ? self.pauseTransfer(item) : Promise.resolve();
          })).then(function () { self.persistTransferCenter(); });
        },
        resumePausedTransfers: function () {
          var self = this;
          return Promise.all(((this.transferCenter || {}).items || []).map(function (item) {
            return self.canResumeTransfer(item) ? self.resumeTransfer(item) : Promise.resolve();
          })).then(function () { self.persistTransferCenter(); });
        },
        cancelActiveTransfers: function () {
          var self = this;
          var actions = ((((this.boot || {}).desktop || {}).appActions) || {});
          var run = function () {
            return Promise.all((self.activeTransfers() || []).map(function (item) {
              return self.canCancelTransfer(item) ? self.cancelTransfer(item).catch(function () { return null; }) : Promise.resolve();
            })).then(function () {
              self.persistTransferCenter();
              if (self.notifySuccess) self.notifySuccess('Transfer Center', 'Active transfers cancelled.');
            });
          };
          if (actions.confirmBeforeDestructive && this.confirmDialog) return this.confirmDialog('Cancel active transfers', 'Cancel all active transfers in this shell session?', { confirmText: 'Cancel transfers' }).then(function (confirmed) { return confirmed ? run() : null; });
          return run();
        },
        clearFinishedTransfers: function () {
          var self = this;
          var actions = ((((this.boot || {}).desktop || {}).appActions) || {});
          var run = function () {
            var keep = {};
            self.transferCenter.items = (self.transferCenter.items || []).filter(function (item) {
              var active = ['queued','preparing','uploading','downloading','finalizing','verifying','cancelling','paused'].indexOf(item.status) >= 0;
              if (active) keep[item.id] = 1;
              return active;
            });
            Object.keys(self.transferControllers || {}).forEach(function (key) {
              if (!keep[key]) delete (self.transferControllers || {})[key];
            }, self);
            self.persistTransferCenter();
            if (self.notifySuccess) self.notifySuccess('Transfer Center', 'Finished transfers cleared.');
            return true;
          };
          if (actions.confirmBeforeDestructive && this.confirmDialog) return this.confirmDialog('Clear finished transfers', 'Remove completed, failed, and cancelled transfers from the history list?', { confirmText: 'Clear history' }).then(function (confirmed) { return confirmed ? run() : false; });
          return Promise.resolve(run());
        },
        centerAuthWindow: function (force) {
          var width = Math.min(460, Math.max(380, (window.innerWidth || document.documentElement.clientWidth || 1280) - 32));
          var left = Math.max(16, Math.round((((window.innerWidth || document.documentElement.clientWidth || 1280) - width) / 2)));
          var top = Math.max(18, Math.round((((window.innerHeight || document.documentElement.clientHeight || 720) - 380) / 2) - 12));
          if (force || !(this.authWindow.left >= 0)) this.authWindow.left = left;
          if (force || !(this.authWindow.top >= 0)) this.authWindow.top = top;
          this.authWindow.width = width;
        },
        authWindowStyle: function () {
          return { width: (this.authWindow.width || 440) + 'px', '--mioos-auth-x': (this.authWindow.left || 0) + 'px', '--mioos-auth-y': (this.authWindow.top || 0) + 'px' };
        },
        beginAuthDrag: function (event) {
          if (!event || event.button !== 0) return;
          this.authDrag = { active: true, startX: event.clientX, startY: event.clientY, left: this.authWindow.left || 0, top: this.authWindow.top || 0 };
        },
        onAuthWindowMove: function (event) {
          var drag = this.authDrag || {};
          var maxLeft, maxTop;
          if (!drag.active) return;
          maxLeft = Math.max(16, (window.innerWidth || document.documentElement.clientWidth || 1280) - (this.authWindow.width || 440) - 16);
          maxTop = Math.max(18, (window.innerHeight || document.documentElement.clientHeight || 720) - 180);
          this.authWindow.left = Math.max(16, Math.min(maxLeft, (drag.left || 0) + (event.clientX - (drag.startX || 0))));
          this.authWindow.top = Math.max(18, Math.min(maxTop, (drag.top || 0) + (event.clientY - (drag.startY || 0))));
        },
        endAuthDrag: function () {
          if (!this.authDrag || !this.authDrag.active) return;
          this.authDrag.active = false;
          this.persistAuthWindowPosition();
        },
        desktopGridMetrics: function () {
          var size = this.desktopUi.iconSize || 'medium';
          if (size === 'small') return { width: 88, height: 90, icon: 28 };
          if (size === 'large') return { width: 112, height: 122, icon: 48 };
          return { width: 96, height: 104, icon: 36 };
        },
        desktopViewportHeight: function () {
          return Math.max(240, (window.innerHeight || document.documentElement.clientHeight || 720) - (+(((((this.boot || {}).desktop || {}).windowing || {}).taskbarHeight) || 40)) - 10);
        },
        desktopLayoutPayload: function () {
          return { iconSize: this.desktopUi.iconSize || 'medium', sortMode: this.desktopUi.sortMode || 'manual', positions: window.MIOOSState.deepClone(this.desktopUi.positions || {}) };
        },
        ensureDesktopLayout: function () {
          var self = this;
          var metrics = this.desktopGridMetrics();
          var col = 0;
          var row = 0;
          var viewportHeight = this.desktopViewportHeight();
          var cached = null;
          if (!this.desktopUi.positions) this.desktopUi.positions = {};
          if (!Object.keys(this.desktopUi.positions).length) {
            try { cached = JSON.parse(window.localStorage.getItem(this.desktopLayoutStorageKey()) || 'null'); } catch (err) { cached = null; }
            if (cached && cached.positions) {
              this.desktopUi.positions = window.MIOOSState.deepClone(cached.positions || {});
              if (cached.iconSize) this.desktopUi.iconSize = cached.iconSize;
              if (cached.sortMode) this.desktopUi.sortMode = cached.sortMode;
            }
          }
          (this.desktopEntries || []).forEach(function (entry) {
            if (!entry || !entry.key) return;
            if (!self.desktopUi.positions[entry.key]) {
              var left = +(entry.iconLeft || 0);
              var top = +(entry.iconTop || 0);
              if (!(left >= 0 && top >= 0)) {
                left = 16 + (col * metrics.width);
                top = 16 + (row * metrics.height);
                row += 1;
                if ((16 + ((row + 1) * metrics.height)) > viewportHeight) { row = 0; col += 1; }
              }
              self.desktopUi.positions[entry.key] = { left: left, top: top };
            }
          });
          Object.keys(this.desktopUi.positions).forEach(function (key) {
            var exists = (self.desktopEntries || []).some(function (entry) { return entry.key === key; });
            if (!exists) delete self.desktopUi.positions[key];
          });
          this.sortDesktopEntries(this.desktopUi.sortMode || 'manual', true);
        },
        desktopIconStyle: function (entry) {
          var pos = ((this.desktopUi || {}).positions || {})[entry.key] || { left: 16, top: 16 };
          return { '--mioos-x': (+pos.left || 16) + 'px', '--mioos-y': (+pos.top || 16) + 'px' };
        },
        desktopIconClass: function (entry) {
          return {
            'is-selected': ((this.desktopUi || {}).selectedKey || '') === entry.key,
            'is-small': (this.desktopUi.iconSize || 'medium') === 'small',
            'is-large': (this.desktopUi.iconSize || 'medium') === 'large',
            'is-list': (this.desktopUi.viewMode || 'details') === 'list'
          };
        },
        fsDesktopIconFor: function (item) {
          var kind = String(((item || {}).kind || '')).toLowerCase();
          var mime = String(((item || {}).mime || '')).toLowerCase();
          if (kind === 'folder') return ((item || {}).customize || {}).icon || '📁';
          if (mime.indexOf('image/') === 0) return '🖼';
          if (mime.indexOf('video/') === 0) return '🎞';
          if (mime.indexOf('audio/') === 0) return '🎵';
          if (mime.indexOf('application/pdf') === 0) return '📄';
          return '📄';
        },
        fsDesktopEntryFromItem: function (item) {
          if (!item || !item.id) return null;
          return {
            key: 'vfs:' + item.id,
            id: item.id,
            source: 'vfs',
            title: item.name || item.title || 'Item',
            subtitle: item.path || this.explorerItemTypeLabel(item),
            icon: this.fsDesktopIconFor(item),
            kind: item.kind || 'file',
            mime: item.mime || '',
            path: item.path || '',
            size: item.size || item.sizeBytes || 0,
            sizeLabel: item.sizeLabel || '',
            modifiedAt: item.modifiedAt || item.updatedAt || item.createdAt || ''
          };
        },
        rebuildDesktopEntries: function () {
          this.desktopEntries = window.MIOOSState.deepClone((this.desktopAppEntries || []).concat(this.desktopFolderEntries || []));
        },
        syncDesktopFolderEntries: function () {
          var self = this;
          var desktopId = ((((this.boot || {}).vfs || {}).desktopId) || '');
          if (!desktopId || !this.command) { this.desktopFolderEntries = []; this.rebuildDesktopEntries(); return Promise.resolve([]); }
          return this.command('fs.list', { id: desktopId, parent: '/Desktop' }).then(function (payload) {
            var rows = (((payload || {}).vfs || {}).entries) || [];
            var list = [];
            var i;
            for (i = 1; rows[i]; i += 1) {
              if (rows[i].attributes && +rows[i].attributes.hidden) continue;
              if (rows[i].name === 'Welcome.txt') continue;
              list.push(self.fsDesktopEntryFromItem(rows[i]));
            }
            self.desktopFolderEntries = list.filter(Boolean);
            self.rebuildDesktopEntries();
            self.ensureDesktopLayout();
            return self.desktopFolderEntries;
          }).catch(function () {
            self.desktopFolderEntries = [];
            self.rebuildDesktopEntries();
            return [];
          });
        },
        openDesktopEntry: function (entry) {
          var self = this;
          var win;
          if (!entry) return;
          if (entry.source === 'vfs') {
            if (String(entry.kind || '').toLowerCase() === 'folder') {
              win = this.windows.find(function (item) { return item.appKey === 'home'; }) || this.createWindowForApp('home') || this.createWindowForApp('explorer');
              if (win && this.loadExplorerFolder) this.loadExplorerFolder(win.id, entry.id, { selectFirst: true });
              return;
            }
            if (this.openImageViewerWindow && /image\//i.test(entry.mime || '')) return this.openImageViewerWindow(entry);
            if (this.openMediaViewerWindow && /(audio|video)\//i.test(entry.mime || '')) return this.openMediaViewerWindow(entry);
            if (this.openPdfViewerWindow && /application\/pdf/i.test(entry.mime || '')) return this.openPdfViewerWindow(entry);
            if (this.openStructuredViewerWindow && /(json|xml|yaml|csv|markdown)/i.test(entry.mime || '') ) return this.openStructuredViewerWindow(entry);
            if (this.openTextViewerWindow) return this.openTextViewerWindow(entry);
            return;
          }
          this.openApp(entry.key);
        },
        selectDesktopEntry: function (entry) {
          this.desktopUi.selectedKey = entry && entry.key ? entry.key : '';
        },
        beginDesktopIconDrag: function (entry, event) {
          var pos;
          if (!entry || !entry.key || !event || event.button !== 0) return;
          this.closeDesktopContextMenu();
          this.selectDesktopEntry(entry);
          pos = (this.desktopUi.positions || {})[entry.key] || { left: 16, top: 16 };
          this.desktopUi.drag = { armed: true, active: false, moved: false, key: entry.key, startX: event.clientX, startY: event.clientY, left: +pos.left || 16, top: +pos.top || 16 };
        },
        handleGlobalMouseMove: function (event) {
          this.onAuthWindowMove(event);
          if (this.onDragMove) this.onDragMove(event);
          this.onDesktopIconMove(event);
        },
        handleGlobalMouseUp: function (event) {
          if (this.endDrag) this.endDrag(event);
          this.endDesktopIconDrag(event);
          this.endAuthDrag(event);
        },
        onDesktopIconMove: function (event) {
          var drag = this.desktopUi.drag || {};
          var dx, dy, pos;
          if (!drag.armed || !drag.key) return;
          dx = event.clientX - (+drag.startX || 0);
          dy = event.clientY - (+drag.startY || 0);
          if (!drag.active && ((Math.abs(dx) > 4) || (Math.abs(dy) > 4))) drag.active = true;
          if (!drag.active) return;
          drag.moved = true;
          pos = this.desktopUi.positions[drag.key] || { left: drag.left || 16, top: drag.top || 16 };
          pos.left = Math.max(8, (drag.left || 16) + dx);
          pos.top = Math.max(8, Math.min(this.desktopViewportHeight() - this.desktopGridMetrics().height, (drag.top || 16) + dy));
          this.desktopUi.positions[drag.key] = pos;
        },
        endDesktopIconDrag: function () {
          var drag = this.desktopUi.drag || {};
          if (!drag.armed) return;
          if (drag.moved) this.persistDesktopLayout();
          this.desktopUi.drag = { armed: false, active: false, moved: false, key: '', startX: 0, startY: 0, left: 0, top: 0 };
        },
        desktopLayoutStorageKey: function () {
          return 'mioos.desktop.layout.' + (((this.boot || {}).user || {}).id || 'guest');
        },
        persistDesktopLayout: function () {
          var payload = this.desktopLayoutPayload();
          try { window.localStorage.setItem(this.desktopLayoutStorageKey(), JSON.stringify(payload)); } catch (err) {}
          if (this.socketRequest) {
            this.socketRequest((this.boot.routes || {}).commandEvent || 'desktop.command', { command: 'desktop.layout.save', iconSize: payload.iconSize, sortMode: payload.sortMode, positions: payload.positions }, { command: 'desktop.layout.save', dedupeKey: 'desktop.layout.save', timeoutMs: 3000 }).catch(function () {});
          }
        },
        refreshDesktopIcons: function () {
          this.refreshView();
          this.showAlert('Desktop', 'Desktop refreshed.');
        },
        rearrangeDesktopIcons: function () {
          var self = this;
          var metrics = this.desktopGridMetrics();
          var viewportHeight = this.desktopViewportHeight();
          var col = 0;
          var row = 0;
          (this.desktopEntries || []).forEach(function (entry) {
            self.desktopUi.positions[entry.key] = { left: 16 + (col * metrics.width), top: 16 + (row * metrics.height) };
            row += 1;
            if ((16 + ((row + 1) * metrics.height)) > viewportHeight) { row = 0; col += 1; }
          });
          this.desktopUi.sortMode = 'manual';
          this.persistDesktopLayout();
        },
        sortDesktopEntries: function (mode, silent) {
          var nextMode = mode || 'manual';
          if (nextMode === 'name') {
            this.desktopEntries.sort(function (a, b) { return String(a.title || a.key || '').localeCompare(String(b.title || b.key || '')); });
          } else if (nextMode === 'type') {
            this.desktopEntries.sort(function (a, b) { var ak = String(a.kind || ''); var bk = String(b.kind || ''); return ak.localeCompare(bk) || String(a.title || '').localeCompare(String(b.title || '')); });
          }
          this.desktopUi.sortMode = nextMode;
          if (nextMode !== 'manual') this.rearrangeDesktopIcons();
          else if (!silent) this.persistDesktopLayout();
        },
        setDesktopIconSize: function (size) {
          this.desktopUi.iconSize = size || 'medium';
          this.persistDesktopLayout();
        },
        openDesktopContextMenu: function (event) {
          if (!event) return;
          if (this.closeAllFolderContextMenus) this.closeAllFolderContextMenus();
          if (this.closeWindowMenu) this.closeWindowMenu();
          if (this.shellUi) this.shellUi.trayOpen = false;
          this.desktopUi.contextMenu = { open: true, type: 'desktop', key: '', left: event.clientX, top: event.clientY };
        },
        openDesktopIconContextMenu: function (entry, event) {
          if (!entry || !event) return;
          if (this.closeAllFolderContextMenus) this.closeAllFolderContextMenus();
          if (this.closeWindowMenu) this.closeWindowMenu();
          if (this.shellUi) this.shellUi.trayOpen = false;
          this.selectDesktopEntry(entry);
          this.desktopUi.contextMenu = { open: true, type: 'icon', key: entry.key, left: event.clientX, top: event.clientY };
        },
        closeDesktopContextMenu: function () { var menu = this.desktopContextMenuState(); menu.open = false; },
        contextMenuStyle: function () {
          var menu = this.desktopContextMenuState();
          return { left: (menu.left || 0) + 'px', top: (menu.top || 0) + 'px' };
        },
        contextMenuExplorerTargetWindow: function () {
          var menu = this.desktopContextMenuState();
          return (menu && menu.type === 'explorer-folder') ? (menu.windowId || '') : '';
        },
        contextMenuExplorerTargetFolder: function () {
          var menu = this.desktopContextMenuState();
          return (menu && menu.type === 'explorer-folder') ? (menu.folder || null) : null;
        },
        contextMenuExplorerTargetItem: function () {
          var menu = this.desktopContextMenuState();
          return (menu && menu.type === 'explorer-folder') ? (menu.item || null) : null;
        },
        contextMenuOpenSelected: function () {
          var windowId = this.contextMenuExplorerTargetWindow();
          var item = this.contextMenuExplorerTargetItem();
          if (!windowId) return;
          if (item && this.explorerOpenItem) this.explorerOpenItem(windowId, item);
          else if (this.explorerOpenSelected) this.explorerOpenSelected(windowId);
          this.closeDesktopContextMenu();
        },
        contextMenuDownloadSelected: function () {
          var windowId = this.contextMenuExplorerTargetWindow();
          if (windowId && this.explorerDownloadSelected) this.explorerDownloadSelected(windowId);
          this.closeDesktopContextMenu();
        },
        contextMenuDeleteSelected: function () {
          var windowId = this.contextMenuExplorerTargetWindow();
          if (windowId && this.explorerDeleteSelected) this.explorerDeleteSelected(windowId);
          this.closeDesktopContextMenu();
        },
        desktopContextEntry: function () {
          var menu = this.desktopContextMenuState();
          var key = (menu || {}).key || (this.desktopUi.selectedKey || '');
          return (this.desktopEntries || []).find(function (entry) { return entry.key === key; }) || null;
        },
        contextOpenSelected: function () {
          var entry = this.desktopContextEntry();
          this.closeDesktopContextMenu();
          if (entry) this.openDesktopEntry(entry);
        },
        contextControlPanel: function () { this.closeDesktopContextMenu(); this.openApp('customize'); },
        contextPersonalize: function () { this.closeDesktopContextMenu(); this.openApp('customize'); },
        contextDeleteIcon: function () { var self = this; var entry = this.desktopContextEntry(); this.closeDesktopContextMenu(); if (entry && entry.source === 'vfs' && this.command) { return this.command('fs.delete', { id: entry.id }).then(function () { if (self.syncDesktopFolderEntries) return self.syncDesktopFolderEntries(); }).then(function () { self.notifySuccess('Desktop', 'Item removed from Desktop.'); }).catch(function (err) { self.showAlert('Desktop', (err && err.message) || 'delete_failed'); }); } this.showAlert('Desktop', 'Desktop shortcuts are managed by installed modules.'); },
        taskbarMaxVisibleGroups: function () {
          var width = window.innerWidth || document.documentElement.clientWidth || 1280;
          if (width < 700) return 3;
          if (width < 980) return 5;
          return 7;
        },
        taskbarPrimaryGroups: function () {
          var groups = this.taskbarGroups || [];
          return groups.slice(0, this.taskbarMaxVisibleGroups());
        },
        taskbarOverflowGroups: function () {
          var groups = this.taskbarGroups || [];
          return groups.slice(this.taskbarMaxVisibleGroups());
        },
        activateTaskGroup: function (group) {
          var target;
          if (!group || !(group.windows || []).length) return;
          if (group.activeWindowId) {
            target = (group.windows || []).find(function (win) { return win.id === group.activeWindowId; });
          }
          if (!target) target = group.windows[group.windows.length - 1];
          if (target.state === 'minimized') this.restoreWindowAction(target.id);
          this.focusWindow(target.id);
        },
        cycleTaskGroup: function (group) {
          var activeIndex = -1;
          var next;
          if (!group || !(group.windows || []).length) return;
          group.windows.forEach(function (win, index) { if (win.id === this.activeWindowId) activeIndex = index; }.bind(this));
          next = group.windows[(activeIndex + 1) % group.windows.length];
          if (!next) next = group.windows[0];
          if (next.state === 'minimized') this.restoreWindowAction(next.id);
          this.focusWindow(next.id);
        },
        toggleTaskGroup: function (group) {
          if (!group) return;
          if (group.count > 1) { this.cycleTaskGroup(group); return; }
          this.activateTaskGroup(group);
        },
        closeTaskGroup: function (group) {
          (group && group.windows || []).forEach(function (win) { this.closeWindow(win.id); }.bind(this));
        },

        themeStudioStorageKey: function () {
          return 'mioos.themeStudio.applied.v1';
        },
        themeStudioProfilesKey: function () {
          return 'mioos.themeStudio.profiles.v1';
        },
        themeStudioRootNode: function () {
          return window.MIOOSState.getRootNode ? window.MIOOSState.getRootNode() : null;
        },
        themeStudioSanitizeColor: function (value, fallback) {
          var color = String(value || '').trim();
          if ((/^#[0-9a-fA-F]{6}$/).test(color)) return color;
          if ((/^(rgb|rgba|hsl|hsla)\(/).test(color)) return color;
          if (color.indexOf('color-mix(') === 0) return color;
          return fallback;
        },
        themeStudioCanonicalPresetKey: function (presetKey) {
          var key = String(presetKey || '').toLowerCase();
          var map = {
            'xp-classic-blue': 'luna-blue',
            'xp-classic-dark': 'royale-noir',
            'meadow-classic': 'meadow-classic-light',
            'glass-horizon': 'glass-horizon-light',
            'graphite-dock': 'graphite-dock-light',
            'ember-panel': 'ember-panel-light'
          };
          return map[key] || key || 'glass-horizon-light';
        },
        themeStudioFamilyKey: function (presetKey) {
          var key = this.themeStudioCanonicalPresetKey(presetKey);
          if (['luna-blue', 'royale-noir', 'meadow-classic-light', 'meadow-classic-dark'].indexOf(key) >= 0) return 'meadow-classic';
          if (['aero-glass', 'aero-midnight', 'glass-horizon-light', 'glass-horizon-dark'].indexOf(key) >= 0) return 'glass-horizon';
          if (['graphite-dock-light', 'graphite-dock-dark'].indexOf(key) >= 0) return 'graphite-dock';
          if (['ubuntu-human', 'ubuntu-graphite', 'ember-panel-light', 'ember-panel-dark'].indexOf(key) >= 0) return 'ember-panel';
          return 'custom';
        },
        themeStudioFamilyLabel: function (familyKey) {
          var key = String(familyKey || '').toLowerCase();
          if (key === 'meadow-classic') return 'Meadow Classic';
          if (key === 'glass-horizon') return 'Glass Horizon';
          if (key === 'graphite-dock') return 'Graphite Dock';
          if (key === 'ember-panel') return 'Ember Panel';
          return 'Custom';
        },
        themeStudioNormalizeProfile: function (profile) {
          var incoming = profile || {};
          var base = this.themeStudioFactoryProfile('Custom Theme', 'Custom', incoming.activeMode || incoming.mode || 'light');
          var next = Object.assign({}, base, incoming || {});
          var desktopIn = incoming.desktop || {};
          var appearanceIn = incoming.appearance || {};
          var panelIn = incoming.panel || {};
          var launcherIn = incoming.launcher || {};
          var windowChromeIn = incoming.windowChrome || {};
          var colorsIn = incoming.colors || {};
          next.presetKey = this.themeStudioCanonicalPresetKey(next.presetKey || 'glass-horizon-light');
          next.familyKey = incoming.familyKey || next.familyKey || this.themeStudioFamilyKey(next.presetKey);
          next.family = incoming.family || next.family || this.themeStudioFamilyLabel(next.familyKey);
          next.mode = ((incoming.activeMode || incoming.mode || next.mode || 'light') === 'dark') ? 'dark' : 'light';
          next.activeMode = next.mode;
          next.density = incoming.density || appearanceIn.density || next.density || base.density || 'comfortable';
          next.coverage = Object.assign({}, base.coverage, incoming.coverage || {});
          next.appearance = Object.assign({}, base.appearance, appearanceIn || {});
          next.desktop = Object.assign({}, base.desktop, desktopIn || {});
          next.panel = Object.assign({}, base.panel, panelIn || {});
          next.launcher = Object.assign({}, base.launcher, launcherIn || {});
          next.windowChrome = Object.assign({}, base.windowChrome, windowChromeIn || {});
          next.fonts = Object.assign({}, base.fonts, incoming.fonts || {});
          next.metrics = Object.assign({}, base.metrics, incoming.metrics || {});
          next.effects = Object.assign({}, base.effects, incoming.effects || {});
          next.validation = Object.assign({}, base.validation, incoming.validation || {});
          next.exports = Object.assign({}, base.exports, incoming.exports || {});
          next.mobile = Object.assign({}, base.mobile, incoming.mobile || {});
          next.targets = Object.assign({}, base.targets, incoming.targets || {});
          next.colors = Object.assign({}, base.colors, colorsIn || {});
          next.recipes = Object.assign({}, base.recipes, incoming.recipes || {});
          if (incoming.wallpaperPreset && !desktopIn.wallpaperPreset) next.desktop.wallpaperPreset = incoming.wallpaperPreset;
          if (incoming.wallpaperUrl && !desktopIn.wallpaperUrl) next.desktop.wallpaperUrl = incoming.wallpaperUrl;
          if (incoming.wallpaperFit && !desktopIn.wallpaperFit) next.desktop.wallpaperFit = incoming.wallpaperFit;
          if (incoming.desktopColor && !desktopIn.color) next.desktop.color = incoming.desktopColor;
          if (incoming.colors && incoming.colors.accent) next.appearance.accent = incoming.colors.accent;
          if (incoming.colors && incoming.colors.titlebar) next.windowChrome.titleTop = incoming.colors.titlebar;
          if (incoming.colors && incoming.colors.startButton) next.panel.startTop = incoming.colors.startButton;
          if (incoming.colors && incoming.colors.taskbar) next.panel.taskbarTop = incoming.colors.taskbar;
          if (incoming.metrics && incoming.metrics.taskbarHeight) next.panel.height = +(incoming.metrics.taskbarHeight || next.panel.height);
          if (incoming.metrics && incoming.metrics.iconSize) next.desktop.iconSize = +(incoming.metrics.iconSize || next.desktop.iconSize);
          next.colors.accent = next.appearance.accent || next.colors.accent;
          next.colors.accentStrong = next.colors.accentStrong || next.colors.accent;
          next.colors.titlebar = next.windowChrome.titleTop;
          next.colors.inactiveTitlebar = next.windowChrome.titleBottom;
          next.colors.taskbar = next.panel.taskbarTop;
          next.colors.taskbarDark = next.panel.taskbarBottom;
          next.colors.startButton = next.panel.startTop;
          next.colors.taskbarText = next.colors.taskbarText || '#ffffff';
          next.colors.titleText = next.colors.titleText || '#173a68';
          next.colors.panel = next.colors.panel || '#f8fbff';
          next.colors.panelAlt = next.colors.panelAlt || '#ffffff';
          next.colors.panelText = next.colors.panelText || '#1a314d';
          next.colors.iconText = next.colors.iconText || '#f6fbff';
          next.colors.border = next.colors.border || '#86a2c5';
          next.colors.focus = next.colors.focus || '#ffd86c';
          next.desktopColor = next.desktop.color || next.desktopColor || '#183b66';
          next.wallpaperPreset = next.desktop.wallpaperPreset;
          next.wallpaperUrl = next.desktop.wallpaperUrl;
          next.wallpaperFit = next.desktop.wallpaperFit;
          next.customVariablesJson = String(next.customVariablesJson || base.customVariablesJson || '{\n}');
          next.extraCss = String(next.extraCss || '');
          next.notes = String(next.notes || '');
          return next;
        },
        themeStudioPersistProfiles: function () {
          try {
            var payload = [];
            this.windows.forEach(function (win) {
              var state = win && win.themeStudioState;
              if (!state || !Array.isArray(state.profiles)) return;
              payload = state.profiles;
            });
            this.themeStudioProfilesCache = payload || [];
            window.localStorage.setItem(this.themeStudioProfilesKey(), JSON.stringify(payload || []));
          } catch (err) {}
        },
        themeStudioEnsureStyleNode: function () {
          var node = document.getElementById(this.themeStyleNodeId);
          if (!node) {
            node = document.createElement('style');
            node.id = this.themeStyleNodeId;
            document.head.appendChild(node);
          }
          return node;
        },
        themeStudioWallpaperCss: function (profile) {
          var p = this.themeStudioNormalizeProfile(profile || {});
          var desktop = p.desktop || {};
          var overlay = String(desktop.overlay || 'gloss');
          var wallpaperTop = desktop.wallpaperTop || '#2d66c2';
          var wallpaperMiddle = desktop.wallpaperMiddle || '#153a79';
          var wallpaperBottom = desktop.wallpaperBottom || '#0d244b';
          var fit = desktop.wallpaperFit || 'cover';
          var mode = desktop.wallpaperPreset || p.appearance.wallpaperMode || 'gradient-gloss';
          var base = 'linear-gradient(180deg, ' + wallpaperTop + ' 0%, ' + wallpaperMiddle + ' 52%, ' + wallpaperBottom + ' 100%)';
          if (mode === 'custom-url' && desktop.wallpaperUrl) {
            return 'linear-gradient(180deg, rgba(255,255,255,0.12), rgba(255,255,255,0.02)), url(' + desktop.wallpaperUrl + ') center / ' + (fit === 'tile' ? '240px auto' : fit) + ' ' + (fit === 'tile' ? 'repeat' : 'no-repeat');
          }
          if (mode === 'aurora') return 'linear-gradient(180deg, #183b66 0%, #365d93 42%, #87a6cf 100%)';
          if (mode === 'aurora-night' || mode === 'paper-night') return 'linear-gradient(180deg, #0f1726 0%, #1d2a41 100%)';
          if (mode === 'paper-dawn') return 'linear-gradient(180deg, #f5f7fb 0%, #d9e2f4 100%)';
          if (mode === 'sunrise-grid') return 'linear-gradient(180deg, #c84f2c 0%, #ea8a5a 48%, #f3d7c6 100%)';
          if (mode === 'midnight-grid') return 'linear-gradient(180deg, #3c1f2a 0%, #1c1320 55%, #0f0a10 100%)';
          if (mode === 'solid-blue') return '#245edb';
          if (mode === 'solid-graphite') return '#5f6773';
          if (overlay === 'gloss' || mode === 'gradient-gloss') {
            return 'radial-gradient(circle at 18% 18%, rgba(255,255,255,0.18), transparent 24%), radial-gradient(circle at 82% 10%, rgba(255,255,255,0.12), transparent 20%), ' + base;
          }
          return base;
        },
        availableShellThemes: function () {
          return ((((this.boot || {}).desktop || {}).themes) || []).slice();
        },
        shellDensityOptions: function () {
          return (((((this.boot || {}).desktop || {}).themeSystem || {}).densityOptions) || ['compact','comfortable','spacious']).slice();
        },
        themeStudioPresetFamilies: function () {
          return [
            { key: 'meadow-classic', name: 'Meadow Classic', description: 'Brighter classic shell with stronger bevels and a calm enterprise desktop.' },
            { key: 'glass-horizon', name: 'Glass Horizon', description: 'Glossy blue shell with glassy titlebars and refined aero-like contrast.' },
            { key: 'graphite-dock', name: 'Graphite Dock', description: 'Graphite metallic shell with dock-ready surfaces and restrained chrome.' },
            { key: 'ember-panel', name: 'Ember Panel', description: 'Warm panel desktop with balanced contrast and Ubuntu-inspired utility surfaces.' }
          ];
        },
        applyBootThemeDefaults: function () {
          var desktop = (this.boot || {}).desktop || {};
          var preset = this.themeStudioPresetProfile(desktop.themeKey || 'luna-blue');
          preset.mode = desktop.themeMode || preset.mode || 'light';
          preset.activeMode = preset.mode;
          preset.density = desktop.density || preset.density || 'comfortable';
          if (desktop.wallpaper) preset.desktop.wallpaperPreset = desktop.wallpaper;
          this.applyThemeStudioProfile(preset, { silent: true, persist: false });
        },
        applyPersistedThemeStudioProfile: function () {
          var raw;
          try {
            raw = window.localStorage.getItem(this.themeStudioStorageKey());
            if (!raw) return;
            this.appliedThemeProfile = this.themeStudioNormalizeProfile(JSON.parse(raw));
            this.applyThemeStudioProfile(this.appliedThemeProfile, { silent: true, persist: false });
          } catch (err) {}
        },
        themeStudioRemotePayload: function () {
          return { key: this.themeStudioActiveKey || '' };
        },
        themeStudioRequest: function (routeKey, payload) {
          var route = ((((this.boot || {}).routes || {})[routeKey]) || '');
          return new Promise(function (resolve, reject) {
            var xhr;
            var body;
            if (!route) { reject(new Error('route_missing')); return; }
            xhr = new XMLHttpRequest();
            xhr.open('POST', route, true);
            xhr.setRequestHeader('Content-Type', 'application/json');
            xhr.onreadystatechange = function () {
              if (xhr.readyState !== 4) return;
              try { body = JSON.parse(xhr.responseText || '{}'); } catch (err) { body = {}; }
              if (xhr.status >= 200 && xhr.status < 300) { resolve(body); return; }
              reject(new Error(body.detail || body.error || ('http_' + xhr.status)));
            };
            xhr.onerror = function () { reject(new Error('network_error')); };
            xhr.send(JSON.stringify(payload || {}));
          });
        },
        themeStudioLoadRemote: function () {
          var self = this;
          if (this.requiresSignin) return Promise.resolve(null);
          return this.themeStudioRequest('themeLoad', this.themeStudioRemotePayload()).then(function (msg) {
            var profiles = [];
            var i = 0;
            var item;
            self.themeStudioProfilesCache = [];
            self.themeStudioActiveKey = (msg && msg.activeKey) || '';
            for (i = 1; msg && msg.profiles && msg.profiles[i]; i += 1) {
              item = msg.profiles[i];
              profiles.push({ key: item.key, name: item.name || item.key, family: item.family || 'Custom', mode: item.mode || 'light', data: item.data || null });
            }
            self.themeStudioProfilesCache = profiles;
            (self.windows || []).forEach(function (win) {
              if (!win || !win.themeStudioState) return;
              win.themeStudioState.profiles = profiles.slice();
              if (self.themeStudioActiveKey) win.themeStudioState.profileKey = self.themeStudioActiveKey;
            });
            if (msg && msg.profile && Object.keys(msg.profile).length) {
              self.appliedThemeProfile = self.themeStudioNormalizeProfile(msg.profile);
              self.applyThemeStudioProfile(self.appliedThemeProfile, { silent: true, persist: true });
            }
            return msg;
          }).catch(function () { return null; });
        },
        themeStudioSaveRemote: function (entry, activate) {
          var self = this;
          return this.themeStudioRequest('themeSave', { key: (entry || {}).key || '', activate: activate ? 1 : 0, profile: (entry || {}).data || entry || {} }).then(function (msg) {
            self.themeStudioActiveKey = (msg && msg.activeKey) || ((entry || {}).key || '');
            return self.themeStudioLoadRemote().then(function () { return msg; });
          });
        },
        setShellTheme: function (themeKey) {
          var current = this.appliedThemeProfile ? window.MIOOSState.deepClone(this.appliedThemeProfile) : this.themeStudioPresetProfile((((this.boot || {}).desktop || {}).themeKey) || 'luna-blue');
          var next = this.themeStudioPresetProfile(themeKey || 'glass-horizon-light');
          next.density = current.density || next.density || 'comfortable';
          this.applyThemeStudioProfile(next, { persist: true });
        },
        setDesktopDensity: function (density) {
          var next = this.appliedThemeProfile ? window.MIOOSState.deepClone(this.appliedThemeProfile) : this.themeStudioPresetProfile((((this.boot || {}).desktop || {}).themeKey) || 'glass-horizon-light');
          next.density = density || 'comfortable';
          this.applyThemeStudioProfile(next, { silent: true, persist: true });
          this.showAlert('Shell Density', 'Density set to ' + next.density + '.');
        },
        applyThemeStudioProfile: function (profile, options) {
          var rootNode = this.themeStudioRootNode();
          var opts = options || {};
          var p = this.themeStudioNormalizeProfile(profile || {});
          var desktop = p.desktop || {};
          var appearance = p.appearance || {};
          var panel = p.panel || {};
          var launcher = p.launcher || {};
          var windowChrome = p.windowChrome || {};
          var fonts = p.fonts || {};
          var metrics = p.metrics || {};
          var effects = p.effects || {};
          var colors = p.colors || {};
          var body = document.body;
          var styleNode = this.themeStudioEnsureStyleNode();
          var vars;
          if (!rootNode) return;
          vars = {
            '--mioos-font': fonts.ui || '"Segoe UI", Tahoma, sans-serif',
            '--mioos-font-mono': fonts.mono || 'Consolas, monospace',
            '--mioos-blue-1': this.themeStudioSanitizeColor(colors.accent || appearance.accent, '#72a8ff'),
            '--mioos-blue-2': this.themeStudioSanitizeColor(colors.accentStrong || colors.accent || appearance.accent, '#4d7cff'),
            '--mioos-taskbar': this.themeStudioSanitizeColor(panel.taskbarTop || colors.taskbar, '#6385bd'),
            '--mioos-taskbar-dark': this.themeStudioSanitizeColor(panel.taskbarBottom || colors.taskbarDark || colors.taskbar, '#24406f'),
            '--mioos-start': this.themeStudioSanitizeColor(panel.startTop || colors.startButton, '#7fd25f'),
            '--mioos-start-bottom': this.themeStudioSanitizeColor(panel.startBottom || panel.startTop || colors.startButton, '#2f7e22'),
            '--mioos-text': this.themeStudioSanitizeColor(colors.panelText, '#173455'),
            '--mioos-muted': this.themeStudioSanitizeColor(colors.muted, '#5a7087'),
            '--mioos-titlebar': this.themeStudioSanitizeColor(windowChrome.titleTop || colors.titlebar, '#6f93c7'),
            '--mioos-taskbar-text': this.themeStudioSanitizeColor(colors.taskbarText, '#ffffff'),
            '--mioos-window-radius': Math.max(0, +(metrics.windowRadius || appearance.cornerRadius || 10)) + 'px',
            '--mioos-taskbar-height': Math.max(36, +(panel.height || 46)) + 'px',
            '--mioos-titlebar-height': Math.max(28, +(windowChrome.titleHeight || 34)) + 'px',
            '--mioos-caption-size': Math.max(20, +(windowChrome.captionButtonSize || 24)) + 'px',
            '--mioos-title-size': Math.max(12, +(fonts.titleSize || 12)) + 'px',
            '--mioos-base-size': Math.max(11, +(fonts.baseSize || 12)) + 'px',
            '--mioos-launcher-width': Math.max(320, +(launcher.width || 376)) + 'px',
            '--mioos-launcher-height': Math.max(260, +(launcher.height || 314)) + 'px',
            '--mioos-start-min-width': Math.max(72, +(panel.startMinWidth || 92)) + 'px',
            '--mioos-task-min-width': Math.max(88, +(panel.taskMinWidth || 122)) + 'px',
            '--mioos-sidebar-width': Math.max(180, +(windowChrome.sidebarWidth || 220)) + 'px',
            '--mioos-preview-width': Math.max(220, +(windowChrome.previewWidth || 272)) + 'px',
            '--mioos-blur-strength': Math.max(0, +(effects.blurStrength || 14)) + 'px',
            '--mioos-transparency': Math.max(0, +(effects.transparency || 38)) + '%',
            '--mioos-selection-opacity': Math.max(8, +(desktop.selectionOpacity || 25)) + '%',
            '--mioos-icon-grid-gap': Math.max(8, +(desktop.iconSpacing || 16)) + 'px',
            '--mioos-icon-size': Math.max(32, +(desktop.iconSize || 54)) + 'px',
            '--mioos-desktop-label-size': Math.max(10, +(desktop.labelSize || 11)) + 'px',
            '--mioos-launcher-body': this.themeStudioSanitizeColor(launcher.bodyBackground || colors.panel || '#f9fbff', '#f9fbff'),
            '--mioos-launcher-rail': this.themeStudioSanitizeColor(launcher.rightBackground || colors.panelAlt || '#dfe8f6', '#dfe8f6'),
            '--mioos-control-height': Math.max(20, +(metrics.controlHeight || 24)) + 'px',
            '--mioos-shadow': '0 ' + Math.max(10, +(metrics.shadowDepth || 18)) + 'px ' + Math.max(22, +(metrics.shadowDepth || 18) * 2) + 'px rgba(17, 31, 52, 0.24)',
            '--mioos-shell-glass-top': 'rgba(255,255,255,' + (0.70 + (Math.min(60, +(effects.transparency || 38)) / 1000)).toFixed(2) + ')',
            '--mioos-shell-glass-bottom': 'rgba(225,235,248,' + (0.82 + (Math.min(60, +(effects.transparency || 38)) / 1200)).toFixed(2) + ')',
            '--mioos-shell-launcher-width': Math.max(320, +(launcher.width || 376)) + 'px',
            '--mioos-shell-launcher-height': Math.max(260, +(launcher.height || 314)) + 'px',
            '--mioos-shell-menu-width': 'min(' + Math.max(320, +(launcher.width || 376)) + 'px, calc(100vw - 20px))',
            '--mioos-shell-start-min-width': Math.max(72, +(panel.startMinWidth || 92)) + 'px',
            '--mioos-shell-task-min-width': Math.max(88, +(panel.taskMinWidth || 122)) + 'px',
            '--mioos-shell-sidebar-width': Math.max(180, +(windowChrome.sidebarWidth || 220)) + 'px',
            '--mioos-shell-preview-width': Math.max(220, +(windowChrome.previewWidth || 272)) + 'px',
            '--mioos-shell-title-height': Math.max(28, +(windowChrome.titleHeight || 34)) + 'px',
            '--mioos-shell-caption-size': Math.max(20, +(windowChrome.captionButtonSize || 24)) + 'px',
            '--mioos-titlebar-bottom': this.themeStudioSanitizeColor(windowChrome.titleBottom || windowChrome.titleTop || colors.titlebar, '#4e6e9f'),
            '--mioos-launcher-header-top': this.themeStudioSanitizeColor(launcher.headerTop || panel.startTop || '#3769ab', '#3769ab'),
            '--mioos-launcher-header-bottom': this.themeStudioSanitizeColor(launcher.headerBottom || panel.startBottom || '#173c6f', '#173c6f')
          };
          Object.keys(vars).forEach(function (key) { rootNode.style.setProperty(key, vars[key]); });
          rootNode.style.setProperty('--mioos-desktop-background', this.themeStudioWallpaperCss(p));
          rootNode.dataset.themeKey = p.presetKey || 'glass-horizon-light';
          rootNode.dataset.themeMode = p.mode || 'light';
          rootNode.dataset.themeFamily = p.familyKey || this.themeStudioFamilyKey(p.presetKey);
          rootNode.dataset.themeDensity = p.density || appearance.density || 'comfortable';
          rootNode.dataset.density = p.density || appearance.density || 'comfortable';
          if (this.boot && this.boot.desktop) {
            this.boot.desktop.themeKey = rootNode.dataset.themeKey;
            this.boot.desktop.themeMode = rootNode.dataset.themeMode;
            this.boot.desktop.density = rootNode.dataset.themeDensity;
          }
          this.desktopUi.iconSize = +(desktop.iconSize || 0) >= 44 ? 'large' : (+(desktop.iconSize || 0) <= 34 ? 'small' : (this.desktopUi.iconSize || 'medium'));
          rootNode.classList.remove('mioos-theme-dark', 'mioos-theme-light', 'mioos-density-compact', 'mioos-density-spacious');
          rootNode.classList.add((p.mode || 'light') === 'dark' ? 'mioos-theme-dark' : 'mioos-theme-light');
          if ((p.density || '') === 'compact') rootNode.classList.add('mioos-density-compact');
          if ((p.density || '') === 'spacious') rootNode.classList.add('mioos-density-spacious');
          body.style.background = desktop.color || '#153a79';
          if (document && document.documentElement) document.documentElement.style.colorScheme = (p.mode || 'light');
          styleNode.textContent = (p.extraCss || '') + '\n' + '#mioosRoot{--mioos-desktop-background:' + this.themeStudioWallpaperCss(p) + ';}\n' + ((p.desktopCssHint || '') ? ('#mioosRoot{' + p.desktopCssHint + '}') : '');
          if (!opts.silent) this.showAlert('Customize', (p.name || 'Custom Theme') + ' applied.');
          this.appliedThemeProfile = window.MIOOSState.deepClone(p);
          if (opts.persist !== false) {
            try { window.localStorage.setItem(this.themeStudioStorageKey(), JSON.stringify(p)); } catch (err) {}
          }
        },
        themeStudioTabList: function () {
          return [
            { key: 'general', label: 'General' },
            { key: 'modes', label: 'Modes & Presets' },
            { key: 'shell', label: 'Desktop & Shell' },
            { key: 'launcher', label: 'Panel / Start / Dock' },
            { key: 'window', label: 'Windows & Controls' },
            { key: 'typography', label: 'Typography & Metrics' },
            { key: 'effects', label: 'Effects' }
          ];
        },
        themeStudioFactoryProfile: function (name, family, mode) {
          return {
            presetKey: '',
            name: name || 'Aurora Shell',
            author: (this.boot.user && this.boot.user.displayName) || 'MIOOS User',
            familyKey: family && family !== 'Custom' ? String(family || '').toLowerCase().replace(/\s+/g, '-') : 'custom',
            family: family || 'Custom',
            mode: mode || 'light',
            activeMode: mode || 'light',
            density: 'comfortable',
            coverage: { meadowClassic: 1, glassHorizon: 1, graphiteDock: 1, emberPanel: 1 },
            appearance: { target: 'mouse-keyboard-desktop', accent: '#72a8ff', cornerRadius: 10, panelPosition: 'bottom', launcherLayout: 'two-column', wallpaperMode: 'gradient-gloss' },
            desktop: { wallpaperPreset: 'gradient-gloss', wallpaperUrl: '', wallpaperFit: 'cover', wallpaperTop: '#2d66c2', wallpaperMiddle: '#153a79', wallpaperBottom: '#0d244b', overlay: 'gloss', color: '#153a79', iconSize: 54, iconSpacing: 16, labelSize: 11, labelOverflow: 'two-line', labelGlow: 1, selectionOpacity: 25, contextMenuDensity: 'balanced', contextMenuIcons: 1, contextMenuShortcuts: 1 },
            panel: { style: 'glass-bar', height: 46, taskMinWidth: 122, grouping: 'when-full', startStyle: 'orb-capsule', startMinWidth: 92, startTop: '#7fd25f', startBottom: '#2f7e22', taskbarTop: '#6385bd', taskbarBottom: '#24406f', trayStyle: 'glass', dateVisible: 1, clockLayout: 'stacked' },
            launcher: { layout: 'two-column', width: 376, height: 314, avatarVisible: 1, searchEnabled: 1, leftRatio: 1.1, rightRatio: 0.9, headerTop: '#3769ab', headerBottom: '#173c6f', bodyBackground: '#f9fbff', rightBackground: '#dfe8f6', footerText: '#476076' },
            windowChrome: { style: 'glass-gradient', titleHeight: 34, captionButtonSize: 24, titleTop: '#6f93c7', titleBottom: '#4e6e9f', menubarVisible: 0, toolbarVisible: 1, statusbarVisible: 1, sidebarWidth: 220, previewWidth: 272, explorerListMode: 'details', breadcrumbStyle: 'segmented', transferProgressStyle: 'gloss-pill' },
            fonts: { ui: '"Segoe UI", Tahoma, sans-serif', mono: 'Consolas, monospace', baseSize: 12, titleSize: 13, titleWeight: '700', panelSize: 11, launcherSize: 12, desktopLabelSize: 11, scale: 100, tabularDigits: 1, underlineShortcuts: 1 },
            metrics: { paddingScale: 100, controlHeight: 24, touchScale: 100, windowRadius: 10, windowBorder: 1, buttonRadius: 8, shadowDepth: 18, iconSize: 54 },
            effects: { blurStrength: 14, transparency: 38, animationMs: 120, backdropBlur: 1 },
            validation: { contrast: 1, touchTargets: 1, fallbacks: 1 },
            exports: { cssVariables: 1, jsonManifest: 1, runtimePatch: 1, mobileOverrides: 1 },
            mobile: { panelHeight: 52, launcherLayout: 'single-column' },
            targets: { shell: true, taskbar: true, windows: true, controls: true },
            colors: { accent: '#72a8ff', accentStrong: '#4d7cff', panel: '#f8fbff', panelAlt: '#ffffff', panelText: '#173455', muted: '#5a7087', titlebar: '#6f93c7', inactiveTitlebar: '#4e6e9f', titleText: '#173a68', taskbar: '#6385bd', taskbarDark: '#24406f', taskbarText: '#ffffff', startButton: '#7fd25f', iconText: '#f6fbff', border: '#86a2c5', focus: '#ffd86c' },
            recipes: { shell: '', window: '', taskbar: '' },
            desktopCssHint: '',
            customVariablesJson: '{\n  "panel.height": 46,\n  "launcher.layout": "two-column"\n}',
            extraCss: '',
            notes: ''
          };
        },
        themeStudioPresetProfile: function (presetKey) {
          var key = this.themeStudioCanonicalPresetKey(presetKey);
          var profile;
          if (key === 'luna-blue' || key === 'meadow-classic-light') {
            profile = this.themeStudioFactoryProfile('Meadow Classic', 'Meadow Classic', 'light');
            profile.presetKey = 'meadow-classic-light';
            profile.familyKey = 'meadow-classic';
            profile.desktop.wallpaperTop = '#85c95c'; profile.desktop.wallpaperMiddle = '#66aa45'; profile.desktop.wallpaperBottom = '#3d7a28'; profile.desktop.color = '#4d8d37';
            profile.appearance.accent = '#3a78d8';
            profile.windowChrome.titleTop = '#cddbf2'; profile.windowChrome.titleBottom = '#9db6de';
            profile.panel.taskbarTop = '#4b82d8'; profile.panel.taskbarBottom = '#1b4d9e'; profile.panel.startTop = '#7fcd5d'; profile.panel.startBottom = '#2e7d22';
            profile.colors.panel = '#f5f8fd'; profile.colors.panelText = '#162033'; profile.colors.titleText = '#162033'; profile.colors.taskbarText = '#ffffff'; profile.colors.border = '#98b0cf';
            return this.themeStudioNormalizeProfile(profile);
          }
          if (key === 'royale-noir' || key === 'meadow-classic-dark') {
            profile = this.themeStudioFactoryProfile('Meadow Classic Night', 'Meadow Classic', 'dark');
            profile.presetKey = 'meadow-classic-dark';
            profile.familyKey = 'meadow-classic';
            profile.desktop.wallpaperTop = '#243a3f'; profile.desktop.wallpaperMiddle = '#1d2f39'; profile.desktop.wallpaperBottom = '#101921'; profile.desktop.color = '#16212d';
            profile.appearance.accent = '#8eb6ff';
            profile.windowChrome.titleTop = '#42607f'; profile.windowChrome.titleBottom = '#203246';
            profile.panel.taskbarTop = '#223951'; profile.panel.taskbarBottom = '#111e2d'; profile.panel.startTop = '#4a8f35'; profile.panel.startBottom = '#21551a';
            profile.colors.panel = '#182330'; profile.colors.panelAlt = '#223142'; profile.colors.panelText = '#edf4ff'; profile.colors.titleText = '#edf4ff'; profile.colors.taskbarText = '#edf4ff'; profile.colors.border = '#4f6680';
            return this.themeStudioNormalizeProfile(profile);
          }
          if (key === 'aero-glass' || key === 'glass-horizon-light') {
            profile = this.themeStudioFactoryProfile('Glass Horizon', 'Glass Horizon', 'light');
            profile.presetKey = 'glass-horizon-light';
            profile.familyKey = 'glass-horizon';
            profile.desktop.wallpaperTop = '#2d66c2'; profile.desktop.wallpaperMiddle = '#153a79'; profile.desktop.wallpaperBottom = '#0d244b'; profile.desktop.color = '#153a79';
            profile.appearance.accent = '#72a8ff';
            profile.windowChrome.titleTop = '#6f93c7'; profile.windowChrome.titleBottom = '#4e6e9f';
            profile.panel.taskbarTop = '#6385bd'; profile.panel.taskbarBottom = '#24406f'; profile.panel.startTop = '#7fd25f'; profile.panel.startBottom = '#2f7e22';
            profile.colors.panel = '#f8fbff'; profile.colors.panelAlt = '#ffffff'; profile.colors.panelText = '#173455'; profile.colors.titleText = '#173a68'; profile.colors.taskbarText = '#ffffff'; profile.colors.border = '#90a9c6';
            profile.metrics.windowRadius = 10; profile.metrics.buttonRadius = 8; profile.windowChrome.previewWidth = 272;
            return this.themeStudioNormalizeProfile(profile);
          }
          if (key === 'aero-midnight' || key === 'glass-horizon-dark') {
            profile = this.themeStudioFactoryProfile('Glass Horizon Midnight', 'Glass Horizon', 'dark');
            profile.presetKey = 'glass-horizon-dark';
            profile.familyKey = 'glass-horizon';
            profile.desktop.wallpaperTop = '#1f2d40'; profile.desktop.wallpaperMiddle = '#172232'; profile.desktop.wallpaperBottom = '#0f1621'; profile.desktop.color = '#121a25';
            profile.appearance.accent = '#93b0ff';
            profile.windowChrome.titleTop = '#44556f'; profile.windowChrome.titleBottom = '#263243';
            profile.panel.taskbarTop = '#1d2a3d'; profile.panel.taskbarBottom = '#111b29'; profile.panel.startTop = '#425e8e'; profile.panel.startBottom = '#24385a';
            profile.colors.panel = '#1a2331'; profile.colors.panelAlt = '#232f40'; profile.colors.panelText = '#eef4fb'; profile.colors.titleText = '#eef4fb'; profile.colors.taskbarText = '#eef4fb'; profile.colors.border = '#46576e';
            return this.themeStudioNormalizeProfile(profile);
          }
          if (key === 'graphite-dock-light') {
            profile = this.themeStudioFactoryProfile('Graphite Dock', 'Graphite Dock', 'light');
            profile.presetKey = 'graphite-dock-light';
            profile.familyKey = 'graphite-dock';
            profile.desktop.wallpaperTop = '#cfd6df'; profile.desktop.wallpaperMiddle = '#8d97a5'; profile.desktop.wallpaperBottom = '#515868'; profile.desktop.color = '#6c7381';
            profile.appearance.accent = '#7da8ff';
            profile.windowChrome.titleTop = '#d7dbe4'; profile.windowChrome.titleBottom = '#8e96a5';
            profile.panel.taskbarTop = '#d9dce4'; profile.panel.taskbarBottom = '#8d93a0'; profile.panel.startTop = '#f7f8fb'; profile.panel.startBottom = '#c8ccd7';
            profile.colors.panel = '#f7f9fc'; profile.colors.panelAlt = '#ffffff'; profile.colors.panelText = '#2e3440'; profile.colors.titleText = '#2f3846'; profile.colors.taskbarText = '#213246'; profile.colors.border = '#a4abba';
            profile.launcher.headerTop = '#858c9a'; profile.launcher.headerBottom = '#565e6d'; profile.launcher.rightBackground = '#e5e9f0';
            return this.themeStudioNormalizeProfile(profile);
          }
          if (key === 'graphite-dock-dark') {
            profile = this.themeStudioFactoryProfile('Graphite Dock Night', 'Graphite Dock', 'dark');
            profile.presetKey = 'graphite-dock-dark';
            profile.familyKey = 'graphite-dock';
            profile.desktop.wallpaperTop = '#48505b'; profile.desktop.wallpaperMiddle = '#262b33'; profile.desktop.wallpaperBottom = '#12161d'; profile.desktop.color = '#1a1f26';
            profile.appearance.accent = '#a9beff';
            profile.windowChrome.titleTop = '#6b7280'; profile.windowChrome.titleBottom = '#39414d';
            profile.panel.taskbarTop = '#2e343f'; profile.panel.taskbarBottom = '#171c23'; profile.panel.startTop = '#505867'; profile.panel.startBottom = '#29303b';
            profile.colors.panel = '#1f252e'; profile.colors.panelAlt = '#293240'; profile.colors.panelText = '#eef2f7'; profile.colors.titleText = '#eef2f7'; profile.colors.taskbarText = '#f7faff'; profile.colors.border = '#515a68';
            return this.themeStudioNormalizeProfile(profile);
          }
          if (key === 'ubuntu-human' || key === 'ember-panel-light') {
            profile = this.themeStudioFactoryProfile('Ember Panel', 'Ember Panel', 'light');
            profile.presetKey = 'ember-panel-light';
            profile.familyKey = 'ember-panel';
            profile.desktop.wallpaperTop = '#e58c46'; profile.desktop.wallpaperMiddle = '#9a4d29'; profile.desktop.wallpaperBottom = '#4e1e18'; profile.desktop.color = '#7d3b2b';
            profile.appearance.accent = '#ffb26d';
            profile.windowChrome.titleTop = '#ef9a4f'; profile.windowChrome.titleBottom = '#6d221a';
            profile.panel.taskbarTop = '#f0a05d'; profile.panel.taskbarBottom = '#7b2f1d'; profile.panel.startTop = '#f3b36c'; profile.panel.startBottom = '#b94f2a';
            profile.colors.panel = '#fff7f2'; profile.colors.panelAlt = '#fffdfb'; profile.colors.panelText = '#2b1e1a'; profile.colors.titleText = '#fff6f1'; profile.colors.taskbarText = '#fff6f1'; profile.colors.border = '#c89374';
            profile.launcher.headerTop = '#e58c46'; profile.launcher.headerBottom = '#6f1e18'; profile.launcher.rightBackground = '#f0dfd4';
            return this.themeStudioNormalizeProfile(profile);
          }
          if (key === 'ubuntu-graphite' || key === 'ember-panel-dark') {
            profile = this.themeStudioFactoryProfile('Ember Panel Night', 'Ember Panel', 'dark');
            profile.presetKey = 'ember-panel-dark';
            profile.familyKey = 'ember-panel';
            profile.desktop.wallpaperTop = '#5e2b22'; profile.desktop.wallpaperMiddle = '#2b1714'; profile.desktop.wallpaperBottom = '#120d0f'; profile.desktop.color = '#1c1316';
            profile.appearance.accent = '#ffb087';
            profile.windowChrome.titleTop = '#7f4333'; profile.windowChrome.titleBottom = '#43201c';
            profile.panel.taskbarTop = '#3c241f'; profile.panel.taskbarBottom = '#1b1110'; profile.panel.startTop = '#8a4a2d'; profile.panel.startBottom = '#532618';
            profile.colors.panel = '#24181d'; profile.colors.panelAlt = '#2d2026'; profile.colors.panelText = '#fff4ef'; profile.colors.titleText = '#fff4ef'; profile.colors.taskbarText = '#fff4ef'; profile.colors.border = '#6e484c';
            return this.themeStudioNormalizeProfile(profile);
          }
          return this.themeStudioFactoryProfile('Custom Theme', 'Custom', 'light');
        },
        ensureThemeStudioState: function (win) {
          if (!win) return { activeTab: 'general', profiles: [], profileKey: '', profile: {}, exportText: '' };
          if (!win.themeStudioState) {
            var storedProfiles = [];
            try { storedProfiles = JSON.parse(window.localStorage.getItem(this.themeStudioProfilesKey()) || '[]'); } catch (err) { storedProfiles = []; }
            win.themeStudioState = {
              activeTab: 'general',
              profiles: (Array.isArray(this.themeStudioProfilesCache) && this.themeStudioProfilesCache.length) ? this.themeStudioProfilesCache.slice() : ((Array.isArray(storedProfiles) && storedProfiles.length) ? storedProfiles : [
                { key: 'meadow-classic-light', name: 'Meadow Classic', family: 'Meadow Classic', mode: 'light', data: this.themeStudioPresetProfile('meadow-classic-light') },
                { key: 'meadow-classic-dark', name: 'Meadow Classic Night', family: 'Meadow Classic', mode: 'dark', data: this.themeStudioPresetProfile('meadow-classic-dark') },
                { key: 'glass-horizon-light', name: 'Glass Horizon', family: 'Glass Horizon', mode: 'light', data: this.themeStudioPresetProfile('glass-horizon-light') },
                { key: 'glass-horizon-dark', name: 'Glass Horizon Midnight', family: 'Glass Horizon', mode: 'dark', data: this.themeStudioPresetProfile('glass-horizon-dark') },
                { key: 'graphite-dock-light', name: 'Graphite Dock', family: 'Graphite Dock', mode: 'light', data: this.themeStudioPresetProfile('graphite-dock-light') },
                { key: 'graphite-dock-dark', name: 'Graphite Dock Night', family: 'Graphite Dock', mode: 'dark', data: this.themeStudioPresetProfile('graphite-dock-dark') },
                { key: 'ember-panel-light', name: 'Ember Panel', family: 'Ember Panel', mode: 'light', data: this.themeStudioPresetProfile('ember-panel-light') },
                { key: 'ember-panel-dark', name: 'Ember Panel Night', family: 'Ember Panel', mode: 'dark', data: this.themeStudioPresetProfile('ember-panel-dark') }
              ]),
              profileKey: this.themeStudioActiveKey || 'glass-horizon-light',
              profile: this.appliedThemeProfile ? window.MIOOSState.deepClone(this.appliedThemeProfile) : this.themeStudioPresetProfile('glass-horizon-light'),
              exportText: ''
            };
          }
          return win.themeStudioState;
        },
        themeStudioState: function (win) { return this.ensureThemeStudioState(win); },
        themeStudioProfiles: function (win) { return this.ensureThemeStudioState(win).profiles || []; },
        themeStudioSetTab: function (windowId, tabKey) { var win = this.windows.find(function (item) { return item.id === windowId; }); this.ensureThemeStudioState(win).activeTab = tabKey || 'general'; },
        themeStudioSelectProfile: function (windowId, profileKey) { var win = this.windows.find(function (item) { return item.id === windowId; }); var state = this.ensureThemeStudioState(win); var entry = (state.profiles || []).find(function (item) { return item.key === profileKey; }); var source; if (!entry) return; source = entry.data ? window.MIOOSState.deepClone(entry.data) : this.themeStudioPresetProfile(entry.key || 'glass-horizon-light'); state.profileKey = entry.key; state.profile = this.themeStudioNormalizeProfile(source); state.profile.name = entry.name || state.profile.name; state.profile.family = entry.family || state.profile.family; state.profile.mode = entry.mode || state.profile.mode; state.profile.activeMode = entry.mode || state.profile.activeMode; this.themeStudioPreviewCurrent(windowId); },
        themeStudioApplyPresetFamily: function (windowId, familyKey) { var win = this.windows.find(function (item) { return item.id === windowId; }); var state = this.ensureThemeStudioState(win); var mode = ((state.profile || {}).mode || 'light') === 'dark' ? 'dark' : 'light'; var presetKey = String(familyKey || 'glass-horizon') + '-' + mode; state.profile = this.themeStudioPresetProfile(presetKey); state.profileKey = presetKey; this.themeStudioPreviewCurrent(windowId); },
        themeStudioApplyPreset: function (windowId, presetKey) { var win = this.windows.find(function (item) { return item.id === windowId; }); var state = this.ensureThemeStudioState(win); state.profile = this.themeStudioPresetProfile(presetKey || 'glass-horizon-light'); state.profileKey = this.themeStudioCanonicalPresetKey(presetKey || 'glass-horizon-light'); this.themeStudioPreviewCurrent(windowId); },
        themeStudioNewProfile: function (windowId) { var win = this.windows.find(function (item) { return item.id === windowId; }); var state = this.ensureThemeStudioState(win); state.profileKey = 'custom-' + Date.now(); state.profile = this.themeStudioFactoryProfile('New Custom Theme', 'Custom', 'light'); state.profile.familyKey = 'glass-horizon'; state.activeTab = 'general'; this.themeStudioPreviewCurrent(windowId); },
        themeStudioDuplicateProfile: function (windowId) { var win = this.windows.find(function (item) { return item.id === windowId; }); var state = this.ensureThemeStudioState(win); state.profile = window.MIOOSState.deepClone(state.profile); state.profile.name = (state.profile.name || 'Custom Theme') + ' Copy'; state.profileKey = 'custom-' + Date.now(); this.themeStudioPreviewCurrent(windowId); },
        themeStudioResetProfile: function (windowId) { var win = this.windows.find(function (item) { return item.id === windowId; }); var state = this.ensureThemeStudioState(win); state.profile = this.themeStudioPresetProfile('glass-horizon-light'); state.profileKey = 'glass-horizon-light'; state.exportText = ''; state.activeTab = 'general'; this.themeStudioPreviewCurrent(windowId); },
        themeStudioSaveProfile: function (windowId) { var self = this; var win = this.windows.find(function (item) { return item.id === windowId; }); var state = this.ensureThemeStudioState(win); var normalized = this.themeStudioNormalizeProfile(state.profile); var entry = { key: state.profileKey || ('custom-' + Date.now()), name: normalized.name || 'Custom Theme', family: normalized.family || 'Custom', mode: normalized.mode || 'light', data: window.MIOOSState.deepClone(normalized) }; var idx = (state.profiles || []).findIndex(function (item) { return item.key === entry.key; }); state.profileKey = entry.key; if (idx >= 0) state.profiles.splice(idx, 1, entry); else state.profiles.push(entry); state.exportText = JSON.stringify(entry.data, null, 2); this.themeStudioPersistProfiles(); return this.themeStudioSaveRemote(entry, 0).then(function () { self.showAlert('Customize', 'Theme draft saved to globals-backed profiles.'); }).catch(function () { self.showAlert('Customize', 'Theme draft saved locally.'); }); },
        themeStudioApplyCurrent: function (windowId) { var self = this; var win = this.windows.find(function (item) { return item.id === windowId; }); var state = this.ensureThemeStudioState(win); var normalized = this.themeStudioNormalizeProfile(state.profile); var entry = { key: state.profileKey || ('custom-' + Date.now()), name: normalized.name || 'Custom Theme', family: normalized.family || 'Custom', mode: normalized.mode || 'light', data: window.MIOOSState.deepClone(normalized) }; this.applyThemeStudioProfile(state.profile, { persist: true }); return this.themeStudioSaveRemote(entry, 1).catch(function () { self.showAlert('Customize', 'Applied locally. Global save unavailable.'); }); },
        themeStudioPreviewCurrent: function (windowId) { var win = this.windows.find(function (item) { return item.id === windowId; }); var state = this.ensureThemeStudioState(win); if (!state || !state.profile) return; this.applyThemeStudioProfile(state.profile, { persist: false, silent: true }); },
        themeStudioClearWallpaper: function (windowId) { var win = this.windows.find(function (item) { return item.id === windowId; }); var state = this.ensureThemeStudioState(win); if (!state || !state.profile || !state.profile.desktop) return; state.profile.desktop.wallpaperUrl = ''; state.profile.desktop.wallpaperPreset = 'gradient-gloss'; state.profile.appearance.wallpaperMode = 'gradient-gloss'; this.themeStudioPreviewCurrent(windowId); },
        themeStudioExportProfile: function (windowId) { var win = this.windows.find(function (item) { return item.id === windowId; }); var state = this.ensureThemeStudioState(win); state.exportText = JSON.stringify(this.themeStudioNormalizeProfile(state.profile), null, 2); this.showAlert('Customize', 'Theme JSON is ready in the export buffer.'); },
        themeStudioImportProfile: function (windowId) { var win = this.windows.find(function (item) { return item.id === windowId; }); var state = this.ensureThemeStudioState(win); try { if (!state.exportText) return; state.profile = this.themeStudioNormalizeProfile(Object.assign(this.themeStudioFactoryProfile('Imported Theme', 'Custom', 'light'), JSON.parse(state.exportText))); this.showAlert('Customize', 'Import buffer applied to the current draft.'); } catch (err) { this.showAlert('Customize', 'Import buffer is not valid JSON yet.'); } },
        themeStudioPreviewWallpaper: function (profile) { return this.themeStudioWallpaperCss(profile || {}); },
        themeStudioPreviewDesktopStyle: function (win) { var profile = this.ensureThemeStudioState(win).profile; var bg = this.themeStudioWallpaperCss(profile); return { background: bg, color: ((profile.colors || {}).iconText || '#ffffff'), gap: (((profile.desktop || {}).iconSpacing || 16)) + 'px', fontSize: (((profile.fonts || {}).desktopLabelSize || 11)) + 'px' }; },
        themeStudioPreviewWindowStyle: function (win) { var p = this.ensureThemeStudioState(win).profile; return { background: (p.colors || {}).panel || '#ffffff', color: (p.colors || {}).panelText || '#132136', borderColor: (p.colors || {}).border || '#4e79c7', borderWidth: (((p.metrics || {}).windowBorder || 1)) + 'px', borderStyle: 'solid', borderRadius: (((p.metrics || {}).windowRadius || 8)) + 'px', boxShadow: '0 ' + ((((p.metrics || {}).shadowDepth || 18))) + 'px ' + (((((p.metrics || {}).shadowDepth || 18) * 2))) + 'px rgba(0,0,0,0.22)', fontFamily: ((p.fonts || {}).ui || 'Tahoma, sans-serif'), fontSize: (((p.fonts || {}).baseSize || 13)) + 'px' }; },
        themeStudioPreviewTitlebarStyle: function (win) { var p = this.ensureThemeStudioState(win).profile; return { background: 'linear-gradient(180deg, ' + (((p.windowChrome || {}).titleTop) || '#6f93c7') + ' 0%, ' + (((p.windowChrome || {}).titleBottom) || '#4e6e9f') + ' 100%)', color: (p.colors || {}).titleText || '#ffffff', fontSize: (((p.fonts || {}).titleSize || 13)) + 'px' }; },
        themeStudioPreviewTaskbarStyle: function (win) { var p = this.ensureThemeStudioState(win).profile; return { background: 'linear-gradient(180deg, ' + (((p.panel || {}).taskbarTop) || '#6385bd') + ' 0%, ' + (((p.panel || {}).taskbarBottom) || '#24406f') + ' 100%)', color: (p.colors || {}).taskbarText || '#ffffff', height: ((((p.panel || {}).height) || 46)) + 'px' }; },
        terminalStatusText: function (win) {
          if (Terminal && typeof Terminal.terminalStatusText === 'function') {
            return Terminal.terminalStatusText.call(this, win);
          }
          if (Terminal && typeof Terminal.methods === 'object' && typeof Terminal.methods.terminalStatusText === 'function') {
            return Terminal.methods.terminalStatusText.call(this, win);
          }
          return (((win || {}).terminalState || {}).status) || this.t('terminal.status.ready', 'Terminal idle');
        }
      }, Auth, WS, WM, Terminal, Explorer)
    });

    app.config.compilerOptions.delimiters = ['[[', ']]'];
    app.mount('#mioosRoot');
  }

  window.MIOOSCore = { mount: mount };
})();
