(function () {
  function deepClone(value) {
    if (window.MIOOSState && typeof window.MIOOSState.deepClone === 'function') {
      return window.MIOOSState.deepClone(value || {});
    }
    return JSON.parse(JSON.stringify(value || {}));
  }

  function statusMessage(err, fallback) {
    if (!err) return fallback || 'Unable to save theme';
    return err.detail || err.error || err.message || fallback || 'Unable to save theme';
  }

  window.MIOOSTheme = {
    methods: {
      themeStudioLoadCommandName: function () {
        return ((((this.boot || {}).routes || {}).themeLoadCommand) || 'desktop.theme.load');
      },
      themeStudioSaveCommandName: function () {
        return ((((this.boot || {}).routes || {}).themeSaveCommand) || 'desktop.theme.save');
      },
      themeStudioStatusText: function () {
        var state = this.themeStudioStatus || {};
        return state.message || 'Theme ready';
      },
      themeStudioStorageKey: function () {
        return '';
      },
      themeStudioProfilesKey: function () {
        return '';
      },
      themeStudioServerThemeKey: function () {
        return ((((this.boot || {}).desktop || {}).themeKey) || 'xp-classic-blue');
      },
      themeStudioServerProfile: function () {
        return ((((this.boot || {}).desktop || {}).themeProfile) || null);
      },
      initThemeStudioStore: function () {
        var store = this.themeStudioStore || {};
        var presets, serverProfile, quickMap, fallbackId, normalized;
        if (store.initialized) return store;
        store.initialized = true;
        store.themes = {};
        store.order = [];
        store.customThemes = [];
        store.activeTab = store.activeTab || 'themes';
        if (!store.previewTab) store.previewTab = 'desktop';
        store.previewWindowState = this.themeStudioDefaultPreviewWindow();
        store.importBuffer = '';
        presets = this.themeStudioBaseThemeConfigs();
        Object.keys(presets || {}).forEach(function (id) {
          store.themes[id] = this.themeStudioNormalizeConfig(presets[id]);
          store.order.push(id);
        }.bind(this));
        serverProfile = this.themeStudioServerProfile();
        if (serverProfile && Object.keys(serverProfile).length) {
          normalized = this.themeStudioNormalizeConfig(serverProfile);
          normalized.locked = false;
          store.themes[normalized.id] = normalized;
          if (store.order.indexOf(normalized.id) < 0) store.order.push(normalized.id);
          if (store.customThemes.indexOf(normalized.id) < 0) store.customThemes.push(normalized.id);
          store.activeThemeId = normalized.id;
        } else {
          quickMap = this.shellThemeQuickMap ? this.shellThemeQuickMap() : {};
          fallbackId = quickMap[String(this.themeStudioServerThemeKey() || '')] || 'glow';
          if (!store.themes[fallbackId]) fallbackId = 'glow';
          store.activeThemeId = fallbackId;
        }
        this.themeStudioStore = store;
        return store;
      },
      applyPersistedThemeStudioProfile: function () {
        var store = this.initThemeStudioStore();
        var theme = this.themeStudioThemeById(store.activeThemeId) || this.themeStudioThemeById('glow');
        if (!theme) return null;
        return this.applyThemeStudioConfig(theme, { silent: true, persist: false, source: 'boot' });
      },
      themeStudioServerPayload: function (theme) {
        var out = this.themeStudioNormalizeConfig(theme || this.themeStudioActiveTheme() || {});
        out = deepClone(out);
        delete out.locked;
        return out;
      },
      saveThemeStudioProfileToServer: function (reason) {
        var self = this;
        var payload = this.themeStudioServerPayload();
        var themeKey = this.activeThemeKey || payload.id || this.themeStudioServerThemeKey();
        if (!this.command || this.requiresSignin) {
          this.themeStudioStatus = { state: 'idle', message: this.requiresSignin ? 'Sign in to save theme' : 'Theme ready' };
          return Promise.resolve(payload);
        }
        this.themeStudioStatus = { state: 'saving', message: reason === 'apply' ? 'Applying theme…' : 'Saving theme…' };
        return this.command(this.themeStudioSaveCommandName(), {
          themeKey: themeKey,
          theme: payload
        }).then(function (msg) {
          var desktop = (msg && msg.desktop) || {};
          var current = desktop.current || payload;
          if (self.boot && self.boot.desktop) {
            self.boot.desktop.themeKey = desktop.themeKey || themeKey;
            self.boot.desktop.themeProfile = deepClone(current);
          }
          self.activeThemeKey = desktop.themeKey || themeKey;
          self.appliedThemeProfile = deepClone(current);
          self.themeStudioStatus = { state: 'saved', message: 'Saved to profile' };
          return desktop;
        }).catch(function (err) {
          self.themeStudioStatus = { state: 'error', message: statusMessage(err, 'Theme save failed') };
          throw err;
        });
      },
      themeStudioPersistCustomThemes: function (immediate) {
        var self = this;
        var commit = function () {
          self._themeStudioPersistTimer = null;
          return self.saveThemeStudioProfileToServer('save').catch(function () { return null; });
        };
        if (this._themeStudioPersistTimer) {
          window.clearTimeout(this._themeStudioPersistTimer);
          this._themeStudioPersistTimer = null;
        }
        if (immediate) return commit();
        this.themeStudioStatus = { state: 'saving', message: 'Saving theme…' };
        this._themeStudioPersistTimer = window.setTimeout(commit, 220);
      },
      applyShellTheme: function (themeKey) {
        var profile = this.shellThemeProfile(themeKey);
        if (!profile) return;
        this.themeStudioActivate(profile.id, { persist: true, silent: false, immediate: true, reason: 'apply' });
      },
      applyThemeStudioConfig: function (config, options) {
        var rootNode = this.themeStudioRootNode();
        var opts = options || {};
        var theme = this.themeStudioNormalizeConfig(config || this.themeStudioActiveTheme() || {});
        var styleNode = this.themeStudioEnsureStyleNode();
        var body = document.body;
        var current, taskbarHeightPx, loginCfg, loginStyle;
        if (!rootNode) return theme;
        current = this.themeStudioResolvedVars(theme);
        (this._themeStudioAppliedKeys || this.themeStudioManagedVarKeys()).forEach(function (key) { rootNode.style.removeProperty(key); });
        taskbarHeightPx = ((theme.taskbarConfig || {}).height || parseInt(current['--taskbar-height'] || '48', 10) || 48) + 'px';
        current['--taskbar-height'] = taskbarHeightPx;
        current['--taskbar-position'] = (theme.taskbarConfig || {}).position || 'bottom';
        current['--start-menu-width'] = ((((theme.startMenuConfig || {}).width) || 360) + 'px');
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
        current['--desktop-icon-size-mobile'] = ((((theme.mobileConfig || {}).iconSizeMobile) || 60) + 'px');
        current['--taskbar-height-mobile'] = ((((theme.mobileConfig || {}).taskbarHeightMobile) || 46) + 'px');
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
        if (this.boot && this.boot.desktop) {
          this.boot.desktop.themeKey = theme.id;
          this.boot.desktop.themeProfile = this.themeStudioClone(theme);
          if (this.boot.desktop.windowing) this.boot.desktop.windowing.taskbarHeight = parseInt(taskbarHeightPx, 10) || 48;
          this.boot.desktop.taskbarPosition = (theme.taskbarConfig || {}).position || 'bottom';
        }
        if (!opts.silent) this.showAlert('Theme Studio', (theme.name || 'Theme') + ' applied.');
        if (opts.persist) this.themeStudioPersistCustomThemes(!!opts.immediate);
        return theme;
      },
      themeStudioActivate: function (id, options) {
        var store = this.initThemeStudioStore();
        var opts = options || {};
        if (!store.themes[id]) return;
        store.activeThemeId = id;
        this.applyThemeStudioConfig(store.themes[id], {
          silent: opts.silent !== undefined ? opts.silent : true,
          persist: opts.persist !== undefined ? opts.persist : false,
          immediate: !!opts.immediate
        });
      },
      themeStudioApplyToDesktop: function (id) {
        var target = this.themeStudioThemeById(id || ((this.themeStudioStore || {}).activeThemeId));
        if (!target) return;
        this.themeStudioActivate(target.id, { persist: true, silent: false, immediate: true, reason: 'apply' });
      },
      themeStudioSaveCustomTheme: function () {
        var target = this.themeStudioEditableTheme();
        if (!target) return;
        this.applyThemeStudioConfig(target, { silent: false, persist: true, immediate: true });
      }
    }
  };
})();
