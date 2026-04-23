(function () {
  function deepClone(value) {
    return JSON.parse(JSON.stringify(value || {}));
  }

  function defaultLocales() {
    return [
      { code: 'en', label: 'English', dir: 'ltr', isDefault: true },
      { code: 'ar', label: 'العربية', dir: 'rtl', isDefault: false },
      { code: 'es', label: 'Español', dir: 'ltr', isDefault: false }
    ];
  }

  function defaultBoot() {
    return {
      product: { name: 'MIOOS', subtitle: '', profile: 'dev', version: '' },
      user: { id: '', displayName: '', authenticated: false, roles: [] },
      session: { id: 'mioos-shell', transportModel: 'core-websocket-plus-app-websockets' },
      locale: { code: 'en', dir: 'ltr', label: 'English', rtl: false, supported: defaultLocales() },
      i18n: { strings: {} },
      routes: {
        desktop: '/mioos',
        bootstrap: '/api/mioos/bootstrap',
        view: '/api/mioos/view',
        signin: '/api/mioos/auth/signin',
        publicSignin: '/api/mioos/auth/signin',
        signout: '/api/mioos/auth/signout',
        guestSignin: '/api/mioos/auth/guest',
        passwordChange: '/api/mioos/auth/password/change',
        auditExport: '/api/mioos/auth/audit/export',
        fsUploadBegin: '/api/mioos/fs/upload/begin',
        fsUploadChunk: '/api/mioos/fs/upload/chunk',
        fsUploadStatus: '/api/mioos/fs/upload/status',
        fsUploadCommit: '/api/mioos/fs/upload/commit',
        fsUploadAbort: '/api/mioos/fs/upload/abort',
        fsBlob: '/api/mioos/fs/blob',
        themeLoad: '/api/mioos/theme/load',
        themeSave: '/api/mioos/theme/save',
        fsSetMeta: '/api/mioos/fs/setmeta',
        debugSnapshotCommand: 'debug.snapshot',
        websocket: '/ws/mioos',
        terminalWebsocket: '/ws/mioos/terminal',
        commandEvent: 'desktop.command',
        commandResultEvent: 'desktop.result',
        commandErrorEvent: 'desktop.error'
      },
      desktop: {
        themeKey: 'luna-blue',
        wallpaper: 'aurora',
        density: 'comfortable',
        fontFamily: 'Segoe UI',
        fontSize: 13,
        launcherLabel: 'Menu',
        shellChrome: 'shell-foundation',
        taskbarStyle: 'taskbar-foundation',
        startMenuStyle: 'launcher-foundation',
        windowManager: 'mioos-native-vue-css',
        commandTransport: 'websocket-only',
        realtimeContract: 'core-websocket-plus-app-websockets',
        themes: [
          { key: 'meadow-classic-light', title: 'Meadow Classic', family: 'Meadow Classic', mode: 'light', wallpaper: 'aurora', accent: '#2f67d8', taskbar: '#245dd8' },
          { key: 'meadow-classic-dark', title: 'Meadow Classic Night', family: 'Meadow Classic', mode: 'dark', wallpaper: 'aurora-night', accent: '#6fa8ff', taskbar: '#1b2e48' },
          { key: 'glass-horizon-light', title: 'Glass Horizon', family: 'Glass Horizon', mode: 'light', wallpaper: 'paper-dawn', accent: '#4b86e8', taskbar: '#dce7f5' },
          { key: 'glass-horizon-dark', title: 'Glass Horizon Midnight', family: 'Glass Horizon', mode: 'dark', wallpaper: 'paper-night', accent: '#7eb6ff', taskbar: '#192638' },
          { key: 'graphite-dock-light', title: 'Graphite Dock', family: 'Graphite Dock', mode: 'light', wallpaper: 'solid-graphite', accent: '#7da8ff', taskbar: '#d9dce4' },
          { key: 'graphite-dock-dark', title: 'Graphite Dock Night', family: 'Graphite Dock', mode: 'dark', wallpaper: 'midnight-grid', accent: '#a9beff', taskbar: '#2e343f' },
          { key: 'ember-panel-light', title: 'Ember Panel', family: 'Ember Panel', mode: 'light', wallpaper: 'sunrise-grid', accent: '#dd6a36', taskbar: '#f2e7df' },
          { key: 'ember-panel-dark', title: 'Ember Panel Night', family: 'Ember Panel', mode: 'dark', wallpaper: 'midnight-grid', accent: '#ffb087', taskbar: '#20161a' }
        ]
      },
      auth: { enabled: true, required: true, guestLoginEnabled: false, mode: 'local-session-required', unauthenticatedAccessAllowed: false, providers: { local: { enabled: true, loginMode: 'username-password', guestAllowed: false }, framework: { enabled: true, mode: 'mioauth-session-jwt', tokenType: 'jwt', sessionCookie: 'mioos_auth' } }, lockout: { threshold: 5, minutes: 15 }, passwordPolicy: { minLength: 12, requireUpper: true, requireLower: true, requireDigit: true, requireSymbol: true, maxAgeDays: 90, warnDays: 14, changeTokenMinutes: 15 }, audit: { enabled: true, retainDays: 365, reportLimit: 20, reportWindowDays: 30, scope: 'self' }, management: { sessionAdminEnabled: true, accountAdminEnabled: true, sessionLimit: 20, accountLimit: 20, adminRole: 'admin' } },
      explorer: { currentFolderId: 'root', quickPlaces: [], preview: { enabled: true, mime: 'text/plain' } },
      terminal: {
        enabled: true,
        engine: 'xtermjs',
        transport: 'pipe',
        commandTransport: 'dedicated-websocket',
        sessionModel: 'multi-window-ydb-direct',
        websocketPath: '/ws/mioos/terminal',
        websocketPollMs: 250,
        maxSessionsPerUser: 8,
        profile: {
          fontFamily: 'Consolas',
          fontSize: 14,
          cursorBlink: true,
          cursorStyle: 'block',
          scrollback: 2500,
          renderer: 'canvas',
          unicode: 'unicode11',
          rows: 28,
          cols: 112
        }
      },
      websocket: {
        heartbeatSeconds: 15,
        resumeWindowSeconds: 180,
        maxInflightPerChannel: 4,
        maxSocketsPerSession: 6,
        coreSockets: 1,
        fsSockets: 1,
        uploadBatchSize: 2,
        batchFlushThreshold: 2,
        diagnosticsEnabled: true,
        requestTimeoutMs: 15000,
        uploadBeginTimeoutMs: 20000,
        uploadChunkTimeoutMs: 30000,
        uploadCommitTimeoutMs: 120000,
        uploadAbortTimeoutMs: 15000,
        uploadSocketOpenTimeoutMs: 15000,
        maxFrameBytes: 262144,
        maxMessageBytes: 1048576
      },
      vfs: { enabled: false, rootId: 'root', homeId: 'home', chunkSize: 131072, httpChunkBytes: 131072, readPreviewBytes: 262144, readWindowBytes: 262144, mediaInitialBytes: 262144, mediaWarmupBytes: 65536, globalsOnly: true, uploadStaleSeconds: 1800, downloadStaleSeconds: 900, uploadChunkBytes: 860000, uploadConcurrency: 3, uploadBatchSize: 2, uploadMaxInflightChunks: 6, batchFlushThreshold: 2, transferPersistence: 'localstorage-resumable-transfer-list', transferControls: { cancel: true, retry: true, pause: true, resume: true } },
      apps: [],
      windows: [],
      modules: []
    };
  }

  function defaultView() {
    return {
      summary: {
        headline: 'Production shell desktop',
        subheadline: '',
        theme: 'luna-blue',
        launcherLabel: 'Menu',
        windowManager: 'mioos-native-vue-css',
        authMode: 'anonymous',
        authenticated: false
      },
      documents: [],
      controlPanel: [],
      explorer: { currentFolderId: 'root', quickPlaces: [], preview: { enabled: true, mime: 'text/plain' } },
      terminal: {
        status: 'ready',
        transport: 'pipe',
        engine: 'xtermjs',
        renderer: 'canvas',
        sessionModel: 'multi-window-ydb-direct',
        headline: 'MIOOS YottaDB terminal ready',
        subheadline: '',
        profile: { fontFamily: 'Consolas', fontSize: 14, rows: 28, cols: 112 },
        sessions: []
      }
    };
  }

  function normalizeBoot(source) {
    var base = defaultBoot();
    var boot = source || {};
    base.product = Object.assign(base.product, boot.product || {});
    base.user = Object.assign(base.user, boot.user || {});
    if (!Array.isArray(base.user.roles)) base.user.roles = [];
    base.session = Object.assign(base.session, boot.session || {});
    base.locale = Object.assign(base.locale, boot.locale || {});
    base.i18n = Object.assign(base.i18n, boot.i18n || {});
    base.i18n.strings = Object.assign({}, base.i18n.strings || {}, (boot.i18n || {}).strings || {});
    base.routes = Object.assign(base.routes, boot.routes || {});
    base.desktop = Object.assign(base.desktop, boot.desktop || {});
    base.desktop.accessibility = Object.assign(base.desktop.accessibility, (boot.desktop || {}).accessibility || {});
    base.desktop.performance = Object.assign(base.desktop.performance, (boot.desktop || {}).performance || {});
    base.desktop.moduleSystem = Object.assign(base.desktop.moduleSystem, (boot.desktop || {}).moduleSystem || {});
    base.desktop.debugCenter = Object.assign(base.desktop.debugCenter || {}, (boot.desktop || {}).debugCenter || {});
    base.desktop.windowing = Object.assign(base.desktop.windowing, (boot.desktop || {}).windowing || {});
    base.desktop.appActions = Object.assign({}, (defaultBoot().desktop.appActions || {}), base.desktop.appActions || {}, (boot.desktop || {}).appActions || {});
    base.desktop.themeSystem = Object.assign({}, (defaultBoot().desktop.themeSystem || {}), base.desktop.themeSystem || {}, (boot.desktop || {}).themeSystem || {});
    base.desktop.shellSurfaces = Object.assign({}, (defaultBoot().desktop.shellSurfaces || {}), base.desktop.shellSurfaces || {}, (boot.desktop || {}).shellSurfaces || {});
    base.desktop.notifications = Object.assign({}, (defaultBoot().desktop.notifications || {}), base.desktop.notifications || {}, (boot.desktop || {}).notifications || {});
    base.desktop.dialogs = Object.assign({}, (defaultBoot().desktop.dialogs || {}), base.desktop.dialogs || {}, (boot.desktop || {}).dialogs || {});
    base.desktop.themes = Array.isArray((boot.desktop || {}).themes) && (boot.desktop || {}).themes.length ? deepClone((boot.desktop || {}).themes) : deepClone(defaultBoot().desktop.themes || []);
    base.auth = Object.assign(base.auth, boot.auth || {});
    base.auth.providers = Object.assign({}, (defaultBoot().auth.providers || {}), base.auth.providers || {}, (boot.auth || {}).providers || {});
    base.auth.providers.local = Object.assign({}, (defaultBoot().auth.providers || {}).local || {}, ((base.auth || {}).providers || {}).local || {}, (((boot.auth || {}).providers || {}).local || {}));
    base.auth.providers.framework = Object.assign({}, (defaultBoot().auth.providers || {}).framework || {}, ((base.auth || {}).providers || {}).framework || {}, (((boot.auth || {}).providers || {}).framework || {}));
    base.auth.lockout = Object.assign({}, (defaultBoot().auth.lockout || {}), base.auth.lockout || {}, (boot.auth || {}).lockout || {});
    base.auth.passwordPolicy = Object.assign({}, (defaultBoot().auth.passwordPolicy || {}), base.auth.passwordPolicy || {}, (boot.auth || {}).passwordPolicy || {});
    base.auth.audit = Object.assign({}, (defaultBoot().auth.audit || {}), base.auth.audit || {}, (boot.auth || {}).audit || {});
    base.auth.management = Object.assign({}, (defaultBoot().auth.management || {}), base.auth.management || {}, (boot.auth || {}).management || {});
    base.websocket = Object.assign(base.websocket || {}, boot.websocket || {});
    base.vfs = Object.assign(base.vfs, boot.vfs || {});
    base.terminal = Object.assign(base.terminal, boot.terminal || {});
    base.terminal.profile = Object.assign(base.terminal.profile, (boot.terminal || {}).profile || {});
    base.apps = Array.isArray(boot.apps) ? deepClone(boot.apps) : [];
    base.windows = Array.isArray(boot.windows) ? deepClone(boot.windows) : [];
    base.modules = Array.isArray(boot.modules) ? deepClone(boot.modules) : [];
    base.locale.supported = Array.isArray((boot.locale || {}).supported) ? deepClone(boot.locale.supported) : defaultLocales();
    return base;
  }

  function normalizeView(source) {
    var base = defaultView();
    var view = source || {};
    base.summary = Object.assign(base.summary, view.summary || {});
    base.documents = Array.isArray(view.documents) ? deepClone(view.documents) : [];
    base.controlPanel = Array.isArray(view.controlPanel) ? deepClone(view.controlPanel) : [];
    base.explorer = Object.assign(base.explorer, view.explorer || {});
    base.terminal = Object.assign(base.terminal, view.terminal || {});
    base.terminal.profile = Object.assign(base.terminal.profile, (view.terminal || {}).profile || {});
    base.terminal.sessions = Array.isArray((view.terminal || {}).sessions) ? deepClone(view.terminal.sessions) : [];
    return base;
  }

  window.MIOOSState = {
    deepClone: deepClone,
    defaultBoot: defaultBoot,
    defaultView: defaultView,
    normalizeBoot: normalizeBoot,
    normalizeView: normalizeView,
    getBootNode: function () { return document.getElementById('mioosBootJson'); },
    getRootNode: function () { return document.getElementById('mioosRoot'); }
  };
})();
