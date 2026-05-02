(function () {
  function root(vm) { return vm.$root || vm; }
  function clone(value) { try { return JSON.parse(JSON.stringify(value || {})); } catch (ignore) { return {}; } }

  var datasets = [
    { key: 'permissions', title: 'Permissions', kind: 'permission', tableId: 'permissions-admin-permissions' },
    { key: 'permission-groups', title: 'Permission Groups', kind: 'group', tableId: 'permissions-admin-groups' },
    { key: 'permission-profiles', title: 'Permission Profiles', kind: 'profile', tableId: 'permissions-admin-profiles' },
    { key: 'permission-assignments', title: 'Assignments', kind: 'assignment', tableId: 'permissions-admin-assignments' },
    { key: 'permission-audit', title: 'Audit Trail', kind: 'audit', tableId: 'permissions-admin-audit' }
  ];

  function datasetByKey(key) {
    return datasets.find(function (item) { return item.key === key; }) || datasets[0];
  }

  var methods = {
    permissionAdminDatasets: function () { return datasets.slice(); },
    permissionAdminDefaultForm: function () {
      return {
        key: '',
        name: '',
        description: '',
        category: 'Custom',
        phi: 0,
        sensitive: 0,
        minimumNecessary: 1,
        breakGlassAllowed: 0,
        principalType: 'user',
        principal: '',
        profileKey: 'minimum-necessary',
        reason: 'Administrative permission maintenance'
      };
    },
    openPermissionsWindow: function (options) {
      options = options || {};
      var id = 'win-permissions-' + Date.now();
      this.windows.push({ id: id, appKey: 'mioos.permissions.admin', title: options.title || 'Permissions', state: 'normal', left: 172, top: 88, width: 1120, height: 700, z: this.zCounter + 1, moduleWindow: true, moduleId: 'mioos.permissions.admin', moduleComponent: 'permissions', surface: 'mioos-surface-permissions' });
      this.focusWindow(id);
      return id;
    },
    permissionCommand: function (command, payload) {
      if (!this.command) return Promise.reject(new Error('permission_admin_requires_websocket'));
      return this.command(command, payload || {});
    },
    permissionUpsert: function (kind, form) {
      var self = this;
      var body = clone(form || {});
      body.kind = kind || body.kind || 'permission';
      return this.permissionCommand('permission.upsert', body).then(function (msg) {
        if (self.pushNotification) self.pushNotification('Permissions updated', body.kind + ': ' + (body.key || body.name || 'record'));
        return msg;
      });
    },
    permissionDelete: function (kind, key, reason) {
      return this.permissionCommand('permission.delete', { kind: kind, key: key, reason: reason || 'Administrative permission delete' });
    },
    permissionAssign: function (form) {
      var body = clone(form || {});
      return this.permissionCommand('permission.assign', { principalType: body.principalType || 'user', principal: body.principal, profileKey: body.profileKey, reason: body.reason || 'Administrative profile assignment' });
    },
    permissionEffective: function () { return this.permissionCommand('permission.effective', {}); },
    permissionTableReset: function (tableId) { return this.backendTableReset ? this.backendTableReset(tableId) : Promise.resolve(); },
    permissionSelectedKeys: function (tableId) {
      var state = this.backendTableState ? this.backendTableState(tableId) : null;
      return this.backendTableSelectedKeys ? this.backendTableSelectedKeys(state) : [];
    }
  };

  function register(app) {
    if (!app || !app.component) return;
    app.component('mioos-permissions-admin', {
      props: ['window'],
      data: function () { return { active: 'permissions', form: root(this).permissionAdminDefaultForm(), message: '' }; },
      computed: {
        vm: function () { return root(this); },
        datasets: function () { return this.vm.permissionAdminDatasets(); },
        activeDataset: function () { return datasetByKey(this.active); },
        activeTableId: function () { return this.activeDataset.tableId; },
        selectedKeys: function () { return this.vm.permissionSelectedKeys(this.activeTableId); },
        canEditRecord: function () { return ['permission', 'group', 'profile'].indexOf(this.activeDataset.kind) >= 0; },
        canAssign: function () { return this.activeDataset.kind === 'assignment'; }
      },
      methods: {
        switchDataset: function (key) { this.active = key; this.message = ''; },
        resetForm: function () { this.form = this.vm.permissionAdminDefaultForm(); },
        saveRecord: function () {
          var self = this;
          return this.vm.permissionUpsert(this.activeDataset.kind, this.form).then(function () {
            self.message = 'Saved ' + self.activeDataset.kind + ' ' + (self.form.key || self.form.name || 'record');
            return self.vm.backendTableFetch(self.activeTableId);
          }).catch(function (err) { self.message = (err && (err.detail || err.error || err.message)) || 'Save failed'; });
        },
        deleteSelected: function () {
          var self = this;
          var key = this.selectedKeys[0] || this.form.key;
          if (!key) { this.message = 'Select a row or enter a key first.'; return Promise.resolve(); }
          return this.vm.permissionDelete(this.activeDataset.kind, key, this.form.reason).then(function () {
            self.message = 'Deleted ' + key;
            return self.vm.backendTableFetch(self.activeTableId);
          }).catch(function (err) { self.message = (err && (err.detail || err.error || err.message)) || 'Delete failed'; });
        },
        assignProfile: function () {
          var self = this;
          return this.vm.permissionAssign(this.form).then(function () {
            self.message = 'Assigned ' + self.form.profileKey + ' to ' + self.form.principalType + ':' + self.form.principal;
            return self.vm.backendTableFetch('permissions-admin-assignments');
          }).catch(function (err) { self.message = (err && (err.detail || err.error || err.message)) || 'Assignment failed'; });
        },
        resetTable: function () { return this.vm.permissionTableReset(this.activeTableId); }
      },
      template: '' +
        '<section class="mioos-surface mioos-permissions-admin">' +
          '<header class="mioos-permissions-head"><div><strong>Permissions</strong><span>HIPAA-aligned access governance • WebSocket-only module commands • audited admin changes</span></div><button type="button" class="mioos-btn" @click="resetTable">Reset table</button></header>' +
          '<nav class="mioos-permissions-tabs" aria-label="Permission tables"><button v-for="tab in datasets" :key="tab.key" type="button" :class="{\'is-active\': active === tab.key}" @click="switchDataset(tab.key)">[[ tab.title ]]</button></nav>' +
          '<div class="mioos-permissions-body">' +
            '<mioos-full-table :table-id="activeTableId" :title="activeDataset.title" :dataset="activeDataset.key"></mioos-full-table>' +
            '<aside class="mioos-permissions-panel">' +
              '<strong>Admin Actions</strong>' +
              '<p>All actions use the core WebSocket command channel and write non-PHI audit records.</p>' +
              '<label><span>Key</span><input v-model="form.key" placeholder="permission/group/profile key"></label>' +
              '<label><span>Name</span><input v-model="form.name" placeholder="Display name"></label>' +
              '<label><span>Description</span><textarea v-model="form.description" rows="3" placeholder="Purpose and scope"></textarea></label>' +
              '<label><span>Category</span><input v-model="form.category" placeholder="Security, HIPAA, Module"></label>' +
              '<label><span>Principal Type</span><select v-model="form.principalType"><option>user</option><option>role</option></select></label>' +
              '<label><span>Principal</span><input v-model="form.principal" placeholder="username or role"></label>' +
              '<label><span>Profile Key</span><input v-model="form.profileKey" placeholder="minimum-necessary"></label>' +
              '<label><span>Reason</span><textarea v-model="form.reason" rows="2"></textarea></label>' +
              '<div class="mioos-permissions-checks"><label><input type="checkbox" v-model="form.phi" true-value="1" false-value="0"> PHI access</label><label><input type="checkbox" v-model="form.sensitive" true-value="1" false-value="0"> Sensitive</label><label><input type="checkbox" v-model="form.minimumNecessary" true-value="1" false-value="0"> Minimum necessary</label><label><input type="checkbox" v-model="form.breakGlassAllowed" true-value="1" false-value="0"> Break glass</label></div>' +
              '<div class="mioos-permissions-actions"><button type="button" class="mioos-btn" :disabled="!canEditRecord" @click="saveRecord">Add / Edit</button><button type="button" class="mioos-btn" :disabled="!canEditRecord" @click="deleteSelected">Delete selected</button><button type="button" class="mioos-btn" @click="assignProfile">Assign profile</button><button type="button" class="mioos-btn" @click="resetForm">Clear</button></div>' +
              '<output v-if="message">[[ message ]]</output>' +
            '</aside>' +
          '</div>' +
        '</section>'
    });

    app.component('mioos-surface-permissions', {
      props: ['window'],
      template: '<mioos-permissions-admin :window="window"></mioos-permissions-admin>'
    });
  }

  window.MIOOSPermissions = { methods: methods, register: register };
  if (window.MIOOSModules && typeof window.MIOOSModules.registerComponent === 'function') {
    window.MIOOSModules.registerComponent({ key: 'permissions', name: 'mioos-permissions-admin', title: 'Permissions Admin', surface: 'mioos-surface-permissions', source: 'internal', owner: 'MIOOS', transport: 'websocket-only', description: 'HIPAA-aligned permissions, groups, profiles, assignments, and audit administration using reusable tables.' });
    window.MIOOSModules.registerModule({ id: 'mioos.permissions.admin', key: 'mioos.permissions.admin', appKey: 'mioos.permissions.admin', title: 'Permissions', source: 'internal', category: 'Security', icon: '🛡', componentKey: 'permissions', surface: 'mioos-surface-permissions' });
  }
})();
