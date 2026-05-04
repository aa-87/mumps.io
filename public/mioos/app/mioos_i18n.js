(function () {
  function strings(app) {
    return (((app || {}).boot || {}).i18n || {}).strings || {};
  }

  window.MIOOSI18N = {
    t: function (app, key, fallback) {
      var dict = strings(app);
      return dict[key] || fallback || key;
    },
    localeOptions: function (app) {
      return ((((app || {}).boot || {}).locale || {}).supported || []).slice();
    },
    currentLocale: function (app) {
      return (((app || {}).boot || {}).locale || { code: 'en', dir: 'ltr', label: 'English', rtl: false });
    },
    applyDocumentLocale: function (app) {
      var locale = this.currentLocale(app);
      var root = window.MIOOSState && window.MIOOSState.getRootNode ? window.MIOOSState.getRootNode() : null;
      if (document && document.documentElement) {
        document.documentElement.setAttribute('lang', locale.code || 'en');
        document.documentElement.setAttribute('dir', locale.dir || 'ltr');
      }
      if (document && document.body) {
        document.body.setAttribute('dir', locale.dir || 'ltr');
      }
      if (root) {
        root.setAttribute('lang', locale.code || 'en');
        root.setAttribute('dir', locale.dir || 'ltr');
      }
    },
    changeLocale: function (app, code) {
      var locale;
      if (!code) return;
      code = String(code || '').toLowerCase();
      locale = (this.localeOptions(app) || []).filter(function (item) { return String(item.code || '').toLowerCase() === code; })[0] || { code: code, dir: code === 'ar' || code === 'he' || code === 'fa' || code === 'ur' ? 'rtl' : 'ltr', label: code, rtl: code === 'ar' || code === 'he' || code === 'fa' || code === 'ur' };
      if (app && app.boot) {
        app.boot.locale = Object.assign({}, app.boot.locale || {}, locale, { rtl: String(locale.dir || '').toLowerCase() === 'rtl' || !!locale.rtl });
        this.applyDocumentLocale(app);
      }
      try { document.cookie = 'mioos_lang=' + encodeURIComponent(code) + '; Path=/; SameSite=Lax'; } catch (cookieErr) {}
      try {
        var url = new window.URL(window.location.href);
        url.searchParams.set('lang', code);
        window.location.href = url.toString();
      } catch (err) {
        window.location.search = '?lang=' + encodeURIComponent(code);
      }
    }
  };
})();
