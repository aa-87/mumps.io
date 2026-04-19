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
          activeThemeKey: '',
          themeStyleNodeId: 'mioos-theme-studio-style',
          themeStudioStore: { initialized: false, themes: {}, order: [], customThemes: [], activeThemeId: 'windows-7', previewWindowState: {}, importBuffer: '', activeTab: 'global' },
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
        var self = this;
        this.bootstrapFromDom();
        this.initThemeStudioStore();
        this.applyPersistedThemeStudioProfile();
        this.restorePersistedTransfers();
        this.normalizeDesktopUiState();
        this.ensureDesktopLayout();
        this.normalizeDesktopUiState();
        this.applyDocumentLocale();
        this.startClock();
        if (!this.requiresSignin) {
          this.refreshView();
          this.initSocket().catch(function () {});
          if (this.startTerminalPolling) this.startTerminalPolling();
        }
        this._dragMove = this.handleGlobalMouseMove.bind(this);
        this._dragEnd = this.handleGlobalMouseUp.bind(this);
        this._viewportResize = this.handleViewportResize.bind(this);
        window.addEventListener('mousemove', this._dragMove);
        window.addEventListener('mouseup', this._dragEnd);
        this._shortcutHandler = this.onGlobalShortcut.bind(this);
        window.addEventListener('keydown', this._shortcutHandler);
        this._persistTransfersOnUnload = this.persistTransferCenter.bind(this);
        this._networkOffline = function () {
          if (self.autoPauseTransfersByReason) self.autoPauseTransfersByReason('Paused (connection lost)', 'upload');
        };
        this._networkOnline = function () {
          if (self.persistTransferCenter) self.persistTransferCenter();
        };
        window.addEventListener('resize', this._viewportResize);
        window.addEventListener('beforeunload', this._persistTransfersOnUnload);
        window.addEventListener('offline', this._networkOffline);
        window.addEventListener('online', this._networkOnline);
        if (!this.requiresSignin) window.setTimeout(function () { if (self.revivePersistedTransfers) self.revivePersistedTransfers(); }, 400);
      },
      beforeUnmount: function () {
        if (this.clockTimer) window.clearInterval(this.clockTimer);
        if (this.pingTimer) window.clearInterval(this.pingTimer);
        if (this.terminalPollTimer) window.clearInterval(this.terminalPollTimer);
        if (this.socket) this.socket.close();
        if (this._dragRaf) window.cancelAnimationFrame(this._dragRaf);
        this.persistTransferCenter();
        window.removeEventListener('mousemove', this._dragMove);
        window.removeEventListener('mouseup', this._dragEnd);
        window.removeEventListener('keydown', this._shortcutHandler);
        window.removeEventListener('resize', this._viewportResize);
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
          this.desktopEntries = window.MIOOSState.deepClone((this.view && this.view.desktopEntries) || this.boot.desktopEntries || this.boot.apps || []);
          this.windows = window.MIOOSState.deepClone(this.boot.windows || []);
          this.ensureModuleWindowState();
          this.normalizeDesktopUiState();
          this.desktopUi.iconSize = ((((this.boot || {}).desktop || {}).icons || {}).size) || 'medium';
          this.desktopUi.sortMode = ((((this.boot || {}).desktop || {}).icons || {}).sortMode) || 'manual';
          this.activeThemeKey = (((this.boot || {}).desktop || {}).themeKey) || 'xp-classic-blue';
          this.normalizeDesktopUiState();
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

        shellThemeQuickMap: function () {
          return {
            'xp-classic-blue': 'windows-xp',
            'win7-aero': 'windows-7',
            'mac-slate': 'mac-os',
            'ubuntu-amber': 'ubuntu'
          };
        },
        shellThemeOptions: function () {
          return [
            { key: 'xp-classic-blue', label: 'Vintage' },
            { key: 'win7-aero', label: 'Glow' },
            { key: 'mac-slate', label: 'Curve' },
            { key: 'ubuntu-amber', label: 'Panel' }
          ];
        },
        resolveShellThemeProfile: function (themeKey) {
          var quickMap = this.shellThemeQuickMap();
          var id = quickMap[String(themeKey || '')] || themeKey || (((this.themeStudioStore || {}).activeThemeId) || '') || 'windows-7';
          this.initThemeStudioStore();
          return this.themeStudioThemeById(id) || this.themeStudioThemeById('windows-7');
        },
        applyShellTheme: function (themeKey) {
          var profile = this.resolveShellThemeProfile(themeKey);
          if (!profile) return null;
          this.themeStudioActivate(profile.id, { persist: true, silent: false });
          return profile;
        },
        desktopWallpaperStyle: function () {
          var profile = this.themeStudioActiveTheme();
          var fit = (profile && profile.wallpaperFit) || 'cover';
          return {
            backgroundColor: (((profile || {}).cssVars || {})['--desktop-bg']) || '#3d7ad6',
            backgroundImage: this.themeStudioWallpaperCss(profile),
            backgroundSize: fit === 'tile' ? '240px auto' : fit,
            backgroundPosition: 'center center',
            backgroundRepeat: fit === 'tile' ? 'repeat' : 'no-repeat'
          };
        },
        currentShellThemeFamily: function () {
          var profile = this.themeStudioActiveTheme();
          return (profile && profile.base) || 'win7';
        },
        deselectAll: function () {
          this.menuOpen = false;
          this.closeDesktopContextMenu();
          if (this.desktopUi) this.desktopUi.selectedKey = '';
        },
        showDesktop: function () {
          (this.windows || []).forEach(function (win) {
            if (!win || win.state === 'closed') return;
            win.state = 'minimized';
          });
          this.activeWindowId = '';
          this.menuOpen = false;
        },
        cycleWindowFocus: function () {
          var ordered = (this.taskbarWindows || []).filter(function (win) { return win && win.state !== 'closed'; }).slice().sort(function (a, b) { return (b.z || 0) - (a.z || 0); });
          var currentIndex = ordered.findIndex(function (win) { return win.id === this.activeWindowId; }, this);
          if (!ordered.length) return;
          currentIndex = currentIndex < 0 ? 0 : ((currentIndex + 1) % ordered.length);
          this.taskbarToggle(ordered[currentIndex].id);
        },
        openTaskManagerPlaceholder: function () {
          if ((this.windows || []).some(function (win) { return win.appKey === 'diagnostics'; })) this.openApp('diagnostics');
          else if ((this.windows || []).some(function (win) { return win.appKey === 'debug-center'; })) this.openApp('debug-center');
        },
        onGlobalShortcut: function (event) {
          var key = String((event && event.key) || '').toLowerCase();
          if (!event) return;
          if ((event.metaKey || event.ctrlKey) && !event.shiftKey && key === 'd') {
            event.preventDefault();
            this.showDesktop();
            return;
          }
          if (event.altKey && key === 'tab') {
            event.preventDefault();
            this.cycleWindowFocus();
            return;
          }
          if (event.ctrlKey && event.shiftKey && key === 'escape') {
            event.preventDefault();
            this.openTaskManagerPlaceholder();
          }
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
          if (!sessionId) return Promise.resolve();
          this.securityCenter.loading = true;
          return this.command('auth.session.revoke', { sessionId: sessionId }).then(function () {
            return self.refreshSecurityCenter();
          }).finally(function () {
            self.securityCenter.loading = false;
          });
        },
        unlockSecurityUser: function (username) {
          var self = this;
          if (!username) return Promise.resolve();
          this.securityCenter.loading = true;
          return this.command('auth.user.unlock', { username: username }).then(function () {
            return self.refreshSecurityCenter();
          }).finally(function () {
            self.securityCenter.loading = false;
          });
        },
        exportSecurityAudit: function () {
          var path = ((this.boot || {}).routes || {}).auditExport || '/api/mioos/auth/audit/export';
          if (!path) return;
          window.open(path, '_blank');
        },
        pushDebugEvent: function (kind, name, detail, meta) {
          var limit = +((((this.boot || {}).desktop || {}).debugCenter || {}).eventLimit || 50) || 50;
          var entry = Object.assign({ id: 'dbg-' + (++this.debugCenter.seq), ts: Date.now(), kind: kind || 'event', name: name || '', detail: detail || '' }, meta || {});
          this.debugCenter.events.unshift(entry);
          if (this.debugCenter.events.length > limit) this.debugCenter.events.splice(limit);
          return entry;
        },
        clearDebugEvents: function () {
          this.debugCenter.events.splice(0, this.debugCenter.events.length);
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
          if (window.navigator && window.navigator.clipboard && window.navigator.clipboard.writeText) {
            window.navigator.clipboard.writeText(text).catch(function () {});
          }
          return text;
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
        clearFinishedTransfers: function () {
          var keep = {};
          this.transferCenter.items = (this.transferCenter.items || []).filter(function (item) {
            var active = ['queued','preparing','uploading','downloading','finalizing','verifying','cancelling','paused'].indexOf(item.status) >= 0;
            if (active) keep[item.id] = 1;
            return active;
          });
          Object.keys(this.transferControllers || {}).forEach(function (key) {
            if (!keep[key]) delete (this.transferControllers || {})[key];
          }, this);
          this.persistTransferCenter();
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
          return { '--x': ((+pos.left || 16) + 'px'), '--y': ((+pos.top || 16) + 'px'), transform: 'translate(var(--x), var(--y))' };
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
          var self = this;
          if (!((this.dragState && this.dragState.active) || (((this.desktopUi || {}).drag || {}).armed))) return;
          this._queuedPointer = { clientX: event.clientX, clientY: event.clientY };
          if (this._dragRaf) return;
          this._dragRaf = window.requestAnimationFrame(function () {
            var next = self._queuedPointer || { clientX: event.clientX, clientY: event.clientY };
            self._dragRaf = 0;
            if (self.onDragMove) self.onDragMove(next);
            self.onDesktopIconMove(next);
          });
        },
        handleGlobalMouseUp: function (event) {
          if (this._dragRaf) {
            window.cancelAnimationFrame(this._dragRaf);
            this._dragRaf = 0;
            if (this._queuedPointer) {
              if (this.onDragMove) this.onDragMove(this._queuedPointer);
              this.onDesktopIconMove(this._queuedPointer);
            }
          }
          this._queuedPointer = null;
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
        closeDesktopContextMenu: function () { var menu = this.desktopContextMenuState(); menu.open = false; },
        contextMenuStyle: function () {
          var menu = this.desktopContextMenuState();
          return { left: (menu.left || 0) + 'px', top: (menu.top || 0) + 'px' };
        },
        desktopContextEntry: function () {
          var menu = this.desktopContextMenuState();
          var key = (menu || {}).key || (this.desktopUi.selectedKey || '');
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
          return 'mioos.themeStudio.active.v2';
        },
        themeStudioProfilesKey: function () {
          return 'mioos.themeStudio.custom.v2';
        },
        themeStudioRootNode: function () {
          return window.MIOOSState.getRootNode ? window.MIOOSState.getRootNode() : null;
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
        themeStudioClone: function (value) {
          if (window.MIOOSState && window.MIOOSState.deepClone) return window.MIOOSState.deepClone(value || {});
          try { return JSON.parse(JSON.stringify(value || {})); } catch (err) { return value || {}; }
        },
        themeStudioDefaultPreviewWindow: function () {
          return { title: 'Sample Window', x: 82, y: 64, w: 292, h: 190 };
        },
        themeStudioBaseThemeConfigs: function () {
          return {
            'windows-xp': {
              id: 'windows-xp', name: 'Vintage', base: 'xp', locked: true, iconSet: 'system', fontStack: 'Tahoma, "Segoe UI", sans-serif', wallpaperPreset: 'bliss', wallpaperUrl: '', wallpaperFit: 'cover', previewScale: 0.86, classModifiers: ['xp-luna'], animationSpeeds: { minimize: 180, progress: 220 }, extraCss: '',
              cssVars: {
                '--desktop-bg': '#3d7ad6', '--desktop-overlay': 'rgba(255,255,255,0.06)', '--window-bg': '#f5f9ff', '--window-border': '#2456a6', '--window-border-strong': '#13326a', '--titlebar-bg': 'linear-gradient(180deg, #0f5bd7 0%, #3f8df6 52%, #a9c7ff 100%)', '--titlebar-text': '#ffffff', '--titlebar-inactive': 'linear-gradient(180deg, #6c89b0 0%, #9bb2ce 100%)', '--accent': '#0b63f6', '--accent-soft': 'rgba(11,99,246,0.18)', '--taskbar-bg': 'linear-gradient(180deg, rgba(255,255,255,0.25) 0%, rgba(255,255,255,0.06) 22%, #0f4aa9 23%, #0a246a 100%)', '--taskbar-border': 'rgba(255,255,255,0.28)', '--taskbar-text': '#ffffff', '--menu-bg': 'rgba(248,251,255,0.96)', '--menu-border': '#7fa7e7', '--menu-text': '#10233f', '--menu-hover': 'linear-gradient(180deg, rgba(255,255,255,0.95) 0%, rgba(200,224,255,0.95) 100%)', '--menu-divider': 'rgba(36,86,166,0.18)', '--menu-shadow': '0 18px 40px rgba(8, 26, 63, 0.35)', '--icon-label-bg': 'rgba(15,32,68,0.36)', '--icon-label-text': '#f8fbff', '--icon-shadow': '0 1px 2px rgba(0,0,0,0.75)', '--shadow-window': '0 18px 40px rgba(8,24,56,0.30)', '--shadow-window-active': '0 24px 48px rgba(4,18,44,0.38)', '--font-ui': 'Tahoma, "Segoe UI", sans-serif', '--font-size-ui': '11px', '--window-radius': '10px', '--desktop-grid-cell': '88px', '--desktop-icon-size': '48px', '--titlebar-height': '32px', '--taskbar-height': '48px', '--button-radius': '7px', '--button-tint': 'linear-gradient(180deg, #ffffff 0%, #d8e8ff 100%)', '--button-tint-hover': 'linear-gradient(180deg, #ffffff 0%, #c8defd 100%)', '--glass-opacity': '0', '--control-min': '#f2d25a', '--control-max': '#7ecb61', '--control-close': '#e06d5c'
              }
            },
            'windows-7': {
              id: 'windows-7', name: 'Glow', base: 'win7', locked: true, iconSet: 'system', fontStack: '"Segoe UI", Tahoma, sans-serif', wallpaperPreset: 'aurora', wallpaperUrl: '', wallpaperFit: 'cover', previewScale: 0.86, classModifiers: ['glass'], animationSpeeds: { minimize: 220, progress: 240 }, extraCss: '',
              cssVars: {
                '--desktop-bg': '#173a5d', '--desktop-overlay': 'rgba(255,255,255,0.08)', '--window-bg': 'rgba(248,251,255,0.78)', '--window-border': 'rgba(255,255,255,0.64)', '--window-border-strong': 'rgba(58,77,106,0.88)', '--titlebar-bg': 'linear-gradient(180deg, rgba(255,255,255,0.38) 0%, rgba(152,198,255,0.14) 100%)', '--titlebar-text': '#12304b', '--titlebar-inactive': 'linear-gradient(180deg, rgba(255,255,255,0.16) 0%, rgba(139,162,190,0.08) 100%)', '--accent': '#4ba3ff', '--accent-soft': 'rgba(75,163,255,0.18)', '--taskbar-bg': 'linear-gradient(180deg, rgba(255,255,255,0.15) 0%, rgba(16,24,39,0.34) 100%)', '--taskbar-border': 'rgba(255,255,255,0.22)', '--taskbar-text': '#f4f8ff', '--menu-bg': 'rgba(248,251,255,0.88)', '--menu-border': 'rgba(255,255,255,0.48)', '--menu-text': '#10243d', '--menu-hover': 'linear-gradient(180deg, rgba(255,255,255,0.78) 0%, rgba(214,231,255,0.85) 100%)', '--menu-divider': 'rgba(255,255,255,0.24)', '--menu-shadow': '0 24px 60px rgba(8, 18, 36, 0.40)', '--icon-label-bg': 'rgba(11,25,49,0.34)', '--icon-label-text': '#f8fbff', '--icon-shadow': '0 1px 2px rgba(0,0,0,0.78)', '--shadow-window': '0 18px 42px rgba(0,0,0,0.28)', '--shadow-window-active': '0 24px 58px rgba(0,0,0,0.36)', '--font-ui': '"Segoe UI", Tahoma, sans-serif', '--font-size-ui': '12px', '--window-radius': '14px', '--desktop-grid-cell': '92px', '--desktop-icon-size': '50px', '--titlebar-height': '36px', '--taskbar-height': '48px', '--button-radius': '8px', '--button-tint': 'linear-gradient(180deg, rgba(255,255,255,0.82) 0%, rgba(224,238,255,0.72) 100%)', '--button-tint-hover': 'linear-gradient(180deg, rgba(255,255,255,0.94) 0%, rgba(210,232,255,0.84) 100%)', '--glass-opacity': '0.76', '--control-min': '#f2d25a', '--control-max': '#7ecb61', '--control-close': '#e06d5c'
              }
            },
            'mac-os': {
              id: 'mac-os', name: 'Curve', base: 'mac', locked: true, iconSet: 'system', fontStack: '-apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif', wallpaperPreset: 'solid-graphite', wallpaperUrl: '', wallpaperFit: 'cover', previewScale: 0.84, classModifiers: ['vibrant'], animationSpeeds: { minimize: 210, progress: 200 }, extraCss: '',
              cssVars: {
                '--desktop-bg': '#5f6975', '--desktop-overlay': 'rgba(255,255,255,0.04)', '--window-bg': 'rgba(252,252,252,0.92)', '--window-border': '#cfd6df', '--window-border-strong': '#adb7c4', '--titlebar-bg': 'linear-gradient(180deg, #f4f5f7 0%, #d7dce2 100%)', '--titlebar-text': '#18202b', '--titlebar-inactive': 'linear-gradient(180deg, #edf1f4 0%, #cfd6dd 100%)', '--accent': '#0a84ff', '--accent-soft': 'rgba(10,132,255,0.16)', '--taskbar-bg': 'rgba(246,247,249,0.26)', '--taskbar-border': 'rgba(255,255,255,0.28)', '--taskbar-text': '#f7f9fc', '--menu-bg': 'rgba(255,255,255,0.82)', '--menu-border': 'rgba(214,221,228,0.82)', '--menu-text': '#1f2937', '--menu-hover': 'linear-gradient(180deg, rgba(255,255,255,0.98) 0%, rgba(238,242,247,0.92) 100%)', '--menu-divider': 'rgba(159,171,184,0.25)', '--menu-shadow': '0 22px 54px rgba(15, 23, 42, 0.30)', '--icon-label-bg': 'rgba(18,25,35,0.28)', '--icon-label-text': '#ffffff', '--icon-shadow': '0 1px 3px rgba(0,0,0,0.75)', '--shadow-window': '0 18px 40px rgba(0,0,0,0.18)', '--shadow-window-active': '0 22px 52px rgba(0,0,0,0.24)', '--font-ui': '-apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif', '--font-size-ui': '12px', '--window-radius': '16px', '--desktop-grid-cell': '90px', '--desktop-icon-size': '50px', '--titlebar-height': '34px', '--taskbar-height': '64px', '--button-radius': '999px', '--button-tint': 'linear-gradient(180deg, rgba(255,255,255,0.95) 0%, rgba(231,235,241,0.92) 100%)', '--button-tint-hover': 'linear-gradient(180deg, rgba(255,255,255,1) 0%, rgba(244,246,249,0.96) 100%)', '--glass-opacity': '0.68', '--control-min': '#f5c84c', '--control-max': '#63c554', '--control-close': '#ff5f57'
              }
            },
            'ubuntu': {
              id: 'ubuntu', name: 'Panel', base: 'ubuntu', locked: true, iconSet: 'system', fontStack: 'Ubuntu, "Segoe UI", sans-serif', wallpaperPreset: 'ubuntu-warm', wallpaperUrl: '', wallpaperFit: 'cover', previewScale: 0.86, classModifiers: ['ambiance'], animationSpeeds: { minimize: 190, progress: 210 }, extraCss: '',
              cssVars: {
                '--desktop-bg': '#3d1937', '--desktop-overlay': 'rgba(255,255,255,0.03)', '--window-bg': '#2b2431', '--window-border': '#6b5d74', '--window-border-strong': '#16111a', '--titlebar-bg': 'linear-gradient(180deg, #4b3a52 0%, #302734 100%)', '--titlebar-text': '#f7f1ff', '--titlebar-inactive': 'linear-gradient(180deg, #5c4d61 0%, #3d3342 100%)', '--accent': '#e95420', '--accent-soft': 'rgba(233,84,32,0.16)', '--taskbar-bg': 'linear-gradient(180deg, rgba(24,24,27,0.95) 0%, rgba(11,11,12,0.96) 100%)', '--taskbar-border': 'rgba(255,255,255,0.08)', '--taskbar-text': '#f8f2ff', '--menu-bg': 'rgba(35,29,39,0.96)', '--menu-border': '#6b5d74', '--menu-text': '#f8f2ff', '--menu-hover': 'linear-gradient(180deg, rgba(233,84,32,0.24) 0%, rgba(98,54,26,0.32) 100%)', '--menu-divider': 'rgba(255,255,255,0.08)', '--menu-shadow': '0 24px 58px rgba(0,0,0,0.42)', '--icon-label-bg': 'rgba(10,8,12,0.36)', '--icon-label-text': '#ffffff', '--icon-shadow': '0 1px 3px rgba(0,0,0,0.85)', '--shadow-window': '0 20px 45px rgba(0,0,0,0.34)', '--shadow-window-active': '0 24px 58px rgba(0,0,0,0.42)', '--font-ui': 'Ubuntu, "Segoe UI", sans-serif', '--font-size-ui': '11px', '--window-radius': '12px', '--desktop-grid-cell': '90px', '--desktop-icon-size': '48px', '--titlebar-height': '34px', '--taskbar-height': '40px', '--button-radius': '6px', '--button-tint': 'linear-gradient(180deg, rgba(255,255,255,0.12) 0%, rgba(233,84,32,0.10) 100%)', '--button-tint-hover': 'linear-gradient(180deg, rgba(255,255,255,0.18) 0%, rgba(233,84,32,0.22) 100%)', '--glass-opacity': '0.18', '--control-min': '#f2d25a', '--control-max': '#7ecb61', '--control-close': '#e95420'
              }
            }
          };
        },
        themeStudioNormalizeConfig: function (config) {
          var incoming = this.themeStudioClone(config || {});
          var presets = this.themeStudioBaseThemeConfigs();
          var baseId = incoming.id && presets[incoming.id] ? incoming.id : ((incoming.base === 'xp' || incoming.family === 'Windows XP') ? 'windows-xp' : ((incoming.base === 'mac' || incoming.family === 'Mac') ? 'mac-os' : ((incoming.base === 'ubuntu' || incoming.family === 'Ubuntu') ? 'ubuntu' : 'windows-7')));
          var base = this.themeStudioClone(presets[baseId] || presets['windows-7']);
          var next = Object.assign({}, base, incoming || {});
          next.cssVars = Object.assign({}, base.cssVars || {}, (incoming || {}).cssVars || {});
          next.animationSpeeds = Object.assign({}, base.animationSpeeds || {}, (incoming || {}).animationSpeeds || {});
          next.classModifiers = Array.isArray((incoming || {}).classModifiers) ? incoming.classModifiers.slice(0) : (String((incoming || {}).classModifiers || '').trim() ? String(incoming.classModifiers).split(/\s+/) : (base.classModifiers || []).slice(0));
          if (!next.id) next.id = base.id;
          if (!next.name) next.name = base.name;
          if (!next.base) next.base = base.base;
          if (!next.fontStack) next.fontStack = next.cssVars['--font-ui'] || base.fontStack;
          next.cssVars['--font-ui'] = next.fontStack;
          if (!next.wallpaperPreset) next.wallpaperPreset = base.wallpaperPreset;
          if (!next.wallpaperFit) next.wallpaperFit = base.wallpaperFit;
          if (!next.previewScale) next.previewScale = base.previewScale;
          if (typeof next.locked === 'undefined') next.locked = !!base.locked;
          if (!next.extraCss) next.extraCss = '';
          return next;
        },
        initThemeStudioStore: function () {
          var store = this.themeStudioStore || {};
          var presets, rawCustom, parsedCustom, rawApplied, parsedApplied, bootTheme, quickMap;
          if (store.initialized) return store;
          store.themes = {};
          store.order = [];
          store.customThemes = [];
          store.activeThemeId = 'windows-7';
          store.previewWindowState = this.themeStudioDefaultPreviewWindow();
          store.importBuffer = '';
          store.activeTab = 'global';
          if (!store.previewTab) store.previewTab = 'desktop';
          presets = this.themeStudioBaseThemeConfigs();
          Object.keys(presets).forEach(function (id) {
            store.themes[id] = this.themeStudioNormalizeConfig(presets[id]);
            store.order.push(id);
          }.bind(this));
          try { rawCustom = window.localStorage.getItem(this.themeStudioProfilesKey()); } catch (err) { rawCustom = ''; }
          try { parsedCustom = JSON.parse(rawCustom || '[]'); } catch (err2) { parsedCustom = []; }
          if (Array.isArray(parsedCustom)) {
            parsedCustom.forEach(function (entry) {
              var cfg = this.themeStudioNormalizeConfig(entry || {});
              cfg.locked = false;
              if (!cfg.id) cfg.id = 'custom-' + Date.now();
              store.themes[cfg.id] = cfg;
              store.order.push(cfg.id);
              store.customThemes.push(cfg.id);
            }.bind(this));
          }
          try { rawApplied = window.localStorage.getItem(this.themeStudioStorageKey()); } catch (err3) { rawApplied = ''; }
          try { parsedApplied = rawApplied ? JSON.parse(rawApplied) : null; } catch (err4) { parsedApplied = null; }
          if (parsedApplied) {
            parsedApplied = this.themeStudioNormalizeConfig(parsedApplied);
            if (!store.themes[parsedApplied.id]) {
              parsedApplied.locked = false;
              store.themes[parsedApplied.id] = parsedApplied;
              store.order.push(parsedApplied.id);
              store.customThemes.push(parsedApplied.id);
            }
            store.activeThemeId = parsedApplied.id;
          } else {
            bootTheme = String((((this.boot || {}).desktop || {}).themeKey) || '');
            quickMap = this.shellThemeQuickMap();
            if (quickMap[bootTheme]) store.activeThemeId = quickMap[bootTheme];
          }
          store.initialized = true;
          this.themeStudioStore = store;
          return store;
        },
        themeStudioThemeList: function () {
          var store = this.initThemeStudioStore();
          return (store.order || []).map(function (id) { return store.themes[id]; }).filter(Boolean);
        },
        themeStudioThemeById: function (id) {
          var store = this.initThemeStudioStore();
          return (store.themes || {})[id] || null;
        },
        themeStudioActiveTheme: function () {
          var store = this.initThemeStudioStore();
          return this.themeStudioThemeById(store.activeThemeId) || this.themeStudioThemeById('windows-7');
        },
        themeStudioEditableTheme: function () {
          var store = this.initThemeStudioStore();
          var active = this.themeStudioActiveTheme();
          var copy;
          if (!active) return null;
          if (!active.locked) return active;
          copy = this.themeStudioClone(active);
          copy.id = 'custom-' + Date.now();
          copy.name = active.name + ' Copy';
          copy.locked = false;
          copy.sourceId = active.id;
          store.themes[copy.id] = copy;
          store.order.push(copy.id);
          store.customThemes.push(copy.id);
          store.activeThemeId = copy.id;
          this.themeStudioPersistCustomThemes();
          return copy;
        },
        themeStudioPersistCustomThemes: function () {
          var store = this.initThemeStudioStore();
          var payload = (store.order || []).map(function (id) { return store.themes[id]; }).filter(function (item) { return item && !item.locked; });
          store.customThemes = payload.map(function (item) { return item.id; });
          try { window.localStorage.setItem(this.themeStudioProfilesKey(), JSON.stringify(payload)); } catch (err) {}
        },
        themeStudioWallpaperCss: function (theme) {
          var t = this.themeStudioNormalizeConfig(theme || this.themeStudioActiveTheme() || {});
          if (t.wallpaperPreset === 'custom-url' && t.wallpaperUrl) return 'url(' + t.wallpaperUrl + ')';
          if (t.wallpaperPreset === 'bliss') return 'linear-gradient(180deg, rgba(255,255,255,0.14) 0%, rgba(255,255,255,0) 28%), linear-gradient(180deg, #8acb59 0%, #6fb14a 42%, #3e7b35 100%)';
          if (t.wallpaperPreset === 'aurora') return 'radial-gradient(circle at top, rgba(147,197,253,0.26), transparent 30%), linear-gradient(180deg, #16385c 0%, #23476d 36%, #3a6288 100%)';
          if (t.wallpaperPreset === 'solid-graphite') return 'linear-gradient(180deg, #6c7a89 0%, #313b48 100%)';
          if (t.wallpaperPreset === 'ubuntu-warm') return 'linear-gradient(180deg, #6e2d35 0%, #2d2c54 100%)';
          return 'linear-gradient(180deg, #3d7ad6 0%, #2656a5 100%)';
        },
        applyPersistedThemeStudioProfile: function () {
          this.initThemeStudioStore();
          this.applyThemeStudioConfig(this.themeStudioActiveTheme(), { silent: true, persist: false });
        },
        applyThemeStudioConfig: function (config, options) {
          var rootNode = this.themeStudioRootNode();
          var opts = options || {};
          var theme = this.themeStudioNormalizeConfig(config || this.themeStudioActiveTheme() || {});
          var styleNode = this.themeStudioEnsureStyleNode();
          var body = document.body;
          var current, modifierClasses;
          if (!rootNode) return theme;
          current = theme.cssVars || {};
          Object.keys(current).forEach(function (key) { rootNode.style.setProperty(key, current[key]); });
          rootNode.style.setProperty('--desktop-wallpaper', this.themeStudioWallpaperCss(theme));
          rootNode.style.setProperty('--font-ui', theme.fontStack || current['--font-ui'] || '"Segoe UI", sans-serif');
          rootNode.style.setProperty('--theme-minimize-speed', Math.max(120, +(theme.animationSpeeds || {}).minimize || 180) + 'ms');
          rootNode.style.setProperty('--theme-progress-speed', Math.max(120, +(theme.animationSpeeds || {}).progress || 220) + 'ms');
          rootNode.dataset.shellTheme = theme.id || 'windows-7';
          rootNode.dataset.shellFamily = theme.base || 'win7';
          rootNode.dataset.themeBase = theme.base || 'win7';
          rootNode.classList.remove('theme-base-xp', 'theme-base-win7', 'theme-base-mac', 'theme-base-ubuntu');
          rootNode.classList.add('theme-base-' + (theme.base || 'win7'));
          modifierClasses = Array.prototype.slice.call(rootNode.classList).filter(function (name) { return name.indexOf('theme-mod-') === 0; });
          modifierClasses.forEach(function (name) { rootNode.classList.remove(name); });
          (theme.classModifiers || []).forEach(function (name) {
            if (name) rootNode.classList.add('theme-mod-' + String(name).replace(/[^a-z0-9_-]/ig, '-').toLowerCase());
          });
          styleNode.textContent = theme.extraCss || '';
          if (body) body.style.background = current['--desktop-bg'] || '#3d7ad6';
          this.activeThemeKey = theme.id;
          this.appliedThemeProfile = this.themeStudioClone(theme);
          this.themeStudioStore.activeThemeId = theme.id;
          if (!opts.silent) this.showAlert('Theme Studio', (theme.name || 'Theme') + ' applied.');
          if (opts.persist !== false) {
            try { window.localStorage.setItem(this.themeStudioStorageKey(), JSON.stringify(theme)); } catch (err) {}
          }
          return theme;
        },
        themeStudioTabs: function () {
          return [
            { key: 'global', label: 'Global' },
            { key: 'window', label: 'Window' },
            { key: 'buttons', label: 'Buttons' },
            { key: 'menus', label: 'Menus' },
            { key: 'taskbar', label: 'Taskbar & Icons' },
            { key: 'advanced', label: 'Advanced' }
          ];
        },
        themeStudioActiveTab: function () {
          return (((this.themeStudioStore || {}).activeTab) || 'global');
        },
        themeStudioSetTab: function (tabKey) {
          this.initThemeStudioStore();
          this.themeStudioStore.activeTab = tabKey || 'global';
        },
        themeStudioActivate: function (id, options) {
          var store = this.initThemeStudioStore();
          if (!store.themes[id]) return;
          store.activeThemeId = id;
          this.applyThemeStudioConfig(store.themes[id], { silent: options && options.silent !== undefined ? options.silent : true, persist: options && options.persist !== undefined ? options.persist : false });
        },
        themeStudioCreateNewTheme: function (name) {
          var theme = this.themeStudioClone(this.themeStudioActiveTheme() || this.themeStudioThemeById('windows-7'));
          var store = this.initThemeStudioStore();
          theme.id = 'custom-' + Date.now();
          theme.name = name || 'New Custom Theme';
          theme.locked = false;
          theme.sourceId = this.themeStudioStore.activeThemeId;
          store.themes[theme.id] = theme;
          store.order.push(theme.id);
          store.customThemes.push(theme.id);
          store.activeThemeId = theme.id;
          this.themeStudioPersistCustomThemes();
          this.applyThemeStudioConfig(theme, { silent: true, persist: false });
        },
        themeStudioDuplicateTheme: function (sourceId) {
          var source = this.themeStudioThemeById(sourceId || ((this.themeStudioStore || {}).activeThemeId));
          var store = this.initThemeStudioStore();
          var copy;
          if (!source) return;
          copy = this.themeStudioClone(source);
          copy.id = 'custom-' + Date.now();
          copy.name = (source.name || 'Theme') + ' Copy';
          copy.locked = false;
          copy.sourceId = source.id;
          store.themes[copy.id] = copy;
          store.order.push(copy.id);
          store.customThemes.push(copy.id);
          store.activeThemeId = copy.id;
          this.themeStudioPersistCustomThemes();
          this.applyThemeStudioConfig(copy, { silent: true, persist: false });
        },
        themeStudioLoadBaseTheme: function (baseName) {
          var target = this.themeStudioEditableTheme();
          var preset = this.themeStudioBaseThemeConfigs()[baseName || 'windows-7'];
          var previousName;
          if (!target || !preset) return;
          previousName = target.name;
          preset = this.themeStudioNormalizeConfig(preset);
          Object.assign(target, this.themeStudioClone(preset), { id: target.id, name: previousName, locked: false, sourceId: preset.id });
          this.applyThemeStudioConfig(target, { silent: true, persist: false });
          this.themeStudioPersistCustomThemes();
        },
        themeStudioResetToBase: function () {
          var active = this.themeStudioActiveTheme();
          var sourceId;
          if (!active) return;
          sourceId = active.sourceId || (active.base === 'xp' ? 'windows-xp' : (active.base === 'mac' ? 'mac-os' : (active.base === 'ubuntu' ? 'ubuntu' : 'windows-7')));
          if (active.locked) {
            this.themeStudioActivate(active.id, { persist: false, silent: true });
            return;
          }
          Object.assign(active, this.themeStudioClone(this.themeStudioBaseThemeConfigs()[sourceId] || this.themeStudioBaseThemeConfigs()['windows-7']), { id: active.id, name: active.name, locked: false, sourceId: sourceId });
          this.applyThemeStudioConfig(active, { silent: true, persist: false });
          this.themeStudioPersistCustomThemes();
        },
        themeStudioDeleteCustomTheme: function (id) {
          var store = this.initThemeStudioStore();
          var targetId = id || store.activeThemeId;
          var fallback;
          if (!store.themes[targetId] || store.themes[targetId].locked) return;
          delete store.themes[targetId];
          store.order = (store.order || []).filter(function (item) { return item !== targetId; });
          store.customThemes = (store.customThemes || []).filter(function (item) { return item !== targetId; });
          fallback = this.themeStudioThemeById('windows-7') || this.themeStudioThemeList()[0];
          store.activeThemeId = fallback ? fallback.id : 'windows-7';
          this.themeStudioPersistCustomThemes();
          this.applyThemeStudioConfig(this.themeStudioActiveTheme(), { silent: true, persist: false });
        },
        themeStudioUpdateField: function (path, value) {
          var target = this.themeStudioEditableTheme();
          var ref = target;
          var parts = String(path || '').split('.');
          var i;
          if (!target || !parts.length) return;
          for (i = 0; i < parts.length - 1; i += 1) {
            if (!ref[parts[i]] || typeof ref[parts[i]] !== 'object') ref[parts[i]] = {};
            ref = ref[parts[i]];
          }
          ref[parts[parts.length - 1]] = value;
          if (path === 'fontStack') target.cssVars['--font-ui'] = value;
          this.applyThemeStudioConfig(target, { silent: true, persist: false });
          this.themeStudioPersistCustomThemes();
        },
        themeStudioUpdateVar: function (key, value) {
          var target = this.themeStudioEditableTheme();
          if (!target) return;
          if (!target.cssVars) target.cssVars = {};
          target.cssVars[key] = value;
          if (key === '--font-ui') target.fontStack = value;
          this.applyThemeStudioConfig(target, { silent: true, persist: false });
          this.themeStudioPersistCustomThemes();
        },
        themeStudioSetClassModifiers: function (value) {
          var target = this.themeStudioEditableTheme();
          if (!target) return;
          target.classModifiers = String(value || '').trim() ? String(value).trim().split(/\s+/) : [];
          this.applyThemeStudioConfig(target, { silent: true, persist: false });
          this.themeStudioPersistCustomThemes();
        },
        themeStudioClassModifiersText: function () {
          var active = this.themeStudioActiveTheme();
          return ((active || {}).classModifiers || []).join(' ');
        },
        themeStudioApplyToDesktop: function (id) {
          var target = this.themeStudioThemeById(id || ((this.themeStudioStore || {}).activeThemeId));
          if (!target) return;
          this.themeStudioActivate(target.id, { persist: true, silent: false });
        },
        themeStudioExportTheme: function (id) {
          var store = this.initThemeStudioStore();
          var target = this.themeStudioThemeById(id || store.activeThemeId);
          if (!target) return;
          store.importBuffer = JSON.stringify(target, null, 2);
          this.showAlert('Theme Studio', 'Theme JSON copied into the import/export buffer.');
        },
        themeStudioImportTheme: function () {
          var store = this.initThemeStudioStore();
          var parsed;
          if (!store.importBuffer) return;
          try { parsed = JSON.parse(store.importBuffer); } catch (err) { this.showAlert('Theme Studio', 'Import buffer is not valid JSON.'); return; }
          parsed = this.themeStudioNormalizeConfig(parsed);
          parsed.id = 'custom-' + Date.now();
          parsed.locked = false;
          if (!parsed.name) parsed.name = 'Imported Theme';
          store.themes[parsed.id] = parsed;
          store.order.push(parsed.id);
          store.customThemes.push(parsed.id);
          store.activeThemeId = parsed.id;
          this.themeStudioPersistCustomThemes();
          this.applyThemeStudioConfig(parsed, { silent: true, persist: false });
        },
        themeStudioCopyImportBuffer: function () {
          var store = this.initThemeStudioStore();
          var value = String(store.importBuffer || '');
          if (!value) return;
          if (navigator.clipboard && navigator.clipboard.writeText) {
            navigator.clipboard.writeText(value).then(function(){}, function(){});
          }
          this.showAlert('Theme Studio', 'Theme JSON copied to clipboard.');
        },
        themeStudioSaveCustomTheme: function () {
          if (this.themeStudioActiveTheme() && this.themeStudioActiveTheme().locked) return;
          this.themeStudioPersistCustomThemes();
          this.showAlert('Theme Studio', 'Custom theme saved.');
        },
        themeStudioIsActive: function (id) {
          return (((this.themeStudioStore || {}).activeThemeId) || '') === id;
        },
        themeStudioPreviewRootStyle: function () {
          var active = this.themeStudioActiveTheme();
          var style = { '--desktop-wallpaper': this.themeStudioWallpaperCss(active), transform: 'scale(' + (((active || {}).previewScale) || 0.86) + ')' };
          Object.keys(((active || {}).cssVars) || {}).forEach(function (key) { style[key] = active.cssVars[key]; });
          return style;
        },
        themeStudioPreviewIcons: function () {
          return [
            { key: 'pc', icon: '🖥', label: 'Computer' },
            { key: 'docs', icon: '📁', label: 'Documents' },
            { key: 'paint', icon: '🎨', label: 'Studio' }
          ];
        },
        themeStudioColorValue: function (key, fallback) {
          var active = this.themeStudioActiveTheme();
          return ((((active || {}).cssVars) || {})[key]) || fallback || '#000000';
        },
        themeStudioTextValue: function (key, fallback) {
          return this.themeStudioColorValue(key, fallback || '');
        },
        themeStudioStorageKey: function () {
          return 'mioos.themeStudio.active.v5';
        },
        themeStudioProfilesKey: function () {
          return 'mioos.themeStudio.custom.v5';
        },
        themeStudioNormalizeConfig: function (config) {
          var incoming = this.themeStudioClone(config || {});
          var presets = this.themeStudioBaseThemeConfigs();
          var baseId = incoming.sourceId || incoming.id || 'windows-7';
          var base = this.themeStudioClone(presets[baseId] || presets['windows-7']);
          var out = Object.assign({}, base, incoming);
          out.cssVars = Object.assign({}, base.cssVars || {}, incoming.cssVars || {});
          out.animationSpeeds = Object.assign({}, base.animationSpeeds || {}, incoming.animationSpeeds || {});
          out.taskbarConfig = Object.assign({ position: 'bottom', height: parseInt((base.cssVars || {})['--taskbar-height'] || '48', 10) || 48, transparentAmount: 0, buttonStyle: 'xp' }, base.taskbarConfig || {}, incoming.taskbarConfig || {});
          out.startMenuConfig = Object.assign({ style: 'classic', width: 360, accentColor: (out.cssVars || {})['--accent'] || '#0b63f6', nested: true, variants: ['classic', 'panel'] }, base.startMenuConfig || {}, incoming.startMenuConfig || {});
          out.loginScreenConfig = Object.assign({ wallpaperUrl: '', privacyNotice: '', warningTitle: '', loginBoxStyle: 'xp-transparent', avatarSize: 72, textColor: (out.cssVars || {})['--taskbar-text'] || '#ffffff' }, base.loginScreenConfig || {}, incoming.loginScreenConfig || {});
          out.mobileConfig = Object.assign({ taskbarHeightMobile: 46, iconSizeMobile: 60, dockCompact: true }, base.mobileConfig || {}, incoming.mobileConfig || {});
          out.colorSchemes = (incoming.colorSchemes && incoming.colorSchemes.length) ? incoming.colorSchemes.slice() : ((base.colorSchemes && base.colorSchemes.length) ? base.colorSchemes.slice() : []);
          out.darkEnabled = !!incoming.darkEnabled;
          if (!out.id) out.id = 'custom-' + Date.now();
          if (!out.name) out.name = base.name || 'Custom Theme';
          if (!out.sourceId) out.sourceId = base.id || 'windows-7';
          if (!out.wallpaperPreset) out.wallpaperPreset = base.wallpaperPreset || 'aurora';
          if (out.wallpaperUrl && out.wallpaperPreset !== 'custom-upload') out.wallpaperPreset = 'custom-upload';
          return out;
        },
        initThemeStudioStore: function () {
          var store = this.themeStudioStore || {};
          var presets, rawCustom, parsedCustom, rawApplied, parsedApplied;
          if (store.initialized) return store;
          store.initialized = true;
          store.themes = {};
          store.order = [];
          store.customThemes = [];
          store.activeTab = 'themes';
          if (!store.previewTab) store.previewTab = 'desktop';
          store.previewWindowState = this.themeStudioDefaultPreviewWindow();
          store.importBuffer = '';
          presets = this.themeStudioBaseThemeConfigs();
          Object.keys(presets).forEach(function (id) {
            store.themes[id] = this.themeStudioNormalizeConfig(presets[id]);
            store.order.push(id);
          }.bind(this));
          try { rawCustom = window.localStorage.getItem(this.themeStudioProfilesKey()); } catch (err) { rawCustom = ''; }
          if (rawCustom) {
            try { parsedCustom = JSON.parse(rawCustom); } catch (err2) { parsedCustom = []; }
            if (Array.isArray(parsedCustom)) {
              parsedCustom.forEach(function (entry) {
                var cfg = this.themeStudioNormalizeConfig(entry || {});
                cfg.locked = false;
                store.themes[cfg.id] = cfg;
                store.order.push(cfg.id);
                store.customThemes.push(cfg.id);
              }.bind(this));
            }
          }
          try { rawApplied = window.localStorage.getItem(this.themeStudioStorageKey()); } catch (err3) { rawApplied = ''; }
          if (rawApplied) {
            try { parsedApplied = this.themeStudioNormalizeConfig(JSON.parse(rawApplied)); } catch (err4) { parsedApplied = null; }
          }
          if (parsedApplied) {
            store.themes[parsedApplied.id] = parsedApplied;
            if (store.order.indexOf(parsedApplied.id) < 0) store.order.push(parsedApplied.id);
            if (!parsedApplied.locked && store.customThemes.indexOf(parsedApplied.id) < 0) store.customThemes.push(parsedApplied.id);
            store.activeThemeId = parsedApplied.id;
          } else {
            store.activeThemeId = 'windows-7';
          }
          this.themeStudioStore = store;
          return store;
        },
        themeStudioThemeList: function () {
          var store = this.initThemeStudioStore();
          return (store.order || []).map(function (id) { return store.themes[id]; }).filter(Boolean).sort(function (a, b) {
            if (!!a.locked === !!b.locked) return String(a.name || '').localeCompare(String(b.name || ''));
            return a.locked ? -1 : 1;
          });
        },
        themeStudioWallpaperCss: function (theme) {
          var t = this.themeStudioNormalizeConfig(theme || this.themeStudioActiveTheme() || {});
          if (t.wallpaperUrl) return 'url(' + t.wallpaperUrl + ')';
          if (t.wallpaperPreset === 'bliss') return 'linear-gradient(180deg, rgba(255,255,255,0.14) 0%, rgba(255,255,255,0) 28%), linear-gradient(180deg, #8acb59 0%, #6fb14a 42%, #3e7b35 100%)';
          if (t.wallpaperPreset === 'aurora') return 'radial-gradient(circle at top, rgba(147,197,253,0.26), transparent 30%), linear-gradient(180deg, #16385c 0%, #23476d 36%, #3a6288 100%)';
          if (t.wallpaperPreset === 'solid-graphite') return 'linear-gradient(180deg, #6c7a89 0%, #313b48 100%)';
          if (t.wallpaperPreset === 'ubuntu-warm') return 'linear-gradient(180deg, #6e2d35 0%, #2d2c54 100%)';
          return 'linear-gradient(180deg, #3d7ad6 0%, #2656a5 100%)';
        },
        themeStudioLoginWallpaperCss: function (theme) {
          var t = this.themeStudioNormalizeConfig(theme || this.themeStudioActiveTheme() || {});
          var cfg = t.loginScreenConfig || {};
          if (cfg.wallpaperUrl) return 'url(' + cfg.wallpaperUrl + ')';
          return this.themeStudioWallpaperCss(t);
        },
        themeStudioDarkOverrides: function (theme) {
          if (!theme || !theme.darkEnabled) return {};
          var accent = ((((theme || {}).cssVars) || {})['--accent']) || '#5aa2ff';
          return {
            '--desktop-overlay': 'rgba(255,255,255,0.02)',
            '--window-bg': 'rgba(22, 28, 39, 0.94)',
            '--window-border': 'rgba(124, 148, 182, 0.34)',
            '--window-border-strong': 'rgba(6, 10, 18, 0.92)',
            '--titlebar-text': '#eff6ff',
            '--titlebar-bg': 'linear-gradient(180deg, rgba(72,86,113,0.96) 0%, rgba(24,32,45,0.98) 100%)',
            '--titlebar-inactive': 'linear-gradient(180deg, rgba(68,78,95,0.78) 0%, rgba(29,35,47,0.92) 100%)',
            '--taskbar-bg': 'linear-gradient(180deg, rgba(30,36,48,0.92) 0%, rgba(9,12,18,0.97) 100%)',
            '--taskbar-text': '#f3f8ff',
            '--taskbar-border': 'rgba(255,255,255,0.12)',
            '--menu-bg': 'rgba(20, 26, 36, 0.96)',
            '--menu-border': 'rgba(124,148,182,0.30)',
            '--menu-text': '#f2f7ff',
            '--menu-hover': 'linear-gradient(180deg, color-mix(in srgb, ' + accent + ' 34%, rgba(255,255,255,0.12)) 0%, rgba(26,36,52,0.96) 100%)',
            '--menu-divider': 'rgba(148,163,184,0.18)',
            '--icon-label-bg': 'rgba(8, 14, 22, 0.62)',
            '--icon-label-text': '#ffffff',
            '--button-tint': 'linear-gradient(180deg, rgba(88,105,132,0.98) 0%, rgba(45,58,78,0.98) 100%)',
            '--button-tint-hover': 'linear-gradient(180deg, rgba(112,131,161,1) 0%, rgba(55,70,93,0.98) 100%)',
            '--theme-surface': 'rgba(17, 22, 31, 0.82)',
            '--theme-surface-strong': 'rgba(23, 29, 40, 0.92)',
            '--theme-panel-bg': 'rgba(21, 27, 37, 0.88)',
            '--theme-panel-border': 'rgba(124, 148, 182, 0.20)',
            '--theme-field-bg': 'rgba(14, 19, 27, 0.94)',
            '--theme-field-text': '#f3f7fd',
            '--theme-muted-text': '#c4d0df',
            '--theme-tab-bg': 'rgba(20, 26, 36, 0.80)',
            '--theme-tab-active-bg': 'linear-gradient(180deg, rgba(104,138,182,0.32) 0%, rgba(24,32,45,0.96) 100%)',
            '--theme-tab-border': 'rgba(124, 148, 182, 0.24)',
            '--theme-preview-card-bg': 'rgba(18, 24, 33, 0.72)',
            '--theme-preview-card-border': 'rgba(124, 148, 182, 0.20)'
          };
        },
        applyThemeStudioConfig: function (config, options) {
          var rootNode = this.themeStudioRootNode();
          var opts = options || {};
          var theme = this.themeStudioNormalizeConfig(config || this.themeStudioActiveTheme() || {});
          var styleNode = this.themeStudioEnsureStyleNode();
          var body = document.body;
          var current, darkVars, taskbarHeightPx, loginCfg, loginStyle;
          if (!rootNode) return theme;
          current = Object.assign({}, theme.cssVars || {});
          darkVars = this.themeStudioDarkOverrides(theme);
          Object.keys(darkVars).forEach(function (key) { current[key] = darkVars[key]; });
          taskbarHeightPx = ((theme.taskbarConfig || {}).height || parseInt(current['--taskbar-height'] || '48', 10) || 48) + 'px';
          current['--taskbar-height'] = taskbarHeightPx;
          current['--taskbar-position'] = (theme.taskbarConfig || {}).position || 'bottom';
          current['--start-menu-width'] = (((theme.startMenuConfig || {}).width) || 360) + 'px';
          current['--start-menu-accent'] = ((theme.startMenuConfig || {}).accentColor) || current['--accent'] || '#0b63f6';
          current['--font-ui'] = theme.fontStack || current['--font-ui'] || '"Segoe UI", sans-serif';
          current['--font-titlebar'] = current['--font-titlebar'] || current['--font-ui'];
          current['--font-taskbar'] = current['--font-taskbar'] || current['--font-ui'];
          current['--font-menu'] = current['--font-menu'] || current['--font-ui'];
          current['--font-icon-label'] = current['--font-icon-label'] || current['--font-ui'];
          current['--font-size-ui'] = current['--font-size-ui'] || '12px';
          current['--font-size-titlebar'] = current['--font-size-titlebar'] || current['--font-size-ui'];
          current['--font-size-taskbar'] = current['--font-size-taskbar'] || current['--font-size-ui'];
          current['--font-size-menu'] = current['--font-size-menu'] || current['--font-size-ui'];
          current['--font-size-icon-label'] = current['--font-size-icon-label'] || current['--font-size-ui'];
          current['--desktop-icon-size-mobile'] = (((theme.mobileConfig || {}).iconSizeMobile) || 60) + 'px';
          current['--taskbar-height-mobile'] = (((theme.mobileConfig || {}).taskbarHeightMobile) || 46) + 'px';
          Object.keys(current).forEach(function (key) { rootNode.style.setProperty(key, current[key]); });
          rootNode.style.setProperty('--desktop-wallpaper', this.themeStudioWallpaperCss(theme));
          rootNode.style.setProperty('--login-wallpaper', this.themeStudioLoginWallpaperCss(theme));
          rootNode.style.setProperty('--theme-minimize-speed', Math.max(120, +(theme.animationSpeeds || {}).minimize || 180) + 'ms');
          rootNode.style.setProperty('--theme-progress-speed', Math.max(120, +(theme.animationSpeeds || {}).progress || 220) + 'ms');
          loginCfg = theme.loginScreenConfig || {};
          loginStyle = loginCfg.loginBoxStyle || 'xp-transparent';
          if (loginStyle === 'glow-vibrant') {
            rootNode.style.setProperty('--login-box-bg', 'rgba(11, 28, 52, 0.58)');
            rootNode.style.setProperty('--login-box-border', 'rgba(255,255,255,0.32)');
            rootNode.style.setProperty('--login-box-shadow', '0 20px 54px rgba(2, 8, 23, 0.44)');
          } else if (loginStyle === 'curve-minimal') {
            rootNode.style.setProperty('--login-box-bg', 'rgba(255,255,255,0.82)');
            rootNode.style.setProperty('--login-box-border', 'rgba(214,221,228,0.84)');
            rootNode.style.setProperty('--login-box-shadow', '0 18px 42px rgba(15, 23, 42, 0.22)');
          } else {
            rootNode.style.setProperty('--login-box-bg', 'rgba(255,255,255,0.76)');
            rootNode.style.setProperty('--login-box-border', 'rgba(255,255,255,0.28)');
            rootNode.style.setProperty('--login-box-shadow', '0 22px 56px rgba(0,0,0,0.28)');
          }
          rootNode.style.setProperty('--login-box-text', loginCfg.textColor || current['--taskbar-text'] || '#ffffff');
          rootNode.dataset.shellTheme = theme.id || 'windows-7';
          rootNode.dataset.shellFamily = theme.base || 'win7';
          rootNode.dataset.themeBase = theme.base || 'win7';
          rootNode.dataset.taskbarPosition = (theme.taskbarConfig || {}).position || 'bottom';
          rootNode.dataset.startMenuStyle = (theme.startMenuConfig || {}).style || 'classic';
          rootNode.dataset.taskbarButtonStyle = (theme.taskbarConfig || {}).buttonStyle || 'xp';
          rootNode.classList.toggle('theme-dark-mode', !!theme.darkEnabled);
          rootNode.classList.remove('theme-base-xp', 'theme-base-win7', 'theme-base-mac', 'theme-base-ubuntu');
          rootNode.classList.add('theme-base-' + (theme.base || 'win7'));
          Array.prototype.slice.call(rootNode.classList).filter(function (name) { return name.indexOf('theme-mod-') === 0; }).forEach(function (name) { rootNode.classList.remove(name); });
          (theme.classModifiers || []).forEach(function (name) {
            if (name) rootNode.classList.add('theme-mod-' + String(name).replace(/[^a-z0-9_-]/ig, '-').toLowerCase());
          });
          styleNode.textContent = theme.extraCss || '';
          if (body) body.style.background = current['--desktop-bg'] || '#3d7ad6';
          this.activeThemeKey = theme.id;
          this.appliedThemeProfile = this.themeStudioClone(theme);
          this.themeStudioStore.activeThemeId = theme.id;
          if (((this.boot || {}).desktop || {}).windowing) this.boot.desktop.windowing.taskbarHeight = parseInt(taskbarHeightPx, 10) || 48;
          if ((this.boot || {}).desktop) this.boot.desktop.taskbarPosition = (theme.taskbarConfig || {}).position || 'bottom';
          if (!opts.silent) this.showAlert('Theme Studio', (theme.name || 'Theme') + ' applied.');
          if (opts.persist !== false) {
            try { window.localStorage.setItem(this.themeStudioStorageKey(), JSON.stringify(theme)); } catch (err) {}
          }
          return theme;
        },
        themeStudioTabs: function () {
          return [
            { key: 'themes', label: 'Themes' },
            { key: 'desktop', label: 'Desktop' },
            { key: 'appearance', label: 'Appearance' },
            { key: 'taskbar', label: 'Taskbar' },
            { key: 'start', label: 'Start Menu' },
            { key: 'login', label: 'Login Screen' },
            { key: 'advanced', label: 'Advanced' }
          ];
        },
        themeStudioActiveTab: function () {
          return (((this.themeStudioStore || {}).activeTab) || 'themes');
        },
        themeStudioFontOptions: function () {
          return [
            { value: 'Tahoma, "Segoe UI", sans-serif', label: 'Tahoma / Segoe UI' },
            { value: '"Segoe UI", Tahoma, sans-serif', label: 'Segoe UI' },
            { value: 'Verdana, Geneva, sans-serif', label: 'Verdana' },
            { value: 'Trebuchet MS, "Segoe UI", sans-serif', label: 'Trebuchet MS' },
            { value: 'Ubuntu, "Segoe UI", sans-serif', label: 'Ubuntu' },
            { value: '-apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif', label: 'System UI' },
            { value: '"MS Sans Serif", Tahoma, sans-serif', label: 'MS Sans Serif' }
          ];
        },
        themeStudioFontFieldMap: function () {
          return { ui: '--font-ui', titlebar: '--font-titlebar', taskbar: '--font-taskbar', menu: '--font-menu', icon: '--font-icon-label' };
        },
        themeStudioFontValue: function (role, fallback) {
          var map = this.themeStudioFontFieldMap();
          var key = map[role] || '--font-ui';
          var active = this.themeStudioActiveTheme() || {};
          return (((active.cssVars || {})[key]) || active.fontStack || fallback || this.themeStudioFontOptions()[0].value);
        },
        themeStudioSetFontFamily: function (role, value) {
          var key = (this.themeStudioFontFieldMap() || {})[role] || '--font-ui';
          var target = this.themeStudioEditableTheme();
          if (!target) return;
          if (!target.cssVars) target.cssVars = {};
          target.cssVars[key] = value;
          if (role === 'ui') {
            target.fontStack = value;
            if (!target.cssVars['--font-titlebar']) target.cssVars['--font-titlebar'] = value;
            if (!target.cssVars['--font-taskbar']) target.cssVars['--font-taskbar'] = value;
            if (!target.cssVars['--font-menu']) target.cssVars['--font-menu'] = value;
            if (!target.cssVars['--font-icon-label']) target.cssVars['--font-icon-label'] = value;
          }
          this.applyThemeStudioConfig(target, { silent: true, persist: false });
          this.themeStudioPersistCustomThemes();
        },
        themeStudioSetTab: function (tabKey) {
          this.initThemeStudioStore();
          this.themeStudioStore.activeTab = tabKey || 'themes';
        },
        themeStudioPreviewTab: function () {
          this.initThemeStudioStore();
          return (((this.themeStudioStore || {}).previewTab) || 'desktop');
        },
        themeStudioSetPreviewTab: function (tabKey) {
          this.initThemeStudioStore();
          this.themeStudioStore.previewTab = (tabKey === 'mobile') ? 'mobile' : 'desktop';
        },
        themeStudioRenameActiveTheme: function (nextName) {
          var name = nextName;
          var target;
          if (!name) name = window.prompt('Rename theme', ((this.themeStudioActiveTheme() || {}).name) || 'Theme');
          if (!name) return;
          target = this.themeStudioEditableTheme();
          if (!target) return;
          target.name = String(name).trim() || 'Custom Theme';
          this.applyThemeStudioConfig(target, { silent: true, persist: false });
          this.themeStudioPersistCustomThemes();
        },
        themeStudioSetDarkEnabled: function (enabled) {
          var target = this.themeStudioEditableTheme();
          if (!target) return;
          target.darkEnabled = !!enabled;
          this.applyThemeStudioConfig(target, { silent: true, persist: false });
          this.themeStudioPersistCustomThemes();
        },
        themeStudioToggleDarkEnabled: function () {
          this.themeStudioSetDarkEnabled(!((this.themeStudioActiveTheme() || {}).darkEnabled));
        },
        themeStudioUpdateField: function (path, value) {
          var target = this.themeStudioEditableTheme();
          var ref = target;
          var parts = String(path || '').split('.');
          var i;
          if (!target || !parts.length) return;
          for (i = 0; i < parts.length - 1; i += 1) {
            if (!ref[parts[i]] || typeof ref[parts[i]] !== 'object') ref[parts[i]] = {};
            ref = ref[parts[i]];
          }
          ref[parts[parts.length - 1]] = value;
          if (path === 'fontStack') target.cssVars['--font-ui'] = value;
          if (path === 'name') target.name = value;
          if (path === 'taskbarConfig.height') target.cssVars['--taskbar-height'] = (+value || 48) + 'px';
          if (path === 'startMenuConfig.width') target.cssVars['--start-menu-width'] = (+value || 360) + 'px';
          if (path === 'startMenuConfig.accentColor') target.cssVars['--start-menu-accent'] = value;
          if (path === 'loginScreenConfig.textColor') target.cssVars['--login-box-text'] = value;
          this.applyThemeStudioConfig(target, { silent: true, persist: false });
          this.themeStudioPersistCustomThemes();
        },
        themeStudioSetFontScale: function (value) {
          var next = Math.max(10, Math.min(18, +value || 12));
          var target = this.themeStudioEditableTheme();
          var titlebar;
          if (!target) return;
          if (!target.cssVars) target.cssVars = {};
          titlebar = Math.max(30, Math.round(next * 2.9));
          target.cssVars['--font-size-ui'] = next + 'px';
          target.cssVars['--font-size-titlebar'] = Math.max(next, next + 1) + 'px';
          target.cssVars['--font-size-taskbar'] = next + 'px';
          target.cssVars['--font-size-menu'] = next + 'px';
          target.cssVars['--font-size-icon-label'] = Math.max(10, next - 1) + 'px';
          target.cssVars['--titlebar-height'] = titlebar + 'px';
          this.applyThemeStudioConfig(target, { silent: true, persist: false });
          this.themeStudioPersistCustomThemes();
        },
        themeStudioFontScaleValue: function () {
          return parseInt(this.themeStudioTextValue('--font-size-ui', '12px'), 10) || 12;
        },
        themeStudioUploadField: function (path, event) {
          var self = this;
          var file = event && event.target && event.target.files && event.target.files[0];
          var reader;
          if (!file) return;
          if (file.type && file.type.indexOf('image/') !== 0) {
            this.showAlert('Theme Studio', 'Please choose an image file.');
            event.target.value = '';
            return;
          }
          reader = new FileReader();
          reader.onload = function () {
            self.themeStudioUpdateField(path, reader.result);
            if (path === 'wallpaperUrl') self.themeStudioUpdateField('wallpaperPreset', 'custom-upload');
            event.target.value = '';
          };
          reader.readAsDataURL(file);
        },
        themeStudioClearUploadedField: function (path) {
          this.themeStudioUpdateField(path, '');
          if (path === 'wallpaperUrl') this.themeStudioUpdateField('wallpaperPreset', 'aurora');
        },
        desktopSurfaceStyle: function () {
          var pos = this.taskbarPosition();
          var h = this.taskbarHeightValue() + 14;
          return {
            paddingTop: (pos === 'top' ? h : 16) + 'px',
            paddingRight: '16px',
            paddingBottom: (pos === 'bottom' ? h : 16) + 'px',
            paddingLeft: (pos === 'left' ? h : 16) + 'px',
            boxSizing: 'border-box'
          };
        },
        taskbarPosition: function () {
          var theme = this.themeStudioActiveTheme() || {};
          return (((theme.taskbarConfig || {}).position) || (((this.boot || {}).desktop || {}).taskbarPosition) || 'bottom');
        },
        taskbarHeightValue: function () {
          var theme = this.themeStudioActiveTheme() || {};
          var mobile = window.innerWidth <= 768;
          if (mobile && theme.mobileConfig && theme.mobileConfig.taskbarHeightMobile) return +theme.mobileConfig.taskbarHeightMobile;
          return +(((theme.taskbarConfig || {}).height) || parseInt((((theme.cssVars || {})['--taskbar-height']) || '48px'), 10) || ((((this.boot || {}).desktop || {}).windowing || {}).taskbarHeight) || 48);
        },
        taskbarButtonStyleType: function () {
          var theme = this.themeStudioActiveTheme() || {};
          return (((theme.taskbarConfig || {}).buttonStyle) || 'xp');
        },
        taskbarTransparencyValue: function () {
          var theme = this.themeStudioActiveTheme() || {};
          return Math.max(0, Math.min(1, +(((theme.taskbarConfig || {}).transparentAmount) || 0)));
        },
        taskbarEffectiveBackground: function (theme, alpha) {
          var t = theme || this.themeStudioActiveTheme() || {};
          var base = t.base || 'win7';
          var a = Math.max(0, Math.min(0.72, +alpha || 0));
          if (a <= 0.01) return (((t.cssVars || {})['--taskbar-bg']) || '');
          if (base === 'xp') return 'linear-gradient(180deg, rgba(255,255,255,' + (0.22 - a * 0.08).toFixed(3) + ') 0%, rgba(255,255,255,' + (0.06 - a * 0.03).toFixed(3) + ') 22%, rgba(15,74,169,' + (0.94 - a * 0.34).toFixed(3) + ') 23%, rgba(10,36,106,' + (0.98 - a * 0.40).toFixed(3) + ') 100%)';
          if (base === 'mac') return 'linear-gradient(180deg, rgba(246,247,249,' + (0.34 - a * 0.12).toFixed(3) + ') 0%, rgba(214,220,228,' + (0.26 - a * 0.10).toFixed(3) + ') 100%)';
          if (base === 'ubuntu') return 'linear-gradient(180deg, rgba(24,24,27,' + (0.95 - a * 0.36).toFixed(3) + ') 0%, rgba(11,11,12,' + (0.96 - a * 0.38).toFixed(3) + ') 100%)';
          return 'linear-gradient(180deg, rgba(255,255,255,' + (0.15 - a * 0.08).toFixed(3) + ') 0%, rgba(16,24,39,' + (0.34 - a * 0.12).toFixed(3) + ') 100%)';
        },
        taskbarShellStyle: function () {
          var pos = this.taskbarPosition();
          var h = this.taskbarHeightValue();
          var alpha = this.taskbarTransparencyValue();
          var style = {
            '--taskbar-transparency': String(alpha),
            '--taskbar-overlay': (this.themeStudioActiveTheme() || {}).darkEnabled ? ('rgba(255,255,255,' + (0.04 + alpha * 0.12).toFixed(3) + ')') : ('rgba(255,255,255,' + (0.02 + alpha * 0.24).toFixed(3) + ')'),
            '--taskbar-blur': (6 + Math.round(alpha * 14)) + 'px',
            '--taskbar-effective-bg': this.taskbarEffectiveBackground(this.themeStudioActiveTheme(), alpha)
          };
          if (pos === 'left') style.width = h + 'px'; else style.height = h + 'px';
          return style;
        },
        startMenuStyleType: function () {
          var theme = this.themeStudioActiveTheme() || {};
          return (((theme.startMenuConfig || {}).style) || 'classic');
        },
        startMenuPopupStyle: function () {
          var pos = this.taskbarPosition();
          var width = +((((this.themeStudioActiveTheme() || {}).startMenuConfig || {}).width) || 360);
          var h = this.taskbarHeightValue() + 12;
          var style = { width: Math.max(300, width) + 'px' };
          if (pos === 'top') { style.top = h + 'px'; style.bottom = 'auto'; style.left = '14px'; }
          else if (pos === 'left') { style.left = (h + 12) + 'px'; style.bottom = '14px'; style.top = 'auto'; }
          else { style.left = '14px'; style.bottom = h + 'px'; }
          return style;
        },
        startMenuGroups: function () {
          var theme = this.themeStudioActiveTheme() || {};
          var style = (((theme.startMenuConfig || {}).style) || 'classic');
          var nested = ((theme.startMenuConfig || {}).nested) !== false;
          var groups;
          if (style === 'panel') {
            return [
              { key: 'applications', title: 'Applications', subtitle: 'Launch your tools', open: true, items: [
                { key: 'terminal', title: 'Terminal', subtitle: 'Interactive shell', icon: '⌨' },
                { key: 'theme-studio', title: 'Appearance', subtitle: 'Customize the shell', icon: '🎨' },
                { key: 'transfers', title: 'Transfers', subtitle: 'Uploads and activity', icon: '⇅' }
              ]},
              { key: 'places', title: 'Places', subtitle: 'Folders and storage', open: true, items: [
                { key: 'my-computer', title: 'Home Folder', subtitle: 'Browse storage', icon: '🗂' },
                { key: 'documents', title: 'Documents', subtitle: 'Recent work', icon: '📁' },
                { key: 'control-panel', title: 'Settings', subtitle: 'System configuration', icon: '⚙' }
              ]},
              { key: 'system', title: 'System', subtitle: 'Health and security', open: true, items: [
                { key: 'security-center', title: 'Security', subtitle: 'Sessions and users', icon: '🛡' },
                { key: 'diagnostics', title: 'Diagnostics', subtitle: 'Transport and boot health', icon: '📈' },
                { key: 'debug-center', title: 'Developer Tools', subtitle: 'Inspect the shell', icon: '🧪' }
              ]}
            ];
          }
          groups = [
            { key: 'system', title: 'System Tools', subtitle: 'Core shell utilities', open: true, items: [
              { key: 'my-computer', title: 'My Computer', subtitle: 'Browse storage', icon: '🖥' },
              { key: 'documents', title: 'Documents', subtitle: 'Open recent files', icon: '📁' },
              { key: 'theme-studio', title: 'Theme Studio', subtitle: 'Customize the shell', icon: '🎨' }
            ]},
            { key: 'work', title: 'Workflows', subtitle: 'Everyday apps', open: nested, items: [
              { key: 'terminal', title: 'Terminal', subtitle: 'Interactive shell', icon: '⌨' },
              { key: 'transfers', title: 'Transfers', subtitle: 'Upload status', icon: '⇅' },
              { key: 'control-panel', title: 'Control Panel', subtitle: 'Settings and tools', icon: '⚙' }
            ]},
            { key: 'support', title: 'Support', subtitle: 'Diagnostics and monitoring', open: false, items: [
              { key: 'diagnostics', title: 'Diagnostics', subtitle: 'Transport and boot health', icon: '📈' },
              { key: 'security-center', title: 'Security Center', subtitle: 'Sessions and users', icon: '🛡' },
              { key: 'debug-center', title: 'Debug Center', subtitle: 'Developer tools', icon: '🧪' }
            ]}
          ];
          if (!nested) groups.forEach(function (group) { group.open = true; });
          return groups;
        },
        activeLoginScreenConfig: function () {
          return (((this.themeStudioActiveTheme() || {}).loginScreenConfig) || {});
        },
        activeLoginPrivacyNotice: function () {
          return (((this.activeLoginScreenConfig() || {}).privacyNotice) || '');
        },
        themeStudioSaveCustomTheme: function () {
          var target = this.themeStudioEditableTheme();
          if (!target) return;
          this.themeStudioPersistCustomThemes();
          this.applyThemeStudioConfig(target, { silent: false, persist: true });
        },
        themeStudioPreviewRootStyle: function () {
          var active = this.themeStudioActiveTheme();
          var alpha = this.taskbarTransparencyValue();
          var style = { '--desktop-wallpaper': this.themeStudioWallpaperCss(active), '--login-wallpaper': this.themeStudioLoginWallpaperCss(active), transform: 'scale(' + (((active || {}).previewScale) || 0.86) + ')' };
          var current = Object.assign({}, ((active || {}).cssVars) || {}, this.themeStudioDarkOverrides(active));
          Object.keys(current).forEach(function (key) { style[key] = current[key]; });
          style['--taskbar-height'] = this.taskbarHeightValue() + 'px';
          style['--start-menu-width'] = ((((active || {}).startMenuConfig || {}).width) || 360) + 'px';
          style['--taskbar-transparency'] = String(alpha);
          style['--taskbar-overlay'] = (active && active.darkEnabled) ? ('rgba(255,255,255,' + (0.04 + alpha * 0.12).toFixed(3) + ')') : ('rgba(255,255,255,' + (0.02 + alpha * 0.24).toFixed(3) + ')');
          style['--taskbar-blur'] = (6 + Math.round(alpha * 14)) + 'px';
          style['--taskbar-effective-bg'] = this.taskbarEffectiveBackground(active, alpha);
          return style;
        },
        themeStudioPreviewMobileRootStyle: function () {
          var active = this.themeStudioActiveTheme();
          var mobileHeight = (((active || {}).mobileConfig || {}).taskbarHeightMobile) || 46;
          var alpha = this.taskbarTransparencyValue();
          var current = Object.assign({}, ((active || {}).cssVars) || {}, this.themeStudioDarkOverrides(active));
          var style = { '--desktop-wallpaper': this.themeStudioWallpaperCss(active), '--login-wallpaper': this.themeStudioLoginWallpaperCss(active) };
          Object.keys(current).forEach(function (key) { style[key] = current[key]; });
          style['--taskbar-height'] = mobileHeight + 'px';
          style['--desktop-icon-size'] = ((((active || {}).mobileConfig || {}).iconSizeMobile) || 60) + 'px';
          style['--taskbar-transparency'] = String(alpha);
          style['--taskbar-overlay'] = (active && active.darkEnabled) ? ('rgba(255,255,255,' + (0.04 + alpha * 0.12).toFixed(3) + ')') : ('rgba(255,255,255,' + (0.02 + alpha * 0.24).toFixed(3) + ')');
          style['--taskbar-blur'] = (6 + Math.round(alpha * 14)) + 'px';
          style['--taskbar-effective-bg'] = this.taskbarEffectiveBackground(active, alpha);
          return style;
        },
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
    if (window.MIOOSShellUI && typeof window.MIOOSShellUI.register === 'function') {
      window.MIOOSShellUI.register(app);
    }
    app.mount('#mioosRoot');
  }

  window.MIOOSCore = { mount: mount };
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', mount, { once: true });
  } else {
    mount();
  }
})();
