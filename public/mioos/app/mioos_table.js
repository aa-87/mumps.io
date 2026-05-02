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
      { key: 'updated', label: 'Updated', type: 'date', width: 150, sortable: true, resizable: true, hidden: false, group: '' }
    ];
  }

  var TABLE_CONTRACT = 'mioos-advanced-table-v8';

  function defaultTableConfig() {
    return {
      contract: TABLE_CONTRACT,
      features: { toolbar: true, datasetSwitcher: true, search: true, filters: true, grouping: true, columnPicker: true, columnGroups: false, rowCrud: true, columnCrud: true, selection: true, bulkActions: true, pagination: true, rowDetails: true, resizeColumns: true, serverSide: true, processingIndicator: true },
      columns: [],
      defaultSort: { column: 'name', direction: 'ascending' },
      defaultPageSize: 25,
      readonly: false,
      density: 'compact',
      transport: 'websocket',
      mutateTransport: 'http',
      tableQueryTimeoutMs: 8000,
      tableMutationTimeoutMs: 4500,
      includeDataAlias: false,
      actionsWidth: 156,
      emptyMessage: 'No rows match the current server-side table query.',
      loadingMessage: 'Loading rows from server…',
      saveMessage: 'Saving table changes…',
      processingMessage: 'Server communication in progress'
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


  function mumpsTableSnippet(dataset, extraLines) {
    extraLines = Array.isArray(extraLines) ? extraLines : [];
    var lines = [
      '; 1) Define/seed the dataset in MUMPS',
      'NEW USER,ROOT,MOD',
      'SET USER=$GET(STATE("principal"),"admin")',
      'SET ROOT=$NAME(^MIO("MIOOS","TABLE",USER,"' + dataset + '"))',
      'KILL @ROOT',
      'SET @ROOT@("schema","columns",1,"key")="id"',
      'SET @ROOT@("schema","columns",1,"label")="ID"',
      'SET @ROOT@("schema","columns",1,"type")="text"',
      'SET @ROOT@("schema","columns",1,"width")=120',
      'SET @ROOT@("schema","columns",2,"key")="name"',
      'SET @ROOT@("schema","columns",2,"label")="Name"',
      'SET @ROOT@("schema","columns",2,"type")="text"',
      'SET @ROOT@("schema","columns",2,"width")=220',
      'SET @ROOT@("schema","columns",3,"key")="status"',
      'SET @ROOT@("schema","columns",3,"label")="Status"',
      'SET @ROOT@("schema","columns",3,"type")="badge"',
      'SET @ROOT@("schema","columns",3,"width")=120',
      'SET @ROOT@("rows",1,"id")="' + dataset + '-1"',
      'SET @ROOT@("rows",1,"name")="First row"',
      'SET @ROOT@("rows",1,"status")="Open"',
      'SET @ROOT@("rows",1,"_expand","title")="Details"',
      'SET @ROOT@("rows",1,"_expand","body")="Optional row details shown from the ID/control column."',
      '',
      '; 2) Register/open the table module with MUMPS metadata',
      'KILL MOD',
      'SET MOD("componentKey")="table"',
      'SET MOD("surface")="mioos-surface-table"',
      'SET MOD("tableState","dataset")="' + dataset + '"',
      'SET MOD("tableState","config","contract")="' + TABLE_CONTRACT + '"'
    ];
    extraLines.forEach(function (line) { lines.push(line); });
    lines = lines.concat([
      '',
      '; 3) Routines to reload/test after changing the table contract',
      'ZLINK "MIOOSTBL"',
      'ZLINK "MIOOSAPI"',
      'ZLINK "MIOOSWS"',
      'ZLINK "MIOOSMOD"',
      'ZLINK "MIOOST"',
      'DO INIT^MIOOS(.CONF)',
      'DO ^MIOOST'
    ]);
    return lines.join('\n');
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
    return (Array.isArray(rows) ? rows : defaultRows()).map(function (row, index) {
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

  function normalizeGroupColumns(value, fallback) {
    var list = toList(value).map(function (item) { return typeof item === 'string' ? item : ((item || {}).key || (item || {}).name || ''); }).filter(Boolean);
    if (!list.length && fallback) list = [fallback];
    var seen = {};
    return list.filter(function (key) { if (seen[key]) return false; seen[key] = true; return true; });
  }

  function parseJsonResponse(response, label) {
    return response.text().then(function (text) {
      var payload = null;
      if (text) { try { payload = JSON.parse(text); } catch (err) { payload = null; } }
      if (!response.ok) {
        if (payload) return payload;
        throw new Error(label + ' failed: HTTP ' + response.status + (text ? ' — ' + text.slice(0, 180) : ''));
      }
      if (!text) throw new Error(label + ' returned an empty response from the server');
      if (!payload) throw new Error(label + ' returned invalid JSON');
      return payload;
    });
  }

  function serverErrorMessage(label, err) {
    var base = (err && (err.detail || err.error || err.message)) || 'Failed to fetch';
    var text = String(base || '').toLowerCase();
    if (label === 'Table mutation' && (text.indexOf('timeout') >= 0 || text.indexOf('aborted') >= 0)) return 'Table mutation timed out. The change was not confirmed. Please retry.';
    if (base === 'Failed to fetch') return label + ' could not reach the server. The backend closed the connection or returned no response.';
    return base;
  }

  function extractTablePayload(message) {
    if (message && message.table) return message.table;
    if (message && message.result) return message.result;
    return message || {};
  }

  function shouldFallbackSocket(err) {
    var text = String((err && (err.error || err.detail || err.message)) || '');
    return text === 'command_unsupported' || text === 'socket_unavailable' || text === 'socket_closed' || text === 'socket_error' || text === 'socket_send_failed' || text === 'socket_timeout' || text === 'socket_request_timeout' || text === 'worker_command_timeout' || text.indexOf('timeout') >= 0;
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
        processing: false,
        error: '',
        rows: defaultRows(),
        columns: defaultColumns(),
        selected: {},
        expanded: {},
        search: '',
        groupBy: '',
        groupByColumns: [],
        draw: 0,
        lastDraw: 0,
        requestLabel: '',
        lastServerAt: '',
        features: {},
        actionsWidth: 156,
        sort: { column: 'name', direction: 'ascending' },
        pagination: { page: 1, pageSize: 25, totalRows: 3, filteredRows: 3, pageRows: 3, pageCount: 1 },
        pageJump: '1',
        rowActions: [{ key: 'edit', label: 'Edit' }, { key: 'duplicate', label: 'Duplicate' }, { key: 'delete', label: 'Delete' }],
        bulkActions: [{ key: 'export', label: 'Export selected' }, { key: 'bulk.delete', label: 'Delete selected' }],
        groups: [],
        filters: {},
        filterDraft: {},
        config: defaultTableConfig(),
        toast: '',
        validation: {},
        columnResize: null,
        columnPickerOpen: false,
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
    backendTableQueryPayload: function (state, draw) {
      var page = +(state.pagination || {}).page || 1;
      var pageSize = +(state.pagination || {}).pageSize || 25;
      var columns = normalizeColumns(state.columns);
      var sort = clone(state.sort || { column: 'name', direction: 'ascending' });
      var orderIndex = Math.max(0, columns.findIndex(function (col) { return col.key === sort.column; }));
      var groupByColumns = normalizeGroupColumns(state.groupByColumns || [], state.groupBy || '');
      return {
        dataset: state.dataset || 'demo',
        folderId: state.folderId || '',
        page: page,
        pageSize: pageSize,
        draw: draw || +(state.draw || 0),
        start: Math.max(0, (page - 1) * pageSize),
        length: pageSize,
        serverSide: true,
        processing: true,
        search: state.search || '',
        groupBy: groupByColumns.length ? groupByColumns[0] : (state.groupBy || ''),
        groupByColumns: groupByColumns,
        includeDataAlias: !!(((state.config || {}).includeDataAlias)),
        sort: sort,
        order: [{ column: orderIndex, dir: sort.direction === 'descending' ? 'desc' : 'asc', name: sort.column || '' }],
        filters: clone(state.filters || {}),
        columns: columns.map(function (col) { return { key: col.key, data: col.key, name: col.key, label: col.label, searchable: col.searchable !== false, orderable: col.sortable !== false, hidden: !!col.hidden, width: col.width }; })
      };
    },
    backendTableUseWebSocket: function (state, operation) {
      var cfg = mergeConfig(defaultTableConfig(), (state || {}).config || {});
      var transport = operation === 'mutate' ? (cfg.mutateTransport || 'http') : (cfg.transport || 'websocket');
      if (transport === 'http') return false;
      return typeof this.command === 'function';
    },
    backendTableTimeoutMs: function (state, operation) {
      var cfg = mergeConfig(defaultTableConfig(), (state || {}).config || {});
      return Math.max(1000, +(operation === 'mutate' ? cfg.tableMutationTimeoutMs : cfg.tableQueryTimeoutMs) || (operation === 'mutate' ? 4500 : 8000));
    },
    backendTableHttpPost: function (route, payload, label, timeoutMs) {
      var controller = (typeof AbortController !== 'undefined') ? new AbortController() : null;
      var timer = null;
      if (controller && timeoutMs) timer = window.setTimeout(function () { try { controller.abort(); } catch (ignore) {} }, timeoutMs);
      return fetch(route, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'same-origin',
        signal: controller ? controller.signal : undefined,
        body: JSON.stringify(payload)
      }).then(function (response) { return parseJsonResponse(response, label); }).catch(function (err) {
        if (err && err.name === 'AbortError') throw new Error('table_request_timeout');
        throw err;
      }).finally(function () { if (timer) window.clearTimeout(timer); });
    },
    backendTableFetch: function (tableId, patch) {
      var state = this.backendTableState(tableId);
      var route = this.backendTableRoute();
      var vm = this;
      Object.assign(state, patch || {});
      state.draw = +(state.draw || 0) + 1;
      state.loading = true;
      state.processing = true;
      state.requestLabel = 'Loading rows from server';
      state.error = '';
      var body = this.backendTableQueryPayload(state, state.draw);
      var timeoutMs = this.backendTableTimeoutMs(state, 'query');
      var request = this.backendTableUseWebSocket(state, 'query')
        ? this.command('table.query', body, { timeoutMs: timeoutMs }).then(extractTablePayload).catch(function (err) { if (shouldFallbackSocket(err)) return vm.backendTableHttpPost(route, body, 'Table query', timeoutMs); throw err; })
        : this.backendTableHttpPost(route, body, 'Table query', timeoutMs);
      return request.then(function (payload) {
        vm.backendTableApplyPayload(state, payload || {});
        return state;
      }).catch(function (err) {
        state.error = serverErrorMessage('Table query', err);
        return state;
      }).finally(function () {
        state.loading = false;
        state.processing = false;
        state.requestLabel = '';
      });
    },
    backendTableMutate: function (tableId, action, payload) {
      var state = this.backendTableState(tableId);
      var vm = this;
      state.draw = +(state.draw || 0) + 1;
      var body = Object.assign({}, payload || {}, { action: action, dataset: state.dataset || 'demo', mutationOnly: true, draw: state.draw });
      state.saving = true;
      state.processing = true;
      state.requestLabel = 'Sending table mutation to server';
      state.error = '';
      state.validation = {};
      var route = this.backendTableMutateRoute();
      var timeoutMs = this.backendTableTimeoutMs(state, 'mutate');
      var request = this.backendTableUseWebSocket(state, 'mutate')
        ? this.command('table.mutate', body, { timeoutMs: timeoutMs }).then(extractTablePayload).catch(function (err) { if (shouldFallbackSocket(err)) return vm.backendTableHttpPost(route, body, 'Table mutation', timeoutMs); throw err; })
        : this.backendTableHttpPost(route, body, 'Table mutation', timeoutMs);
      return request.then(function (payload) {
        payload = payload || {};
        if (payload.ok === false) {
          state.error = payload.message || payload.detail || payload.error || 'Table mutation failed';
          state.validation = clone(payload.fieldErrors || {});
          return payload;
        }
        state.toast = payload.message || 'Table mutation saved';
        state.selected = {};
        state.editor.open = false;
        if (payload.refetch === false) return payload;
        return vm.backendTableFetch(tableId).then(function () { return payload; });
      }).catch(function (err) {
        state.error = serverErrorMessage('Table mutation', err);
        return { ok: false, error: state.error, mutationOnly: true, refetch: false };
      }).finally(function () {
        state.saving = false;
        state.processing = false;
        state.requestLabel = '';
      });
    },
    backendTableApplyPayload: function (state, payload) {
      payload = payload || {};
      if (payload.mutationOnly) {
        if (payload.ok === false) state.error = payload.message || payload.error || payload.detail || 'Table mutation failed';
        return;
      }
      if (payload.draw && payload.draw < +(state.lastDraw || 0)) return;
      if (payload.draw) state.lastDraw = +payload.draw;
      state.lastServerAt = new Date().toLocaleTimeString();
      state.features = Object.assign({}, payload.features || {});
      state.readOnly = !!(+((state.features || {}).readOnly || 0)) || !!((state.config || {}).readonly);
      if (payload.groupByColumns) state.groupByColumns = normalizeGroupColumns(payload.groupByColumns || [], '');
      state.groupBy = (state.groupByColumns || [])[0] || state.groupBy || '';
      var schemaColumns = (((payload.schema || {}).columns) || []);
      var payloadRows = Array.isArray(payload.rows) ? payload.rows : (Array.isArray(payload.data) ? payload.data : []);
      state.columns = normalizeColumns(schemaColumns.length ? schemaColumns : state.columns);
      state.rows = normalizeRows(payloadRows);
      state.pagination = Object.assign({}, state.pagination || {}, payload.pagination || {});
      if (typeof payload.recordsTotal !== 'undefined') state.pagination.totalRows = +payload.recordsTotal || 0;
      if (typeof payload.recordsFiltered !== 'undefined') state.pagination.filteredRows = +payload.recordsFiltered || 0;
      state.rowActions = (payload || {}).rowActions || state.rowActions || [];
      state.bulkActions = (payload || {}).bulkActions || state.bulkActions || [];
      state.groups = toList((payload || {}).groups);
      state.error = payload && payload.ok === false ? (payload.error || payload.detail || 'Table request failed') : state.error;
      if (!normalizeGroupColumns(state.groupByColumns || [], state.groupBy || '').length) state.groupExpanded = {};
      if (normalizeGroupColumns(state.groupByColumns || [], state.groupBy || '').length && !Object.keys(state.groupExpanded || {}).length) {
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
    backendTableVisibleRowActions: function (state) {
      if (!this.backendTableFeature(state, 'rowCrud')) return [];
      return ((state || {}).rowActions || []).filter(function (action) {
        var key = (action || {}).key || '';
        return key === 'edit' || key === 'duplicate' || key === 'delete';
      });
    },
    backendTableShowSelection: function (state) {
      return this.backendTableFeature(state, 'selection');
    },
    backendTableShowActions: function (state) {
      return this.backendTableVisibleRowActions(state).length > 0;
    },
    backendTableShowControl: function (state) {
      return this.backendTableShowSelection(state) || this.backendTableFeature(state, 'rowDetails');
    },
    backendTableColspan: function (state) {
      return this.backendTableVisibleColumns(state).length + (this.backendTableShowControl(state) ? 1 : 0) + (this.backendTableShowActions(state) ? 1 : 0);
    },
    backendTableAllColumns: function (state) { return normalizeColumns((state || {}).columns || []); },
    backendTableColumnStyle: function (column) { return { width: Math.max(48, +(column || {}).width || 120) + 'px' }; },
    backendTableActionsStyle: function (state) { return { width: Math.max(96, +((state || {}).actionsWidth || (((state || {}).config || {}).actionsWidth) || 156)) + 'px' }; },
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
    backendTableGroupColumns: function (state) {
      return normalizeGroupColumns((state || {}).groupByColumns || [], (state || {}).groupBy || '');
    },
    backendTableGroupedRows: function (state) {
      var rows = normalizeRows((state || {}).rows || []);
      var keys = normalizeGroupColumns((state || {}).groupByColumns || [], (state || {}).groupBy || '');
      if (!keys.length) return [{ key: '', label: '', rows: rows, count: rows.length, ungrouped: true }];
      var map = {};
      rows.forEach(function (row) {
        var label = keys.map(function (key) { return String(row[key] == null || row[key] === '' ? '(blank)' : row[key]); }).join(' / ');
        var compound = keys.map(function (key) { return key + '=' + String(row[key] == null || row[key] === '' ? '(blank)' : row[key]); }).join(' / ');
        if (!map[compound]) map[compound] = { key: compound, label: label, rows: [], count: 0 };
        map[compound].rows.push(row);
        map[compound].count += 1;
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
    backendTableOpenColumnPicker: function (tableId) { this.backendTableState(tableId).columnPickerOpen = true; },
    backendTableCloseColumnPicker: function (tableId) { this.backendTableState(tableId).columnPickerOpen = false; },
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
      state.groupByColumns = [];
      state.groupBy = '';
      state.groupExpanded = {};
      return this.backendTableFetch(tableId);
    },
    backendTableSetPage: function (tableId, page) {
      var state = this.backendTableState(tableId);
      var max = +((state.pagination || {}).pageCount) || 1;
      state.pagination.page = Math.min(Math.max(1, +page || 1), max);
      state.pageJump = String(state.pagination.page);
      return this.backendTableFetch(tableId);
    },
    backendTableJumpPage: function (tableId, page) {
      var state = this.backendTableState(tableId);
      var max = +((state.pagination || {}).pageCount) || 1;
      var next = Math.min(Math.max(1, +page || 1), max);
      state.pageJump = String(next);
      return this.backendTableSetPage(tableId, next);
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
      if (!this.backendTableFeature(state, 'columnCrud')) return Promise.resolve(state);
      return this.backendTableMutate(tableId, 'column.visibility', { columnKey: key, hidden: nextHidden }).catch(function () {});
    },
    backendTableSetGroupBy: function (tableId, key) {
      var state = this.backendTableState(tableId);
      state.groupByColumns = key ? [key] : [];
      state.groupBy = key || '';
      state.groupExpanded = {};
      return this.backendTableFetch(tableId);
    },
    backendTableToggleGroupByColumn: function (tableId, key) {
      var state = this.backendTableState(tableId);
      var list = normalizeGroupColumns(state.groupByColumns || [], state.groupBy || '');
      if (list.indexOf(key) >= 0) list = list.filter(function (item) { return item !== key; });
      else list.push(key);
      state.groupByColumns = list;
      state.groupBy = list[0] || '';
      state.groupExpanded = {};
      state.pagination.page = 1;
      return this.backendTableFetch(tableId);
    },
    backendTableGroupColumnActive: function (state, key) {
      return normalizeGroupColumns((state || {}).groupByColumns || [], (state || {}).groupBy || '').indexOf(key) >= 0;
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
      if (!this.backendTableFeature(state, 'rowCrud') && (key === 'edit' || key === 'duplicate' || key === 'delete')) return null;
      if (key === 'edit') return this.backendTableOpenRowEditor(tableId, row);
      if (key === 'duplicate') return this.backendTableOpenRowEditor(tableId, Object.assign({}, clone(row), { id: '' }));
      if (key === 'delete') { if (typeof confirm === 'function' && !confirm('Delete this row?')) return null; return this.backendTableMutate(tableId, 'row.delete', { rowId: (row || {}).id }).then(function(payload){ if (payload && payload.ok !== false) state.toast = 'Row deleted'; }); }
      if (this.showAlert) this.showAlert('Table action', ((action || {}).label || key || 'Action') + ' queued for ' + ((row || {}).name || (row || {}).id || 'row'));
    },
    backendTableRunBulkAction: function (tableId, action) {
      var state = this.backendTableState(tableId);
      var key = (action || {}).key || action || '';
      var ids = this.backendTableSelectedIds(state);
      if (!ids.length) return;
      if ((key === 'bulk.delete' || key === 'delete') && !this.backendTableFeature(state, 'rowCrud')) return null;
      if (key === 'bulk.delete' || key === 'delete') { if (typeof confirm === 'function' && !confirm('Delete ' + ids.length + ' selected row(s)?')) return null; return this.backendTableMutate(tableId, 'rows.delete', { ids: ids }).then(function(payload){ if (payload && payload.ok !== false) state.toast = ids.length + ' row(s) deleted'; }); }
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
      if (!this.backendTableFeature(state, 'columnCrud')) return null;
      state.validation = {};
      state.columnPickerOpen = false;
      state.editor = { open: true, mode: 'column', title: column && column.key ? 'Column designer: edit column' : 'Column designer: add column', row: {}, column: clone(column || { key: '', label: '', type: 'text', width: 140, sortable: true, resizable: true, hidden: false }) };
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
      if (!this.backendTableValidateEditor(state)) { state.error = 'Please fix the highlighted table editor fields.'; return Promise.resolve({ ok: false, error: 'validation_failed' }); }
      if ((state.editor || {}).mode === 'column') return this.backendTableMutate(tableId, 'column.save', { column: clone(state.editor.column || {}) }).then(function(payload){ if (payload && payload.ok !== false) state.toast = 'Column saved'; });
      return this.backendTableMutate(tableId, 'row.save', { row: clone(state.editor.row || {}) }).then(function(payload){ if (payload && payload.ok !== false) state.toast = 'Row saved'; });
    },
    backendTableDeleteColumn: function (tableId, column) {
      if (!column || !column.key) return;
      if (!this.backendTableFeature(this.backendTableState(tableId), 'columnCrud')) return null;
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
        if (resize && resize.key && vm.backendTableFeature(state, 'columnCrud')) vm.backendTableMutate(tableId, 'column.resize', { columnKey: resize.key, width: resize.width || resize.startWidth }).catch(function () {});
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
    backendTableBeginActionsResize: function (tableId, event) {
      var state = this.backendTableState(tableId);
      if (!event) return;
      state.actionsResize = { startX: event.clientX, startWidth: +(state.actionsWidth || ((state.config || {}).actionsWidth) || 156), width: +(state.actionsWidth || ((state.config || {}).actionsWidth) || 156) };
      var vm = this;
      function move(e) { vm.backendTableMoveActionsResize(tableId, e); }
      function up() {
        document.removeEventListener('pointermove', move);
        document.removeEventListener('pointerup', up);
        state.actionsResize = null;
      }
      document.addEventListener('pointermove', move);
      document.addEventListener('pointerup', up, { once: true });
    },
    backendTableMoveActionsResize: function (tableId, event) {
      var state = this.backendTableState(tableId);
      var resize = state.actionsResize;
      if (!resize || !event) return;
      var next = Math.max(96, resize.startWidth + (event.clientX - resize.startX));
      resize.width = next;
      state.actionsWidth = next;
    },
    backendTableApplyConfig: function (tableId, config) {
      var state = this.backendTableState(tableId);
      state.config = mergeConfig(defaultTableConfig(), config || state.config || {});
      if (state.config.defaultPageSize) state.pagination.pageSize = +state.config.defaultPageSize || state.pagination.pageSize;
      if (state.config.defaultSort) state.sort = clone(state.config.defaultSort);
      if (state.config.groupByColumns) state.groupByColumns = normalizeGroupColumns(state.config.groupByColumns || [], state.config.groupBy || '');
      if (state.config.groupBy && !state.groupByColumns.length) state.groupByColumns = [state.config.groupBy];
      state.groupBy = (state.groupByColumns || [])[0] || state.groupBy || '';
      if (state.config.columns && state.config.columns.length) state.columns = normalizeColumns(state.config.columns);
      state.actionsWidth = Math.max(96, +(state.config.actionsWidth || state.actionsWidth || 156));
      return state.config;
    },
    backendTableFeature: function (state, key) {
      var cfg = mergeConfig(defaultTableConfig(), (state || {}).config || {});
      var enabled = !!((cfg.features || {})[key]);
      var map = { rowCrud: 'crudRows', columnCrud: 'crudColumns', rowDetails: 'expansionRows', resizeColumns: 'resizableColumns', filters: 'filtering', grouping: 'columnGrouping', bulkActions: 'bulkActions', selection: 'selection', pagination: 'serverPagination' };
      var serverKey = map[key] || key;
      var features = (state || {}).features || {};
      if (Object.prototype.hasOwnProperty.call(features, serverKey) && (+features[serverKey] === 0 || features[serverKey] === false)) return false;
      if ((state || {}).readOnly && (key === 'rowCrud' || key === 'columnCrud')) return false;
      return enabled;
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
        '<section class="mioos-full-table" :class="[\'density-\' + ((state.config || {}).density || \'compact\'), { \'is-processing\': state.loading || state.saving, \'is-readonly\': state.readOnly }]" :aria-busy="(state.loading || state.saving) ? \'true\' : \'false\'">' +
          '<header class="mioos-table-toolbar">' +
            '<div><strong>[[ state.title || title || \'Backend Table\' ]]</strong><span>Server-side table · dense MUMPS module API</span></div>' +
            '<label v-if="vm.backendTableFeature(state, &quot;datasetSwitcher&quot;)"><span>Dataset</span><select :value="state.dataset" @change="vm.backendTableSetDataset(tableId || state.id, $event.target.value)"><option value="demo">Sample table</option><option value="patient-registration">Patient registration</option><option value="ui-elements">UI + form elements</option><option value="massive">Massive dataset</option><option value="vfs">VFS folder</option></select></label>' +
            '<label v-if="vm.backendTableFeature(state, &quot;search&quot;)" class="mioos-table-search"><span>Search</span><input v-model="searchInput" :disabled="state.loading || state.saving" @keydown.enter="commitSearch" @blur="commitSearch" placeholder="Filter rows" aria-label="Search table rows"></label>' +
            '<details v-if="vm.backendTableFeature(state, &quot;filters&quot;)" class="mioos-table-filters"><summary>Filters</summary><label v-for="col in filterableColumns" :key="col.key"><span>[[ col.label ]]</span><input :value="vm.backendTableFilterValue(state, col.key)" @change="vm.backendTableSetFilter(tableId || state.id, col.key, $event.target.value)" placeholder="Exact value"></label><button type="button" @click="vm.backendTableClearFilters(tableId || state.id)">Clear filters</button></details>' +
            '<details v-if="vm.backendTableFeature(state, &quot;grouping&quot;)" class="mioos-table-grouping"><summary>Group columns</summary><label v-for="col in allColumns" :key="col.key"><input type="checkbox" :checked="vm.backendTableGroupColumnActive(state, col.key)" @change="vm.backendTableToggleGroupByColumn(tableId || state.id, col.key)"><span>[[ col.label ]]</span></label><div class="mioos-table-group-chips" v-if="vm.backendTableGroupColumns(state).length"><span v-for="key in vm.backendTableGroupColumns(state)" :key="key">[[ key ]]</span></div></details>' +
            '<button v-if="vm.backendTableFeature(state, &quot;columnPicker&quot;)" class="mioos-btn" type="button" @click="vm.backendTableOpenColumnPicker(tableId || state.id)">Columns</button>' +
            '<button v-if="vm.backendTableFeature(state, &quot;rowCrud&quot;)" type="button" class="mioos-btn" @click="vm.backendTableOpenRowEditor(tableId || state.id)">Add row</button>' +
            '<button v-if="vm.backendTableFeature(state, &quot;columnCrud&quot;)" type="button" class="mioos-btn" @click="vm.backendTableOpenColumnEditor(tableId || state.id)">Add column</button>' +
            '<span v-if="state.readOnly" class="mioos-table-readonly">Read-only</span>' +
          '</header>' +
          '<div class="mioos-table-processing" role="status" aria-live="polite" v-if="state.loading || state.saving"><span class="mioos-table-spinner"></span><strong>[[ state.saving ? state.config.saveMessage : state.config.loadingMessage ]]</strong><em>[[ state.requestLabel || state.config.processingMessage ]]</em></div>' +
          '<div class="mioos-table-toast" role="status" v-if="state.toast">[[ state.toast ]]</div>' +
          '<div class="mioos-table-bulkbar" v-if="selectedCount && vm.backendTableFeature(state, &quot;bulkActions&quot;)"><span>[[ selectedCount ]] selected</span><button v-for="action in state.bulkActions" :key="action.key" type="button" @click="vm.backendTableRunBulkAction(tableId || state.id, action)">[[ action.label ]]</button><button type="button" @click="vm.backendTableClearSelection(tableId || state.id)">Clear</button></div>' +
          '<div class="mioos-table-error" v-if="state.error">[[ state.error ]]</div>' +
          '<div class="mioos-table-editor-backdrop" v-if="state.columnPickerOpen" @click.self="vm.backendTableCloseColumnPicker(tableId || state.id)">' +
            '<div class="mioos-table-editor is-column-picker" role="dialog" aria-modal="true">' +
              '<header><strong>Visible columns</strong><button type="button" @click="vm.backendTableCloseColumnPicker(tableId || state.id)">×</button></header>' +
              '<section class="mioos-table-column-list">' +
                '<button v-for="col in allColumns" :key="col.key" type="button" @click="vm.backendTableToggleColumn(tableId || state.id, col.key)">' +
                  '<span>[[ col.hidden ? \'☐\' : \'☑\' ]]</span><b>[[ col.label ]]</b><small>[[ col.key ]]</small>' +
                '</button>' +
              '</section>' +
            '</div>' +
          '</div>' +
          '<div class="mioos-table-editor-backdrop" v-if="state.editor && state.editor.open" @click.self="vm.backendTableCloseEditor(tableId || state.id)">' +
            '<div class="mioos-table-editor" role="dialog" aria-modal="true">' +
              '<header><strong>[[ state.editor.title ]]</strong><button type="button" aria-label="Close editor" @click="vm.backendTableCloseEditor(tableId || state.id)">×</button></header>' +
              '<section v-if="state.editor.mode === \'row\'" class="mioos-table-form-grid"><label v-for="col in allColumns" :key="col.key"><span>[[ col.label ]]</span><input v-model="state.editor.row[col.key]" :placeholder="col.key"></label></section>' +
              '<section v-else class="mioos-table-form-grid"><label><span>Key</span><input v-model="state.editor.column.key" placeholder="fieldName"></label><label><span>Label</span><input v-model="state.editor.column.label" placeholder="Column label"></label><label><span>Type</span><select v-model="state.editor.column.type"><option>text</option><option>badge</option><option>date</option><option>number</option><option>boolean</option></select></label><label><span>Width</span><input type="number" v-model="state.editor.column.width"></label><label><span>Group</span><input v-model="state.editor.column.group" placeholder="Optional header group"></label><label class="mioos-table-check"><span>Hidden</span><input type="checkbox" v-model="state.editor.column.hidden"></label></section>' +
              '<p class="mioos-table-error" v-for="err in Object.values(state.validation || {})" :key="err">[[ err ]]</p><footer><button type="button" class="mioos-btn is-primary" :disabled="state.saving || state.loading" @click="vm.backendTableSaveEditor(tableId || state.id)">[[ state.saving ? &quot;Saving…&quot; : &quot;Save&quot; ]]</button><button type="button" class="mioos-btn" @click="vm.backendTableCloseEditor(tableId || state.id)">Cancel</button></footer>' +
            '</div>' +
          '</div>' +
          '<div class="mioos-table-wrap">' +
            '<table class="mioos-table-grid" role="grid">' +
              '<colgroup><col v-if="vm.backendTableShowControl(state)" class="mioos-table-select-col"><col v-for="col in columns" :key="col.key" :style="vm.backendTableColumnStyle(col)"><col v-if="vm.backendTableShowActions(state)" class="mioos-table-actions-col" :style="vm.backendTableActionsStyle(state)"></colgroup>' +
              '<thead>' +
                '<tr v-if="vm.backendTableFeature(state, &quot;columnGroups&quot;)" class="mioos-table-groups"><th v-if="vm.backendTableShowControl(state)"></th><th v-for="group in columnGroups" :key="group.label + group.span" :colspan="group.span">[[ group.label ]]</th><th v-if="vm.backendTableShowActions(state)"></th></tr>' +
                '<tr><th v-if="vm.backendTableShowControl(state)" class="mioos-table-control-head"><label v-if="vm.backendTableShowSelection(state)" class="mioos-table-select-all"><input type="checkbox" :checked="vm.backendTableAllVisibleSelected(state)" @change="vm.backendTableToggleSelectAllVisible(tableId || state.id)"><span>All</span></label><span v-else class="sr-only">Details</span></th><th v-for="col in columns" :key="col.key"><button type="button" @click="vm.backendTableSortBy(tableId || state.id, col)">[[ col.label ]] [[ vm.backendTableSortMark(state, col) ]]</button><button v-if="vm.backendTableFeature(state, &quot;columnCrud&quot;)" type="button" class="mioos-table-col-edit" title="Edit column" @click.stop="vm.backendTableOpenColumnEditor(tableId || state.id, col)">⚙</button><button v-if="vm.backendTableFeature(state, &quot;columnCrud&quot;)" type="button" class="mioos-table-col-delete" title="Delete column" @click.stop="vm.backendTableDeleteColumn(tableId || state.id, col)">×</button><span v-if="vm.backendTableFeature(state, &quot;resizeColumns&quot;)" class="mioos-table-resizer" @pointerdown.prevent="vm.backendTableBeginColumnResize(tableId || state.id, col, $event)"></span></th><th v-if="vm.backendTableShowActions(state)" class="mioos-table-actions-head"><span>Actions</span><span class="mioos-table-resizer" @pointerdown.prevent="vm.backendTableBeginActionsResize(tableId || state.id, $event)"></span></th></tr>' +
              '</thead>' +
              '<tbody>' +
                '<tr v-if="!state.loading && !state.rows.length" class="mioos-table-empty-row"><td :colspan="vm.backendTableColspan(state)">[[ state.config.emptyMessage ]]</td></tr>' +
                '<template v-for="group in rowGroups" :key="group.key || \'all\'">' +
                  '<tr v-if="vm.backendTableGroupColumns(state).length" class="mioos-table-group-row"><td :colspan="vm.backendTableColspan(state)"><button type="button" @click="vm.backendTableToggleGroup(tableId || state.id, group.key)">[[ vm.backendTableIsGroupExpanded(state, group.key) ? \'▾\' : \'▸\' ]]</button><strong>[[ group.label ]]</strong><span>[[ group.count ]] rows</span></td></tr>' +
                  '<template v-if="!vm.backendTableGroupColumns(state).length || vm.backendTableIsGroupExpanded(state, group.key)">' +
                    '<template v-for="row in group.rows" :key="keyOf(row)">' +
                      '<tr :class="{ \'is-selected\': vm.backendTableIsSelected(state, row) }"><td v-if="vm.backendTableShowControl(state)" class="mioos-table-control-cell"><button v-if="row._expand && vm.backendTableFeature(state, &quot;rowDetails&quot;)" class="mioos-table-detail-toggle" type="button" :aria-expanded="vm.backendTableIsExpanded(state, row) ? \'true\' : \'false\'" @click="vm.backendTableToggleExpand(tableId || state.id, row)">[[ vm.backendTableIsExpanded(state, row) ? \'▾\' : \'▸\' ]]</button><input v-if="vm.backendTableShowSelection(state)" type="checkbox" :checked="vm.backendTableIsSelected(state, row)" @change="vm.backendTableToggleRow(tableId || state.id, row)"></td><td v-for="col in columns" :key="col.key"><span :class="\'mioos-table-cell type-\' + col.type">[[ vm.backendTableCellText(row, col) ]]</span></td><td v-if="vm.backendTableShowActions(state)" class="mioos-table-actions"><button v-for="action in vm.backendTableVisibleRowActions(state)" :key="action.key" type="button" @click="vm.backendTableRunAction(tableId || state.id, action, row)">[[ action.label ]]</button></td></tr>' +
                      '<tr v-if="vm.backendTableIsExpanded(state, row)" class="mioos-table-expanded-row"><td v-if="vm.backendTableShowControl(state)"></td><td :colspan="columns.length + (vm.backendTableShowActions(state) ? 1 : 0)"><strong>[[ (row._expand || {}).title || \'Details\' ]]</strong><p>[[ (row._expand || {}).body || JSON.stringify(row) ]]</p></td></tr>' +
                    '</template>' +
                  '</template>' +
                '</template>' +
              '</tbody>' +
            '</table>' +
          '</div>' +
          '<footer v-if="vm.backendTableFeature(state, &quot;pagination&quot;)" class="mioos-table-pager"><span>[[ state.pagination.filteredRows ]] of [[ state.pagination.totalRows ]] rows</span><button type="button" :disabled="state.loading || state.saving" @click="vm.backendTableSetPage(tableId || state.id, 1)">First</button><button type="button" :disabled="state.loading || state.saving" @click="vm.backendTableSetPage(tableId || state.id, state.pagination.page - 1)">Prev</button><span>Page [[ state.pagination.page ]] / [[ state.pagination.pageCount ]]</span><label class="mioos-table-page-jump"><span>Jump</span><input type="number" min="1" :max="state.pagination.pageCount" :value="state.pagination.page" :disabled="state.loading || state.saving" @keydown.enter.prevent="vm.backendTableJumpPage(tableId || state.id, $event.target.value)"><button type="button" :disabled="state.loading || state.saving" @click="vm.backendTableJumpPage(tableId || state.id, $event.currentTarget.previousElementSibling.value)">Go</button></label><button type="button" :disabled="state.loading || state.saving" @click="vm.backendTableSetPage(tableId || state.id, state.pagination.page + 1)">Next</button><button type="button" :disabled="state.loading || state.saving" @click="vm.backendTableSetPage(tableId || state.id, state.pagination.pageCount)">Last</button><label>Rows <select :value="state.pagination.pageSize" @change="vm.backendTableSetPageSize(tableId || state.id, $event.target.value)"><option>10</option><option>25</option><option>50</option><option>100</option><option>250</option></select></label></footer>' +
        '</section>'
    });


    app.component('mioos-surface-table-showcase', {
      props: ['window'],
      computed: {
        vm: function () { return root(this); },
        variants: function () {
          return [
            { key: 'simple', title: 'Simple read-only table', dataset: 'demo', summary: 'Search, sort, and pagination only; no selection or actions column.', code: mumpsTableSnippet('demo', ['SET MOD("tableState","config","features","rowCrud")=0', 'SET MOD("tableState","config","features","selection")=0', 'SET MOD("tableState","config","features","bulkActions")=0', 'SET MOD("tableState","config","features","rowDetails")=0', 'SET MOD("tableState","config","features","columnCrud")=0']), config: { features: { filters: false, grouping: false, columnPicker: false, rowCrud: false, columnCrud: false, selection: false, bulkActions: false, rowDetails: false } } },
            { key: 'dense', title: 'Dense operational table', dataset: 'demo', summary: 'Compact spacing for data-intensive MUMPS internal tools.', code: mumpsTableSnippet('demo', ['SET MOD("tableState","config","density")="compact"', 'SET MOD("tableState","config","defaultPageSize")=50', 'SET MOD("tableState","config","actionsWidth")=132']), config: { density: 'compact', defaultPageSize: 50, actionsWidth: 132 } },
            { key: 'editable', title: 'Editable CRUD table', dataset: 'demo', summary: 'Row create/edit/delete, column management, selection, and bulk delete.', code: mumpsTableSnippet('demo', ['SET MOD("tableState","config","features","rowCrud")=1', 'SET MOD("tableState","config","features","columnCrud")=1', 'SET MOD("tableState","config","features","selection")=1', 'SET MOD("tableState","config","features","bulkActions")=1']), config: { features: { rowCrud: true, columnCrud: true, selection: true, bulkActions: true, resizeColumns: true } } },
            { key: 'patient', title: 'Patient registration table', dataset: 'patient-registration', summary: 'Healthcare sample dataset with search, filters, details, and CRUD.', code: mumpsTableSnippet('patient-registration', ['SET MOD("tableState","config","defaultSort","column")="lastName"', 'SET MOD("tableState","config","defaultSort","direction")="ascending"']), config: { defaultSort: { column: 'lastName', direction: 'ascending' } } },
            { key: 'massive', title: 'Massive read-only table', dataset: 'massive', summary: 'Fast server-side generated 10,000-row dataset with page-only row materialization and no actions column.', code: mumpsTableSnippet('massive', ['SET MOD("tableState","config","defaultSort","column")="id"', 'SET MOD("tableState","config","defaultPageSize")=100', 'SET MOD("tableState","config","features","rowCrud")=0', 'SET MOD("tableState","config","features","selection")=0', 'SET MOD("tableState","config","features","bulkActions")=0', 'SET MOD("tableState","config","features","rowDetails")=0']), config: { defaultPageSize: 100, defaultSort: { column: 'id', direction: 'ascending' }, features: { rowCrud: false, columnCrud: false, rowDetails: false, selection: false, bulkActions: false } } }
          ];
        }
      },
      methods: {
        openVariant: function (variant) {
          if (!this.vm.openBackendTableWindow) return;
          this.vm.openBackendTableWindow({ title: variant.title, dataset: variant.dataset, config: window.MIOOSTable.createConfig(variant.config || {}) });
        }
      },
      template: '' +
        '<section class="mioos-table-showcase">' +
          '<header><div><strong>Advanced Table MUMPS API</strong><span>Copyable MUMPS contracts for internal and user-created modules</span></div></header>' +
          '<div class="mioos-table-showcase-grid">' +
            '<article v-for="variant in variants" :key="variant.key" class="mioos-table-showcase-card">' +
              '<h3>[[ variant.title ]]</h3><p>[[ variant.summary ]]</p>' +
              '<pre><code>[[ variant.code ]]</code></pre>' +
              '<button type="button" class="mioos-btn" @click="openVariant(variant)">Open variation</button>' +
            '</article>' +
          '</div>' +
        '</section>'
    });

    app.component('mioos-surface-table', {
      props: ['window'],
      computed: { state: function () { return (this.window || {}).tableState || {}; } },
      template: '<mioos-full-table :table-id="state.id || window.id" :title="state.title || window.title" :dataset="state.dataset || \'demo\'" :folder-id="state.folderId || \'\'" :config="state.config || {}"></mioos-full-table>'
    });
  }

  window.MIOOSTable = { contract: TABLE_CONTRACT, defaultConfig: defaultTableConfig, createConfig: function (patch) { return mergeConfig(defaultTableConfig(), patch || {}); }, methods: methods, register: register };
  if (window.MIOOSModules && typeof window.MIOOSModules.registerComponent === 'function') {
    window.MIOOSModules.registerComponent({ key: 'table', name: 'mioos-full-table', title: 'Advanced Backend Table', surface: 'mioos-surface-table', description: 'Server-side table with WebSocket query, HTTP-safe mutations, dense layouts, sorting, selection, bulk actions, row and column CRUD, resizable columns, grouping, and massive datasets.' });
    window.MIOOSModules.registerComponent({ key: 'table-showcase', name: 'mioos-surface-table-showcase', title: 'Table Variations', surface: 'mioos-surface-table-showcase', description: 'Copyable simple-to-advanced MUMPS table contracts for backend developers.' });
  }
})();
