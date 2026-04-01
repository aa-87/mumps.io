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
      user: { id: 'guest', displayName: 'Guest', authenticated: false, roles: [] },
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
        }
      },
      auth: { enabled: false, required: false, guestLoginEnabled: false, mode: 'anonymous' },
      explorer: {
        headline: 'Global-backed explorer',
        subheadline: 'Browse the MIOOS virtual file system backed entirely by globals.',
        rootId: 'root',
        homeId: 'root'
      },
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
      apps: [],
      windows: []
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
      explorer: {
        headline: 'Global-backed explorer',
        subheadline: 'Browse the MIOOS virtual file system backed entirely by globals.',
        rootId: 'root',
        homeId: 'root'
      },
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
    base.auth = Object.assign(base.auth, boot.auth || {});
    base.terminal = Object.assign(base.terminal, boot.terminal || {});
    base.terminal.profile = Object.assign(base.terminal.profile, (boot.terminal || {}).profile || {});
    base.apps = Array.isArray(boot.apps) ? deepClone(boot.apps) : [];
    base.windows = Array.isArray(boot.windows) ? deepClone(boot.windows) : [];
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
