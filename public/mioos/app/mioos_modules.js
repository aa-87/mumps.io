(function () {
  var registeredComponents = {};
  var registeredModules = {};

  function clone(value) { try { return JSON.parse(JSON.stringify(value || {})); } catch (ignore) { return {}; } }
  function toList(value) {
    if (!value) return [];
    if (Array.isArray(value)) return value.filter(Boolean);
    if (typeof value === 'object') {
      return Object.keys(value).filter(function (key) { return key !== 'byValue'; }).sort(function (a, b) { return (+a || 999999) - (+b || 999999) || String(a).localeCompare(String(b)); }).map(function (key) { return value[key]; }).filter(function (item) { return item && typeof item === 'object'; });
    }
    return [];
  }
  function root(vm) { return vm.$root || vm; }
  function bootRegistry(vm) { return (((vm || {}).boot || {}).uiModules) || { modules: [], components: [], examples: [], contract: 'mioos-ui-module-v2' }; }
  function lower(value) { return String(value == null ? '' : value).toLowerCase(); }
  function sourceOf(row) { return row.source || row.kind || (row.userCreated ? 'user' : 'built-in'); }
  function categoryOf(row) { return row.category || row.group || 'General'; }
  function rowKey(row) { return (row && (row.id || row.key || row.appKey || row.name)) || ''; }

  function uniqueRows(rows, keyFn) {
    var seen = {};
    return rows.filter(function (row) {
      var key = keyFn(row);
      if (!key || seen[key]) return false;
      seen[key] = 1;
      return true;
    });
  }
  function componentRows(vm) { return uniqueRows(toList(bootRegistry(vm).components).concat(Object.keys(registeredComponents).map(function (key) { return registeredComponents[key]; })), function (row) { return row && (row.key || row.name); }); }
  function moduleRows(vm) { return uniqueRows(toList(bootRegistry(vm).modules).concat(toList(((vm || {}).boot || {}).modules)).concat(Object.keys(registeredModules).map(function (key) { return registeredModules[key]; })), rowKey); }
  function exampleRows(vm) { return uniqueRows(toList(bootRegistry(vm).examples), function (row) { return row && (row.key || row.path || row.title); }); }
  function componentByKey(vm, key) { key = String(key || ''); return componentRows(vm).find(function (row) { return row.key === key || row.name === key || row.component === key; }) || registeredComponents[key] || null; }
  function moduleByKey(vm, key) { key = String(key || ''); return moduleRows(vm).find(function (row) { return row.id === key || row.key === key || row.appKey === key; }) || registeredModules[key] || null; }

  function filterRows(rows, filters) {
    filters = filters || {};
    var q = lower(filters.query);
    var category = filters.category || 'all';
    var source = filters.source || 'all';
    return rows.filter(function (row) {
      var haystack = [rowKey(row), row.title, row.name, row.description, categoryOf(row), sourceOf(row), row.componentKey, row.path].map(lower).join(' ');
      if (q && haystack.indexOf(q) < 0) return false;
      if (category !== 'all' && categoryOf(row) !== category) return false;
      if (source !== 'all' && sourceOf(row) !== source) return false;
      return true;
    });
  }
  function distinct(values) {
    var seen = {}, out = [];
    values.forEach(function (value) { value = value || ''; if (value && !seen[value]) { seen[value] = 1; out.push(value); } });
    return out.sort(function (a, b) { return String(a).localeCompare(String(b)); });
  }

  function resolveSurface(win, vm) {
    var moduleKey = (win || {}).moduleComponent || (win || {}).componentKey || '';
    var module = moduleByKey(vm, (win || {}).moduleId || (win || {}).appKey || '');
    if (!moduleKey && module) moduleKey = module.componentKey || module.component || '';
    if ((win || {}).appKey === 'app-catalog' || (win || {}).appKey === 'ui-modules' || moduleKey === 'module-catalog') return 'mioos-surface-ui-modules';
    if ((win || {}).appKey === 'permissions' || moduleKey === 'permissions') return 'mioos-surface-permissions';
    if ((win || {}).appKey === 'table-samples' || (win || {}).appKey === 'sample-table' || (win || {}).appKey === 'patient-registration' || (win || {}).appKey === 'ui-elements' || moduleKey === 'table') return 'mioos-surface-table';
    if (module && module.surface) return module.surface;
    var component = componentByKey(vm, moduleKey);
    if (component && component.surface) return component.surface;
    if ((win || {}).moduleWindow || moduleKey) return 'mioos-surface-ui-module';
    return '';
  }

  var methods = {
    uiModuleRegistry: function () { return bootRegistry(this); },
    uiModuleCatalogRows: function () { return moduleRows(this); },
    uiModuleComponentRows: function () { return componentRows(this); },
    uiModuleExampleRows: function () { return exampleRows(this); },
    uiModuleComponent: function (key) { return componentByKey(this, key); },
    uiModuleRecord: function (key) { return moduleByKey(this, key); },
    uiModuleRoute: function () { return ((((this.boot || {}).routes || {}).moduleCatalog) || '/api/mioos/modules/catalog'); },
    uiModuleRefreshCatalog: function () {
      var self = this;
      return fetch(this.uiModuleRoute(), { method: 'POST', credentials: 'same-origin', headers: { 'Content-Type': 'application/json' }, body: '{}' }).then(function (response) {
        if (!response.ok) throw new Error('Module catalog failed: HTTP ' + response.status);
        return response.json();
      }).then(function (payload) {
        self.boot.uiModules = clone(payload || {});
        self.boot.modules = toList((payload || {}).modules);
        return self.boot.uiModules;
      }).catch(function (err) {
        if (self.showAlert) self.showAlert('UI Modules', (err && err.message) || 'Module catalog failed');
        throw err;
      });
    },
    uiModuleOpen: function (key) { var module = this.uiModuleRecord(key); return module ? this.uiModuleOpenModule(module) : null; },
    uiModuleOpenModule: function (module) {
      module = clone(module || {});
      if (!module.appKey) module.appKey = module.key || module.id;
      module.key = module.appKey;
      module.kind = module.kind || 'module';
      module.moduleWindow = true;
      module.moduleId = module.id || module.key;
      module.moduleComponent = module.componentKey || module.component || '';
      if (module.componentKey === 'table' || module.surface === 'mioos-surface-table') {
        module.tableState = module.tableState || { id: 'table-' + (module.id || module.key || Date.now()), title: module.title || 'Backend Table', dataset: module.dataset || 'demo', config: module.tableConfig || null };
      }
      this.openApp(module.appKey);
      var win = (this.windows || []).find(function (item) { return item.appKey === module.appKey; });
      if (win) Object.assign(win, { moduleWindow: true, moduleId: module.moduleId, moduleComponent: module.moduleComponent, tableState: module.tableState || win.tableState || null });
      return win || null;
    },
    uiModuleOpenComponent: function (componentKey, options) {
      var component = this.uiModuleComponent(componentKey) || { key: componentKey, title: componentKey };
      if (component.key === 'table' && this.openBackendTableWindow) return this.openBackendTableWindow(Object.assign({ title: component.title || 'Advanced Table', dataset: 'demo' }, options || {}));
      return this.createWindowForApp({ key: 'component-' + component.key, appKey: 'component-' + component.key, title: component.title || component.key, icon: component.icon || '▣', kind: 'module', moduleWindow: true, moduleComponent: component.key, componentKey: component.key, surface: component.surface }, { state: 'normal', moduleWindow: true, moduleComponent: component.key });
    },
    uiModuleSurfaceComponent: function (win) { return resolveSurface(win, this); }
  };

  function register(app) {
    if (!app || !app.component) return;
    app.component('mioos-surface-ui-modules', {
      props: ['window'],
      data: function () { return { query: '', category: 'all', source: 'all', mode: 'modules', layout: 'cards', error: '', loading: false }; },
      computed: {
        vm: function () { return root(this); },
        modules: function () { return this.vm.uiModuleCatalogRows(); },
        components: function () { return this.vm.uiModuleComponentRows(); },
        examples: function () { return this.vm.uiModuleExampleRows(); },
        rows: function () { return this.mode === 'components' ? this.components : (this.mode === 'examples' ? this.examples : this.modules); },
        visibleRows: function () { return filterRows(this.rows, { query: this.query, category: this.category, source: this.source }); },
        categories: function () { return distinct(this.rows.map(categoryOf)); },
        sources: function () { return distinct(this.rows.map(sourceOf)); },
        contract: function () { return (this.vm.uiModuleRegistry() || {}).contract || 'mioos-ui-module-v2'; }
      },
      mounted: function () { if (!this.modules.length && this.vm.uiModuleRefreshCatalog) this.refresh(); },
      methods: {
        refresh: function () { var self = this; self.loading = true; self.error = ''; return self.vm.uiModuleRefreshCatalog().catch(function (err) { self.error = (err && err.message) || 'Catalog refresh failed'; }).finally(function () { self.loading = false; }); },
        launch: function (row) { if (this.mode === 'components') return this.vm.uiModuleOpenComponent(row.key || row.name); if (this.mode === 'examples') return this.vm.uiModuleOpenComponent(row.componentKey || row.key); return this.vm.uiModuleOpenModule(row); },
        badge: function (row) { return sourceOf(row); },
        keyOf: rowKey,
        categoryOf: categoryOf
      },
      template: '' +
        '<div class="mioos-surface mioos-ui-module-shell mioos-ui-module-catalog-v2">' +
          '<header class="mioos-ui-module-head"><div><strong>App Catalogue + UI Modules</strong><span>[[ contract ]] • searchable launcher, components, and examples</span></div><div class="mioos-ui-module-actions"><button type="button" class="mioos-btn" @click="layout = layout === \'cards\' ? \'list\' : \'cards\'">[[ layout === \'cards\' ? \'List\' : \'Cards\' ]]</button><button type="button" class="mioos-btn" :disabled="loading" @click="refresh">Refresh</button></div></header>' +
          '<nav class="mioos-ui-module-tabs" aria-label="Module catalog sections"><button type="button" :class="{ active: mode === \'modules\' }" @click="mode = \'modules\'; category = \'all\'; source = \'all\'">Modules <span>[[ modules.length ]]</span></button><button type="button" :class="{ active: mode === \'components\' }" @click="mode = \'components\'; category = \'all\'; source = \'all\'">Components <span>[[ components.length ]]</span></button><button type="button" :class="{ active: mode === \'examples\' }" @click="mode = \'examples\'; category = \'all\'; source = \'all\'">Examples <span>[[ examples.length ]]</span></button></nav>' +
          '<section class="mioos-ui-module-filters"><label><span>Search</span><input v-model="query" placeholder="Find modules, tables, forms, examples"></label><label><span>Category</span><select v-model="category"><option value="all">All categories</option><option v-for="item in categories" :key="item" :value="item">[[ item ]]</option></select></label><label><span>Source</span><select v-model="source"><option value="all">All sources</option><option v-for="item in sources" :key="item" :value="item">[[ item ]]</option></select></label></section>' +
          '<div class="mioos-table-error" v-if="error">[[ error ]]</div><div class="mioos-ui-module-empty" v-if="!loading && !visibleRows.length">No modules match the current filters.</div><div class="mioos-ui-module-loading" v-if="loading">Loading catalogue…</div>' +
          '<section :class="layout === \'cards\' ? \'mioos-ui-module-grid\' : \'mioos-ui-module-list\'">' +
            '<article v-for="row in visibleRows" :key="keyOf(row)" class="mioos-ui-module-card" tabindex="0" @keydown.enter.prevent="launch(row)"><div class="mioos-ui-module-card-top"><span class="mioos-ui-module-icon">[[ row.icon || \'▣\' ]]</span><span class="mioos-ui-module-badge">[[ badge(row) ]]</span></div><strong>[[ row.title || row.name || row.key || row.id ]]</strong><span>[[ row.description || row.path || row.surface || \'Reusable MIOOS module asset\' ]]</span><footer><small>[[ categoryOf(row) ]]</small><button type="button" class="mioos-btn is-primary" @click="launch(row)">Launch</button></footer></article>' +
          '</section>' +
        '</div>'
    });

    app.component('mioos-surface-ui-module', {
      props: ['window'],
      computed: { vm: function () { return root(this); }, module: function () { return this.vm.uiModuleRecord((this.window || {}).moduleId || (this.window || {}).appKey) || {}; }, component: function () { return this.vm.uiModuleComponent((this.window || {}).moduleComponent || this.module.componentKey) || {}; } },
      template: '<div class="mioos-surface mioos-ui-module-host"><header><strong>[[ module.title || window.title ]]</strong><span>[[ module.description || component.description || "MIOOS UI module" ]]</span></header><section><dl><dt>Module</dt><dd>[[ module.id || window.appKey ]]</dd><dt>Component</dt><dd>[[ component.key || window.moduleComponent || "custom" ]]</dd><dt>Source</dt><dd>[[ module.source || component.source || "user" ]]</dd></dl></section></div>'
    });
  }

  function registerComponent(definition) { if (!definition || !definition.key) return null; registeredComponents[definition.key] = Object.assign({}, definition); return registeredComponents[definition.key]; }
  function registerModule(definition) { var key = definition && (definition.id || definition.key || definition.appKey); if (!key) return null; registeredModules[key] = Object.assign({}, definition); return registeredModules[key]; }
  window.MIOOSModules = { methods: methods, register: register, registerComponent: registerComponent, registerModule: registerModule, resolveSurface: resolveSurface, listComponents: function () { return Object.keys(registeredComponents).map(function (key) { return registeredComponents[key]; }); } };
})();
