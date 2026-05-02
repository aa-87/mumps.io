(function () {
  function wsPreferred(vm) {
    var mode = String((((vm.boot || {}).transport || {}).mode) || (((vm.boot || {}).vfs || {}).transport) || 'websocket').toLowerCase();
    return mode !== 'http';
  }
  function httpFallback(vm) {
    var t = ((vm.boot || {}).transport || {});
    return t.httpFallback !== false && t.httpFallback !== 0;
  }
  function applyAuthCookie(auth) {
    auth = auth || {};
    if (auth.clearCookie) {
      document.cookie = encodeURIComponent(auth.cookieName || 'mioos_auth') + '=; Path=/; Max-Age=0; SameSite=Lax';
      return;
    }
    if (auth.token && auth.cookieName) {
      document.cookie = encodeURIComponent(auth.cookieName) + '=' + encodeURIComponent(auth.token) + '; Path=/; Max-Age=' + (+(auth.maxAgeSeconds || 604800)) + '; SameSite=Lax';
    }
  }
  function authCommand(vm, command, payload) {
    if (!wsPreferred(vm) || !vm.command) return Promise.reject(new Error('http_mode'));
    return vm.command(command, payload || {}).then(function (msg) {
      var auth = (msg && msg.auth) || {};
      if (auth.token || auth.clearCookie) applyAuthCookie(auth);
      return { ok: true, json: Object.assign({ ok: 1 }, auth) };
    });
  }
  function httpJson(url, opts) {
    return window.fetch(url, opts).then(function (resp) { return resp.json().then(function (json) { return { ok: resp.ok, json: json }; }); });
  }
  window.MIOOSAuth = {
    methods: {
      submitSignin: function () {
        var self = this;
        if (this.authBusy) return;
        this.authBusy = true;
        authCommand(this, 'auth.signin', { username: this.authForm.username, password: this.authForm.password })
          .catch(function (err) {
            if (!httpFallback(self)) throw err;
            return httpJson((self.boot.routes.publicSignin || self.boot.routes.signin), { method: 'POST', headers: { 'Content-Type': 'application/json', Accept: 'application/json' }, credentials: 'same-origin', body: JSON.stringify({ username: self.authForm.username, password: self.authForm.password }) });
          })
          .then(function (result) {
            if (!result.ok || !result.json || result.json.ok !== 1) throw new Error((result.json || {}).detail || (result.json || {}).error || self.t('alerts.signinFailed.message'));
            if (result.json.requiresPasswordChange) {
              self.authPasswordChange.required = true;
              self.authPasswordChange.username = result.json.username || self.authForm.username || '';
              self.authPasswordChange.changeToken = result.json.changeToken || '';
              self.authPasswordChange.newPassword = '';
              self.authPasswordChange.confirmPassword = '';
              self.authPasswordChange.status = result.json.passwordStatus || {};
              self.authPasswordChange.policy = result.json.passwordPolicy || (((self.boot || {}).auth || {}).passwordPolicy) || {};
              self.authForm.password = '';
              return;
            }
            window.location.reload();
          })
          .catch(function (err) { self.showAlert(self.t('alerts.signinFailed.title'), err.message || self.t('alerts.signinFailed.message')); })
          .finally(function () { self.authBusy = false; });
      },
      submitGuestSignin: function () {
        var self = this;
        if (this.authBusy) return;
        this.authBusy = true;
        authCommand(this, 'auth.guest', {})
          .catch(function (err) { if (!httpFallback(self)) throw err; return httpJson(self.boot.routes.guestSignin, { method: 'POST', headers: { Accept: 'application/json' }, credentials: 'same-origin' }); })
          .then(function (result) { if (!result.ok || !result.json || result.json.ok !== 1) throw new Error((result.json || {}).detail || (result.json || {}).error || self.t('alerts.guestSigninFailed.message')); window.location.reload(); })
          .catch(function (err) { self.showAlert(self.t('alerts.guestSigninFailed.title'), err.message || self.t('alerts.guestSigninFailed.message')); })
          .finally(function () { self.authBusy = false; });
      },
      submitPasswordChange: function () {
        var self = this;
        if (this.authBusy) return;
        this.authBusy = true;
        var payload = { changeToken: this.authPasswordChange.changeToken, newPassword: this.authPasswordChange.newPassword, confirmPassword: this.authPasswordChange.confirmPassword };
        authCommand(this, 'auth.password.change', payload)
          .catch(function (err) { if (!httpFallback(self)) throw err; return httpJson(self.boot.routes.passwordChange, { method: 'POST', headers: { 'Content-Type': 'application/json', Accept: 'application/json' }, credentials: 'same-origin', body: JSON.stringify(payload) }); })
          .then(function (result) { if (!result.ok || !result.json || result.json.ok !== 1) throw new Error((result.json || {}).detail || (result.json || {}).error || self.t('alerts.passwordChangeFailed.message')); window.location.reload(); })
          .catch(function (err) { self.showAlert(self.t('alerts.passwordChangeFailed.title'), err.message || self.t('alerts.passwordChangeFailed.message')); })
          .finally(function () { self.authBusy = false; });
      },
      passwordPolicyLines: function () {
        var policy = (((this.authPasswordChange || {}).policy) || (((this.boot || {}).auth || {}).passwordPolicy) || {});
        var lines = ['Minimum length: ' + (policy.minLength || 12)];
        if (policy.requireUpper) lines.push('Include an uppercase letter');
        if (policy.requireLower) lines.push('Include a lowercase letter');
        if (policy.requireDigit) lines.push('Include a digit');
        if (policy.requireSymbol) lines.push('Include a symbol');
        if (policy.maxAgeDays) lines.push('Rotate at least every ' + policy.maxAgeDays + ' days');
        return lines;
      },
      submitSignout: function () {
        var self = this;
        if (this.authBusy) return;
        this.authBusy = true;
        authCommand(this, 'auth.signout', {})
          .catch(function (err) { if (!httpFallback(self)) throw err; return window.fetch(self.boot.routes.signout, { method: 'POST', headers: { Accept: 'application/json' }, credentials: 'same-origin' }).then(function () { return { ok: true, json: { ok: 1 } }; }); })
          .then(function () { window.location.reload(); })
          .catch(function () { self.showAlert(self.t('alerts.signoutFailed.title'), self.t('alerts.signoutFailed.message')); })
          .finally(function () { self.authBusy = false; });
      },
      showAlert: function (title, message) { this.alertTitle = title; this.alertMessage = message; },
      dismissAlert: function () { this.alertTitle = ''; this.alertMessage = ''; },
      refreshAuthSession: function () { return Promise.resolve({ ok: 1, skipped: 1, transport: 'websocket' }); },
      handleExpiredAuth: function (message) {
        var self = this;
        var text = message || 'Your session expired. Please sign in again.';
        return authCommand(this, 'auth.signout', {}).catch(function () { return null; }).then(function () {
          if (self.showAlert) self.showAlert(self.t('alerts.signinRequired.title', 'Sign in required'), text);
          window.setTimeout(function () { window.location.reload(); }, 250);
        });
      }
    }
  };
})();
