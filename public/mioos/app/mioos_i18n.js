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
      var dir = String(locale.dir || (locale.rtl ? 'rtl' : 'ltr') || 'ltr').toLowerCase();
      var isRtl = dir === 'rtl' || !!locale.rtl;
      if (document && document.documentElement) {
        document.documentElement.setAttribute('lang', locale.code || 'en');
        document.documentElement.setAttribute('dir', dir);
        document.documentElement.classList.toggle('is-rtl', isRtl);
      }
      if (document && document.body) {
        document.body.setAttribute('dir', dir);
        document.body.classList.toggle('is-rtl', isRtl);
      }
      if (root) {
        root.setAttribute('lang', locale.code || 'en');
        root.setAttribute('dir', dir);
        root.classList.toggle('is-rtl', isRtl);
        root.dataset.localeDir = dir;
        root.dataset.localeCode = locale.code || 'en';
      }
    },
    changeLocale: function (app, code) {
      var locale, runtimeCode, urlCode;
      if (!code) return;
      code = String(code || '').toLowerCase();
      runtimeCode = code === 'sp' ? 'es' : code;
      locale = (this.localeOptions(app) || []).filter(function (item) { return String(item.code || '').toLowerCase() === runtimeCode; })[0] || { code: runtimeCode, dir: runtimeCode === 'ar' || runtimeCode === 'he' || runtimeCode === 'fa' || runtimeCode === 'ur' ? 'rtl' : 'ltr', label: runtimeCode, rtl: runtimeCode === 'ar' || runtimeCode === 'he' || runtimeCode === 'fa' || runtimeCode === 'ur' };
      if (app && app.boot) {
        app.boot.locale = Object.assign({}, app.boot.locale || {}, locale, { rtl: String(locale.dir || '').toLowerCase() === 'rtl' || !!locale.rtl });
        this.applyDocumentLocale(app);
      }
      try { document.cookie = 'mioos_lang=' + encodeURIComponent(runtimeCode) + '; Path=/; SameSite=Lax'; } catch (cookieErr) {}
      try {
        if (window.sessionStorage) window.sessionStorage.setItem('mioos_lang', runtimeCode);
      } catch (storageErr) {}
      try {
        var url = new window.URL(window.location.href);
        if (runtimeCode === 'en') url.searchParams.delete('lang');
        else if (runtimeCode === 'es') url.searchParams.set('lang', 'sp');
        else url.searchParams.set('lang', runtimeCode);
        if (window.location && window.location.assign) {
          window.location.assign(url.pathname + url.search + url.hash);
          return;
        }
      } catch (urlErr) {}
      try {
        urlCode = runtimeCode === 'en' ? '' : (runtimeCode === 'es' ? 'sp' : runtimeCode);
        window.location.href = '/' + (urlCode ? '?lang=' + encodeURIComponent(urlCode) : '');
      } catch (fallbackErr) {}
    }

  };
})();
