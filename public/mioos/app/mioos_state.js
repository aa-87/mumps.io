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
        debugSnapshotCommand: 'debug.snapshot',
        websocket: '/ws/mioos',
        terminalWebsocket: '/ws/mioos/terminal',
        commandEvent: 'desktop.command',
        commandResultEvent: 'desktop.result',
        commandErrorEvent: 'desktop.error'
      },
      desktop: {
        themeKey: 'foundation-light',
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
          transport: 'websocket-first-http-refresh',
          uploadPreparation: 'blob-slice-no-base64',
          uploadStrategy: 'http-binary-parallel-slice-xhr-with-auto-pause',
          uploadFinalizeStrategy: 'binary-direct-stage-promote-with-copy-on-overwrite',
          transferPersistence: 'localstorage-resumable-transfer-list',
          downloadStrategy: 'direct-http-range-native',
          downloadSendStrategy: 'vfs-segment-streaming-http-blob',
          mediaStreamStrategy: 'range-kickstart-http-blob-partial-window',
          textPreviewStrategy: 'windowed-websocket-range-read'
        },
        moduleSystem: { enabled: true, launcher: 'desktop-icons-and-menu', manifestVersion: 1, appCatalogEnabled: true, appCatalogKey: 'app-catalog', dynamicWindows: true, debugAppKey: 'debug-center' },
        debugCenter: { enabled: true, eventLimit: 50, snapshotVersion: 1 },
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
        },
        themeSystem: { version: 2, editor: 'theme-studio', persistence: 'localstorage-applied-profile', liveApply: true, quickSwitch: true, densityOptions: ['compact', 'comfortable', 'spacious'] },
        shellSurfaces: { explorer: true, themeStudio: true, transfers: true, diagnostics: true, securityCenter: true, appCatalog: true, debugCenter: true, moduleWindows: true, notifications: true, dialogs: true },
        appSurfaceModel: 'shell-standard-actions',
        appActions: { confirmBeforeDestructive: true, notifyOnAdminActions: true, copyExportsToClipboard: true, moduleNotesSessionLocal: true },
        notifications: { model: 'toast-and-tray', stackLimit: 6, tray: true },
        dialogs: { model: 'shell-standard', confirm: true, input: true },
        themes: [
          { key: 'foundation-light', title: 'Foundation Light', family: 'Foundation', mode: 'light', wallpaper: 'aurora', accent: '#2f6fed', taskbar: '#e8eef8' },
          { key: 'foundation-dark', title: 'Foundation Dark', family: 'Foundation', mode: 'dark', wallpaper: 'aurora-night', accent: '#7db4ff', taskbar: '#111a28' },
          { key: 'glass-light', title: 'Glass Light', family: 'Glass', mode: 'light', wallpaper: 'aurora', accent: '#4687ff', taskbar: '#dce7f7' },
          { key: 'glass-dark', title: 'Glass Dark', family: 'Glass', mode: 'dark', wallpaper: 'aurora-night', accent: '#8ac5ff', taskbar: '#0f1724' },
          { key: 'contrast-light', title: 'Contrast Light', family: 'Contrast', mode: 'light', wallpaper: 'solid-graphite', accent: '#1142aa', taskbar: '#ffffff' },
          { key: 'contrast-dark', title: 'Contrast Dark', family: 'Contrast', mode: 'dark', wallpaper: 'solid-graphite', accent: '#ffd043', taskbar: '#0b1017' }
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
      vfs: { enabled: false, rootId: 'root', homeId: 'home', chunkSize: 131072, httpChunkBytes: 131072, readPreviewBytes: 262144, readWindowBytes: 262144, mediaInitialBytes: 262144, mediaWarmupBytes: 65536, globalsOnly: true, uploadStaleSeconds: 1800, downloadStaleSeconds: 900, uploadChunkBytes: 860000, uploadConcurrency: 3, transferPersistence: 'localstorage-resumable-transfer-list', transferControls: { cancel: true, retry: true, pause: true, resume: true } },
      apps: [],
      windows: [],
      modules: []
    };
  }

  function defaultView() {
    return {
      summary: {
        headline: 'Production shell workspace',
        subheadline: '',
        theme: 'foundation-light',
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
    base.desktop.themeSystem = Object.assign({}, (defaultBoot().desktop.themeSystem || {}), base.desktop.themeSystem || {}, (boot.desktop || {}).themeSystem || {});
    base.desktop.shellSurfaces = Object.assign({}, (defaultBoot().desktop.shellSurfaces || {}), base.desktop.shellSurfaces || {}, (boot.desktop || {}).shellSurfaces || {});
    base.desktop.appSurfaceModel = (boot.desktop || {}).appSurfaceModel || base.desktop.appSurfaceModel || (defaultBoot().desktop.appSurfaceModel || 'shell-standard-actions');
    base.desktop.appActions = Object.assign({}, (defaultBoot().desktop.appActions || {}), base.desktop.appActions || {}, (boot.desktop || {}).appActions || {});
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
