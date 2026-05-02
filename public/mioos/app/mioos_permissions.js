(function () {
  function root(vm) { return vm.$root || vm; }

  function clone(value) {
    try { return JSON.parse(JSON.stringify(value || {})); } catch (ignore) { return {}; }
  }

  function route(vm, key, fallback) {
    return (((root(vm).boot || {}).routes || {})[key]) || fallback;
  }

  function postJson(url, body) {
    return fetch(url, {
      method: 'POST',
      credentials: 'same-origin',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body || {})
    }).then(function (res) {
      return res.json().then(function (obj) {
        if (!res.ok || (obj && obj.ok === 0)) throw new Error((obj && (obj.detail || obj.error)) || ('HTTP ' + res.status));
        return obj || {};
      });
    });
  }

  function formFromMeta(meta) {
    meta = meta || {};
    return {
      id: meta.id || '',
      readOnly: +(((meta.attributes || {}).readOnly) || 0),
      hidden: +(((meta.attributes || {}).hidden) || 0),
      shared: +(((meta.attributes || {}).shared) || 0),
      scope: ((meta.sharing || {}).scope) || 'private',
      users: ((meta.sharing || {}).users) || '',
      viewMode: meta.viewMode || 'details',
      sortBy: meta.sortBy || 'name',
      sortDirection: meta.sortDirection || 'ascending'
    };
  }

  var methods = {};

  function register(app) {
    if (!app || !app.component) return;
    app.component('mioos-permissions-panel', {
      props: ['window'],
      data: function () {
        var boot = (root(this).boot || {});
        var vfs = boot.vfs || {};
        return {
          targetId: ((this.window || {}).permissionsState || {}).id || vfs.homeId || vfs.rootId || 'root',
          activeTab: 'summary',
          loading: false,
          saving: false,
          error: '',
          status: '',
          meta: null,
          form: formFromMeta(null)
        };
      },
      computed: {
        vm: function () { return root(this); },
        tabs: function () {
          return [
            { key: 'summary', label: 'Summary' },
            { key: 'attributes', label: 'Attributes' },
            { key: 'sharing', label: 'Sharing' },
            { key: 'folder', label: 'Folder defaults' }
          ];
        },
        isFolder: function () { return (this.meta || {}).kind === 'folder'; },
        identityLine: function () {
          var meta = this.meta || {};
          return (meta.name || meta.path || this.targetId || 'Item') + ' • owner ' + (meta.owner || 'unknown') + ' • roles ' + (meta.roles || 'none');
        }
      },
      mounted: function () { this.load(); },
      methods: {
        setTab: function (key) { this.activeTab = key || 'summary'; },
        load: function () {
          var self = this;
          this.loading = true;
          this.error = '';
          this.status = '';
          return postJson(route(this, 'fsMeta', '/api/mioos/fs/meta'), { id: this.targetId, path: this.targetId })
            .then(function (meta) {
              self.meta = meta;
              self.targetId = meta.id || self.targetId;
              self.form = formFromMeta(meta);
              self.status = 'Loaded metadata for ' + (meta.path || meta.name || meta.id);
              return meta;
            })
            .catch(function (err) {
              self.error = (err && err.message) || 'Unable to load permissions metadata';
            })
            .finally(function () { self.loading = false; });
        },
        save: function () {
          var self = this;
          var payload = {
            id: this.targetId,
            attributes: {
              readOnly: this.form.readOnly ? 1 : 0,
              hidden: this.form.hidden ? 1 : 0,
              shared: this.form.shared ? 1 : 0
            },
            sharing: {
              scope: this.form.shared ? (this.form.scope || 'users') : 'private',
              users: this.form.shared ? (this.form.users || '') : ''
            },
            viewMode: this.form.viewMode,
            sortBy: this.form.sortBy,
            sortDirection: this.form.sortDirection
          };
          this.saving = true;
          this.error = '';
          this.status = '';
          return postJson(route(this, 'fsSetMeta', '/api/mioos/fs/setmeta'), payload)
            .then(function (meta) {
              self.meta = meta;
              self.form = formFromMeta(meta);
              self.status = 'Saved permissions for ' + (meta.path || meta.name || meta.id);
              return meta;
            })
            .catch(function (err) {
              self.error = (err && err.message) || 'Unable to save permissions metadata';
            })
            .finally(function () { self.saving = false; });
        },
        resetForm: function () { this.form = formFromMeta(this.meta); }
      },
      template: '' +
        '<section class="mioos-permissions-panel mioos-surface">' +
          '<header class="mioos-permissions-head"><div><strong>Permissions UI</strong><span>VFS owner, sharing, attributes, and folder defaults</span></div><button type="button" class="mioos-btn" @click="load" :disabled="loading">Refresh</button></header>' +
          '<div class="mioos-permissions-target"><label><span>Target ID or path</span><input v-model="targetId" @keydown.enter="load" placeholder="root, home, fs-... or /Home"></label><button type="button" class="mioos-btn" @click="load" :disabled="loading">Load</button></div>' +
          '<nav class="mioos-permissions-tabs" role="tablist"><button v-for="tab in tabs" :key="tab.key" type="button" role="tab" :aria-selected="activeTab === tab.key" :class="{ active: activeTab === tab.key }" @click="setTab(tab.key)">[[ tab.label ]]</button></nav>' +
          '<p class="mioos-permissions-error" v-if="error">[[ error ]]</p><p class="mioos-permissions-status" v-if="status">[[ status ]]</p>' +
          '<article class="mioos-permissions-body" v-if="meta">' +
            '<section v-if="activeTab === \'summary\'" class="mioos-permissions-card"><strong>[[ identityLine ]]</strong><dl><dt>Path</dt><dd>[[ meta.path ]]</dd><dt>Kind</dt><dd>[[ meta.kind ]]</dd><dt>Read / write / delete</dt><dd>[[ meta.permRead ]] / [[ meta.permWrite ]] / [[ meta.permDelete ]]</dd><dt>Sharing</dt><dd>[[ (meta.sharing || {}).scope || \'private\' ]]</dd></dl></section>' +
            '<section v-if="activeTab === \'attributes\'" class="mioos-permissions-card"><label><input type="checkbox" v-model="form.readOnly"> Read-only</label><label><input type="checkbox" v-model="form.hidden"> Hidden</label><label><input type="checkbox" v-model="form.shared"> Shared</label></section>' +
            '<section v-if="activeTab === \'sharing\'" class="mioos-permissions-card"><label><span>Scope</span><select v-model="form.scope" :disabled="!form.shared"><option value="private">Private</option><option value="users">Named users</option><option value="everyone">Everyone</option></select></label><label><span>Named users</span><input v-model="form.users" :disabled="!form.shared" placeholder="comma separated users"></label></section>' +
            '<section v-if="activeTab === \'folder\'" class="mioos-permissions-card"><p v-if="!isFolder">Folder defaults apply only to folders.</p><label><span>View mode</span><select v-model="form.viewMode" :disabled="!isFolder"><option value="details">Details</option><option value="icons">Icons</option><option value="list">List</option></select></label><label><span>Sort by</span><select v-model="form.sortBy" :disabled="!isFolder"><option value="name">Name</option><option value="modified">Modified</option><option value="size">Size</option><option value="kind">Kind</option></select></label><label><span>Direction</span><select v-model="form.sortDirection" :disabled="!isFolder"><option value="ascending">Ascending</option><option value="descending">Descending</option></select></label></section>' +
          '</article>' +
          '<footer class="mioos-permissions-actions"><button type="button" class="mioos-btn" @click="resetForm" :disabled="!meta || saving">Reset</button><button type="button" class="mioos-btn primary" @click="save" :disabled="!meta || saving">[[ saving ? \'Saving…\' : \'Save changes\' ]]</button></footer>' +
        '</section>'
    });
    app.component('mioos-surface-permissions', {
      props: ['window'],
      template: '<mioos-permissions-panel :window="window"></mioos-permissions-panel>'
    });
  }

  window.MIOOSPermissions = { methods: methods, register: register };
  if (window.MIOOSModules && typeof window.MIOOSModules.registerComponent === 'function') {
    window.MIOOSModules.registerComponent({ key: 'permissions', name: 'mioos-permissions-panel', title: 'Permissions UI', surface: 'mioos-surface-permissions', source: 'internal', owner: 'MIOOS', backend: 'MIOOSFS', description: 'Inspect and update VFS owner, sharing, and read-only metadata.' });
    window.MIOOSModules.registerModule({ id: 'mioos.permissions', key: 'permissions', appKey: 'permissions', title: 'Permissions UI', source: 'internal', category: 'Security', icon: '🛡', componentKey: 'permissions', surface: 'mioos-surface-permissions' });
  }
})();
