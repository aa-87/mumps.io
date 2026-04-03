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
          terminalPollTimer: null
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
            }
          }
        }
      },
      mounted: function () {
        this.bootstrapFromDom();
        this.applyDocumentLocale();
        this.startClock();
        this.refreshView();
        this.initSocket();
        if (this.startTerminalPolling) this.startTerminalPolling();
        this._dragMove = this.onDragMove.bind(this);
        this._dragEnd = this.endDrag.bind(this);
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
            colors: { accent: '#245edb', accentStrong: '#1f4fa5', panel: '#f7fbff', panelText: '#132136', titlebar: '#2b5bc7', taskbar: '#245edb', iconText: '#ffffff', border: '#4e79c7' },
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
            win.themeStudioState = {
              activeTab: 'overview',
              profiles: [
                { key: 'xp', name: 'Windows XP Inspired', family: 'Windows XP', mode: 'light', data: this.themeStudioPresetProfile('xp') },
                { key: 'win7', name: 'Windows 7 Inspired', family: 'Windows 7', mode: 'light', data: this.themeStudioPresetProfile('win7') },
                { key: 'mac', name: 'Mac Inspired', family: 'Mac', mode: 'light', data: this.themeStudioPresetProfile('mac') }
              ],
              profileKey: 'xp', profile: this.themeStudioPresetProfile('xp'), exportText: ''
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
        themeStudioSaveProfile: function (windowId) { var win = this.windows.find(function (item) { return item.id === windowId; }); var state = this.ensureThemeStudioState(win); var entry = { key: state.profileKey || ('custom-' + Date.now()), name: state.profile.name || 'Custom Theme', family: state.profile.family || 'Custom', mode: state.profile.mode || 'light', data: window.MIOOSState.deepClone(state.profile) }; var idx = (state.profiles || []).findIndex(function (item) { return item.key === entry.key; }); state.profileKey = entry.key; if (idx >= 0) state.profiles.splice(idx, 1, entry); else state.profiles.push(entry); state.exportText = JSON.stringify(entry.data, null, 2); this.showAlert('Theme Studio', 'Draft saved inside Theme Studio.'); },
        themeStudioExportProfile: function (windowId) { var win = this.windows.find(function (item) { return item.id === windowId; }); var state = this.ensureThemeStudioState(win); state.exportText = JSON.stringify(state.profile, null, 2); this.showAlert('Theme Studio', 'Export JSON is ready in the buffer below.'); },
        themeStudioImportProfile: function (windowId) { var win = this.windows.find(function (item) { return item.id === windowId; }); var state = this.ensureThemeStudioState(win); try { if (!state.exportText) return; state.profile = Object.assign(this.themeStudioFactoryProfile('Imported Theme', 'Custom', 'light'), JSON.parse(state.exportText)); this.showAlert('Theme Studio', 'Import buffer applied to the current draft.'); } catch (err) { this.showAlert('Theme Studio', 'Import buffer is not valid JSON yet.'); } },
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
