(function () {
  if (!window.Vue || !window.Vue.createApp) return;
  var root = document.getElementById("miomosRoot");
  var bootNode = document.getElementById("miomosBootJson");
  if (!root || !bootNode) return;
  if (root.__miomosVueMounted) return;
  root.__miomosVueMounted = true;
  function clone(obj) {
    return JSON.parse(JSON.stringify(obj || {}));
  }
  function arr(val) {
    if (Array.isArray(val)) return val;
    if (!val || typeof val !== "object") return [];
    return Object.keys(val)
      .sort(function (a, b) {
        return Number(a) - Number(b);
      })
      .map(function (k) {
        return val[k];
      });
  }
  function parseBoot() {
    try {
      return JSON.parse(bootNode.textContent || "{}");
    } catch (e) {
      return {};
    }
  }
  var app = window.Vue.createApp({
    data: function () {
      var boot = parseBoot(),
        view = boot.view || {};
      return {
        boot: boot,
        profile:
          root.getAttribute("data-miomos-profile") ||
          (boot.product || {}).profile ||
          "dev",
        currentClock: "",
        viewportWidth: window.innerWidth || 1400,
        bootLoading: false,
        menuOpen: !!((boot.desktop || {}).uiState || {}).menuOpen,
        activeStartSection:
          ((boot.desktop || {}).uiState || {}).startMenuSection || "Pinned",
        startSearch: ((boot.desktop || {}).uiState || {}).startMenuQuery || "",
        recentLaunchKeys: [],
        activeWindowId:
          ((boot.desktop || {}).uiState || {}).activeWindowId || "",
        zCounter: 20,
        socket: null,
        socketConnected: false,
        socketConnecting: false,
        shouldReconnect: true,
        reconnectDelay: 1000,
        reconnectTimer: null,
        heartbeatTimer: null,
        staleSocketTimer: null,
        lastSocketAt: 0,
        reconnectCount: 0,
        lastReconnectAt: "",
        inflightCommandCount: 0,
        pendingCommands: {},
        socketPending: {},
        socketRequestSeq: 0,
        commandError: "",
        lastCommandName:
          ((boot.desktop || {}).uiState || {}).lastCommandName || "",
        dismissedAlertKey: "",
        uiStateSaveTimer: null,
        messages: [
          {
            id: "pending",
            userName: "System",
            text: "Waiting for server chat snapshot.",
            ts: "Pending connect",
          },
        ],
        chatDraft: "",
        terminalStatus: (view.terminal || {}).status || "Terminal idle",
        terminal: {
          terminalId: ((boot.desktop || {}).uiState || {}).terminalId || "",
          inputLine: "",
          transcript: "",
          history: [],
          historyIndex: -1,
          prompt: "YDB>",
          cwd: "/",
          transport: "pipe",
          seq: 0,
          busy: false,
        },
        terminalWindows: {},
        terminalLoadErrors: {},
        terminalPollTimer: null,
        terminalWindowSeq: 0,
        view: view,
        apps: arr((boot.desktop || {}).apps),
        windows: arr((boot.desktop || {}).windows).map(function (win, idx) {
          return {
            id: win.id || "win-" + idx,
            appKey: win.appKey || win.key || "workspace",
            title: win.title || win.appKey || "Window",
            left: Number(win.left || 120),
            top: Number(win.top || 60),
            width: Number(win.width || 720),
            height: Number(win.height || 520),
            z: Number(win.z || idx + 1),
            taskOrder: Number(win.taskOrder || idx + 1),
            minimized: (win.state || "") === "minimized",
            closed: false,
            maximized: false,
            restoreRect: null,
            snap: "",
          };
        }),
        customFolders: [],
        desktopIconPositions: {},
        explorerPrefs: {},
        explorerIconPositions: {},
        explorerDrag: {
          active: false,
          folderKey: "",
          itemKey: "",
          pointerId: null,
          startX: 0,
          startY: 0,
          baseX: 0,
          baseY: 0,
          moved: false,
        },
        shellDrag: {
          active: false,
          sourceKind: "",
          sourceKey: "",
          sourceParentKey: "",
          sourceWindowId: "",
          operation: "move",
          hoverTargetKind: "",
          hoverTargetKey: "",
          hoverAllowed: false,
          hoverLabel: "",
          clientX: 0,
          clientY: 0,
          moved: false,
        },
        vfsLocationOverrides: {},
        explorerLinks: [],
        iconDrag: {
          active: false,
          key: "",
          pointerId: null,
          startX: 0,
          startY: 0,
          baseX: 0,
          baseY: 0,
          moved: false,
        },
        dialogPositions: {
          run: { left: null, top: null },
          about: { left: null, top: null },
          power: { left: null, top: null },
        },
        dialogDrag: {
          active: false,
          kind: "",
          pointerId: null,
          startX: 0,
          startY: 0,
          baseLeft: 0,
          baseTop: 0,
        },
        folderSequence: 0,
        suppressIconLaunchKey: "",
        suppressIconLaunchUntil: 0,
        snapPreview: { visible: false, left: 0, top: 0, width: 0, height: 0 },
        resizeEdges: ["n", "s", "e", "w", "ne", "nw", "se", "sw"],
        settingsStatus: "Ready",
        layoutMode: ((boot.desktop || {}).uiState || {}).layoutMode || "",
        contextMenu: {
          visible: false,
          kind: "",
          x: 0,
          y: 0,
          items: [],
          targetId: "",
          targetKey: "",
          targetKind: "",
        },
        dialogs: { run: false, about: false, power: false },
        runDialogInput: "terminal",
        settingsForm: {
          themeKey:
            ((view.settings || {}).current || {}).themeKey ||
            ((boot.desktop || {}).theme || {}).currentKey ||
            "midnight-professional",
          fontFamily:
            ((view.settings || {}).current || {}).fontFamily ||
            (boot.desktop || {}).fontFamily ||
            "Segoe UI",
          fontSize: String(
            ((view.settings || {}).current || {}).fontSize ||
              (boot.desktop || {}).fontSize ||
              13,
          ),
          titleAccent:
            ((view.settings || {}).current || {}).titleAccent ||
            (boot.desktop || {}).titleAccent ||
            "theme",
          iconStyle:
            ((view.settings || {}).current || {}).iconStyle ||
            (boot.desktop || {}).iconStyle ||
            "glass",
          wallpaper:
            ((view.settings || {}).current || {}).wallpaper ||
            root.getAttribute("data-wallpaper") ||
            "midnight-clinic",
          density:
            ((view.settings || {}).current || {}).density ||
            root.getAttribute("data-density") ||
            "dense",
          animations:
            ((view.settings || {}).current || {}).animations ||
            root.getAttribute("data-animations") ||
            "standard",
          windowPreset:
            ((view.settings || {}).current || {}).windowPreset ||
            root.getAttribute("data-window-preset") ||
            "analyst",
          snapMode:
            ((view.settings || {}).current || {}).snapMode ||
            root.getAttribute("data-snap-mode") ||
            "quadrant",
          motionProfile:
            ((view.settings || {}).current || {}).motionProfile ||
            root.getAttribute("data-motion-profile") ||
            "standard",
          titlebarStyle:
            ((view.settings || {}).current || {}).titlebarStyle ||
            root.getAttribute("data-titlebar-style") ||
            "accent",
          icons: clone(((view.settings || {}).current || {}).icon || {}),
          terminal: {
            fontFamily: String(
              (((view.settings || {}).current || {}).terminal || {})
                .fontFamily ||
                ((view.terminal || {}).profile || {}).fontFamily ||
                "Consolas",
            ),
            fontSize: String(
              (((view.settings || {}).current || {}).terminal || {}).fontSize ||
                ((view.terminal || {}).profile || {}).fontSize ||
                13,
            ),
            cursorBlink: String(
              (((view.settings || {}).current || {}).terminal || {})
                .cursorBlink != null
                ? (((view.settings || {}).current || {}).terminal || {})
                    .cursorBlink
                : ((view.terminal || {}).profile || {}).cursorBlink != null
                  ? ((view.terminal || {}).profile || {}).cursorBlink
                  : 1,
            ),
            cursorStyle: String(
              (((view.settings || {}).current || {}).terminal || {})
                .cursorStyle ||
                ((view.terminal || {}).profile || {}).cursorStyle ||
                "block",
            ),
            scrollback: String(
              (((view.settings || {}).current || {}).terminal || {})
                .scrollback ||
                ((view.terminal || {}).profile || {}).scrollback ||
                3000,
            ),
            renderer: String(
              (((view.settings || {}).current || {}).terminal || {}).renderer ||
                ((view.terminal || {}).profile || {}).renderer ||
                "canvas",
            ),
            unicode: String(
              (((view.settings || {}).current || {}).terminal || {}).unicode ||
                ((view.terminal || {}).profile || {}).unicode ||
                "unicode11",
            ),
            cols: String(
              (((view.settings || {}).current || {}).terminal || {}).cols ||
                ((view.terminal || {}).profile || {}).cols ||
                120,
            ),
            rows: String(
              (((view.settings || {}).current || {}).terminal || {}).rows ||
                ((view.terminal || {}).profile || {}).rows ||
                28,
            ),
            sizeMode: String(
              (((view.settings || {}).current || {}).terminal || {}).sizeMode ||
                ((view.terminal || {}).profile || {}).sizeMode ||
                "fit-container",
            ),
            palette: String(
              (((view.settings || {}).current || {}).terminal || {}).palette ||
                ((view.terminal || {}).profile || {}).palette ||
                "theme",
            ),
          },
        },
      };
    },
    computed: {
      currentThemes: function () {
        return arr(((this.view.settings || {}).catalog || {}).themes);
      },
      fontOptions: function () {
        return arr(((this.view.settings || {}).catalog || {}).fonts);
      },
      fontSizeOptions: function () {
        return arr(((this.view.settings || {}).catalog || {}).fontSizes);
      },
      titleAccentOptions: function () {
        return arr(((this.view.settings || {}).catalog || {}).titleAccents);
      },
      iconStyleOptions: function () {
        return arr(((this.view.settings || {}).catalog || {}).iconStyles);
      },
      densityOptions: function () {
        return arr(((this.view.settings || {}).catalog || {}).densities);
      },
      wallpaperOptions: function () {
        return arr(((this.view.settings || {}).catalog || {}).wallpapers);
      },
      animationOptions: function () {
        return arr(((this.view.settings || {}).catalog || {}).animations);
      },
      wmWindowPresets: function () {
        return arr(
          (((this.view.settings || {}).catalog || {}).windowManager || {})
            .windowPresets,
        );
      },
      wmSnapModes: function () {
        return arr(
          (((this.view.settings || {}).catalog || {}).windowManager || {})
            .snapModes,
        );
      },
      wmMotionProfiles: function () {
        return arr(
          (((this.view.settings || {}).catalog || {}).windowManager || {})
            .motionProfiles,
        );
      },
      wmTitlebarStyles: function () {
        return arr(
          (((this.view.settings || {}).catalog || {}).windowManager || {})
            .titlebarStyles,
        );
      },
      wmActions: function () {
        var actions = arr(
          ((this.boot.desktop || {}).windowManager || {}).actions,
        );
        if (actions.length) return actions;
        return [
          {
            key: "tile",
            label: "Tile windows",
            subtitle: "Fit visible windows to a clean grid",
            shortcut: "Alt+G",
          },
          {
            key: "cascade",
            label: "Cascade windows",
            subtitle: "Offset active surfaces for review",
            shortcut: "Alt+C",
          },
          {
            key: "minimizeAll",
            label: "Minimize all",
            subtitle: "Clear the workspace quickly",
            shortcut: "Alt+N",
          },
          {
            key: "restoreAll",
            label: "Restore all",
            subtitle: "Bring back hidden work",
            shortcut: "Alt+R",
          },
          {
            key: "focusTerminal",
            label: "Focus terminal",
            subtitle: "Jump to the YDB console",
            shortcut: "Alt+T",
          },
          {
            key: "runDialog",
            label: "Run…",
            subtitle: "Open an app by name",
            shortcut: "Alt+M",
          },
          {
            key: "powerDialog",
            label: "Turn Off Computer",
            subtitle: "Show the shell power dialog",
            shortcut: "",
          },
        ];
      },
      currentThemeDefinition: function () {
        var key =
          this.settingsForm.themeKey ||
          ((this.boot.desktop || {}).theme || {}).currentKey ||
          "midnight-professional";
        var themes = this.currentThemes || [];
        for (var i = 0; i < themes.length; i += 1) {
          if ((themes[i] || {}).key === key) return themes[i] || {};
        }
        return ((this.boot.desktop || {}).theme || {}).current || {};
      },
      terminalPrompt: function () {
        return (this.terminal && this.terminal.prompt) || "YDB>";
      },
      terminalTranscript: function () {
        var text = (this.terminal || {}).transcript || "";
        if (!text) return "Open YDB to begin a shell session.\n";
        return text;
      },
      terminalFonts: function () {
        return arr(
          (((this.view.settings || {}).catalog || {}).terminal || {}).fonts,
        );
      },
      terminalFontSizes: function () {
        return arr(
          (((this.view.settings || {}).catalog || {}).terminal || {}).fontSizes,
        );
      },
      terminalCursorStyles: function () {
        return arr(
          (((this.view.settings || {}).catalog || {}).terminal || {})
            .cursorStyles,
        );
      },
      terminalCursorBlink: function () {
        return arr(
          (((this.view.settings || {}).catalog || {}).terminal || {})
            .cursorBlink,
        );
      },
      terminalScrollbacks: function () {
        return arr(
          (((this.view.settings || {}).catalog || {}).terminal || {})
            .scrollbacks,
        );
      },
      terminalRenderers: function () {
        return arr(
          (((this.view.settings || {}).catalog || {}).terminal || {}).renderers,
        );
      },
      terminalSizeModes: function () {
        return arr(
          (((this.view.settings || {}).catalog || {}).terminal || {}).sizeModes,
        );
      },
      terminalPalettes: function () {
        return arr(
          (((this.view.settings || {}).catalog || {}).terminal || {}).palettes,
        );
      },
      terminalUnicodeModes: function () {
        return arr(
          (((this.view.settings || {}).catalog || {}).terminal || {})
            .unicodeModes,
        );
      },
      terminalThemeSpec: function () {
        var palette = String(
            ((this.settingsForm || {}).terminal || {}).palette || "theme",
          ),
          mode = String((this.currentThemeDefinition || {}).mode || "dark");
        if (palette === "black-on-white")
          return {
            background: "#ffffff",
            foreground: "#111111",
            cursor: "#111111",
            cursorAccent: "#ffffff",
            selectionBackground: "rgba(17,17,17,0.18)",
            chromeBorder: "rgba(24,24,24,0.26)",
            chromeBackground:
              "linear-gradient(180deg, rgba(255,255,255,0.985), rgba(241,243,246,0.99))",
            statusBackground: "rgba(255,255,255,0.86)",
            statusText: "#222222",
            dot: "#111111",
            dotHalo: "rgba(17,17,17,0.16)",
          };
        if (palette === "white-on-black")
          return {
            background: "#000000",
            foreground: "#f5f5f5",
            cursor: "#f5f5f5",
            cursorAccent: "#000000",
            selectionBackground: "rgba(245,245,245,0.24)",
            chromeBorder: "rgba(255,255,255,0.12)",
            chromeBackground:
              "linear-gradient(180deg, rgba(0,0,0,0.985), rgba(10,10,10,0.99))",
            statusBackground: "rgba(0,0,0,0.72)",
            statusText: "rgba(245,245,245,0.82)",
            dot: "#f5f5f5",
            dotHalo: "rgba(245,245,245,0.16)",
          };
        if (palette === "midnight-blue")
          return {
            background: "#0b1220",
            foreground: "#dce9ff",
            cursor: "#dce9ff",
            cursorAccent: "#0b1220",
            selectionBackground: "rgba(143,179,255,0.30)",
            chromeBorder: "rgba(53,78,107,0.92)",
            chromeBackground:
              "linear-gradient(180deg, rgba(13,21,33,0.98), rgba(7,12,20,0.98))",
            statusBackground: "rgba(7,12,20,0.55)",
            statusText: "rgba(207,221,240,0.72)",
            dot: "#7aa0f7",
            dotHalo: "rgba(122,160,247,0.18)",
          };
        if (mode === "light")
          return {
            background: "#ffffff",
            foreground: "#1c2738",
            cursor: "#1c2738",
            cursorAccent: "#ffffff",
            selectionBackground: "rgba(95,141,255,0.18)",
            chromeBorder: "rgba(148,163,184,0.42)",
            chromeBackground:
              "linear-gradient(180deg, rgba(255,255,255,0.98), rgba(241,246,255,0.98))",
            statusBackground: "rgba(255,255,255,0.82)",
            statusText: "rgba(28,39,56,0.76)",
            dot: "#3467d6",
            dotHalo: "rgba(52,103,214,0.16)",
          };
        return {
          background: "#0b1220",
          foreground: "#dce9ff",
          cursor: "#dce9ff",
          cursorAccent: "#0b1220",
          selectionBackground: "rgba(143,179,255,0.30)",
          chromeBorder: "rgba(53,78,107,0.92)",
          chromeBackground:
            "linear-gradient(180deg, rgba(13,21,33,0.98), rgba(7,12,20,0.98))",
          statusBackground: "rgba(7,12,20,0.55)",
          statusText: "rgba(207,221,240,0.72)",
          dot: "#7aa0f7",
          dotHalo: "rgba(122,160,247,0.18)",
        };
      },
      terminalViewportStyle: function () {
        var spec = this.terminalThemeSpec || {};
        return {
          borderColor: spec.chromeBorder || "",
          background: spec.chromeBackground || "",
          boxShadow:
            "inset 0 1px 0 rgba(255,255,255,0.06), inset 0 0 0 1px rgba(255,255,255,0.03), 0 18px 34px rgba(5,10,17,0.24)",
        };
      },
      terminalStatuslineStyle: function () {
        var spec = this.terminalThemeSpec || {},
          connected = !!(this.terminal || {}).terminalId;
        return {
          color: spec.statusText || "",
          background: spec.statusBackground || "",
          "--miomos-terminal-dot": connected
            ? spec.dot || "#7aa0f7"
            : "#c77c35",
          "--miomos-terminal-dot-halo": connected
            ? spec.dotHalo || "rgba(122,160,247,0.18)"
            : "rgba(199,124,53,0.18)",
        };
      },
      allEntries: function () {
        return this.apps.concat(arr(this.customFolders)).sort(function (a, b) {
          var ao = Number(a.order || 0),
            bo = Number(b.order || 0);
          if (ao !== bo) return ao - bo;
          return String(a.title || a.key || "").localeCompare(
            String(b.title || b.key || ""),
          );
        });
      },
      pinnedEntries: function () {
        return this.allEntries
          .filter(function (app) {
            return !!app.desktopPinned;
          })
          .sort(function (a, b) {
            return Number(a.order || 0) - Number(b.order || 0);
          });
      },
      quickLaunchEntries: function () {
        return this.pinnedEntries
          .filter(function (app) {
            return (app.kind || "") !== "directory";
          })
          .slice(0, 3);
      },
      shellChrome: function () {
        return this.view.shellChrome || {};
      },
      startSectionTabs: function () {
        return this.menuSections.map(function (section) {
          return section.label;
        });
      },
      shellQuickLaunchLabel: function () {
        return this.shellChrome.quickLaunchLabel || "Quick Launch";
      },
      shellOverflowLabel: function () {
        return this.shellChrome.overflowLabel || "More Windows";
      },
      shellRecentLabel: function () {
        return this.shellChrome.recentLabel || "Recently used";
      },
      shellSearchPlaceholder: function () {
        return (
          this.shellChrome.searchPlaceholder ||
          "Search programs and shell actions"
        );
      },
      trayItems: function () {
        var tray = arr(this.shellChrome.tray);
        if (tray.length) return tray;
        return [
          {
            key: "network",
            label: "Network connected",
            icon: "LAN",
            action: "about",
            className: "is-ok",
          },
          {
            key: "workspace",
            label: "Workspace ready",
            icon: "✓",
            action: "refresh",
          },
          { key: "power", label: "Power options", icon: "⏻", action: "power" },
        ];
      },
      dragCueText: function () {
        if (!this.shellDrag.active || !this.shellDrag.moved) return "";
        if (this.shellDrag.hoverAllowed && this.shellDrag.hoverLabel) {
          if (this.shellDrag.operation === "copy")
            return "Copy here · " + this.shellDrag.hoverLabel;
          if (this.shellDrag.operation === "shortcut")
            return "Create shortcut here · " + this.shellDrag.hoverLabel;
          return "Move here · " + this.shellDrag.hoverLabel;
        }
        if (this.shellDrag.hoverTargetKind === "desktop")
          return "Arrange on Desktop";
        return "Cannot drop here";
      },
      dragCueStyle: function () {
        return {
          left: Math.max(12, Number(this.shellDrag.clientX || 0) + 18) + "px",
          top: Math.max(12, Number(this.shellDrag.clientY || 0) + 18) + "px",
        };
      },
      anyDialogOpen: function () {
        return !!(this.dialogs.run || this.dialogs.about || this.dialogs.power);
      },
      desktopEntries: function () {
        return this.pinnedEntries
          .filter(function (app) {
            return !!app.desktopPinned;
          })
          .sort(function (a, b) {
            var ax = Number(a.desktopOrder || a.order || 0),
              bx = Number(b.desktopOrder || b.order || 0);
            if (ax !== bx) return ax - bx;
            return Number(a.order || 0) - Number(b.order || 0);
          });
      },
      directoryEntries: function () {
        return this.allEntries
          .filter(function (app) {
            return (app.kind || "") === "directory";
          })
          .sort(function (a, b) {
            return Number(a.order || 0) - Number(b.order || 0);
          });
      },
      plannedEntries: function () {
        return this.allEntries
          .filter(function (app) {
            return (app.kind || "") === "future";
          })
          .sort(function (a, b) {
            return Number(a.order || 0) - Number(b.order || 0);
          });
      },
      shellSummary: function () {
        return {
          pinned: this.desktopEntries.length,
          directories: this.directoryEntries.length,
          planned: this.plannedEntries.length,
        };
      },
      mobileBreakpoint: function () {
        return (
          Number(((this.boot.desktop || {}).mobile || {}).breakpoint || 900) ||
          900
        );
      },
      isCompactViewport: function () {
        return Number(this.viewportWidth || 0) <= this.mobileBreakpoint;
      },
      qualitySummary: function () {
        var ready = this.allEntries.filter(function (app) {
          return (app.status || "") !== "planned";
        }).length;
        return { ready: ready, windows: this.windows.length, shortcuts: 6 };
      },
      trayBadges: function () {
        return [
          {
            label: this.socketConnected ? "LAN" : "Offline",
            className: this.socketConnected ? "is-ok" : "is-offline",
          },
          {
            label: "WS Bus",
            className: this.socketConnected ? "is-ok" : "is-offline",
          },
          {
            label: (
              (this.boot.product || {}).profile ||
              this.profile ||
              "dev"
            ).toUpperCase(),
          },
          { label: this.settingsForm.density || "dense" },
        ];
      },
      contextMenuStyle: function () {
        return {
          left: (this.contextMenu.x || 0) + "px",
          top: (this.contextMenu.y || 0) + "px",
        };
      },
      desktopPolicy: function () {
        return (this.boot.desktop || {}).policy || {};
      },
      shellHealth: function () {
        var state = "offline";
        if (this.socketConnected) state = "live";
        else if (this.socketConnecting || this.reconnectTimer)
          state = "reconnecting";
        return {
          socketState: state,
          stale:
            !!this.lastSocketAt &&
            Date.now() - this.lastSocketAt >
              (this.desktopPolicy.staleSocketMs || 45000),
        };
      },
      shellAlertKey: function () {
        if (this.commandError) return "command:" + this.commandError;
        if (this.shellHealth.stale) return "socket:stale";
        if (this.shellHealth.socketState === "reconnecting")
          return "socket:reconnecting";
        return "";
      },
      showShellAlert: function () {
        return !!(
          this.shellAlertKey && this.dismissedAlertKey !== this.shellAlertKey
        );
      },
      shellAlertTitle: function () {
        if (this.commandError) return "Shell command issue";
        if (this.shellHealth.stale) return "Socket heartbeat stale";
        if (this.shellHealth.socketState === "reconnecting")
          return "Reconnecting session";
        return "";
      },
      shellAlertMessage: function () {
        if (this.commandError) return this.commandError;
        if (this.shellHealth.stale)
          return "The desktop has not seen socket activity recently. The client will recycle the connection automatically.";
        if (this.shellHealth.socketState === "reconnecting")
          return "The persistent MIOMOS socket is reconnecting using the server-authored backoff policy.";
        return "";
      },
      shellAlertClass: function () {
        return {
          "is-error": !!this.commandError,
          "is-warning": !this.commandError,
        };
      },
      taskWindows: function () {
        return this.windows
          .filter(function (win) {
            return !win.closed;
          })
          .sort(function (a, b) {
            var ao = Number(a.taskOrder || 0),
              bo = Number(b.taskOrder || 0);
            if (ao !== bo) return ao - bo;
            return Number(a.z || 0) - Number(b.z || 0);
          });
      },
      taskbarSlotCount: function () {
        if (this.isCompactViewport) return 4;
        if ((this.viewportWidth || 0) <= 1180) return 5;
        if ((this.viewportWidth || 0) <= 1420) return 6;
        return 7;
      },
      visibleTaskWindows: function () {
        return this.taskWindows.slice(0, this.taskbarSlotCount);
      },
      overflowTaskWindows: function () {
        return this.taskWindows.slice(this.taskbarSlotCount);
      },
      currentShellSurface: function () {
        if (this.anyDialogOpen) return "dialog";
        if (this.contextMenu.visible) return "context-menu";
        if (this.menuOpen) return "start-menu";
        return "desktop";
      },
      menuSections: function () {
        var order = [
            "Pinned",
            "Directories",
            "Applications",
            "System",
            "Planned",
          ],
          buckets = {},
          out = [];
        this.allEntries.forEach(function (app) {
          var key = app.group || "Applications";
          if (!buckets[key]) buckets[key] = [];
          buckets[key].push(app);
        });
        order.forEach(function (label) {
          if (buckets[label] && buckets[label].length) {
            buckets[label].sort(function (a, b) {
              return Number(a.order || 0) - Number(b.order || 0);
            });
            out.push({ label: label, items: buckets[label] });
          }
        });
        return out;
      },
      normalizedStartSearch: function () {
        return String(this.startSearch || "")
          .trim()
          .toLowerCase();
      },
      visibleShellActions: function () {
        var q = this.normalizedStartSearch,
          actions = this.wmActions.slice(0);
        if (!q) return actions;
        return actions.filter(function (action) {
          var hay = [action.label, action.subtitle, action.shortcut, action.key]
            .join(" ")
            .toLowerCase();
          return hay.indexOf(q) >= 0;
        });
      },
      visibleMenuSections: function () {
        var active = this.activeStartSection || "",
          q = this.normalizedStartSearch,
          sections = this.menuSections.slice(0);
        if (active && !q)
          sections = sections.filter(function (section) {
            return section.label === active;
          });
        if (!q) return sections;
        return sections
          .map(function (section) {
            return {
              label: section.label,
              items: section.items.filter(function (app) {
                var hay = [
                  app.title,
                  app.subtitle,
                  app.badge,
                  app.key,
                  app.group,
                  app.kind,
                ]
                  .join(" ")
                  .toLowerCase();
                return hay.indexOf(q) >= 0;
              }),
            };
          })
          .filter(function (section) {
            return section.items.length > 0;
          });
      },
      startRecentEntries: function () {
        var keys = this.recentLaunchKeys.slice(0),
          used = {},
          list = [],
          fallback = arr(this.shellChrome.recentFallback);
        keys.forEach(function (key) {
          if (!key || used[key]) return;
          var app = this.allEntries.find(function (entry) {
            return entry.key === key;
          });
          if (!app || app.disabled) return;
          used[key] = 1;
          list.push(app);
        }, this);
        if (!list.length)
          fallback.forEach(function (item) {
            var key = (item || {}).key || "";
            if (!key || used[key]) return;
            var app = this.allEntries.find(function (entry) {
              return entry.key === key;
            });
            if (!app || app.disabled) return;
            used[key] = 1;
            list.push(app);
          }, this);
        return list.slice(0, 4);
      },
      hasStartMatches: function () {
        return (
          !this.normalizedStartSearch ||
          !!(this.visibleShellActions.length || this.visibleMenuSections.length)
        );
      },
      snapPreviewStyle: function () {
        return {
          left: this.snapPreview.left + "px",
          top: this.snapPreview.top + "px",
          width: this.snapPreview.width + "px",
          height: this.snapPreview.height + "px",
        };
      },
    },
    mounted: function () {
      var self = this;
      this.currentClock = new Date().toLocaleTimeString([], {
        hour: "2-digit",
        minute: "2-digit",
      });
      window.setInterval(function () {
        self.currentClock = new Date().toLocaleTimeString([], {
          hour: "2-digit",
          minute: "2-digit",
        });
      }, 60000);
      this.applySettings();
      this.syncViewportMode();
      this.loadUiStateLocal();
      this.loadRecentLaunches();
      if (
        this.startSectionTabs.length &&
        this.startSectionTabs.indexOf(this.activeStartSection) < 0
      )
        this.activeStartSection = this.startSectionTabs[0];
      if (this.windows.length)
        this.focusWindow(this.activeWindowId || this.windows[0].id);
      this.installWindowListeners();
      this.loadLayoutLocal();
      this.normalizeTaskOrder();
      this.refreshView().catch(function () {});
      this.connectSocket();
      this.windows.forEach(function (win) {
        if (win.appKey === "terminal") self.ensureTerminalWindowState(win.id);
      });
      if (this.terminal.terminalId) {
        var existingTerminal = this.windows.find(function (win) {
          return win.appKey === "terminal";
        });
        if (existingTerminal)
          this.ensureTerminalWindowState(existingTerminal.id).terminalId =
            this.terminal.terminalId;
      }
      this.$nextTick(function () {
        self.windows.forEach(function (win) {
          if (win.appKey === "terminal") self.ensureXtermMounted(win.id);
        });
      });
      if (this.hasLiveTerminalSession()) this.startTerminalPolling();
    },
    beforeUnmount: function () {
      this.stopTerminalPolling();
      this.disposeAllXterms();
      this.clearXtermMountTimers();
    },
    methods: {
      appEntry: function (key) {
        return (
          this.allEntries.find(function (x) {
            return x.key === key;
          }) ||
          this.apps.find(function (x) {
            return x.key === key;
          }) ||
          null
        );
      },
      windowEntry: function (win) {
        if (
          win &&
          ((win.kind || "") === "directory" ||
            String(win.appKey || "").indexOf("directory:") === 0)
        )
          return {
            key:
              win.directoryKey ||
              String(win.appKey || "").replace("directory:", "") ||
              win.id,
            title: win.title || "Folder",
            kind: "directory",
            subtitle:
              win.subtitle ||
              "Folder view with Windows XP style tasks and views.",
            icon: win.icon || "DIR",
            badge: win.badge || "Folder",
            summary: win.summary || "Folder view",
          };
        return (
          this.appEntry(win.appKey) || {
            key: win.appKey,
            title: win.title || "Window",
            kind: "app",
            subtitle: "",
          }
        );
      },
      terminalWindowDefaults: function () {
        return {
          terminalId: "",
          inputLine: "",
          transcript: "",
          history: [],
          historyIndex: -1,
          prompt: "YDB>",
          cwd: "/",
          transport: "pipe",
          seq: 0,
          busy: false,
          status: "Terminal idle",
          loadError: "",
        };
      },
      ensureTerminalWindowState: function (winId) {
        if (!winId) return this.terminalWindowDefaults();
        if (!this.terminalWindows[winId])
          this.terminalWindows[winId] = clone(this.terminalWindowDefaults());
        return this.terminalWindows[winId];
      },
      terminalStateFor: function (winId) {
        return this.terminalWindows[winId] || this.terminalWindowDefaults();
      },
      terminalStatusFor: function (winId) {
        return (this.terminalWindows[winId] || {}).status || "Terminal idle";
      },
      terminalLoadErrorFor: function (winId) {
        return (this.terminalWindows[winId] || {}).loadError || "";
      },
      terminalConnected: function (winId) {
        return !!((this.terminalWindows[winId] || {}).terminalId || "");
      },
      activeTerminalWindow: function () {
        return this.terminalWindows[this.activeWindowId] || null;
      },
      hasLiveTerminalSession: function () {
        var self = this;
        return this.windows.some(function (win) {
          return (
            win.appKey === "terminal" &&
            !win.closed &&
            !!(self.terminalWindows[win.id] || {}).terminalId
          );
        });
      },
      latestOpenTerminalWindow: function () {
        var wins = this.windows.filter(function (win) {
          return win.appKey === "terminal" && !win.closed;
        });
        if (!wins.length) return null;
        wins.sort(function (a, b) {
          return Number(b.z || 0) - Number(a.z || 0);
        });
        return wins[0] || null;
      },
      syncActiveTerminalState: function (winId) {
        var state = this.ensureTerminalWindowState(winId);
        this.terminalStatus = state.status || "Terminal idle";
        this.terminal.terminalId = state.terminalId || "";
        this.terminal.inputLine = state.inputLine || "";
        this.terminal.transcript = state.transcript || "";
        this.terminal.history = Array.isArray(state.history)
          ? state.history.slice(0)
          : [];
        this.terminal.historyIndex = Number(state.historyIndex || -1);
        this.terminal.prompt = state.prompt || "YDB>";
        this.terminal.cwd = state.cwd || "/";
        this.terminal.transport = state.transport || "pipe";
        this.terminal.seq = Number(state.seq || 0);
        this.terminal.busy = !!state.busy;
      },
      appIcon: function (appKey) {
        var icons = this.settingsForm.icons || {};
        if (icons[appKey]) return icons[appKey];
        var app = this.appEntry(appKey);
        return (app && app.icon) || (appKey || "?").slice(0, 2).toUpperCase();
      },
      folderItemsFor: function (entry) {
        if (!entry) return [];
        if (entry.key === "ui-samples")
          return [
            "ui-library",
            "workspace",
            "collaboration",
            "security",
            "admin",
          ]
            .map(function (key) {
              return this.appEntry(key);
            }, this)
            .filter(Boolean);
        if (entry.key === "jobs" || entry.key === "exports")
          return [this.appEntry("workspace")].filter(Boolean);
        if (entry.key === "profiles")
          return [
            this.appEntry("settings"),
            this.appEntry("ui-library"),
          ].filter(Boolean);
        if (entry.key === "logs")
          return [this.appEntry("security"), this.appEntry("admin")].filter(
            Boolean,
          );
        return [];
      },
      folderEmptyCopy: function (entry) {
        return entry && entry.key && String(entry.key).indexOf("folder-") === 0
          ? "This folder was created from the desktop context menu."
          : "This folder is ready for future product surfaces.";
      },
      explorerViewOptions: function () {
        return [
          { key: "thumbnails", label: "Thumbnails" },
          { key: "tiles", label: "Tiles" },
          { key: "large-icons", label: "Large Icons" },
          { key: "icons", label: "Icons" },
          { key: "list", label: "List" },
          { key: "details", label: "Details" },
        ];
      },
      explorerSortOptions: function () {
        return [
          { key: "name", label: "Name" },
          { key: "size", label: "Size" },
          { key: "type", label: "Type" },
          { key: "modified", label: "Modified" },
        ];
      },
      explorerStateDefaults: function () {
        var desktop = (this.boot || {}).desktop || {};
        return {
          viewMode:
            desktop.explorerDefaultView ||
            desktop.explorerViewMode ||
            "large-icons",
          sortBy: desktop.explorerDefaultSort || "name",
          sortDir: desktop.explorerDefaultSortDir || "asc",
          autoArrange: 1,
          selectedKey: "",
          showSidePane: 1,
        };
      },
      explorerFolderKey: function (subject) {
        var entry = subject && subject.id ? this.windowEntry(subject) : subject;
        return (entry && entry.key) || "";
      },
      ensureExplorerState: function (subject) {
        var key = this.explorerFolderKey(subject),
          defaults = this.explorerStateDefaults();
        if (!key) return clone(defaults);
        if (!this.explorerPrefs[key]) this.explorerPrefs[key] = clone(defaults);
        return this.explorerPrefs[key];
      },
      explorerStateFor: function (subject) {
        return this.ensureExplorerState(subject);
      },
      explorerViewLabel: function (mode) {
        mode = String(mode || "large-icons");
        if (mode === "large-icons") return "Large Icons";
        if (mode === "thumbnails") return "Thumbnails";
        if (mode === "tiles") return "Tiles";
        if (mode === "icons") return "Icons";
        if (mode === "list") return "List";
        return "Details";
      },
      explorerSortLabel: function (mode) {
        mode = String(mode || "name");
        if (mode === "modified") return "date modified";
        return mode;
      },
      explorerRootPath: function (subject) {
        var entry = subject && subject.id ? this.windowEntry(subject) : subject,
          key = (entry && entry.key) || "",
          title = (entry && entry.title) || "Folder";
        if (!key) return "Desktop\\" + title;
        if (key === "my-documents") return "Desktop\\My Documents";
        if (key === "my-computer") return "Desktop\\My Computer";
        if (key === "my-network-places") return "Desktop\\My Network Places";
        if (key === "recycle-bin") return "Desktop\\Recycle Bin";
        return "Desktop\\" + title;
      },
      fileTypeLabel: function (item) {
        if (!item) return "";
        if (item.shortcut) return "Shortcut";
        if (item.kind === "directory") return "File Folder";
        if (item.typeLabel) return item.typeLabel;
        if (item.extension)
          return String(item.extension).toUpperCase() + " File";
        return item.badge || "File";
      },
      normalizeExplorerItem: function (raw, idx, parentKey) {
        var item = raw || {},
          kind = String(
            item.kind || (item.badge === "Folder" ? "directory" : "file"),
          ),
          isDir = kind === "directory",
          title = item.title || item.label || item.key || "Item " + (idx + 1);
        return {
          key: item.key || "item-" + idx,
          title: title,
          subtitle: item.subtitle || item.summary || "",
          summary: item.summary || item.subtitle || "",
          kind: kind,
          icon:
            item.icon ||
            (isDir
              ? "DIR"
              : (item.extension || item.badge || "DOC")
                  .slice(0, 3)
                  .toUpperCase()),
          badge: item.badge || (isDir ? "Folder" : "File"),
          launchKey: item.launchKey || item.key || "",
          parentKey: item.parentKey || parentKey || "",
          sourceKey: item.sourceKey || item.key || "",
          shortcut: item.shortcut ? 1 : 0,
          sizeBytes: Number(item.sizeBytes || 0),
          sizeLabel: item.sizeLabel || (isDir ? "" : "1 KB"),
          typeLabel: item.typeLabel || this.fileTypeLabel(item),
          modifiedAt: item.modifiedAt || item.modified || "Today",
          extension: item.extension || "",
          path: item.path || "",
          order: Number(item.order || idx || 0),
          vfsEntry: item.vfsEntry ? 1 : 0,
        };
      },
      effectiveVfsParentKey: function (item) {
        var key = String((item || {}).key || ""),
          parent = String((item || {}).parentKey || "");
        if (key && this.vfsLocationOverrides[key])
          return String(this.vfsLocationOverrides[key] || "");
        return parent;
      },
      explorerLinksFor: function (parentKey) {
        var target = String(parentKey || "");
        return arr(this.explorerLinks)
          .filter(function (link) {
            return String((link || {}).parentKey || "") === target;
          })
          .map(function (link, idx) {
            return this.normalizeExplorerItem(
              {
                key: link.key,
                sourceKey: link.sourceKey,
                title: link.title,
                subtitle: link.summary || "Shortcut",
                summary: link.summary || "Shortcut",
                icon: link.icon || "LNK",
                badge: "Shortcut",
                kind: link.kind || "file",
                launchKey: link.launchKey || link.sourceKey || "",
                parentKey: link.parentKey,
                extension: link.extension || "lnk",
                sizeLabel: link.sizeLabel || "",
                modifiedAt: link.modifiedAt || "Today",
                shortcut: 1,
                vfsEntry: 0,
                typeLabel: "Shortcut",
              },
              idx,
              parentKey,
            );
          }, this);
      },
      sortExplorerItems: function (items, state) {
        var list = (items || []).slice(0),
          field = String((state || {}).sortBy || "name"),
          dir = String((state || {}).sortDir || "asc");
        list.sort(function (a, b) {
          var af = a.kind === "directory" ? 0 : 1,
            bf = b.kind === "directory" ? 0 : 1,
            av = "",
            bv = "";
          if (af !== bf) return af - bf;
          if (field === "size") {
            av = Number(a.sizeBytes || 0);
            bv = Number(b.sizeBytes || 0);
          } else if (field === "type") {
            av = String(a.typeLabel || "").toLowerCase();
            bv = String(b.typeLabel || "").toLowerCase();
          } else if (field === "modified") {
            av = String(a.modifiedAt || "").toLowerCase();
            bv = String(b.modifiedAt || "").toLowerCase();
          } else {
            av = String(a.title || "").toLowerCase();
            bv = String(b.title || "").toLowerCase();
          }
          if (av < bv) return dir === "desc" ? 1 : -1;
          if (av > bv) return dir === "desc" ? -1 : 1;
          return Number(a.order || 0) - Number(b.order || 0);
        });
        return list;
      },
      explorerItemsFor: function (subject) {
        var entry = subject && subject.id ? this.windowEntry(subject) : subject,
          key = (entry && entry.key) || "",
          vfs = arr((((this.boot || {}).desktop || {}).vfs || {}).entries),
          items = [];
        if (!entry) return [];
        if (vfs.length)
          items = vfs
            .filter(function (row) {
              return (
                String(this.effectiveVfsParentKey(row)) === String(key || "")
              );
            }, this)
            .map(function (row, idx) {
              var normalized = this.normalizeExplorerItem(row, idx, key);
              normalized.parentKey = this.effectiveVfsParentKey(row);
              return normalized;
            }, this);
        if (!items.length)
          items = this.folderItemsFor(entry).map(function (row, idx) {
            return this.normalizeExplorerItem(row, idx, key);
          }, this);
        items = items.concat(this.explorerLinksFor(key));
        return this.sortExplorerItems(items, this.ensureExplorerState(entry));
      },
      isExplorerIconMode: function (subject) {
        var mode = String(
          this.ensureExplorerState(subject).viewMode || "large-icons",
        );
        return (
          ["thumbnails", "tiles", "large-icons", "icons"].indexOf(mode) > -1
        );
      },
      explorerIconSizeClass: function (subject) {
        return (
          "is-" +
          String(this.ensureExplorerState(subject).viewMode || "large-icons")
        );
      },
      ensureExplorerIconBucket: function (folderKey) {
        if (!folderKey) return {};
        if (!this.explorerIconPositions[folderKey])
          this.explorerIconPositions[folderKey] = {};
        return this.explorerIconPositions[folderKey];
      },
      defaultExplorerItemPosition: function (folderKey, idx, mode) {
        var colWidth =
            mode === "thumbnails"
              ? 140
              : mode === "tiles"
                ? 188
                : mode === "icons"
                  ? 90
                  : 108,
          rowHeight = mode === "thumbnails" ? 128 : mode === "tiles" ? 84 : 102,
          cols = mode === "tiles" ? 2 : 4;
        return {
          x: 16 + (idx % cols) * colWidth,
          y: 14 + Math.floor(idx / cols) * rowHeight,
        };
      },
      clampExplorerItemPosition: function (subject, pos) {
        var win = subject && subject.id ? subject : null,
          state = this.ensureExplorerState(subject),
          maxW = Math.max(
            260,
            Number((win && win.width) || 760) - (state.showSidePane ? 260 : 42),
          ),
          maxH = Math.max(220, Number((win && win.height) || 520) - 190);
        pos.x = Math.max(8, Math.min(Number(pos.x || 0), maxW - 120));
        pos.y = Math.max(8, Math.min(Number(pos.y || 0), maxH - 92));
        return pos;
      },
      explorerCanvasStyle: function (subject) {
        var state = this.ensureExplorerState(subject),
          items = this.explorerItemsFor(subject),
          cols =
            state.viewMode === "tiles"
              ? 2
              : state.viewMode === "thumbnails"
                ? 3
                : 4,
          rowHeight =
            state.viewMode === "thumbnails"
              ? 128
              : state.viewMode === "tiles"
                ? 84
                : 102,
          rows = Math.max(2, Math.ceil(Math.max(items.length, 1) / cols));
        return { minHeight: rows * rowHeight + 24 + "px" };
      },
      explorerItemStyle: function (subject, item, idx) {
        if (!this.isExplorerIconMode(subject)) return {};
        var state = this.ensureExplorerState(subject),
          folderKey = this.explorerFolderKey(subject),
          bucket = this.ensureExplorerIconBucket(folderKey),
          pos =
            bucket[item.key] ||
            this.defaultExplorerItemPosition(folderKey, idx, state.viewMode);
        bucket[item.key] = pos;
        return { left: (pos.x || 0) + "px", top: (pos.y || 0) + "px" };
      },
      selectExplorerItem: function (subject, item) {
        var state = this.ensureExplorerState(subject);
        state.selectedKey = (item && item.key) || "";
      },
      explorerItemSelected: function (subject, item) {
        return (
          String(this.ensureExplorerState(subject).selectedKey || "") ===
          String((item && item.key) || "")
        );
      },
      arrangeExplorer: function (subject, forcedSort) {
        var entry = subject && subject.id ? this.windowEntry(subject) : subject,
          state = this.ensureExplorerState(entry),
          folderKey = this.explorerFolderKey(entry),
          bucket = this.ensureExplorerIconBucket(folderKey),
          items;
        if (forcedSort) state.sortBy = forcedSort;
        items = this.sortExplorerItems(this.explorerItemsFor(entry), state);
        items.forEach(function (item, idx) {
          bucket[item.key] = this.defaultExplorerItemPosition(
            folderKey,
            idx,
            state.viewMode,
          );
        }, this);
        state.autoArrange = 1;
        this.saveLayout();
        this.persistUiState("explorer-arrange");
      },
      setExplorerView: function (subject, mode) {
        var state = this.ensureExplorerState(subject);
        state.viewMode = String(mode || "large-icons");
        if (!this.isExplorerIconMode(subject)) state.autoArrange = 1;
        this.arrangeExplorer(subject);
        this.persistUiState("explorer-view");
      },
      setExplorerSort: function (subject, field) {
        var state = this.ensureExplorerState(subject);
        state.sortBy = String(field || "name");
        state.sortDir = "asc";
        this.arrangeExplorer(subject);
      },
      toggleExplorerSort: function (subject, field) {
        var state = this.ensureExplorerState(subject),
          next = String(field || "name");
        if (state.sortBy === next)
          state.sortDir = state.sortDir === "asc" ? "desc" : "asc";
        else {
          state.sortBy = next;
          state.sortDir = "asc";
        }
        this.arrangeExplorer(subject);
      },
      toggleExplorerSidePane: function (subject) {
        var state = this.ensureExplorerState(subject);
        state.showSidePane = state.showSidePane ? 0 : 1;
        this.saveLayout();
        this.persistUiState("explorer-side-pane");
      },
      explorerSelectionSummary: function (subject) {
        var items = this.explorerItemsFor(subject),
          selected = this.ensureExplorerState(subject).selectedKey || "",
          chosen = items.find(function (item) {
            return String(item.key || "") === String(selected || "");
          });
        if (chosen) return chosen.title + " selected";
        return items.length + " object" + (items.length === 1 ? "" : "s");
      },
      openExplorerDirectory: function (item) {
        var self = this,
          win = this.windows.find(function (w) {
            return (
              String(w.directoryKey || "") === String(item.key || "") ||
              w.id === "win-dir-" + item.key
            );
          });
        if (!win) {
          win = {
            id: "win-dir-" + item.key,
            appKey: "directory:" + item.key,
            kind: "directory",
            directoryKey: item.key,
            title: item.title || "Folder",
            subtitle:
              item.summary ||
              item.subtitle ||
              "Folder view with Windows XP style tasks and views.",
            icon: item.icon || "DIR",
            badge: item.badge || "Folder",
            summary: item.summary || item.subtitle || "",
            left: Math.min(180 + this.windows.length * 18, 420),
            top: Math.min(96 + this.windows.length * 16, 260),
            width: 860,
            height: 560,
            z: ++this.zCounter,
            taskOrder: this.nextTaskOrder(),
            minimized: false,
            closed: false,
            maximized: false,
            restoreRect: null,
            snap: "",
          };
          this.windows.push(win);
        }
        win.closed = false;
        win.minimized = false;
        this.focusWindow(win.id);
        this.saveLayout();
        this.persistUiState("explorer-open-directory");
        this.$nextTick(function () {
          if (self.isExplorerIconMode(win)) self.arrangeExplorer(win);
        });
      },
      openExplorerItem: function (item, subject) {
        if (!item) return;
        this.selectExplorerItem(subject, item);
        if (item.kind === "directory") {
          this.openExplorerDirectory(item);
          return;
        }
        if (item.vfsEntry && Number(item.downloadAllowed || 0)) {
          this.downloadVfsEntry(item);
          return;
        }
        if (item.launchKey && this.appEntry(item.launchKey)) {
          this.launchApp(item.launchKey);
          return;
        }
        this.lastCommandName = "explorer.preview";
        this.persistUiState("explorer-preview");
      },
      beginExplorerItemDrag: function (subject, item, ev) {
        if (!item || (ev.button != null && ev.button !== 0)) return;
        var folderKey = this.explorerFolderKey(subject),
          state = this.ensureExplorerState(subject),
          bucket = this.ensureExplorerIconBucket(folderKey),
          start =
            bucket[item.key] ||
            this.defaultExplorerItemPosition(folderKey, 0, state.viewMode),
          self = this;
        this.selectExplorerItem(subject, item);
        this.explorerDrag = {
          active: true,
          folderKey: folderKey,
          itemKey: item.key,
          pointerId: ev.pointerId,
          startX: ev.clientX,
          startY: ev.clientY,
          baseX: start.x,
          baseY: start.y,
          moved: false,
        };
        this.beginShellDrag({
          sourceKind: item.vfsEntry ? "vfs-item" : "explorer-item",
          sourceKey: item.key,
          sourceParentKey: folderKey,
          sourceWindowId: (subject || {}).id || "",
          operation: this.dragOperationFromEvent(ev),
          clientX: ev.clientX,
          clientY: ev.clientY,
        });
        function move(mev) {
          var dx, dy, pos;
          if (
            !self.explorerDrag.active ||
            self.explorerDrag.itemKey !== item.key
          )
            return;
          dx = mev.clientX - self.explorerDrag.startX;
          dy = mev.clientY - self.explorerDrag.startY;
          if (Math.abs(dx) > 3 || Math.abs(dy) > 3) {
            self.explorerDrag.moved = true;
            self.shellDrag.moved = true;
          }
          if (self.isExplorerIconMode(subject)) {
            pos = self.clampExplorerItemPosition(subject, {
              x: self.explorerDrag.baseX + dx,
              y: self.explorerDrag.baseY + dy,
            });
            bucket[item.key] = pos;
          }
          self.updateShellDropHover(mev.clientX, mev.clientY, mev);
        }
        function up(mev) {
          window.removeEventListener("pointermove", move);
          window.removeEventListener("pointerup", up);
          window.removeEventListener("pointercancel", up);
          if (self.explorerDrag.moved) {
            if (
              !self.commitShellDrop(mev, {
                sourceKind: item.vfsEntry ? "vfs-item" : "explorer-item",
                sourceKey: item.key,
                sourceParentKey: folderKey,
                sourceWindowId: (subject || {}).id || "",
                item: item,
              })
            ) {
              if (self.isExplorerIconMode(subject)) {
                state.autoArrange = 0;
                self.saveLayout();
                self.persistUiState("explorer-drag");
              }
            }
          }
          self.explorerDrag = {
            active: false,
            folderKey: "",
            itemKey: "",
            pointerId: null,
            startX: 0,
            startY: 0,
            baseX: 0,
            baseY: 0,
            moved: false,
          };
          self.endShellDrag();
        }
        window.addEventListener("pointermove", move);
        window.addEventListener("pointerup", up);
        window.addEventListener("pointercancel", up);
      },
      dragOperationFromEvent: function (ev) {
        if (ev && ev.altKey) return "shortcut";
        if (ev && ev.ctrlKey) return "copy";
        return "move";
      },
      beginShellDrag: function (meta) {
        this.shellDrag = {
          active: true,
          sourceKind: String((meta || {}).sourceKind || ""),
          sourceKey: String((meta || {}).sourceKey || ""),
          sourceParentKey: String((meta || {}).sourceParentKey || ""),
          sourceWindowId: String((meta || {}).sourceWindowId || ""),
          operation: String((meta || {}).operation || "move"),
          hoverTargetKind: "",
          hoverTargetKey: "",
          hoverAllowed: false,
          hoverLabel: "",
          clientX: Number((meta || {}).clientX || 0),
          clientY: Number((meta || {}).clientY || 0),
          moved: false,
        };
      },
      endShellDrag: function () {
        this.shellDrag = {
          active: false,
          sourceKind: "",
          sourceKey: "",
          sourceParentKey: "",
          sourceWindowId: "",
          operation: "move",
          hoverTargetKind: "",
          hoverTargetKey: "",
          hoverAllowed: false,
          hoverLabel: "",
          clientX: 0,
          clientY: 0,
          moved: false,
        };
      },
      isDesktopDropTarget: function (entry) {
        return !!entry && String(entry.kind || "") === "directory";
      },
      shellDropTargetMatches: function (kind, key) {
        return (
          this.shellDrag.active &&
          String(this.shellDrag.hoverTargetKind || "") === String(kind || "") &&
          String(this.shellDrag.hoverTargetKey || "") === String(key || "")
        );
      },
      shellDropMetaFromElement: function (el) {
        var node = el,
          ds;
        while (node && node !== document.body) {
          ds = node.dataset || {};
          if (ds.dropTargetKind === "directory")
            return {
              kind:
                node.classList && node.classList.contains("miomos-desktop-icon")
                  ? "desktop-icon"
                  : "explorer-item",
              key: String(
                node.getAttribute("data-launch-app") ||
                  node.getAttribute("data-entry-key") ||
                  ds.folderKey ||
                  "",
              ),
              label:
                String(node.getAttribute("title") || "").trim() ||
                String((node.textContent || "").trim() || "Folder"),
            };
          if (ds.explorerDropzone === "1")
            return {
              kind: "explorer-window",
              key: String(ds.folderKey || ""),
              label: "Folder window",
            };
          if (ds.desktopDropzone === "1")
            return { kind: "desktop", key: "desktop", label: "Desktop" };
          node = node.parentElement;
        }
        return { kind: "desktop", key: "desktop", label: "Desktop" };
      },
      updateShellDropHover: function (x, y, ev) {
        var op = this.dragOperationFromEvent(ev),
          target = this.shellDropMetaFromElement(
            document.elementFromPoint(x, y),
          );
        this.shellDrag.operation = op;
        this.shellDrag.clientX = Number(x || 0);
        this.shellDrag.clientY = Number(y || 0);
        this.shellDrag.hoverTargetKind = String((target || {}).kind || "");
        this.shellDrag.hoverTargetKey = String((target || {}).key || "");
        this.shellDrag.hoverLabel = String((target || {}).label || "");
        this.shellDrag.hoverAllowed = this.isAllowedDropTarget(
          this.shellDrag,
          target,
        );
      },
      isAllowedDropTarget: function (drag, target) {
        var sourceKind = String((drag || {}).sourceKind || ""),
          targetKind = String((target || {}).kind || ""),
          targetKey = String((target || {}).key || ""),
          sourceKey = String((drag || {}).sourceKey || ""),
          sourceParent = String((drag || {}).sourceParentKey || "");
        if (!targetKind) return false;
        if (targetKind === "desktop")
          return (
            sourceKind === "desktop-icon" ||
            sourceKind === "vfs-item" ||
            sourceKind === "explorer-item"
          );
        if (!targetKey || targetKey === sourceKey || targetKey === sourceParent)
          return false;
        return true;
      },
      buildLinkFromSource: function (source, targetKey, mode) {
        var item =
          (source || {}).item ||
          this.explorerItemsFor({ key: source.sourceParentKey }).find(
            function (row) {
              return String(row.key || "") === String(source.sourceKey || "");
            },
          ) ||
          this.appEntry(source.sourceKey) ||
          {};
        var stamp = String(Date.now());
        return {
          key:
            (mode || "shortcut") +
            "-" +
            String(source.sourceKey || "") +
            "-" +
            stamp.slice(-6),
          sourceKey: String(source.sourceKey || ""),
          parentKey: String(targetKey || ""),
          title:
            mode === "copy"
              ? "Copy of " + String(item.title || source.sourceKey || "Item")
              : String(item.title || source.sourceKey || "Shortcut"),
          summary:
            mode === "shortcut"
              ? "Shortcut created from drag and drop"
              : "Copy staged in shell layout",
          icon: String(item.icon || (mode === "shortcut" ? "LNK" : "DOC")),
          kind: String(item.kind || "file"),
          launchKey: String(
            item.launchKey || item.key || source.sourceKey || "",
          ),
          extension: mode === "shortcut" ? "lnk" : String(item.extension || ""),
          sizeLabel: String(item.sizeLabel || ""),
          modifiedAt: "Today",
        };
      },
      commitShellDrop: function (ev, source) {
        var drag = this.shellDrag,
          target = {
            kind: drag.hoverTargetKind,
            key: drag.hoverTargetKey,
            label: drag.hoverLabel,
          },
          op = String(drag.operation || "move");
        if (
          !drag.active ||
          !drag.moved ||
          !this.isAllowedDropTarget(drag, target)
        )
          return false;
        if (
          (source || {}).sourceKind === "vfs-item" &&
          target.kind !== "desktop"
        ) {
          if (op === "move")
            this.vfsLocationOverrides[source.sourceKey] = target.key;
          else
            this.explorerLinks.push(
              this.buildLinkFromSource(
                source,
                target.key,
                op === "copy" ? "copy" : "shortcut",
              ),
            );
          this.saveLayout();
          this.persistUiState("dragdrop-" + op);
          return true;
        }
        if (
          (source || {}).sourceKind === "desktop-icon" &&
          target.kind !== "desktop"
        ) {
          this.explorerLinks.push(
            this.buildLinkFromSource(
              source,
              target.key,
              op === "copy" ? "copy" : "shortcut",
            ),
          );
          this.saveLayout();
          this.persistUiState("dragdrop-link");
          return true;
        }
        if (
          (source || {}).sourceKind === "explorer-item" &&
          target.kind !== "desktop"
        ) {
          this.explorerLinks.push(
            this.buildLinkFromSource(
              source,
              target.key,
              op === "copy" ? "copy" : "shortcut",
            ),
          );
          this.saveLayout();
          this.persistUiState("dragdrop-link");
          return true;
        }
        this.saveLayout();
        return true;
      },
      defaultDesktopIconPosition: function (index) {
        var col = 0,
          row = index;
        return { x: 18 + col * 104, y: 22 + row * 102 };
      },
      normalizeDesktopIconPositions: function () {
        var self = this;
        this.desktopEntries.forEach(function (entry, idx) {
          if (!self.desktopIconPositions[entry.key])
            self.desktopIconPositions[entry.key] =
              self.defaultDesktopIconPosition(idx);
        });
      },
      desktopIconStyle: function (entry, idx) {
        if (this.isCompactViewport) return {};
        var pos =
          this.desktopIconPositions[entry.key] ||
          this.defaultDesktopIconPosition(idx);
        return { left: (pos.x || 0) + "px", top: (pos.y || 0) + "px" };
      },
      clampDesktopIconPosition: function (pos) {
        var rect = this.stageRect();
        pos.x = Math.max(
          10,
          Math.min(Number(pos.x || 0), Math.max(10, rect.width - 98)),
        );
        pos.y = Math.max(
          10,
          Math.min(Number(pos.y || 0), Math.max(10, rect.height - 118)),
        );
        return pos;
      },
      openDesktopEntry: function (app, ev) {
        if (!app || app.disabled) return;
        if (
          this.suppressIconLaunchKey === app.key &&
          Date.now() < this.suppressIconLaunchUntil
        ) {
          if (ev && ev.preventDefault) ev.preventDefault();
          return;
        }
        this.launchApp(app.key);
      },
      beginIconDrag: function (app, ev) {
        if (
          !app ||
          this.isCompactViewport ||
          app.disabled ||
          (ev.button != null && ev.button !== 0)
        )
          return;
        var start =
          this.desktopIconPositions[app.key] ||
          this.defaultDesktopIconPosition(
            this.desktopEntries.findIndex(function (x) {
              return x.key === app.key;
            }),
          );
        this.desktopIconPositions[app.key] = { x: start.x, y: start.y };
        this.iconDrag = {
          active: true,
          key: app.key,
          pointerId: ev.pointerId,
          startX: ev.clientX,
          startY: ev.clientY,
          baseX: start.x,
          baseY: start.y,
          moved: false,
        };
        this.beginShellDrag({
          sourceKind: "desktop-icon",
          sourceKey: app.key,
          sourceParentKey: "desktop",
          sourceWindowId: "",
          operation: this.dragOperationFromEvent(ev),
          clientX: ev.clientX,
          clientY: ev.clientY,
        });
        var self = this;
        function move(mev) {
          if (!self.iconDrag.active || self.iconDrag.key !== app.key) return;
          var dx = mev.clientX - self.iconDrag.startX,
            dy = mev.clientY - self.iconDrag.startY;
          if (Math.abs(dx) > 3 || Math.abs(dy) > 3) {
            self.iconDrag.moved = true;
            self.shellDrag.moved = true;
          }
          var pos = {
            x: self.iconDrag.baseX + dx,
            y: self.iconDrag.baseY + dy,
          };
          self.desktopIconPositions[app.key] =
            self.clampDesktopIconPosition(pos);
          self.updateShellDropHover(mev.clientX, mev.clientY, mev);
        }
        function up(mev) {
          window.removeEventListener("pointermove", move);
          window.removeEventListener("pointerup", up);
          window.removeEventListener("pointercancel", up);
          var moved = self.iconDrag.moved;
          self.iconDrag.active = false;
          self.iconDrag.key = "";
          if (moved) {
            self.suppressIconLaunchKey = app.key;
            self.suppressIconLaunchUntil = Date.now() + 350;
            if (
              !self.commitShellDrop(mev, {
                sourceKind: "desktop-icon",
                sourceKey: app.key,
                sourceParentKey: "desktop",
              })
            )
              self.saveLayout();
          }
          self.endShellDrag();
        }
        window.addEventListener("pointermove", move);
        window.addEventListener("pointerup", up);
        window.addEventListener("pointercancel", up);
      },
      createCustomFolder: function () {
        var next = this.folderSequence + 1,
          key = "folder-" + next,
          title = "New Folder";
        this.folderSequence = next;
        this.customFolders.push({
          key: key,
          title: title,
          subtitle: "Desktop folder created from the MIOMOS context menu",
          icon: "DIR",
          badge: "Folder",
          kind: "directory",
          group: "Directories",
          order: 200 + next,
          desktopOrder: 200 + next,
          launchKey: key,
          desktopPinned: 1,
          status: "available",
          summary: "Empty folder",
        });
        this.desktopIconPositions[key] = this.clampDesktopIconPosition({
          x: 18,
          y: 22 + (this.desktopEntries.length + 1) * 102,
        });
        this.normalizeDesktopIconPositions();
        this.closeContextMenu("new-folder");
        this.saveLayout();
        this.persistUiState("new-folder");
        this.launchApp(key);
      },
      deleteCustomFolder: function (key) {
        this.customFolders = this.customFolders.filter(function (entry) {
          return entry.key !== key;
        });
        delete this.desktopIconPositions[key];
        this.windows = this.windows.filter(function (win) {
          return win.appKey !== key;
        });
        this.saveLayout();
        this.persistUiState("delete-folder");
      },
      nextTaskOrder: function () {
        var max = 0;
        this.windows.forEach(function (win) {
          max = Math.max(max, Number(win.taskOrder || 0));
        });
        return max + 1;
      },
      createTerminalWindow: function (entry) {
        var count =
            this.windows.filter(function (win) {
              return win.appKey === "terminal";
            }).length + 1,
          offset = (count - 1) * 28,
          win = {
            id: "win-terminal-" + Date.now() + "-" + count,
            appKey: "terminal",
            title:
              entry && entry.title
                ? entry.title + (count > 1 ? " " + count : "")
                : "Terminal" + (count > 1 ? " " + count : ""),
            left: Math.min(220 + offset, 420),
            top: Math.min(96 + offset, 260),
            width: 960,
            height: 620,
            z: ++this.zCounter,
            taskOrder: this.nextTaskOrder(),
            minimized: false,
            closed: false,
            maximized: false,
            restoreRect: null,
            snap: "",
          };
        this.windows.push(win);
        this.terminalWindowSeq = count;
        this.ensureTerminalWindowState(win.id);
        return win;
      },
      ensureWindowForEntry: function (entry) {
        if (!entry) return null;
        var wantId =
          entry.kind === "directory"
            ? "win-dir-" + entry.key
            : "win-" + entry.key;
        var win = this.windows.find(function (w) {
          return (
            w.id === wantId ||
            w.appKey === entry.key ||
            String(w.directoryKey || "") === String(entry.key || "")
          );
        });
        if (win) return win;
        win = {
          id: wantId,
          appKey:
            entry.kind === "directory" ? "directory:" + entry.key : entry.key,
          kind: entry.kind || "app",
          directoryKey: entry.kind === "directory" ? entry.key : "",
          title: entry.title || entry.key,
          subtitle: entry.subtitle || entry.summary || "",
          icon: entry.icon || "",
          badge: entry.badge || "",
          summary: entry.summary || "",
          left: 140,
          top: 82,
          width: entry.kind === "directory" ? 860 : 780,
          height: entry.kind === "directory" ? 560 : 520,
          z: ++this.zCounter,
          taskOrder: this.nextTaskOrder(),
          minimized: false,
          closed: false,
          maximized: false,
          restoreRect: null,
          snap: "",
        };
        this.windows.push(win);
        return win;
      },
      uiStateStorageKey: function () {
        return (
          "miomos.ui." +
          ((this.boot.session || {}).id ||
            root.getAttribute("data-miomos-session") ||
            "anon")
        );
      },
      loadUiStateLocal: function () {
        var raw = "",
          saved = {};
        try {
          raw = window.localStorage.getItem(this.uiStateStorageKey()) || "";
        } catch (e) {
          raw = "";
        }
        if (!raw) return;
        try {
          saved = JSON.parse(raw);
        } catch (e2) {
          saved = {};
        }
        if (
          (this.desktopPolicy.persistMenuState || 0) &&
          saved.menuOpen != null
        )
          this.menuOpen = !!saved.menuOpen;
        if (
          (this.desktopPolicy.persistActiveWindow || 0) &&
          saved.activeWindowId
        )
          this.activeWindowId = saved.activeWindowId;
        if (saved.lastCommandName) this.lastCommandName = saved.lastCommandName;
        if (saved.startMenuSection)
          this.activeStartSection = saved.startMenuSection;
        if (saved.startMenuQuery != null)
          this.startSearch = String(saved.startMenuQuery || "");
      },
      serializeUiState: function (reason) {
        var active =
            this.windows.find(function (w) {
              return w.id === this.activeWindowId;
            }, this) || {},
          activeTerm = this.activeTerminalWindow();
        return {
          menuOpen: !!this.menuOpen,
          activeWindowId: this.activeWindowId || "",
          focusedAppKey: active.appKey || "",
          layoutMode: this.layoutMode || "",
          lastCommandName: this.lastCommandName || "",
          terminalId: (activeTerm && activeTerm.terminalId) || "",
          startMenuSection: this.activeStartSection || "",
          startMenuQuery: this.startSearch || "",
          shellSurface: this.currentShellSurface || "desktop",
          reason: reason || "",
        };
      },
      saveUiStateLocal: function () {
        var payload = this.serializeUiState("local-cache");
        try {
          window.localStorage.setItem(
            this.uiStateStorageKey(),
            JSON.stringify(payload),
          );
        } catch (e) {}
      },
      queueUiStateSave: function (reason) {
        var self = this;
        if (
          !(
            this.desktopPolicy.persistMenuState ||
            this.desktopPolicy.persistActiveWindow ||
            this.desktopPolicy.persistLayout
          )
        )
          return;
        if (this.uiStateSaveTimer) window.clearTimeout(this.uiStateSaveTimer);
        this.uiStateSaveTimer = window.setTimeout(function () {
          self.uiStateSaveTimer = null;
          self.saveUiStateServer(reason || "interaction");
        }, 220);
      },
      saveUiStateServer: function (reason) {
        var self = this;
        if (this.inflightCommandCount > 0) {
          this.queueUiStateSave(reason || "retry");
          return;
        }
        this.command(
          "session.ui.save",
          this.serializeUiState(reason || "interaction"),
        ).catch(function () {});
      },
      persistUiState: function (reason) {
        this.saveUiStateLocal();
        this.queueUiStateSave(reason || "interaction");
      },
      dismissShellAlert: function () {
        this.dismissedAlertKey = this.shellAlertKey || "";
      },
      closeShellSurfaces: function (mode) {
        var keep = mode || "";
        if (keep !== "dialog") this.closeDialogs();
        if (keep !== "menu") this.menuOpen = false;
        if (keep !== "context") this.closeContextMenu("shell-surface");
      },
      loadRecentLaunches: function () {
        var raw = "",
          list = [];
        try {
          raw =
            window.localStorage.getItem(
              "miomosRecentLaunches:" + ((this.boot.user || {}).id || "guest"),
            ) || "";
        } catch (e) {
          raw = "";
        }
        if (!raw) return;
        try {
          list = JSON.parse(raw);
        } catch (e2) {
          list = [];
        }
        this.recentLaunchKeys = Array.isArray(list)
          ? list.filter(Boolean).slice(0, 8)
          : [];
      },
      saveRecentLaunches: function () {
        try {
          window.localStorage.setItem(
            "miomosRecentLaunches:" + ((this.boot.user || {}).id || "guest"),
            JSON.stringify(this.recentLaunchKeys.slice(0, 8)),
          );
        } catch (e) {}
      },
      recordRecentLaunch: function (key) {
        if (!key) return;
        this.recentLaunchKeys = [key]
          .concat(
            this.recentLaunchKeys.filter(function (item) {
              return item !== key;
            }),
          )
          .slice(0, 8);
        this.saveRecentLaunches();
      },
      setActiveStartSection: function (label) {
        if (!label) return;
        this.activeStartSection = label;
        this.persistUiState("start-section");
      },
      cycleStartSection: function (step) {
        var tabs = this.startSectionTabs || [],
          idx = 0;
        if (!tabs.length) return;
        idx = tabs.indexOf(this.activeStartSection);
        if (idx < 0) idx = 0;
        idx = (idx + step + tabs.length) % tabs.length;
        this.setActiveStartSection(tabs[idx]);
      },
      taskButtonState: function (win) {
        if (!win || win.closed) return "closed";
        if (win.minimized) return "minimized";
        if (this.activeWindowId === win.id) return "active";
        return "background";
      },
      taskButtonClass: function (win) {
        var state = this.taskButtonState(win);
        return {
          "is-active": state === "active",
          "is-pressed": state === "active",
          "is-minimized": state === "minimized",
          "is-background": state === "background",
        };
      },
      ensureDialogPosition: function (kind) {
        var pos = this.dialogPositions[kind] || { left: null, top: null },
          defs = {
            run: { w: 420, h: 180, dx: 0 },
            about: { w: 420, h: 184, dx: 20 },
            power: { w: 430, h: 214, dx: 40 },
          },
          def = defs[kind] || defs.run,
          rect = this.stageRect();
        if (pos.left == null || pos.top == null) {
          pos = {
            left: Math.max(18, Math.floor((rect.width - def.w) / 2) + def.dx),
            top: Math.max(22, Math.floor((rect.height - def.h) / 2) + def.dx),
          };
          this.dialogPositions[kind] = pos;
        }
        return pos;
      },
      dialogStyle: function (kind) {
        if (this.isCompactViewport) return {};
        var pos = this.ensureDialogPosition(kind);
        return { left: (pos.left || 0) + "px", top: (pos.top || 0) + "px" };
      },
      clampDialogPosition: function (kind) {
        var pos = this.dialogPositions[kind] || { left: 40, top: 40 },
          rect = this.stageRect();
        pos.left = Math.max(
          12,
          Math.min(Number(pos.left || 0), Math.max(12, rect.width - 460)),
        );
        pos.top = Math.max(
          12,
          Math.min(Number(pos.top || 0), Math.max(12, rect.height - 260)),
        );
        this.dialogPositions[kind] = pos;
      },
      beginDialogDrag: function (kind, ev) {
        if (
          this.isCompactViewport ||
          (ev.target &&
            ev.target.closest &&
            ev.target.closest(".miomos-shell-dialog-close"))
        )
          return;
        var pos = this.ensureDialogPosition(kind);
        this.dialogDrag = {
          active: true,
          kind: kind,
          pointerId: ev.pointerId,
          startX: ev.clientX,
          startY: ev.clientY,
          baseLeft: pos.left,
          baseTop: pos.top,
        };
        var self = this;
        function move(mev) {
          if (!self.dialogDrag.active || self.dialogDrag.kind !== kind) return;
          self.dialogPositions[kind] = {
            left:
              self.dialogDrag.baseLeft + (mev.clientX - self.dialogDrag.startX),
            top:
              self.dialogDrag.baseTop + (mev.clientY - self.dialogDrag.startY),
          };
          self.clampDialogPosition(kind);
        }
        function up() {
          window.removeEventListener("pointermove", move);
          window.removeEventListener("pointerup", up);
          window.removeEventListener("pointercancel", up);
          self.dialogDrag.active = false;
          self.dialogDrag.kind = "";
          self.saveLayout();
        }
        window.addEventListener("pointermove", move);
        window.addEventListener("pointerup", up);
        window.addEventListener("pointercancel", up);
      },
      openDialog: function (kind) {
        this.dialogs.run = false;
        this.dialogs.about = false;
        this.dialogs.power = false;
        this.closeShellSurfaces("dialog");
        if (kind && this.dialogs.hasOwnProperty(kind)) {
          this.dialogs[kind] = true;
          this.ensureDialogPosition(kind);
        }
        this.persistUiState("dialog-" + (kind || "none"));
        if (kind === "run")
          this.$nextTick(function () {
            var el = root.querySelector(".miomos-shell-dialog-input");
            if (el && el.focus) el.focus();
          });
      },
      closeDialogs: function () {
        this.dialogs.run = false;
        this.dialogs.about = false;
        this.dialogs.power = false;
        this.persistUiState("dialog-close");
      },
      executeRunDialog: function () {
        var key = String(this.runDialogInput || "")
          .trim()
          .toLowerCase();
        if (!key) return;
        if (key === "cmd" || key === "ydb") key = "terminal";
        if (key === "desk") key = "workspace";
        this.closeDialogs();
        this.launchApp(key);
      },
      onTrayAction: function (tray) {
        if (!tray) return;
        if (tray.action === "refresh") {
          this.refreshView();
          return;
        }
        if (tray.action === "power") {
          this.openDialog("power");
          return;
        }
        this.openDialog("about");
      },
      markSocketActivity: function () {
        this.lastSocketAt = Date.now();
      },
      entryKindLabel: function (kind) {
        if (kind === "directory") return "Directory";
        if (kind === "settings") return "Settings";
        if (kind === "future") return "Planned";
        return "App";
      },
      entryStatusLabel: function (status) {
        if (status === "planned") return "Roadmap";
        if (status === "available") return "Ready";
        return String(status || "");
      },
      entryGlyphClass: function (kind) {
        kind = String(kind || "app");
        return "miomos-entry-glyph--" + kind;
      },
      installWindowListeners: function () {
        var self = this;
        this._miomosKeydown = function (ev) {
          self.onGlobalKeydown(ev);
        };
        this._miomosFileDragGuard = function (ev) {
          if (!self.hasExternalFiles(ev)) return;
          if (ev && ev.preventDefault) ev.preventDefault();
        };
        this._miomosFileDropGuard = function (ev) {
          if (!self.hasExternalFiles(ev)) return;
          if (ev && ev.preventDefault) ev.preventDefault();
          if (root.contains(ev.target)) return;
          self.clearNativeDropHover();
        };
        window.addEventListener("resize", function () {
          self.syncViewportMode();
          self.onWindowResize();
        });
        window.addEventListener("keydown", this._miomosKeydown);
        document.addEventListener("dragover", this._miomosFileDragGuard);
        document.addEventListener("drop", this._miomosFileDropGuard);
        document.addEventListener("pointerdown", function (ev) {
          if (
            self.contextMenu.visible &&
            !(
              ev.target &&
              ev.target.closest &&
              ev.target.closest(".miomos-context-menu")
            )
          )
            self.closeContextMenu("pointerdown");
          if (!root.contains(ev.target) && self.menuOpen) {
            self.menuOpen = false;
            self.persistUiState("outside-click");
          }
        });
        window.addEventListener("beforeunload", function () {
          self.shouldReconnect = false;
          self.saveLayoutLocal();
          self.saveUiStateLocal();
          self.clearReconnectTimer();
          self.clearHeartbeat();
          self.clearStaleMonitor();
          self.stopTerminalPolling();
        });
      },
      applySettings: function () {
        var theme = this.currentThemeDefinition || {};
        root.dataset.density = this.settingsForm.density || "dense";
        root.dataset.wallpaper =
          this.settingsForm.wallpaper || "midnight-clinic";
        root.dataset.animations = this.settingsForm.animations || "standard";
        root.dataset.windowPreset = this.settingsForm.windowPreset || "analyst";
        root.dataset.snapMode = this.settingsForm.snapMode || "quadrant";
        root.dataset.motionProfile =
          this.settingsForm.motionProfile || "standard";
        root.dataset.titlebarStyle =
          this.settingsForm.titlebarStyle || "accent";
        root.dataset.themeMode = theme.mode || "dark";
        root.style.setProperty(
          "--miomos-font",
          this.settingsForm.fontFamily || "Segoe UI",
        );
        root.style.fontSize =
          (parseInt(this.settingsForm.fontSize || "13", 10) || 13) + "px";
        this.applyThemeVariables(theme);
        this.syncViewportMode();
        this.windows.forEach(function (win) {
          if (win.appKey === "terminal" && !win.closed) {
            this.ensureXtermMounted(win.id);
            this.applyXtermProfile(win.id);
          }
        }, this);
      },
      applyThemeVariables: function (theme) {
        theme = theme || {};
        root.style.setProperty("--desktop", theme.desktop || "#0b1320");
        root.style.setProperty(
          "--surface",
          theme.surface || "rgba(15, 23, 36, 0.95)",
        );
        root.style.setProperty(
          "--surface-alt",
          theme.surfaceAlt || "rgba(11, 18, 29, 0.96)",
        );
        root.style.setProperty(
          "--surface-soft",
          theme.surfaceSoft || "rgba(255,255,255,0.03)",
        );
        root.style.setProperty(
          "--border",
          theme.border || "rgba(148,163,184,0.18)",
        );
        root.style.setProperty("--text", theme.text || "#ecf3ff");
        root.style.setProperty("--muted", theme.muted || "#93a7c4");
        root.style.setProperty("--accent", theme.accent || "#5f8dff");
        root.style.setProperty(
          "--accent-soft",
          theme.accentSoft || "rgba(95,141,255,0.18)",
        );
        root.style.setProperty(
          "--accent-strong",
          theme.accentStrong || "rgba(95,141,255,0.34)",
        );
        root.style.setProperty("--title-accent", theme.accent || "#5f8dff");
        root.style.setProperty(
          "--active-title",
          theme.titleActive ||
            "linear-gradient(180deg, rgba(255,255,255,0.12), rgba(255,255,255,0.03)), linear-gradient(90deg, #5f8dff, rgba(255,255,255,0.02) 40%)",
        );
        root.style.setProperty(
          "--inactive-title",
          theme.titleInactive ||
            "linear-gradient(180deg, rgba(91,103,122,0.42), rgba(45,56,72,0.36))",
        );
        root.style.setProperty(
          "--miomos-shadow",
          theme.shadow || "0 18px 42px rgba(0,0,0,.26)",
        );
      },
      syncViewportMode: function () {
        this.viewportWidth =
          window.innerWidth || document.documentElement.clientWidth || 1400;
        root.dataset.mobileLayout = this.isCompactViewport ? "1" : "0";
      },
      focusWindow: function (id) {
        var win = this.windows.find(function (w) {
          return w.id === id;
        });
        if (!win || win.closed) return;
        this.activeWindowId = win.id;
        this.zCounter += 1;
        win.z = this.zCounter;
        if (win.appKey === "terminal") {
          this.syncActiveTerminalState(win.id);
          this.$nextTick(this.ensureXtermMounted.bind(this, win.id));
        }
        this.persistUiState("focus-window");
      },
      normalizeTaskOrder: function () {
        var used = {},
          next = 1;
        this.windows
          .slice()
          .sort(function (a, b) {
            var ao = Number(a.taskOrder || 0),
              bo = Number(b.taskOrder || 0);
            if (ao && bo && ao !== bo) return ao - bo;
            return Number(a.z || 0) - Number(b.z || 0);
          })
          .forEach(function (win) {
            var slot = Number(win.taskOrder || 0);
            if (!slot || used[slot]) {
              while (used[next]) next += 1;
              slot = next;
            }
            used[slot] = 1;
            win.taskOrder = slot;
            if (slot >= next) next = slot + 1;
          });
      },
      launchApp: function (key) {
        var entry = this.appEntry(key) || {},
          launchKey = entry.launchKey || key,
          win = null,
          self = this;
        if (entry.disabled) {
          this.closeShellSurfaces("");
          this.persistUiState("disabled-launch");
          return;
        }
        if (launchKey === "terminal") {
          this.closeShellSurfaces("");
          this.recordRecentLaunch(launchKey);
          win = this.createTerminalWindow(entry);
          this.focusWindow(win.id);
          this.lastCommandName = "launch." + launchKey;
          this.saveLayout();
          this.persistUiState("launch-app");
          this.$nextTick(function () {
            self.openTerminal(win.id, true);
          });
          return;
        }
        win = this.windows.find(function (w) {
          return (
            w.appKey === launchKey ||
            w.id === launchKey ||
            w.id === "win-dir-" + launchKey
          );
        });
        if (!win && (entry.kind || "") === "directory")
          win = this.ensureWindowForEntry(entry);
        if (!win) {
          this.closeShellSurfaces("");
          this.persistUiState("missing-window");
          return;
        }
        this.closeShellSurfaces("");
        this.recordRecentLaunch(launchKey);
        win.title = entry.title || win.title;
        win.closed = false;
        win.minimized = false;
        this.focusWindow(win.id);
        this.lastCommandName = "launch." + launchKey;
        this.saveLayout();
        this.persistUiState("launch-app");
      },
      minimizeWindow: function (id) {
        var win = this.windows.find(function (w) {
          return w.id === id;
        });
        if (!win) return;
        win.minimized = true;
        if (this.activeWindowId === win.id) this.activeWindowId = "";
        this.saveLayout();
        this.persistUiState("minimize-window");
      },
      closeWindow: function (id) {
        var win = this.windows.find(function (w) {
          return w.id === id;
        });
        if (!win) return;
        if (win.appKey === "terminal") {
          this.closeTerminal(id, { closeWindow: true });
          return;
        }
        win.closed = true;
        win.minimized = false;
        if (this.activeWindowId === win.id) this.activeWindowId = "";
        this.saveLayout();
        this.persistUiState("close-window");
      },
      toggleTaskWindow: function (id) {
        var win = this.windows.find(function (w) {
          return w.id === id;
        });
        if (!win) return;
        this.closeShellSurfaces("");
        if (!win.closed && !win.minimized && this.activeWindowId === win.id) {
          win.minimized = true;
          this.activeWindowId = "";
        } else if (win.minimized) {
          win.minimized = false;
          this.focusWindow(win.id);
        } else {
          win.closed = false;
          win.minimized = false;
          this.focusWindow(win.id);
        }
        this.saveLayout();
        this.persistUiState("task-toggle");
      },
      toggleMenu: function () {
        if (this.menuOpen) {
          this.menuOpen = false;
          this.persistUiState("toggle-menu-close");
          return;
        }
        if (
          this.startSectionTabs.length &&
          this.startSectionTabs.indexOf(this.activeStartSection) < 0
        )
          this.activeStartSection = this.startSectionTabs[0];
        this.closeShellSurfaces("menu");
        this.menuOpen = true;
        this.persistUiState("toggle-menu-open");
        this.focusStartSearch();
      },
      focusStartSearch: function () {
        var self = this;
        this.$nextTick(function () {
          var node = self.$refs.startSearchInput;
          if (Array.isArray(node)) node = node[0] || null;
          if (node && node.focus) node.focus();
        });
      },
      clearStartSearch: function () {
        this.startSearch = "";
        this.persistUiState("start-search-clear");
        this.focusStartSearch();
      },
      executeStartSearch: function () {
        if (!this.normalizedStartSearch) return;
        if (
          this.visibleMenuSections.length &&
          this.visibleMenuSections[0].items &&
          this.visibleMenuSections[0].items[0]
        ) {
          this.launchApp(this.visibleMenuSections[0].items[0].key);
          return;
        }
        if (this.visibleShellActions.length && this.visibleShellActions[0]) {
          this.runShellAction(this.visibleShellActions[0].key);
          return;
        }
      },
      openTaskOverflowMenu: function (ev) {
        var self = this,
          rect =
            ev && ev.currentTarget && ev.currentTarget.getBoundingClientRect
              ? ev.currentTarget.getBoundingClientRect()
              : { left: 24, bottom: window.innerHeight - 42 };
        this.closeShellSurfaces("context");
        this.contextMenu.kind = "taskbar-overflow";
        this.contextMenu.targetId = "";
        this.contextMenu.items = this.overflowTaskWindows.map(function (win) {
          return {
            key: "task.toggle." + win.id,
            label: win.title,
            icon: self.appIcon(win.appKey),
            shortcut: win.minimized
              ? "Restore"
              : self.activeWindowId === win.id && !win.closed
                ? "Minimize"
                : "Activate",
          };
        });
        this.contextMenu.x = Math.max(8, rect.left);
        this.contextMenu.y = Math.max(
          8,
          rect.bottom - this.contextMenu.items.length * 30 - 12,
        );
        this.contextMenu.visible = true;
      },
      openDesktopContextMenu: function (ev) {
        this.openContextMenu("desktop", ev, null);
      },
      openIconContextMenu: function (entry, ev) {
        this.openContextMenu("desktop-icon", ev, entry);
      },
      openWindowContextMenu: function (win, ev) {
        this.focusWindow(win.id);
        this.openContextMenu("window", ev, win);
      },
      openContextMenu: function (kind, ev, payload) {
        var items = [],
          hasOpen = this.taskWindows.length > 0,
          x = Math.max(6, ev.clientX || 0),
          y = Math.max(6, ev.clientY || 0),
          targetId = (payload && payload.id) || "",
          targetKey = (payload && payload.key) || "",
          targetKind = (payload && payload.kind) || "";
        this.closeShellSurfaces("context");
        if (kind === "window" && payload) {
          items = [
            {
              key: "restore",
              label: "Restore",
              icon: "▢",
              disabled: !payload.minimized && !payload.maximized,
            },
            {
              key: "minimize",
              label: "Minimize",
              icon: "—",
              disabled: !!payload.minimized,
            },
            {
              key: "maximize",
              label: payload.maximized ? "Restore Down" : "Maximize",
              icon: "□",
            },
            { separator: 1, key: "sep1", label: "────────" },
            { key: "close", label: "Close", icon: "✕" },
          ];
        } else if (kind === "desktop-icon" && payload) {
          items = [
            {
              key: "openEntry",
              label: "Open",
              icon: this.appIcon(payload.key),
              shortcut: payload.kind === "directory" ? "Folder" : "App",
            },
            { separator: 1, key: "sep2", label: "────────" },
            { key: "menu", label: "Open Start Menu", icon: "★" },
            { key: "newFolder", label: "New Folder", icon: "DIR" },
          ];
          if (String(payload.key || "").indexOf("folder-") === 0)
            items.push({
              key: "deleteFolder",
              label: "Delete Folder",
              icon: "✕",
            });
        } else {
          items = [
            { key: "newFolder", label: "New Folder", icon: "DIR" },
            { key: "launch.workspace", label: "Open Workspace", icon: "APP" },
            { key: "launch.terminal", label: "Open Terminal", icon: "TRM" },
            { separator: 1, key: "sep2", label: "────────" },
            { key: "menu", label: "Open Start Menu", icon: "★" },
            { key: "runDialog", label: "Run…", icon: "▶" },
            { key: "aboutDialog", label: "About MIOMOS", icon: "i" },
            { key: "refresh", label: "Refresh Desktop", icon: "↻" },
            {
              key: "tile",
              label: "Tile Windows",
              icon: "▣",
              disabled: !hasOpen,
            },
            {
              key: "minimizeAll",
              label: "Minimize All",
              icon: "▁",
              disabled: !hasOpen,
            },
            {
              key: "restoreAll",
              label: "Restore All",
              icon: "▣",
              disabled: !hasOpen,
            },
            { separator: 1, key: "sep3", label: "────────" },
            { key: "powerDialog", label: "Turn Off Computer", icon: "⏻" },
          ];
        }
        this.contextMenu = {
          visible: true,
          kind: kind,
          x: x,
          y: y,
          items: items,
          targetId: targetId,
          targetKey: targetKey,
          targetKind: targetKind,
        };
        this.persistUiState("context-open");
      },
      closeContextMenu: function (reason) {
        if (!this.contextMenu.visible) return;
        this.contextMenu.visible = false;
      },
      runContextAction: function (item) {
        var target = this.contextMenu.targetId || "",
          targetKey = this.contextMenu.targetKey || "";
        if (!item || item.separator || item.disabled) return;
        if (item.key === "menu") {
          this.menuOpen = true;
          this.closeContextMenu("menu");
          this.persistUiState("context-menu");
          this.focusStartSearch();
          return;
        }
        if (item.key === "refresh") {
          this.closeContextMenu("refresh");
          this.refreshView();
          return;
        }
        if (item.key === "newFolder") {
          this.createCustomFolder();
          return;
        }
        if (item.key === "openEntry" && targetKey) {
          this.closeContextMenu("open-entry");
          this.launchApp(targetKey);
          return;
        }
        if (item.key === "deleteFolder" && targetKey) {
          this.closeContextMenu("delete-folder");
          this.deleteCustomFolder(targetKey);
          return;
        }
        if (item.key === "runDialog") {
          this.closeContextMenu("run-dialog");
          this.openDialog("run");
          return;
        }
        if (item.key === "aboutDialog") {
          this.closeContextMenu("about-dialog");
          this.openDialog("about");
          return;
        }
        if (item.key === "powerDialog") {
          this.closeContextMenu("power-dialog");
          this.openDialog("power");
          return;
        }
        if (
          item.key === "tile" ||
          item.key === "cascade" ||
          item.key === "minimizeAll" ||
          item.key === "restoreAll" ||
          item.key === "focusTerminal"
        ) {
          this.closeContextMenu(item.key);
          this.runShellAction(item.key);
          return;
        }
        if (item.key.indexOf("task.toggle.") === 0) {
          this.closeContextMenu(item.key);
          this.toggleTaskWindow(item.key.split(".").slice(2).join("."));
          return;
        }
        if (item.key.indexOf("launch.") === 0) {
          this.closeContextMenu(item.key);
          this.launchApp(item.key.split(".").slice(1).join("."));
          return;
        }
        if (target) {
          if (item.key === "restore") {
            this.restoreWindow(target);
            this.closeContextMenu("restore");
            return;
          }
          if (item.key === "minimize") {
            this.minimizeWindow(target);
            this.closeContextMenu("minimize");
            return;
          }
          if (item.key === "maximize") {
            this.toggleMaximize(target);
            this.closeContextMenu("maximize");
            return;
          }
          if (item.key === "close") {
            this.closeWindow(target);
            this.closeContextMenu("close");
            return;
          }
        }
        this.closeContextMenu("done");
      },
      runShellAction: function (actionKey) {
        this.lastCommandName = "shell." + actionKey;
        this.persistUiState("shell-action");
        if (actionKey === "tile") return this.tileWindows();
        if (actionKey === "cascade") return this.cascadeWindows();
        if (actionKey === "minimizeAll") return this.minimizeAllWindows();
        if (actionKey === "restoreAll") return this.restoreAllWindows();
        if (actionKey === "focusTerminal") return this.focusTerminalWindow();
        if (actionKey === "focusNext") return this.focusWindowByIndex(1);
        if (actionKey === "focusPrev") return this.focusWindowByIndex(-1);
        if (actionKey === "runDialog") return this.openDialog("run");
        if (actionKey === "aboutDialog") return this.openDialog("about");
        if (actionKey === "powerDialog") return this.openDialog("power");
      },
      visibleWindows: function () {
        return this.windows.filter(function (w) {
          return !w.closed;
        });
      },
      tileWindows: function () {
        if (this.isCompactViewport) {
          this.layoutMode = "stack";
          this.saveLayout();
          return;
        }
        var wins = this.windows.filter(function (w) {
          return !w.closed;
        });
        if (!wins.length) return;
        var rect = this.stageRect(),
          cols = Math.ceil(Math.sqrt(wins.length)),
          rows = Math.ceil(wins.length / cols),
          gutter = 12,
          cellW = Math.max(
            360,
            Math.floor((rect.width - (cols - 1) * gutter) / cols),
          ),
          cellH = Math.max(
            240,
            Math.floor((rect.height - (rows - 1) * gutter) / rows),
          );
        wins.forEach(function (win, idx) {
          var col = idx % cols,
            row = Math.floor(idx / cols);
          win.minimized = false;
          win.maximized = false;
          win.snap = "grid";
          win.left = (cellW + gutter) * col;
          win.top = (cellH + gutter) * row;
          win.width =
            col === cols - 1 ? Math.max(360, rect.width - win.left) : cellW;
          win.height =
            row === rows - 1 ? Math.max(240, rect.height - win.top) : cellH;
        });
        this.layoutMode = "tile";
        this.focusWindow(wins[0].id);
        this.saveLayout();
      },
      cascadeWindows: function () {
        if (this.isCompactViewport) {
          this.layoutMode = "stack";
          this.saveLayout();
          return;
        }
        var wins = this.windows.filter(function (w) {
          return !w.closed;
        });
        if (!wins.length) return;
        var rect = this.stageRect(),
          offsetX = 28,
          offsetY = 24,
          width = Math.max(560, Math.floor(rect.width * 0.72)),
          height = Math.max(360, Math.floor(rect.height * 0.72));
        wins.forEach(function (win, idx) {
          win.minimized = false;
          win.maximized = false;
          win.snap = "cascade";
          win.left = Math.min(
            idx * offsetX,
            Math.max(0, rect.width - width - 20),
          );
          win.top = Math.min(
            idx * offsetY,
            Math.max(0, rect.height - height - 20),
          );
          win.width = width;
          win.height = height;
        });
        this.layoutMode = "cascade";
        this.focusWindow(wins[wins.length - 1].id);
        this.saveLayout();
      },
      minimizeAllWindows: function () {
        this.windows.forEach(function (win) {
          if (!win.closed) win.minimized = true;
        });
        this.layoutMode = "";
        this.activeWindowId = "";
        this.saveLayout();
        this.persistUiState("minimize-all");
      },
      restoreAllWindows: function () {
        var self = this;
        this.windows.forEach(function (win) {
          if (!win.closed) win.minimized = false;
          if (win.snap === "grid" || win.snap === "cascade") win.snap = "";
          self.clampWindow(win);
        });
        this.layoutMode = "";
        if (this.windows.length) this.focusWindow(this.windows[0].id);
        this.saveLayout();
        this.persistUiState("restore-all");
      },
      focusTerminalWindow: function () {
        var win = this.latestOpenTerminalWindow();
        this.lastCommandName = "shell.focusTerminal";
        if (win) {
          win.closed = false;
          win.minimized = false;
          this.focusWindow(win.id);
          return;
        }
        this.launchApp("terminal");
      },
      focusWindowByIndex: function (step) {
        var wins = this.taskWindows.filter(function (win) {
          return !win.minimized && !win.closed;
        });
        if (!wins.length) return;
        var idx = wins.findIndex(function (win) {
          return win.id === this.activeWindowId;
        }, this);
        if (idx < 0) idx = 0;
        idx = (idx + step + wins.length) % wins.length;
        this.focusWindow(wins[idx].id);
      },
      onGlobalKeydown: function (ev) {
        if (
          (ev.ctrlKey && ev.key === "Escape") ||
          (!ev.ctrlKey && !ev.altKey && !ev.shiftKey && ev.key === "Meta")
        ) {
          ev.preventDefault();
          this.toggleMenu();
          return;
        }
        if (
          ev.altKey &&
          !ev.shiftKey &&
          !ev.ctrlKey &&
          (ev.key === "m" || ev.key === "M")
        ) {
          ev.preventDefault();
          this.toggleMenu();
          return;
        }
        if (
          ev.altKey &&
          !ev.shiftKey &&
          !ev.ctrlKey &&
          (ev.key === "g" || ev.key === "G")
        ) {
          ev.preventDefault();
          this.tileWindows();
          return;
        }
        if (
          ev.altKey &&
          !ev.shiftKey &&
          !ev.ctrlKey &&
          (ev.key === "c" || ev.key === "C")
        ) {
          ev.preventDefault();
          this.cascadeWindows();
          return;
        }
        if (
          ev.altKey &&
          !ev.shiftKey &&
          !ev.ctrlKey &&
          (ev.key === "n" || ev.key === "N")
        ) {
          ev.preventDefault();
          this.minimizeAllWindows();
          return;
        }
        if (
          ev.altKey &&
          !ev.shiftKey &&
          !ev.ctrlKey &&
          (ev.key === "r" || ev.key === "R")
        ) {
          ev.preventDefault();
          this.restoreAllWindows();
          return;
        }
        if (
          ev.altKey &&
          !ev.shiftKey &&
          !ev.ctrlKey &&
          (ev.key === "t" || ev.key === "T")
        ) {
          ev.preventDefault();
          this.focusTerminalWindow();
          return;
        }
        if (
          this.menuOpen &&
          !ev.altKey &&
          !ev.ctrlKey &&
          (ev.key === "ArrowRight" || ev.key === "ArrowDown")
        ) {
          ev.preventDefault();
          this.cycleStartSection(1);
          return;
        }
        if (
          this.menuOpen &&
          !ev.altKey &&
          !ev.ctrlKey &&
          (ev.key === "ArrowLeft" || ev.key === "ArrowUp")
        ) {
          ev.preventDefault();
          this.cycleStartSection(-1);
          return;
        }
        if (this.menuOpen && ev.key === "Enter" && this.normalizedStartSearch) {
          ev.preventDefault();
          this.executeStartSearch();
          return;
        }
        if (ev.key === "Escape" && this.anyDialogOpen) {
          ev.preventDefault();
          this.closeDialogs();
          return;
        }
        if (ev.key === "Escape" && this.contextMenu.visible) {
          ev.preventDefault();
          this.closeContextMenu("escape");
          return;
        }
        if (ev.key === "Escape" && this.menuOpen && this.startSearch) {
          ev.preventDefault();
          this.clearStartSearch();
          return;
        }
        if (ev.key === "Escape" && this.menuOpen) {
          ev.preventDefault();
          this.menuOpen = false;
          this.saveUiStateLocal();
          return;
        }
        if (ev.altKey && !ev.ctrlKey && /^[1-9]$/.test(ev.key)) {
          ev.preventDefault();
          var idx = parseInt(ev.key, 10) - 1;
          if (this.taskWindows[idx])
            this.toggleTaskWindow(this.taskWindows[idx].id);
        }
      },
      windowClassMap: function (win) {
        return {
          "is-active":
            this.activeWindowId === win.id && !win.minimized && !win.closed,
          "is-minimized": !!win.minimized,
          "is-closed": !!win.closed,
          "is-maximized": !!win.maximized,
          "is-tiled": (win.snap || "") === "grid",
          "is-cascaded": (win.snap || "") === "cascade",
        };
      },
      windowStyle: function (win) {
        if (this.isCompactViewport)
          return {
            left: "0px",
            top: "0px",
            width: "100%",
            height: "auto",
            zIndex: win.z,
          };
        return {
          left: win.left + "px",
          top: win.top + "px",
          width: win.width + "px",
          height: win.height + "px",
          zIndex: win.z,
        };
      },
      stageRect: function () {
        var stage = this.$refs.stage;
        return stage
          ? stage.getBoundingClientRect()
          : {
              left: 0,
              top: 0,
              width: window.innerWidth - 20,
              height: window.innerHeight - 64,
              right: window.innerWidth - 20,
              bottom: window.innerHeight - 64,
            };
      },
      clampWindow: function (win) {
        if (this.isCompactViewport) return;
        var rect = this.stageRect();
        win.left = Math.max(
          0,
          Math.min(win.left, Math.max(0, rect.width - 240)),
        );
        win.top = Math.max(0, Math.min(win.top, Math.max(0, rect.height - 70)));
        win.width = Math.max(340, Math.min(win.width, rect.width));
        win.height = Math.max(220, Math.min(win.height, rect.height));
      },
      beginDrag: function (win, ev) {
        if (
          this.isCompactViewport ||
          ev.target.closest("[data-window-action]") ||
          win.maximized
        )
          return;
        this.focusWindow(win.id);
        var startX = ev.clientX,
          startY = ev.clientY,
          base = { left: win.left, top: win.top },
          self = this;
        function move(mev) {
          win.left = base.left + (mev.clientX - startX);
          win.top = base.top + (mev.clientY - startY);
          self.clampWindow(win);
          self.updateSnapPreview(mev.clientX, mev.clientY);
        }
        function up(uev) {
          window.removeEventListener("pointermove", move);
          window.removeEventListener("pointerup", up);
          window.removeEventListener("pointercancel", up);
          self.commitSnapFromPointer(win.id, uev.clientX, uev.clientY);
          self.snapPreview.visible = false;
          self.saveLayout();
        }
        window.addEventListener("pointermove", move);
        window.addEventListener("pointerup", up);
        window.addEventListener("pointercancel", up);
      },
      beginResize: function (win, edge, ev) {
        if (this.isCompactViewport || win.maximized) return;
        this.focusWindow(win.id);
        var sx = ev.clientX,
          sy = ev.clientY,
          start = {
            left: win.left,
            top: win.top,
            width: win.width,
            height: win.height,
          },
          self = this;
        function move(mev) {
          var dx = mev.clientX - sx,
            dy = mev.clientY - sy;
          if (edge.indexOf("e") > -1)
            win.width = Math.max(340, start.width + dx);
          if (edge.indexOf("s") > -1)
            win.height = Math.max(220, start.height + dy);
          if (edge.indexOf("w") > -1) {
            win.left = start.left + dx;
            win.width = Math.max(340, start.width - dx);
            if (win.width === 340) win.left = start.left + (start.width - 340);
          }
          if (edge.indexOf("n") > -1) {
            win.top = start.top + dy;
            win.height = Math.max(220, start.height - dy);
            if (win.height === 220) win.top = start.top + (start.height - 220);
          }
          self.clampWindow(win);
        }
        function up() {
          window.removeEventListener("pointermove", move);
          window.removeEventListener("pointerup", up);
          window.removeEventListener("pointercancel", up);
          self.saveLayout();
        }
        window.addEventListener("pointermove", move);
        window.addEventListener("pointerup", up);
        window.addEventListener("pointercancel", up);
      },
      toggleMaximize: function (id) {
        var win = this.windows.find(function (w) {
          return w.id === id;
        });
        if (!win || this.isCompactViewport) return;
        if (!win.maximized) {
          win.restoreRect = {
            left: win.left,
            top: win.top,
            width: win.width,
            height: win.height,
            snap: win.snap || "",
          };
          this.applySnap(id, "maximize");
        } else {
          if (win.restoreRect) {
            win.left = win.restoreRect.left;
            win.top = win.restoreRect.top;
            win.width = win.restoreRect.width;
            win.height = win.restoreRect.height;
          }
          win.maximized = false;
          win.snap = "";
        }
        this.saveLayout();
      },
      snapCandidateForPointer: function (x, y) {
        var stage = this.stageRect(),
          m = 18,
          kind = "";
        if (y <= stage.top + m) return "maximize";
        if (this.settingsForm.snapMode === "off") return "";
        if (x <= stage.left + m) {
          if (
            (this.settingsForm.snapMode === "quadrant" ||
              this.settingsForm.snapMode === "grid") &&
            y <= stage.top + Math.floor(stage.height / 2)
          )
            return "top-left";
          if (
            (this.settingsForm.snapMode === "quadrant" ||
              this.settingsForm.snapMode === "grid") &&
            y >= stage.top + Math.floor(stage.height * 0.68)
          )
            return "bottom-left";
          return "left";
        }
        if (x >= stage.right - m) {
          if (
            (this.settingsForm.snapMode === "quadrant" ||
              this.settingsForm.snapMode === "grid") &&
            y <= stage.top + Math.floor(stage.height / 2)
          )
            return "top-right";
          if (
            (this.settingsForm.snapMode === "quadrant" ||
              this.settingsForm.snapMode === "grid") &&
            y >= stage.top + Math.floor(stage.height * 0.68)
          )
            return "bottom-right";
          return "right";
        }
        return kind;
      },
      updateSnapPreview: function (x, y) {
        var stage = this.stageRect(),
          kind = this.snapCandidateForPointer(x, y),
          p = { visible: false, left: 0, top: 0, width: 0, height: 0 };
        if (kind === "maximize")
          p = {
            visible: true,
            left: 0,
            top: 0,
            width: stage.width,
            height: stage.height,
          };
        else if (kind === "left")
          p = {
            visible: true,
            left: 0,
            top: 0,
            width: Math.floor(stage.width / 2),
            height: stage.height,
          };
        else if (kind === "right")
          p = {
            visible: true,
            left: Math.ceil(stage.width / 2),
            top: 0,
            width: Math.floor(stage.width / 2),
            height: stage.height,
          };
        else if (kind === "top-left")
          p = {
            visible: true,
            left: 0,
            top: 0,
            width: Math.floor(stage.width / 2),
            height: Math.floor(stage.height / 2),
          };
        else if (kind === "top-right")
          p = {
            visible: true,
            left: Math.ceil(stage.width / 2),
            top: 0,
            width: Math.floor(stage.width / 2),
            height: Math.floor(stage.height / 2),
          };
        else if (kind === "bottom-left")
          p = {
            visible: true,
            left: 0,
            top: Math.ceil(stage.height / 2),
            width: Math.floor(stage.width / 2),
            height: Math.floor(stage.height / 2),
          };
        else if (kind === "bottom-right")
          p = {
            visible: true,
            left: Math.ceil(stage.width / 2),
            top: Math.ceil(stage.height / 2),
            width: Math.floor(stage.width / 2),
            height: Math.floor(stage.height / 2),
          };
        this.snapPreview = p;
      },
      commitSnapFromPointer: function (id, x, y) {
        var kind = this.snapCandidateForPointer(x, y);
        if (kind) return this.applySnap(id, kind);
      },
      applySnap: function (id, kind) {
        var win = this.windows.find(function (w) {
          return w.id === id;
        });
        if (!win) return;
        if (!win.restoreRect)
          win.restoreRect = {
            left: win.left,
            top: win.top,
            width: win.width,
            height: win.height,
            snap: win.snap || "",
          };
        var stage = this.stageRect(),
          halfW = Math.floor(stage.width / 2),
          halfH = Math.floor(stage.height / 2);
        if (kind === "maximize") {
          win.left = 0;
          win.top = 0;
          win.width = stage.width;
          win.height = stage.height;
          win.maximized = true;
          win.snap = "maximize";
        } else if (kind === "left") {
          win.left = 0;
          win.top = 0;
          win.width = halfW;
          win.height = stage.height;
          win.maximized = false;
          win.snap = "left";
        } else if (kind === "right") {
          win.left = Math.ceil(stage.width / 2);
          win.top = 0;
          win.width = halfW;
          win.height = stage.height;
          win.maximized = false;
          win.snap = "right";
        } else if (kind === "top-left") {
          win.left = 0;
          win.top = 0;
          win.width = halfW;
          win.height = halfH;
          win.maximized = false;
          win.snap = "top-left";
        } else if (kind === "top-right") {
          win.left = Math.ceil(stage.width / 2);
          win.top = 0;
          win.width = halfW;
          win.height = halfH;
          win.maximized = false;
          win.snap = "top-right";
        } else if (kind === "bottom-left") {
          win.left = 0;
          win.top = Math.ceil(stage.height / 2);
          win.width = halfW;
          win.height = halfH;
          win.maximized = false;
          win.snap = "bottom-left";
        } else if (kind === "bottom-right") {
          win.left = Math.ceil(stage.width / 2);
          win.top = Math.ceil(stage.height / 2);
          win.width = halfW;
          win.height = halfH;
          win.maximized = false;
          win.snap = "bottom-right";
        }
      },
      serializeLayout: function () {
        return {
          version: "roi37",
          mode: this.layoutMode || "",
          entryPositions: this.desktopIconPositions,
          explorerPrefs: this.explorerPrefs,
          explorerIconPositions: this.explorerIconPositions,
          vfsLocations: this.vfsLocationOverrides,
          explorerLinks: this.explorerLinks,
          customFolders: this.customFolders.map(function (entry) {
            return {
              key: entry.key,
              title: entry.title,
              subtitle: entry.subtitle,
              icon: entry.icon,
              badge: entry.badge,
              kind: entry.kind,
              group: entry.group,
              order: entry.order,
              desktopOrder: entry.desktopOrder,
              launchKey: entry.launchKey,
              desktopPinned: !!entry.desktopPinned,
              status: entry.status,
              summary: entry.summary,
            };
          }),
          dialogs: this.dialogPositions,
          windows: this.windows.map(function (w) {
            return {
              id: w.id,
              appKey: w.appKey,
              left: w.left,
              top: w.top,
              width: w.width,
              height: w.height,
              z: w.z,
              taskOrder: w.taskOrder || 0,
              minimized: !!w.minimized,
              closed: !!w.closed,
              maximized: !!w.maximized,
              snap: w.snap || "",
            };
          }),
        };
      },
      parseLayoutRaw: function (raw) {
        if (!raw) return null;
        try {
          return JSON.parse(raw);
        } catch (e) {
          return null;
        }
      },
      applySavedLayout: function (layout) {
        var self = this;
        if (!layout || typeof layout !== "object") return;
        if (layout.mode) this.layoutMode = layout.mode;
        if (layout.entryPositions && typeof layout.entryPositions === "object")
          this.desktopIconPositions = Object.assign(
            {},
            this.desktopIconPositions,
            layout.entryPositions,
          );
        if (layout.explorerPrefs && typeof layout.explorerPrefs === "object")
          this.explorerPrefs = Object.assign(
            {},
            this.explorerPrefs,
            layout.explorerPrefs,
          );
        if (
          layout.explorerIconPositions &&
          typeof layout.explorerIconPositions === "object"
        )
          this.explorerIconPositions = Object.assign(
            {},
            this.explorerIconPositions,
            layout.explorerIconPositions,
          );
        if (layout.vfsLocations && typeof layout.vfsLocations === "object")
          this.vfsLocationOverrides = Object.assign(
            {},
            this.vfsLocationOverrides,
            layout.vfsLocations,
          );
        if (Array.isArray(layout.explorerLinks))
          this.explorerLinks = layout.explorerLinks.slice(0);
        if (Array.isArray(layout.customFolders)) {
          this.customFolders = layout.customFolders.map(function (entry, idx) {
            return {
              key: entry.key || "folder-" + (idx + 1),
              title: entry.title || "Folder",
              subtitle: entry.subtitle || "Desktop folder",
              icon: entry.icon || "DIR",
              badge: entry.badge || "Folder",
              kind: "directory",
              group: entry.group || "Directories",
              order: Number(entry.order || 200 + idx),
              desktopOrder: Number(
                entry.desktopOrder || entry.order || 200 + idx,
              ),
              launchKey: entry.launchKey || entry.key || "folder-" + (idx + 1),
              desktopPinned: entry.desktopPinned !== false,
              status: entry.status || "available",
              summary: entry.summary || "Folder",
            };
          });
          this.folderSequence = this.customFolders.reduce(function (
            max,
            entry,
          ) {
            var n = parseInt(
              String(entry.key || "")
                .split("-")
                .pop(),
              10,
            );
            return isFinite(n) ? Math.max(max, n) : max;
          }, 0);
        }
        if (layout.dialogs && typeof layout.dialogs === "object") {
          ["run", "about", "power"].forEach(function (kind) {
            if (layout.dialogs[kind])
              self.dialogPositions[kind] = {
                left: Number(layout.dialogs[kind].left || 0),
                top: Number(layout.dialogs[kind].top || 0),
              };
          });
        }
        arr(layout.windows).forEach(function (saved) {
          var win = self.windows.find(function (w) {
            return w.id === saved.id;
          });
          if (!win) return;
          Object.assign(win, {
            left: Number(saved.left || win.left),
            top: Number(saved.top || win.top),
            width: Number(saved.width || win.width),
            height: Number(saved.height || win.height),
            z: Number(saved.z || win.z),
            taskOrder: Number(saved.taskOrder || win.taskOrder || 0),
            minimized: !!saved.minimized,
            closed: !!saved.closed,
            maximized: !!saved.maximized,
            snap: saved.snap || "",
          });
          self.clampWindow(win);
        });
        this.normalizeTaskOrder();
        this.normalizeDesktopIconPositions();
      },
      loadLayoutLocal: function () {
        var key = "miomos.layout." + (this.boot.session || {}).id,
          raw = "";
        this.applySavedLayout(
          this.parseLayoutRaw((this.boot.desktop || {}).savedLayoutJson || ""),
        );
        try {
          raw = window.localStorage.getItem(key) || "";
        } catch (e) {}
        this.applySavedLayout(this.parseLayoutRaw(raw));
      },
      saveLayoutLocal: function () {
        var key = "miomos.layout." + (this.boot.session || {}).id;
        try {
          window.localStorage.setItem(
            key,
            JSON.stringify(this.serializeLayout()),
          );
        } catch (e) {}
      },
      saveLayout: function () {
        this.saveLayoutLocal();
        this.command("layout.save", { layout: this.serializeLayout() }).catch(
          function () {},
        );
      },
      onWindowResize: function () {
        var self = this;
        if (this.isCompactViewport) {
          this.windows.forEach(function (win) {
            if (win.appKey === "terminal" && !win.closed)
              self.resizeTerminal(win.id);
          });
          return;
        }
        this.windows.forEach(function (w) {
          if (
            [
              "left",
              "right",
              "maximize",
              "top-left",
              "top-right",
              "bottom-left",
              "bottom-right",
            ].indexOf(w.snap || "") > -1 ||
            w.maximized
          )
            self.applySnap(w.id, w.snap || "maximize");
          else self.clampWindow(w);
        });
        if (this.layoutMode === "tile") this.tileWindows();
        this.windows.forEach(function (win) {
          if (win.appKey === "terminal" && !win.closed)
            self.resizeTerminal(win.id);
        });
      },
      ensureSocketReady: function () {
        var self = this,
          timeoutMs =
            Number(this.desktopPolicy.commandTimeoutMs || 8000) || 8000;
        if (this.socket && this.socket.readyState === 1)
          return Promise.resolve(true);
        this.connectSocket();
        return new Promise(function (resolve, reject) {
          var stopAt = Date.now() + timeoutMs;
          (function waitForSocket() {
            if (self.socket && self.socket.readyState === 1)
              return resolve(true);
            if (Date.now() >= stopAt)
              return reject(new Error("socket_timeout"));
            window.setTimeout(waitForSocket, 75);
          })();
        });
      },
      socketRequest: function (event, payload, options) {
        var self = this,
          opts = options || {},
          maxInflight = Number(this.desktopPolicy.commandMaxInflight || 3) || 3,
          timeoutMs =
            Number(
              opts.timeoutMs || this.desktopPolicy.commandTimeoutMs || 8000,
            ) || 8000,
          label = String(opts.command || event || "socket.request"),
          key = opts.dedupeKey || label + "|" + JSON.stringify(payload || {});
        if (this.pendingCommands[key]) return this.pendingCommands[key];
        if (this.inflightCommandCount >= maxInflight) {
          this.commandError =
            "Another shell command is still in flight. Please wait for it to finish before submitting a new action.";
          return Promise.reject(new Error("command_busy"));
        }
        this.commandError = "";
        this.dismissedAlertKey = "";
        this.lastCommandName = label;
        this.saveUiStateLocal();
        this.inflightCommandCount += 1;
        var requestId = "ws-" + ++this.socketRequestSeq + "-" + Date.now();
        var req = this.ensureSocketReady()
          .then(function () {
            return new Promise(function (resolve, reject) {
              var pending = {
                key: key,
                command: label,
                timer: null,
                resolve: function (msg) {
                  if (pending.timer) window.clearTimeout(pending.timer);
                  delete self.socketPending[requestId];
                  resolve(msg);
                },
                reject: function (err) {
                  if (pending.timer) window.clearTimeout(pending.timer);
                  delete self.socketPending[requestId];
                  reject(err);
                },
              };
              pending.timer = window.setTimeout(function () {
                pending.reject(new Error("socket_request_timeout"));
              }, timeoutMs);
              self.socketPending[requestId] = pending;
              if (
                !self.sendSocket(
                  Object.assign(
                    {
                      event: event,
                      requestId: requestId,
                      sessionId:
                        (self.boot.session || {}).id ||
                        root.getAttribute("data-miomos-session") ||
                        "",
                    },
                    payload || {},
                  ),
                )
              ) {
                pending.reject(new Error("socket_send_failed"));
              }
            });
          })
          .catch(function (err) {
            self.commandError =
              "Command " +
              label +
              " failed: " +
              (err && err.message ? err.message : "unknown error");
            self.dismissedAlertKey = "";
            throw err;
          })
          .finally(function () {
            self.inflightCommandCount = Math.max(
              0,
              self.inflightCommandCount - 1,
            );
            delete self.pendingCommands[key];
            self.saveUiStateLocal();
          });
        this.pendingCommands[key] = req;
        return req;
      },
      command: function (command, payload) {
        var eventName =
          (this.boot.routes || {}).commandEvent ||
          root.getAttribute("data-miomos-command-event") ||
          "command.exec";
        var body = Object.assign({ command: command }, payload || {});
        var key = command + "|" + JSON.stringify(body);
        return this.socketRequest(eventName, body, {
          dedupeKey: key,
          command: command,
        });
      },
      refreshView: function () {
        var self = this;
        return this.command("view.refresh", {})
          .then(function (json) {
            if (json.view) self.view = json.view;
            self.syncSettingsForm();
            self.applySettings();
            self.commandError = "";
            return json;
          })
          .catch(function (err) {
            self.commandError =
              "View refresh failed: " +
              (err && err.message ? err.message : "unknown error");
            self.dismissedAlertKey = "";
            throw err;
          });
      },
      syncSettingsForm: function () {
        var cur = (this.view.settings || {}).current || {};
        this.settingsForm.themeKey = cur.themeKey || this.settingsForm.themeKey;
        this.settingsForm.fontFamily =
          cur.fontFamily || this.settingsForm.fontFamily;
        this.settingsForm.fontSize = String(
          cur.fontSize || this.settingsForm.fontSize,
        );
        this.settingsForm.titleAccent =
          cur.titleAccent || this.settingsForm.titleAccent;
        this.settingsForm.iconStyle =
          cur.iconStyle || this.settingsForm.iconStyle;
        this.settingsForm.wallpaper =
          cur.wallpaper || this.settingsForm.wallpaper;
        this.settingsForm.density = cur.density || this.settingsForm.density;
        this.settingsForm.animations =
          cur.animations || this.settingsForm.animations;
        this.settingsForm.windowPreset =
          cur.windowPreset || this.settingsForm.windowPreset;
        this.settingsForm.snapMode = cur.snapMode || this.settingsForm.snapMode;
        this.settingsForm.motionProfile =
          cur.motionProfile || this.settingsForm.motionProfile;
        this.settingsForm.titlebarStyle =
          cur.titlebarStyle || this.settingsForm.titlebarStyle;
        this.settingsForm.icons = Object.assign(
          {},
          this.settingsForm.icons,
          cur.icon || {},
        );
        if (cur.terminal) {
          var self = this;
          Object.keys(cur.terminal).forEach(function (k) {
            self.settingsForm.terminal[k] = String(cur.terminal[k]);
          });
        }
      },
      buildSettingsPayload: function () {
        return {
          themeKey: this.settingsForm.themeKey,
          fontFamily: this.settingsForm.fontFamily,
          fontSize: parseInt(this.settingsForm.fontSize, 10),
          titleAccent: this.settingsForm.titleAccent,
          iconStyle: this.settingsForm.iconStyle,
          wallpaper: this.settingsForm.wallpaper,
          density: this.settingsForm.density,
          animations: this.settingsForm.animations,
          windowPreset: this.settingsForm.windowPreset,
          snapMode: this.settingsForm.snapMode,
          motionProfile: this.settingsForm.motionProfile,
          titlebarStyle: this.settingsForm.titlebarStyle,
          icons: clone(this.settingsForm.icons),
          terminal: {
            fontFamily: this.settingsForm.terminal.fontFamily,
            fontSize: parseInt(this.settingsForm.terminal.fontSize, 10),
            cursorBlink: parseInt(this.settingsForm.terminal.cursorBlink, 10),
            cursorStyle: this.settingsForm.terminal.cursorStyle,
            palette: this.settingsForm.terminal.palette,
            scrollback: parseInt(this.settingsForm.terminal.scrollback, 10),
            renderer: this.settingsForm.terminal.renderer,
            sizeMode: this.settingsForm.terminal.sizeMode,
            unicode: this.settingsForm.terminal.unicode,
            cols: parseInt(this.settingsForm.terminal.cols || "120", 10),
            rows: parseInt(this.settingsForm.terminal.rows || "28", 10),
          },
        };
      },
      saveSettings: function () {
        var self = this;
        this.settingsStatus = "Saving…";
        this.command("settings.save", this.buildSettingsPayload())
          .then(function () {
            self.settingsStatus = "Saved";
            self.refreshView().catch(function () {});
          })
          .catch(function () {
            self.settingsStatus = "Save failed";
          });
      },
      hasExternalFiles: function (ev) {
        var dt = (ev && ev.dataTransfer) || null,
          types,
          i;
        if (!dt) return false;
        if (dt.files && dt.files.length) return true;
        types = dt.types || [];
        for (i = 0; i < types.length; i += 1) {
          if (String(types[i]) === "Files") return true;
        }
        return false;
      },
      ensureBootVfsEntries: function () {
        var desktop = (this.boot || {}).desktop || {},
          vfs = desktop.vfs || (desktop.vfs = {}),
          list = arr(vfs.entries).slice(0);
        if (!Array.isArray(vfs.entries)) vfs.entries = list;
        return vfs.entries;
      },
      mergeVfsEntry: function (entry) {
        var entries = this.ensureBootVfsEntries(),
          key = String((entry || {}).key || ""),
          idx = -1;
        if (!key) return;
        idx = entries.findIndex(function (row) {
          return String((row || {}).key || "") === key;
        });
        if (idx >= 0) entries.splice(idx, 1, entry);
        else entries.push(entry);
        if (this.boot && this.boot.desktop)
          this.boot.desktop = Object.assign({}, this.boot.desktop, {
            vfs: Object.assign({}, this.boot.desktop.vfs || {}, {
              entries: entries,
            }),
          });
        this.boot = Object.assign({}, this.boot);
      },
      downloadVfsEntry: function (item) {
        var route =
            (this.boot.routes || {}).vfsDownload || "/api/miomos/vfs/download",
          key = encodeURIComponent(String((item || {}).key || ""));
        if (!key) return;
        window.location.href = route + "?key=" + key;
        this.lastCommandName = "vfs.download";
        this.persistUiState("vfs-download");
      },
      canUploadToFolderKey: function (folderKey) {
        var key = String(folderKey || "");
        if (!key || key === "desktop") return false;
        if (key.indexOf("folder-") === 0) return true;
        return arr((((this.boot || {}).desktop || {}).vfs || {}).entries).some(
          function (row) {
            return (
              String((row || {}).key || "") === key &&
              String((row || {}).kind || "") === "directory" &&
              !!Number((row || {}).uploadAllowed || 0)
            );
          },
        );
      },
      inferDropTarget: function (ev, explicitKey, explicitTitle) {
        var target;
        if (explicitKey)
          return {
            key: String(explicitKey || ""),
            title: String(explicitTitle || "Folder"),
          };
        target = this.shellDropMetaFromElement(
          ev && ev.target
            ? ev.target
            : document.elementFromPoint(ev.clientX, ev.clientY),
        );
        if (!target) return null;
        if (
          target.kind === "desktop-icon" ||
          target.kind === "explorer-item" ||
          target.kind === "explorer-window"
        )
          return {
            key: String(target.key || ""),
            title: String(target.label || explicitTitle || "Folder"),
          };
        return null;
      },
      beginNativeDropHover: function (ev, folderKey, folderTitle) {
        var target = this.inferDropTarget(ev, folderKey, folderTitle);
        if (!target || !this.canUploadToFolderKey(target.key)) {
          this.endShellDrag();
          return;
        }
        this.shellDrag.active = true;
        this.shellDrag.sourceKind = "external-file";
        this.shellDrag.sourceKey = "";
        this.shellDrag.sourceParentKey = "";
        this.shellDrag.sourceWindowId = "";
        this.shellDrag.operation = "copy";
        this.shellDrag.hoverTargetKind = folderKey
          ? "explorer-window"
          : String(
              (target.key || "").indexOf("folder-") === 0
                ? "desktop-icon"
                : "explorer-window",
            );
        this.shellDrag.hoverTargetKey = target.key;
        this.shellDrag.hoverAllowed = true;
        this.shellDrag.hoverLabel = target.title || "Folder";
        this.shellDrag.clientX = Number((ev && ev.clientX) || 0);
        this.shellDrag.clientY = Number((ev && ev.clientY) || 0);
        this.shellDrag.moved = true;
      },
      clearNativeDropHover: function () {
        if (String(this.shellDrag.sourceKind || "") === "external-file")
          this.endShellDrag();
      },
      uploadFilesToFolder: function (files, folderKey, folderTitle) {
        var self = this,
          route =
            (this.boot.routes || {}).vfsUpload || "/api/miomos/vfs/upload",
          list = Array.prototype.slice.call(files || []);
        if (!list.length || !this.canUploadToFolderKey(folderKey))
          return Promise.resolve([]);
        this.commandError = "";
        return list
          .reduce(function (prev, file) {
            return prev.then(function (acc) {
              var fd = new FormData();
              fd.append("parentKey", String(folderKey || ""));
              fd.append("parentTitle", String(folderTitle || "Folder"));
              fd.append("file", file, file.name || "Upload.bin");
              return fetch(route, {
                method: "POST",
                body: fd,
                credentials: "same-origin",
              })
                .then(function (res) {
                  return res.json().then(function (json) {
                    return { status: res.status, json: json || {} };
                  });
                })
                .then(function (pkt) {
                  var entry = (pkt.json || {}).entry || null,
                    desktop = (self.boot || {}).desktop || {},
                    vfs = desktop.vfs || (desktop.vfs = {});
                  if (pkt.status < 200 || pkt.status > 299 || !entry)
                    throw new Error(
                      (pkt.json || {}).detail ||
                        (pkt.json || {}).error ||
                        "upload_failed",
                    );
                  self.mergeVfsEntry(entry);
                  if (vfs.summary) {
                    vfs.summary.totalFiles =
                      Number(vfs.summary.totalFiles || 0) + 1;
                    vfs.summary.totalBytes =
                      Number(vfs.summary.totalBytes || 0) +
                      Number(entry.sizeBytes || 0);
                  }
                  acc.push(entry);
                  return acc;
                });
            });
          }, Promise.resolve([]))
          .then(function (entries) {
            self.saveLayout();
            self.persistUiState("vfs-upload");
            return entries;
          });
      },
      onNativeDragEnter: function (ev, folderKey, folderTitle) {
        if (!this.hasExternalFiles(ev)) return;
        if (ev && ev.preventDefault) ev.preventDefault();
        this.beginNativeDropHover(ev, folderKey, folderTitle);
      },
      onNativeDragOver: function (ev, folderKey, folderTitle) {
        if (!this.hasExternalFiles(ev)) return;
        if (ev && ev.preventDefault) ev.preventDefault();
        if (ev && ev.dataTransfer) ev.dataTransfer.dropEffect = "copy";
        this.beginNativeDropHover(ev, folderKey, folderTitle);
      },
      onNativeDrop: function (ev, folderKey, folderTitle) {
        var self = this,
          target,
          files = ev && ev.dataTransfer ? ev.dataTransfer.files : null;
        if (!this.hasExternalFiles(ev)) return;
        if (ev && ev.preventDefault) ev.preventDefault();
        target = this.inferDropTarget(ev, folderKey, folderTitle);
        if (!target || !this.canUploadToFolderKey(target.key)) {
          this.commandError = "Drop target does not allow uploads.";
          this.clearNativeDropHover();
          return;
        }
        this.uploadFilesToFolder(files, target.key, target.title)
          .catch(function (err) {
            self.commandError =
              "Upload failed: " +
              (err && err.message ? err.message : "upload_failed");
            self.dismissedAlertKey = "";
          })
          .finally(function () {
            self.clearNativeDropHover();
          });
      },
      quickTheme: function (key) {
        var self = this;
        this.settingsForm.themeKey = key;
        this.command("theme.quick", { themeKey: key })
          .then(function () {
            self.settingsStatus = "Theme updated";
            self.refreshView().catch(function () {});
          })
          .catch(function () {
            self.settingsStatus = "Theme update failed";
          });
      },
      signout: function () {
        var evt =
          (this.boot.routes || {}).signoutEvent ||
          root.getAttribute("data-miomos-signout-event") ||
          "auth.signout";
        return this.socketRequest(
          evt,
          {},
          {
            dedupeKey: "auth.signout",
            command: "auth.signout",
            timeoutMs: 4000,
          },
        ).finally(function () {
          window.location.reload();
        });
      },
      connectSocket: function () {
        var self = this,
          path =
            (this.boot.routes || {}).websocket ||
            root.getAttribute("data-miomos-ws");
        if (!path) return;
        if (this.socketConnecting) return;
        if (
          this.socket &&
          (this.socket.readyState === 0 || this.socket.readyState === 1)
        )
          return;
        var proto = window.location.protocol === "https:" ? "wss://" : "ws://";
        var url = /^wss?:\/\//i.test(path)
          ? path
          : proto + window.location.host + path;
        this.socketConnecting = true;
        try {
          this.socket = new WebSocket(url);
        } catch (e) {
          this.socketConnecting = false;
          this.scheduleReconnect();
          return;
        }
        this.socket.addEventListener("open", function () {
          self.socketConnecting = false;
          self.socketConnected = true;
          self.reconnectDelay =
            Number(self.desktopPolicy.reconnectBaseMs || 1000) || 1000;
          self.markSocketActivity();
          self.sendSocket({
            event: "hello",
            sessionId:
              (self.boot.session || {}).id ||
              root.getAttribute("data-miomos-session"),
          });
          self.startHeartbeat();
          self.startStaleMonitor();
        });
        this.socket.addEventListener("message", function (ev) {
          self.markSocketActivity();
          self.handleSocketMessage(ev.data);
        });
        this.socket.addEventListener("close", function () {
          self.socketConnected = false;
          self.socketConnecting = false;
          self.clearHeartbeat();
          self.clearStaleMonitor();
          self.rejectPendingSocketRequests("socket_closed");
          self.socket = null;
          self.lastReconnectAt = new Date().toISOString();
          self.reconnectCount += 1;
          self.dismissedAlertKey = "";
          if (self.shouldReconnect) self.scheduleReconnect();
        });
        this.socket.addEventListener("error", function () {
          self.socketConnected = false;
          if (self.socket && self.socket.readyState < 2) {
            try {
              self.socket.close();
            } catch (e) {}
          }
        });
      },
      markSocketActivity: function () {
        this.lastSocketAt = Date.now();
      },
      rejectPendingSocketRequests: function (reason) {
        var pending = this.socketPending || {},
          ids = Object.keys(pending),
          message = reason || "socket_closed";
        this.socketPending = {};
        ids.forEach(function (id) {
          try {
            pending[id].reject(new Error(message));
          } catch (e) {}
        });
      },
      sendSocket: function (payload) {
        if (!this.socket || this.socket.readyState !== 1) return false;
        try {
          this.socket.send(JSON.stringify(payload));
          return true;
        } catch (e) {
          return false;
        }
      },
      startHeartbeat: function () {
        var self = this,
          every = Number(this.desktopPolicy.heartbeatMs || 15000) || 15000;
        this.clearHeartbeat();
        this.heartbeatTimer = window.setInterval(function () {
          if (self.socket && self.socket.readyState === 1)
            self.sendSocket({
              event: "ping",
              sessionId:
                (self.boot.session || {}).id ||
                root.getAttribute("data-miomos-session"),
            });
        }, every);
      },
      clearHeartbeat: function () {
        if (this.heartbeatTimer) window.clearInterval(this.heartbeatTimer);
        this.heartbeatTimer = null;
      },
      startStaleMonitor: function () {
        var self = this,
          maxAge = Number(this.desktopPolicy.staleSocketMs || 45000) || 45000,
          every = Math.max(5000, Math.floor(maxAge / 3));
        this.clearStaleMonitor();
        this.staleSocketTimer = window.setInterval(function () {
          if (
            self.socket &&
            self.socket.readyState === 1 &&
            self.lastSocketAt &&
            Date.now() - self.lastSocketAt > maxAge
          ) {
            try {
              self.socket.close();
            } catch (e) {}
          }
        }, every);
      },
      clearStaleMonitor: function () {
        if (this.staleSocketTimer) window.clearInterval(this.staleSocketTimer);
        this.staleSocketTimer = null;
      },
      scheduleReconnect: function () {
        var self = this,
          maxMs = Number(this.desktopPolicy.reconnectMaxMs || 15000) || 15000;
        this.clearReconnectTimer();
        this.reconnectTimer = window.setTimeout(function () {
          self.reconnectTimer = null;
          self.connectSocket();
        }, this.reconnectDelay);
        this.reconnectDelay = Math.min(this.reconnectDelay * 1.6, maxMs);
      },
      clearReconnectTimer: function () {
        if (this.reconnectTimer) window.clearTimeout(this.reconnectTimer);
        this.reconnectTimer = null;
      },
      handleSocketMessage: function (raw) {
        var msg, pending;
        try {
          msg = JSON.parse(raw || "{}");
        } catch (e) {
          return;
        }
        if (msg.requestId && this.socketPending[msg.requestId]) {
          pending = this.socketPending[msg.requestId];
          if (msg.ok === 0 || msg.event === "command.error")
            pending.reject(
              new Error(msg.detail || msg.error || "request_failed"),
            );
          else pending.resolve(msg);
          return;
        }
        if (msg.event === "hello" || msg.event === "pong") {
          this.socketConnected = true;
          this.commandError = "";
          return;
        }
        if (msg.event === "session.signout") {
          this.commandError = msg.detail || msg.reason || "Session signed out.";
          this.terminalStatus = "Session signed out";
          this.shouldReconnect = false;
          this.clearReconnectTimer();
          if (this.socket && this.socket.readyState < 2) {
            try {
              this.socket.close();
            } catch (e) {}
          }
          return;
        }
        if (msg.event === "chat.snapshot") {
          this.messages = arr(msg.messages);
          return;
        }
        if (msg.event === "chat.message") {
          this.messages = this.messages
            .concat([
              msg.message || {
                userName: "System",
                text: "Message received.",
                ts: "Now",
              },
            ])
            .slice(-30);
          return;
        }
      },
      sendChat: function () {
        var text = (this.chatDraft || "").trim();
        if (!text) return;
        this.sendSocket({
          event: "chat.send",
          room: (this.view.chat || {}).room || "general",
          text: text,
          sessionId:
            (this.boot.session || {}).id ||
            root.getAttribute("data-miomos-session"),
        });
        this.chatDraft = "";
      },
      terminalCtor: function () {
        return (
          window.Terminal ||
          (window.Xterm || {}).Terminal ||
          (window.XTerm || {}).Terminal ||
          null
        );
      },
      resolveTerminalViewport: function (winId) {
        if (!winId) winId = this.activeWindowId || "";
        var viewport = document.getElementById(
          "miomosTerminalViewport-" + winId,
        );
        if (!viewport || viewport.nodeType !== 1) return null;
        return viewport;
      },
      resolveTerminalHost: function (winId) {
        if (!winId) winId = this.activeWindowId || "";
        var host = document.getElementById("miomosTerminalHost-" + winId);
        if (!host || host.nodeType !== 1) return null;
        return host;
      },
      clearXtermMountTimer: function (winId) {
        this._xtermMountTimers = this._xtermMountTimers || {};
        if (winId) {
          if (this._xtermMountTimers[winId])
            window.clearTimeout(this._xtermMountTimers[winId]);
          delete this._xtermMountTimers[winId];
          return;
        }
        Object.keys(this._xtermMountTimers).forEach(function (key) {
          window.clearTimeout(this._xtermMountTimers[key]);
        }, this);
        this._xtermMountTimers = {};
      },
      clearXtermMountTimers: function () {
        this.clearXtermMountTimer("");
      },
      scheduleXtermMount: function (winId) {
        var self = this;
        this._xtermMountTimers = this._xtermMountTimers || {};
        this.clearXtermMountTimer(winId);
        this._xtermMountTimers[winId] = window.setTimeout(function () {
          delete self._xtermMountTimers[winId];
          self.ensureXtermMounted(winId);
        }, 60);
      },
      terminalSizingMode: function () {
        return String(
          ((this.settingsForm || {}).terminal || {}).sizeMode ||
            "fit-container",
        );
      },
      computeTerminalGrid: function (winId) {
        var viewport = this.resolveTerminalViewport(winId),
          size =
            parseInt(this.settingsForm.terminal.fontSize || "13", 10) || 13,
          cols = parseInt(this.settingsForm.terminal.cols || "120", 10) || 120,
          rows = parseInt(this.settingsForm.terminal.rows || "28", 10) || 28;
        if (this.terminalSizingMode() !== "fit-container")
          return { cols: cols, rows: rows };
        if (viewport) {
          cols = Math.max(
            80,
            Math.min(
              220,
              Math.floor(
                (viewport.clientWidth - 26) / Math.max(8, size * 0.62),
              ),
            ),
          );
          rows = Math.max(
            20,
            Math.min(
              60,
              Math.floor(
                (viewport.clientHeight - 22) / Math.max(16, size * 1.68),
              ),
            ),
          );
        }
        return { cols: cols, rows: rows };
      },
      buildXtermOptions: function (winId) {
        var grid = this.computeTerminalGrid(winId);
        return {
          fontFamily: String(
            ((this.settingsForm || {}).terminal || {}).fontFamily || "Consolas",
          ),
          fontSize:
            parseInt(
              ((this.settingsForm || {}).terminal || {}).fontSize || "13",
              10,
            ) || 13,
          cursorBlink:
            String(
              ((this.settingsForm || {}).terminal || {}).cursorBlink != null
                ? ((this.settingsForm || {}).terminal || {}).cursorBlink
                : "1",
            ) !== "0",
          cursorStyle: String(
            ((this.settingsForm || {}).terminal || {}).cursorStyle || "block",
          ),
          scrollback:
            parseInt(
              ((this.settingsForm || {}).terminal || {}).scrollback || "3000",
              10,
            ) || 3000,
          cols: grid.cols,
          rows: grid.rows,
          convertEol: true,
          allowTransparency: true,
          theme: clone(
            this.terminalThemeSpec || {
              background: "#0b1220",
              foreground: "#dce9ff",
              cursor: "#dce9ff",
              cursorAccent: "#0b1220",
              selectionBackground: "rgba(143,179,255,0.30)",
            },
          ),
        };
      },
      applyXtermProfile: function (winId) {
        this._xterms = this._xterms || {};
        var xterm = this._xterms[winId];
        if (!xterm) return;
        var opts = this.buildXtermOptions(winId);
        xterm.options.fontFamily = opts.fontFamily;
        xterm.options.fontSize = opts.fontSize;
        xterm.options.cursorBlink = opts.cursorBlink;
        xterm.options.cursorStyle = opts.cursorStyle;
        xterm.options.scrollback = opts.scrollback;
        xterm.options.theme = opts.theme;
        this.resizeXtermClient(winId, opts.cols, opts.rows);
      },
      ensureXtermMounted: function (winId) {
        this._xterms = this._xterms || {};
        var ctor = this.terminalCtor(),
          host = this.resolveTerminalHost(winId),
          self = this,
          state = this.ensureTerminalWindowState(winId);
        if (!host) return;
        if (!ctor) {
          state.loadError = "xterm.js failed to load for this page.";
          this.terminalLoadErrors[winId] = state.loadError;
          return;
        }
        if (!host.clientWidth || !host.clientHeight) {
          this.scheduleXtermMount(winId);
          return;
        }
        state.loadError = "";
        this.terminalLoadErrors[winId] = "";
        if (!this._xterms[winId]) {
          this._xterms[winId] = new ctor(this.buildXtermOptions(winId));
          this._xterms[winId].open(host);
          host.setAttribute("data-xterm-mounted", "1");
          if (this._xterms[winId].onData)
            this._xterms[winId].onData(function (data) {
              self.onXtermData(winId, String(data || ""));
            });
          this.renderXtermTranscript(winId);
        }
        this.applyXtermProfile(winId);
      },
      disposeXterm: function (winId) {
        this._xterms = this._xterms || {};
        var host = this.resolveTerminalHost(winId),
          xterm = this._xterms[winId];
        this.clearXtermMountTimer(winId);
        if (xterm && xterm.dispose) {
          try {
            xterm.dispose();
          } catch (e) {}
        }
        delete this._xterms[winId];
        if (host) host.removeAttribute("data-xterm-mounted");
      },
      disposeAllXterms: function () {
        var self = this;
        this._xterms = this._xterms || {};
        Object.keys(this._xterms).forEach(function (winId) {
          self.disposeXterm(winId);
        });
      },
      focusTerminalInput: function (winId) {
        var xterm;
        this.ensureXtermMounted(winId);
        this._xterms = this._xterms || {};
        xterm = this._xterms[winId];
        if (xterm && xterm.focus) xterm.focus();
      },
      normalizeTerminalChunk: function (chunk) {
        return String(chunk || "")
          .replace(/\r\n/g, "\n")
          .replace(/\r/g, "\n");
      },
      appendTerminalChunk: function (winId, chunk) {
        this._xterms = this._xterms || {};
        var normalized = this.normalizeTerminalChunk(chunk),
          state = this.ensureTerminalWindowState(winId),
          xterm = this._xterms[winId];
        if (!normalized) return;
        var limit =
          parseInt(this.settingsForm.terminal.scrollback || "3000", 10) || 3000;
        var lines = (state.transcript + normalized).split("\n");
        if (lines.length > limit) lines = lines.slice(lines.length - limit);
        state.transcript = lines.join("\n");
        if (xterm && xterm.write) {
          xterm.write(normalized);
          if (xterm.scrollToBottom) xterm.scrollToBottom();
        }
        this.syncActiveTerminalState(winId);
      },
      renderXtermTranscript: function (winId) {
        this._xterms = this._xterms || {};
        var xterm = this._xterms[winId],
          state = this.ensureTerminalWindowState(winId);
        if (!xterm) return;
        xterm.reset();
        if (state.transcript) xterm.write(state.transcript);
        if (state.inputLine) xterm.write(state.inputLine);
        if (xterm.scrollToBottom) xterm.scrollToBottom();
      },
      rewriteTerminalInput: function (winId, nextLine) {
        this._xterms = this._xterms || {};
        var next = String(nextLine || ""),
          xterm = this._xterms[winId],
          state = this.ensureTerminalWindowState(winId);
        if (!xterm) {
          state.inputLine = next;
          this.syncActiveTerminalState(winId);
          return;
        }
        while (state.inputLine.length) {
          xterm.write("\b \b");
          state.inputLine = state.inputLine.slice(0, -1);
        }
        if (next) {
          state.inputLine = next;
          xterm.write(next);
        }
        this.syncActiveTerminalState(winId);
      },
      recallTerminalHistory: function (winId, step) {
        var state = this.ensureTerminalWindowState(winId);
        if (!state.history.length) return;
        if (step < 0) {
          if (state.historyIndex < 0)
            state.historyIndex = state.history.length - 1;
          else if (state.historyIndex > 0) state.historyIndex -= 1;
        } else {
          if (state.historyIndex < 0) return;
          if (state.historyIndex >= state.history.length - 1) {
            state.historyIndex = -1;
            this.rewriteTerminalInput(winId, "");
            return;
          }
          state.historyIndex += 1;
        }
        this.rewriteTerminalInput(
          winId,
          state.history[state.historyIndex] || "",
        );
      },
      onXtermData: function (winId, data) {
        this._xterms = this._xterms || {};
        var i = 0,
          chunk = "",
          xterm = this._xterms[winId],
          state = this.ensureTerminalWindowState(winId);
        if (!data) return;
        while (i < data.length) {
          if (data.slice(i, i + 3) === "\x1b[A") {
            this.recallTerminalHistory(winId, -1);
            i += 3;
            continue;
          }
          if (data.slice(i, i + 3) === "\x1b[B") {
            this.recallTerminalHistory(winId, 1);
            i += 3;
            continue;
          }
          chunk = data.charAt(i);
          if (chunk === "\r") {
            if (xterm) xterm.write("\r\n");
            this.submitTerminalLine(winId, state.inputLine);
            i += 1;
            continue;
          }
          if (chunk === "\u007f") {
            if (state.inputLine.length) {
              state.inputLine = state.inputLine.slice(0, -1);
              if (xterm) xterm.write("\b \b");
            }
            i += 1;
            continue;
          }
          if (chunk === "\u0003") {
            state.inputLine = "";
            if (xterm) xterm.write("^C\r\n");
            state.transcript = (state.transcript || "") + "^C\n";
            i += 1;
            continue;
          }
          if (chunk === "\u000c") {
            this.sendTerminalControl(winId, "clear");
            i += 1;
            continue;
          }
          if (chunk < " ") {
            i += 1;
            continue;
          }
          state.inputLine += chunk;
          if (xterm) xterm.write(chunk);
          i += 1;
        }
        this.syncActiveTerminalState(winId);
      },
      startTerminalPolling: function () {
        var self = this;
        if (this.terminalPollTimer) return;
        this.terminalPollTimer = window.setInterval(function () {
          self.windows.forEach(function (win) {
            var state;
            if (win.appKey !== "terminal" || win.closed) return;
            state = self.terminalWindows[win.id] || {};
            if (!state.terminalId || state.busy) return;
            self.pollTerminal(win.id);
          });
        }, 1500);
      },
      stopTerminalPolling: function () {
        if (this.terminalPollTimer)
          window.clearInterval(this.terminalPollTimer);
        this.terminalPollTimer = null;
      },
      openTerminal: function (winId, forceNew) {
        var self = this,
          state = this.ensureTerminalWindowState(winId),
          grid = this.computeTerminalGrid(winId),
          payload = {
            terminalId: forceNew ? "__new__" : state.terminalId || "",
            cols: grid.cols,
            rows: grid.rows,
          };
        this.ensureXtermMounted(winId);
        state.busy = true;
        state.status = "Opening terminal...";
        this.syncActiveTerminalState(winId);
        return this.command("terminal.open", payload)
          .then(function (json) {
            self.handleTerminalMessage(winId, (json && json.terminal) || {});
            state.status = "Terminal ready";
            self.startTerminalPolling();
            self.resizeTerminal(winId);
            self.focusTerminalInput(winId);
            return json;
          })
          .catch(function (err) {
            state.status = "Terminal unavailable";
            self.syncActiveTerminalState(winId);
            throw err;
          })
          .finally(function () {
            state.busy = false;
            self.syncActiveTerminalState(winId);
          });
      },
      pollTerminal: function (winId) {
        var self = this,
          state = this.ensureTerminalWindowState(winId);
        if (!state.terminalId) return;
        this.command("terminal.poll", { terminalId: state.terminalId || "" })
          .then(function (json) {
            self.handleTerminalMessage(winId, (json && json.terminal) || {});
          })
          .catch(function () {});
      },
      submitTerminalLine: function (winId, lineOverride) {
        var self = this,
          state = this.ensureTerminalWindowState(winId),
          line =
            lineOverride != null
              ? String(lineOverride)
              : String(state.inputLine || "");
        if (!state.terminalId) {
          this.openTerminal(winId, true)
            .then(function () {
              self.submitTerminalLine(winId, line);
            })
            .catch(function () {});
          return;
        }
        state.busy = true;
        if (line.trim()) {
          state.history.push(line);
          if (state.history.length > 100)
            state.history = state.history.slice(-100);
        }
        state.historyIndex = -1;
        state.inputLine = "";
        this.syncActiveTerminalState(winId);
        this.command("terminal.input", {
          terminalId: state.terminalId || "",
          line: line,
        })
          .then(function (json) {
            self.handleTerminalMessage(winId, (json && json.terminal) || {});
            state.status = "Terminal live";
          })
          .catch(function () {
            state.status = "Terminal input failed";
          })
          .finally(function () {
            state.busy = false;
            self.syncActiveTerminalState(winId);
          });
      },
      closeTerminal: function (winId, opts) {
        var self = this,
          state = this.ensureTerminalWindowState(winId),
          termId = state.terminalId || "",
          closeWindow = !!(opts || {}).closeWindow;
        if (!termId) {
          this.disposeXterm(winId);
          state.status = "Terminal closed";
          if (closeWindow) {
            var win0 = this.windows.find(function (w) {
              return w.id === winId;
            });
            if (win0) {
              win0.closed = true;
              win0.minimized = false;
              if (self.activeWindowId === win0.id) self.activeWindowId = "";
            }
          }
          this.syncActiveTerminalState(winId);
          this.saveLayout();
          this.persistUiState(closeWindow ? "close-window" : "terminal-close");
          return;
        }
        this.command("terminal.close", { terminalId: termId })
          .then(function (json) {
            self.handleTerminalMessage(
              winId,
              (json && json.terminal) || { closed: 1 },
            );
          })
          .finally(function () {
            state.status = "Terminal closed";
            state.terminalId = "";
            state.cwd = "/";
            state.inputLine = "";
            state.busy = false;
            self.disposeXterm(winId);
            if (closeWindow) {
              var win = self.windows.find(function (w) {
                return w.id === winId;
              });
              if (win) {
                win.closed = true;
                win.minimized = false;
                if (self.activeWindowId === win.id) self.activeWindowId = "";
              }
            }
            self.syncActiveTerminalState(winId);
            self.saveLayout();
            self.persistUiState(
              closeWindow ? "close-window" : "terminal-close",
            );
          });
      },
      handleTerminalMessage: function (winId, msg) {
        var state = this.ensureTerminalWindowState(winId);
        if (msg.terminalId) state.terminalId = msg.terminalId;
        if (msg.prompt) state.prompt = msg.prompt;
        if (msg.cwd) state.cwd = msg.cwd;
        if (msg.transport) state.transport = msg.transport;
        if (msg.seq != null) state.seq = Number(msg.seq || 0);
        if (msg.clear) {
          state.transcript = "";
          this._xterms = this._xterms || {};
          if (this._xterms[winId] && this._xterms[winId].reset)
            this._xterms[winId].reset();
        }
        var writes = [];
        if (Array.isArray(msg.write)) writes = msg.write;
        else if (msg.write)
          Object.keys(msg.write)
            .sort(function (a, b) {
              return Number(a) - Number(b);
            })
            .forEach(function (k) {
              writes.push(msg.write[k]);
            });
        writes.forEach(function (chunk) {
          this.appendTerminalChunk(winId, chunk || "");
        }, this);
        this.ensureXtermMounted(winId);
        if (msg.closed) {
          state.status = "Terminal closed";
        } else if (state.terminalId) {
          state.status = "Terminal live";
        }
        this.syncActiveTerminalState(winId);
      },
      sendTerminalControl: function (winId, word) {
        this._xterms = this._xterms || {};
        var xterm = this._xterms[winId];
        if (!word) return;
        this.rewriteTerminalInput(winId, String(word));
        if (xterm) xterm.write("\r\n");
        this.submitTerminalLine(winId, String(word));
      },
      onTerminalKeydown: function (ev) {
        if (ev && ev.preventDefault) ev.preventDefault();
      },
      clearTerminal: function (winId) {
        this._xterms = this._xterms || {};
        var state = this.ensureTerminalWindowState(winId),
          xterm = this._xterms[winId];
        state.transcript = "";
        state.inputLine = "";
        if (xterm) {
          if (xterm.clear) xterm.clear();
          else if (xterm.reset) xterm.reset();
        }
        this.focusTerminalInput(winId);
        this.syncActiveTerminalState(winId);
      },
      resizeXtermClient: function (winId, cols, rows) {
        this._xterms = this._xterms || {};
        var xterm = this._xterms[winId];
        if (!xterm || !xterm.resize) return;
        try {
          xterm.resize(Math.max(80, cols || 80), Math.max(20, rows || 20));
          if (xterm.scrollToBottom) xterm.scrollToBottom();
        } catch (e) {}
      },
      resizeTerminal: function (winId) {
        var self = this,
          state = this.ensureTerminalWindowState(winId),
          grid = this.computeTerminalGrid(winId),
          cols = grid.cols,
          rows = grid.rows;
        this.ensureXtermMounted(winId);
        this.resizeXtermClient(winId, cols, rows);
        if (!state.terminalId) return;
        this.command("terminal.resize", {
          terminalId: state.terminalId || "",
          cols: cols,
          rows: rows,
        })
          .then(function (json) {
            self.handleTerminalMessage(winId, (json && json.terminal) || {});
          })
          .catch(function () {});
      },
    },
  });
  app.config.compilerOptions.delimiters = ["[[", "]]"];
  app.mount("#miomosRoot");
})();
