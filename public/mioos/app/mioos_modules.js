(function () {
  var registeredComponents = {};
  var registeredModules = {};

  function clone(value) {
    try { return JSON.parse(JSON.stringify(value || {})); } catch (ignore) { return {}; }
  }

  function toList(value) {
    if (!value) return [];
    if (Array.isArray(value)) return value.filter(Boolean);
    if (typeof value === 'object') {
      return Object.keys(value).filter(function (key) { return key !== 'byValue'; }).sort(function (a, b) { return (+a || 999999) - (+b || 999999) || String(a).localeCompare(String(b)); }).map(function (key) { return value[key]; }).filter(function (item) { return item && typeof item === 'object'; });
    }
    return [];
  }

  function root(vm) { return vm.$root || vm; }

  function bootRegistry(vm) {
    return (((vm || {}).boot || {}).uiModules) || { modules: [], components: [], examples: [] };
  }

  function componentRows(vm) {
    var rows = toList(bootRegistry(vm).components).concat(Object.keys(registeredComponents).map(function (key) { return registeredComponents[key]; }));
    var seen = {};
    return rows.filter(function (row) {
      var key = row && (row.key || row.name);
      if (!key || seen[key]) return false;
      seen[key] = 1;
      return true;
    });
  }

  function moduleRows(vm) {
    var rows = toList(bootRegistry(vm).modules).concat(toList(((vm || {}).boot || {}).modules)).concat(Object.keys(registeredModules).map(function (key) { return registeredModules[key]; }));
    var seen = {};
    return rows.filter(function (row) {
      var key = row && (row.id || row.key || row.appKey);
      if (!key || seen[key]) return false;
      seen[key] = 1;
      return true;
    });
  }

  function componentByKey(vm, key) {
    var rows = componentRows(vm);
    key = String(key || '');
    return rows.find(function (row) { return row.key === key || row.name === key || row.component === key; }) || registeredComponents[key] || null;
  }

  function moduleByKey(vm, key) {
    var rows = moduleRows(vm);
    key = String(key || '');
    return rows.find(function (row) { return row.id === key || row.key === key || row.appKey === key; }) || registeredModules[key] || null;
  }

  function resolveSurface(win, vm) {
    var moduleKey = (win || {}).moduleComponent || (win || {}).componentKey || '';
    var module = moduleByKey(vm, (win || {}).moduleId || (win || {}).appKey || '');
    if (!moduleKey && module) moduleKey = module.componentKey || module.component || '';
    if ((win || {}).appKey === 'ui-modules' || (win || {}).appKey === 'app-catalog' || moduleKey === 'module-catalog') return 'mioos-surface-ui-modules';
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
    uiModuleExampleRows: function () { return toList(bootRegistry(this).examples); },
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
    uiModuleOpen: function (key) {
      var module = this.uiModuleRecord(key);
      if (!module) return null;
      return this.uiModuleOpenModule(module);
    },
    uiModuleOpenModule: function (module) {
      module = clone(module || {});
      if (!module.appKey) module.appKey = module.key || module.id;
      module.key = module.appKey;
      module.kind = module.kind || 'module';
      module.moduleWindow = true;
      module.moduleId = module.id || module.key;
      module.moduleComponent = module.componentKey || module.component || '';
      if (module.componentKey === 'table' || module.surface === 'mioos-surface-table') {
        module.tableState = module.tableState || { id: 'table-' + (module.id || module.key || Date.now()), title: module.title || 'Backend Table', dataset: 'demo' };
      }
      this.openApp(module.appKey);
      var win = (this.windows || []).find(function (item) { return item.appKey === module.appKey; });
      if (win) Object.assign(win, { title: module.title || win.title, icon: module.icon || win.icon, kind: 'module', moduleWindow: true, moduleId: module.moduleId, moduleComponent: module.moduleComponent, componentKey: module.componentKey || module.component || '', surface: module.surface || win.surface || '', tableState: module.tableState || win.tableState || null, permissionsState: module.permissionsState || win.permissionsState || null });
      return win || null;
    },
    uiModuleOpenComponent: function (componentKey, options) {
      var component = this.uiModuleComponent(componentKey) || { key: componentKey, title: componentKey };
      if (component.key === 'table' && this.openBackendTableWindow) {
        return this.openBackendTableWindow(Object.assign({ title: component.title || 'Backend Table', dataset: 'demo' }, options || {}));
      }
      return this.createWindowForApp({ key: 'component-' + component.key, appKey: 'component-' + component.key, title: component.title || component.key, icon: component.icon || '▣', kind: 'module', moduleWindow: true, moduleComponent: component.key, componentKey: component.key, surface: component.surface }, { state: 'normal', moduleWindow: true, moduleComponent: component.key });
    },
    uiModuleSurfaceComponent: function (win) { return resolveSurface(win, this); }
  };

  function register(app) {
    if (!app || !app.component) return;
    app.component('mioos-surface-ui-modules', {
      props: ['window'],
      computed: {
        vm: function () { return root(this); },
        modules: function () { return this.vm.uiModuleCatalogRows(); },
        components: function () { return this.vm.uiModuleComponentRows(); },
        examples: function () { return this.vm.uiModuleExampleRows(); },
        contract: function () { return (this.vm.uiModuleRegistry() || {}).contract || 'mioos-ui-module-v1'; }
      },
      template: '' +
        '<div class="mioos-surface mioos-ui-module-shell">' +
          '<header class="mioos-ui-module-head"><div><strong>UI Modules</strong><span>[[ contract ]] • internal and user-created module foundation</span></div><button type="button" class="mioos-btn" @click="vm.uiModuleRefreshCatalog()">Refresh Catalog</button></header>' +
          '<section class="mioos-ui-module-grid">' +
            '<article class="mioos-ui-module-card"><strong>Components</strong><span>Reusable UI primitives registered with the shell.</span><button v-for="component in components" :key="component.key" type="button" @click="vm.uiModuleOpenComponent(component.key)"><b>[[ component.title || component.key ]]</b><small>[[ component.description || component.name ]]</small></button></article>' +
            '<article class="mioos-ui-module-card"><strong>Modules</strong><span>Launchable internal and user module manifests.</span><button v-for="module in modules" :key="module.id || module.key" type="button" @click="vm.uiModuleOpenModule(module)"><b>[[ module.title || module.id ]]</b><small>[[ module.source || "internal" ]] • [[ module.category || "Module" ]]</small></button></article>' +
            '<article class="mioos-ui-module-card"><strong>Examples</strong><span>Source templates for new modules.</span><button v-for="example in examples" :key="example.key" type="button" @click="vm.uiModuleOpenComponent(example.componentKey || example.key)"><b>[[ example.title || example.key ]]</b><small>[[ example.path ]]</small></button></article>' +
          '</section>' +
        '</div>'
    });

    app.component('mioos-surface-ui-module', {
      props: ['window'],
      computed: {
        vm: function () { return root(this); },
        module: function () { return this.vm.uiModuleRecord((this.window || {}).moduleId || (this.window || {}).appKey) || {}; },
        component: function () { return this.vm.uiModuleComponent((this.window || {}).moduleComponent || this.module.componentKey) || {}; }
      },
      template: '' +
        '<div class="mioos-surface mioos-ui-module-host">' +
          '<header><strong>[[ module.title || window.title ]]</strong><span>[[ module.description || component.description || "MIOOS UI module" ]]</span></header>' +
          '<section><dl><dt>Module</dt><dd>[[ module.id || window.appKey ]]</dd><dt>Component</dt><dd>[[ component.key || window.moduleComponent || "custom" ]]</dd><dt>Source</dt><dd>[[ module.source || component.source || "user" ]]</dd></dl></section>' +
        '</div>'
    });
  }

  function registerComponent(definition) {
    if (!definition || !definition.key) return null;
    registeredComponents[definition.key] = Object.assign({}, definition);
    return registeredComponents[definition.key];
  }

  function registerModule(definition) {
    var key = definition && (definition.id || definition.key || definition.appKey);
    if (!key) return null;
    registeredModules[key] = Object.assign({}, definition);
    return registeredModules[key];
  }

  window.MIOOSModules = { methods: methods, register: register, registerComponent: registerComponent, registerModule: registerModule, resolveSurface: resolveSurface, listComponents: function () { return Object.keys(registeredComponents).map(function (key) { return registeredComponents[key]; }); } };
})();
