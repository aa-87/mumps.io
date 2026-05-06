(function () {
  function safeJson(resp) {
    return resp.json().catch(function () { return {}; }).then(function (json) { return { ok: resp.ok, status: resp.status, json: json || {} }; });
  }

  function authMessageFor(result, fallback, serverFallback) {
    var json = (result || {}).json || {};
    var status = +(result || {}).status || 0;
    var code = String(json.error || json.detail || '').toLowerCase();
    if (status === 401 || code.indexOf('signin') >= 0 || code.indexOf('credential') >= 0 || code.indexOf('password') >= 0 || code.indexOf('invalid') >= 0) {
      return fallback || 'The username or password was rejected.';
    }
    if (status >= 500) return serverFallback || 'The sign-in service could not complete the request. Please try again.';
    return fallback || serverFallback || 'Sign-in could not be completed. Please try again.';
  }

  function reloadSoon() {
    window.setTimeout(function () { window.location.reload(); }, 180);
  }

  window.MIOOSAuth = {
    methods: {
      setAuthFeedback: function (kind, title, message) {
        this.authFeedback = { open: !!message, kind: kind || 'info', title: title || 'Sign in', message: message || '' };
      },
      clearAuthFeedback: function () {
        this.authFeedback = { open: false, kind: 'info', title: '', message: '' };
      },
      submitSignin: function () {
        var self = this;
        if (this.authBusy) return;
        this.authBusy = true;
        this.dismissAlert();
        this.setAuthFeedback('info', 'Sign in', 'Checking credentials…');
        window.fetch((this.boot.routes.publicSignin || this.boot.routes.signin), {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
          credentials: 'same-origin',
          body: JSON.stringify({ username: this.authForm.username, password: this.authForm.password })
        })
          .then(safeJson)
          .then(function (result) {
            if (!result.ok || !result.json || result.json.ok !== 1) {
              var err = new Error(authMessageFor(result, 'The username or password was rejected.', 'The sign-in service could not complete the request. Please try again.'));
              err.safeMessage = err.message;
              throw err;
            }
            if (result.json.requiresPasswordChange) {
              self.authPasswordChange.required = true;
              self.authPasswordChange.username = result.json.username || self.authForm.username || '';
              self.authPasswordChange.changeToken = result.json.changeToken || '';
              self.authPasswordChange.newPassword = '';
              self.authPasswordChange.confirmPassword = '';
              self.authPasswordChange.status = result.json.passwordStatus || {};
              self.authPasswordChange.policy = result.json.passwordPolicy || (((self.boot || {}).auth || {}).passwordPolicy) || {};
              self.authForm.password = '';
              self.setAuthFeedback('info', 'Password update required', 'Update your password to continue loading the shell.');
              return;
            }
            self.setAuthFeedback('success', 'Sign in accepted', 'Loading your desktop…');
            reloadSoon();
          })
          .catch(function (err) {
            var message = (err && err.safeMessage) || (err && err.name === 'TypeError' ? 'Network error while contacting the sign-in service. Please try again.' : 'Sign-in could not be completed. Please try again.');
            self.setAuthFeedback('error', 'Sign in failed', message);
          })
          .finally(function () {
            self.authBusy = false;
          });
      },
      submitGuestSignin: function () {
        var self = this;
        if (this.authBusy) return;
        this.authBusy = true;
        this.dismissAlert();
        this.setAuthFeedback('info', 'Guest sign in', 'Starting guest session…');
        window.fetch(this.boot.routes.guestSignin, {
          method: 'POST',
          headers: { Accept: 'application/json' },
          credentials: 'same-origin'
        })
          .then(safeJson)
          .then(function (result) {
            if (!result.ok || !result.json || result.json.ok !== 1) {
              var err = new Error(authMessageFor(result, 'Guest sign-in is not available.', 'Guest sign-in could not be completed. Please try again.'));
              err.safeMessage = err.message;
              throw err;
            }
            self.setAuthFeedback('success', 'Guest session ready', 'Loading your desktop…');
            reloadSoon();
          })
          .catch(function (err) {
            var message = (err && err.safeMessage) || (err && err.name === 'TypeError' ? 'Network error while contacting the sign-in service. Please try again.' : 'Guest sign-in could not be completed. Please try again.');
            self.setAuthFeedback('error', 'Guest sign in failed', message);
          })
          .finally(function () {
            self.authBusy = false;
          });
      },

      submitPasswordChange: function () {
        var self = this;
        if (this.authBusy) return;
        this.authBusy = true;
        this.dismissAlert();
        this.setAuthFeedback('info', 'Password update', 'Updating password…');
        window.fetch(this.boot.routes.passwordChange, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
          credentials: 'same-origin',
          body: JSON.stringify({
            changeToken: this.authPasswordChange.changeToken,
            newPassword: this.authPasswordChange.newPassword,
            confirmPassword: this.authPasswordChange.confirmPassword
          })
        })
          .then(safeJson)
          .then(function (result) {
            if (!result.ok || !result.json || result.json.ok !== 1) {
              var err = new Error(authMessageFor(result, 'Password update was rejected. Check the policy and try again.', 'Password update could not be completed. Please try again.'));
              err.safeMessage = err.message;
              throw err;
            }
            self.setAuthFeedback('success', 'Password updated', 'Loading your desktop…');
            reloadSoon();
          })
          .catch(function (err) {
            var message = (err && err.safeMessage) || (err && err.name === 'TypeError' ? 'Network error while contacting the sign-in service. Please try again.' : 'Password update could not be completed. Please try again.');
            self.setAuthFeedback('error', 'Password update failed', message);
          })
          .finally(function () {
            self.authBusy = false;
          });
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
        window.fetch(this.boot.routes.signout, {
          method: 'POST',
          headers: { Accept: 'application/json' },
          credentials: 'same-origin'
        })
          .then(function () {
            window.location.reload();
          })
          .catch(function () {
            self.showAlert(self.t('alerts.signoutFailed.title'), self.t('alerts.signoutFailed.message'));
          })
          .finally(function () {
            self.authBusy = false;
          });
      },
      showAlert: function (title, message) {
        this.alertTitle = title;
        this.alertMessage = message;
      },
      dismissAlert: function () {
        this.alertTitle = '';
        this.alertMessage = '';
      },
      refreshAuthSession: function () {
        var self = this;
        var route = (((this.boot || {}).routes || {}).authRefresh);
        if (!route) return Promise.resolve({ ok: 1, skipped: 1 });
        return window.fetch(route, {
          method: 'POST',
          headers: { Accept: 'application/json' },
          credentials: 'same-origin'
        }).then(function (resp) {
          return resp.json().catch(function () { return {}; }).then(function (json) {
            if (!resp.ok || !json || json.ok !== 1) {
              var err = new Error((json || {}).detail || (json || {}).error || 'auth_refresh_failed');
              err.code = (json || {}).detail || (json || {}).error || 'auth_refresh_failed';
              throw err;
            }
            return json;
          });
        });
      },
      handleExpiredAuth: function (message) {
        var self = this;
        var route = (((this.boot || {}).routes || {}).signout);
        var text = message || 'Your session expired. Please sign in again.';
        var done = function () {
          if (self.showAlert) self.showAlert(self.t('alerts.signinRequired.title', 'Sign in required'), text);
          window.setTimeout(function () { window.location.reload(); }, 250);
        };
        if (!route) { done(); return Promise.resolve(); }
        return window.fetch(route, {
          method: 'POST',
          headers: { Accept: 'application/json' },
          credentials: 'same-origin'
        }).catch(function () { return null; }).then(done);
      }
    }
  };
})();
