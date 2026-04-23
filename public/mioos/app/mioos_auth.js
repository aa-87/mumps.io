(function () {
  window.MIOOSAuth = {
    methods: {
      submitSignin: function () {
        var self = this;
        if (this.authBusy) return;
        this.authBusy = true;
        window.fetch((this.boot.routes.publicSignin || this.boot.routes.signin), {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
          credentials: 'same-origin',
          body: JSON.stringify({ username: this.authForm.username, password: this.authForm.password })
        })
          .then(function (resp) { return resp.json().then(function (json) { return { ok: resp.ok, json: json }; }); })
          .then(function (result) {
            if (!result.ok || !result.json || result.json.ok !== 1) {
              throw new Error((result.json || {}).detail || (result.json || {}).error || self.t('alerts.signinFailed.message'));
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
              return;
            }
            window.location.reload();
          })
          .catch(function (err) {
            self.showAlert(self.t('alerts.signinFailed.title'), err.message || self.t('alerts.signinFailed.message'));
          })
          .finally(function () {
            self.authBusy = false;
          });
      },
      submitGuestSignin: function () {
        var self = this;
        if (this.authBusy) return;
        this.authBusy = true;
        window.fetch(this.boot.routes.guestSignin, {
          method: 'POST',
          headers: { Accept: 'application/json' },
          credentials: 'same-origin'
        })
          .then(function (resp) { return resp.json().then(function (json) { return { ok: resp.ok, json: json }; }); })
          .then(function (result) {
            if (!result.ok || !result.json || result.json.ok !== 1) {
              throw new Error((result.json || {}).detail || (result.json || {}).error || self.t('alerts.guestSigninFailed.message'));
            }
            window.location.reload();
          })
          .catch(function (err) {
            self.showAlert(self.t('alerts.guestSigninFailed.title'), err.message || self.t('alerts.guestSigninFailed.message'));
          })
          .finally(function () {
            self.authBusy = false;
          });
      },

      submitPasswordChange: function () {
        var self = this;
        if (this.authBusy) return;
        this.authBusy = true;
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
          .then(function (resp) { return resp.json().then(function (json) { return { ok: resp.ok, json: json }; }); })
          .then(function (result) {
            if (!result.ok || !result.json || result.json.ok !== 1) {
              throw new Error((result.json || {}).detail || (result.json || {}).error || self.t('alerts.passwordChangeFailed.message'));
            }
            window.location.reload();
          })
          .catch(function (err) {
            self.showAlert(self.t('alerts.passwordChangeFailed.title'), err.message || self.t('alerts.passwordChangeFailed.message'));
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
        this.alertTitle = '';
        this.alertMessage = '';
        if (this.pushNotification) this.pushNotification('alert', title, message, { sticky: true });
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
