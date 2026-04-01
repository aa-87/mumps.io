(function () {
  window.MIOOSAuth = {
    methods: {
      submitSignin: function () {
        var self = this;
        if (this.authBusy) return;
        this.authBusy = true;
        window.fetch(this.boot.routes.signin, {
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
      }
    }
  };
})();
