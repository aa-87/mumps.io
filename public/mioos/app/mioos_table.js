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
      { key: 'updated', label: 'Updated', type: 'date', width: 150, sortable: true, resizable: true, hidden: false, group: '' },
      { key: 'notes', label: 'Notes', type: 'textarea', width: 260, sortable: false, resizable: true, hidden: false, group: 'Details' }
    ];
  }

  var TABLE_CONTRACT = 'mioos-advanced-table-v8';

  function defaultTableConfig() {
    return {
      contract: TABLE_CONTRACT,
      features: { toolbar: true, datasetSwitcher: true, search: true, filters: true, grouping: true, columnPicker: true, columnGroups: false, rowCrud: true, columnCrud: true, selection: true, bulkActions: true, pagination: true, rowDetails: true, resizeColumns: true, cellEditing: true, columnReorder: true, fixedColumns: true, serverSide: true, processingIndicator: true },
      columns: [],
      defaultSort: { column: 'name', direction: 'ascending' },
      defaultPageSize: 25,
      readonly: false,
      density: 'compact',
      transport: 'websocket',
      mutateTransport: 'websocket',
      actionsWidth: 156,
      fixedColumns: { start: 0, end: 0 },
      emptyMessage: 'No rows match the current server-side table query.',
      loadingMessage: '',
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
        group: col.group || col.groupLabel || '',
        required: !!col.required,
        editable: col.editable === false || col.editable === 0 || col.editable === '0' ? false : true,
        cellCallback: col.cellCallback || '',
        options: toList(col.options || col.values || col.enum)
      };
    });
  }

  function normalizeRows(rows) {
    return (Array.isArray(rows) ? rows : defaultRows()).map(function (row, index) {
      var out = clone(row);
      out.id = out.id || out.key || ('row-' + index);
      if (typeof out.notes === 'undefined' && out._expand && out._expand.body) out.notes = out._expand.body;
      return out;
    });
  }

  function normalizeFilterEntry(value) {
    if (value && typeof value === 'object' && !Array.isArray(value)) {
      var out = clone(value);
      out.mode = out.mode || 'include';
      if (!Array.isArray(out.values)) out.values = typeof out.value === 'undefined' || out.value === '' ? [] : [String(out.value)];
      return out;
    }
    var values = Array.isArray(value) ? value.slice() : (value ? [String(value)] : []);
    return { mode: 'include', values: values, value: values[0] || '', from: '', to: '' };
  }

  function filterControlForColumn(column) {
    var type = String((column || {}).type || 'text').toLowerCase();
    if (type === 'badge' || type === 'select' || type === 'multiselect') return 'select';
    if (type === 'boolean' || type === 'checkbox') return 'boolean';
    if (type === 'date') return 'date';
    if (type === 'number' || type === 'numeric') return 'number';
    if (type === 'textarea') return 'textarea';
    return 'text';
  }

  function toList(value) {
    if (!value) return [];
    if (Array.isArray(value)) return value;
    if (typeof value === 'object') {
      return Object.keys(value).filter(function (key) { return key !== 'byValue'; }).sort(function (a, b) { return (+a || 999999) - (+b || 999999) || String(a).localeCompare(String(b)); }).map(function (key) { return value[key]; }).filter(Boolean);
    }
    return [];
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
        groupModalOpen: false,
        groupDraftColumns: [],
        filterModalOpen: false,
        dialogPositions: {},
        fixedColumns: { start: 0, end: 0 },
        draw: 0,
        lastDraw: 0,
        requestLabel: '',
        lastServerAt: '',
        features: {},
        actionsWidth: 156,
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
        patientRegistration: null,
        columnResize: null,
        columnPickerOpen: false,
        groupExpanded: {},
        editor: { open: false, mode: 'row', title: '', row: {}, column: {} },
        cellEditor: { open: false, rowId: '', columnKey: '', value: '', originalValue: '' },
        optionDialog: { open: false, context: '', columnKey: '', columnLabel: '', value: '' },
        confirmDialog: { open: false, kind: '', title: '', message: '', confirmText: 'Confirm', danger: false, payload: {} }
      };
    },
    backendTableState: function (tableId) {
      return tableState(this, tableId || 'mioos-table');
    },
    backendTableSetToast: function (tableId, message) {
      var state = this.backendTableState(tableId);
      state.toast = message || '';
      if (state.toastTimer) clearTimeout(state.toastTimer);
      if (state.toast && typeof setTimeout === 'function') {
        state.toastTimer = setTimeout(function () { state.toast = ''; state.toastTimer = null; }, 3600);
      }
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
        groupBy: state.groupBy || '',
        groupByColumns: Array.isArray(state.groupByColumns) ? state.groupByColumns.slice() : (state.groupBy ? [state.groupBy] : []),
        includeDataAlias: false,
        sort: sort,
        order: [{ column: orderIndex, dir: sort.direction === 'descending' ? 'desc' : 'asc', name: sort.column || '' }],
        filters: clone(state.filters || {}),
        columns: columns.map(function (col) { return { key: col.key, data: col.key, name: col.key, label: col.label, type: col.type, searchable: col.searchable !== false, orderable: col.sortable !== false, hidden: !!col.hidden, width: col.width, editable: col.editable !== false, cellCallback: col.cellCallback || '' }; })
      };
    },
    backendTableUseWebSocket: function (state, operation) {
      var cfg = mergeConfig(defaultTableConfig(), (state || {}).config || {});
      var transport = operation === 'mutate' ? (cfg.mutateTransport || 'http') : (cfg.transport || 'websocket');
      if (transport === 'http') return false;
      return typeof this.command === 'function';
    },
    backendTableHttpPost: function (route, payload, label) {
      return fetch(route, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'same-origin',
        body: JSON.stringify(payload)
      }).then(function (response) { return parseJsonResponse(response, label); });
    },
    backendTableFetch: function (tableId, patch) {
      var state = this.backendTableState(tableId);
      var route = this.backendTableRoute();
      var vm = this;
      Object.assign(state, patch || {});
      state.draw = +(state.draw || 0) + 1;
      state.loading = true;
      state.processing = true;
      var requestId = 'q' + state.draw + '-' + Date.now();
      state.queryRequestId = requestId;
      state.requestLabel = 'table.query';
      state.error = '';
      var body = this.backendTableQueryPayload(state, state.draw);
      var request = this.backendTableUseWebSocket(state, 'query')
        ? this.command('table.query', body).then(extractTablePayload).catch(function (err) { if (shouldFallbackSocket(err)) return vm.backendTableHttpPost(route, body, 'Table query'); throw err; })
        : this.backendTableHttpPost(route, body, 'Table query');
      return request.then(function (payload) {
        vm.backendTableApplyPayload(state, payload || {});
        return state;
      }).catch(function (err) {
        state.error = serverErrorMessage('Table query', err);
        return state;
      }).finally(function () {
        if (state.queryRequestId === requestId) {
          state.loading = false;
          state.processing = !!state.saving;
          state.requestLabel = '';
        }
      });
    },
    backendTableMutate: function (tableId, action, payload) {
      var state = this.backendTableState(tableId);
      var vm = this;
      state.draw = +(state.draw || 0) + 1;
      var body = Object.assign({ dataset: state.dataset || 'demo', action: action, mutationOnly: true }, payload || {});
      var passiveMutation = /^(cell\.save|column\.visibility|column\.reorder|column\.fixed|column\.option\.add|column\.resize)$/.test(action || '');
      state.saving = true;
      state.processing = !passiveMutation;
      var requestId = 'm' + state.draw + '-' + Date.now();
      state.mutationRequestId = requestId;
      state.requestLabel = passiveMutation ? '' : 'Saving table changes';
      state.error = '';
      var route = this.backendTableMutateRoute();
      var request = this.backendTableUseWebSocket(state, 'mutate')
        ? this.command('table.mutate', body).then(extractTablePayload).catch(function (err) { if (shouldFallbackSocket(err)) return vm.backendTableHttpPost(route, body, 'Table mutation'); throw err; })
        : this.backendTableHttpPost(route, body, 'Table mutation');
      return request.then(function (payload) {
        if (payload && payload.ok === false) {
          state.validation = clone(payload.fieldErrors || {});
          state.error = payload.message || payload.detail || payload.error || 'Table mutation failed';
          return payload;
        }
        state.validation = {};
        if (payload && payload.export && payload.export.csv) {
          vm.backendTableSetToast(tableId, payload.message || 'CSV export generated');
          return payload;
        }
        state.selected = {};
        if (state.editor && !body.keepEditor) state.editor.open = false;
        vm.backendTableSetToast(tableId, (payload && payload.message) || 'Table updated');
        if (payload && payload.refetch) return vm.backendTableFetch(tableId).then(function () { return payload; });
        vm.backendTableApplyPayload(state, payload || {});
        return payload;
      }).catch(function (err) {
        state.error = serverErrorMessage('Table mutation', err);
        return { ok: false, error: state.error };
      }).finally(function () {
        if (state.mutationRequestId === requestId) {
          state.saving = false;
          state.processing = !!state.loading;
          state.requestLabel = '';
        }
      });
    },
    backendTableApplyPayload: function (state, payload) {
      payload = payload || {};
      if (payload.draw && payload.draw < +(state.lastDraw || 0)) return;
      if (payload.draw) state.lastDraw = +payload.draw;
      state.lastServerAt = new Date().toLocaleTimeString();
      var hasSchema = !!(payload.schema && typeof payload.schema === 'object');
      var hasSchemaColumns = !!(hasSchema && Array.isArray(payload.schema.columns));
      var hasRows = Object.prototype.hasOwnProperty.call(payload, 'rows') || Object.prototype.hasOwnProperty.call(payload, 'data');
      var hasQueryShape = hasRows || hasSchema || Object.prototype.hasOwnProperty.call(payload, 'pagination') || Object.prototype.hasOwnProperty.call(payload, 'recordsTotal') || Object.prototype.hasOwnProperty.call(payload, 'recordsFiltered');
      if (payload.features) state.features = Object.assign({}, payload.features || {});
      if (Object.prototype.hasOwnProperty.call(payload, 'patientRegistration')) state.patientRegistration = payload.patientRegistration || null;
      var preferredFixed = state.columnPrefs && state.columnPrefs.fixedColumns ? state.columnPrefs.fixedColumns : null;
      state.fixedColumns = this.backendTableNormalizeFixedColumns(state, preferredFixed || (hasSchema ? payload.schema.fixedColumns : null) || payload.fixedColumns || state.fixedColumns || ((state.config || {}).fixedColumns));
      if (Array.isArray(payload.groupByColumns)) state.groupByColumns = payload.groupByColumns.slice();
      state.readOnly = !!(+((state.features || {}).readOnly || 0)) || !!((state.config || {}).readonly);
      if (hasSchemaColumns) state.columns = this.backendTableApplyColumnPrefs(state, payload.schema.columns);
      if (hasRows) {
        var payloadRows = Array.isArray(payload.rows) ? payload.rows : (Array.isArray(payload.data) ? payload.data : []);
        state.rows = normalizeRows(payloadRows);
      }
      if (payload.pagination) state.pagination = Object.assign({}, state.pagination || {}, payload.pagination || {});
      if (typeof payload.recordsTotal !== 'undefined') state.pagination.totalRows = +payload.recordsTotal || 0;
      if (typeof payload.recordsFiltered !== 'undefined') state.pagination.filteredRows = +payload.recordsFiltered || 0;
      if (Object.prototype.hasOwnProperty.call(payload, 'rowActions')) state.rowActions = payload.rowActions || [];
      if (Object.prototype.hasOwnProperty.call(payload, 'bulkActions')) state.bulkActions = payload.bulkActions || [];
      if (Object.prototype.hasOwnProperty.call(payload, 'groups')) state.groups = toList(payload.groups);
      state.error = payload && payload.ok === false ? (payload.error || payload.detail || 'Table request failed') : state.error;
      if (!hasQueryShape) return;
      if (!(state.groupByColumns && state.groupByColumns.length) && !state.groupBy) state.groupExpanded = {};
      if (((state.groupByColumns && state.groupByColumns.length) || state.groupBy) && !Object.keys(state.groupExpanded || {}).length) {
        state.groups.forEach(function (g) { state.groupExpanded[g.key || g.label] = true; });
      }
    },
    backendTableCaptureColumnPrefs: function (state) {
      state = state || {};
      var prefs = { order: [], hidden: {}, width: {}, fixedColumns: clone(state.fixedColumns || {}) };
      normalizeColumns(state.columns || []).forEach(function (col) {
        if (!col || !col.key) return;
        prefs.order.push(col.key);
        prefs.hidden[col.key] = !!col.hidden;
        if (+col.width > 0) prefs.width[col.key] = +col.width;
      });
      state.columnPrefs = prefs;
      return prefs;
    },
    backendTableApplyColumnPrefs: function (state, columns) {
      var normalized = normalizeColumns(columns || []);
      var prefs = (state || {}).columnPrefs || {};
      var hasPrefs = (prefs.order && prefs.order.length) || prefs.hidden || prefs.width;
      if (!hasPrefs) return normalized;
      var byKey = {}, used = {}, ordered = [];
      normalized.forEach(function (col) {
        if (!col || !col.key) return;
        if (prefs.hidden && Object.prototype.hasOwnProperty.call(prefs.hidden, col.key)) col.hidden = !!prefs.hidden[col.key];
        if (prefs.width && +prefs.width[col.key] > 0) col.width = +prefs.width[col.key];
        byKey[col.key] = col;
      });
      (prefs.order || []).forEach(function (key) {
        if (byKey[key] && !used[key]) { ordered.push(byKey[key]); used[key] = true; }
      });
      normalized.forEach(function (col) { if (col && col.key && !used[col.key]) ordered.push(col); });
      return ordered.length ? ordered : normalized;
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
    backendTableEditorGroups: function (state) {
      var columns = this.backendTableAllColumns(state || {}).filter(function (col) { return col.key !== 'id' && col.editable !== false; });
      if (!columns.length) return [];
      var groups = [];
      var byName = {};
      columns.forEach(function (col) {
        var name = String(col.group || 'Details');
        if (!byName[name]) { byName[name] = { label: name, columns: [] }; groups.push(byName[name]); }
        byName[name].columns.push(col);
      });
      return groups;
    },
    backendTableNormalizeFixedColumns: function (state, source) {
      source = source || {};
      var visible = this.backendTableVisibleColumns(state || {});
      var max = visible.length;
      var start = Math.max(0, +(source.start || source.fixedStart || 0) || 0);
      var end = Math.max(0, +(source.end || source.fixedEnd || 0) || 0);
      if (!this.backendTableFeature(state || {}, 'fixedColumns')) return { start: 0, end: 0 };
      if (start > max) start = max;
      if (end > Math.max(0, max - start)) end = Math.max(0, max - start);
      return { start: start, end: end };
    },
    backendTableColumnWidth: function (column) { return Math.max(48, +(column || {}).width || 120); },
    backendTableControlWidth: function () { return 48; },
    backendTableFixedColumns: function (state) { return this.backendTableNormalizeFixedColumns(state, (state || {}).fixedColumns || (((state || {}).config || {}).fixedColumns)); },
    backendTableFixedOffset: function (state, index, side, role) {
      var columns = this.backendTableVisibleColumns(state || {});
      var offset = 0;
      if (side === 'start') {
        if (this.backendTableShowControl(state)) offset += this.backendTableControlWidth();
        for (var i = 0; i < index; i += 1) offset += this.backendTableColumnWidth(columns[i]);
        if (role === 'control') offset = 0;
      } else if (side === 'end') {
        if (this.backendTableShowActions(state)) offset += Math.max(96, +((state || {}).actionsWidth || (((state || {}).config || {}).actionsWidth) || 156));
        for (var j = columns.length - 1; j > index; j -= 1) offset += this.backendTableColumnWidth(columns[j]);
        if (role === 'actions') offset = 0;
      }
      return offset;
    },
    backendTableStickySide: function (state, column, index, role) {
      var fixed = this.backendTableFixedColumns(state);
      var columns = this.backendTableVisibleColumns(state || {});
      if (!this.backendTableFeature(state || {}, 'fixedColumns')) return '';
      if (role === 'control') return fixed.start > 0 ? 'start' : '';
      if (role === 'actions') return fixed.end > 0 ? 'end' : '';
      if (!column || index < 0) return '';
      if (fixed.start > 0 && index < fixed.start) return 'start';
      if (fixed.end > 0 && index >= Math.max(0, columns.length - fixed.end)) return 'end';
      return '';
    },
    backendTableStickyClass: function (state, column, index, role) {
      var side = this.backendTableStickySide(state, column, index, role);
      if (!side) return '';
      return 'mioos-table-sticky is-fixed-' + side + (role ? ' is-fixed-' + role : '');
    },
    backendTableStickyStyle: function (state, column, index, role) {
      var side = this.backendTableStickySide(state, column, index, role);
      if (!side) return {};
      var style = { zIndex: role === 'head' ? 6 : 5 };
      if (side === 'start') style.left = this.backendTableFixedOffset(state, index, 'start', role) + 'px';
      if (side === 'end') style.right = this.backendTableFixedOffset(state, index, 'end', role) + 'px';
      return style;
    },
    backendTableSetFixedColumns: function (tableId, side, value) {
      var state = this.backendTableState(tableId);
      if (!this.backendTableFeature(state, 'fixedColumns')) return Promise.resolve(state);
      var next = this.backendTableNormalizeFixedColumns(state, state.fixedColumns || {});
      next[side === 'end' ? 'end' : 'start'] = Math.max(0, +value || 0);
      next = this.backendTableNormalizeFixedColumns(state, next);
      state.fixedColumns = next;
      this.backendTableCaptureColumnPrefs(state);
      var vm = this;
      return this.backendTableMutate(tableId, 'column.fixed', { fixedColumns: next, keepEditor: true }).then(function (payload) {
        if (payload && payload.ok !== false) vm.backendTableSetToast(tableId, 'Fixed columns updated');
        return payload;
      });
    },
    backendTableColumnStyle: function (column) { return { width: this.backendTableColumnWidth(column) + 'px' }; },
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
    backendTableGroupedRows: function (state) {
      var rows = normalizeRows((state || {}).rows || []);
      var keys = Array.isArray((state || {}).groupByColumns) && state.groupByColumns.length ? state.groupByColumns : ((state || {}).groupBy ? [state.groupBy] : []);
      if (!keys.length) return [{ key: '', label: '', rows: rows, count: rows.length, ungrouped: true }];
      var map = {};
      rows.forEach(function (row) {
        var parts = keys.map(function (key) { return String(row[key] == null || row[key] === '' ? '(blank)' : row[key]); });
        var value = parts.join(' / ');
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
      return normalizeColumns((state || {}).columns || []).filter(function (col) { return !col.hidden; });
    },
    backendTableFilterControl: function (column) { return filterControlForColumn(column); },
    backendTableFilterValue: function (state, key) {
      var val = normalizeFilterEntry(((state || {}).filters || {})[key]);
      return val.value || (Array.isArray(val.values) ? (val.values[0] || '') : '');
    },
    backendTableFilterDraftEntry: function (state, key) {
      var source = ((state || {}).filterDraft || {})[key];
      if (!source) source = ((state || {}).filters || {})[key];
      return normalizeFilterEntry(source);
    },
    backendTableOpenFilters: function (tableId) {
      var state = this.backendTableState(tableId);
      state.filterDraft = clone(state.filters || {});
      state.filterModalOpen = true;
    },
    backendTableCloseFilters: function (tableId) { this.backendTableState(tableId).filterModalOpen = false; },
    backendTableSetFilterDraft: function (tableId, key, field, value) {
      var state = this.backendTableState(tableId);
      state.filterDraft = clone(state.filterDraft || {});
      var entry = normalizeFilterEntry(state.filterDraft[key]);
      if (field === 'mode') entry.mode = value || 'include';
      else if (field === 'from') entry.from = value || '';
      else if (field === 'to') entry.to = value || '';
      else { entry.value = value || ''; entry.values = value ? [String(value)] : []; }
      state.filterDraft[key] = entry;
    },
    backendTableApplyFilters: function (tableId) {
      var state = this.backendTableState(tableId);
      var next = {};
      Object.keys(state.filterDraft || {}).forEach(function (key) {
        var entry = normalizeFilterEntry(state.filterDraft[key]);
        var hasValue = entry.mode === 'blank' || entry.mode === 'notblank' || entry.value || entry.from || entry.to || (entry.values || []).length;
        if (hasValue) next[key] = entry;
      });
      state.filters = next;
      state.pagination.page = 1;
      state.filterModalOpen = false;
      return this.backendTableFetch(tableId);
    },
    backendTableSetFilter: function (tableId, key, value) {
      var state = this.backendTableState(tableId);
      state.filters = clone(state.filters || {});
      if (!value) delete state.filters[key]; else state.filters[key] = { mode: 'include', value: String(value), values: [String(value)] };
      state.pagination.page = 1;
      return this.backendTableFetch(tableId);
    },
    backendTableClearFilters: function (tableId) {
      var state = this.backendTableState(tableId);
      state.filters = {};
      state.filterDraft = {};
      state.pagination.page = 1;
      state.filterModalOpen = false;
      return this.backendTableFetch(tableId);
    },
    backendTableOpenColumnPicker: function (tableId) { this.backendTableState(tableId).columnPickerOpen = true; },
    backendTableCloseColumnPicker: function (tableId) { this.backendTableState(tableId).columnPickerOpen = false; },
    backendTableSetDataset: function (tableId, value) {
      var state = this.backendTableState(tableId);
      state.dataset = value || 'demo';
      state.pagination.page = 1;
      state.selected = {};
      state.expanded = {};
      state.groupExpanded = {};
      state.columnPrefs = {};
      return this.backendTableFetch(tableId);
    },
    backendTableSetPage: function (tableId, page) {
      var state = this.backendTableState(tableId);
      var max = +((state.pagination || {}).pageCount) || 1;
      state.pagination.page = Math.min(Math.max(1, +page || 1), max);
      return this.backendTableFetch(tableId);
    },
    backendTablePageRangeLabel: function (state) {
      var p = (state || {}).pagination || {};
      var filtered = +p.filteredRows || 0;
      var rows = +p.pageRows || 0;
      if (!filtered || !rows) return 'Showing 0 of ' + filtered + ' rows';
      var start = ((+p.page || 1) - 1) * (+p.pageSize || rows) + 1;
      var end = Math.min(filtered, start + rows - 1);
      return 'Showing ' + start + '–' + end + ' of ' + filtered + ' rows';
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
      this.backendTableCaptureColumnPrefs(state);
      if (!this.backendTableFeature(state, 'columnCrud')) return Promise.resolve(state);
      return this.backendTableMutate(tableId, 'column.visibility', { columnKey: key, hidden: nextHidden }).catch(function () {});
    },
    backendTableSetGroupBy: function (tableId, key) {
      var state = this.backendTableState(tableId);
      state.groupBy = key || '';
      state.groupByColumns = key ? [key] : [];
      state.groupExpanded = {};
      return this.backendTableFetch(tableId);
    },
    backendTableOpenGrouping: function (tableId) {
      var state = this.backendTableState(tableId);
      state.groupDraftColumns = (Array.isArray(state.groupByColumns) && state.groupByColumns.length ? state.groupByColumns : (state.groupBy ? [state.groupBy] : [])).slice();
      state.groupModalOpen = true;
    },
    backendTableCloseGrouping: function (tableId) { this.backendTableState(tableId).groupModalOpen = false; },
    backendTableToggleGroupDraft: function (tableId, key) {
      var state = this.backendTableState(tableId);
      var list = Array.isArray(state.groupDraftColumns) ? state.groupDraftColumns.slice() : [];
      var index = list.indexOf(key);
      if (index >= 0) list.splice(index, 1); else list.push(key);
      state.groupDraftColumns = list;
    },
    backendTableApplyGrouping: function (tableId) {
      var state = this.backendTableState(tableId);
      state.groupByColumns = (state.groupDraftColumns || []).slice();
      state.groupBy = state.groupByColumns[0] || '';
      state.groupExpanded = {};
      state.groupModalOpen = false;
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
      if (!this.backendTableFeature(state, 'rowCrud') && (key === 'edit' || key === 'duplicate' || key === 'delete')) return null;
      if (key === 'edit') return this.backendTableOpenRowEditor(tableId, row);
      if (key === 'duplicate') return this.backendTableOpenRowEditor(tableId, Object.assign({}, clone(row), { id: '' }));
      if (key === 'delete') return this.backendTableOpenConfirmDialog(tableId, { kind: 'row.delete', title: 'Delete row', message: 'Delete this row?', confirmText: 'Delete', danger: true, payload: { rowId: (row || {}).id } });
      if (this.showAlert) this.showAlert('Table action', ((action || {}).label || key || 'Action') + ' queued for ' + ((row || {}).name || (row || {}).id || 'row'));
    },
    backendTableRunBulkAction: function (tableId, action) {
      var state = this.backendTableState(tableId);
      var key = (action || {}).key || action || '';
      var ids = this.backendTableSelectedIds(state);
      if (!ids.length) return;
      if (key === 'export' || key === 'rows.export') { return this.backendTableMutate(tableId, 'rows.export', { ids: ids }).then(function (payload) {
        if (payload && payload.export && payload.export.csv) {
          state.toast = payload.message || (ids.length + ' row(s) exported');
          if (typeof Blob !== 'undefined' && typeof URL !== 'undefined') {
            var blob = new Blob([payload.export.csv], { type: payload.export.contentType || 'text/csv' });
            var url = URL.createObjectURL(blob);
            var a = document.createElement('a');
            a.href = url;
            a.download = payload.export.fileName || 'table_selected_rows.csv';
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            setTimeout(function () { URL.revokeObjectURL(url); }, 500);
          }
        }
        return payload;
      }); }
      if ((key === 'bulk.delete' || key === 'delete') && !this.backendTableFeature(state, 'rowCrud')) return null;
      if (key === 'bulk.delete' || key === 'delete') return this.backendTableOpenConfirmDialog(tableId, { kind: 'rows.delete', title: 'Delete selected rows', message: 'Delete ' + ids.length + ' selected row(s)?', confirmText: 'Delete rows', danger: true, payload: { ids: ids } });
      if (this.showAlert) this.showAlert('Bulk table action', ((action || {}).label || key || 'Action') + ' applied to ' + ids.length + ' row(s)');
    },
    backendTableCellText: function (row, column) {
      var value = row ? row[column.key] : '';
      if (value === null || typeof value === 'undefined') return '';
      return String(value);
    },
    backendTableCanEditCell: function (state, row, column) {
      if (!row || !column || !column.key) return false;
      if (column.key === 'id') return false;
      if (column.editable === false || column.editable === 0 || column.editable === '0') return false;
      if (!this.backendTableFeature(state, 'cellEditing')) return false;
      if ((state || {}).readOnly) return false;
      return true;
    },
    backendTableIsCellEditing: function (state, row, column) {
      var cell = (state || {}).cellEditor || {};
      var rowId = (row && (row.id || row.key)) || '';
      return !!cell.open && cell.rowId === rowId && cell.columnKey === (column || {}).key;
    },
    backendTableOpenCellEditor: function (tableId, row, column) {
      var state = this.backendTableState(tableId);
      if (!this.backendTableCanEditCell(state, row, column)) return null;
      var rowId = (row && (row.id || row.key)) || '';
      var value = row && typeof row[column.key] !== 'undefined' && row[column.key] !== null ? String(row[column.key]) : '';
      state.validation = {};
      state.cellEditor = { open: true, rowId: rowId, columnKey: column.key, value: value, originalValue: value };
    },
    backendTableCancelCellEditor: function (tableId) {
      var state = this.backendTableState(tableId);
      state.cellEditor = { open: false, rowId: '', columnKey: '', value: '', originalValue: '' };
    },
    backendTableCellDraftValue: function (state, row, column) {
      if (this.backendTableIsCellEditing(state, row, column)) return ((state || {}).cellEditor || {}).value || '';
      return row && typeof row[(column || {}).key] !== 'undefined' && row[(column || {}).key] !== null ? String(row[(column || {}).key]) : '';
    },
    backendTableSetCellDraft: function (tableId, value) {
      var state = this.backendTableState(tableId);
      state.cellEditor = Object.assign({}, state.cellEditor || {}, { value: value == null ? '' : String(value) });
    },
    backendTableCellMultiValue: function (state, row, column) {
      var val = this.backendTableCellDraftValue(state, row, column);
      if (!val) return [];
      return String(val).split(',').map(function (part) { return part.trim(); }).filter(Boolean);
    },
    backendTableSetCellMultiDraft: function (tableId, event) {
      var vals = Array.prototype.slice.call(((event || {}).target || {}).selectedOptions || []).map(function (opt) { return opt.value; });
      this.backendTableSetCellDraft(tableId, vals.join(', '));
    },
    backendTableSaveCell: function (tableId, row, column) {
      var state = this.backendTableState(tableId);
      var cell = state.cellEditor || {};
      if (!cell.open || !column || !column.key) return Promise.resolve({ ok: false });
      var vm = this;
      return this.backendTableMutate(tableId, 'cell.save', { rowId: cell.rowId || ((row || {}).id || (row || {}).key), columnKey: column.key, value: cell.value || '', keepEditor: true }).then(function (payload) {
        if (payload && payload.ok === false) return payload;
        state.toast = 'Cell saved';
        vm.backendTableCancelCellEditor(tableId);
        return payload;
      });
    },
    backendTableColumnOptions: function (state, column) {
      column = column || {};
      var options = toList(column.options || []);
      var seen = {};
      normalizeRows((state || {}).rows || []).forEach(function (row) {
        var value = row ? row[column.key] : '';
        if (value !== null && typeof value !== 'undefined' && value !== '') seen[String(value)] = true;
      });
      options.forEach(function (value) { if (value !== '') seen[String(value)] = true; });
      return Object.keys(seen).sort();
    },
    backendTableCanAddColumnOption: function (state, column) {
      if (!column) return false;
      var control = filterControlForColumn(column);
      return this.backendTableFeature(state, 'columnCrud') && (control === 'select');
    },
    backendTableAddColumnOption: function (tableId, column, value) {
      var state = this.backendTableState(tableId);
      value = String(value || '').trim();
      if (!column || !column.key || !value) return Promise.resolve({ ok: false });
      return this.backendTableMutate(tableId, 'column.option.add', { columnKey: column.key, value: value, keepEditor: true }).then(function (payload) {
        if (payload && payload.ok !== false) state.toast = 'Option added';
        return payload;
      });
    },
    backendTableAddFilterOption: function (tableId, column) {
      return this.backendTableOpenOptionDialog(tableId, column, 'filter');
    },
    backendTableAddEditorOption: function (tableId, column) {
      return this.backendTableOpenOptionDialog(tableId, column, 'editor');
    },
    backendTableOpenOptionDialog: function (tableId, column, context) {
      var state = this.backendTableState(tableId);
      if (!column || !column.key) return null;
      var value = '';
      if (context === 'filter') value = String((this.backendTableFilterDraftEntry(state, column.key) || {}).value || '');
      if (context === 'editor' && state.editor && state.editor.row) value = String(state.editor.row[column.key] || '');
      state.optionDialog = { open: true, context: context || 'filter', columnKey: column.key, columnLabel: column.label || column.key, value: value };
      state.error = '';
      return null;
    },
    backendTableCloseOptionDialog: function (tableId) {
      this.backendTableState(tableId).optionDialog = { open: false, context: '', columnKey: '', columnLabel: '', value: '' };
    },
    backendTableOptionDialogColumn: function (state) {
      var key = ((state || {}).optionDialog || {}).columnKey || '';
      return normalizeColumns((state || {}).columns || []).filter(function (col) { return col.key === key; })[0] || null;
    },
    backendTableSetOptionDialogValue: function (tableId, value) {
      var state = this.backendTableState(tableId);
      state.optionDialog = Object.assign({}, state.optionDialog || {}, { value: value || '' });
    },
    backendTableConfirmOptionDialog: function (tableId) {
      var state = this.backendTableState(tableId);
      var dialog = state.optionDialog || {};
      var column = this.backendTableOptionDialogColumn(state);
      var value = String(dialog.value || '').trim();
      if (!column || !column.key) { state.error = 'Choose a column before adding an option.'; return Promise.resolve({ ok: false, error: 'invalid_column_key' }); }
      if (!value) { state.error = 'Enter a value before adding it to the column options.'; return Promise.resolve({ ok: false, error: 'option_value_missing' }); }
      var vm = this;
      return this.backendTableAddColumnOption(tableId, column, value).then(function (payload) {
        if (payload && payload.ok !== false) {
          if (dialog.context === 'filter') vm.backendTableSetFilterDraft(tableId, column.key, 'value', value);
          if (dialog.context === 'editor' && state.editor && state.editor.row) state.editor.row[column.key] = value;
          vm.backendTableCloseOptionDialog(tableId);
        }
        return payload;
      });
    },
    backendTableFieldError: function (state, key) {
      return ((state || {}).validation || {})[key] || '';
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
      var col = clone(column || { key: '', label: '', type: 'text', width: 140, sortable: true, resizable: true, hidden: false });
      if (column && column.key) col.originalKey = column.key;
      state.editor = { open: true, mode: 'column', title: column && column.key ? 'Column designer: edit column' : 'Column designer: add column', row: {}, column: col };
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
      if ((state.editor || {}).mode === 'column') return this.backendTableMutate(tableId, 'column.save', { column: clone(state.editor.column || {}), originalKey: (state.editor.column || {}).originalKey || '' }).then(function(payload){ if (payload && payload.ok !== false) state.toast = 'Column saved'; });
      return this.backendTableMutate(tableId, 'row.save', { row: clone(state.editor.row || {}) }).then(function(payload){ if (payload && payload.ok !== false) state.toast = 'Row saved'; });
    },
    backendTableDeleteColumn: function (tableId, column) {
      if (!column || !column.key) return null;
      if (!this.backendTableFeature(this.backendTableState(tableId), 'columnCrud')) return null;
      return this.backendTableOpenConfirmDialog(tableId, { kind: 'column.delete', title: 'Delete column', message: 'Delete column "' + (column.label || column.key) + '"? This removes the column and values from the dataset.', confirmText: 'Delete column', danger: true, payload: { columnKey: column.key } });
    },
    backendTableOpenConfirmDialog: function (tableId, options) {
      var state = this.backendTableState(tableId);
      options = options || {};
      state.confirmDialog = { open: true, kind: options.kind || '', title: options.title || 'Confirm action', message: options.message || 'Continue?', confirmText: options.confirmText || 'Confirm', danger: !!options.danger, payload: clone(options.payload || {}) };
      return null;
    },
    backendTableCloseConfirmDialog: function (tableId) {
      this.backendTableState(tableId).confirmDialog = { open: false, kind: '', title: '', message: '', confirmText: 'Confirm', danger: false, payload: {} };
    },
    backendTableConfirmDialog: function (tableId) {
      var state = this.backendTableState(tableId);
      var dialog = state.confirmDialog || {};
      var payload = clone(dialog.payload || {});
      var action = dialog.kind || '';
      if (!action) { this.backendTableCloseConfirmDialog(tableId); return Promise.resolve({ ok: false, error: 'confirm_action_missing' }); }
      this.backendTableCloseConfirmDialog(tableId);
      var vm = this;
      return this.backendTableMutate(tableId, action, payload).then(function (result) {
        if (result && result.ok !== false) vm.backendTableSetToast(tableId, result.message || 'Table updated');
        return result;
      }).catch(function (err) {
        state.error = (err && err.message) || 'Table action failed';
        return { ok: false, error: state.error };
      });
    },
    backendTableMoveColumn: function (tableId, key, direction) {
      var state = this.backendTableState(tableId);
      if (!this.backendTableFeature(state, 'columnReorder')) return null;
      var columns = normalizeColumns(state.columns);
      var index = columns.findIndex(function (col) { return col.key === key; });
      var next = index + (+direction || 0);
      if (index < 0 || next < 0 || next >= columns.length) return null;
      var moved = columns.splice(index, 1)[0];
      columns.splice(next, 0, moved);
      state.columns = columns;
      this.backendTableCaptureColumnPrefs(state);
      return this.backendTableSaveColumnOrder(tableId);
    },
    backendTableSaveColumnOrder: function (tableId) {
      var state = this.backendTableState(tableId);
      var vm = this;
      this.backendTableCaptureColumnPrefs(state);
      var columns = normalizeColumns(state.columns).map(function (col, index) { return { key: col.key, order: index + 1 }; });
      return this.backendTableMutate(tableId, 'column.reorder', { columns: columns }).then(function (payload) { if (payload && payload.ok !== false) vm.backendTableSetToast(tableId, 'Column order saved'); return payload; });
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
    backendTableDialogStyle: function (state, key) {
      var pos = ((state || {}).dialogPositions || {})[key];
      if (!pos) return {};
      return { left: pos.left + 'px', top: pos.top + 'px', transform: 'none' };
    },
    backendTableBeginDialogDrag: function (tableId, key, event) {
      if (!event) return;
      var state = this.backendTableState(tableId);
      var modal = event.currentTarget && event.currentTarget.closest ? event.currentTarget.closest('.mioos-table-editor') : null;
      var host = event.currentTarget && event.currentTarget.closest ? event.currentTarget.closest('.mioos-full-table') : null;
      if (!modal || !host) return;
      var m = modal.getBoundingClientRect();
      var h = host.getBoundingClientRect();
      state.dialogPositions = Object.assign({}, state.dialogPositions || {});
      state.dialogPositions[key] = { left: Math.max(8, m.left - h.left), top: Math.max(8, m.top - h.top) };
      state.dialogDrag = { key: key, startX: event.clientX, startY: event.clientY, startLeft: state.dialogPositions[key].left, startTop: state.dialogPositions[key].top, maxLeft: Math.max(8, h.width - m.width - 8), maxTop: Math.max(8, h.height - m.height - 8) };
      var vm = this;
      function move(e) { vm.backendTableMoveDialog(tableId, e); }
      function up() { document.removeEventListener('pointermove', move); document.removeEventListener('pointerup', up); state.dialogDrag = null; }
      document.addEventListener('pointermove', move);
      document.addEventListener('pointerup', up, { once: true });
    },
    backendTableMoveDialog: function (tableId, event) {
      var state = this.backendTableState(tableId);
      var drag = state.dialogDrag;
      if (!drag || !event) return;
      var left = Math.max(8, Math.min(drag.maxLeft, drag.startLeft + event.clientX - drag.startX));
      var top = Math.max(8, Math.min(drag.maxTop, drag.startTop + event.clientY - drag.startY));
      state.dialogPositions = Object.assign({}, state.dialogPositions || {});
      state.dialogPositions[drag.key] = { left: left, top: top };
    },
    backendTableCloseTopDialog: function (tableId) {
      var state = this.backendTableState(tableId);
      if ((state.confirmDialog || {}).open) return this.backendTableCloseConfirmDialog(tableId);
      if ((state.optionDialog || {}).open) return this.backendTableCloseOptionDialog(tableId);
      if ((state.editor || {}).open) return this.backendTableCloseEditor(tableId);
      if (state.columnPickerOpen) return this.backendTableCloseColumnPicker(tableId);
      if (state.groupModalOpen) return this.backendTableCloseGrouping(tableId);
      if (state.filterModalOpen) return this.backendTableCloseFilters(tableId);
      if ((state.cellEditor || {}).open) return this.backendTableCancelCellEditor(tableId);
    },
    backendTableHandleKeydown: function (tableId, event) {
      if (!event || event.key !== 'Escape') return;
      this.backendTableCloseTopDialog(tableId);
    },
    backendTableApplyConfig: function (tableId, config) {
      var state = this.backendTableState(tableId);
      state.config = mergeConfig(defaultTableConfig(), config || state.config || {});
      if (state.config.defaultPageSize) state.pagination.pageSize = +state.config.defaultPageSize || state.pagination.pageSize;
      if (state.config.defaultSort) state.sort = clone(state.config.defaultSort);
      if (state.config.columns && state.config.columns.length) state.columns = normalizeColumns(state.config.columns);
      state.actionsWidth = Math.max(96, +(state.config.actionsWidth || state.actionsWidth || 156));
      state.fixedColumns = this.backendTableNormalizeFixedColumns(state, state.config.fixedColumns || state.fixedColumns);
      return state.config;
    },
    backendTableFeature: function (state, key) {
      var cfg = mergeConfig(defaultTableConfig(), (state || {}).config || {});
      var enabled = !!((cfg.features || {})[key]);
      var map = { rowCrud: 'crudRows', columnCrud: 'crudColumns', rowDetails: 'expansionRows', resizeColumns: 'resizableColumns', filters: 'filtering', grouping: 'columnGrouping', bulkActions: 'bulkActions', selection: 'selection', pagination: 'serverPagination', cellEditing: 'cellEditing', columnReorder: 'columnReorder', fixedColumns: 'fixedColumns' };
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
        filterableColumns: function () { return this.vm.backendTableFilterableColumns(this.state); },
        editorGroups: function () { return this.vm.backendTableEditorGroups(this.state); }
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
        '<section class="mioos-full-table" tabindex="0" @keydown.esc.stop="vm.backendTableHandleKeydown(tableId || state.id, $event)" :class="[\'density-\' + ((state.config || {}).density || \'compact\'), { \'is-processing\': state.loading, \'is-readonly\': state.readOnly }]" :aria-busy="(state.loading || state.saving) ? \'true\' : \'false\'">' +
          '<header class="mioos-table-toolbar">' +
            '<div><strong>[[ state.title || title || \'Backend Table\' ]]</strong><span>Server-side table · dense MUMPS module API</span></div>' +
            '<label v-if="vm.backendTableFeature(state, &quot;datasetSwitcher&quot;)"><span>Dataset</span><select :value="state.dataset" @change="vm.backendTableSetDataset(tableId || state.id, $event.target.value)"><option value="demo">Sample table</option><option value="patient-registration">Patient registration</option><option value="ui-elements">UI + form elements</option><option value="massive">Massive dataset</option><option value="vfs">VFS folder</option></select></label>' +
            '<label v-if="vm.backendTableFeature(state, &quot;search&quot;)" class="mioos-table-search"><span>Search</span><input v-model="searchInput" :disabled="state.loading || state.saving" @keydown.enter="commitSearch" @blur="commitSearch" placeholder="Filter rows" aria-label="Search table rows"></label>' +
            '<button v-if="vm.backendTableFeature(state, &quot;filters&quot;)" class="mioos-btn" type="button" @click="vm.backendTableOpenFilters(tableId || state.id)">Filters</button>' +
            '<button v-if="vm.backendTableFeature(state, &quot;grouping&quot;)" class="mioos-btn" type="button" @click="vm.backendTableOpenGrouping(tableId || state.id)">Group<span v-if="state.groupByColumns && state.groupByColumns.length"> ([[ state.groupByColumns.length ]])</span></button>' +
            '<button v-if="vm.backendTableFeature(state, &quot;columnPicker&quot;)" class="mioos-btn" type="button" @click="vm.backendTableOpenColumnPicker(tableId || state.id)">Columns</button>' +
            '<button v-if="vm.backendTableFeature(state, &quot;rowCrud&quot;)" type="button" class="mioos-btn" @click="vm.backendTableOpenRowEditor(tableId || state.id)">Add row</button>' +
            '<button v-if="vm.backendTableFeature(state, &quot;columnCrud&quot;)" type="button" class="mioos-btn" @click="vm.backendTableOpenColumnEditor(tableId || state.id)">Add column</button>' +
            '<span v-if="state.readOnly" class="mioos-table-readonly">Read-only</span>' +
          '</header>' +
          '<div class="mioos-table-processing" :class="{ active: state.loading }" role="status" aria-label="Table loading" :aria-hidden="state.loading ? \'false\' : \'true\'"><span class="mioos-table-loading-line"></span></div>' +
          '<div class="mioos-table-feedback-rail" aria-live="polite"><div class="mioos-table-toast" role="status" :class="{ active: !!state.toast }" :aria-hidden="state.toast ? \'false\' : \'true\'">[[ state.toast ]]</div><div class="mioos-table-error" role="alert" :class="{ active: !!state.error }" :aria-hidden="state.error ? \'false\' : \'true\'">[[ state.error ]]</div></div>' +
          '<aside class="mioos-table-patient-banner" v-if="state.patientRegistration"><div><strong>[[ state.patientRegistration.title || &quot;Patient Registration&quot; ]]</strong><span>[[ state.patientRegistration.statusMessage || state.patientRegistration.notice ]]</span></div><ol v-if="state.patientRegistration.workflow"><li v-for="step in state.patientRegistration.workflow" :key="step">[[ step ]]</li></ol><small v-if="state.patientRegistration.duplicateCandidateCount">[[ state.patientRegistration.duplicateCandidateCount ]] duplicate candidate(s) need review</small></aside>' +
          '<div class="mioos-table-bulkbar" v-if="selectedCount && vm.backendTableFeature(state, &quot;bulkActions&quot;)"><span>[[ selectedCount ]] selected</span><button v-for="action in state.bulkActions" :key="action.key" type="button" @click="vm.backendTableRunBulkAction(tableId || state.id, action)">[[ action.label ]]</button><button type="button" @click="vm.backendTableClearSelection(tableId || state.id)">Clear</button></div>' +
          '<div class="mioos-table-editor-backdrop" v-if="state.filterModalOpen" @click.self="vm.backendTableCloseFilters(tableId || state.id)">' +
            '<div class="mioos-table-editor is-filter-editor mioos-system-modal" role="dialog" aria-modal="true" :style="vm.backendTableDialogStyle(state, &quot;filters&quot;)">' +
              '<header class="mioos-system-modal-titlebar" @pointerdown.prevent="vm.backendTableBeginDialogDrag(tableId || state.id, &quot;filters&quot;, $event)"><strong>Advanced filters</strong><button type="button" aria-label="Close filters" @pointerdown.stop @click.stop="vm.backendTableCloseFilters(tableId || state.id)">×</button></header>' +
              '<section class="mioos-table-modal-list is-advanced-filter"><article v-for="col in filterableColumns" :key="col.key" class="mioos-table-filter-row"><div><strong>[[ col.label ]]</strong><small>[[ col.key ]] · [[ col.type ]]</small></div><select :value="vm.backendTableFilterDraftEntry(state, col.key).mode" @change="vm.backendTableSetFilterDraft(tableId || state.id, col.key, &quot;mode&quot;, $event.target.value)"><option value="include">Include</option><option value="exclude">Exclude</option><option value="contains">Contains</option><option value="starts">Starts with</option><option value="ends">Ends with</option><option value="range">Range</option><option value="blank">Blank</option><option value="notblank">Not blank</option></select><template v-if="vm.backendTableFilterDraftEntry(state, col.key).mode === &quot;range&quot;"><input :type="vm.backendTableFilterControl(col) === &quot;date&quot; ? &quot;date&quot; : (vm.backendTableFilterControl(col) === &quot;number&quot; ? &quot;number&quot; : &quot;text&quot;)" :value="vm.backendTableFilterDraftEntry(state, col.key).from" @input="vm.backendTableSetFilterDraft(tableId || state.id, col.key, &quot;from&quot;, $event.target.value)" placeholder="From"><input :type="vm.backendTableFilterControl(col) === &quot;date&quot; ? &quot;date&quot; : (vm.backendTableFilterControl(col) === &quot;number&quot; ? &quot;number&quot; : &quot;text&quot;)" :value="vm.backendTableFilterDraftEntry(state, col.key).to" @input="vm.backendTableSetFilterDraft(tableId || state.id, col.key, &quot;to&quot;, $event.target.value)" placeholder="To"></template><template v-else-if="vm.backendTableFilterControl(col) === &quot;select&quot;"><select :value="vm.backendTableFilterDraftEntry(state, col.key).value" @change="vm.backendTableSetFilterDraft(tableId || state.id, col.key, &quot;value&quot;, $event.target.value)"><option value="">Any</option><option v-for="opt in vm.backendTableColumnOptions(state, col)" :key="opt" :value="opt">[[ opt ]]</option></select><button v-if="vm.backendTableCanAddColumnOption(state, col)" type="button" class="mioos-table-inline-link" @click="vm.backendTableAddFilterOption(tableId || state.id, col)">Add value</button></template><template v-else-if="vm.backendTableFilterControl(col) === &quot;boolean&quot;"><select :value="vm.backendTableFilterDraftEntry(state, col.key).value" @change="vm.backendTableSetFilterDraft(tableId || state.id, col.key, &quot;value&quot;, $event.target.value)"><option value="">Any</option><option value="true">True</option><option value="false">False</option></select></template><input v-else :type="vm.backendTableFilterControl(col) === &quot;date&quot; ? &quot;date&quot; : (vm.backendTableFilterControl(col) === &quot;number&quot; ? &quot;number&quot; : &quot;text&quot;)" :value="vm.backendTableFilterDraftEntry(state, col.key).value" @input="vm.backendTableSetFilterDraft(tableId || state.id, col.key, &quot;value&quot;, $event.target.value)" placeholder="Filter value"></article></section>' +
              '<footer><button type="button" class="mioos-btn is-primary" @click="vm.backendTableApplyFilters(tableId || state.id)">Apply filters</button><button type="button" class="mioos-btn" @click="vm.backendTableClearFilters(tableId || state.id)">Clear filters</button><button type="button" class="mioos-btn" @click="vm.backendTableCloseFilters(tableId || state.id)">Cancel</button></footer>' +
            '</div>' +
          '</div>' +
          '<div class="mioos-table-editor-backdrop" v-if="state.groupModalOpen" @click.self="vm.backendTableCloseGrouping(tableId || state.id)">' +
            '<div class="mioos-table-editor is-group-editor mioos-system-modal" role="dialog" aria-modal="true" :style="vm.backendTableDialogStyle(state, &quot;grouping&quot;)">' +
              '<header class="mioos-system-modal-titlebar" @pointerdown.prevent="vm.backendTableBeginDialogDrag(tableId || state.id, &quot;grouping&quot;, $event)"><strong>Group columns</strong><button type="button" aria-label="Close grouping" @pointerdown.stop @click.stop="vm.backendTableCloseGrouping(tableId || state.id)">×</button></header>' +
              '<section class="mioos-table-column-list"><button v-for="col in allColumns" :key="col.key" type="button" :class="{ active: state.groupDraftColumns.indexOf(col.key) >= 0 }" @click="vm.backendTableToggleGroupDraft(tableId || state.id, col.key)"><span>[[ state.groupDraftColumns.indexOf(col.key) >= 0 ? &quot;☑&quot; : &quot;☐&quot; ]]</span><b>[[ col.label ]]</b><small>[[ col.key ]]</small></button></section>' +
              '<footer><button type="button" class="mioos-btn is-primary" @click="vm.backendTableApplyGrouping(tableId || state.id)">Apply grouping</button><button type="button" class="mioos-btn" @click="vm.backendTableSetGroupBy(tableId || state.id, &quot;&quot;); vm.backendTableCloseGrouping(tableId || state.id)">Clear grouping</button></footer>' +
            '</div>' +
          '</div>' +
          '<div class="mioos-table-editor-backdrop" v-if="state.columnPickerOpen" @click.self="vm.backendTableCloseColumnPicker(tableId || state.id)">' +
            '<div class="mioos-table-editor is-column-picker mioos-system-modal" role="dialog" aria-modal="true" :style="vm.backendTableDialogStyle(state, &quot;columns&quot;)">' +
              '<header class="mioos-system-modal-titlebar" @pointerdown.prevent="vm.backendTableBeginDialogDrag(tableId || state.id, &quot;columns&quot;, $event)"><strong>Visible columns</strong><button type="button" aria-label="Close columns" @pointerdown.stop @click.stop="vm.backendTableCloseColumnPicker(tableId || state.id)">×</button></header>' +
              '<section v-if="vm.backendTableFeature(state, &quot;fixedColumns&quot;)" class="mioos-table-fixed-controls"><label><span>Fixed start columns</span><input type="number" min="0" :max="columns.length" :value="(state.fixedColumns || {}).start || 0" @change="vm.backendTableSetFixedColumns(tableId || state.id, &quot;start&quot;, $event.target.value)"></label><label><span>Fixed end columns</span><input type="number" min="0" :max="columns.length" :value="(state.fixedColumns || {}).end || 0" @change="vm.backendTableSetFixedColumns(tableId || state.id, &quot;end&quot;, $event.target.value)"></label></section>' +
              '<section class="mioos-table-column-list">' +
                '<article v-for="(col, index) in allColumns" :key="col.key" class="mioos-table-column-item">' +
                  '<button type="button" :class="{ active: !col.hidden }" @click="vm.backendTableToggleColumn(tableId || state.id, col.key)"><span>[[ col.hidden ? &quot;☐&quot; : &quot;☑&quot; ]]</span><b>[[ col.label ]]</b><small>[[ col.key ]]</small></button>' +
                  '<span v-if="vm.backendTableFeature(state, &quot;columnReorder&quot;)" class="mioos-table-column-reorder"><button type="button" :disabled="index === 0 || state.saving" @click="vm.backendTableMoveColumn(tableId || state.id, col.key, -1)">↑</button><button type="button" :disabled="index >= allColumns.length - 1 || state.saving" @click="vm.backendTableMoveColumn(tableId || state.id, col.key, 1)">↓</button></span>' +
                '</article>' +
              '</section>' +
            '</div>' +
          '</div>' +
          '<div class="mioos-table-editor-backdrop" v-if="state.editor && state.editor.open" @click.self="vm.backendTableCloseEditor(tableId || state.id)">' +
            '<div class="mioos-table-editor mioos-system-modal" role="dialog" aria-modal="true" :style="vm.backendTableDialogStyle(state, &quot;editor&quot;)">' +
              '<header class="mioos-system-modal-titlebar" @pointerdown.prevent="vm.backendTableBeginDialogDrag(tableId || state.id, &quot;editor&quot;, $event)"><strong>[[ state.editor.title ]]</strong><button type="button" aria-label="Close editor" @pointerdown.stop @click.stop="vm.backendTableCloseEditor(tableId || state.id)">×</button></header>' +
              '<section v-if="state.editor.mode === \'row\'" class="mioos-table-intake-form"><article v-for="group in editorGroups" :key="group.label" class="mioos-table-intake-section"><h3>[[ group.label ]]</h3><div class="mioos-table-form-grid"><label v-for="col in group.columns" :key="col.key" :class="{ \'has-error\': vm.backendTableFieldError(state, col.key) }"><span>[[ col.label ]]</span><textarea v-if="vm.backendTableFilterControl(col) === &quot;textarea&quot;" v-model="state.editor.row[col.key]" :placeholder="col.key"></textarea><select v-else-if="col.type === &quot;multiselect&quot;" multiple v-model="state.editor.row[col.key]"><option v-for="opt in vm.backendTableColumnOptions(state, col)" :key="opt" :value="opt">[[ opt ]]</option></select><select v-else-if="vm.backendTableFilterControl(col) === &quot;select&quot;" v-model="state.editor.row[col.key]"><option value="">Choose…</option><option v-for="opt in vm.backendTableColumnOptions(state, col)" :key="opt" :value="opt">[[ opt ]]</option></select><select v-else-if="vm.backendTableFilterControl(col) === &quot;boolean&quot;" v-model="state.editor.row[col.key]"><option value="">Choose…</option><option value="true">True</option><option value="false">False</option></select><input v-else-if="vm.backendTableFilterControl(col) === &quot;date&quot;" type="date" v-model="state.editor.row[col.key]" :placeholder="col.key"><input v-else-if="vm.backendTableFilterControl(col) === &quot;number&quot;" type="number" v-model="state.editor.row[col.key]" :placeholder="col.key"><input v-else v-model="state.editor.row[col.key]" :placeholder="col.key"><button v-if="vm.backendTableCanAddColumnOption(state, col)" type="button" class="mioos-table-inline-link" @click="vm.backendTableAddEditorOption(tableId || state.id, col)">Add option</button><small v-if="vm.backendTableFieldError(state, col.key)" class="mioos-field-error">[[ vm.backendTableFieldError(state, col.key) ]]</small></label></div></article></section>' +
              '<section v-else class="mioos-table-form-grid"><label><span>Key</span><input v-model="state.editor.column.key" :disabled="!!state.editor.column.originalKey" placeholder="fieldName"><small v-if="state.editor.column.originalKey">Column keys are immutable; create a new column to change the key.</small></label><label><span>Label</span><input v-model="state.editor.column.label" placeholder="Column label"></label><label><span>Type</span><select v-model="state.editor.column.type"><option>text</option><option>textarea</option><option>select</option><option>multiselect</option><option>badge</option><option>date</option><option>number</option><option>boolean</option></select></label><label><span>Width</span><input type="number" v-model="state.editor.column.width"></label><label><span>Group</span><input v-model="state.editor.column.group" placeholder="Optional header group"></label><label class="mioos-table-check"><span>Hidden</span><input type="checkbox" v-model="state.editor.column.hidden"></label></section>' +
              '<p class="mioos-table-error" v-for="err in Object.values(state.validation || {})" :key="err">[[ err ]]</p><footer><button type="button" class="mioos-btn is-primary" :disabled="state.saving || state.loading" @click="vm.backendTableSaveEditor(tableId || state.id)">[[ state.saving ? &quot;Saving…&quot; : &quot;Save&quot; ]]</button><button type="button" class="mioos-btn" @click="vm.backendTableCloseEditor(tableId || state.id)">Cancel</button></footer>' +
            '</div>' +
          '</div>' +
          '<div class="mioos-table-editor-backdrop" v-if="state.optionDialog && state.optionDialog.open" @click.self="vm.backendTableCloseOptionDialog(tableId || state.id)">' +
            '<div class="mioos-table-editor is-option-editor mioos-system-modal" role="dialog" aria-modal="true" :style="vm.backendTableDialogStyle(state, &quot;option&quot;)">' +
              '<header class="mioos-system-modal-titlebar" @pointerdown.prevent="vm.backendTableBeginDialogDrag(tableId || state.id, &quot;option&quot;, $event)"><strong>Add value</strong><button type="button" aria-label="Close add value" @pointerdown.stop @click.stop="vm.backendTableCloseOptionDialog(tableId || state.id)">×</button></header>' +
              '<section class="mioos-table-form-grid"><label><span>Column</span><input readonly :value="(state.optionDialog || {}).columnLabel"></label><label><span>New value</span><input :value="(state.optionDialog || {}).value" @input="vm.backendTableSetOptionDialogValue(tableId || state.id, $event.target.value)" @keydown.enter="vm.backendTableConfirmOptionDialog(tableId || state.id)" autofocus></label></section>' +
              '<footer><button type="button" class="mioos-btn is-primary" :disabled="state.saving" @click="vm.backendTableConfirmOptionDialog(tableId || state.id)">Add value</button><button type="button" class="mioos-btn" @click="vm.backendTableCloseOptionDialog(tableId || state.id)">Cancel</button></footer>' +
            '</div>' +
          '</div>' +
          '<div class="mioos-table-editor-backdrop" v-if="state.confirmDialog && state.confirmDialog.open" @click.self="vm.backendTableCloseConfirmDialog(tableId || state.id)">' +
            '<div class="mioos-table-editor is-confirm-editor mioos-system-modal" role="dialog" aria-modal="true" :style="vm.backendTableDialogStyle(state, &quot;confirm&quot;)">' +
              '<header class="mioos-system-modal-titlebar" @pointerdown.prevent="vm.backendTableBeginDialogDrag(tableId || state.id, &quot;confirm&quot;, $event)"><strong>[[ (state.confirmDialog || {}).title || &quot;Confirm action&quot; ]]</strong><button type="button" aria-label="Close confirmation" @pointerdown.stop @click.stop="vm.backendTableCloseConfirmDialog(tableId || state.id)">×</button></header>' +
              '<section class="mioos-table-confirm-body"><p>[[ (state.confirmDialog || {}).message || &quot;Continue?&quot; ]]</p></section>' +
              '<footer><button type="button" class="mioos-btn" :class="{ danger: (state.confirmDialog || {}).danger }" :disabled="state.saving" @click="vm.backendTableConfirmDialog(tableId || state.id)">[[ (state.confirmDialog || {}).confirmText || &quot;Confirm&quot; ]]</button><button type="button" class="mioos-btn" @click="vm.backendTableCloseConfirmDialog(tableId || state.id)">Cancel</button></footer>' +
            '</div>' +
          '</div>' +
          '<div class="mioos-table-wrap">' +
            '<table class="mioos-table-grid" role="grid">' +
              '<colgroup><col v-if="vm.backendTableShowControl(state)" class="mioos-table-select-col"><col v-for="col in columns" :key="col.key" :style="vm.backendTableColumnStyle(col)"><col v-if="vm.backendTableShowActions(state)" class="mioos-table-actions-col" :style="vm.backendTableActionsStyle(state)"></colgroup>' +
              '<thead>' +
                '<tr v-if="vm.backendTableFeature(state, &quot;columnGroups&quot;)" class="mioos-table-groups"><th v-if="vm.backendTableShowControl(state)"></th><th v-for="group in columnGroups" :key="group.label + group.span" :colspan="group.span">[[ group.label ]]</th><th v-if="vm.backendTableShowActions(state)"></th></tr>' +
                '<tr><th v-if="vm.backendTableShowControl(state)" class="mioos-table-control-head" :class="vm.backendTableStickyClass(state, null, -1, &quot;control&quot;)" :style="vm.backendTableStickyStyle(state, null, -1, &quot;control&quot;)"><label v-if="vm.backendTableShowSelection(state)" class="mioos-table-select-all"><input type="checkbox" :checked="vm.backendTableAllVisibleSelected(state)" @change="vm.backendTableToggleSelectAllVisible(tableId || state.id)"><span>All</span></label><span v-else class="sr-only">Details</span></th><th v-for="(col, index) in columns" :key="col.key" :class="vm.backendTableStickyClass(state, col, index, &quot;head&quot;)" :style="Object.assign({}, vm.backendTableColumnStyle(col), vm.backendTableStickyStyle(state, col, index, &quot;head&quot;))"><button type="button" @click="vm.backendTableSortBy(tableId || state.id, col)">[[ col.label ]] [[ vm.backendTableSortMark(state, col) ]]</button><button v-if="vm.backendTableFeature(state, &quot;columnCrud&quot;)" type="button" class="mioos-table-col-edit" title="Edit column" @click.stop="vm.backendTableOpenColumnEditor(tableId || state.id, col)">⚙</button><button v-if="vm.backendTableFeature(state, &quot;columnCrud&quot;)" type="button" class="mioos-table-col-delete" title="Delete column" @click.stop="vm.backendTableDeleteColumn(tableId || state.id, col)">×</button><span v-if="vm.backendTableFeature(state, &quot;resizeColumns&quot;)" class="mioos-table-resizer" @pointerdown.prevent="vm.backendTableBeginColumnResize(tableId || state.id, col, $event)"></span></th><th v-if="vm.backendTableShowActions(state)" class="mioos-table-actions-head" :class="vm.backendTableStickyClass(state, null, -1, &quot;actions&quot;)" :style="Object.assign({}, vm.backendTableActionsStyle(state), vm.backendTableStickyStyle(state, null, -1, &quot;actions&quot;))"><span>Actions</span><span class="mioos-table-resizer" @pointerdown.prevent="vm.backendTableBeginActionsResize(tableId || state.id, $event)"></span></th></tr>' +
              '</thead>' +
              '<tbody>' +
                '<tr v-if="!state.loading && !state.rows.length" class="mioos-table-empty-row"><td :colspan="vm.backendTableColspan(state)">[[ state.config.emptyMessage ]]</td></tr>' +
                '<template v-for="group in rowGroups" :key="group.key || \'all\'">' +
                  '<tr v-if="state.groupByColumns && state.groupByColumns.length" class="mioos-table-group-row"><td :colspan="vm.backendTableColspan(state)"><button type="button" @click="vm.backendTableToggleGroup(tableId || state.id, group.key)">[[ vm.backendTableIsGroupExpanded(state, group.key) ? \'▾\' : \'▸\' ]]</button><strong>[[ group.label ]]</strong><span>[[ group.count ]] rows</span></td></tr>' +
                  '<template v-if="!(state.groupByColumns && state.groupByColumns.length) || vm.backendTableIsGroupExpanded(state, group.key)">' +
                    '<template v-for="row in group.rows" :key="keyOf(row)">' +
                      '<tr :class="{ \'is-selected\': vm.backendTableIsSelected(state, row) }"><td v-if="vm.backendTableShowControl(state)" class="mioos-table-control-cell" :class="vm.backendTableStickyClass(state, null, -1, &quot;control&quot;)" :style="vm.backendTableStickyStyle(state, null, -1, &quot;control&quot;)"><button v-if="row._expand && vm.backendTableFeature(state, &quot;rowDetails&quot;)" class="mioos-table-detail-toggle" type="button" :aria-expanded="vm.backendTableIsExpanded(state, row) ? \'true\' : \'false\'" @click="vm.backendTableToggleExpand(tableId || state.id, row)">[[ vm.backendTableIsExpanded(state, row) ? \'▾\' : \'▸\' ]]</button><input v-if="vm.backendTableShowSelection(state)" type="checkbox" :checked="vm.backendTableIsSelected(state, row)" @change="vm.backendTableToggleRow(tableId || state.id, row)"></td><td v-for="(col, index) in columns" :key="col.key" :class="[vm.backendTableStickyClass(state, col, index, &quot;body&quot;), { \'is-cell-editing\': vm.backendTableIsCellEditing(state, row, col), \'is-cell-editable\': vm.backendTableCanEditCell(state, row, col) }]" :style="vm.backendTableStickyStyle(state, col, index, &quot;body&quot;)"><div v-if="vm.backendTableIsCellEditing(state, row, col)" class="mioos-table-cell-editor"><textarea v-if="vm.backendTableFilterControl(col) === &quot;textarea&quot;" :value="vm.backendTableCellDraftValue(state, row, col)" @input="vm.backendTableSetCellDraft(tableId || state.id, $event.target.value)"></textarea><select v-else-if="col.type === &quot;multiselect&quot;" multiple :value="vm.backendTableCellMultiValue(state, row, col)" @change="vm.backendTableSetCellMultiDraft(tableId || state.id, $event)"><option v-for="opt in vm.backendTableColumnOptions(state, col)" :key="opt" :value="opt">[[ opt ]]</option></select><select v-else-if="vm.backendTableFilterControl(col) === &quot;select&quot;" :value="vm.backendTableCellDraftValue(state, row, col)" @change="vm.backendTableSetCellDraft(tableId || state.id, $event.target.value)"><option value="">Choose…</option><option v-for="opt in vm.backendTableColumnOptions(state, col)" :key="opt" :value="opt">[[ opt ]]</option></select><select v-else-if="vm.backendTableFilterControl(col) === &quot;boolean&quot;" :value="vm.backendTableCellDraftValue(state, row, col)" @change="vm.backendTableSetCellDraft(tableId || state.id, $event.target.value)"><option value="">Choose…</option><option value="true">True</option><option value="false">False</option></select><input v-else-if="vm.backendTableFilterControl(col) === &quot;date&quot;" type="date" :value="vm.backendTableCellDraftValue(state, row, col)" @input="vm.backendTableSetCellDraft(tableId || state.id, $event.target.value)"><input v-else-if="vm.backendTableFilterControl(col) === &quot;number&quot;" type="number" :value="vm.backendTableCellDraftValue(state, row, col)" @input="vm.backendTableSetCellDraft(tableId || state.id, $event.target.value)"><input v-else :value="vm.backendTableCellDraftValue(state, row, col)" @input="vm.backendTableSetCellDraft(tableId || state.id, $event.target.value)"><small v-if="vm.backendTableFieldError(state, col.key)" class="mioos-field-error">[[ vm.backendTableFieldError(state, col.key) ]]</small><span class="mioos-table-cell-actions"><button type="button" class="mioos-btn is-primary" :disabled="state.saving" @click="vm.backendTableSaveCell(tableId || state.id, row, col)">Save</button><button type="button" class="mioos-btn" @click="vm.backendTableCancelCellEditor(tableId || state.id)">Cancel</button></span></div><button v-else-if="vm.backendTableCanEditCell(state, row, col)" type="button" class="mioos-table-cell-edit-button" @click="vm.backendTableOpenCellEditor(tableId || state.id, row, col)"><span :class="\'mioos-table-cell type-\' + col.type">[[ vm.backendTableCellText(row, col) ]]</span><small>Edit</small></button><span v-else :class="\'mioos-table-cell type-\' + col.type">[[ vm.backendTableCellText(row, col) ]]</span></td><td v-if="vm.backendTableShowActions(state)" class="mioos-table-actions" :class="vm.backendTableStickyClass(state, null, -1, &quot;actions&quot;)" :style="vm.backendTableStickyStyle(state, null, -1, &quot;actions&quot;)"><button v-for="action in vm.backendTableVisibleRowActions(state)" :key="action.key" type="button" @click="vm.backendTableRunAction(tableId || state.id, action, row)">[[ action.label ]]</button></td></tr>' +
                      '<tr v-if="vm.backendTableIsExpanded(state, row)" class="mioos-table-expanded-row"><td v-if="vm.backendTableShowControl(state)"></td><td :colspan="columns.length + (vm.backendTableShowActions(state) ? 1 : 0)"><strong>[[ (row._expand || {}).title || \'Details\' ]]</strong><p>[[ (row._expand || {}).body || JSON.stringify(row) ]]</p></td></tr>' +
                    '</template>' +
                  '</template>' +
                '</template>' +
              '</tbody>' +
            '</table>' +
          '</div>' +
          '<footer v-if="vm.backendTableFeature(state, &quot;pagination&quot;)" class="mioos-table-pager"><span>[[ vm.backendTablePageRangeLabel(state) ]]</span><button type="button" :disabled="state.loading || state.saving" @click="vm.backendTableSetPage(tableId || state.id, 1)">First</button><button type="button" :disabled="state.loading || state.saving" @click="vm.backendTableSetPage(tableId || state.id, state.pagination.page - 1)">Prev</button><label>Page <input type="number" min="1" :max="state.pagination.pageCount" v-model.number="state.pagination.pageJump" @keydown.enter="vm.backendTableSetPage(tableId || state.id, state.pagination.pageJump || state.pagination.page)"></label><span>/ [[ state.pagination.pageCount ]]</span><button type="button" :disabled="state.loading || state.saving" @click="vm.backendTableSetPage(tableId || state.id, state.pagination.page + 1)">Next</button><button type="button" :disabled="state.loading || state.saving" @click="vm.backendTableSetPage(tableId || state.id, state.pagination.pageCount)">Last</button><label>Rows <select :value="state.pagination.pageSize" @change="vm.backendTableSetPageSize(tableId || state.id, $event.target.value)"><option>10</option><option>25</option><option>50</option><option>100</option><option>250</option></select></label></footer>' +
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
    window.MIOOSModules.registerComponent({ key: 'table', name: 'mioos-full-table', title: 'Advanced Backend Table', surface: 'mioos-surface-table', description: 'Server-side table with WebSocket query, HTTP-safe mutations, dense layouts, sorting, selection, bulk actions, row and column CRUD, resizable columns, column reorder, fixed columns, grouping, and massive datasets.' });
    window.MIOOSModules.registerComponent({ key: 'table-showcase', name: 'mioos-surface-table-showcase', title: 'Table Variations', surface: 'mioos-surface-table-showcase', description: 'Copyable simple-to-advanced MUMPS table contracts for backend developers.' });
  }
})();
