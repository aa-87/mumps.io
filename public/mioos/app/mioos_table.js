(function () {
  function clone(value) {
    try { return JSON.parse(JSON.stringify(value || {})); } catch (ignore) { return {}; }
  }

  function defaultColumns() {
    return [
      { key: 'name', label: 'Name', type: 'text', width: 240, sortable: true, resizable: true, hidden: false, group: 'Identity' },
      { key: 'status', label: 'Status', type: 'badge', width: 120, sortable: true, resizable: true, hidden: false, group: 'State' },
      { key: 'owner', label: 'Owner', type: 'text', width: 150, sortable: true, resizable: true, hidden: false, group: 'Ownership' },
      { key: 'priority', label: 'Priority', type: 'text', width: 120, sortable: true, resizable: true, hidden: false, group: 'State' },
      { key: 'updated', label: 'Updated', type: 'date', width: 150, sortable: true, resizable: true, hidden: false, group: 'Timeline' }
    ];
  }

  function defaultRows() {
    return [
      { id: 'demo-1', name: 'Audit backlog', status: 'Open', owner: 'MIOOS', priority: 'High', updated: '2026-05-01', _expand: { title: 'Notes', body: 'Security and audit work items.' } },
      { id: 'demo-2', name: 'Explorer grid', status: 'Done', owner: 'Shell', priority: 'Medium', updated: '2026-04-30', _expand: { title: 'Notes', body: 'Resizable Explorer grid source inspiration.' } },
      { id: 'demo-3', name: 'Transfer manager', status: 'Open', owner: 'VFS', priority: 'High', updated: '2026-04-28', _expand: { title: 'Notes', body: 'Upload and download transfer controls.' } }
    ];
  }

  function normalizeColumns(columns) {
    var source = Array.isArray(columns) && columns.length ? columns : defaultColumns();
    return source.map(function (col, index) {
      col = col || {};
      return {
        key: col.key || ('col' + index),
        label: col.label || col.title || col.key || ('Column ' + (index + 1)),
        type: col.type || 'text',
        width: Math.max(72, +(col.width || 140)),
        minWidth: Math.max(48, +(col.minWidth || 72)),
        sortable: col.sortable !== false,
        resizable: col.resizable !== false,
        hidden: !!col.hidden,
        group: col.group || col.groupLabel || ''
      };
    });
  }

  function normalizeRows(rows) {
    return (Array.isArray(rows) && rows.length ? rows : defaultRows()).map(function (row, index) {
      var out = clone(row);
      out.id = out.id || out.key || ('row-' + index);
      return out;
    });
  }

  function root(vm) { return vm.$root || vm; }

  function tableState(vm, tableId) {
    vm.backendTables = vm.backendTables || {};
    if (!vm.backendTables[tableId]) vm.backendTables[tableId] = vm.backendTableDefaultState(tableId);
    return vm.backendTables[tableId];
  }

  var methods = {
    backendTableDefaultColumns: defaultColumns,
    backendTableDefaultRows: defaultRows,
    backendTableDefaultState: function (tableId) {
      return {
        id: tableId || 'mioos-table',
        title: 'Backend Table',
        dataset: 'demo',
        loading: false,
        error: '',
        rows: defaultRows(),
        columns: defaultColumns(),
        selected: {},
        expanded: {},
        search: '',
        groupBy: '',
        sort: { column: 'name', direction: 'ascending' },
        pagination: { page: 1, pageSize: 25, totalRows: 3, filteredRows: 3, pageRows: 3, pageCount: 1 },
        rowActions: [
          { key: 'open', label: 'Open' },
          { key: 'edit', label: 'Edit' },
          { key: 'delete', label: 'Delete' }
        ],
        bulkActions: [
          { key: 'export', label: 'Export selected' }
        ],
        groups: [],
        columnResize: null
      };
    },
    backendTableState: function (tableId) {
      return tableState(this, tableId || 'mioos-table');
    },
    backendTableRoute: function () {
      return ((((this.boot || {}).routes || {}).tableQuery) || '/api/mioos/table/query');
    },
    backendTableQueryPayload: function (state) {
      return {
        dataset: state.dataset || 'demo',
        folderId: state.folderId || '',
        page: +(state.pagination || {}).page || 1,
        pageSize: +(state.pagination || {}).pageSize || 25,
        search: state.search || '',
        groupBy: state.groupBy || '',
        sort: clone(state.sort || { column: 'name', direction: 'ascending' }),
        columns: normalizeColumns(state.columns).map(function (col) { return { key: col.key, hidden: !!col.hidden, width: col.width }; })
      };
    },
    backendTableFetch: function (tableId, patch) {
      var state = this.backendTableState(tableId);
      var route = this.backendTableRoute();
      var vm = this;
      Object.assign(state, patch || {});
      state.loading = true;
      state.error = '';
      return fetch(route, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'same-origin',
        body: JSON.stringify(this.backendTableQueryPayload(state))
      }).then(function (response) {
        if (!response.ok) throw new Error('Table query failed: HTTP ' + response.status);
        return response.json();
      }).then(function (payload) {
        vm.backendTableApplyPayload(state, payload || {});
        return state;
      }).catch(function (err) {
        state.error = (err && err.message) || 'Table query failed';
        vm.backendTableApplyClientFallback(state);
        return state;
      }).finally(function () {
        state.loading = false;
      });
    },
    backendTableApplyPayload: function (state, payload) {
      var schemaColumns = ((((payload || {}).schema || {}).columns) || []);
      state.columns = normalizeColumns(schemaColumns.length ? schemaColumns : state.columns);
      state.rows = normalizeRows((payload || {}).rows || []);
      state.pagination = Object.assign({}, state.pagination || {}, (payload || {}).pagination || {});
      state.rowActions = (payload || {}).rowActions || state.rowActions || [];
      state.bulkActions = (payload || {}).bulkActions || state.bulkActions || [];
      state.groups = (payload || {}).groups || [];
    },
    backendTableApplyClientFallback: function (state) {
      var rows = normalizeRows(state.rows);
      var search = String(state.search || '').toLowerCase();
      var sort = state.sort || { column: 'name', direction: 'ascending' };
      if (search) {
        rows = rows.filter(function (row) {
          return Object.keys(row).some(function (key) {
            return key.charAt(0) !== '_' && String(row[key] == null ? '' : row[key]).toLowerCase().indexOf(search) >= 0;
          });
        });
      }
      rows.sort(function (a, b) {
        var av = String(a[sort.column] == null ? '' : a[sort.column]).toLowerCase();
        var bv = String(b[sort.column] == null ? '' : b[sort.column]).toLowerCase();
        if (av === bv) return 0;
        return (sort.direction === 'descending' ? (av < bv ? 1 : -1) : (av > bv ? 1 : -1));
      });
      state.pagination.totalRows = rows.length;
      state.pagination.filteredRows = rows.length;
      state.pagination.pageCount = Math.max(1, Math.ceil(rows.length / Math.max(1, +state.pagination.pageSize || 25)));
      state.pagination.page = Math.min(Math.max(1, +state.pagination.page || 1), state.pagination.pageCount);
      var start = (state.pagination.page - 1) * state.pagination.pageSize;
      state.rows = rows.slice(start, start + state.pagination.pageSize);
      state.pagination.pageRows = state.rows.length;
    },
    backendTableVisibleColumns: function (state) {
      return normalizeColumns((state || {}).columns || []).filter(function (col) { return !col.hidden; });
    },
    backendTableAllColumns: function (state) {
      return normalizeColumns((state || {}).columns || []);
    },
    backendTableColumnStyle: function (column) {
      return { width: Math.max(48, +(column || {}).width || 120) + 'px' };
    },
    backendTableColumnGroupRows: function (state) {
      var columns = this.backendTableVisibleColumns(state);
      var groups = [];
      var last = null;
      columns.forEach(function (col) {
        var label = col.group || '';
        if (!last || last.label !== label) {
          last = { label: label, span: 0 };
          groups.push(last);
        }
        last.span += 1;
      });
      return groups;
    },
    backendTableSortBy: function (tableId, column) {
      var state = this.backendTableState(tableId);
      if (!column || column.sortable === false) return;
      if ((state.sort || {}).column === column.key) {
        state.sort.direction = state.sort.direction === 'descending' ? 'ascending' : 'descending';
      } else {
        state.sort = { column: column.key, direction: 'ascending' };
      }
      state.pagination.page = 1;
      this.backendTableFetch(tableId);
    },
    backendTableSortMark: function (state, column) {
      if (!state || !state.sort || state.sort.column !== column.key) return '';
      return state.sort.direction === 'descending' ? '▼' : '▲';
    },
    backendTableSetSearch: function (tableId, value) {
      var state = this.backendTableState(tableId);
      state.search = value || '';
      state.pagination.page = 1;
      return this.backendTableFetch(tableId);
    },
    backendTableSetPage: function (tableId, page) {
      var state = this.backendTableState(tableId);
      var max = +((state.pagination || {}).pageCount) || 1;
      state.pagination.page = Math.min(Math.max(1, +page || 1), max);
      return this.backendTableFetch(tableId);
    },
    backendTableSetPageSize: function (tableId, pageSize) {
      var state = this.backendTableState(tableId);
      state.pagination.pageSize = Math.max(1, +pageSize || 25);
      state.pagination.page = 1;
      return this.backendTableFetch(tableId);
    },
    backendTableToggleColumn: function (tableId, key) {
      var state = this.backendTableState(tableId);
      state.columns = normalizeColumns(state.columns).map(function (col) {
        if (col.key === key) col.hidden = !col.hidden;
        return col;
      });
    },
    backendTableSetGroupBy: function (tableId, key) {
      var state = this.backendTableState(tableId);
      state.groupBy = key || '';
      return this.backendTableFetch(tableId);
    },
    backendTableToggleRow: function (tableId, row) {
      var state = this.backendTableState(tableId);
      var key = (row && (row.id || row.key)) || '';
      if (!key) return;
      state.selected[key] = !state.selected[key];
    },
    backendTableToggleExpand: function (tableId, row) {
      var state = this.backendTableState(tableId);
      var key = (row && (row.id || row.key)) || '';
      if (!key) return;
      state.expanded[key] = !state.expanded[key];
    },
    backendTableIsSelected: function (state, row) {
      return !!((state || {}).selected || {})[(row && (row.id || row.key)) || ''];
    },
    backendTableIsExpanded: function (state, row) {
      return !!((state || {}).expanded || {})[(row && (row.id || row.key)) || ''];
    },
    backendTableSelectedCount: function (state) {
      return Object.keys((state || {}).selected || {}).filter(function (key) { return !!state.selected[key]; }).length;
    },
    backendTableRunAction: function (tableId, action, row) {
      var state = this.backendTableState(tableId);
      state.lastAction = { action: (action || {}).key || action || '', rowId: (row || {}).id || '', at: new Date().toISOString() };
      if (this.showAlert) this.showAlert('Table action', ((action || {}).label || action || 'Action') + ' queued for ' + ((row || {}).name || (row || {}).id || 'row'));
    },
    backendTableRunBulkAction: function (tableId, action) {
      var state = this.backendTableState(tableId);
      state.lastAction = { action: (action || {}).key || action || '', selected: this.backendTableSelectedCount(state), at: new Date().toISOString() };
      if (this.showAlert) this.showAlert('Bulk table action', ((action || {}).label || action || 'Action') + ' queued for ' + state.lastAction.selected + ' row(s)');
    },
    backendTableCellText: function (row, column) {
      var value = row ? row[column.key] : '';
      if (value === null || typeof value === 'undefined') return '';
      return String(value);
    },
    backendTableBeginColumnResize: function (tableId, column, event) {
      var state = this.backendTableState(tableId);
      if (!column || column.resizable === false || !event) return;
      state.columnResize = { key: column.key, startX: event.clientX, startWidth: +column.width || 120 };
      var vm = this;
      function move(e) { vm.backendTableMoveColumnResize(tableId, e); }
      function up() {
        document.removeEventListener('pointermove', move);
        document.removeEventListener('pointerup', up);
        state.columnResize = null;
      }
      document.addEventListener('pointermove', move);
      document.addEventListener('pointerup', up, { once: true });
    },
    backendTableMoveColumnResize: function (tableId, event) {
      var state = this.backendTableState(tableId);
      var resize = state.columnResize;
      if (!resize || !event) return;
      var next = Math.max(48, resize.startWidth + (event.clientX - resize.startX));
      state.columns = normalizeColumns(state.columns).map(function (col) {
        if (col.key === resize.key) col.width = next;
        return col;
      });
    },
    openBackendTableWindow: function (options) {
      options = options || {};
      var id = 'win-table-' + Date.now();
      this.windows.push({ id: id, appKey: 'backend-table', title: options.title || 'Backend Table', state: 'normal', left: 180, top: 92, width: 980, height: 620, z: this.zCounter + 1, tableState: { id: id, title: options.title || 'Backend Table', dataset: options.dataset || 'demo', folderId: options.folderId || '' } });
      this.focusWindow(id);
      return id;
    }
  };

  function register(app) {
    if (!app || !app.component) return;
    app.component('mioos-full-table', {
      props: ['tableId', 'title', 'dataset', 'folderId'],
      data: function () { return { searchInput: '' }; },
      computed: {
        vm: function () { return root(this); },
        state: function () { return this.vm.backendTableState(this.tableId || 'mioos-table'); },
        columns: function () { return this.vm.backendTableVisibleColumns(this.state); },
        allColumns: function () { return this.vm.backendTableAllColumns(this.state); },
        groups: function () { return this.vm.backendTableColumnGroupRows(this.state); },
        selectedCount: function () { return this.vm.backendTableSelectedCount(this.state); }
      },
      mounted: function () {
        var state = this.state;
        state.title = this.title || state.title;
        state.dataset = this.dataset || state.dataset || 'demo';
        state.folderId = this.folderId || state.folderId || '';
        this.searchInput = state.search || '';
        this.vm.backendTableFetch(this.tableId || state.id);
      },
      methods: {
        commitSearch: function () { this.vm.backendTableSetSearch(this.tableId || this.state.id, this.searchInput); },
        keyOf: function (row) { return (row && (row.id || row.key)) || ''; }
      },
      template: '' +
        '<section class="mioos-full-table" :aria-busy="state.loading ? \'true\' : \'false\'">' +
          '<header class="mioos-table-toolbar">' +
            '<div><strong>[[ state.title || title || \'Backend Table\' ]]</strong><span>Backend pagination, sorting, grouping, expansion, actions</span></div>' +
            '<label class="mioos-table-search"><span>Search</span><input v-model="searchInput" @keydown.enter="commitSearch" @blur="commitSearch" placeholder="Filter rows"></label>' +
            '<label><span>Group</span><select :value="state.groupBy" @change="vm.backendTableSetGroupBy(tableId || state.id, $event.target.value)"><option value="">None</option><option v-for="col in allColumns" :key="col.key" :value="col.key">[[ col.label ]]</option></select></label>' +
            '<details class="mioos-table-column-picker"><summary>Columns</summary><button v-for="col in allColumns" :key="col.key" type="button" @click="vm.backendTableToggleColumn(tableId || state.id, col.key)"><span>[[ col.hidden ? \'☐\' : \'☑\' ]]</span> [[ col.label ]]</button></details>' +
          '</header>' +
          '<div class="mioos-table-bulkbar" v-if="selectedCount"><span>[[ selectedCount ]] selected</span><button v-for="action in state.bulkActions" :key="action.key" type="button" @click="vm.backendTableRunBulkAction(tableId || state.id, action)">[[ action.label ]]</button></div>' +
          '<div class="mioos-table-error" v-if="state.error">[[ state.error ]]</div>' +
          '<div class="mioos-table-wrap">' +
            '<table class="mioos-table-grid" role="grid">' +
              '<colgroup><col class="mioos-table-select-col"><col class="mioos-table-expand-col"><col v-for="col in columns" :key="col.key" :style="vm.backendTableColumnStyle(col)"><col class="mioos-table-actions-col"></colgroup>' +
              '<thead>' +
                '<tr class="mioos-table-groups"><th></th><th></th><th v-for="group in groups" :key="group.label + group.span" :colspan="group.span">[[ group.label ]]</th><th></th></tr>' +
                '<tr><th>Select</th><th></th><th v-for="col in columns" :key="col.key"><button type="button" @click="vm.backendTableSortBy(tableId || state.id, col)">[[ col.label ]] [[ vm.backendTableSortMark(state, col) ]]</button><span class="mioos-table-resizer" @pointerdown.prevent="vm.backendTableBeginColumnResize(tableId || state.id, col, $event)"></span></th><th>Actions</th></tr>' +
              '</thead>' +
              '<tbody>' +
                '<template v-for="row in state.rows" :key="keyOf(row)">' +
                  '<tr :class="{ \'is-selected\': vm.backendTableIsSelected(state, row) }"><td><input type="checkbox" :checked="vm.backendTableIsSelected(state, row)" @change="vm.backendTableToggleRow(tableId || state.id, row)"></td><td><button type="button" @click="vm.backendTableToggleExpand(tableId || state.id, row)">[[ vm.backendTableIsExpanded(state, row) ? \'▾\' : \'▸\' ]]</button></td><td v-for="col in columns" :key="col.key"><span :class="\'mioos-table-cell type-\' + col.type">[[ vm.backendTableCellText(row, col) ]]</span></td><td class="mioos-table-actions"><button v-for="action in state.rowActions" :key="action.key" type="button" @click="vm.backendTableRunAction(tableId || state.id, action, row)">[[ action.label ]]</button></td></tr>' +
                  '<tr v-if="vm.backendTableIsExpanded(state, row)" class="mioos-table-expanded-row"><td></td><td></td><td :colspan="columns.length + 1"><strong>[[ (row._expand || {}).title || \'Details\' ]]</strong><p>[[ (row._expand || {}).body || JSON.stringify(row) ]]</p></td></tr>' +
                '</template>' +
              '</tbody>' +
            '</table>' +
          '</div>' +
          '<footer class="mioos-table-pager"><span>[[ state.pagination.filteredRows ]] of [[ state.pagination.totalRows ]] rows</span><button type="button" @click="vm.backendTableSetPage(tableId || state.id, 1)">First</button><button type="button" @click="vm.backendTableSetPage(tableId || state.id, state.pagination.page - 1)">Prev</button><span>Page [[ state.pagination.page ]] / [[ state.pagination.pageCount ]]</span><button type="button" @click="vm.backendTableSetPage(tableId || state.id, state.pagination.page + 1)">Next</button><button type="button" @click="vm.backendTableSetPage(tableId || state.id, state.pagination.pageCount)">Last</button><label>Rows <select :value="state.pagination.pageSize" @change="vm.backendTableSetPageSize(tableId || state.id, $event.target.value)"><option>10</option><option>25</option><option>50</option><option>100</option></select></label></footer>' +
        '</section>'
    });

    app.component('mioos-surface-table', {
      props: ['window'],
      computed: { state: function () { return (this.window || {}).tableState || {}; } },
      template: '<mioos-full-table :table-id="state.id || window.id" :title="state.title || window.title" :dataset="state.dataset || \'demo\'" :folder-id="state.folderId || \'\'"></mioos-full-table>'
    });
  }

  window.MIOOSTable = { methods: methods, register: register };
  if (window.MIOOSModules && typeof window.MIOOSModules.registerComponent === "function") {
    window.MIOOSModules.registerComponent({ key: "table", name: "mioos-full-table", title: "Backend Table", surface: "mioos-surface-table", source: "internal", owner: "MIOOS", backend: "MIOOSTBL", queryRoute: "/api/mioos/table/query", description: "Backend-paginated, sortable, hideable, groupable, expandable table component." });
    window.MIOOSModules.registerModule({ id: "mioos.ui.table", key: "mioos.ui.table", appKey: "mioos.ui.table", title: "Backend Table", source: "internal", category: "Components", icon: "▤", componentKey: "table", surface: "mioos-surface-table", tableState: { id: "mioos-ui-module-table-example", title: "Backend Table Example", dataset: "demo" } });
    window.MIOOSModules.registerModule({ id: "mioos.sample.table", key: "sample-table", appKey: "sample-table", title: "Sample Table", source: "internal", category: "Examples", icon: "▦", componentKey: "table", surface: "mioos-surface-table", tableState: { id: "mioos-sample-table", title: "Sample Table", dataset: "demo" } });
  }
})();
