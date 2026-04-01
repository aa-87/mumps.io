(function () {
  function windowById(vm, windowId) {
    return (vm.windows || []).find(function (item) { return item.id === windowId; }) || null;
  }

  function setStatus(win, text) {
    if (!win) return;
    win.explorerState = win.explorerState || {};
    win.explorerState.status = text || '';
  }

  function iconFor(entry) {
    if (!entry) return '•';
    if (entry.kind === 'folder') return '📁';
    if ((entry.mime || '').indexOf('text/') === 0) return '📄';
    return '📦';
  }

  window.MIOOSExplorer = {
    methods: {
      ensureExplorerWindow: function (win) {
        if (!win) return;
        if (win.appKey !== 'my-computer' && win.appKey !== 'documents') return;
        if (win.explorerState && win.explorerState.ready) return;
        var rootId = (((this.boot || {}).vfs || {}).rootId) || 'root';
        var homeId = (((this.boot || {}).vfs || {}).homeId) || rootId;
        var startId = win.appKey === 'documents' ? homeId : rootId;
        var startName = win.appKey === 'documents' ? (win.title || this.t('app.documents.title', 'My Documents')) : (win.title || this.t('app.my-computer.title', 'My Computer'));
        win.explorerState = {
          ready: true,
          currentFolderId: startId,
          currentFolderName: startName,
          parentId: '',
          entries: [],
          selectedId: '',
          selectedEntry: null,
          preview: '',
          status: this.t('explorer.status.ready', 'Ready'),
          loading: false,
          path: ''
        };
      },
      primeExplorerWindows: function () {
        var self = this;
        (this.windows || []).forEach(function (win) {
          if ((win.appKey === 'my-computer' || win.appKey === 'documents') && win.state !== 'closed' && win.state !== 'minimized') {
            self.openExplorerWindow(win.id);
          }
        });
      },
      explorerLocations: function () {
        var vfs = (this.boot || {}).vfs || {};
        return [
          { key: 'root', id: vfs.rootId || 'root', title: this.t('app.my-computer.title', 'My Computer'), icon: '💻' },
          { key: 'documents', id: vfs.homeId || vfs.rootId || 'root', title: this.t('app.documents.title', 'My Documents'), icon: '📁' }
        ];
      },
      explorerEntries: function (win) {
        this.ensureExplorerWindow(win);
        return ((win || {}).explorerState || {}).entries || [];
      },
      explorerSelected: function (win) {
        this.ensureExplorerWindow(win);
        return ((win || {}).explorerState || {}).selectedEntry || null;
      },
      explorerPreview: function (win) {
        this.ensureExplorerWindow(win);
        return (((win || {}).explorerState || {}).preview) || '';
      },
      explorerStatusText: function (win) {
        this.ensureExplorerWindow(win);
        return (((win || {}).explorerState || {}).status) || this.t('explorer.status.ready', 'Ready');
      },
      explorerIcon: function (entry) {
        return iconFor(entry);
      },
      openExplorerWindow: function (windowId, folderId) {
        var self = this;
        var win = windowById(this, windowId);
        if (!win) return Promise.resolve(false);
        this.ensureExplorerWindow(win);
        win.state = 'normal';
        this.focusWindow(windowId);
        return this.loadExplorerFolder(windowId, folderId || win.explorerState.currentFolderId).then(function () {
          return true;
        }).catch(function (err) {
          self.showAlert(self.t('alerts.fsListFailed.title', 'Explorer unavailable'), (err && (err.detail || err.message)) || self.t('alerts.fsListFailed.message', 'Unable to load folder.'));
          return false;
        });
      },
      loadExplorerFolder: function (windowId, folderId) {
        var self = this;
        var win = windowById(this, windowId);
        if (!win) return Promise.reject(new Error('window_missing'));
        this.ensureExplorerWindow(win);
        win.explorerState.loading = true;
        setStatus(win, this.t('explorer.status.loading', 'Loading folder...'));
        return this.command('fs.list', { parent: folderId }).then(function (msg) {
          var vfs = msg.vfs || {};
          var folder = vfs.folder || {};
          var entries = Array.isArray(vfs.entries) ? vfs.entries.slice() : [];
          entries.sort(function (a, b) {
            var ak = (a.kind === 'folder') ? 0 : 1;
            var bk = (b.kind === 'folder') ? 0 : 1;
            if (ak !== bk) return ak - bk;
            return String(a.name || '').localeCompare(String(b.name || ''));
          });
          win.explorerState.currentFolderId = folder.id || folderId;
          win.explorerState.currentFolderName = folder.name || win.title;
          win.explorerState.parentId = folder.parentId || '';
          win.explorerState.path = folder.path || '';
          win.explorerState.entries = entries;
          win.explorerState.selectedId = '';
          win.explorerState.selectedEntry = null;
          win.explorerState.preview = '';
          win.explorerState.loading = false;
          setStatus(win, entries.length + ' ' + self.t('explorer.status.items', 'items'));
          return entries;
        }).catch(function (err) {
          win.explorerState.loading = false;
          setStatus(win, self.t('explorer.status.error', 'Folder load failed'));
          throw err;
        });
      },
      explorerGoUp: function (windowId) {
        var win = windowById(this, windowId);
        if (!win) return;
        this.ensureExplorerWindow(win);
        if (!win.explorerState.parentId) return;
        this.loadExplorerFolder(windowId, win.explorerState.parentId);
      },
      explorerJump: function (windowId, folderId) {
        if (!folderId) return;
        this.loadExplorerFolder(windowId, folderId);
      },
      explorerSelect: function (windowId, entry) {
        var win = windowById(this, windowId);
        if (!win || !entry) return;
        this.ensureExplorerWindow(win);
        win.explorerState.selectedId = entry.id || '';
        win.explorerState.selectedEntry = entry;
        if (entry.kind === 'folder') {
          win.explorerState.preview = '';
          setStatus(win, this.t('explorer.status.folderSelected', 'Folder selected'));
          return;
        }
        if ((entry.mime || '').indexOf('text/') !== 0) {
          win.explorerState.preview = '';
          setStatus(win, this.t('explorer.status.previewUnavailable', 'Preview not available for this file type'));
          return;
        }
        this.readExplorerFile(windowId, entry.id);
      },
      explorerOpen: function (windowId, entry) {
        if (!entry) return;
        if (entry.kind === 'folder') {
          this.loadExplorerFolder(windowId, entry.id);
          return;
        }
        this.explorerSelect(windowId, entry);
      },
      readExplorerFile: function (windowId, entryId) {
        var self = this;
        var win = windowById(this, windowId);
        if (!win || !entryId) return Promise.resolve('');
        this.ensureExplorerWindow(win);
        setStatus(win, this.t('explorer.status.reading', 'Reading file...'));
        return this.command('fs.read', { id: entryId }).then(function (msg) {
          var vfs = msg.vfs || {};
          var text = vfs.content || '';
          win.explorerState.preview = text;
          setStatus(win, self.t('explorer.status.previewReady', 'Preview ready'));
          return text;
        }).catch(function (err) {
          win.explorerState.preview = '';
          setStatus(win, self.t('explorer.status.previewFailed', 'Preview failed'));
          throw err;
        });
      }
    }
  };
})();
