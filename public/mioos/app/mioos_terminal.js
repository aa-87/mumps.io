(function () {
  function clone(obj) {
    return JSON.parse(JSON.stringify(obj || {}));
  }
  function defaultTerminalState() {
    return {
      terminalId: '',
      inputLine: '',
      transcript: '',
      history: [],
      historyIndex: -1,
      prompt: 'YDB>',
      cwd: '/',
      transport: 'pipe',
      seq: 0,
      busy: false,
      pollInFlight: false,
      lastActivityAt: 0,
      lastOutputAt: 0,
      lastPollAt: 0,
      status: 'Terminal idle',
      loadError: '',
      profile: {}
    };
  }
  window.MIOOSTerminal = {
    methods: {
      terminalContainerId: function (windowId) { return 'mioosTerminalViewport-' + windowId; },
      getWindowById: function (windowId) {
        return this.windows.find(function (item) { return item.id === windowId; }) || null;
      },
      ensureTerminalState: function (windowId) {
        var win = this.getWindowById(windowId);
        if (!win) return defaultTerminalState();
        if (!win.terminalState) win.terminalState = defaultTerminalState();
        return win.terminalState;
      },
      terminalCtor: function () {
        return window.Terminal || (window.Xterm || {}).Terminal || (window.XTerm || {}).Terminal || null;
      },
      terminalWindowDefaults: function () {
        return defaultTerminalState();
      },
      createTerminalWindow: function () {
        var count = this.windows.filter(function (w) { return w.appKey === 'terminal'; }).length + 1;
        var win = {
          id: 'win-terminal-' + Date.now() + '-' + count,
          appKey: 'terminal',
          title: this.t('app.terminal.title', 'Terminal') + ' ' + count,
          left: 112 + (count * 24),
          top: 76 + (count * 20),
          width: 860,
          height: 470,
          z: ++this.zCounter,
          state: 'normal',
          terminalState: defaultTerminalState(),
          _term: null,
          _appliedProfileKey: ''
        };
        this.windows.push(win);
        this.activeWindowId = win.id;
        var self = this;
        this.$nextTick(function () {
          self.ensureXtermMounted(win.id);
          self.openTerminal(win.id, true);
        });
      },
      resolveTerminalViewport: function (winId) {
        return document.getElementById('mioosTerminalViewport-' + winId);
      },
      resolveTerminalHost: function (winId) {
        return document.getElementById('mioosTerminalHost-' + winId) || this.resolveTerminalViewport(winId);
      },
      terminalSizingMode: function () { return 'fit-container'; },
      computeTerminalGrid: function (winId) {
        var viewport = this.resolveTerminalViewport(winId),
            fontSize = Number((((this.ensureTerminalState(winId) || {}).profile || {}).fontSize) || ((((this.boot || {}).terminal || {}).profile || {}).fontSize) || 14) || 14,
            cols = Number((((this.ensureTerminalState(winId) || {}).profile || {}).cols) || 120) || 120,
            rows = Number((((this.ensureTerminalState(winId) || {}).profile || {}).rows) || 28) || 28;
        if (viewport) {
          cols = Math.max(80, Math.min(220, Math.floor((viewport.clientWidth - 26) / Math.max(8, fontSize * 0.62))));
          rows = Math.max(20, Math.min(60, Math.floor((viewport.clientHeight - 22) / Math.max(16, fontSize * 1.68))));
        }
        return { cols: cols, rows: rows };
      },
      buildXtermOptions: function (winId) {
        var state = this.ensureTerminalState(winId), p = state.profile || (((this.boot || {}).terminal || {}).profile || {}), grid = this.computeTerminalGrid(winId);
        return {
          fontFamily: String(p.fontFamily || 'Consolas'),
          fontSize: parseInt(p.fontSize || 14, 10) || 14,
          cursorBlink: p.cursorBlink !== false,
          cursorStyle: String(p.cursorStyle || 'block'),
          scrollback: parseInt(p.scrollback || 3000, 10) || 3000,
          cols: grid.cols,
          rows: grid.rows,
          convertEol: true,
          allowTransparency: true,
          theme: { background: '#0b1220', foreground: '#dce9ff', cursor: '#dce9ff', cursorAccent: '#0b1220', selectionBackground: 'rgba(143,179,255,0.30)' }
        };
      },
      ensureXtermMounted: function (winId) {
        var ctor = this.terminalCtor(), host = this.resolveTerminalHost(winId), state = this.ensureTerminalState(winId), self = this, win = this.getWindowById(winId);
        if (!host || !win) return;
        if (!ctor) {
          state.loadError = 'xterm.js failed to load for this page.';
          return;
        }
        if (!host.clientWidth || !host.clientHeight) {
          var self2 = this;
          window.setTimeout(function () { self2.ensureXtermMounted(winId); }, 60);
          return;
        }
        state.loadError = '';
        if (!win._term) {
          win._term = new ctor(this.buildXtermOptions(winId));
          win._term.open(host);
          host.setAttribute('data-xterm-mounted', '1');
          if (win._term.onData) win._term.onData(function (data) { self.onXtermData(winId, String(data || '')); });
          this.renderXtermTranscript(winId);
        }
        this.applyXtermProfile(winId);
      },
      applyXtermProfile: function (winId) {
        var win = this.getWindowById(winId), xterm = win && win._term, p = (this.ensureTerminalState(winId).profile || {}), key;
        if (!xterm || !win) return;
        key = [p.fontFamily || '', p.fontSize || '', p.cursorBlink !== false ? 1 : 0, p.cursorStyle || '', p.scrollback || ''].join('|');
        if (win._appliedProfileKey === key) return;
        win._appliedProfileKey = key;
        xterm.options.fontFamily = p.fontFamily || 'Consolas';
        xterm.options.fontSize = parseInt(p.fontSize || 14, 10) || 14;
        xterm.options.cursorBlink = p.cursorBlink !== false;
        xterm.options.cursorStyle = p.cursorStyle || 'block';
        xterm.options.scrollback = parseInt(p.scrollback || 3000, 10) || 3000;
        var grid = this.computeTerminalGrid(winId);
        this.resizeXtermClient(winId, grid.cols, grid.rows);
      },
      resizeXtermClient: function (winId, cols, rows) {
        var win = this.getWindowById(winId), xterm = win && win._term;
        if (!xterm || !xterm.resize) return;
        try { xterm.resize(Math.max(80, cols || 80), Math.max(20, rows || 20)); if (xterm.scrollToBottom) xterm.scrollToBottom(); } catch (e) {}
      },
      normalizeTerminalChunk: function (chunk) { return String(chunk || '').replace(/\r\n/g, '\n').replace(/\r/g, '\n'); },
      appendTerminalChunk: function (winId, chunk) {
        var state = this.ensureTerminalState(winId), win = this.getWindowById(winId), xterm = win && win._term, normalized = this.normalizeTerminalChunk(chunk);
        if (!normalized) return;
        var limit = parseInt((state.profile || {}).scrollback || 3000, 10) || 3000;
        var lines = (String(state.transcript || '') + normalized).split('\n');
        if (lines.length > limit) lines = lines.slice(lines.length - limit);
        state.transcript = lines.join('\n');
        if (xterm && xterm.write) { xterm.write(normalized); if (xterm.scrollToBottom) xterm.scrollToBottom(); }
      },
      renderXtermTranscript: function (winId) {
        var win = this.getWindowById(winId), state = this.ensureTerminalState(winId);
        if (!win || !win._term) return;
        try { win._term.reset(); } catch (e) {}
        if (state.transcript) win._term.write(state.transcript);
        if (state.inputLine) win._term.write(state.inputLine);
      },
      rewriteTerminalInput: function (winId, nextLine) {
        var win = this.getWindowById(winId), state = this.ensureTerminalState(winId), next = String(nextLine || '');
        if (!win || !win._term) { state.inputLine = next; return; }
        while (state.inputLine.length) { win._term.write('\b \b'); state.inputLine = state.inputLine.slice(0, -1); }
        if (next) { state.inputLine = next; win._term.write(next); }
      },
      recallTerminalHistory: function (winId, step) {
        var state = this.ensureTerminalState(winId);
        if (!state.history.length) return;
        if (step < 0) {
          if (state.historyIndex < 0) state.historyIndex = state.history.length - 1; else if (state.historyIndex > 0) state.historyIndex -= 1;
        } else {
          if (state.historyIndex < 0) return;
          if (state.historyIndex >= state.history.length - 1) { state.historyIndex = -1; this.rewriteTerminalInput(winId, ''); return; }
          state.historyIndex += 1;
        }
        this.rewriteTerminalInput(winId, state.history[state.historyIndex] || '');
      },
      onXtermData: function (winId, data) {
        var i = 0, chunk = '', win = this.getWindowById(winId), state = this.ensureTerminalState(winId);
        if (!win || !data) return;
        while (i < data.length) {
          if (data.slice(i, i + 3) === '\x1b[A') { this.recallTerminalHistory(winId, -1); i += 3; continue; }
          if (data.slice(i, i + 3) === '\x1b[B') { this.recallTerminalHistory(winId, 1); i += 3; continue; }
          chunk = data.charAt(i);
          if (chunk === '\r') { if (win._term) win._term.write('\r\n'); this.submitTerminalLine(winId, state.inputLine); i += 1; continue; }
          if (chunk === '\u007f') { if (state.inputLine.length) { state.inputLine = state.inputLine.slice(0, -1); if (win._term) win._term.write('\b \b'); } i += 1; continue; }
          if (chunk === '\u0003') { state.inputLine = ''; if (win._term) win._term.write('^C\r\n'); state.transcript = (state.transcript || '') + '^C\n'; i += 1; continue; }
          if (chunk === '\u000c') { this.clearTerminalWindow(winId); i += 1; continue; }
          if (chunk < ' ') { i += 1; continue; }
          state.inputLine += chunk; if (win._term) win._term.write(chunk); i += 1;
        }
      },
      markTerminalActive: function (winId) {
        var state = this.ensureTerminalState(winId), now = Date.now();
        state.lastActivityAt = now;
        if (!state.lastOutputAt) state.lastOutputAt = now;
      },
      terminalPollDelay: function (winId) {
        var state = this.ensureTerminalState(winId), now = Date.now(), ref = Math.max(state.lastActivityAt || 0, state.lastOutputAt || 0), age = ref ? (now - ref) : 999999;
        if (state.busy || state.pollInFlight) return 35;
        if (age < 1200) return 25;
        if (age < 5000) return 75;
        return 180;
      },
      startTerminalPolling: function () {
        var self = this;
        if (this.terminalPollTimer) return;
        function tick() {
          var nextDelay = 180;
          self.windows.forEach(function (win) {
            var state, delay;
            if (!win || win.appKey !== 'terminal' || win.state === 'closed' || win.state === 'minimized') return;
            state = self.ensureTerminalState(win.id);
            delay = self.terminalPollDelay(win.id);
            if (delay < nextDelay) nextDelay = delay;
            if (!state.terminalId || state.busy || state.pollInFlight) return;
            if ((Date.now() - (state.lastPollAt || 0)) < delay) return;
            self.pollTerminal(win.id);
          });
          self.terminalPollTimer = window.setTimeout(tick, nextDelay);
        }
        this.terminalPollTimer = window.setTimeout(tick, 25);
      },
      stopTerminalPolling: function () { if (this.terminalPollTimer) window.clearTimeout(this.terminalPollTimer); this.terminalPollTimer = null; },
      openTerminal: function (winId, forceNew) {
        var self = this, state = this.ensureTerminalState(winId), grid = this.computeTerminalGrid(winId), payload = { terminalId: forceNew ? '__new__' : (state.terminalId || ''), cols: grid.cols, rows: grid.rows };
        this.ensureXtermMounted(winId);
        state.busy = true; state.status = 'Opening terminal...';
        this.markTerminalActive(winId);
        return this.command('terminal.open', payload).then(function (json) {
          self.handleTerminalMessage(winId, (json && json.terminal) || {});
          state.status = 'Terminal ready';
          self.markTerminalActive(winId);
          self.startTerminalPolling();
          self.resizeTerminal(winId);
          self.focusTerminalWindow(winId);
          return json;
        }).catch(function (err) {
          state.status = 'Terminal unavailable';
          self.showAlert(self.t('alerts.terminalOpenFailed.title', 'Terminal open failed'), (err && (err.detail || err.error || err.message)) || self.t('alerts.terminalOpenFailed.message', 'The terminal could not be opened.'));
          throw err;
        }).finally(function () { state.busy = false; });
      },
      requestTerminalOpen: function (winId, forceNew) { return this.openTerminal(winId, forceNew === true); },
      pollTerminal: function (winId) {
        var self = this, state = this.ensureTerminalState(winId);
        if (!state.terminalId || state.pollInFlight) return;
        state.pollInFlight = true;
        state.lastPollAt = Date.now();
        this.command('terminal.poll', { terminalId: state.terminalId || '' }).then(function (json) {
          self.handleTerminalMessage(winId, (json && json.terminal) || {});
        }).catch(function () {}).finally(function () {
          state.pollInFlight = false;
        });
      },
      submitTerminalLine: function (winId, lineOverride) {
        var self = this, state = this.ensureTerminalState(winId), line = lineOverride != null ? String(lineOverride) : String(state.inputLine || '');
        if (!state.terminalId) {
          this.openTerminal(winId, true).then(function () { self.submitTerminalLine(winId, line); }).catch(function () {});
          return;
        }
        state.busy = true;
        this.markTerminalActive(winId);
        if (line.trim()) { state.history.push(line); if (state.history.length > 100) state.history = state.history.slice(-100); }
        state.historyIndex = -1; state.inputLine = '';
        this.command('terminal.input', { terminalId: state.terminalId || '', line: line }).then(function (json) {
          self.handleTerminalMessage(winId, (json && json.terminal) || {});
          state.status = 'Terminal live';
          self.markTerminalActive(winId);
        }).catch(function (err) {
          state.status = 'Terminal input failed';
          self.showAlert(self.t('alerts.terminalCommandFailed.title', 'Terminal command failed'), (err && (err.detail || err.error || err.message)) || self.t('alerts.terminalCommandFailed.message', 'The terminal command did not complete.'));
        }).finally(function () { state.busy = false; });
      },
      resizeTerminal: function (winId) {
        var self = this, state = this.ensureTerminalState(winId), grid = this.computeTerminalGrid(winId);
        this.ensureXtermMounted(winId); this.resizeXtermClient(winId, grid.cols, grid.rows);
        this.markTerminalActive(winId);
        if (!state.terminalId) return;
        this.command('terminal.resize', { terminalId: state.terminalId || '', cols: grid.cols, rows: grid.rows }).then(function (json) {
          self.handleTerminalMessage(winId, (json && json.terminal) || {});
        }).catch(function () {});
      },
      syncTerminalWindow: function (winId) { this.resizeTerminal(winId); },
      focusTerminalWindow: function (winId) { var win = this.getWindowById(winId); this.ensureXtermMounted(winId); if (win && win._term && win._term.focus) win._term.focus(); },
      clearTerminalWindow: function (winId) {
        var state = this.ensureTerminalState(winId), win = this.getWindowById(winId);
        state.transcript = ''; state.inputLine = '';
        if (win && win._term) { if (win._term.clear) win._term.clear(); else if (win._term.reset) win._term.reset(); }
        this.focusTerminalWindow(winId);
      },
      closeTerminalWindow: function (winId) {
        var self = this, state = this.ensureTerminalState(winId), win = this.getWindowById(winId), termId = state.terminalId || '';
        function finalize() {
          state.status = 'Terminal closed'; state.terminalId = ''; state.cwd = '/'; state.inputLine = ''; state.busy = false;
          if (win && win._term) { try { win._term.dispose(); } catch (e) {} win._term = null; }
          if (win) win.state = 'closed';
          if (self.activeWindowId === winId) self.activeWindowId = '';
        }
        if (!termId) { finalize(); return; }
        this.command('terminal.close', { terminalId: termId }).then(function (json) {
          self.handleTerminalMessage(winId, (json && json.terminal) || { closed: 1 });
        }).catch(function () {}).finally(function () { finalize(); });
      },
      handleTerminalMessage: function (winId, msg) {
        var state = this.ensureTerminalState(winId), win = this.getWindowById(winId), writes = [], writeCount = 0;
        if (!win) return;
        if (msg.terminalId) state.terminalId = msg.terminalId;
        if (msg.prompt) state.prompt = msg.prompt;
        if (msg.cwd) state.cwd = msg.cwd;
        if (msg.transport) state.transport = msg.transport;
        if (msg.seq != null) state.seq = Number(msg.seq || 0);
        if (msg.clear) { state.transcript = ''; if (win._term && win._term.reset) win._term.reset(); }
        if (Array.isArray(msg.write)) writes = msg.write; else if (msg.write) Object.keys(msg.write).sort(function (a, b) { return Number(a) - Number(b); }).forEach(function (k) { writes.push(msg.write[k]); });
        writeCount = Number(msg.writeCount || writes.length || 0);
        if (msg.profile) state.profile = clone(msg.profile);
        this.ensureXtermMounted(winId);
        if (msg.profile) this.applyXtermProfile(winId);
        writes.forEach(function (chunk) { this.appendTerminalChunk(winId, chunk || ''); }, this);
        if (writeCount > 0) {
          state.lastOutputAt = Date.now();
          state.lastActivityAt = state.lastOutputAt;
        }
        if (msg.closed) state.status = 'Terminal closed'; else if (state.terminalId) state.status = 'Terminal live';
      },
      handleTerminalCommandResult: function (msg) {
        var data = msg.terminal || {}, win = this.getWindowById(data.windowId || '');
        if (!win && data.terminalId) {
          win = this.windows.find(function (item) { return (((item || {}).terminalState || {}).terminalId || '') === data.terminalId; });
        }
        if (!win) return;
        this.handleTerminalMessage(win.id, data);
      },
      handleTerminalCommandError: function (msg) {
        if (!msg || !msg.command || msg.command.indexOf('terminal.') !== 0) return false;
        this.showAlert(this.t('alerts.terminalCommandFailed.title', 'Terminal command failed'), msg.detail || msg.error || this.t('alerts.terminalCommandFailed.message', 'The terminal command did not complete.'));
        return true;
      }
    }
  };
})();
