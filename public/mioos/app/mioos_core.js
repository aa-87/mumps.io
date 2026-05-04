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
    var Table = (window.MIOOSTable || {}).methods || {};
    var Modules = (window.MIOOSModules || {}).methods || {};
    var Permissions = (window.MIOOSPermissions || {}).methods || {};
    var I18N = window.MIOOSI18N || {};

    var app = window.Vue.createApp({
      data: function () {
        return {
          boot: window.MIOOSState.defaultBoot(),
          view: window.MIOOSState.defaultView(),
          backendTables: {},
          desktopEntries: [],
          launcherEntries: [],
          windows: [],
          activeWindowId: '',
          menuOpen: false,
          menuFilter: '',
          startMenuUi: { selectedKey: '', lastOpenedAt: 0, expandedGroups: {}, expandedFolders: {}, folderChildren: {}, folderLoading: {}, popupPosition: null, popupDrag: null },
          socket: null,
          socketConnected: false,
          clockText: '',
          alertTitle: '',
          alertMessage: '',
          shellDialog: { open: false, kind: '', title: '', message: '', value: '', placeholder: '', confirmText: 'OK', cancelText: 'Cancel', danger: false, resolver: null },
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
            username: '',
            password: ''
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
          themeStudioStore: { initialized: false, themes: {}, order: [], customThemes: [], activeThemeId: 'glow', previewWindowState: {}, importBuffer: '', activeTab: 'themes' },
          transferCenter: { items: [], seq: 0, autoOpen: true },
          transferControllers: {},
          transportDiagnostics: { loading: false, refreshedAt: 0, error: '', report: {} },
          securityCenter: { loading: false, refreshedAt: 0, error: '', report: {}, trail: [], sessions: [], accounts: [] },
          debugCenter: { loading: false, refreshedAt: 0, error: '', snapshot: {}, events: [], seq: 0 },
          socketTelemetry: {},
          moduleCatalog: { loading: false, refreshedAt: 0, error: '' },
          systemSettings: { loading: false, saving: false, refreshedAt: 0, error: '', status: '', activeGroup: 'modules', payload: { groups: [], settings: [] }, draft: {} },
          _bootPrimed: false,
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
            .filter(function (win) { return win.state !== 'closed'; })
            .sort(function (a, b) { return (a.z || 0) - (b.z || 0); });
        },
        taskbarWindows: function () {
          return this.windows.filter(function (win) { return win.state !== 'closed'; });
        },
        filteredEntries: function () {
          return this.startMenuFlatItems ? this.startMenuFlatItems() : (this.launcherEntries || []);
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
            if (Array.isArray(entries)) {
              this.desktopEntries = window.MIOOSState.deepClone(entries);
              this.ensureDesktopLayout();
            }
          }
        }
      },
      beforeMount: function () {
        this.primeBootForFirstPaint();
      },
      mounted: function () {
        var self = this;
        this.primeBootForFirstPaint();
        /* First-paint theme and desktop layout are server-authored before the initial Vue render. */
        this.restorePersistedTransfers();
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
        window.addEventListener('pointermove', this._dragMove);
        window.addEventListener('pointerup', this._dragEnd);
        window.addEventListener('pointercancel', this._dragEnd);
        this._shortcutHandler = this.onGlobalShortcut.bind(this);
        window.addEventListener('keydown', this._shortcutHandler);
        this._persistTransfersOnUnload = this.persistTransferCenter.bind(this);
        this._networkOffline = function () {
          if (self.autoPauseTransfersByReason) self.autoPauseTransfersByReason('Paused (connection lost)', 'upload');
        };
        this._networkOnline = function () {
          if (self.persistTransferCenter) self.persistTransferCenter();
        };
        this._windowBlurDragEnd = this.handleGlobalMouseUp.bind(this);
        window.addEventListener('blur', this._windowBlurDragEnd);
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
        if (this._themeStudioApplyRaf) window.cancelAnimationFrame(this._themeStudioApplyRaf);
        if (this._themeStudioPersistTimer) { window.clearTimeout(this._themeStudioPersistTimer); this._themeStudioPersistTimer = null; }
        this.themeStudioPersistCustomThemes(true);
        this.persistTransferCenter();
        window.removeEventListener('mousemove', this._dragMove);
        window.removeEventListener('mouseup', this._dragEnd);
        window.removeEventListener('pointermove', this._dragMove);
        window.removeEventListener('pointerup', this._dragEnd);
        window.removeEventListener('pointercancel', this._dragEnd);
        window.removeEventListener('keydown', this._shortcutHandler);
        window.removeEventListener('blur', this._windowBlurDragEnd);
        window.removeEventListener('resize', this._viewportResize);
        window.removeEventListener('beforeunload', this._persistTransfersOnUnload);
        window.removeEventListener('offline', this._networkOffline);
        window.removeEventListener('online', this._networkOnline);
        this.windows.forEach(function (win) {
          if (win._term) win._term.dispose();
        });
      },
      methods: Object.assign({
        primeBootForFirstPaint: function () {
          if (this._bootPrimed) return;
          this.bootstrapFromDom();
          this.initThemeStudioStore();
          if (this.themeStudioBootProfile && this.themeStudioBootProfile() && this.hydrateShellTheme) this.hydrateShellTheme(this.themeStudioBootProfile());
          this.normalizeDesktopUiState();
          this.ensureDesktopLayout();
          this.normalizeDesktopUiState();
          this._bootPrimed = true;
        },
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
        desktopSystemShortcuts: function () {
          return []; /* ROI 2: desktop icons are VFS entries under /Home/Desktop, not client-side duplicates. */
        },
        desktopEntryIsSystemArtifact: function (entry) {
          var text = String(((entry || {}).title || '') + ' ' + ((entry || {}).label || '') + ' ' + ((entry || {}).name || '') + ' ' + ((entry || {}).path || '')).toLowerCase();
          return !!(text && /(^|[\s_./-])roi([\s_./-]|$)/.test(text));
        },
        desktopRenderEntries: function () {
          var out = [];
          var seen = {};
          function add(entry) {
            if (!entry || !entry.key || seen[entry.key]) return;
            seen[entry.key] = 1;
            out.push(entry);
          }
          (this.desktopEntries || []).filter(function (entry) { return entry && !this.desktopEntryIsSystemArtifact(entry); }, this).forEach(add);
          return out;
        },
        isProtectedThemeUrl: function (value) {
          var text = String(value || '');
          return !!(text && (text.indexOf('/api/mioos/theme-asset') >= 0 || text.indexOf('/api/mioos/fs/blob') >= 0));
        },
        sanitizeProtectedThemeProfile: function (profile) {
          var copy = this.themeStudioClone ? this.themeStudioClone(profile || {}) : JSON.parse(JSON.stringify(profile || {}));
          var self = this;
          var publicLoginConfig = copy && copy.publicLogin && copy.loginScreenConfig ? this.themeStudioClone(copy.loginScreenConfig) : null;
          function walk(obj) {
            if (!obj || typeof obj !== 'object') return obj;
            Object.keys(obj).forEach(function (key) {
              var value = obj[key];
              if (typeof value === 'string') {
                if (self.isProtectedThemeUrl(value)) obj[key] = '';
              } else if (value && typeof value === 'object') {
                walk(value);
              }
            });
            return obj;
          }
          walk(copy);
          if (publicLoginConfig) copy.loginScreenConfig = publicLoginConfig;
          return copy;
        },
        sanitizeBootThemeForAuth: function () {
          var boot = this.boot || {};
          var auth = boot.auth || {};
          var signedIn = !!((boot.user || {}).authenticated);
          var protectedPreAuth = !!(auth.required && !signedIn);
          if (!protectedPreAuth) return;
          boot.desktop = boot.desktop || {};
          if (this.isProtectedThemeUrl(boot.desktop.wallpaperUrl)) boot.desktop.wallpaperUrl = '';
          if (this.isProtectedThemeUrl(boot.wallpaperUrl)) boot.wallpaperUrl = '';
          if (boot.desktop.activeThemeProfile) boot.desktop.activeThemeProfile = this.sanitizeProtectedThemeProfile(boot.desktop.activeThemeProfile);
        },
        bootstrapFromDom: function () {
          var node = window.MIOOSState.getBootNode();
          if (!node) return;
          try {
            this.boot = window.MIOOSState.normalizeBoot(JSON.parse(node.textContent || '{}'));
            this.sanitizeBootThemeForAuth();
          } catch (err) {
            this.showAlert(this.t('alerts.bootError.title'), this.t('alerts.bootError.message'));
            this.boot = window.MIOOSState.defaultBoot();
            this.sanitizeBootThemeForAuth();
          }
          this.profile = this.boot.product.profile || 'dev';
          this.launcherEntries = window.MIOOSState.deepClone(this.boot.apps || []);
          this.desktopEntries = window.MIOOSState.deepClone(Array.isArray(this.boot.desktopEntries) ? this.boot.desktopEntries : []);
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

        systemSettingsRoutes: function () {
          return {
            load: ((((this.boot || {}).routes || {}).settingsLoad) || '/api/mioos/settings/load'),
            save: ((((this.boot || {}).routes || {}).settingsSave) || '/api/mioos/settings/save')
          };
        },
        systemSettingsToList: function (value) {
          if (!value) return [];
          if (Array.isArray(value)) return value.filter(function (item) { return item !== null && typeof item !== 'undefined'; });
          if (typeof value === 'object') {
            return Object.keys(value).filter(function (key) { return key !== 'byValue'; }).sort(function (a, b) { return (+a || 999999) - (+b || 999999) || String(a).localeCompare(String(b)); }).map(function (key) { return value[key]; }).filter(function (item) { return item !== null && typeof item !== 'undefined'; });
          }
          return [];
        },
        systemSettingsNormalizePayload: function (payload) {
          payload = payload || {};
          payload.groups = this.systemSettingsToList(payload.groups);
          payload.settings = this.systemSettingsToList(payload.settings);
          payload.settings.forEach(function (setting) {
            if (setting && setting.enum) setting.enum = this.systemSettingsToList(setting.enum).map(function (item) { return String(item); });
          }, this);
          return payload;
        },
        systemSettingsLoad: function () {
          var self = this;
          var route = this.systemSettingsRoutes().load;
          this.systemSettings.loading = true;
          this.systemSettings.error = '';
          return fetch(route, { method: 'POST', credentials: 'same-origin', headers: { 'Content-Type': 'application/json' }, body: '{}' })
            .then(function (response) {
              if (!response.ok) throw new Error('Settings load failed: HTTP ' + response.status);
              return response.json();
            })
            .then(function (payload) {
              payload = self.systemSettingsNormalizePayload(payload || {});
              self.systemSettings.payload = payload;
              self.systemSettings.draft = Object.assign({}, payload.values || {});
              if (!self.systemSettings.activeGroup && payload.groups[0]) self.systemSettings.activeGroup = payload.groups[0].key;
              if (!payload.groups.some(function (group) { return group.key === self.systemSettings.activeGroup; }) && payload.groups[0]) self.systemSettings.activeGroup = payload.groups[0].key;
              self.systemSettings.refreshedAt = Date.now();
              self.systemSettings.loading = false;
              return payload;
            })
            .catch(function (err) {
              self.systemSettings.loading = false;
              self.systemSettings.error = (err && err.message) || 'Settings load failed';
              throw err;
            });
        },
        systemSettingsSave: function () {
          var self = this;
          var route = this.systemSettingsRoutes().save;
          var payload = { values: Object.assign({}, (this.systemSettings || {}).draft || {}) };
          this.systemSettings.saving = true;
          this.systemSettings.error = '';
          this.systemSettings.status = '';
          return fetch(route, { method: 'POST', credentials: 'same-origin', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload) })
            .then(function (response) {
              if (!response.ok) throw new Error('Settings save failed: HTTP ' + response.status);
              return response.json();
            })
            .then(function (saved) {
              saved = self.systemSettingsNormalizePayload(saved || {});
              self.systemSettings.payload = saved;
              self.systemSettings.draft = Object.assign({}, saved.values || payload.values || {});
              self.systemSettings.saving = false;
              self.systemSettings.status = 'Saved. Server validation and clamping have been applied.';
              self.systemSettingsApplyLocal(saved.values || payload.values || {});
              return saved;
            })
            .catch(function (err) {
              self.systemSettings.saving = false;
              self.systemSettings.error = (err && err.message) || 'Settings save failed';
              throw err;
            });
        },
        systemSettingsApplyLocal: function (values) {
          values = values || {};
          var boot = this.boot || {};
          boot.desktop = boot.desktop || {};
          boot.desktop.moduleSystem = boot.desktop.moduleSystem || {};
          if (Object.prototype.hasOwnProperty.call(values, 'mioos.modules.enabled')) boot.desktop.moduleSystem.enabled = !!(+values['mioos.modules.enabled']);
          if (Object.prototype.hasOwnProperty.call(values, 'mioos.modules.appCatalogEnabled')) boot.desktop.moduleSystem.appCatalogEnabled = !!(+values['mioos.modules.appCatalogEnabled']);
          if (Object.prototype.hasOwnProperty.call(values, 'mioos.modules.dynamicWindows')) boot.desktop.moduleSystem.dynamicWindows = !!(+values['mioos.modules.dynamicWindows']);
          if (Object.prototype.hasOwnProperty.call(values, 'mioos.modules.launcher')) boot.desktop.moduleSystem.launcher = String(values['mioos.modules.launcher'] || 'desktop-icons-and-menu');
          if (Object.prototype.hasOwnProperty.call(values, 'mioos.desktop.density')) boot.desktop.density = String(values['mioos.desktop.density'] || 'comfortable');
          if (Object.prototype.hasOwnProperty.call(values, 'mioos.desktop.startMenuStyle')) boot.desktop.startMenuStyle = String(values['mioos.desktop.startMenuStyle'] || 'launcher-foundation');
          boot.vfs = boot.vfs || {};
          if (Object.prototype.hasOwnProperty.call(values, 'mioos.fs.transport')) boot.vfs.transport = String(values['mioos.fs.transport'] || 'http-and-websocket');
          if (Object.prototype.hasOwnProperty.call(values, 'mioos.upload.chunkBytes')) boot.vfs.uploadChunkBytes = +values['mioos.upload.chunkBytes'] || boot.vfs.uploadChunkBytes;
          if (Object.prototype.hasOwnProperty.call(values, 'mioos.upload.concurrency')) boot.vfs.uploadConcurrency = +values['mioos.upload.concurrency'] || boot.vfs.uploadConcurrency;
          if (Object.prototype.hasOwnProperty.call(values, 'mioos.upload.batchSize')) boot.vfs.uploadBatchSize = +values['mioos.upload.batchSize'] || boot.vfs.uploadBatchSize;
          if (Object.prototype.hasOwnProperty.call(values, 'mioos.upload.maxInflightChunks')) boot.vfs.uploadMaxInflightChunks = +values['mioos.upload.maxInflightChunks'] || boot.vfs.uploadMaxInflightChunks;
          boot.websocket = boot.websocket || {};
          if (Object.prototype.hasOwnProperty.call(values, 'mioos.websocket.maxSocketsPerSession')) boot.websocket.maxSocketsPerSession = +values['mioos.websocket.maxSocketsPerSession'] || boot.websocket.maxSocketsPerSession;
          if (Object.prototype.hasOwnProperty.call(values, 'mioos.websocket.coreSockets')) boot.websocket.coreSockets = +values['mioos.websocket.coreSockets'] || boot.websocket.coreSockets;
          if (Object.prototype.hasOwnProperty.call(values, 'mioos.websocket.fsSockets')) boot.websocket.fsSockets = +values['mioos.websocket.fsSockets'] || boot.websocket.fsSockets;
          if (Object.prototype.hasOwnProperty.call(values, 'mioos.websocket.heartbeatSeconds')) boot.websocket.heartbeatSeconds = +values['mioos.websocket.heartbeatSeconds'] || boot.websocket.heartbeatSeconds;
          if (Object.prototype.hasOwnProperty.call(values, 'mioos.websocket.diagnosticsEnabled')) boot.websocket.diagnosticsEnabled = !!(+values['mioos.websocket.diagnosticsEnabled']);
          if (boot.desktop.moduleSystem.enabled && boot.desktop.moduleSystem.appCatalogEnabled && this.uiModuleRefreshCatalog) this.uiModuleRefreshCatalog().catch(function () {});
        },
        systemSettingsResetDraft: function () {
          this.systemSettings.draft = Object.assign({}, ((this.systemSettings.payload || {}).values) || {});
          this.systemSettings.status = 'Draft reset to the last server-loaded values.';
        },
        systemSettingsGroupRows: function () {
          return this.systemSettingsToList(((this.systemSettings || {}).payload || {}).groups);
        },
        systemSettingsRowsForGroup: function (groupKey) {
          var rows = this.systemSettingsToList(((this.systemSettings || {}).payload || {}).settings);
          return rows.filter(function (row) { return String(row.group || '') === String(groupKey || ''); });
        },
        systemSettingsActiveGroup: function () {
          var rows = this.systemSettingsGroupRows();
          return rows.find(function (row) { return row.key === this.systemSettings.activeGroup; }, this) || rows[0] || { key: 'modules', title: 'Settings', description: '' };
        },
        systemSettingsInputId: function (setting) {
          return 'mioos-setting-' + String((setting || {}).key || '').replace(/[^a-z0-9_-]+/gi, '-');
        },
        systemSettingsDraftValue: function (setting) {
          var key = (setting || {}).key;
          if (!key) return '';
          if (Object.prototype.hasOwnProperty.call((this.systemSettings || {}).draft || {}, key)) return this.systemSettings.draft[key];
          return (setting || {}).value;
        },
        systemSettingsSetDraft: function (setting, value) {
          var key = (setting || {}).key;
          if (!key) return;
          var type = String((setting || {}).type || 'text');
          if (type === 'boolean') value = value ? 1 : 0;
          if (type === 'integer') value = Math.round(Number(value || 0));
          this.systemSettings.draft[key] = value;
          this.systemSettings.status = '';
        },
        systemSettingsSettingSummary: function (setting) {
          var bits = [];
          if ((setting || {}).type) bits.push('Type: ' + setting.type);
          if (setting && setting.min !== undefined && setting.max !== undefined) bits.push('Allowed range: ' + setting.min + '–' + setting.max);
          if (setting && setting.enum && setting.enum.length) bits.push('Allowed values: ' + setting.enum.join(', '));
          if ((setting || {}).applies) bits.push(String(setting.applies));
          return bits.join(' • ');
        },
        shellThemeQuickMap: function () {
          return {
            'xp-classic-blue': 'vintage',
            'win7-aero': 'glow',
            'mac-slate': 'curve',
            'ubuntu-amber': 'panel'
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
          var id = quickMap[String(themeKey || '')] || themeKey || (((this.themeStudioStore || {}).activeThemeId) || '') || 'glow';
          this.initThemeStudioStore();
          return this.themeStudioThemeById(id) || this.themeStudioThemeById('glow');
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

        transferQueueRows: function (limit) {
          var seen = {};
          var rows = (this.transferCenter.items || []).filter(function (item) {
            var key;
            if (!item) return false;
            if (['completed','failed','cancelled'].indexOf(item.status) >= 0) return false;
            key = item.id || [item.kind || '', item.name || '', item.totalBytes || 0, item.status || '', item.resume && item.resume.uploadId || ''].join('|');
            if (seen[key]) return false;
            seen[key] = 1;
            return true;
          });
          rows.sort(function (a, b) { return +((b && (b.updatedAt || b.startedAt || 0)) || 0) - +((a && (a.updatedAt || a.startedAt || 0)) || 0); });
          return rows.slice(0, Math.max(1, +(limit || 8)));
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
          return this.completedTransfers().filter(function (item) { return item.status === 'failed' || item.status === 'cancelled'; }).length;
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
          return Promise.all((this.activeTransfers() || []).map(function (item) {
            return self.canCancelTransfer(item) ? self.cancelTransfer(item).catch(function () { return null; }) : Promise.resolve();
          })).then(function () { self.persistTransferCenter(); });
        },
        transferTimestampLabel: function (item) {
          var t = +(item && (item.updatedAt || item.startedAt) || 0);
          if (!t) return '';
          try { return new Date(t).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }); } catch (err) { return ''; }
        },
        transferDirectionLabel: function (item) {
          if (!item) return '';
          var kind = String(item.kind || 'transfer');
          var target = item.targetPath || item.path || item.sourcePath || '';
          if (kind === 'upload') return 'Upload' + (target ? ' → ' + target : '');
          if (kind === 'download') return 'Download' + (target ? ' ← ' + target : '');
          if (kind === 'copy') return 'Copy' + (target ? ' → ' + target : '');
          if (kind === 'move') return 'Move' + (target ? ' → ' + target : '');
          return kind;
        },
        transferProgressLabel: function (item) {
          var pct = this.transferPercent(item);
          var done = +(item && item.processedBytes || 0);
          var total = +(item && item.totalBytes || 0);
          if (total > 0) return pct + '% · ' + this.formatBytesCompact(done) + ' of ' + this.formatBytesCompact(total);
          return pct + '%';
        },
        transferStatusCaption: function (item) {
          if (!item) return 'Queued';
          if (item.stage) return item.stage;
          var s = String(item.status || 'queued');
          return s.charAt(0).toUpperCase() + s.slice(1).replace(/-/g, ' ');
        },
        formatBytesCompact: function (bytes) {
          var size = +bytes || 0;
          var units = ['B','KB','MB','GB','TB'];
          var idx = 0;
          while (size >= 1024 && idx < units.length - 1) { size = size / 1024; idx++; }
          if (idx === 0) return Math.round(size) + ' ' + units[idx];
          return (size >= 10 ? size.toFixed(1) : size.toFixed(2)).replace(/\.0+$/, '') + ' ' + units[idx];
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
            self.boot.uiModules = window.MIOOSState.deepClone(((msg || {}).module) || {});
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
          if (this.transferCenter.items.length > 250) this.transferCenter.items = this.transferCenter.items.slice(0, 250);
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
        desktopNextOpenPosition: function () {
          var metrics = this.desktopGridMetrics();
          var viewportHeight = this.desktopViewportHeight();
          var occupied = {};
          Object.keys((this.desktopUi || {}).positions || {}).forEach(function (key) {
            var pos = ((this.desktopUi || {}).positions || {})[key] || {};
            var col = Math.max(0, Math.round(((+pos.left || 16) - 16) / metrics.width));
            var row = Math.max(0, Math.round(((+pos.top || 16) - 16) / metrics.height));
            occupied[col + ',' + row] = 1;
          }, this);
          var col = 0, row = 0, guard = 0;
          while (guard < 1000) {
            if (!occupied[col + ',' + row]) return { left: 16 + (col * metrics.width), top: 16 + (row * metrics.height) };
            row += 1;
            if ((16 + ((row + 1) * metrics.height)) > viewportHeight) { row = 0; col += 1; }
            guard += 1;
          }
          return { left: 16 + (col * metrics.width), top: 16 };
        },
        ensureDesktopLayout: function () {
          var self = this;
          if (!this.desktopUi.positions) this.desktopUi.positions = {};
          (this.desktopRenderEntries ? this.desktopRenderEntries() : (this.desktopEntries || [])).forEach(function (entry) {
            if (!entry || !entry.key) return;
            if (!self.desktopUi.positions[entry.key]) {
              var hasExplicitLeft = entry.iconLeft !== undefined && entry.iconLeft !== null && entry.iconLeft !== '';
              var hasExplicitTop = entry.iconTop !== undefined && entry.iconTop !== null && entry.iconTop !== '';
              var left = hasExplicitLeft ? +entry.iconLeft : NaN;
              var top = hasExplicitTop ? +entry.iconTop : NaN;
              var slot = null;
              if (!(hasExplicitLeft && hasExplicitTop && isFinite(left) && isFinite(top) && left >= 0 && top >= 0)) {
                slot = self.desktopNextOpenPosition();
                left = slot.left;
                top = slot.top;
              }
              self.desktopUi.positions[entry.key] = { left: left, top: top };
            }
          });
          Object.keys(this.desktopUi.positions).forEach(function (key) {
            var exists = (self.desktopRenderEntries ? self.desktopRenderEntries() : (self.desktopEntries || [])).some(function (entry) { return entry.key === key; });
            if (!exists) delete self.desktopUi.positions[key];
          });
          this.sortDesktopEntries(this.desktopUi.sortMode || 'manual', true);
        },
        desktopIconStyle: function (entry) {
          var pos = ((this.desktopUi || {}).positions || {})[entry.key] || { left: 16, top: 16 };
          var left = isFinite(+pos.left) ? +pos.left : 16;
          var top = isFinite(+pos.top) ? +pos.top : 16;
          return { '--x': (left + 'px'), '--y': (top + 'px'), transform: 'translate(var(--x), var(--y))' };
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
        persistDesktopLayout: function () {
          var payload = this.desktopLayoutPayload();
          if (this.socketRequest) {
            this.socketRequest((this.boot.routes || {}).commandEvent || 'desktop.command', { command: 'desktop.layout.save', iconSize: payload.iconSize, sortMode: payload.sortMode, positions: payload.positions }, { command: 'desktop.layout.save', dedupeKey: 'desktop.layout.save', timeoutMs: 3000 }).catch(function () {});
          }
        },
        refreshDesktopIcons: function () {
          this.closeDesktopContextMenu();
          this.refreshView();
          this.showAlert('Desktop', 'Desktop refreshed.');
        },
        rearrangeDesktopIcons: function () {
          this.closeDesktopContextMenu();
          var self = this;
          var metrics = this.desktopGridMetrics();
          var viewportHeight = this.desktopViewportHeight();
          var col = 0;
          var row = 0;
          (this.desktopRenderEntries ? this.desktopRenderEntries() : (this.desktopEntries || [])).forEach(function (entry) {
            self.desktopUi.positions[entry.key] = { left: 16 + (col * metrics.width), top: 16 + (row * metrics.height) };
            row += 1;
            if ((16 + ((row + 1) * metrics.height)) > viewportHeight) { row = 0; col += 1; }
          });
          this.desktopUi.sortMode = 'manual';
          this.persistDesktopLayout();
        },
        sortDesktopEntries: function (mode, silent) {
          this.closeDesktopContextMenu();
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
          this.closeDesktopContextMenu();
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
          return (this.desktopRenderEntries ? this.desktopRenderEntries() : (this.desktopEntries || [])).find(function (entry) { return entry.key === key; }) || null;
        },
        contextOpenSelected: function () {
          var entry = this.desktopContextEntry();
          this.closeDesktopContextMenu();
          if (entry) this.openDesktopEntry(entry);
        },
        contextControlPanel: function () { this.closeDesktopContextMenu(); this.openApp('control-panel'); },
        contextPersonalize: function () { this.closeDesktopContextMenu(); this.openApp('customize'); },
        contextDeleteIcon: function () { this.closeDesktopContextMenu(); this.desktopDeleteSelected(); },
        desktopFolderId: function () {
          return (((this.boot || {}).vfs || {}).desktopId) || (((this.view || {}).desktopFolder || {}).id) || 'Desktop';
        },
        desktopEntryIsVfs: function (entry) {
          return !!(entry && (entry.source === 'vfs' || entry.id || entry.parentId || entry.targetPath));
        },
        refreshDesktopVfsViews: function () {
          var self = this;
          var desktopId = this.desktopFolderId();
          return this.refreshView().then(function () {
            (self.windows || []).forEach(function (win) {
              var st = win && win.explorerState;
              if (st && st.folderId === desktopId && self.refreshExplorerWindow) self.refreshExplorerWindow(win.id).catch(function () {});
            });
          });
        },
        openExplorerFolder: function (folderId, title) {
          var win = (this.windows || []).find(function (item) { return item.appKey === 'home'; }) || (this.windows || []).find(function (item) { return item.appKey === 'explorer' || item.appKey === 'documents'; });
          if (!win) { this.openApp('home'); return; }
          if (!win.meta) win.meta = {};
          win.meta.folderId = folderId || this.desktopFolderId();
          if (title) win.title = title;
          this.ensureWindowFrame(win);
          if (win.state === 'closed' || win.state === 'minimized') win.state = 'normal';
          this.focusWindow(win.id);
          if (this.bootstrapExplorerWindow) {
            this.$nextTick(function () {
              this.bootstrapExplorerWindow(win.id, true);
              if (this.loadExplorerFolder) this.loadExplorerFolder(win.id, win.meta.folderId, { selectFirst: false }).catch(function () {});
            }.bind(this));
          }
        },
        openDesktopEntry: function (entry) {
          if (!entry) return;
          if (entry.source === 'shortcut') { this.openApp(entry.launchKey || entry.appKey || String(entry.key || '').replace(/^shortcut:/, '')); return; }
          if ((entry.kind || entry.type) === 'shortcut' || entry.targetAppKey) { this.openApp(entry.launchKey || entry.appKey || entry.targetAppKey); return; }
          if (!this.desktopEntryIsVfs(entry)) { this.openApp(entry.appKey || entry.launchKey || entry.key); return; }
          if ((entry.kind || entry.type) === 'folder') { this.openExplorerFolder(entry.id || entry.key, entry.title || entry.name || 'Folder'); return; }
          if (this.openFileViewerWindow) { this.openFileViewerWindow(entry); return; }
          this.openExplorerFolder(this.desktopFolderId(), 'Desktop');
        },
        desktopCreateFolder: function () {
          var self = this;
          this.closeDesktopContextMenu();
          return this.inputDialog('Desktop', this.t('explorer.promptNewFolder', 'New folder name'), this.t('explorer.defaultFolderName', 'New Folder')).then(function (name) {
            if (name === null) return null;
            name = String(name || '').trim();
            if (!name || !self.command) return null;
            return self.command('fs.mkdir', { parent: self.desktopFolderId(), name: name }).then(function () { return self.refreshDesktopVfsViews(); });
          }).catch(function (err) { self.showAlert('Desktop', (err && err.message) || 'fs_mkdir_failed'); });
        },
        desktopCreateTextFile: function () {
          var self = this;
          this.closeDesktopContextMenu();
          return this.inputDialog('Desktop', 'New text file name', 'New Text Document.txt').then(function (name) {
            if (name === null) return null;
            name = String(name || '').trim();
            if (!name || !self.command) return null;
            return self.command('fs.write', { parent: self.desktopFolderId(), name: name, content: '', mime: 'text/plain' }).then(function () { return self.refreshDesktopVfsViews(); });
          }).catch(function (err) { self.showAlert('Desktop', (err && err.message) || 'fs_write_failed'); });
        },
        desktopRenameSelected: function () {
          var self = this;
          var entry = this.desktopContextEntry();
          this.closeDesktopContextMenu();
          if (!entry || !this.desktopEntryIsVfs(entry) || !this.command) return Promise.resolve();
          return this.inputDialog('Desktop', this.t('explorer.promptRename', 'Rename item'), entry.name || entry.title || '').then(function (name) {
            if (name === null) return null;
            name = String(name || '').trim();
            if (!name || name === (entry.name || entry.title || '')) return null;
            return self.command('fs.rename', { id: entry.id || entry.key, name: name }).then(function () { return self.refreshDesktopVfsViews(); });
          }).catch(function (err) { self.showAlert('Desktop', (err && err.message) || 'fs_rename_failed'); });
        },
        desktopDeleteSelected: function () {
          var self = this;
          var entry = this.desktopContextEntry();
          this.closeDesktopContextMenu();
          if (!entry || !this.desktopEntryIsVfs(entry) || !this.command) return Promise.resolve();
          return this.confirmDialog('Desktop', this.t('explorer.confirmDelete', 'Delete the selected item?'), { danger: true, confirmText: 'Delete' }).then(function (confirmed) {
            if (!confirmed) return null;
            return self.command('fs.delete', { id: entry.id || entry.key }).then(function () { return self.refreshDesktopVfsViews(); });
          }).catch(function (err) { self.showAlert('Desktop', (err && err.message) || 'fs_delete_failed'); });
        },
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
            vintage: {
              id: 'vintage', name: 'Vintage', base: 'xp', locked: true, iconSet: 'system', fontStack: 'Tahoma, "Segoe UI", sans-serif', wallpaperPreset: 'meadow', wallpaperUrl: '', wallpaperFit: 'cover', previewScale: 0.86, classModifiers: ['vintage-shell'], animationSpeeds: { minimize: 180, progress: 220, open: 180, hover: 120, menu: 160, wallpaper: 280, taskbar: 160 }, extraCss: '',
              cssVars: {
                '--desktop-bg': '#3d7ad6', '--desktop-overlay': 'rgba(255,255,255,0.06)', '--window-bg': '#f5f9ff', '--window-border': '#2456a6', '--window-border-strong': '#13326a', '--titlebar-bg': 'linear-gradient(180deg, #0f5bd7 0%, #3f8df6 52%, #a9c7ff 100%)', '--titlebar-text': '#ffffff', '--titlebar-inactive': 'linear-gradient(180deg, #6c89b0 0%, #9bb2ce 100%)', '--accent': '#0b63f6', '--accent-soft': 'rgba(11,99,246,0.18)', '--taskbar-bg': 'linear-gradient(180deg, rgba(255,255,255,0.25) 0%, rgba(255,255,255,0.06) 22%, #0f4aa9 23%, #0a246a 100%)', '--taskbar-border': 'rgba(255,255,255,0.28)', '--taskbar-text': '#ffffff', '--menu-bg': 'rgba(248,251,255,0.96)', '--menu-border': '#7fa7e7', '--menu-text': '#10233f', '--menu-hover': 'linear-gradient(180deg, rgba(255,255,255,0.95) 0%, rgba(200,224,255,0.95) 100%)', '--menu-divider': 'rgba(36,86,166,0.18)', '--menu-shadow': '0 18px 40px rgba(8, 26, 63, 0.35)', '--icon-label-bg': 'rgba(15,32,68,0.36)', '--icon-label-text': '#f8fbff', '--icon-shadow': '0 1px 2px rgba(0,0,0,0.75)', '--shadow-window': '0 18px 40px rgba(8,24,56,0.30)', '--shadow-window-active': '0 24px 48px rgba(4,18,44,0.38)', '--font-ui': 'Tahoma, "Segoe UI", sans-serif', '--font-size-ui': '11px', '--window-radius': '10px', '--desktop-grid-cell': '88px', '--desktop-icon-size': '48px', '--titlebar-height': '32px', '--taskbar-height': '48px', '--button-radius': '7px', '--button-tint': 'linear-gradient(180deg, #ffffff 0%, #d8e8ff 100%)', '--button-tint-hover': 'linear-gradient(180deg, #ffffff 0%, #c8defd 100%)', '--glass-opacity': '0', '--control-min': '#f2d25a', '--control-max': '#7ecb61', '--control-close': '#e06d5c'
              }
            },
            glow: {
              id: 'glow', name: 'Glow', base: 'win7', locked: true, iconSet: 'system', fontStack: '"Segoe UI", Tahoma, sans-serif', wallpaperPreset: 'aurora', wallpaperUrl: '', wallpaperFit: 'cover', previewScale: 0.86, classModifiers: ['glass'], animationSpeeds: { minimize: 220, progress: 240, open: 210, hover: 130, menu: 170, wallpaper: 300, taskbar: 170 }, extraCss: '',
              cssVars: {
                '--desktop-bg': '#173a5d', '--desktop-overlay': 'rgba(255,255,255,0.08)', '--window-bg': 'rgba(248,251,255,0.78)', '--window-border': 'rgba(255,255,255,0.64)', '--window-border-strong': 'rgba(58,77,106,0.88)', '--titlebar-bg': 'linear-gradient(180deg, rgba(255,255,255,0.38) 0%, rgba(152,198,255,0.14) 100%)', '--titlebar-text': '#12304b', '--titlebar-inactive': 'linear-gradient(180deg, rgba(255,255,255,0.16) 0%, rgba(139,162,190,0.08) 100%)', '--accent': '#4ba3ff', '--accent-soft': 'rgba(75,163,255,0.18)', '--taskbar-bg': 'linear-gradient(180deg, rgba(255,255,255,0.15) 0%, rgba(16,24,39,0.34) 100%)', '--taskbar-border': 'rgba(255,255,255,0.22)', '--taskbar-text': '#f4f8ff', '--menu-bg': 'rgba(248,251,255,0.88)', '--menu-border': 'rgba(255,255,255,0.48)', '--menu-text': '#10243d', '--menu-hover': 'linear-gradient(180deg, rgba(255,255,255,0.78) 0%, rgba(214,231,255,0.85) 100%)', '--menu-divider': 'rgba(255,255,255,0.24)', '--menu-shadow': '0 24px 60px rgba(8, 18, 36, 0.40)', '--icon-label-bg': 'rgba(11,25,49,0.34)', '--icon-label-text': '#f8fbff', '--icon-shadow': '0 1px 2px rgba(0,0,0,0.78)', '--shadow-window': '0 18px 42px rgba(0,0,0,0.28)', '--shadow-window-active': '0 24px 58px rgba(0,0,0,0.36)', '--font-ui': '"Segoe UI", Tahoma, sans-serif', '--font-size-ui': '12px', '--window-radius': '14px', '--desktop-grid-cell': '92px', '--desktop-icon-size': '50px', '--titlebar-height': '36px', '--taskbar-height': '48px', '--button-radius': '8px', '--button-tint': 'linear-gradient(180deg, rgba(255,255,255,0.82) 0%, rgba(224,238,255,0.72) 100%)', '--button-tint-hover': 'linear-gradient(180deg, rgba(255,255,255,0.94) 0%, rgba(210,232,255,0.84) 100%)', '--glass-opacity': '0.76', '--control-min': '#f2d25a', '--control-max': '#7ecb61', '--control-close': '#e06d5c'
              }
            },
            curve: {
              id: 'curve', name: 'Curve', base: 'mac', locked: true, iconSet: 'system', fontStack: '-apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif', wallpaperPreset: 'graphite', wallpaperUrl: '', wallpaperFit: 'cover', previewScale: 0.84, classModifiers: ['vibrant'], animationSpeeds: { minimize: 210, progress: 200, open: 190, hover: 120, menu: 150, wallpaper: 260, taskbar: 150 }, extraCss: '',
              cssVars: {
                '--desktop-bg': '#5f6975', '--desktop-overlay': 'rgba(255,255,255,0.04)', '--window-bg': 'rgba(252,252,252,0.92)', '--window-border': '#cfd6df', '--window-border-strong': '#adb7c4', '--titlebar-bg': 'linear-gradient(180deg, #f4f5f7 0%, #d7dce2 100%)', '--titlebar-text': '#18202b', '--titlebar-inactive': 'linear-gradient(180deg, #edf1f4 0%, #cfd6dd 100%)', '--accent': '#0a84ff', '--accent-soft': 'rgba(10,132,255,0.16)', '--taskbar-bg': 'rgba(246,247,249,0.26)', '--taskbar-border': 'rgba(255,255,255,0.28)', '--taskbar-text': '#f7f9fc', '--menu-bg': 'rgba(255,255,255,0.82)', '--menu-border': 'rgba(214,221,228,0.82)', '--menu-text': '#1f2937', '--menu-hover': 'linear-gradient(180deg, rgba(255,255,255,0.98) 0%, rgba(238,242,247,0.92) 100%)', '--menu-divider': 'rgba(159,171,184,0.25)', '--menu-shadow': '0 22px 54px rgba(15, 23, 42, 0.30)', '--icon-label-bg': 'rgba(18,25,35,0.28)', '--icon-label-text': '#ffffff', '--icon-shadow': '0 1px 3px rgba(0,0,0,0.75)', '--shadow-window': '0 18px 40px rgba(0,0,0,0.18)', '--shadow-window-active': '0 22px 52px rgba(0,0,0,0.24)', '--font-ui': '-apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif', '--font-size-ui': '12px', '--window-radius': '16px', '--desktop-grid-cell': '90px', '--desktop-icon-size': '50px', '--titlebar-height': '34px', '--taskbar-height': '64px', '--button-radius': '999px', '--button-tint': 'linear-gradient(180deg, rgba(255,255,255,0.95) 0%, rgba(231,235,241,0.92) 100%)', '--button-tint-hover': 'linear-gradient(180deg, rgba(255,255,255,1) 0%, rgba(244,246,249,0.96) 100%)', '--glass-opacity': '0.68', '--control-min': '#f5c84c', '--control-max': '#63c554', '--control-close': '#ff5f57'
              }
            },
            panel: {
              id: 'panel', name: 'Panel', base: 'ubuntu', locked: true, iconSet: 'system', fontStack: 'Ubuntu, "Segoe UI", sans-serif', wallpaperPreset: 'ember', wallpaperUrl: '', wallpaperFit: 'cover', previewScale: 0.86, classModifiers: ['panel-shell'], animationSpeeds: { minimize: 190, progress: 210, open: 180, hover: 120, menu: 160, wallpaper: 260, taskbar: 150 }, extraCss: '',
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
          var base = this.themeStudioClone(presets[baseId] || presets['glow']);
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
          var presets, rawCustom, parsedCustom, rawApplied, parsedApplied, bootTheme, quickMap, hasBootProfile;
          if (store.initialized) return store;
          store.themes = {};
          store.order = [];
          store.customThemes = [];
          store.activeThemeId = 'glow';
          store.previewWindowState = this.themeStudioDefaultPreviewWindow();
          store.importBuffer = '';
          store.activeTab = 'global';
          hasBootProfile = false;
          if (!store.previewTab) store.previewTab = 'desktop';
          presets = this.themeStudioBaseThemeConfigs();
          Object.keys(presets).forEach(function (id) {
            store.themes[id] = this.themeStudioNormalizeConfig(presets[id]);
            store.order.push(id);
          }.bind(this));
          var bootProfile = this.themeStudioBootProfile ? this.themeStudioBootProfile() : null;
          if (bootProfile) {
            var bootTheme = this.themeStudioConfigFromServerProfile(bootProfile);
            if (bootTheme && bootTheme.id) {
              store.themes[bootTheme.id] = bootTheme;
              if (store.order.indexOf(bootTheme.id) < 0) store.order.push(bootTheme.id);
              if (!bootTheme.locked && store.customThemes.indexOf(bootTheme.id) < 0) store.customThemes.push(bootTheme.id);
              store.activeThemeId = bootTheme.id;
              hasBootProfile = true;
            }
          }
          rawCustom = ''; /* theme profiles are server-authored; do not hydrate from localStorage */
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
          rawApplied = ''; /* active theme is server-authored; no localStorage fallback */
          try { parsedApplied = rawApplied ? JSON.parse(rawApplied) : null; } catch (err4) { parsedApplied = null; }
          if (parsedApplied && !hasBootProfile) {
            parsedApplied = this.themeStudioNormalizeConfig(parsedApplied);
            if (!store.themes[parsedApplied.id]) {
              parsedApplied.locked = false;
              store.themes[parsedApplied.id] = parsedApplied;
              store.order.push(parsedApplied.id);
              store.customThemes.push(parsedApplied.id);
            }
            store.activeThemeId = parsedApplied.id;
          } else if (!hasBootProfile) {
            bootTheme = String(((((this.boot || {}).desktop || {}).themeKey) || ''));
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
          return this.themeStudioThemeById(store.activeThemeId) || this.themeStudioThemeById('glow');
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
        themeStudioPersistCustomThemes: function (immediate) {
          var store = this.initThemeStudioStore();
          var payload = (store.order || []).map(function (id) { return store.themes[id]; }).filter(function (item) { return item && !item.locked; });
          var commit = function () {
            store.customThemes = payload.map(function (item) { return item.id; });
            /* Custom themes are persisted through themeStudioSaveRemote, not localStorage. */
            this._themeStudioPersistTimer = null;
          }.bind(this);
          if (immediate === true) {
            if (this._themeStudioPersistTimer) { window.clearTimeout(this._themeStudioPersistTimer); this._themeStudioPersistTimer = null; }
            commit();
            return;
          }
          if (this._themeStudioPersistTimer) window.clearTimeout(this._themeStudioPersistTimer);
          this._themeStudioPersistTimer = window.setTimeout(commit, 180);
        },
        themeStudioApplyLive: function (config) {
          var self = this;
          var snapshot = this.themeStudioClone(config || this.themeStudioActiveTheme() || {});
          if (this._themeStudioApplyRaf) window.cancelAnimationFrame(this._themeStudioApplyRaf);
          this._themeStudioApplyRaf = window.requestAnimationFrame(function () {
            self._themeStudioApplyRaf = null;
            self.applyThemeStudioConfig(snapshot, { silent: true, persist: false });
          });
        },
        themeStudioWallpaperCss: function (theme) {
          var t = this.themeStudioNormalizeConfig(theme || this.themeStudioActiveTheme() || {});
          if (t.wallpaperPreset === 'custom-url' && t.wallpaperUrl && !this.isProtectedThemeUrl(t.wallpaperUrl)) return 'url(' + t.wallpaperUrl + ')';
          if (t.wallpaperPreset === 'meadow') return 'linear-gradient(180deg, rgba(255,255,255,0.14) 0%, rgba(255,255,255,0) 28%), linear-gradient(180deg, #8acb59 0%, #6fb14a 42%, #3e7b35 100%)';
          if (t.wallpaperPreset === 'aurora') return 'radial-gradient(circle at top, rgba(147,197,253,0.26), transparent 30%), linear-gradient(180deg, #16385c 0%, #23476d 36%, #3a6288 100%)';
          if (t.wallpaperPreset === 'graphite') return 'linear-gradient(180deg, #6c7a89 0%, #313b48 100%)';
          if (t.wallpaperPreset === 'ember') return 'linear-gradient(180deg, #6e2d35 0%, #2d2c54 100%)';
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
          rootNode.style.setProperty('--theme-open-speed', Math.max(100, +(theme.animationSpeeds || {}).open || 180) + 'ms');
          rootNode.style.setProperty('--theme-hover-speed', Math.max(80, +(theme.animationSpeeds || {}).hover || 120) + 'ms');
          rootNode.style.setProperty('--theme-menu-speed', Math.max(100, +(theme.animationSpeeds || {}).menu || 160) + 'ms');
          rootNode.style.setProperty('--theme-wallpaper-speed', Math.max(120, +(theme.animationSpeeds || {}).wallpaper || 280) + 'ms');
          rootNode.style.setProperty('--theme-taskbar-speed', Math.max(100, +(theme.animationSpeeds || {}).taskbar || 160) + 'ms');
          rootNode.dataset.shellTheme = theme.id || 'glow';
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
            /* Active theme persistence is server-based only. */
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
          var theme = this.themeStudioClone(this.themeStudioActiveTheme() || this.themeStudioThemeById('glow'));
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
          var preset = this.themeStudioBaseThemeConfigs()[baseName || 'glow'];
          var previousName;
          if (!target || !preset) return;
          previousName = target.name;
          preset = this.themeStudioNormalizeConfig(preset);
          Object.assign(target, this.themeStudioClone(preset), { id: target.id, name: previousName, locked: false, sourceId: preset.id });
          this.themeStudioApplyLive(target);
          if (target.variants) target.variants[target.darkEnabled ? 'dark' : 'light'] = this.themeStudioBuildVariantSnapshot(target, !!target.darkEnabled);
          this.themeStudioPersistCustomThemes();
        },
        themeStudioResetToBase: function () {
          var active = this.themeStudioActiveTheme();
          var sourceId;
          if (!active) return;
          sourceId = active.sourceId || (active.base === 'xp' ? 'vintage' : (active.base === 'mac' ? 'curve' : (active.base === 'ubuntu' ? 'panel' : 'glow')));
          if (active.locked) {
            this.themeStudioActivate(active.id, { persist: false, silent: true });
            return;
          }
          Object.assign(active, this.themeStudioClone(this.themeStudioBaseThemeConfigs()[sourceId] || this.themeStudioBaseThemeConfigs()['glow']), { id: active.id, name: active.name, locked: false, sourceId: sourceId });
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
          fallback = this.themeStudioThemeById('glow') || this.themeStudioThemeList()[0];
          store.activeThemeId = fallback ? fallback.id : 'glow';
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
          this.themeStudioApplyLive(target);
          if (target.variants) target.variants[target.darkEnabled ? 'dark' : 'light'] = this.themeStudioBuildVariantSnapshot(target, !!target.darkEnabled);
          this.themeStudioPersistCustomThemes();
        },
        themeStudioUpdateVar: function (key, value) {
          var target = this.themeStudioEditableTheme();
          if (!target) return;
          if (!target.cssVars) target.cssVars = {};
          target.cssVars[key] = value;
          if (key === '--font-ui') target.fontStack = value;
          this.themeStudioApplyLive(target);
          if (target.variants) target.variants[target.darkEnabled ? 'dark' : 'light'] = this.themeStudioBuildVariantSnapshot(target, !!target.darkEnabled);
          this.themeStudioPersistCustomThemes();
        },
        themeStudioSetClassModifiers: function (value) {
          var target = this.themeStudioEditableTheme();
          if (!target) return;
          target.classModifiers = String(value || '').trim() ? String(value).trim().split(/\s+/) : [];
          this.themeStudioApplyLive(target);
          if (target.variants) target.variants[target.darkEnabled ? 'dark' : 'light'] = this.themeStudioBuildVariantSnapshot(target, !!target.darkEnabled);
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
          var exported;
          if (!target) return;
          exported = this.themeStudioBuildExport(target);
          store.importBuffer = JSON.stringify(exported, null, 2);
          this.showAlert('Theme Studio', 'Theme JSON refreshed with light and dark variants.');
        },
        themeStudioBuildExport: function (theme) {
          var target = this.themeStudioNormalizeConfig(theme || this.themeStudioActiveTheme() || {});
          var common = {
            id: target.id,
            name: target.name,
            sourceId: target.sourceId || target.id,
            base: target.base,
            baseTheme: this.themeStudioExportBaseId(target),
            defaultVariant: target.darkEnabled ? 'dark' : 'light',
            iconSet: target.iconSet || 'system',
            fontStack: target.fontStack || (((target.cssVars || {})['--font-ui']) || '"Segoe UI", sans-serif'),
            wallpaperPreset: target.wallpaperPreset || 'aurora',
            wallpaperFit: target.wallpaperFit || 'cover',
            previewScale: target.previewScale || 0.72,
            classModifiers: this.themeStudioClone(target.classModifiers || []),
            extraCss: target.extraCss || ''
          };
          return {
            schema: 'mioos-theme-v4',
            exportedAt: new Date().toISOString(),
            theme: common,
            variants: {
              light: this.themeStudioBuildVariantExport(target, false),
              dark: this.themeStudioBuildVariantExport(target, true)
            }
          };
        },
        themeStudioBuildVariantSnapshot: function (theme, darkEnabled) {
          var target = this.themeStudioNormalizeConfig(theme || {});
          var live = this.themeStudioClone(target);
          var stored = ((target.variants || {})[darkEnabled ? 'dark' : 'light']) || {};
          if (!!target.darkEnabled === !!darkEnabled) {
            return {
              cssVars: this.themeStudioClone(live.cssVars || {}),
              animationSpeeds: this.themeStudioClone(live.animationSpeeds || {}),
              taskbarConfig: this.themeStudioClone(live.taskbarConfig || {}),
              startMenuConfig: this.themeStudioClone(live.startMenuConfig || {}),
              loginScreenConfig: this.themeStudioClone(live.loginScreenConfig || {}),
              mobileConfig: this.themeStudioClone(live.mobileConfig || {})
            };
          }
          return {
            cssVars: this.themeStudioClone(stored.cssVars || live.cssVars || {}),
            animationSpeeds: this.themeStudioClone(stored.animationSpeeds || live.animationSpeeds || {}),
            taskbarConfig: this.themeStudioClone(stored.taskbarConfig || live.taskbarConfig || {}),
            startMenuConfig: this.themeStudioClone(stored.startMenuConfig || live.startMenuConfig || {}),
            loginScreenConfig: this.themeStudioClone(stored.loginScreenConfig || live.loginScreenConfig || {}),
            mobileConfig: this.themeStudioClone(stored.mobileConfig || live.mobileConfig || {})
          };
        },
        themeStudioBuildVariantExport: function (theme, darkEnabled) {
          var target = this.themeStudioNormalizeConfig(theme || {});
          var snapshot = this.themeStudioBuildVariantSnapshot(target, !!darkEnabled);
          return {
            darkEnabled: !!darkEnabled,
            cssVars: this.themeStudioClone(snapshot.cssVars || {}),
            animationSpeeds: this.themeStudioClone(snapshot.animationSpeeds || {}),
            taskbarConfig: this.themeStudioClone(snapshot.taskbarConfig || {}),
            startMenuConfig: this.themeStudioClone(snapshot.startMenuConfig || {}),
            loginScreenConfig: this.themeStudioClone(snapshot.loginScreenConfig || {}),
            mobileConfig: this.themeStudioClone(snapshot.mobileConfig || {})
          };
        },
        themeStudioExportBaseId: function (theme) {
          var id = String((theme && (theme.sourceId || theme.id)) || 'glow');
          var map = { 'windows-xp': 'vintage', 'windows-7': 'glow', 'mac-os': 'curve', 'ubuntu': 'panel' };
          return map[id] || id;
        },
        themeStudioImportTheme: function () {
          var store = this.initThemeStudioStore();
          var parsed, next, source, variants, selected;
          if (!store.importBuffer) return;
          try { parsed = JSON.parse(store.importBuffer); } catch (err) { this.showAlert('Theme Studio', 'Import buffer is not valid JSON.'); return; }
          if (parsed && parsed.theme && parsed.variants) {
            source = this.themeStudioClone(parsed.theme);
            variants = parsed.variants || {};
            if (typeof source.darkEnabled === 'undefined') source.darkEnabled = String(source.defaultVariant || 'light') === 'dark';
            if (!source.sourceId && source.baseTheme) source.sourceId = source.baseTheme;
            selected = source.darkEnabled ? (variants.dark || {}) : (variants.light || {});
            next = Object.assign({}, source, selected || {});
            next.variants = { light: this.themeStudioClone(variants.light || {}), dark: this.themeStudioClone(variants.dark || {}) };
          } else {
            next = parsed;
          }
          parsed = this.themeStudioNormalizeConfig(next);
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
        themeStudioTitlebarColorValue: function (key, fallback) {
          var value = this.themeStudioColorValue(key, fallback || '#000000');
          if (/^#[0-9a-f]{3}([0-9a-f]{3})?$/i.test(String(value || ''))) return value;
          return fallback || '#000000';
        },
        themeStudioSetTitlebarGradient: function (mode, stop, value) {
          var target = this.themeStudioEditableTheme();
          if (!target) return;
          if (!target.cssVars) target.cssVars = {};
          var active = mode === 'inactive' ? false : true;
          var startKey = active ? '--titlebar-active-start' : '--titlebar-inactive-start';
          var endKey = active ? '--titlebar-active-end' : '--titlebar-inactive-end';
          var bgKey = active ? '--titlebar-bg' : '--titlebar-inactive';
          target.cssVars[stop === 'end' ? endKey : startKey] = value || (stop === 'end' ? '#0f172a' : '#1e3a8a');
          var start = target.cssVars[startKey] || (active ? '#1e3a8a' : '#334155');
          var end = target.cssVars[endKey] || (active ? '#0f172a' : '#111827');
          target.cssVars[bgKey] = 'linear-gradient(180deg, ' + start + ' 0%, ' + end + ' 100%)';
          this.themeStudioApplyLive(target);
          if (target.variants) target.variants[target.darkEnabled ? 'dark' : 'light'] = this.themeStudioBuildVariantSnapshot(target, !!target.darkEnabled);
          this.themeStudioPersistCustomThemes();
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
          var baseId = incoming.sourceId || incoming.id || 'glow';
          var base = this.themeStudioClone(presets[baseId] || presets['glow']);
          var out = Object.assign({}, base, incoming);
          out.cssVars = Object.assign({}, base.cssVars || {}, incoming.cssVars || {});
          out.animationSpeeds = Object.assign({}, base.animationSpeeds || {}, incoming.animationSpeeds || {});
          out.taskbarConfig = Object.assign({ position: 'bottom', height: parseInt((base.cssVars || {})['--taskbar-height'] || '48', 10) || 48, transparentAmount: 0, buttonStyle: 'xp' }, base.taskbarConfig || {}, incoming.taskbarConfig || {});
          out.startMenuConfig = Object.assign({ style: 'classic', width: 360, accentColor: (out.cssVars || {})['--accent'] || '#0b63f6', nested: true, variants: ['classic', 'popup'] }, base.startMenuConfig || {}, incoming.startMenuConfig || {});
          out.loginScreenConfig = Object.assign({ wallpaperUrl: '', privacyNotice: '', warningTitle: '', loginBoxStyle: 'xp-transparent', avatarSize: 72, textColor: (out.cssVars || {})['--taskbar-text'] || '#ffffff' }, base.loginScreenConfig || {}, incoming.loginScreenConfig || {});
          out.mobileConfig = Object.assign({ taskbarHeightMobile: 46, iconSizeMobile: 60, dockCompact: true }, base.mobileConfig || {}, incoming.mobileConfig || {});
          out.colorSchemes = (incoming.colorSchemes && incoming.colorSchemes.length) ? incoming.colorSchemes.slice() : ((base.colorSchemes && base.colorSchemes.length) ? base.colorSchemes.slice() : []);
          out.darkEnabled = !!incoming.darkEnabled;
          if (!out.id) out.id = 'custom-' + Date.now();
          if (!out.name) out.name = base.name || 'Custom Theme';
          if (!out.sourceId) out.sourceId = base.id || 'glow';
          if (!out.wallpaperPreset) out.wallpaperPreset = base.wallpaperPreset || 'aurora';
          out.loginScreenConfig = Object.assign({ avatarUrl: '', warningImageUrl: '' }, out.loginScreenConfig || {});
          out.variants = Object.assign({ light: {}, dark: {} }, incoming.variants || {});
          if (out.wallpaperUrl && out.wallpaperPreset !== 'custom-upload') out.wallpaperPreset = 'custom-upload';
          return out;
        },
        initThemeStudioStore: function () {
          var store = this.themeStudioStore || {};
          var presets, rawCustom, parsedCustom, rawApplied, parsedApplied, bootProfile, bootTheme, hasBootProfile;
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

          bootProfile = this.themeStudioBootProfile ? this.themeStudioBootProfile() : null;
          hasBootProfile = !!(bootProfile && Object.keys(bootProfile || {}).length);
          if (hasBootProfile) {
            bootTheme = this.themeStudioConfigFromServerProfile(bootProfile);
            if (bootTheme && bootTheme.id) {
              bootTheme.locked = false;
              store.themes[bootTheme.id] = bootTheme;
              if (store.order.indexOf(bootTheme.id) < 0) store.order.push(bootTheme.id);
              if (store.customThemes.indexOf(bootTheme.id) < 0) store.customThemes.push(bootTheme.id);
              store.activeThemeId = bootTheme.id;
            }
          }

          rawCustom = ''; /* theme profiles are server-authored; do not hydrate from localStorage */
          if (rawCustom) {
            try { parsedCustom = JSON.parse(rawCustom); } catch (err2) { parsedCustom = []; }
            if (Array.isArray(parsedCustom)) {
              parsedCustom.forEach(function (entry) {
                var cfg = this.themeStudioNormalizeConfig(entry || {});
                cfg.locked = false;
                if (!cfg.id) return;
                if (!store.themes[cfg.id]) {
                  store.order.push(cfg.id);
                  store.customThemes.push(cfg.id);
                } else if (store.customThemes.indexOf(cfg.id) < 0 && !cfg.locked) {
                  store.customThemes.push(cfg.id);
                }
                /* Server boot profile is the source of truth for the active theme; local custom themes remain available but cannot override it. */
                if (!(hasBootProfile && cfg.id === store.activeThemeId)) store.themes[cfg.id] = cfg;
              }.bind(this));
            }
          }

          if (!hasBootProfile) {
            rawApplied = ''; /* active theme is server-authored; no localStorage fallback */
            if (rawApplied) {
              try { parsedApplied = this.themeStudioNormalizeConfig(JSON.parse(rawApplied)); } catch (err4) { parsedApplied = null; }
            }
            if (parsedApplied) {
              store.themes[parsedApplied.id] = parsedApplied;
              if (store.order.indexOf(parsedApplied.id) < 0) store.order.push(parsedApplied.id);
              if (!parsedApplied.locked && store.customThemes.indexOf(parsedApplied.id) < 0) store.customThemes.push(parsedApplied.id);
              store.activeThemeId = parsedApplied.id;
            } else {
              /* Initial boot is Glow unless a server-rendered profile or explicit user-local applied theme exists. */
              store.activeThemeId = 'glow';
            }
          }
          if (!store.activeThemeId) store.activeThemeId = 'glow';
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
          if (t.wallpaperUrl && !(this.requiresSignin && this.isProtectedThemeUrl(t.wallpaperUrl))) return 'url(' + t.wallpaperUrl + ')';
          if (t.wallpaperPreset === 'meadow') return 'linear-gradient(180deg, rgba(255,255,255,0.14) 0%, rgba(255,255,255,0) 28%), linear-gradient(180deg, #8acb59 0%, #6fb14a 42%, #3e7b35 100%)';
          if (t.wallpaperPreset === 'aurora') return 'radial-gradient(circle at top, rgba(147,197,253,0.26), transparent 30%), linear-gradient(180deg, #16385c 0%, #23476d 36%, #3a6288 100%)';
          if (t.wallpaperPreset === 'graphite') return 'linear-gradient(180deg, #6c7a89 0%, #313b48 100%)';
          if (t.wallpaperPreset === 'ember') return 'linear-gradient(180deg, #6e2d35 0%, #2d2c54 100%)';
          return 'linear-gradient(180deg, #3d7ad6 0%, #2656a5 100%)';
        },
        themeStudioLoginWallpaperCss: function (theme) {
          var t = this.themeStudioNormalizeConfig(theme || this.themeStudioActiveTheme() || {});
          var cfg = t.loginScreenConfig || {};
          var publicLogin = !!(t.publicLogin || cfg.publicLogin);
          if (cfg.wallpaperUrl && !(this.requiresSignin && this.isProtectedThemeUrl(cfg.wallpaperUrl) && !publicLogin)) return 'url(' + cfg.wallpaperUrl + ')';
          return this.themeStudioWallpaperCss(t);
        },
        themeStudioManagedVarKeys: function () {
          return [
            '--desktop-bg','--desktop-overlay','--window-bg','--window-border','--window-border-strong','--titlebar-bg','--titlebar-text','--titlebar-inactive','--titlebar-active-start','--titlebar-active-end','--titlebar-inactive-start','--titlebar-inactive-end','--accent','--accent-soft','--taskbar-bg','--taskbar-border','--taskbar-text','--menu-bg','--menu-border','--menu-text','--menu-hover','--menu-divider','--menu-shadow','--icon-label-bg','--icon-label-text','--icon-shadow','--shadow-window','--shadow-window-active','--font-ui','--font-titlebar','--font-taskbar','--font-menu','--font-icon-label','--font-size-ui','--font-size-titlebar','--font-size-taskbar','--font-size-menu','--font-size-icon-label','--window-radius','--taskbar-height','--taskbar-transparency','--taskbar-overlay','--taskbar-blur','--taskbar-effective-bg','--theme-surface','--theme-surface-strong','--theme-panel-bg','--theme-panel-border','--theme-field-bg','--theme-field-text','--theme-muted-text','--theme-tab-bg','--theme-tab-active-bg','--theme-tab-border','--theme-preview-card-bg','--theme-preview-card-border','--titlebar-height','--desktop-grid-cell','--desktop-icon-size','--button-radius','--button-tint','--button-tint-hover','--button-text','--glass-opacity','--control-min','--control-max','--control-close','--start-menu-width','--start-menu-accent','--taskbar-position','--desktop-icon-size-mobile','--taskbar-height-mobile','--desktop-wallpaper','--login-wallpaper','--theme-minimize-speed','--theme-progress-speed','--theme-open-speed','--theme-hover-speed','--theme-menu-speed','--theme-wallpaper-speed','--theme-taskbar-speed','--login-box-bg','--login-box-border','--login-box-shadow','--login-box-text','--login-avatar-size'
          ];
        },
        themeStudioLightSurfaceVars: function (theme) {
          var base = ((theme || {}).base) || 'win7';
          if (base === 'xp') return {
            '--theme-surface': 'rgba(244,248,255,0.78)',
            '--theme-surface-strong': 'rgba(248,251,255,0.96)',
            '--theme-panel-bg': 'linear-gradient(180deg, rgba(255,255,255,0.90), rgba(236,243,255,0.84))',
            '--theme-panel-border': 'rgba(37,72,126,0.16)',
            '--theme-field-bg': 'rgba(255,255,255,0.98)',
            '--theme-field-text': '#10233f',
            '--theme-muted-text': '#4d6183',
            '--theme-tab-bg': 'linear-gradient(180deg, rgba(255,255,255,0.78), rgba(226,236,252,0.66))',
            '--theme-tab-active-bg': 'linear-gradient(180deg, rgba(255,255,255,1), rgba(214,228,248,0.96))',
            '--theme-tab-border': 'rgba(37,72,126,0.16)',
            '--theme-preview-card-bg': 'rgba(252,254,255,0.68)',
            '--theme-preview-card-border': 'rgba(37,72,126,0.14)',
            '--button-text': '#111827'
          };
          if (base === 'mac') return {
            '--theme-surface': 'rgba(246,247,250,0.78)',
            '--theme-surface-strong': 'rgba(250,251,253,0.94)',
            '--theme-panel-bg': 'linear-gradient(180deg, rgba(255,255,255,0.88), rgba(241,244,248,0.82))',
            '--theme-panel-border': 'rgba(151,167,184,0.18)',
            '--theme-field-bg': 'rgba(255,255,255,0.96)',
            '--theme-field-text': '#17212c',
            '--theme-muted-text': '#5d6b7e',
            '--theme-tab-bg': 'linear-gradient(180deg, rgba(255,255,255,0.80), rgba(234,239,245,0.74))',
            '--theme-tab-active-bg': 'linear-gradient(180deg, rgba(255,255,255,1), rgba(242,244,247,0.98))',
            '--theme-tab-border': 'rgba(151,167,184,0.18)',
            '--theme-preview-card-bg': 'rgba(252,252,253,0.72)',
            '--theme-preview-card-border': 'rgba(151,167,184,0.16)',
            '--button-text': '#111827'
          };
          if (base === 'ubuntu') return {
            '--theme-surface': 'rgba(249,244,240,0.76)',
            '--theme-surface-strong': 'rgba(254,250,246,0.94)',
            '--theme-panel-bg': 'linear-gradient(180deg, rgba(255,247,242,0.90), rgba(247,236,229,0.84))',
            '--theme-panel-border': 'rgba(118,78,56,0.14)',
            '--theme-field-bg': 'rgba(255,252,248,0.98)',
            '--theme-field-text': '#2d1f1a',
            '--theme-muted-text': '#77554a',
            '--theme-tab-bg': 'linear-gradient(180deg, rgba(255,249,245,0.82), rgba(245,233,225,0.74))',
            '--theme-tab-active-bg': 'linear-gradient(180deg, rgba(255,252,249,1), rgba(249,238,229,0.98))',
            '--theme-tab-border': 'rgba(118,78,56,0.14)',
            '--theme-preview-card-bg': 'rgba(255,250,247,0.70)',
            '--theme-preview-card-border': 'rgba(118,78,56,0.12)',
            '--button-text': '#111827'
          };
          return {
            '--theme-surface': 'rgba(244,248,255,0.76)',
            '--theme-surface-strong': 'rgba(248,251,255,0.94)',
            '--theme-panel-bg': 'linear-gradient(180deg, rgba(255,255,255,0.88), rgba(236,243,255,0.82))',
            '--theme-panel-border': 'rgba(66,88,122,0.16)',
            '--theme-field-bg': 'rgba(255,255,255,0.97)',
            '--theme-field-text': '#10243d',
            '--theme-muted-text': '#54657c',
            '--theme-tab-bg': 'linear-gradient(180deg, rgba(255,255,255,0.78), rgba(226,236,252,0.68))',
            '--theme-tab-active-bg': 'linear-gradient(180deg, rgba(255,255,255,1), rgba(216,229,248,0.96))',
            '--theme-tab-border': 'rgba(66,88,122,0.14)',
            '--theme-preview-card-bg': 'rgba(252,254,255,0.66)',
            '--theme-preview-card-border': 'rgba(66,88,122,0.12)',
            '--button-text': '#111827'
          };
        },
        themeStudioResolvedVars: function (theme) {
          var current = Object.assign({}, this.themeStudioLightSurfaceVars(theme), (((theme || {}).cssVars) || {}));
          var darkVars = this.themeStudioDarkOverrides(theme);
          if (theme && !theme.darkEnabled && ((theme.base || '') === 'ubuntu')) {
            current['--titlebar-text'] = '#20161c';
            current['--taskbar-text'] = '#20161c';
            current['--menu-text'] = '#241d19';
            current['--button-text'] = '#111827';
            current['--button-tint'] = 'linear-gradient(180deg, rgba(255,251,247,0.92) 0%, rgba(241,226,216,0.88) 100%)';
            current['--button-tint-hover'] = 'linear-gradient(180deg, rgba(255,255,255,0.96) 0%, rgba(244,230,220,0.92) 100%)';
          }
          Object.keys(darkVars).forEach(function (key) { current[key] = darkVars[key]; });
          return current;
        },
        themeStudioDarkOverrides: function (theme) {
          if (!theme || !theme.darkEnabled) return {};
          var accent = ((((theme || {}).cssVars) || {})['--accent']) || '#5aa2ff';
          return {
            '--desktop-overlay': 'rgba(255,255,255,0.02)',
            '--desktop-bg': '#0b1220',
            '--window-bg': '#101827',
            '--window-border': '#334155',
            '--window-border-strong': '#020617',
            '--titlebar-text': '#f8fafc',
            '--titlebar-active-start': '#1e3a8a',
            '--titlebar-active-end': '#0f172a',
            '--titlebar-inactive-start': '#334155',
            '--titlebar-inactive-end': '#111827',
            '--titlebar-bg': 'linear-gradient(180deg, #1e3a8a 0%, #0f172a 100%)',
            '--titlebar-inactive': 'linear-gradient(180deg, #334155 0%, #111827 100%)',
            '--taskbar-bg': 'linear-gradient(180deg, #111827 0%, #020617 100%)',
            '--taskbar-text': '#f3f8ff',
            '--taskbar-border': 'rgba(255,255,255,0.12)',
            '--menu-bg': '#111827',
            '--menu-border': '#334155',
            '--menu-text': '#f8fafc',
            '--menu-hover': 'linear-gradient(180deg, color-mix(in srgb, ' + accent + ' 38%, #1f2937) 0%, #1e293b 100%)',
            '--menu-divider': 'rgba(148,163,184,0.28)',
            '--icon-label-bg': 'rgba(8, 14, 22, 0.62)',
            '--icon-label-text': '#ffffff',
            '--button-tint': 'linear-gradient(180deg, #f8fafc 0%, #cbd5e1 100%)',
            '--button-tint-hover': 'linear-gradient(180deg, #ffffff 0%, #e2e8f0 100%)',
            '--button-text': '#0f172a',
            '--theme-surface': 'rgba(17, 22, 31, 0.82)',
            '--theme-surface-strong': 'rgba(23, 29, 40, 0.92)',
            '--theme-panel-bg': '#111827',
            '--theme-panel-border': '#334155',
            '--theme-field-bg': '#0f172a',
            '--theme-field-text': '#f8fafc',
            '--theme-muted-text': '#c4d0df',
            '--theme-tab-bg': 'rgba(20, 26, 36, 0.94)',
            '--theme-tab-active-bg': 'linear-gradient(180deg, rgba(104,138,182,0.42) 0%, rgba(24,32,45,0.98) 100%)',
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
          current = this.themeStudioResolvedVars(theme);
          darkVars = this.themeStudioDarkOverrides(theme);
          (this._themeStudioAppliedKeys || this.themeStudioManagedVarKeys()).forEach(function (key) { rootNode.style.removeProperty(key); });
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
          rootNode.style.setProperty('--theme-open-speed', Math.max(100, +(theme.animationSpeeds || {}).open || 180) + 'ms');
          rootNode.style.setProperty('--theme-hover-speed', Math.max(80, +(theme.animationSpeeds || {}).hover || 120) + 'ms');
          rootNode.style.setProperty('--theme-menu-speed', Math.max(100, +(theme.animationSpeeds || {}).menu || 160) + 'ms');
          rootNode.style.setProperty('--theme-wallpaper-speed', Math.max(120, +(theme.animationSpeeds || {}).wallpaper || 280) + 'ms');
          rootNode.style.setProperty('--theme-taskbar-speed', Math.max(100, +(theme.animationSpeeds || {}).taskbar || 160) + 'ms');
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
          rootNode.style.setProperty('--login-avatar-size', Math.max(48, Math.min(128, +(loginCfg.avatarSize || 82))) + 'px');
          this._themeStudioAppliedKeys = this.themeStudioManagedVarKeys().slice(0);
          rootNode.dataset.shellTheme = theme.id || 'glow';
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
            /* Active theme persistence is server-based only. */
          }
          return theme;
        },
        themeStudioAllowedTabs: function () {
          return ['themes', 'desktop', 'appearance', 'taskbarStart', 'login'];
        },
        themeStudioTabs: function () {
          return [
            { key: 'themes', label: 'Themes' },
            { key: 'desktop', label: 'Desktop' },
            { key: 'appearance', label: 'Appearance' },
            { key: 'taskbarStart', label: 'Taskbar & Start Menu' },
            { key: 'login', label: 'Login Screen' }
          ];
        },
        themeStudioActiveTab: function () {
          var tab = (((this.themeStudioStore || {}).activeTab) || 'themes');
          if (this.themeStudioAllowedTabs().indexOf(tab) < 0) tab = 'themes';
          if (this.themeStudioStore) this.themeStudioStore.activeTab = tab;
          return tab;
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
          this.themeStudioApplyLive(target);
          if (target.variants) target.variants[target.darkEnabled ? 'dark' : 'light'] = this.themeStudioBuildVariantSnapshot(target, !!target.darkEnabled);
          this.themeStudioPersistCustomThemes();
        },
        themeStudioSetTab: function (tabKey) {
          this.initThemeStudioStore();
          this.themeStudioStore.activeTab = this.themeStudioAllowedTabs().indexOf(tabKey) >= 0 ? tabKey : 'themes';
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
          var self = this;
          if (!nextName) {
            return this.inputDialog('Theme Studio', 'Rename theme', ((this.themeStudioActiveTheme() || {}).name) || 'Theme').then(function (name) {
              if (name !== null) self.themeStudioRenameActiveTheme(name);
            });
          }
          var target = this.themeStudioEditableTheme();
          if (!target) return Promise.resolve();
          target.name = String(nextName).trim() || 'Custom Theme';
          this.themeStudioApplyLive(target);
          if (target.variants) target.variants[target.darkEnabled ? 'dark' : 'light'] = this.themeStudioBuildVariantSnapshot(target, !!target.darkEnabled);
          this.themeStudioPersistCustomThemes();
          return Promise.resolve();
        },
        themeStudioSetDarkEnabled: function (enabled) {
          var target = this.themeStudioEditableTheme();
          var nextEnabled = !!enabled;
          var currentKey, nextKey, currentSnapshot, nextSnapshot, rebuilt;
          if (!target) return;
          if (!target.variants) target.variants = { light: {}, dark: {} };
          currentKey = target.darkEnabled ? 'dark' : 'light';
          nextKey = nextEnabled ? 'dark' : 'light';
          currentSnapshot = this.themeStudioBuildVariantSnapshot(target, !!target.darkEnabled);
          target.variants[currentKey] = this.themeStudioClone(currentSnapshot);
          nextSnapshot = target.variants[nextKey] && Object.keys(target.variants[nextKey]).length ? this.themeStudioClone(target.variants[nextKey]) : this.themeStudioBuildVariantSnapshot(target, nextEnabled);
          rebuilt = this.themeStudioNormalizeConfig(Object.assign({}, target, nextSnapshot, { darkEnabled: nextEnabled }));
          Object.keys(rebuilt).forEach(function (key) { target[key] = rebuilt[key]; });
          target.variants[currentKey] = this.themeStudioClone(currentSnapshot);
          target.variants[nextKey] = this.themeStudioBuildVariantSnapshot(target, nextEnabled);
          this.themeStudioApplyLive(target);
          if (target.variants) target.variants[target.darkEnabled ? 'dark' : 'light'] = this.themeStudioBuildVariantSnapshot(target, !!target.darkEnabled);
          this.themeStudioPersistCustomThemes();
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
          this.themeStudioApplyLive(target);
          if (target.variants) target.variants[target.darkEnabled ? 'dark' : 'light'] = this.themeStudioBuildVariantSnapshot(target, !!target.darkEnabled);
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
          this.themeStudioApplyLive(target);
          if (target.variants) target.variants[target.darkEnabled ? 'dark' : 'light'] = this.themeStudioBuildVariantSnapshot(target, !!target.darkEnabled);
          this.themeStudioPersistCustomThemes();
        },
        themeStudioFontScaleValue: function () {
          return parseInt(this.themeStudioTextValue('--font-size-ui', '12px'), 10) || 12;
        },
        themeStudioSetUploadedAsset: function (path, url, meta) {
          var store = this.initThemeStudioStore();
          if (!url) return;
          store.uploadStatus = 'uploaded';
          this.themeStudioUpdateField(path, url);
          if (path === 'wallpaperUrl') this.themeStudioUpdateField('wallpaperPreset', 'custom-upload');
          if (meta && meta.assetId) this.themeStudioUpdateField((path === 'wallpaperUrl' ? 'wallpaperAssetId' : path.replace(/Url$/, 'AssetId')), meta.assetId);
        },
        themeStudioUploadField: function (path, event) {
          var self = this;
          var file = event && event.target && event.target.files && event.target.files[0];
          var route, kind, store;
          if (!file) return Promise.resolve();
          store = this.initThemeStudioStore();
          if (file.type && file.type.indexOf('image/') !== 0) {
            this.showAlert('Theme Studio', 'Please choose an image file.');
            if (event && event.target) event.target.value = '';
            return Promise.resolve();
          }
          route = (((this.boot || {}).routes || {}).themeAssetUpload) || '/api/mioos/theme-asset/upload';
          kind = path.indexOf('loginScreenConfig.avatarUrl') === 0 ? 'login-avatar' : (path.indexOf('loginScreenConfig.warningImageUrl') === 0 ? 'login-warning' : (path.indexOf('loginScreenConfig.') === 0 ? 'login-wallpaper' : 'wallpaper'));
          store.uploadStatus = 'uploading';
          function parseUploadResponse(res) {
            return res.text().then(function (text) {
              var obj = {};
              if (text) {
                try { obj = JSON.parse(text); } catch (err) { obj = { ok: false, error: 'invalid_json_response', detail: text.slice(0, 180) }; }
              }
              return { ok: res.ok, status: res.status, obj: obj || {} };
            });
          }
          function postMultipart() {
            var form = new FormData();
            form.append('kind', kind);
            form.append('file', file, file.name || 'image.bin');
            return fetch(route, { method: 'POST', body: form, credentials: 'same-origin' }).then(parseUploadResponse);
          }
          function postRaw() {
            return fetch(route, {
              method: 'POST',
              body: file,
              credentials: 'same-origin',
              headers: {
                'Content-Type': file.type || 'application/octet-stream',
                'X-MIOOS-Theme-Kind': kind,
                'X-MIOOS-File-Name': encodeURIComponent(file.name || 'image.bin')
              }
            }).then(parseUploadResponse);
          }
          return postMultipart().then(function (payload) {
            if (payload.ok && payload.obj && payload.obj.ok) return payload;
            return postRaw();
          }).then(function (payload) {
            if (!payload.ok || !payload.obj || !payload.obj.ok) throw new Error((payload.obj && (payload.obj.detail || payload.obj.message || payload.obj.error)) || ('upload_failed_http_' + (payload.status || '')));
            self.themeStudioSetUploadedAsset(path, payload.obj.url || payload.obj.assetUrl || '', { assetId: payload.obj.assetId || payload.obj.id || '', kind: payload.obj.kind || kind });
            return (self.themeStudioPersistActiveRemote ? self.themeStudioPersistActiveRemote(self.themeStudioActiveTheme(), true) : Promise.resolve()).catch(function (err) {
              store.uploadStatus = 'uploaded-server-pending';
              self.showAlert('Theme Studio', 'Image uploaded, but the active theme profile was not saved: ' + ((err && err.message) || 'theme_save_failed'));
            });
          }).then(function () {
            if (store.uploadStatus !== 'uploaded-server-pending') store.uploadStatus = 'uploaded';
            self.pushNotification('Theme Studio', 'Image uploaded and linked to the active server theme.');
          }).catch(function (err) {
            store.uploadStatus = 'failed';
            self.showAlert('Theme Studio', 'Image upload failed: ' + (err && err.message ? err.message : 'upload_failed'));
          }).finally(function () {
            if (event && event.target) event.target.value = '';
          });
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
          var startStyle = this.startMenuStyleType();
          var ui = this.startMenuUi || {};
          var style = { width: Math.max(320, width) + 'px' };
          if (startStyle === 'popup') {
            style.maxWidth = 'min(720px, calc(100vw - 24px))';
            style.bottom = 'auto';
            style.right = 'auto';
            if (ui.popupPosition && typeof ui.popupPosition.left !== 'undefined' && typeof ui.popupPosition.top !== 'undefined') {
              style.left = Math.max(8, Math.min(+ui.popupPosition.left || 0, Math.max(8, window.innerWidth - Math.max(320, width) - 8))) + 'px';
              style.top = Math.max(8, Math.min(+ui.popupPosition.top || 0, Math.max(8, window.innerHeight - 120))) + 'px';
              style.transform = 'none';
            } else {
              style.left = '50%';
              style.top = '50%';
              style.transform = 'translate(-50%, -50%)';
            }
            return style;
          }
          if (pos === 'top') { style.top = h + 'px'; style.bottom = 'auto'; style.left = '14px'; }
          else if (pos === 'left') { style.left = (h + 12) + 'px'; style.bottom = '14px'; style.top = 'auto'; }
          else { style.left = '14px'; style.bottom = h + 'px'; }
          return style;
        },
        startMenuNormalizeItem: function (entry, source, groupKey) {
          entry = entry || {};
          var key = String(entry.key || entry.appKey || entry.id || entry.fileId || entry.folderId || entry.name || '').trim();
          if (!key) return null;
          var kind = String(entry.kind || entry.type || '').toLowerCase();
          var isFolder = kind === 'folder' || entry.isFolder || entry.folderId;
          var sourceName = source || entry.source || (entry.id ? 'vfs' : 'app');
          var title = entry.title || entry.label || entry.name || key;
          var subtitle = entry.subtitle || entry.description || entry.detail || '';
          if (!subtitle && sourceName === 'vfs') subtitle = isFolder ? 'Desktop folder' : 'Desktop file';
          if (!subtitle && sourceName === 'module') subtitle = entry.category || 'Module';
          if (!subtitle && sourceName === 'app') subtitle = kind || 'Application';
          return { key: key, appKey: entry.appKey || entry.key || key, launchKey: entry.launchKey || entry.appKey || entry.key || key, title: title, subtitle: subtitle, icon: entry.icon || (isFolder ? '📁' : (sourceName === 'vfs' ? '📄' : '▣')), kind: kind || (isFolder ? 'folder' : 'app'), source: sourceName, groupKey: groupKey || entry.groupKey || sourceName, id: entry.id || '', fileId: entry.fileId || (sourceName === 'vfs' ? (entry.id || key) : ''), folderId: entry.folderId || (isFolder ? (entry.id || key) : ''), path: entry.path || entry.canonicalPath || '', mime: entry.mime || entry.contentType || '', raw: entry, disabled: !!entry.disabled };
        },
        startMenuAppCatalogItems: function () {
          var self = this;
          var seen = {};
          var rows = [];
          function add(entry, source, groupKey) {
            var item = self.startMenuNormalizeItem(entry, source, groupKey);
            if (!item || seen[item.key]) return;
            seen[item.key] = 1;
            rows.push(item);
          }
          (this.launcherEntries || []).forEach(function (entry) { add(entry, 'app', 'applications'); });
          (this.boot.modules || []).forEach(function (module) {
            add({ key: module.appKey || module.id, appKey: module.appKey || module.id, title: module.title || module.name || module.id, subtitle: module.description || module.subtitle || module.category || 'Module', icon: module.icon || '▣', kind: 'module', id: module.id }, 'module', 'modules');
          });
          [
            { key: 'home', title: 'Folder Explorer', subtitle: 'Browse Desktop and VFS folders', icon: '📁', kind: 'tool' },
            { key: 'my-computer', title: 'My Computer', subtitle: 'Root filesystem browser', icon: '💻', kind: 'tool' },
            { key: 'documents', title: 'Documents', subtitle: 'Home folder explorer', icon: '🗂', kind: 'tool' },
            { key: 'customize', title: 'Theme Studio', subtitle: 'Themes, wallpaper, language, and shell settings', icon: '🎨', kind: 'tool' },
            { key: 'terminal', title: 'Terminal', subtitle: 'Open a MUMPS.IO terminal', icon: '⌁', kind: 'tool' },
            { key: 'transfers', title: 'Transfers', subtitle: 'Uploads and downloads', icon: '⇅', kind: 'tool' }
          ].forEach(function (entry) { add(entry, 'app', 'places'); });
          [{ key: 'app-catalog', title: 'Application Catalog', subtitle: 'Browse installed modules', icon: '▦', kind: 'tool' }, { key: 'control-panel', title: 'Control Panel', subtitle: 'System settings', icon: '⚙', kind: 'tool' }, { key: 'diagnostics', title: 'Diagnostics', subtitle: 'Transport and boot health', icon: '📈', kind: 'tool' }, { key: 'security-center', title: 'Security Center', subtitle: 'Sessions and users', icon: '🛡', kind: 'tool' }, { key: 'debug-center', title: 'Debug Center', subtitle: 'Developer tools', icon: '🧪', kind: 'tool' }].forEach(function (entry) { add(entry, 'app', 'system'); });
          (this.localeOptions || []).forEach(function (locale) { add({ key: 'locale:' + locale.code, title: locale.label || locale.code, subtitle: 'Switch language', icon: '🌐', kind: 'language', action: 'locale', code: locale.code }, 'action', 'language'); });
          (this.shellThemeOptions ? this.shellThemeOptions() : []).forEach(function (theme) { add({ key: 'theme:' + theme.key, title: theme.label || theme.key, subtitle: 'Apply theme preset', icon: '🎨', kind: 'theme', action: 'theme', themeKey: theme.key }, 'action', 'themes'); });
          return rows;
        },
        startMenuFilesystemItems: function () {
          var self = this;
          return (this.desktopEntries || []).filter(function (entry) { return entry && (entry.source === 'vfs' || entry.id || entry.path); }).map(function (entry) {
            var copy = Object.assign({}, entry || {});
            copy.key = 'vfs:' + (entry.id || entry.key || entry.path || entry.name);
            return self.startMenuNormalizeItem(copy, 'vfs', 'filesystem');
          }).filter(Boolean);
        },
        startMenuAllItems: function () { return this.startMenuAppCatalogItems().concat(this.startMenuFilesystemItems()); },
        startMenuEnsureUi: function () {
          if (!this.startMenuUi) this.startMenuUi = {};
          if (!this.startMenuUi.expandedGroups) this.startMenuUi.expandedGroups = {};
          if (!this.startMenuUi.expandedFolders) this.startMenuUi.expandedFolders = {};
          if (!this.startMenuUi.folderChildren) this.startMenuUi.folderChildren = {};
          if (!this.startMenuUi.folderLoading) this.startMenuUi.folderLoading = {};
          if (!this.startMenuUi.selectedKey) this.startMenuUi.selectedKey = '';
          return this.startMenuUi;
        },
        startMenuGroupDefaultOpen: function (groupKey) {
          return ['pinned', 'places', 'applications', 'filesystem'].indexOf(String(groupKey || '')) >= 0;
        },
        startMenuGroupOpen: function (group) {
          var ui = this.startMenuEnsureUi();
          var key = String((group || {}).key || '');
          if (Object.prototype.hasOwnProperty.call(ui.expandedGroups, key)) return !!ui.expandedGroups[key];
          return typeof (group || {}).open === 'boolean' ? !!group.open : this.startMenuGroupDefaultOpen(key);
        },
        startMenuToggleGroup: function (group, event) {
          if (event) { event.preventDefault(); event.stopPropagation(); }
          if (!group) return;
          var ui = this.startMenuEnsureUi();
          var key = String(group.key || '');
          ui.expandedGroups[key] = !this.startMenuGroupOpen(group);
        },
        startMenuFolderKey: function (item) {
          item = item || {};
          return String(item.folderId || item.id || item.fileId || item.key || item.path || item.title || '');
        },
        startMenuIsFolderItem: function (item) {
          item = item || {};
          return item.source === 'vfs' && (item.kind === 'folder' || item.folderId || ((item.raw || {}).kind === 'folder'));
        },
        startMenuFolderOpen: function (item) {
          var ui = this.startMenuEnsureUi();
          return !!ui.expandedFolders[this.startMenuFolderKey(item)];
        },
        startMenuFolderLoading: function (item) {
          var ui = this.startMenuEnsureUi();
          return !!ui.folderLoading[this.startMenuFolderKey(item)];
        },
        startMenuFolderChildren: function (item) {
          var ui = this.startMenuEnsureUi();
          return ui.folderChildren[this.startMenuFolderKey(item)] || [];
        },
        startMenuToggleFolder: function (item, event) {
          var self = this;
          var ui = this.startMenuEnsureUi();
          var key = this.startMenuFolderKey(item);
          if (event) { event.preventDefault(); event.stopPropagation(); }
          if (!this.startMenuIsFolderItem(item) || !key) return Promise.resolve();
          ui.expandedFolders[key] = !ui.expandedFolders[key];
          if (!ui.expandedFolders[key] || ui.folderChildren[key]) return Promise.resolve(ui.folderChildren[key] || []);
          ui.folderLoading[key] = true;
          return this.startMenuLoadFolderChildren(item).then(function (children) {
            ui.folderChildren[key] = children || [];
            ui.folderLoading[key] = false;
            return children;
          }).catch(function (err) {
            ui.folderChildren[key] = [{ key: 'folder-error:' + key, title: 'Unable to load folder', subtitle: (err && err.message) || 'fs_list_failed', icon: '⚠', disabled: true, source: 'vfs', groupKey: 'filesystem' }];
            ui.folderLoading[key] = false;
            return ui.folderChildren[key];
          });
        },
        startMenuLoadFolderChildren: function (item) {
          var self = this;
          var folderId = (item || {}).folderId || (item || {}).id || (item || {}).fileId || ((item || {}).raw || {}).id || '';
          if (!folderId || !this.command) return Promise.resolve([]);
          return this.command('fs.list', { id: folderId, parent: folderId }).then(function (msg) {
            var payload = msg && (msg.vfs || msg.payload || msg.result || msg);
            var rows = [];
            if (payload && Array.isArray(payload.items)) rows = payload.items;
            else if (payload && payload.items && typeof payload.items === 'object') rows = Object.keys(payload.items).map(function (k) { return payload.items[k]; });
            else if (payload && Array.isArray(payload.entries)) rows = payload.entries;
            else if (payload && payload.entries && typeof payload.entries === 'object') rows = Object.keys(payload.entries).map(function (k) { return payload.entries[k]; });
            else if (payload && Array.isArray(payload.rows)) rows = payload.rows;
            return rows.map(function (entry) {
              var copy = Object.assign({}, entry || {});
              copy.key = 'vfs:' + (copy.id || copy.key || copy.path || copy.name);
              return self.startMenuNormalizeItem(copy, 'vfs', 'filesystem');
            }).filter(Boolean).sort(function (a, b) {
              if (a.kind !== b.kind) { if (a.kind === 'folder') return -1; if (b.kind === 'folder') return 1; }
              return String(a.title || '').localeCompare(String(b.title || ''));
            });
          });
        },
        startMenuMatchesItem: function (item, needle) {
          if (!needle) return true;
          var hay = ((item.title || '') + ' ' + (item.subtitle || '') + ' ' + (item.key || '') + ' ' + (item.path || '')).toLowerCase();
          return hay.indexOf(needle) !== -1;
        },
        startMenuFilterItems: function (items) {
          var needle = (this.menuFilter || '').trim().toLowerCase();
          var self = this;
          return (items || []).filter(function (item) { return self.startMenuMatchesItem(item, needle); });
        },
        startMenuVisibleItems: function (group) {
          return this.startMenuGroupOpen(group) ? ((group || {}).items || []) : [];
        },
        startMenuRenderRows: function (group) {
          var self = this;
          var rows = [];
          function add(item, level) {
            rows.push({ key: String(item.key || '') + ':' + level, item: item, level: level });
            if (self.startMenuIsFolderItem(item) && self.startMenuFolderOpen(item)) {
              (self.startMenuFolderChildren(item) || []).forEach(function (child) { add(child, level + 1); });
            }
          }
          (this.startMenuVisibleItems(group) || []).forEach(function (item) { add(item, 0); });
          return rows;
        },
        startMenuFlatItems: function () {
          var out = [];
          var self = this;
          (this.startMenuGroups() || []).forEach(function (group) {
            (self.startMenuRenderRows(group) || []).forEach(function (row) { if (row.item && !row.item.disabled) out.push(row.item); });
          });
          return out;
        },
        startMenuGroups: function () {
          var catalog = this.startMenuAppCatalogItems();
          var files = this.startMenuFilesystemItems();
          var apps = catalog.filter(function (item) { return item.groupKey === 'applications'; });
          var modules = catalog.filter(function (item) { return item.source === 'module'; });
          var system = catalog.filter(function (item) { return item.groupKey === 'system'; });
          var places = catalog.filter(function (item) { return item.groupKey === 'places'; });
          var language = catalog.filter(function (item) { return item.groupKey === 'language'; });
          var themes = catalog.filter(function (item) { return item.groupKey === 'themes'; });
          var pinned = [];
          ['home', 'terminal', 'transfers', 'customize', 'app-catalog'].forEach(function (key) { var found = catalog.find(function (item) { return item.key === key || item.appKey === key; }); if (found) pinned.push(found); });
          var groups = [
            { key: 'pinned', title: 'Pinned', subtitle: 'Common places and tools', open: true, items: pinned },
            { key: 'places', title: 'Places', subtitle: 'Folders and explorer entry points', open: true, items: places },
            { key: 'applications', title: 'Programs', subtitle: 'Apps and server-authored modules', open: true, items: apps.concat(modules) },
            { key: 'filesystem', title: 'Desktop Files', subtitle: 'Expandable files and folders from /Home/Desktop', open: true, items: files },
            { key: 'themes', title: 'Themes', subtitle: 'Shell theme presets', open: false, items: themes },
            { key: 'language', title: 'Language', subtitle: 'Locale shortcuts', open: false, items: language },
            { key: 'system', title: 'System', subtitle: 'Settings, security, and diagnostics', open: false, items: system }
          ];
          var self = this;
          groups = groups.map(function (group) { var copy = Object.assign({}, group); copy.items = self.startMenuFilterItems(copy.items); return copy; }).filter(function (group) { return (group.items || []).length > 0; });
          if (!groups.length) groups.push({ key: 'empty', title: 'No results', subtitle: 'Try another search', open: true, items: [{ key: 'empty-result', title: 'No matching apps or files', subtitle: 'Search /Home/Desktop and applications', icon: '⌕', disabled: true }] });
          return groups;
        },
        startMenuItemByKey: function (key) {
          var rows = this.startMenuFlatItems ? this.startMenuFlatItems() : [];
          var i;
          for (i = 0; i < rows.length; i += 1) if (String(rows[i].key) === String(key)) return rows[i];
          return null;
        },
        startMenuSelectItem: function (item) {
          if (!item || !item.key) return;
          if (!this.startMenuUi) this.startMenuUi = { selectedKey: '', lastOpenedAt: 0 };
          this.startMenuUi.selectedKey = item.key;
        },
        startMenuGroupIcon: function (key) {
          var map = { pinned: '★', places: '⌂', applications: '▦', filesystem: '▤', themes: '◐', language: '文', system: '⚙', empty: '⌕' };
          return map[String(key || '')] || '▣';
        },
        startMenuSourceBadge: function (item) {
          item = item || {};
          if (item.action === 'locale') return 'Lang';
          if (item.action === 'theme') return 'Theme';
          if (item.source === 'vfs') return item.kind === 'folder' ? 'Folder' : 'File';
          if (item.source === 'module') return 'Module';
          if (item.groupKey === 'system') return 'System';
          if (item.groupKey === 'places') return 'Place';
          return 'App';
        },
        startMenuItemMeta: function (item) {
          item = item || {};
          var detail = item.subtitle || item.path || item.key || '';
          if (/^#?\s*shortcuts?\s+ready$/i.test(String(detail || '').trim()) || /^#\s*/.test(String(detail || '').trim())) detail = '';
          var badge = this.startMenuSourceBadge ? this.startMenuSourceBadge(item) : '';
          if (detail && badge && detail.indexOf(badge) !== 0) return badge + ' · ' + detail;
          return detail || badge || '';
        },
        startMenuEnsureSelection: function () {
          if (!this.startMenuUi) this.startMenuUi = { selectedKey: '', lastOpenedAt: 0 };
          var items = this.startMenuFlatItems();
          if (!items.length) { this.startMenuUi.selectedKey = ''; return null; }
          if (!this.startMenuUi.selectedKey || !items.some(function (item) { return item.key === this.startMenuUi.selectedKey; }, this)) this.startMenuUi.selectedKey = items[0].key;
          return this.startMenuItemByKey(this.startMenuUi.selectedKey) || items[0];
        },
        startMenuMoveSelection: function (delta) {
          if (!this.startMenuUi) this.startMenuUi = { selectedKey: '', lastOpenedAt: 0 };
          var items = this.startMenuFlatItems();
          if (!items.length) return;
          var idx = items.findIndex(function (item) { return item.key === this.startMenuUi.selectedKey; }, this);
          if (idx < 0) idx = 0;
          idx = (idx + delta + items.length) % items.length;
          this.startMenuUi.selectedKey = items[idx].key;
        },
        startMenuHandleKeydown: function (event) {
          if (!event) return;
          if (event.key === 'Escape') { event.preventDefault(); this.menuOpen = false; return; }
          if (event.key === 'ArrowDown') { event.preventDefault(); this.startMenuMoveSelection(1); return; }
          if (event.key === 'ArrowUp') { event.preventDefault(); this.startMenuMoveSelection(-1); return; }
          if (event.key === 'Home') { event.preventDefault(); var first = this.startMenuFlatItems()[0]; if (first) this.startMenuUi.selectedKey = first.key; return; }
          if (event.key === 'End') { event.preventDefault(); var rows = this.startMenuFlatItems(); var last = rows[rows.length - 1]; if (last) this.startMenuUi.selectedKey = last.key; return; }
          if (event.key === 'Enter') { event.preventDefault(); this.startMenuOpenItem(this.startMenuEnsureSelection()); }
        },
        startMenuOpenItem: function (itemOrKey) {
          var item = typeof itemOrKey === 'string' ? this.startMenuItemByKey(itemOrKey) : itemOrKey;
          if (!item || item.disabled) return;
          if (this.startMenuIsFolderItem && this.startMenuIsFolderItem(item)) {
            this.startMenuToggleFolder(item);
            return;
          }
          this.menuOpen = false;
          if (this.startMenuUi) this.startMenuUi.lastOpenedAt = Date.now();
          if (item.action === 'locale' && this.changeLocale) { this.changeLocale(item.code || String(item.key || '').replace(/^locale:/, '')); return; }
          if (item.action === 'theme' && this.applyShellTheme) { this.applyShellTheme(item.themeKey || String(item.key || '').replace(/^theme:/, '')); return; }
          if (item.source === 'vfs') { if (this.openDesktopEntry) this.openDesktopEntry(item.raw || { key: item.fileId || item.folderId || item.id || item.key, id: item.fileId || item.folderId || item.id || item.key, name: item.title, kind: item.kind, source: 'vfs', mime: item.mime || ((item.raw || {}).mime) || '', path: item.path || '' }); return; }
          if (item.source === 'module' && this.openModuleEntry) { this.openModuleEntry(item.raw && (item.raw.id || item.raw.appKey) || item.appKey || item.key); return; }
          var key = item.launchKey || item.appKey || item.key;
          if (key === 'theme-studio') key = 'customize';
          this.openApp(key);
        },
        startMenuBeginPopupDrag: function (event) {
          if (this.startMenuStyleType && this.startMenuStyleType() !== 'popup') return;
          if (!event || (event.button && event.button !== 0)) return;
          if (event.target && event.target.closest && event.target.closest('button,input,select,textarea,a')) return;
          var ui = this.startMenuEnsureUi();
          var rect = event.currentTarget && event.currentTarget.closest ? event.currentTarget.closest('.mioos-start-menu-vue').getBoundingClientRect() : null;
          ui.popupPosition = ui.popupPosition || { left: rect ? rect.left : Math.max(16, (window.innerWidth - 520) / 2), top: rect ? rect.top : Math.max(16, (window.innerHeight - 520) / 2) };
          ui.popupDrag = { active: true, startX: event.clientX, startY: event.clientY, left: ui.popupPosition.left, top: ui.popupPosition.top };
          var self = this;
          if (event.preventDefault) event.preventDefault();
          if (this._startMenuPopupDragMove) window.removeEventListener('pointermove', this._startMenuPopupDragMove);
          if (this._startMenuPopupDragEnd) window.removeEventListener('pointerup', this._startMenuPopupDragEnd);
          this._startMenuPopupDragMove = function (ev) { self.startMenuMovePopupDrag(ev); };
          this._startMenuPopupDragEnd = function (ev) { self.startMenuEndPopupDrag(ev); };
          window.addEventListener('pointermove', this._startMenuPopupDragMove);
          window.addEventListener('pointerup', this._startMenuPopupDragEnd, { once: true });
        },
        startMenuMovePopupDrag: function (event) {
          var ui = this.startMenuEnsureUi();
          var drag = ui.popupDrag || {};
          if (!drag.active || !event) return;
          var width = +((((this.themeStudioActiveTheme() || {}).startMenuConfig || {}).width) || 520);
          ui.popupPosition = {
            left: Math.max(8, Math.min((drag.left || 0) + event.clientX - drag.startX, Math.max(8, window.innerWidth - Math.max(320, width) - 8))),
            top: Math.max(8, Math.min((drag.top || 0) + event.clientY - drag.startY, Math.max(8, window.innerHeight - 120)))
          };
        },
        startMenuEndPopupDrag: function () {
          var ui = this.startMenuEnsureUi();
          if (ui.popupDrag) ui.popupDrag.active = false;
          if (this._startMenuPopupDragMove) window.removeEventListener('pointermove', this._startMenuPopupDragMove);
          this._startMenuPopupDragMove = null;
          this._startMenuPopupDragEnd = null;
        },
        activeLoginPublicAssets: function () {
          var theme = this.themeStudioActiveTheme ? this.themeStudioActiveTheme() : {};
          var cfg = this.activeLoginScreenConfig ? this.activeLoginScreenConfig() : {};
          return !!((theme || {}).publicLogin || (cfg || {}).publicLogin);
        },
        activeLoginAvatarUrl: function () {
          var cfg = this.activeLoginScreenConfig ? this.activeLoginScreenConfig() : {};
          var url = cfg.avatarUrl || cfg.warningImageUrl || '';
          return this.isProtectedThemeUrl(url) && this.requiresSignin && !this.activeLoginPublicAssets() ? '' : url;
        },
        activeLoginWarningImageUrl: function () {
          var cfg = this.activeLoginScreenConfig ? this.activeLoginScreenConfig() : {};
          var url = cfg.warningImageUrl || '';
          return this.isProtectedThemeUrl(url) && this.requiresSignin && !this.activeLoginPublicAssets() ? '' : url;
        },
        activeLoginWarningTitle: function () {
          var cfg = this.activeLoginScreenConfig ? this.activeLoginScreenConfig() : {};
          return cfg.warningTitle || 'Authorized access only';
        },
        activeLoginDisclaimer: function () {
          var cfg = this.activeLoginScreenConfig ? this.activeLoginScreenConfig() : {};
          return cfg.privacyNotice || cfg.disclaimer || 'Access to this system is restricted to authorized users. Activity may be logged and reviewed.';
        },
        activeLoginScreenConfig: function () {
          return (((this.themeStudioActiveTheme() || {}).loginScreenConfig) || {});
        },
        activeLoginPrivacyNotice: function () {
          return (((this.activeLoginScreenConfig() || {}).privacyNotice) || '');
        },
        themeStudioBootProfile: function () {
          return ((((this.boot || {}).desktop || {}).activeThemeProfile) || null);
        },
        themeStudioConfigFromServerProfile: function (profile) {
          profile = (this.requiresSignin && this.sanitizeProtectedThemeProfile) ? this.sanitizeProtectedThemeProfile(profile || {}) : profile;
          var src = profile || {};
          var cfg = src.themeConfig || src.config || src;
          var desktop = Object.assign({}, cfg.desktop || {}, src.desktop || {});
          var wallpaper = Object.assign({}, cfg.wallpaper || {}, src.wallpaper || {});
          var loginCfg = Object.assign({}, cfg.loginScreenConfig || {}, src.loginScreenConfig || {});
          var id = cfg.id || src.id || src.key || src.presetKey || src.family || 'glow';
          var wallpaperUrl = desktop.wallpaperUrl || src.wallpaperUrl || cfg.wallpaperUrl || wallpaper.url || wallpaper.href || '';
          var wallpaperFit = cfg.wallpaperFit || src.wallpaperFit || desktop.wallpaperFit || wallpaper.fit || 'cover';
          var wallpaperPreset = cfg.wallpaperPreset || src.wallpaperPreset || desktop.wallpaperPreset || wallpaper.preset || (wallpaperUrl ? 'custom-upload' : 'aurora');
          var mapped = this.themeStudioNormalizeConfig(Object.assign({}, cfg, {
            id: id,
            name: cfg.name || src.name || id,
            sourceId: cfg.sourceId || src.sourceId || src.family || src.baseTheme || cfg.baseTheme || id,
            darkEnabled: (src.mode || cfg.mode || '') === 'dark' || !!cfg.darkEnabled,
            cssVars: Object.assign({}, cfg.cssVars || {}, src.cssVars || {}, src.colors || {}),
            wallpaperUrl: wallpaperUrl,
            wallpaperFit: wallpaperFit,
            wallpaperPreset: wallpaperPreset,
            wallpaperAssetId: desktop.wallpaperAssetId || src.wallpaperAssetId || cfg.wallpaperAssetId || wallpaper.assetId || '',
            taskbarConfig: Object.assign({}, cfg.taskbarConfig || {}, src.taskbarConfig || {}),
            startMenuConfig: Object.assign({}, cfg.startMenuConfig || {}, src.startMenuConfig || {}),
            loginScreenConfig: Object.assign({}, loginCfg, {
              wallpaperUrl: loginCfg.wallpaperUrl || ((desktop.login || {}).wallpaperUrl) || '',
              publicLogin: !!(src.publicLogin || loginCfg.publicLogin)
            }),
            publicLogin: !!src.publicLogin,
            mobileConfig: Object.assign({}, cfg.mobileConfig || {}, src.mobileConfig || {})
          }));
          if (((src.appearance || {}).accent) && mapped.cssVars) mapped.cssVars['--accent'] = src.appearance.accent;
          if (mapped.wallpaperUrl) mapped.wallpaperPreset = mapped.wallpaperPreset || 'custom-upload';
          mapped.locked = false;
          return mapped;
        },
        themeStudioServerProfile: function (theme) {
          var target = this.themeStudioNormalizeConfig(theme || this.themeStudioActiveTheme() || {});
          var mode = target.darkEnabled ? 'dark' : 'light';
          return {
            key: target.id,
            id: target.id,
            name: target.name || target.id,
            presetKey: target.id,
            family: target.sourceId || target.id,
            mode: mode,
            density: ((((this.boot || {}).desktop || {}).density) || 'comfortable'),
            appearance: { accent: ((target.cssVars || {})['--accent']) || '', density: ((((this.boot || {}).desktop || {}).density) || 'comfortable') },
            colors: this.themeStudioClone(target.cssVars || {}),
            cssVars: this.themeStudioClone(target.cssVars || {}),
            wallpaperAssetId: target.wallpaperAssetId || '',
            desktop: { wallpaperPreset: target.wallpaperPreset || 'aurora', wallpaperUrl: target.wallpaperUrl || '', wallpaperAssetId: target.wallpaperAssetId || '', wallpaperFit: target.wallpaperFit || 'cover' },
            taskbarConfig: this.themeStudioClone(target.taskbarConfig || {}),
            startMenuConfig: this.themeStudioClone(target.startMenuConfig || {}),
            loginScreenConfig: this.themeStudioClone(target.loginScreenConfig || {}),
            mobileConfig: this.themeStudioClone(target.mobileConfig || {}),
            themeConfig: this.themeStudioClone(target)
          };
        },
        themeStudioOpenSession: function () {
          var store = this.initThemeStudioStore();
          store.sessionSnapshot = this.themeStudioClone(this.themeStudioActiveTheme() || {});
          store.sessionThemes = this.themeStudioClone(store.themes || {});
          store.sessionOrder = (store.order || []).slice(0);
          store.sessionCustomThemes = (store.customThemes || []).slice(0);
          store.sessionActiveThemeId = store.activeThemeId || '';
          store.saveStatus = '';
          store.uploadStatus = '';
          return store.sessionSnapshot;
        },
        themeStudioCloseWindow: function () {
          var target = (this.windows || []).find(function (win) { return win && (win.appKey === 'customize' || win.appKey === 'theme-studio' || win.kind === 'customize'); });
          if (target && this.closeWindow) this.closeWindow(target.id);
        },
        themeStudioCancel: function () {
          var store = this.initThemeStudioStore();
          var snap = store.sessionSnapshot;
          if (store.sessionThemes) {
            store.themes = this.themeStudioClone(store.sessionThemes || {});
            store.order = (store.sessionOrder || []).slice(0);
            store.customThemes = (store.sessionCustomThemes || []).slice(0);
            store.activeThemeId = store.sessionActiveThemeId || ((snap && snap.id) || 'glow');
          } else if (snap && snap.id) {
            store.themes[snap.id] = this.themeStudioNormalizeConfig(snap);
            if ((store.order || []).indexOf(snap.id) < 0) store.order.push(snap.id);
            store.activeThemeId = snap.id;
          }
          if (store.activeThemeId && store.themes[store.activeThemeId]) this.applyThemeStudioConfig(store.themes[store.activeThemeId], { silent: true, persist: false });
          this.themeStudioPersistCustomThemes(true);
          this.themeStudioCloseWindow();
        },
        themeStudioPersistActiveRemote: function (theme, activate) {
          var target = this.themeStudioNormalizeConfig(theme || this.themeStudioActiveTheme() || {});
          var payload = { key: target.id, activate: activate === false ? 0 : 1, profile: this.themeStudioServerProfile(target) };
          if (this.requiresSignin) return Promise.resolve({ ok: 1, skipped: 'signin_required' });
          if (!this.themeStudioSaveRemote) return Promise.resolve({ ok: 0, error: 'theme_save_missing' });
          return this.themeStudioSaveRemote(payload);
        },
        themeStudioApplyToDesktop: function (id) {
          var target = this.themeStudioThemeById(id || ((this.themeStudioStore || {}).activeThemeId));
          var self = this;
          if (!target) return Promise.resolve();
          this.applyThemeStudioConfig(target, { silent: true, persist: true });
          this.themeStudioPersistCustomThemes(true);
          return this.themeStudioPersistActiveRemote(target, true).then(function () {
            self.themeStudioOpenSession();
            self.pushNotification('Theme Studio', (target.name || 'Theme') + ' applied.');
          }).catch(function (err) {
            self.showAlert('Theme Studio', 'Theme applied locally, but server save failed: ' + ((err && err.message) || 'theme_save_failed'));
          });
        },
        themeStudioSaveCustomTheme: function () {
          var target = this.themeStudioEditableTheme();
          var self = this;
          if (!target) return Promise.resolve();
          this.themeStudioPersistCustomThemes(true);
          this.applyThemeStudioConfig(target, { silent: true, persist: true });
          return this.themeStudioPersistActiveRemote(target, true).then(function () {
            self.themeStudioOpenSession();
            self.pushNotification('Theme Studio', (target.name || 'Theme') + ' saved.');
            self.themeStudioCloseWindow();
          }).catch(function (err) {
            self.showAlert('Theme Studio', 'Theme saved locally, but server save failed: ' + ((err && err.message) || 'theme_save_failed'));
          });
        },
        themeStudioPreviewRootStyle: function () {
          var active = this.themeStudioActiveTheme();
          var alpha = this.taskbarTransparencyValue();
          var style = { '--desktop-wallpaper': this.themeStudioWallpaperCss(active), '--login-wallpaper': this.themeStudioLoginWallpaperCss(active), width: '480px', height: '360px' };
          var current = this.themeStudioResolvedVars(active);
          Object.keys(current).forEach(function (key) { style[key] = current[key]; });
          style['--taskbar-height'] = this.taskbarHeightValue() + 'px';
          style['--start-menu-width'] = ((((active || {}).startMenuConfig || {}).width) || 360) + 'px';
          style['--taskbar-transparency'] = String(alpha);
          style['--taskbar-overlay'] = (active && active.darkEnabled) ? ('rgba(255,255,255,' + (0.04 + alpha * 0.12).toFixed(3) + ')') : ('rgba(255,255,255,' + (0.02 + alpha * 0.24).toFixed(3) + ')');
          style['--taskbar-blur'] = (6 + Math.round(alpha * 14)) + 'px';
          style['--taskbar-effective-bg'] = this.taskbarEffectiveBackground(active, alpha);
          style['--theme-open-speed'] = Math.max(100, +(((active || {}).animationSpeeds || {}).open || 180)) + 'ms';
          style['--theme-hover-speed'] = Math.max(80, +(((active || {}).animationSpeeds || {}).hover || 120)) + 'ms';
          style['--theme-menu-speed'] = Math.max(100, +(((active || {}).animationSpeeds || {}).menu || 160)) + 'ms';
          style['--theme-wallpaper-speed'] = Math.max(120, +(((active || {}).animationSpeeds || {}).wallpaper || 280)) + 'ms';
          style['--theme-taskbar-speed'] = Math.max(100, +(((active || {}).animationSpeeds || {}).taskbar || 160)) + 'ms';
          return style;
        },
        themeStudioPreviewMobileRootStyle: function () {
          var active = this.themeStudioActiveTheme();
          var mobileHeight = (((active || {}).mobileConfig || {}).taskbarHeightMobile) || 46;
          var alpha = this.taskbarTransparencyValue();
          var current = this.themeStudioResolvedVars(active);
          var style = { '--desktop-wallpaper': this.themeStudioWallpaperCss(active), '--login-wallpaper': this.themeStudioLoginWallpaperCss(active), width: '220px', height: '372px' };
          Object.keys(current).forEach(function (key) { style[key] = current[key]; });
          style['--taskbar-height'] = mobileHeight + 'px';
          style['--desktop-icon-size'] = ((((active || {}).mobileConfig || {}).iconSizeMobile) || 60) + 'px';
          style['--taskbar-transparency'] = String(alpha);
          style['--taskbar-overlay'] = (active && active.darkEnabled) ? ('rgba(255,255,255,' + (0.04 + alpha * 0.12).toFixed(3) + ')') : ('rgba(255,255,255,' + (0.02 + alpha * 0.24).toFixed(3) + ')');
          style['--taskbar-blur'] = (6 + Math.round(alpha * 14)) + 'px';
          style['--taskbar-effective-bg'] = this.taskbarEffectiveBackground(active, alpha);
          style['--theme-open-speed'] = Math.max(100, +(((active || {}).animationSpeeds || {}).open || 180)) + 'ms';
          style['--theme-hover-speed'] = Math.max(80, +(((active || {}).animationSpeeds || {}).hover || 120)) + 'ms';
          style['--theme-menu-speed'] = Math.max(100, +(((active || {}).animationSpeeds || {}).menu || 160)) + 'ms';
          style['--theme-wallpaper-speed'] = Math.max(120, +(((active || {}).animationSpeeds || {}).wallpaper || 280)) + 'ms';
          style['--theme-taskbar-speed'] = Math.max(100, +(((active || {}).animationSpeeds || {}).taskbar || 160)) + 'ms';
          return style;
        },
        /* MIOOST restored shell helpers: keep legacy shell/test contracts wired to the componentized shell. */
        taskbarGroups: function () {
          var groups = {};
          (this.taskbarWindows ? this.taskbarWindows : []).forEach(function (win) {
            var key = win.appKey || win.kind || win.title || win.id;
            if (!groups[key]) groups[key] = { key: key, title: win.title || key, windows: [], count: 0 };
            groups[key].windows.push(win);
            groups[key].count += 1;
          });
          return Object.keys(groups).map(function (key) { return groups[key]; });
        },
        taskbarPrimaryGroups: function () {
          return this.taskbarGroups().slice(0, 8);
        },
        taskbarOverflowGroups: function () {
          return this.taskbarGroups().slice(8);
        },
        activateTaskGroup: function (group) {
          var wins = (group && group.windows) || [];
          if (wins.length) this.focusWindow(wins[0].id);
        },
        closeTrayPanel: function () {
          this.trayPanelOpen = false;
        },
        clockDateText: function () {
          try { return new Date().toLocaleDateString((this.currentLocale || {}).code || undefined, { month: 'short', day: 'numeric' }); } catch (err) { return ''; }
        },
        pushNotification: function (title, body, options) {
          if (!this.notifications) this.notifications = [];
          var item = Object.assign({ id: 'notice-' + Date.now(), title: title || 'MIOOS', body: body || '', createdAt: Date.now() }, options || {});
          this.notifications.unshift(item);
          if (this.notifications.length > 6) this.notifications.length = 6;
          return item;
        },
        openShellDialog: function (kind, title, message, options) {
          var self = this;
          var opts = options || {};
          if (this.shellDialog && this.shellDialog.open && this.shellDialog.resolver) {
            try { this.shellDialog.resolver(null); } catch (err) {}
          }
          return new Promise(function (resolve) {
            self.shellDialog = {
              open: true,
              kind: kind || 'input',
              title: title || (kind === 'confirm' ? 'Confirm' : 'Input'),
              message: message || '',
              value: opts.value || '',
              placeholder: opts.placeholder || '',
              confirmText: opts.confirmText || (kind === 'confirm' ? 'Confirm' : 'OK'),
              cancelText: opts.cancelText || 'Cancel',
              danger: !!opts.danger,
              resolver: resolve
            };
          });
        },
        inputDialog: function (title, message, value) {
          return this.openShellDialog('input', title, message, { value: value || '', confirmText: 'OK' });
        },
        confirmDialog: function (title, message, options) {
          return this.openShellDialog('confirm', title, message, options || {});
        },
        shellDialogCancel: function () {
          var resolver = (this.shellDialog || {}).resolver;
          this.shellDialog = { open: false, kind: '', title: '', message: '', value: '', placeholder: '', confirmText: 'OK', cancelText: 'Cancel', danger: false, resolver: null };
          if (resolver) resolver(null);
        },
        shellDialogSubmit: function () {
          var dialog = this.shellDialog || {};
          var resolver = dialog.resolver;
          var value = dialog.kind === 'confirm' ? true : String(dialog.value || '');
          this.shellDialog = { open: false, kind: '', title: '', message: '', value: '', placeholder: '', confirmText: 'OK', cancelText: 'Cancel', danger: false, resolver: null };
          if (resolver) resolver(value);
        },
        copyTextToClipboard: function (text) {
          if (navigator.clipboard && navigator.clipboard.writeText) return navigator.clipboard.writeText(String(text || ''));
          var area = document.createElement('textarea');
          area.value = String(text || '');
          document.body.appendChild(area); area.select(); document.execCommand('copy'); document.body.removeChild(area);
          return Promise.resolve();
        },
        workspaceEnabled: function () { return !!((((this.boot || {}).desktop || {}).workspaces || {}).enabled); },
        centerAuthWindow: function () {
          if (WM && typeof WM.centerAuthWindow === 'function') return WM.centerAuthWindow.call(this);
          return null;
        },
        transportServerSocketRows: function () {
          var report = (this.transportDiagnostics && this.transportDiagnostics.report) || {};
          return Object.keys(report.sockets || {}).map(function (key) { return Object.assign({ key: key }, report.sockets[key]); });
        },
        themeStudioPresetFamilies: function () {
          return (((((this.boot || {}).desktop || {}).themeSystem || {}).presetFamilies) || [
            { key: 'meadow-classic', title: 'Meadow Classic' },
            { key: 'glass-horizon', title: 'Glass Horizon' },
            { key: 'graphite-dock', title: 'Graphite Dock' },
            { key: 'ember-panel', title: 'Ember Panel' }
          ]);
        },
        themeStudioLoadRemote: function (key) {
          var route = (((this.boot || {}).routes || {}).themeLoad) || '/api/mioos/theme/load';
          var body = key ? { key: key } : {};
          return fetch(route, { method: 'POST', credentials: 'same-origin', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) }).then(function (res) {
            return res.json().then(function (obj) { if (!res.ok) throw new Error((obj && (obj.detail || obj.error)) || 'theme_load_failed'); return obj || {}; });
          });
        },
        themeStudioSaveRemote: function (payload) {
          var route = (((this.boot || {}).routes || {}).themeSave) || '/api/mioos/theme/save';
          return fetch(route, { method: 'POST', credentials: 'same-origin', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload || {}) }).then(function (res) {
            return res.json().then(function (obj) { if (!res.ok || (obj && obj.ok === 0)) throw new Error((obj && (obj.detail || obj.error)) || 'theme_save_failed'); return obj || {}; });
          });
        },
        hydrateShellTheme: function (profile) {
          var source = profile || (((this.boot || {}).desktop || {}).activeThemeProfile) || null; /* desktop.activeThemeProfile */
          var normalized = source && (source.themeConfig || source.desktop || source.presetKey || source.colors) ? this.themeStudioConfigFromServerProfile(source) : source;
          this.appliedThemeProfile = normalized || source || null;
          if (normalized && normalized.id) this.activeThemeKey = normalized.id;
          else if (source && source.presetKey) this.activeThemeKey = source.presetKey;
          if (normalized && normalized.id && this.themeStudioStore) {
            this.themeStudioStore.activeThemeId = normalized.id;
            if (this.themeStudioStore.themes && !this.themeStudioStore.themes[normalized.id]) {
              this.themeStudioStore.themes[normalized.id] = normalized;
              if (this.themeStudioStore.order && this.themeStudioStore.order.indexOf(normalized.id) < 0) this.themeStudioStore.order.push(normalized.id);
            }
          }
          return this.appliedThemeProfile;
        },
        setShellTheme: function (profile) {
          return this.hydrateShellTheme ? this.hydrateShellTheme(profile) : null;
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
      }, Auth, WS, WM, Terminal, Explorer, Modules, Table, Permissions)
    });

    app.config.compilerOptions.delimiters = ['[[', ']]'];
    if (window.MIOOSModules && typeof window.MIOOSModules.register === 'function') {
      window.MIOOSModules.register(app);
    }
    if (window.MIOOSTable && typeof window.MIOOSTable.register === 'function') {
      window.MIOOSTable.register(app);
    }
    if (window.MIOOSPermissions && typeof window.MIOOSPermissions.register === 'function') {
      window.MIOOSPermissions.register(app);
    }
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
