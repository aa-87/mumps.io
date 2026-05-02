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

  var TABLE_CONTRACT = 'mioos-advanced-table-v3';

  function defaultTableConfig() {
    return {
      contract: TABLE_CONTRACT,
      features: { toolbar: true, datasetSwitcher: true, search: true, filters: true, grouping: true, columnPicker: true, rowCrud: true, columnCrud: true, selection: true, bulkActions: true, pagination: true, rowDetails: true, resizeColumns: true },
      columns: [],
      defaultSort: { column: 'name', direction: 'ascending' },
      defaultPageSize: 25,
      readonly: false,
      density: 'comfortable',
      emptyMessage: 'No rows match the current table query.',
      loadingMessage: 'Loading table data…',
      saveMessage: 'Saving table changes…'
    };
  }

  function mergeConfig(base, patch) {
    var out = clone(base || defaultTableConfig());
    patch = patch || {};
    Object.keys(patch).forEach(function (key) {
      if (key === 'features') out.features = Object.assign({}, out.features || {}, patch.features || {});
      else out[key] = patch[key];
    });
    return out;
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

  function toList(value) {
    if (!value) return [];
    if (Array.isArray(value)) return value;
    if (typeof value === 'object') {
      return Object.keys(value).filter(function (key) { return key !== 'byValue'; }).sort(function (a, b) { return (+a || 999999) - (+b || 999999) || String(a).localeCompare(String(b)); }).map(function (key) { return value[key]; }).filter(Boolean);
    }
    return [];
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
        saving: false,
        error: '',
        rows: defaultRows(),
        columns: defaultColumns(),
        selected: {},
        expanded: {},
        search: '',
        groupBy: '',
        sort: { column: 'name', direction: 'ascending' },
        pagination: { page: 1, pageSize: 25, totalRows: 3, filteredRows: 3, pageRows: 3, pageCount: 1 },
        rowActions: [{ key: 'edit', label: 'Edit' }, { key: 'duplicate', label: 'Duplicate' }, { key: 'delete', label: 'Delete' }],
        bulkActions: [{ key: 'export', label: 'Export selected' }, { key: 'bulk.delete', label: 'Delete selected' }],
        groups: [],
        filters: {},
        filterDraft: {},
        config: defaultTableConfig(),
        toast: '',
        validation: {},
        columnResize: null,
        groupExpanded: {},
        editor: { open: false, mode: 'row', title: '', row: {}, column: {} }
      };
    },
    backendTableState: function (tableId) {
      return tableState(this, tableId || 'mioos-table');
    },
    backendTableRoute: function () {
      return ((((this.boot || {}).routes || {}).tableQuery) || '/api/mioos/table/query');
    },
    backendTableMutateRoute: function () {
      return ((((this.boot || {}).routes || {}).tableMutate) || '/api/mioos/table/mutate');
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
        filters: clone(state.filters || {}),
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
    backendTableMutate: function (tableId, action, payload) {
      var state = this.backendTableState(tableId);
      var vm = this;
      var body = Object.assign(this.backendTableQueryPayload(state), payload || {}, { action: action, dataset: state.dataset || 'demo' });
      state.saving = true;
      state.error = '';
      return fetch(this.backendTableMutateRoute(), {
        method: 'POST',
        credentials: 'same-origin',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body)
      }).then(function (response) {
        if (!response.ok) throw new Error('Table mutation failed: HTTP ' + response.status);
        return response.json();
      }).then(function (payload) {
        vm.backendTableApplyPayload(state, payload || {});
        state.selected = {};
        state.editor.open = false;
        return payload;
      }).catch(function (err) {
        state.error = (err && err.message) || 'Table mutation failed';
        throw err;
      }).finally(function () {
        state.saving = false;
      });
    },
    backendTableApplyPayload: function (state, payload) {
      var schemaColumns = ((((payload || {}).schema || {}).columns) || []);
      state.columns = normalizeColumns(schemaColumns.length ? schemaColumns : state.columns);
      state.rows = normalizeRows((payload || {}).rows || []);
      state.pagination = Object.assign({}, state.pagination || {}, (payload || {}).pagination || {});
      state.rowActions = (payload || {}).rowActions || state.rowActions || [];
      state.bulkActions = (payload || {}).bulkActions || state.bulkActions || [];
      state.groups = toList((payload || {}).groups);
      state.error = payload && payload.ok === false ? (payload.error || 'Table request failed') : state.error;
      if (!state.groupBy) state.groupExpanded = {};
      if (state.groupBy && !Object.keys(state.groupExpanded || {}).length) {
        state.groups.forEach(function (g) { state.groupExpanded[g.key || g.label] = true; });
      }
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
    backendTableAllColumns: function (state) { return normalizeColumns((state || {}).columns || []); },
    backendTableColumnStyle: function (column) { return { width: Math.max(48, +(column || {}).width || 120) + 'px' }; },
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
    backendTableGroupedRows: function (state) {
      var rows = normalizeRows((state || {}).rows || []);
      var key = (state || {}).groupBy || '';
      if (!key) return [{ key: '', label: '', rows: rows, count: rows.length, ungrouped: true }];
      var map = {};
      rows.forEach(function (row) {
        var value = String(row[key] == null || row[key] === '' ? '(blank)' : row[key]);
        if (!map[value]) map[value] = { key: value, label: value, rows: [], count: 0 };
        map[value].rows.push(row);
        map[value].count += 1;
      });
      return Object.keys(map).sort().map(function (value) { return map[value]; });
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
    backendTableFilterableColumns: function (state) {
      return normalizeColumns((state || {}).columns || []).filter(function (col) { return !col.hidden && ['badge', 'text', 'boolean'].indexOf(col.type) >= 0; });
    },
    backendTableFilterValue: function (state, key) {
      var val = ((state || {}).filters || {})[key];
      return Array.isArray(val) ? (val[0] || '') : (val || '');
    },
    backendTableSetFilter: function (tableId, key, value) {
      var state = this.backendTableState(tableId);
      state.filters = clone(state.filters || {});
      if (!value) delete state.filters[key]; else state.filters[key] = [String(value)];
      state.pagination.page = 1;
      return this.backendTableFetch(tableId);
    },
    backendTableClearFilters: function (tableId) {
      var state = this.backendTableState(tableId);
      state.filters = {};
      state.filterDraft = {};
      state.pagination.page = 1;
      return this.backendTableFetch(tableId);
    },
    backendTableSetDataset: function (tableId, value) {
      var state = this.backendTableState(tableId);
      state.dataset = value || 'demo';
      state.pagination.page = 1;
      state.selected = {};
      state.expanded = {};
      state.groupExpanded = {};
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
      var nextHidden = false;
      state.columns = normalizeColumns(state.columns).map(function (col) { if (col.key === key) { col.hidden = !col.hidden; nextHidden = col.hidden; } return col; });
      return this.backendTableMutate(tableId, 'column.visibility', { columnKey: key, hidden: nextHidden }).catch(function () {});
    },
    backendTableSetGroupBy: function (tableId, key) {
      var state = this.backendTableState(tableId);
      state.groupBy = key || '';
      state.groupExpanded = {};
      return this.backendTableFetch(tableId);
    },
    backendTableToggleRow: function (tableId, row) {
      var state = this.backendTableState(tableId);
      var key = (row && (row.id || row.key)) || '';
      if (!key) return;
      state.selected = Object.assign({}, state.selected || {});
      state.selected[key] = !state.selected[key];
    },
    backendTableVisibleRowIds: function (state) {
      return normalizeRows((state || {}).rows || []).map(function (row) { return row.id || row.key; }).filter(Boolean);
    },
    backendTableAllVisibleSelected: function (state) {
      var ids = this.backendTableVisibleRowIds(state);
      return !!ids.length && ids.every(function (id) { return !!state.selected[id]; });
    },
    backendTableToggleSelectAllVisible: function (tableId) {
      var state = this.backendTableState(tableId);
      var ids = this.backendTableVisibleRowIds(state);
      var all = this.backendTableAllVisibleSelected(state);
      state.selected = Object.assign({}, state.selected || {});
      ids.forEach(function (id) { state.selected[id] = !all; });
    },
    backendTableClearSelection: function (tableId) { this.backendTableState(tableId).selected = {}; },
    backendTableToggleExpand: function (tableId, row) {
      var state = this.backendTableState(tableId);
      var key = (row && (row.id || row.key)) || '';
      if (!key) return;
      state.expanded = Object.assign({}, state.expanded || {});
      state.expanded[key] = !state.expanded[key];
    },
    backendTableToggleGroup: function (tableId, groupKey) {
      var state = this.backendTableState(tableId);
      state.groupExpanded = Object.assign({}, state.groupExpanded || {});
      state.groupExpanded[groupKey] = !state.groupExpanded[groupKey];
    },
    backendTableIsGroupExpanded: function (state, groupKey) { return !!((state || {}).groupExpanded || {})[groupKey]; },
    backendTableIsSelected: function (state, row) { return !!((state || {}).selected || {})[(row && (row.id || row.key)) || '']; },
    backendTableIsExpanded: function (state, row) { return !!((state || {}).expanded || {})[(row && (row.id || row.key)) || '']; },
    backendTableSelectedIds: function (state) {
      return Object.keys((state || {}).selected || {}).filter(function (key) { return !!state.selected[key]; });
    },
    backendTableSelectedCount: function (state) { return this.backendTableSelectedIds(state).length; },
    backendTableRunAction: function (tableId, action, row) {
      var key = (action || {}).key || action || '';
      var state = this.backendTableState(tableId);
      if (key === 'edit') return this.backendTableOpenRowEditor(tableId, row);
      if (key === 'duplicate') return this.backendTableOpenRowEditor(tableId, Object.assign({}, clone(row), { id: '' }));
      if (key === 'delete') { if (typeof confirm === 'function' && !confirm('Delete this row?')) return null; return this.backendTableMutate(tableId, 'row.delete', { rowId: (row || {}).id }).then(function(){ state.toast = 'Row deleted'; }); }
      if (this.showAlert) this.showAlert('Table action', ((action || {}).label || key || 'Action') + ' queued for ' + ((row || {}).name || (row || {}).id || 'row'));
    },
    backendTableRunBulkAction: function (tableId, action) {
      var state = this.backendTableState(tableId);
      var key = (action || {}).key || action || '';
      var ids = this.backendTableSelectedIds(state);
      if (!ids.length) return;
      if (key === 'bulk.delete' || key === 'delete') { if (typeof confirm === 'function' && !confirm('Delete ' + ids.length + ' selected row(s)?')) return null; return this.backendTableMutate(tableId, 'rows.delete', { ids: ids }).then(function(){ state.toast = ids.length + ' row(s) deleted'; }); }
      if (this.showAlert) this.showAlert('Bulk table action', ((action || {}).label || key || 'Action') + ' applied to ' + ids.length + ' row(s)');
    },
    backendTableCellText: function (row, column) {
      var value = row ? row[column.key] : '';
      if (value === null || typeof value === 'undefined') return '';
      return String(value);
    },
    backendTableOpenRowEditor: function (tableId, row) {
      var state = this.backendTableState(tableId);
      state.validation = {};
      state.editor = { open: true, mode: 'row', title: row && row.id ? 'Edit row' : 'Add row', row: clone(row || {}), column: {} };
    },
    backendTableOpenColumnEditor: function (tableId, column) {
      var state = this.backendTableState(tableId);
      state.validation = {};
      state.editor = { open: true, mode: 'column', title: column && column.key ? 'Edit column' : 'Add column', row: {}, column: clone(column || { key: '', label: '', type: 'text', width: 140, sortable: true, resizable: true, hidden: false }) };
    },
    backendTableCloseEditor: function (tableId) { this.backendTableState(tableId).editor.open = false; },
    backendTableValidateEditor: function (state) {
      var editor = (state || {}).editor || {};
      var errors = {};
      if (editor.mode === 'column') {
        var key = String((editor.column || {}).key || '').trim();
        if (!/^[A-Za-z][A-Za-z0-9_]{0,63}$/.test(key)) errors.key = 'Column key must start with a letter and contain only letters, numbers, and underscores.';
      } else {
        var visible = normalizeColumns((state || {}).columns || []).filter(function (col) { return !col.hidden && col.key !== 'id'; });
        if (visible.length && !visible.some(function (col) { return String((editor.row || {})[col.key] || '').trim(); })) errors.row = 'At least one visible field must be provided.';
      }
      state.validation = errors;
      return !Object.keys(errors).length;
    },
    backendTableSaveEditor: function (tableId) {
      var state = this.backendTableState(tableId);
      if (!this.backendTableValidateEditor(state)) return Promise.reject(new Error('Table editor validation failed'));
      if ((state.editor || {}).mode === 'column') return this.backendTableMutate(tableId, 'column.save', { column: clone(state.editor.column || {}) }).then(function(){ state.toast = 'Column saved'; });
      return this.backendTableMutate(tableId, 'row.save', { row: clone(state.editor.row || {}) }).then(function(){ state.toast = 'Row saved'; });
    },
    backendTableDeleteColumn: function (tableId, column) {
      if (!column || !column.key) return;
      if (typeof confirm === 'function' && !confirm('Delete column ' + column.label + '?')) return null;
      return this.backendTableMutate(tableId, 'column.delete', { columnKey: column.key });
    },
    backendTableBeginColumnResize: function (tableId, column, event) {
      var state = this.backendTableState(tableId);
      if (!column || column.resizable === false || !event) return;
      state.columnResize = { key: column.key, startX: event.clientX, startWidth: +column.width || 120, width: +column.width || 120 };
      var vm = this;
      function move(e) { vm.backendTableMoveColumnResize(tableId, e); }
      function up() {
        document.removeEventListener('pointermove', move);
        document.removeEventListener('pointerup', up);
        var resize = state.columnResize;
        state.columnResize = null;
        if (resize && resize.key) vm.backendTableMutate(tableId, 'column.resize', { columnKey: resize.key, width: resize.width || resize.startWidth }).catch(function () {});
      }
      document.addEventListener('pointermove', move);
      document.addEventListener('pointerup', up, { once: true });
    },
    backendTableMoveColumnResize: function (tableId, event) {
      var state = this.backendTableState(tableId);
      var resize = state.columnResize;
      if (!resize || !event) return;
      var next = Math.max(48, resize.startWidth + (event.clientX - resize.startX));
      resize.width = next;
      state.columns = normalizeColumns(state.columns).map(function (col) { if (col.key === resize.key) col.width = next; return col; });
    },
    backendTableApplyConfig: function (tableId, config) {
      var state = this.backendTableState(tableId);
      state.config = mergeConfig(defaultTableConfig(), config || state.config || {});
      if (state.config.defaultPageSize) state.pagination.pageSize = +state.config.defaultPageSize || state.pagination.pageSize;
      if (state.config.defaultSort) state.sort = clone(state.config.defaultSort);
      if (state.config.columns && state.config.columns.length) state.columns = normalizeColumns(state.config.columns);
      return state.config;
    },
    backendTableFeature: function (state, key) {
      var cfg = mergeConfig(defaultTableConfig(), (state || {}).config || {});
      return !!((cfg.features || {})[key]);
    },
    backendTableContract: function () { return TABLE_CONTRACT; },
    openBackendTableWindow: function (options) {
      options = options || {};
      var id = 'win-table-' + Date.now();
      this.windows.push({ id: id, appKey: options.appKey || 'backend-table', title: options.title || 'Backend Table', state: 'normal', left: 180, top: 92, width: 1120, height: 720, z: this.zCounter + 1, tableState: { id: id, title: options.title || 'Backend Table', dataset: options.dataset || 'demo', folderId: options.folderId || '', config: mergeConfig(defaultTableConfig(), options.config || {}) } });
      this.focusWindow(id);
      return id;
    }
  };

  function register(app) {
    if (!app || !app.component) return;
    app.component('mioos-full-table', {
      props: ['tableId', 'title', 'dataset', 'folderId', 'config'],
      data: function () { return { searchInput: '' }; },
      computed: {
        vm: function () { return root(this); },
        state: function () { return this.vm.backendTableState(this.tableId || 'mioos-table'); },
        columns: function () { return this.vm.backendTableVisibleColumns(this.state); },
        allColumns: function () { return this.vm.backendTableAllColumns(this.state); },
        columnGroups: function () { return this.vm.backendTableColumnGroupRows(this.state); },
        rowGroups: function () { return this.vm.backendTableGroupedRows(this.state); },
        selectedCount: function () { return this.vm.backendTableSelectedCount(this.state); },
        filterableColumns: function () { return this.vm.backendTableFilterableColumns(this.state); }
      },
      mounted: function () {
        var state = this.state;
        state.title = this.title || state.title;
        state.dataset = this.dataset || state.dataset || 'demo';
        state.folderId = this.folderId || state.folderId || '';
        this.vm.backendTableApplyConfig(this.tableId || state.id, this.config || state.config || {});
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
            '<div><strong>[[ state.title || title || \'Backend Table\' ]]</strong><span>HTTP server pagination, sorting, grouping, bulk actions, and CRUD</span></div>' +
            '<label v-if="vm.backendTableFeature(state, &quot;datasetSwitcher&quot;)"><span>Dataset</span><select :value="state.dataset" @change="vm.backendTableSetDataset(tableId || state.id, $event.target.value)"><option value="demo">Sample table</option><option value="patient-registration">Patient registration</option><option value="ui-elements">UI + form elements</option><option value="massive">Massive dataset</option><option value="vfs">VFS folder</option></select></label>' +
            '<label v-if="vm.backendTableFeature(state, &quot;search&quot;)" class="mioos-table-search"><span>Search</span><input v-model="searchInput" @keydown.enter="commitSearch" @blur="commitSearch" placeholder="Filter rows" aria-label="Search table rows"></label>' +
            '<details v-if="vm.backendTableFeature(state, &quot;filters&quot;)" class="mioos-table-filters"><summary>Filters</summary><label v-for="col in filterableColumns" :key="col.key"><span>[[ col.label ]]</span><input :value="vm.backendTableFilterValue(state, col.key)" @change="vm.backendTableSetFilter(tableId || state.id, col.key, $event.target.value)" placeholder="Exact value"></label><button type="button" @click="vm.backendTableClearFilters(tableId || state.id)">Clear filters</button></details>' +
            '<label v-if="vm.backendTableFeature(state, &quot;grouping&quot;)"><span>Group</span><select :value="state.groupBy" @change="vm.backendTableSetGroupBy(tableId || state.id, $event.target.value)"><option value="">None</option><option v-for="col in allColumns" :key="col.key" :value="col.key">[[ col.label ]]</option></select></label>' +
            '<details v-if="vm.backendTableFeature(state, &quot;columnPicker&quot;)" class="mioos-table-column-picker"><summary>Columns</summary><button v-for="col in allColumns" :key="col.key" type="button" @click="vm.backendTableToggleColumn(tableId || state.id, col.key)"><span>[[ col.hidden ? \'☐\' : \'☑\' ]]</span> [[ col.label ]]</button></details>' +
            '<button v-if="vm.backendTableFeature(state, &quot;rowCrud&quot;)" type="button" class="mioos-btn" @click="vm.backendTableOpenRowEditor(tableId || state.id)">Add row</button>' +
            '<button v-if="vm.backendTableFeature(state, &quot;columnCrud&quot;)" type="button" class="mioos-btn" @click="vm.backendTableOpenColumnEditor(tableId || state.id)">Add column</button>' +
          '</header>' +
          '<div class="mioos-table-status" role="status" v-if="state.loading || state.saving">[[ state.saving ? state.config.saveMessage : state.config.loadingMessage ]]</div><div class="mioos-table-toast" role="status" v-if="state.toast">[[ state.toast ]]</div><div class="mioos-table-bulkbar" v-if="selectedCount && vm.backendTableFeature(state, &quot;bulkActions&quot;)"><span>[[ selectedCount ]] selected</span><button v-for="action in state.bulkActions" :key="action.key" type="button" @click="vm.backendTableRunBulkAction(tableId || state.id, action)">[[ action.label ]]</button><button type="button" @click="vm.backendTableClearSelection(tableId || state.id)">Clear</button></div>' +
          '<div class="mioos-table-error" v-if="state.error">[[ state.error ]]</div>' +
          '<div class="mioos-table-editor" v-if="state.editor && state.editor.open">' +
            '<header><strong>[[ state.editor.title ]]</strong><button type="button" @click="vm.backendTableCloseEditor(tableId || state.id)">×</button></header>' +
            '<section v-if="state.editor.mode === \'row\'" class="mioos-table-form-grid"><label v-for="col in allColumns" :key="col.key"><span>[[ col.label ]]</span><input v-model="state.editor.row[col.key]" :placeholder="col.key"></label></section>' +
            '<section v-else class="mioos-table-form-grid"><label><span>Key</span><input v-model="state.editor.column.key" placeholder="fieldName"></label><label><span>Label</span><input v-model="state.editor.column.label" placeholder="Column label"></label><label><span>Type</span><select v-model="state.editor.column.type"><option>text</option><option>badge</option><option>date</option><option>number</option><option>boolean</option></select></label><label><span>Width</span><input type="number" v-model="state.editor.column.width"></label><label><span>Group</span><input v-model="state.editor.column.group" placeholder="Optional header group"></label><label><span>Hidden</span><input type="checkbox" v-model="state.editor.column.hidden"></label></section>' +
            '<p class="mioos-table-error" v-for="err in Object.values(state.validation || {})" :key="err">[[ err ]]</p><footer><button type="button" class="mioos-btn is-primary" @click="vm.backendTableSaveEditor(tableId || state.id)">Save</button><button type="button" class="mioos-btn" @click="vm.backendTableCloseEditor(tableId || state.id)">Cancel</button></footer>' +
          '</div>' +
          '<div class="mioos-table-wrap">' +
            '<table class="mioos-table-grid" role="grid">' +
              '<colgroup><col class="mioos-table-select-col"><col v-for="col in columns" :key="col.key" :style="vm.backendTableColumnStyle(col)"><col class="mioos-table-actions-col"></colgroup>' +
              '<thead>' +
                '<tr class="mioos-table-groups"><th></th><th v-for="group in columnGroups" :key="group.label + group.span" :colspan="group.span">[[ group.label ]]</th><th></th></tr>' +
                '<tr><th><label class="mioos-table-select-all"><input type="checkbox" :checked="vm.backendTableAllVisibleSelected(state)" @change="vm.backendTableToggleSelectAllVisible(tableId || state.id)"><span>Select all</span></label></th><th v-for="col in columns" :key="col.key"><button type="button" @click="vm.backendTableSortBy(tableId || state.id, col)">[[ col.label ]] [[ vm.backendTableSortMark(state, col) ]]</button><button v-if="vm.backendTableFeature(state, &quot;columnCrud&quot;)" type="button" class="mioos-table-col-edit" title="Edit column" @click.stop="vm.backendTableOpenColumnEditor(tableId || state.id, col)">⚙</button><button v-if="vm.backendTableFeature(state, &quot;columnCrud&quot;)" type="button" class="mioos-table-col-delete" title="Delete column" @click.stop="vm.backendTableDeleteColumn(tableId || state.id, col)">×</button><span v-if="vm.backendTableFeature(state, &quot;resizeColumns&quot;)" class="mioos-table-resizer" @pointerdown.prevent="vm.backendTableBeginColumnResize(tableId || state.id, col, $event)"></span></th><th>Actions</th></tr>' +
              '</thead>' +
              '<tbody>' +
                '<tr v-if="!state.loading && !state.rows.length" class="mioos-table-empty-row"><td :colspan="columns.length + 2">[[ state.config.emptyMessage ]]</td></tr>' +
                '<template v-for="group in rowGroups" :key="group.key || \'all\'">' +
                  '<tr v-if="state.groupBy" class="mioos-table-group-row"><td :colspan="columns.length + 2"><button type="button" @click="vm.backendTableToggleGroup(tableId || state.id, group.key)">[[ vm.backendTableIsGroupExpanded(state, group.key) ? \'▾\' : \'▸\' ]]</button><strong>[[ group.label ]]</strong><span>[[ group.count ]] rows</span></td></tr>' +
                  '<template v-if="!state.groupBy || vm.backendTableIsGroupExpanded(state, group.key)">' +
                    '<template v-for="row in group.rows" :key="keyOf(row)">' +
                      '<tr :class="{ \'is-selected\': vm.backendTableIsSelected(state, row) }"><td><input type="checkbox" :checked="vm.backendTableIsSelected(state, row)" @change="vm.backendTableToggleRow(tableId || state.id, row)"></td><td v-for="col in columns" :key="col.key"><span :class="\'mioos-table-cell type-\' + col.type">[[ vm.backendTableCellText(row, col) ]]</span></td><td class="mioos-table-actions"><button v-if="row._expand && vm.backendTableFeature(state, &quot;rowDetails&quot;)" type="button" @click="vm.backendTableToggleExpand(tableId || state.id, row)">[[ vm.backendTableIsExpanded(state, row) ? \'Hide\' : \'Details\' ]]</button><button v-for="action in state.rowActions" :key="action.key" type="button" @click="vm.backendTableRunAction(tableId || state.id, action, row)">[[ action.label ]]</button></td></tr>' +
                      '<tr v-if="vm.backendTableIsExpanded(state, row)" class="mioos-table-expanded-row"><td></td><td :colspan="columns.length + 1"><strong>[[ (row._expand || {}).title || \'Details\' ]]</strong><p>[[ (row._expand || {}).body || JSON.stringify(row) ]]</p></td></tr>' +
                    '</template>' +
                  '</template>' +
                '</template>' +
              '</tbody>' +
            '</table>' +
          '</div>' +
          '<footer v-if="vm.backendTableFeature(state, &quot;pagination&quot;)" class="mioos-table-pager"><span>[[ state.pagination.filteredRows ]] of [[ state.pagination.totalRows ]] rows</span><button type="button" @click="vm.backendTableSetPage(tableId || state.id, 1)">First</button><button type="button" @click="vm.backendTableSetPage(tableId || state.id, state.pagination.page - 1)">Prev</button><span>Page [[ state.pagination.page ]] / [[ state.pagination.pageCount ]]</span><button type="button" @click="vm.backendTableSetPage(tableId || state.id, state.pagination.page + 1)">Next</button><button type="button" @click="vm.backendTableSetPage(tableId || state.id, state.pagination.pageCount)">Last</button><label>Rows <select :value="state.pagination.pageSize" @change="vm.backendTableSetPageSize(tableId || state.id, $event.target.value)"><option>10</option><option>25</option><option>50</option><option>100</option><option>250</option></select></label></footer>' +
        '</section>'
    });

    app.component('mioos-surface-table', {
      props: ['window'],
      computed: { state: function () { return (this.window || {}).tableState || {}; } },
      template: '<mioos-full-table :table-id="state.id || window.id" :title="state.title || window.title" :dataset="state.dataset || \'demo\'" :folder-id="state.folderId || \'\'"></mioos-full-table>'
    });
  }

  window.MIOOSTable = { contract: TABLE_CONTRACT, defaultConfig: defaultTableConfig, createConfig: function (patch) { return mergeConfig(defaultTableConfig(), patch || {}); }, methods: methods, register: register };
  if (window.MIOOSModules && typeof window.MIOOSModules.registerComponent === 'function') {
    window.MIOOSModules.registerComponent({ key: 'table', name: 'mioos-full-table', title: 'Advanced Backend Table', surface: 'mioos-surface-table', description: 'HTTP-first server-side table with sorting, selection, bulk actions, row and column CRUD, resizable columns, grouping, and large datasets.' });
  }
})();
