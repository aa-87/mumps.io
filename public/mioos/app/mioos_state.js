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
        signout: '/api/mioos/auth/signout',
        guestSignin: '/api/mioos/auth/guest',
        auditExport: '/api/mioos/auth/audit/export',
        websocket: '/ws/mioos',
        terminalWebsocket: '/ws/mioos/terminal',
        commandEvent: 'desktop.command',
        commandResultEvent: 'desktop.result',
        commandErrorEvent: 'desktop.error'
      },
      desktop: {
        themeKey: 'xp-classic-blue',
        wallpaper: 'bliss',
        density: 'comfortable',
        fontFamily: 'Segoe UI',
        fontSize: 13,
        launcherLabel: 'Menu',
        shellChrome: 'winxp-professional',
        taskbarStyle: 'xp-professional',
        startMenuStyle: 'xp-two-column',
        windowManager: 'mioos-native-vue-css',
        commandTransport: 'websocket-only',
        realtimeContract: 'core-websocket-plus-app-websockets',
        themes: [],
        accessibility: {
          rtl: false,
          keyboardModel: 'desktop-first',
          screenReaderHints: 1,
          motionPreference: 'respect-user-preference'
        },
        performance: {
          clientModel: 'thin-vue-umd',
          renderBudgetMs: 16,
          payloadMode: 'tmp-global-safe',
          transport: 'websocket-first-http-refresh'
        },
        moduleSystem: { enabled: true, launcher: 'desktop-icons-and-menu', manifestVersion: 1, appCatalogEnabled: true, appCatalogKey: 'app-catalog', dynamicWindows: true, debugAppKey: 'debug-center' },
        icons: {
          enabled: true,
          draggable: true,
          size: 'medium',
          sizeOptions: ['small', 'medium', 'large'],
          sortMode: 'manual'
        },
        contextMenu: {
          desktop: true,
          icon: true,
          verbs: ['refresh', 'rearrange', 'sort-name', 'sort-type', 'size-small', 'size-medium', 'size-large', 'personalize', 'control-panel', 'open']
        },
        windowing: {
          engine: 'mioos-native-vue-css',
          snapThreshold: 28,
          taskbarHeight: 40,
          minWidth: 320,
          minHeight: 220,
          animations: 'subtle',
          resizeHandles: 'all-edges-and-corners',
          snapModel: 'edges-and-corners',
          doubleClickTitlebar: 1,
          dropUpload: 1
        }
      },
      auth: { enabled: true, required: true, guestLoginEnabled: false, mode: 'local-session-required', unauthenticatedAccessAllowed: false, providers: { local: { enabled: true, loginMode: 'username-password', guestAllowed: false }, framework: { enabled: true, mode: 'mioauth-session-jwt', tokenType: 'jwt', sessionCookie: 'mioos_auth' } }, lockout: { threshold: 5, minutes: 15 }, audit: { enabled: true, retainDays: 365, reportLimit: 20, reportWindowDays: 30, scope: 'self' } },
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
        maxSocketsPerSession: 6,
        coreSockets: 1,
        fsSockets: 5,
        uploadBatchSize: 1,
        heartbeatSeconds: 15,
        resumeWindowSeconds: 180,
        maxInflightPerChannel: 4,
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
      vfs: { enabled: false, rootId: 'root', homeId: 'home', chunkSize: 32000, globalsOnly: true, uploadStaleSeconds: 1800, downloadStaleSeconds: 900, transferControls: { cancel: true, retry: true } },
      apps: [],
      windows: [],
      modules: []
    };
  }

  function defaultView() {
    return {
      summary: {
        headline: 'Production shell foundation',
        subheadline: '',
        theme: 'xp-classic-blue',
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
    base.desktop.windowing = Object.assign(base.desktop.windowing, (boot.desktop || {}).windowing || {});
    base.auth = Object.assign(base.auth, boot.auth || {});
    base.auth.providers = Object.assign({}, (defaultBoot().auth.providers || {}), base.auth.providers || {}, (boot.auth || {}).providers || {});
    base.auth.providers.local = Object.assign({}, (defaultBoot().auth.providers || {}).local || {}, ((base.auth || {}).providers || {}).local || {}, (((boot.auth || {}).providers || {}).local || {}));
    base.auth.providers.framework = Object.assign({}, (defaultBoot().auth.providers || {}).framework || {}, ((base.auth || {}).providers || {}).framework || {}, (((boot.auth || {}).providers || {}).framework || {}));
    base.auth.lockout = Object.assign({}, (defaultBoot().auth.lockout || {}), base.auth.lockout || {}, (boot.auth || {}).lockout || {});
    base.auth.audit = Object.assign({}, (defaultBoot().auth.audit || {}), base.auth.audit || {}, (boot.auth || {}).audit || {});
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
