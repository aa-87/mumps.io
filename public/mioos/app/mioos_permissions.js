(function () {
  function root(vm) { return vm.$root || vm; }
  var methods = {
    permissionsState: function () {
      if (!this.permissionsUi) {
        this.permissionsUi = {
          tab: 'overview',
          principals: [
            { id: 'owner', label: 'Owner', read: true, write: true, delete: true, admin: true },
            { id: 'admin', label: 'Administrators', read: true, write: true, delete: true, admin: true },
            { id: 'user', label: 'Users', read: true, write: false, delete: false, admin: false },
            { id: 'guest', label: 'Guests', read: false, write: false, delete: false, admin: false }
          ],
          audit: [
            { at: 'boot', actor: 'system', action: 'Loaded permission model', target: 'owner-role-flags' },
            { at: 'sample', actor: 'admin', action: 'Reviewed access policy', target: '/Home/Desktop' }
          ]
        };
      }
      return this.permissionsUi;
    },
    permissionsSetTab: function (tab) { this.permissionsState().tab = tab || 'overview'; },
    permissionsToggle: function (principal, key) { if (principal && key) principal[key] = !principal[key]; }
  };
  function register(app) {
    if (!app || !app.component) return;
    app.component('mioos-surface-permissions', {
      props: ['window'],
      computed: { vm: function () { return root(this); }, state: function () { return this.vm.permissionsState(); } },
      template: '' +
        '<section class="mioos-surface mioos-permissions-ui">' +
          '<header class="mioos-permissions-head"><div><strong>Permissions</strong><span>Owner, role, and file capability flags for MIOOS modules.</span></div></header>' +
          '<nav class="mioos-permissions-tabs" role="tablist"><button type="button" :class="{active: state.tab === \'overview\'}" @click="vm.permissionsSetTab(\'overview\')">Overview</button><button type="button" :class="{active: state.tab === \'matrix\'}" @click="vm.permissionsSetTab(\'matrix\')">Matrix</button><button type="button" :class="{active: state.tab === \'audit\'}" @click="vm.permissionsSetTab(\'audit\')">Audit</button></nav>' +
          '<article v-if="state.tab === \'overview\'" class="mioos-permissions-panel"><h3>Permission model</h3><p>MIOOS uses owner-role-flags permissions on VFS-backed resources. Modules should request the narrowest capability and let the backend enforce access.</p><div class="mioos-permissions-cards"><section><strong>Read</strong><span>View metadata and content.</span></section><section><strong>Write</strong><span>Create and modify records.</span></section><section><strong>Delete</strong><span>Remove records or files.</span></section><section><strong>Admin</strong><span>Change ownership or grants.</span></section></div></article>' +
          '<article v-if="state.tab === \'matrix\'" class="mioos-permissions-panel"><table class="mioos-permissions-table"><thead><tr><th>Principal</th><th>Read</th><th>Write</th><th>Delete</th><th>Admin</th></tr></thead><tbody><tr v-for="principal in state.principals" :key="principal.id"><td><strong>[[ principal.label ]]</strong><small>[[ principal.id ]]</small></td><td><input type="checkbox" :checked="principal.read" @change="vm.permissionsToggle(principal, \'read\')"></td><td><input type="checkbox" :checked="principal.write" @change="vm.permissionsToggle(principal, \'write\')"></td><td><input type="checkbox" :checked="principal.delete" @change="vm.permissionsToggle(principal, \'delete\')"></td><td><input type="checkbox" :checked="principal.admin" @change="vm.permissionsToggle(principal, \'admin\')"></td></tr></tbody></table></article>' +
          '<article v-if="state.tab === \'audit\'" class="mioos-permissions-panel"><ul class="mioos-permissions-audit"><li v-for="entry in state.audit" :key="entry.at + entry.action"><strong>[[ entry.action ]]</strong><span>[[ entry.actor ]] • [[ entry.target ]] • [[ entry.at ]]</span></li></ul></article>' +
        '</section>'
    });
  }
  window.MIOOSPermissions = { methods: methods, register: register };
  if (window.MIOOSModules && typeof window.MIOOSModules.registerComponent === 'function') {
    window.MIOOSModules.registerComponent({ key: 'permissions', name: 'mioos-surface-permissions', title: 'Permissions UI', surface: 'mioos-surface-permissions', description: 'Permission matrix, access policy, and audit sample for modules.' });
  }
})();
