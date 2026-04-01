(function () {
  function clone(value) {
    return JSON.parse(JSON.stringify(value || {}));
  }

  function nextWindowId(vm, prefix) {
    vm._mioosWindowSeq = (vm._mioosWindowSeq || 0) + 1;
    return (prefix || 'win') + '-' + vm._mioosWindowSeq;
  }

  function detectTextLike(entry) {
    var mime = ((entry || {}).mime || '').toLowerCase();
    var name = ((entry || {}).name || (entry || {}).title || '').toLowerCase();
    return mime.indexOf('text/') === 0 || mime.indexOf('json') >= 0 || /\.(txt|md|m|json|js|css|html|xml|log|csv)$/i.test(name);
  }

  function detectImageLike(entry) {
    var mime = ((entry || {}).mime || '').toLowerCase();
    var name = ((entry || {}).name || (entry || {}).title || '').toLowerCase();
    return mime.indexOf('image/') === 0 || /\.(png|jpg|jpeg|gif|bmp|webp|svg)$/i.test(name);
  }

  function payloadRoot(msg) {
    return (msg && (msg.vfs || msg.fs || msg.result || msg)) || {};
  }

  function extractItems(payload) {
    var raw = clone((payload && (payload.entries || payload.items || payload.children || (payload.folder || {}).entries)) || []);
    var out = [];
    var keys;
    if (Array.isArray(raw)) return raw;
    if (!raw || typeof raw !== 'object') return [];
    keys = Object.keys(raw).sort(function (a, b) {
      var an = +a;
      var bn = +b;
      if (!isNaN(an) && !isNaN(bn)) return an - bn;
      return a < b ? -1 : (a > b ? 1 : 0);
    });
    keys.forEach(function (key) {
      if (raw[key] && typeof raw[key] === 'object') out.push(raw[key]);
    });
    return out;
  }

  function extractFolder(payload, folderId) {
    var folder = clone((payload && (payload.folder || payload.entry || payload.meta)) || {});
    if (!folder.id && folderId) folder.id = folderId;
    if (!folder.name) folder.name = folder.title || 'Folder';
    if (!folder.path) folder.path = folder.name || '/';
    return folder;
  }

  function textFromPayload(payload) {
    return String(payload.text || payload.content || payload.data || '');
  }

  function createUploadInput(onchange) {
    var input = document.createElement('input');
    input.type = 'file';
    input.style.position = 'fixed';
    input.style.left = '-9999px';
    input.style.top = '-9999px';
    input.addEventListener('change', onchange, { once: true });
    document.body.appendChild(input);
    input.click();
  }

  window.MIOOSExplorer = {
    methods: {
      ensureExplorerWindowState: function (win) {
        if (!win) return null;
        if (!win.explorerState) {
          win.explorerState = {
            initialized: false,
            loading: false,
            folderId: (win.meta || {}).folderId || ((this.boot.vfs || {}).homeId || (this.boot.vfs || {}).rootId || 'root'),
            folder: { id: '', name: '', path: '' },
            items: [],
            selection: null,
            error: '',
            preview: { title: '', content: '', mime: 'text/plain', imageSrc: '' }
          };
        }
        return win.explorerState;
      },
      bootstrapExplorerWindow: function (windowId, force) {
        var win = this.windows.find(function (item) { return item.id === windowId; });
        var state;
        if (!win || (win.appKey !== 'my-computer' && win.appKey !== 'documents' && win.appKey !== 'explorer')) return;
        state = this.ensureExplorerWindowState(win);
        if (state.initialized && !force) return;
        state.initialized = true;
        if (win.appKey === 'documents' && (this.boot.vfs || {}).homeId) {
          state.folderId = (win.meta && win.meta.folderId) || this.boot.vfs.homeId;
        }
        this.loadExplorerFolder(win.id, state.folderId, { selectFirst: true });
      },
      loadExplorerFolder: function (windowId, folderId, options) {
        var self = this;
        var win = this.windows.find(function (item) { return item.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        if (!win || !state || !folderId || !this.command) return Promise.resolve();
        state.loading = true;
        state.error = '';
        return this.command('fs.list', { id: folderId, parent: folderId }).then(function (msg) {
          var payload = payloadRoot(msg);
          var folder = extractFolder(payload, folderId);
          var items = extractItems(payload);
          items.sort(function (a, b) {
            var ak = (a.kind || a.type || '').toLowerCase();
            var bk = (b.kind || b.type || '').toLowerCase();
            if (ak !== bk) {
              if (ak === 'folder') return -1;
              if (bk === 'folder') return 1;
            }
            var an = (a.name || a.title || '').toLowerCase();
            var bn = (b.name || b.title || '').toLowerCase();
            return an < bn ? -1 : (an > bn ? 1 : 0);
          });
          state.folderId = folder.id || folderId;
          state.folder = folder;
          state.items = items;
          state.loading = false;
          state.selection = null;
          state.preview = { title: '', content: '', mime: 'text/plain', imageSrc: '' };
          if ((options || {}).selectFirst && items.length) self.selectExplorerItem(win.id, items[0]);
          win.title = folder.name || win.title;
          return msg;
        }).catch(function (err) {
          state.loading = false;
          state.error = (err && err.message) || 'fs_list_failed';
          if (self.showAlert) self.showAlert(self.t('alerts.shellEventError.title', 'Explorer'), state.error);
        });
      },
      selectExplorerItem: function (windowId, item) {
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        if (!state) return;
        state.selection = clone(item || null);
        if (state.selection && detectTextLike(state.selection)) {
          this.previewTextFile(windowId, state.selection);
        } else if (state.selection && detectImageLike(state.selection)) {
          this.previewImageFile(windowId, state.selection);
        } else {
          state.preview = { title: '', content: '', mime: 'text/plain', imageSrc: '' };
        }
      },
      previewTextFile: function (windowId, item) {
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        if (!win || !state || !item || !this.command) return Promise.resolve();
        state.preview = { title: item.name || item.title || '', content: '', mime: item.mime || 'text/plain', imageSrc: '' };
        return this.command('fs.read', { id: item.id || item.key || item.fileId }).then(function (msg) {
          var payload = payloadRoot(msg);
          state.preview = {
            title: item.name || item.title || '',
            content: textFromPayload(payload),
            mime: item.mime || payload.mime || 'text/plain',
            imageSrc: ''
          };
          return msg;
        }).catch(function (err) {
          state.preview = {
            title: item.name || item.title || '',
            content: (err && err.message) || 'Unable to load preview.',
            mime: item.mime || 'text/plain',
            imageSrc: ''
          };
        });
      },
      previewImageFile: function (windowId, item) {
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        if (!win || !state || !item || !this.command) return Promise.resolve();
        state.preview = { title: item.name || item.title || '', content: '', mime: item.mime || 'image/*', imageSrc: '' };
        return this.command('fs.read', { id: item.id || item.key || item.fileId }).then(function (msg) {
          var payload = payloadRoot(msg);
          state.preview = {
            title: item.name || item.title || '',
            content: '',
            mime: item.mime || payload.mime || 'image/*',
            imageSrc: textFromPayload(payload)
          };
          return msg;
        }).catch(function (err) {
          state.preview = {
            title: item.name || item.title || '',
            content: (err && err.message) || 'Unable to load image preview.',
            mime: item.mime || 'image/*',
            imageSrc: ''
          };
        });
      },
      explorerOpenSelected: function (windowId) {
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        var item = state && state.selection;
        if (!item) return;
        this.explorerOpenItem(windowId, item);
      },
      explorerOpenItem: function (windowId, item) {
        var kind = ((item || {}).kind || (item || {}).type || '').toLowerCase();
        if (kind === 'folder') {
          this.loadExplorerFolder(windowId, item.id || item.key || item.folderId, { selectFirst: true });
          return;
        }
        if (detectImageLike(item)) {
          this.openImageViewerWindow(item);
          return;
        }
        if (detectTextLike(item)) {
          this.openTextViewerWindow(item);
        }
      },
      explorerGoUp: function (windowId) {
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        var parentId = (((state || {}).folder || {}).parentId) || (((win || {}).meta || {}).parentId);
        if (!parentId && (this.boot.vfs || {}).rootId && state && state.folderId !== this.boot.vfs.rootId) parentId = this.boot.vfs.rootId;
        if (!parentId) return;
        this.loadExplorerFolder(windowId, parentId, { selectFirst: true });
      },
      refreshExplorerWindow: function (windowId) {
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        if (!state) return Promise.resolve();
        return this.loadExplorerFolder(windowId, state.folderId, { selectFirst: false });
      },
      explorerPromptUpload: function (windowId) {
        var self = this;
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        if (!state || !this.command) return;
        createUploadInput(function (event) {
          var file = event.target.files && event.target.files[0];
          var reader;
          var mime;
          if (!file) {
            if (event.target && event.target.parentNode) event.target.parentNode.removeChild(event.target);
            return;
          }
          reader = new FileReader();
          mime = file.type || 'application/octet-stream';
          reader.onload = function (loadEvent) {
            var result = loadEvent.target && loadEvent.target.result;
            self.command('fs.write', {
              parent: state.folderId,
              name: file.name,
              mime: mime,
              data: result,
              content: result,
              text: result
            }).then(function () {
              return self.refreshExplorerWindow(windowId).then(function () {
                if (self.refreshView) self.refreshView();
              });
            }).catch(function (err) {
              if (self.showAlert) self.showAlert(self.t('alerts.shellEventError.title', 'Explorer'), (err && err.message) || 'fs_write_failed');
            }).finally(function () {
              if (event.target && event.target.parentNode) event.target.parentNode.removeChild(event.target);
            });
          };
          if (detectTextLike({ name: file.name, mime: mime })) {
            reader.readAsText(file);
          } else {
            reader.readAsDataURL(file);
          }
        });
      },
      explorerCreateFolder: function (windowId) {
        var self = this;
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        var name;
        if (!state || !this.command) return Promise.resolve();
        name = window.prompt(this.t('explorer.promptNewFolder', 'New folder name'), this.t('explorer.defaultFolderName', 'New Folder'));
        if (name === null) return Promise.resolve();
        name = String(name || '').trim();
        if (!name) return Promise.resolve();
        return this.command('fs.mkdir', { parent: state.folderId, name: name }).then(function () {
          return self.refreshExplorerWindow(windowId).then(function () {
            if (self.refreshView) self.refreshView();
          });
        }).catch(function (err) {
          if (self.showAlert) self.showAlert(self.t('alerts.shellEventError.title', 'Explorer'), (err && err.message) || 'fs_mkdir_failed');
        });
      },
      explorerRenameSelected: function (windowId) {
        var self = this;
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        var item = state && state.selection;
        var name;
        if (!item || !this.command) return Promise.resolve();
        name = window.prompt(this.t('explorer.promptRename', 'Rename item'), item.name || item.title || '');
        if (name === null) return Promise.resolve();
        name = String(name || '').trim();
        if (!name || name === (item.name || item.title || '')) return Promise.resolve();
        return this.command('fs.rename', { id: item.id || item.key || '', name: name }).then(function () {
          return self.refreshExplorerWindow(windowId).then(function () {
            if (self.refreshView) self.refreshView();
          });
        }).catch(function (err) {
          if (self.showAlert) self.showAlert(self.t('alerts.shellEventError.title', 'Explorer'), (err && err.message) || 'fs_rename_failed');
        });
      },
      explorerDeleteSelected: function (windowId) {
        var self = this;
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        var item = state && state.selection;
        if (!item || !this.command) return Promise.resolve();
        if (!window.confirm(this.t('explorer.confirmDelete', 'Delete the selected item?'))) return Promise.resolve();
        return this.command('fs.delete', { id: item.id || item.key || '' }).then(function () {
          state.selection = null;
          state.preview = { title: '', content: '', mime: 'text/plain', imageSrc: '' };
          return self.refreshExplorerWindow(windowId).then(function () {
            if (self.refreshView) self.refreshView();
          });
        }).catch(function (err) {
          if (self.showAlert) self.showAlert(self.t('alerts.shellEventError.title', 'Explorer'), (err && err.message) || 'fs_delete_failed');
        });
      },
      explorerMoveSelected: function (windowId) {
        var self = this;
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        var item = state && state.selection;
        var destination = '';
        if (!item || !this.command) return Promise.resolve();
        destination = window.prompt(this.t('explorer.promptMove', 'Move selected item to folder path or id'), ((this.boot.vfs || {}).homeId || (this.boot.vfs || {}).rootId || 'root'));
        if (destination === null) return Promise.resolve();
        destination = String(destination || '').trim();
        if (!destination) return Promise.resolve();
        return this.command('fs.meta', { id: destination, path: destination }).then(function (msg) {
          var payload = payloadRoot(msg);
          var targetId = payload.id || destination;
          return self.command('fs.move', { id: item.id || item.key || '', parent: targetId });
        }).then(function () {
          state.selection = null;
          state.preview = { title: '', content: '', mime: 'text/plain', imageSrc: '' };
          return self.refreshExplorerWindow(windowId).then(function () {
            if (self.refreshView) self.refreshView();
          });
        }).catch(function (err) {
          if (self.showAlert) self.showAlert(self.t('alerts.shellEventError.title', 'Explorer'), (err && err.message) || 'fs_move_failed');
        });
      },
      openTextViewerWindow: function (item) {
        var id = nextWindowId(this, 'win-text');
        var win = {
          id: id,
          appKey: 'text-viewer',
          title: item.name || item.title || 'Text file',
          state: 'normal',
          left: 130,
          top: 90,
          width: 660,
          height: 480,
          z: this.zCounter + 1,
          meta: { fileId: item.id || item.key || '', mime: item.mime || 'text/plain', fileName: item.name || item.title || 'Text file' },
          fileView: { loading: true, content: '', mime: item.mime || 'text/plain' }
        };
        this.windows.push(win);
        this.focusWindow(id);
        if (!this.command) return;
        this.command('fs.read', { id: item.id || item.key || item.fileId }).then(function (msg) {
          var payload = payloadRoot(msg);
          win.fileView.loading = false;
          win.fileView.content = textFromPayload(payload);
          win.fileView.mime = payload.mime || win.fileView.mime;
        }).catch(function (err) {
          win.fileView.loading = false;
          win.fileView.content = (err && err.message) || 'Unable to open file.';
        });
      },
      openImageViewerWindow: function (item) {
        var id = nextWindowId(this, 'win-image');
        var win = {
          id: id,
          appKey: 'image-viewer',
          title: item.name || item.title || 'Image file',
          state: 'normal',
          left: 150,
          top: 110,
          width: 700,
          height: 520,
          z: this.zCounter + 1,
          meta: { fileId: item.id || item.key || '', mime: item.mime || 'image/*', fileName: item.name || item.title || 'Image file' },
          fileView: { loading: true, content: '', mime: item.mime || 'image/*' }
        };
        this.windows.push(win);
        this.focusWindow(id);
        if (!this.command) return;
        this.command('fs.read', { id: item.id || item.key || item.fileId }).then(function (msg) {
          var payload = payloadRoot(msg);
          win.fileView.loading = false;
          win.fileView.content = textFromPayload(payload);
          win.fileView.mime = payload.mime || win.fileView.mime;
        }).catch(function (err) {
          win.fileView.loading = false;
          win.fileView.content = '';
          win.fileView.error = (err && err.message) || 'Unable to open image.';
        });
      }
    }
  };
})();
