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



  function uploadViaTransfer(vm, windowId, state, file, mime, textMode) {
    var helpers = (window.MIOOSTransfer && window.MIOOSTransfer.helpers) || {};
    var createSocket = helpers.createSocket;
    var waitOpen = helpers.waitOpen;
    var request = helpers.request;
    var bootTransfer = (((vm || {}).boot || {}).transfer || {});
    var fallbackChunk = Math.max(1024, Math.min(16384, +(bootTransfer.chunkSize || 16384)));
    if (!createSocket || !waitOpen || !request) return Promise.reject(new Error('transfer_helpers_missing'));
    return new Promise(function (resolve, reject) {
      var coordinator = createSocket(vm);
      var sockets = [];
      var transferId = '';
      var chunkSize = fallbackChunk;
      var chunkTotal = 0;
      var workerCount = 1;
      var nextIndex = 1;
      var completed = 0;
      var failed = false;
      var committed = false;
      function updateProgress() {
        var progress = chunkTotal > 0 ? Math.min(100, Math.round((completed / chunkTotal) * 100)) : 0;
        state.upload = {
          active: true,
          name: file.name,
          stage: committed ? 'Complete' : 'Uploading',
          progress: progress
        };
        if (vm && vm.transferBeginOrUpdate) {
          vm.transferBeginOrUpdate({ id: transferId || ('upload-' + file.name), direction: 'upload', name: file.name, stage: committed ? 'Complete' : 'Uploading', progress: progress, active: !committed, complete: !!committed, failed: false, sizeBytes: file.size || 0, workerCount: workerCount || 1, bytesDone: completed * chunkSize });
        }
      }
      function cleanup() {
        sockets.forEach(function (socket) {
          try { socket.close(); } catch (err) {}
        });
        sockets = [];
        try { coordinator.close(); } catch (err) {}
      }
      function fail(err) {
        if (failed) return;
        failed = true;
        state.upload = {
          active: false,
          name: file.name,
          stage: 'Failed',
          progress: chunkTotal > 0 ? Math.min(100, Math.round((completed / chunkTotal) * 100)) : 0,
          error: (err && err.message) || 'transfer_upload_failed'
        };
        if (vm && vm.transferBeginOrUpdate) vm.transferBeginOrUpdate({ id: transferId || ('upload-' + file.name), direction: 'upload', name: file.name, stage: 'Failed', progress: chunkTotal > 0 ? Math.min(100, Math.round((completed / chunkTotal) * 100)) : 0, active: false, failed: true, complete: false, sizeBytes: file.size || 0, workerCount: workerCount || 1 });
        if (transferId) {
          request(coordinator, 'transfer.upload.abort', { transferId: transferId }, 10000).catch(function () {});
        }
        cleanup();
        reject(err || new Error('transfer_upload_failed'));
      }
      function commit() {
        if (failed || committed) return;
        committed = true;
        request(coordinator, 'transfer.upload.commit', { transferId: transferId }, 30000).then(function (msg) {
          state.upload = { active: false, name: file.name, stage: 'Complete', progress: 100 };
          if (vm && vm.transferBeginOrUpdate) vm.transferBeginOrUpdate({ id: transferId || ('upload-' + file.name), direction: 'upload', name: file.name, stage: 'Complete', progress: 100, active: false, complete: true, failed: false, sizeBytes: file.size || 0, workerCount: workerCount || 1, bytesDone: file.size || 0 });
          window.setTimeout(function () { if (state.upload && state.upload.progress === 100) state.upload = null; }, 800);
          cleanup();
          resolve(msg);
        }).catch(fail);
      }
      function nextChunk() {
        if (failed) return 0;
        if (nextIndex > chunkTotal) return 0;
        return nextIndex++;
      }
      function readChunk(blob) {
        return new Promise(function (res, rej) {
          var reader = new FileReader();
          reader.onload = function (ev) {
            var raw = ev.target && ev.target.result;
            res(textMode ? String(raw || '') : String(raw || '').split(',').pop());
          };
          reader.onerror = function () { rej(new Error('file_read_failed')); };
          if (textMode) reader.readAsText(blob); else reader.readAsDataURL(blob);
        });
      }
      function workerLoop(socket, workerId) {
        var idx = nextChunk();
        var start, end, blob;
        if (!idx) {
          if (completed >= chunkTotal) commit();
          return Promise.resolve();
        }
        start = (idx - 1) * chunkSize;
        end = Math.min(file.size || 0, start + chunkSize);
        blob = file.slice(start, end);
        return readChunk(blob).then(function (data) {
          return request(socket, 'transfer.upload.chunk', {
            transferId: transferId,
            chunkIndex: idx,
            workerId: workerId,
            data: data
          }, 30000);
        }).then(function () {
          completed += 1;
          updateProgress();
          return workerLoop(socket, workerId);
        });
      }
      function startWorkers() {
        var opens = [];
        var i;
        for (i = 1; i <= workerCount; i += 1) {
          (function (workerNo) {
            var socket = createSocket(vm);
            sockets.push(socket);
            opens.push(waitOpen(socket, 10000).then(function () {
              return workerLoop(socket, 'w' + workerNo);
            }));
          })(i);
        }
        Promise.all(opens).then(function () {
          if (completed >= chunkTotal) commit();
        }).catch(fail);
      }
      state.upload = { active: true, name: file.name, stage: 'Starting', progress: 0 };
      waitOpen(coordinator, 10000).then(function () {
        return request(coordinator, 'transfer.upload.begin', {
          parent: state.folderId,
          name: file.name,
          mime: mime,
          sizeBytes: file.size || 0,
          chunkTotal: Math.max(1, Math.ceil((file.size || 0) / fallbackChunk))
        }, 15000);
      }).then(function (beginMsg) {
        var root = beginMsg.transfer || beginMsg.result || {};
        transferId = root.transferId || '';
        chunkSize = Math.max(1024, Math.min(32768, +(root.chunkSize || fallbackChunk)));
        chunkTotal = Math.max(1, Math.ceil((file.size || 0) / chunkSize));
        workerCount = Math.max(1, Math.min(7, +(root.workerCount || bootTransfer.uploadWorkers || 2)));
        updateProgress();
        startWorkers();
      }).catch(fail);
    });
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
            preview: { title: '', content: '', mime: 'text/plain', imageSrc: '' },
            download: null
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
          var mime;
          var textMode;
          var smallText;
          function finish() {
            if (event.target && event.target.parentNode) event.target.parentNode.removeChild(event.target);
          }
          if (!file) {
            finish();
            return;
          }
          mime = file.type || 'application/octet-stream';
          textMode = detectTextLike({ name: file.name, mime: mime });
          smallText = textMode && (file.size || 0) <= 24576;
          if (smallText) {
            var reader = new FileReader();
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
              }).finally(finish);
            };
            reader.onerror = function () {
              if (self.showAlert) self.showAlert(self.t('alerts.shellEventError.title', 'Explorer'), 'file_read_failed');
              finish();
            };
            reader.readAsText(file);
            return;
          }
          uploadViaTransfer(self, windowId, state, file, mime, textMode).then(function () {
            return self.refreshExplorerWindow(windowId).then(function () {
              if (self.refreshView) self.refreshView();
            });
          }).catch(function (err) {
            if (self.showAlert) self.showAlert(self.t('alerts.shellEventError.title', 'Explorer'), (err && err.message) || 'transfer_upload_failed');
          }).finally(finish);
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
      explorerDownloadSelected: function (windowId) {
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        var item = state && state.selection;
        if (!item || !this.transferDownloadFile) return Promise.resolve();
        return this.transferDownloadFile({
          id: item.id || item.key || '',
          path: item.path || '',
          name: item.name || item.title || 'download',
          mime: item.mime || 'application/octet-stream'
        }, state);
      },
      downloadViewerFile: function (win) {
        var fileId = ((win || {}).meta || {}).fileId || '';
        var name = ((win || {}).meta || {}).fileName || (win && win.title) || 'download';
        if (!fileId || !this.transferDownloadFile) return Promise.resolve();
        return this.transferDownloadFile({ id: fileId, name: name, mime: (((win || {}).fileView || {}).mime || ((win || {}).meta || {}).mime || 'application/octet-stream') }, null);
      },
      explorerOpenSelected: function (windowId) {
        var win = this.windows.find(function (entry) { return entry.id === windowId; });
        var state = this.ensureExplorerWindowState(win);
        var item = state && state.selection;
        if (!item) return Promise.resolve();
        return this.explorerOpenItem(windowId, item);
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
