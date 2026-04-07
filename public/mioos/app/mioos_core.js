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
          launcherEntries: [],
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
            top: 0,
            mode: 'move',
            edge: '',
            width: 0,
            height: 0
          },
          snapPreview: { active: false, zone: '', left: 0, top: 0, width: 0, height: 0 },
          clockTimer: null,
          pingTimer: null,
          profile: 'dev',
          authBusy: false,
          authForm: {
            username: 'admin',
            password: 'admin123!'
          },
          commandSeq: 0,
          socketRequestSeq: 0,
          socketPending: {},
          pendingCommands: {},
          terminalWindowSeq: 0,
          terminalPollTimer: null,
          appliedThemeProfile: null,
          themeStyleNodeId: 'mioos-theme-studio-style',
          transferCenter: { items: [], seq: 0, autoOpen: true },
          transferControllers: {},
          transportDiagnostics: { loading: false, refreshedAt: 0, error: '', report: {} },
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
            .filter(function (win) { return win.state !== 'closed' && win.state !== 'minimized'; })
            .sort(function (a, b) { return (a.z || 0) - (b.z || 0); });
        },
        taskbarWindows: function () {
          return this.windows.filter(function (win) { return win.state !== 'closed'; });
        },
        filteredEntries: function () {
          var needle = (this.menuFilter || '').trim().toLowerCase();
          var source = this.launcherEntries && this.launcherEntries.length ? this.launcherEntries : this.desktopEntries;
          if (!needle) return source;
          return source.filter(function (entry) {
            var hay = ((entry.title || '') + ' ' + (entry.subtitle || '')).toLowerCase();
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
              this.desktopEntries = window.MIOOSState.deepClone(entries);
              this.ensureDesktopLayout();
            }
          }
        }
      },
      mounted: function () {
        this.bootstrapFromDom();
        this.ensureDesktopLayout();
        this.applyPersistedThemeStudioProfile();
        this.applyDocumentLocale();
        this.startClock();
        this.refreshView();
        this.initSocket();
        if (this.startTerminalPolling) this.startTerminalPolling();
        this._dragMove = this.handleGlobalMouseMove.bind(this);
        this._dragEnd = this.handleGlobalMouseUp.bind(this);
        this._viewportResize = this.handleViewportResize.bind(this);
        window.addEventListener('mousemove', this._dragMove);
        window.addEventListener('mouseup', this._dragEnd);
        window.addEventListener('resize', this._viewportResize);
      },
      beforeUnmount: function () {
        if (this.clockTimer) window.clearInterval(this.clockTimer);
        if (this.pingTimer) window.clearInterval(this.pingTimer);
        if (this.terminalPollTimer) window.clearInterval(this.terminalPollTimer);
        if (this.socket) this.socket.close();
        window.removeEventListener('mousemove', this._dragMove);
        window.removeEventListener('mouseup', this._dragEnd);
        window.removeEventListener('resize', this._viewportResize);
        this.windows.forEach(function (win) {
          if (win._term) win._term.dispose();
        });
      },
      methods: Object.assign({
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
          this.desktopEntries = window.MIOOSState.deepClone((this.view && this.view.desktopEntries) || this.boot.desktopEntries || this.boot.apps || []);
          this.windows = window.MIOOSState.deepClone(this.boot.windows || []);
          this.ensureModuleWindowState();
          this.desktopUi.iconSize = ((((this.boot || {}).desktop || {}).icons || {}).size) || 'medium';
          this.desktopUi.sortMode = ((((this.boot || {}).desktop || {}).icons || {}).sortMode) || 'manual';
          this.zCounter = this.windows.reduce(function (max, win) { return Math.max(max, win.z || 0); }, 10) + 1;
          if (this.windows.length) this.activeWindowId = this.windows[0].id;
        },
        startClock: function () {
          var self = this;
          function tick() {
            var now = new Date();
            self.clockText = now.toLocaleTimeString(self.currentLocale.code || undefined, { hour: 'numeric', minute: '2-digit' });
          }
          tick();
          this.clockTimer = window.setInterval(tick, 1000);
        },
        t: function (key, fallback) {
          return I18N.t ? I18N.t(this, key, fallback) : (fallback || key);
        },
        applyDocumentLocale: function () {
          if (I18N.applyDocumentLocale) I18N.applyDocumentLocale(this);
        },
        changeLocale: function (code) {
          if (I18N.changeLocale) I18N.changeLocale(this, code);
        },
        openTransfersWindow: function () {
          var win = this.windows.find(function (item) { return item.appKey === 'transfers'; });
          if (!win) return;
          if (win.state === 'closed' || win.state === 'minimized') win.state = 'normal';
          this.focusWindow(win.id);
        },
        transferPercent: function (item) {
          if (!item) return 0;
          if (+item.totalBytes > 0) return Math.max(0, Math.min(100, Math.round(((+item.processedBytes || 0) / (+item.totalBytes || 1)) * 100)));
          return +item.progress || 0;
        },
        activeTransfers: function () {
          return (this.transferCenter.items || []).filter(function (item) {
            return ['queued','preparing','uploading','downloading','finalizing','verifying','cancelling'].indexOf(item.status) >= 0;
          });
        },
        completedTransfers: function () {
          return (this.transferCenter.items || []).filter(function (item) {
            return ['completed','failed','cancelled'].indexOf(item.status) >= 0;
          });
        },
        transferSummaryText: function () {
          var active = this.activeTransfers().length;
          var done = this.completedTransfers().length;
          return active + ' active · ' + done + ' finished';
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
        formatTransportTime: function (value) {
          if (!value) return '—';
          try { return new Date(value).toLocaleTimeString(); } catch (err) { return '—'; }
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
          return next.id;
        },
        updateTransfer: function (transferId, patch) {
          var item = (this.transferCenter.items || []).find(function (entry) { return entry.id === transferId; });
          if (!item) return;
          Object.assign(item, patch || {});
          item.updatedAt = Date.now();
          item.progress = this.transferPercent(item);
        },
        finalizeTransfer: function (transferId, ok, patch) {
          this.updateTransfer(transferId, Object.assign({
            status: ok ? 'completed' : 'failed',
            stage: ok ? 'Completed' : 'Failed'
          }, patch || {}));
          if (ok) this.clearTransferController(transferId);
        },
        clearFinishedTransfers: function () {
          var keep = {};
          this.transferCenter.items = (this.transferCenter.items || []).filter(function (item) {
            var active = ['queued','preparing','uploading','downloading','finalizing','verifying','cancelling'].indexOf(item.status) >= 0;
            if (active) keep[item.id] = 1;
            return active;
          });
          Object.keys(this.transferControllers || {}).forEach(function (key) {
            if (!keep[key]) delete (this.transferControllers || {})[key];
          }, this);
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
          return { left: (+pos.left || 16) + 'px', top: (+pos.top || 16) + 'px' };
        },
        desktopIconClass: function (entry) {
          return {
            'is-selected': ((this.desktopUi || {}).selectedKey || '') === entry.key,
            'is-small': (this.desktopUi.iconSize || 'medium') === 'small',
            'is-large': (this.desktopUi.iconSize || 'medium') === 'large'
          };
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
          if (this.onDragMove) this.onDragMove(event);
          this.onDesktopIconMove(event);
        },
        handleGlobalMouseUp: function (event) {
          if (this.endDrag) this.endDrag(event);
          this.endDesktopIconDrag(event);
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
          this.desktopUi.contextMenu = { open: true, type: 'desktop', key: '', left: event.clientX, top: event.clientY };
        },
        openDesktopIconContextMenu: function (entry, event) {
          if (!entry || !event) return;
          this.selectDesktopEntry(entry);
          this.desktopUi.contextMenu = { open: true, type: 'icon', key: entry.key, left: event.clientX, top: event.clientY };
        },
        closeDesktopContextMenu: function () { this.desktopUi.contextMenu.open = false; },
        contextMenuStyle: function () {
          return { left: (this.desktopUi.contextMenu.left || 0) + 'px', top: (this.desktopUi.contextMenu.top || 0) + 'px' };
        },
        desktopContextEntry: function () {
          var key = (this.desktopUi.contextMenu || {}).key || (this.desktopUi.selectedKey || '');
          return (this.desktopEntries || []).find(function (entry) { return entry.key === key; }) || null;
        },
        contextOpenSelected: function () {
          var entry = this.desktopContextEntry();
          this.closeDesktopContextMenu();
          if (entry) this.openApp(entry.key);
        },
        contextControlPanel: function () { this.closeDesktopContextMenu(); this.openApp('control-panel'); },
        contextPersonalize: function () { this.closeDesktopContextMenu(); this.openApp('theme-studio'); },
        contextDeleteIcon: function () { this.closeDesktopContextMenu(); this.showAlert('Desktop', 'Desktop shortcuts are managed by installed modules.'); },
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
          return (/^#[0-9a-fA-F]{6}$/).test(String(value || '')) ? String(value) : fallback;
        },
        themeStudioNormalizeProfile: function (profile) {
          var base = this.themeStudioFactoryProfile('Custom Theme', 'Custom', 'light');
          var next = Object.assign({}, base, profile || {});
          next.targets = Object.assign({}, base.targets, (profile || {}).targets || {});
          next.colors = Object.assign({}, base.colors, (profile || {}).colors || {});
          next.fonts = Object.assign({}, base.fonts, (profile || {}).fonts || {});
          next.metrics = Object.assign({}, base.metrics, (profile || {}).metrics || {});
          next.recipes = Object.assign({}, base.recipes, (profile || {}).recipes || {});
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
          var bg = this.themeStudioPreviewWallpaper(profile || {});
          if (String(bg).indexOf('url(') === 0) return (profile.desktopColor || '#3a6ea5') + ' ' + bg + ' center / ' + ((profile.wallpaperFit === 'tile') ? '240px auto' : (profile.wallpaperFit || 'cover')) + ' ' + ((profile.wallpaperFit === 'tile') ? 'repeat' : 'no-repeat');
          return bg;
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
        applyThemeStudioProfile: function (profile, options) {
          var rootNode = this.themeStudioRootNode();
          var opts = options || {};
          var p = this.themeStudioNormalizeProfile(profile || {});
          var colors = p.colors || {};
          var fonts = p.fonts || {};
          var metrics = p.metrics || {};
          var body = document.body;
          var styleNode = this.themeStudioEnsureStyleNode();
          var vars;
          if (!rootNode) return;
          vars = {
            '--mioos-font': fonts.ui || 'Tahoma, "Segoe UI", sans-serif',
            '--mioos-font-mono': fonts.mono || 'Consolas, monospace',
            '--mioos-blue-1': this.themeStudioSanitizeColor(colors.accent, '#3a6ee8'),
            '--mioos-blue-2': this.themeStudioSanitizeColor(colors.accentStrong, '#1f4fbf'),
            '--mioos-blue-3': this.themeStudioSanitizeColor(colors.accentStrong, '#173a8f'),
            '--mioos-taskbar': this.themeStudioSanitizeColor(colors.taskbar, '#245edb'),
            '--mioos-taskbar-dark': this.themeStudioSanitizeColor(colors.taskbarDark || colors.taskbar, '#1844a0'),
            '--mioos-start': this.themeStudioSanitizeColor(colors.startButton || '#2aa12a', '#2aa12a'),
            '--mioos-border': this.themeStudioSanitizeColor(colors.border, '#7f9db9'),
            '--mioos-panel': this.themeStudioSanitizeColor(colors.panel, '#f4f7fb'),
            '--mioos-panel-2': this.themeStudioSanitizeColor(colors.panelAlt || '#ffffff', '#ffffff'),
            '--mioos-text': this.themeStudioSanitizeColor(colors.panelText, '#0b1830'),
            '--mioos-muted': this.themeStudioSanitizeColor(colors.muted || '#44536d', '#44536d'),
            '--mioos-focus': this.themeStudioSanitizeColor(colors.focus || '#ffd043', '#ffd043'),
            '--mioos-titlebar': this.themeStudioSanitizeColor(colors.titlebar, '#2b5bc7'),
            '--mioos-titlebar-inactive': this.themeStudioSanitizeColor(colors.inactiveTitlebar || '#5877a9', '#5877a9'),
            '--mioos-titlebar-text': this.themeStudioSanitizeColor(colors.titleText || '#ffffff', '#ffffff'),
            '--mioos-taskbar-text': this.themeStudioSanitizeColor(colors.taskbarText || '#ffffff', '#ffffff'),
            '--mioos-icon-text': this.themeStudioSanitizeColor(colors.iconText || '#ffffff', '#ffffff'),
            '--mioos-window-radius': Math.max(0, +(metrics.windowRadius || 8)) + 'px',
            '--mioos-window-border-width': Math.max(1, +(metrics.windowBorder || 1)) + 'px',
            '--mioos-button-radius': Math.max(0, +(metrics.buttonRadius || 6)) + 'px',
            '--mioos-taskbar-height': Math.max(32, +(metrics.taskbarHeight || 40)) + 'px',
            '--mioos-base-size': Math.max(11, +(fonts.baseSize || 13)) + 'px',
            '--mioos-title-size': Math.max(11, +(fonts.titleSize || 13)) + 'px',
            '--mioos-shadow': '0 ' + (Math.max(6, +(metrics.shadowDepth || 18))) + 'px ' + (Math.max(18, +(metrics.shadowDepth || 18) * 2)) + 'px rgba(0, 24, 64, 0.34)',
            '--mioos-desktop-background': this.themeStudioWallpaperCss(p),
            '--mioos-body-background': this.themeStudioSanitizeColor(p.desktopColor || '#4f91ea', '#4f91ea'),
            '--mioos-icon-shadow': colors.desktopGlow || '0 1px 2px rgba(0,0,0,0.55)'
          };
          Object.keys(vars).forEach(function (key) { rootNode.style.setProperty(key, vars[key]); });
          rootNode.dataset.themeMode = p.mode || 'light';
          rootNode.dataset.themeFamily = p.family || 'Custom';
          rootNode.dataset.themeDensity = p.density || 'comfortable';
          rootNode.classList.remove('mioos-theme-dark', 'mioos-theme-light', 'mioos-density-compact', 'mioos-density-spacious');
          rootNode.classList.add((p.mode || 'light') === 'dark' ? 'mioos-theme-dark' : 'mioos-theme-light');
          if ((p.density || '') === 'compact') rootNode.classList.add('mioos-density-compact');
          if ((p.density || '') === 'spacious') rootNode.classList.add('mioos-density-spacious');
          if (p.desktopClass) rootNode.dataset.themeDesktopClass = p.desktopClass;
          body.style.background = p.desktopColor || '#4f91ea';
          styleNode.textContent = (p.extraCss || '') + '\n' + (p.desktopCssHint ? ('#mioosRoot{' + p.desktopCssHint + '}') : '');
          if (!opts.silent) this.showAlert('Theme Studio', (p.name || 'Custom Theme') + ' applied.');
          this.appliedThemeProfile = window.MIOOSState.deepClone(p);
          if (opts.persist !== false) {
            try { window.localStorage.setItem(this.themeStudioStorageKey(), JSON.stringify(p)); } catch (err) {}
          }
        },
        themeStudioTabList: function () {
          return [
            { key: 'overview', label: 'Overview' },
            { key: 'wallpaper', label: 'Wallpaper' },
            { key: 'colors', label: 'Colors' },
            { key: 'type', label: 'Typography' },
            { key: 'metrics', label: 'Metrics' },
            { key: 'advanced', label: 'Advanced' }
          ];
        },
        themeStudioFactoryProfile: function (name, family, mode) {
          return {
            name: name || 'Custom Theme', author: (this.boot.user && this.boot.user.displayName) || 'MIOOS User', family: family || 'Custom', mode: mode || 'light', density: 'comfortable', cornerModel: 'soft', wallpaperPreset: 'bliss', wallpaperUrl: '', wallpaperFit: 'cover', desktopColor: '#3a6ea5', desktopClass: '', desktopCssHint: '',
            targets: { shell: true, taskbar: true, windows: true, controls: true },
            colors: { accent: '#245edb', accentStrong: '#1f4fa5', panel: '#f7fbff', panelAlt: '#ffffff', panelText: '#132136', muted: '#44536d', titlebar: '#2b5bc7', inactiveTitlebar: '#5877a9', titleText: '#ffffff', taskbar: '#245edb', taskbarDark: '#1844a0', taskbarText: '#ffffff', startButton: '#2aa12a', iconText: '#ffffff', border: '#4e79c7', focus: '#ffd043', desktopGlow: '0 1px 2px rgba(0,0,0,0.55)' },
            fonts: { ui: 'Tahoma, "Segoe UI", sans-serif', mono: 'Consolas, monospace', baseSize: 13, titleSize: 13, menuSize: 13, weight: '500' },
            metrics: { taskbarHeight: 40, windowRadius: 8, windowBorder: 1, buttonRadius: 6, iconSize: 36, shadowDepth: 18 },
            recipes: { shell: '', window: '', taskbar: '' },
            customVariablesJson: '{\n  "--mioos-accent": "#245edb"\n}', extraCss: '', notes: ''
          };
        },
        themeStudioPresetProfile: function (presetKey) {
          var profile;
          if (presetKey === 'xp') { profile = this.themeStudioFactoryProfile('Windows XP Inspired', 'Windows XP', 'light'); profile.wallpaperPreset = 'bliss'; profile.desktopColor = '#3e89d0'; profile.colors.accent = '#245edb'; profile.colors.titlebar = '#2d63d6'; profile.colors.taskbar = '#245edb'; profile.fonts.ui = 'Tahoma, "Segoe UI", sans-serif'; return profile; }
          if (presetKey === 'win7') { profile = this.themeStudioFactoryProfile('Windows 7 Inspired', 'Windows 7', 'light'); profile.wallpaperPreset = 'aurora'; profile.desktopColor = '#254f7d'; profile.colors.accent = '#2f6fd0'; profile.colors.titlebar = '#5f8fd8'; profile.colors.taskbar = '#1d3d63'; profile.metrics.windowRadius = 10; profile.fonts.ui = '"Segoe UI", Tahoma, sans-serif'; return profile; }
          profile = this.themeStudioFactoryProfile('Mac Inspired', 'Mac', 'light'); profile.wallpaperPreset = 'solid-graphite'; profile.desktopColor = '#6c7a89'; profile.colors.accent = '#6f8fb2'; profile.colors.titlebar = '#cfd6df'; profile.colors.taskbar = '#d5dde6'; profile.colors.panel = '#f8fafc'; profile.colors.panelText = '#1f2937'; profile.metrics.windowRadius = 14; profile.fonts.ui = '"Helvetica Neue", Helvetica, Arial, sans-serif'; return profile;
        },
        ensureThemeStudioState: function (win) {
          if (!win) return { activeTab: 'overview', profiles: [], profileKey: '', profile: {}, exportText: '' };
          if (!win.themeStudioState) {
            var storedProfiles = [];
            try { storedProfiles = JSON.parse(window.localStorage.getItem(this.themeStudioProfilesKey()) || '[]'); } catch (err) { storedProfiles = []; }
            win.themeStudioState = {
              activeTab: 'overview',
              profiles: (Array.isArray(storedProfiles) && storedProfiles.length) ? storedProfiles : [
                { key: 'xp', name: 'Windows XP Inspired', family: 'Windows XP', mode: 'light', data: this.themeStudioPresetProfile('xp') },
                { key: 'win7', name: 'Windows 7 Inspired', family: 'Windows 7', mode: 'light', data: this.themeStudioPresetProfile('win7') },
                { key: 'mac', name: 'Mac Inspired', family: 'Mac', mode: 'light', data: this.themeStudioPresetProfile('mac') }
              ],
              profileKey: 'xp', profile: this.appliedThemeProfile ? window.MIOOSState.deepClone(this.appliedThemeProfile) : this.themeStudioPresetProfile('xp'), exportText: ''
            };
          }
          return win.themeStudioState;
        },
        themeStudioState: function (win) { return this.ensureThemeStudioState(win); },
        themeStudioProfiles: function (win) { return this.ensureThemeStudioState(win).profiles || []; },
        themeStudioSetTab: function (windowId, tabKey) { var win = this.windows.find(function (item) { return item.id === windowId; }); this.ensureThemeStudioState(win).activeTab = tabKey || 'overview'; },
        themeStudioSelectProfile: function (windowId, profileKey) { var win = this.windows.find(function (item) { return item.id === windowId; }); var state = this.ensureThemeStudioState(win); var entry = (state.profiles || []).find(function (item) { return item.key === profileKey; }); if (!entry) return; state.profileKey = entry.key; state.profile = window.MIOOSState.deepClone(entry.data); state.profile.name = entry.name; state.profile.family = entry.family; state.profile.mode = entry.mode; },
        themeStudioApplyPreset: function (windowId, presetKey) { var win = this.windows.find(function (item) { return item.id === windowId; }); var state = this.ensureThemeStudioState(win); state.profile = this.themeStudioPresetProfile(presetKey || 'xp'); state.profileKey = presetKey || 'xp'; },
        themeStudioNewProfile: function (windowId) { var win = this.windows.find(function (item) { return item.id === windowId; }); var state = this.ensureThemeStudioState(win); state.profileKey = 'custom-' + Date.now(); state.profile = this.themeStudioFactoryProfile('New Custom Theme', 'Custom', 'light'); state.activeTab = 'overview'; },
        themeStudioDuplicateProfile: function (windowId) { var win = this.windows.find(function (item) { return item.id === windowId; }); var state = this.ensureThemeStudioState(win); state.profile = window.MIOOSState.deepClone(state.profile); state.profile.name = (state.profile.name || 'Custom Theme') + ' Copy'; state.profileKey = 'custom-' + Date.now(); },
        themeStudioResetProfile: function (windowId) { var win = this.windows.find(function (item) { return item.id === windowId; }); var state = this.ensureThemeStudioState(win); state.profile = this.themeStudioFactoryProfile('Custom Theme', 'Custom', 'light'); state.exportText = ''; state.activeTab = 'overview'; },
        themeStudioSaveProfile: function (windowId) { var win = this.windows.find(function (item) { return item.id === windowId; }); var state = this.ensureThemeStudioState(win); var entry = { key: state.profileKey || ('custom-' + Date.now()), name: state.profile.name || 'Custom Theme', family: state.profile.family || 'Custom', mode: state.profile.mode || 'light', data: window.MIOOSState.deepClone(this.themeStudioNormalizeProfile(state.profile)) }; var idx = (state.profiles || []).findIndex(function (item) { return item.key === entry.key; }); state.profileKey = entry.key; if (idx >= 0) state.profiles.splice(idx, 1, entry); else state.profiles.push(entry); state.exportText = JSON.stringify(entry.data, null, 2); this.themeStudioPersistProfiles(); this.showAlert('Theme Studio', 'Draft saved inside Theme Studio.'); },
        themeStudioApplyCurrent: function (windowId) { var win = this.windows.find(function (item) { return item.id === windowId; }); var state = this.ensureThemeStudioState(win); this.applyThemeStudioProfile(state.profile, { persist: true }); },
        themeStudioExportProfile: function (windowId) { var win = this.windows.find(function (item) { return item.id === windowId; }); var state = this.ensureThemeStudioState(win); state.exportText = JSON.stringify(this.themeStudioNormalizeProfile(state.profile), null, 2); this.showAlert('Theme Studio', 'Export JSON is ready in the buffer below.'); },
        themeStudioImportProfile: function (windowId) { var win = this.windows.find(function (item) { return item.id === windowId; }); var state = this.ensureThemeStudioState(win); try { if (!state.exportText) return; state.profile = this.themeStudioNormalizeProfile(Object.assign(this.themeStudioFactoryProfile('Imported Theme', 'Custom', 'light'), JSON.parse(state.exportText))); this.showAlert('Theme Studio', 'Import buffer applied to the current draft.'); } catch (err) { this.showAlert('Theme Studio', 'Import buffer is not valid JSON yet.'); } },
        themeStudioPreviewWallpaper: function (profile) { profile = profile || {}; if (profile.wallpaperPreset === 'custom-url' && profile.wallpaperUrl) return 'url(' + profile.wallpaperUrl + ')'; if (profile.wallpaperPreset === 'aurora') return 'linear-gradient(180deg, #183b66 0%, #365d93 42%, #87a6cf 100%)'; if (profile.wallpaperPreset === 'solid-blue') return '#245edb'; if (profile.wallpaperPreset === 'solid-graphite') return '#5f6773'; return 'linear-gradient(180deg, #8ac04c 0%, #74b94b 38%, #5ea140 100%)'; },
        themeStudioPreviewDesktopStyle: function (win) { var profile = this.ensureThemeStudioState(win).profile; var bg = this.themeStudioPreviewWallpaper(profile); return { background: bg.indexOf('url(') === 0 ? profile.desktopColor : bg, backgroundImage: bg.indexOf('url(') === 0 ? bg : '', backgroundSize: profile.wallpaperFit === 'tile' ? '240px auto' : (profile.wallpaperFit || 'cover'), backgroundRepeat: profile.wallpaperFit === 'tile' ? 'repeat' : 'no-repeat', color: (profile.colors || {}).iconText || '#ffffff' }; },
        themeStudioPreviewWindowStyle: function (win) { var p = this.ensureThemeStudioState(win).profile; return { background: (p.colors || {}).panel || '#ffffff', color: (p.colors || {}).panelText || '#132136', borderColor: (p.colors || {}).border || '#4e79c7', borderWidth: ((p.metrics || {}).windowBorder || 1) + 'px', borderStyle: 'solid', borderRadius: ((p.metrics || {}).windowRadius || 8) + 'px', boxShadow: '0 ' + (((p.metrics || {}).shadowDepth || 18)) + 'px ' + ((((p.metrics || {}).shadowDepth || 18) * 2)) + 'px rgba(0,0,0,0.22)', fontFamily: ((p.fonts || {}).ui || 'Tahoma, sans-serif'), fontSize: (((p.fonts || {}).baseSize || 13)) + 'px' }; },
        themeStudioPreviewTitlebarStyle: function (win) { var p = this.ensureThemeStudioState(win).profile; return { background: (p.colors || {}).titlebar || '#2b5bc7', color: '#ffffff', fontSize: (((p.fonts || {}).titleSize || 13)) + 'px' }; },
        themeStudioPreviewTaskbarStyle: function (win) { var p = this.ensureThemeStudioState(win).profile; return { background: (p.colors || {}).taskbar || '#245edb', height: (((p.metrics || {}).taskbarHeight || 40)) + 'px' }; },
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
