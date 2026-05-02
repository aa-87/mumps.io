(function () {
  function root(vm) {
    return vm.$root;
  }

  function labelOf(entry) {
    return (entry && (entry.title || entry.label || entry.name || entry.key)) || 'Item';
  }

  function iconGlyph(entry) {
    return (entry && entry.icon) || '◻';
  }

  function ensureShellStyles() {
    if (document.getElementById('mioos-shell-ui-runtime-css')) return;
    var node = document.createElement('style');
    node.id = 'mioos-shell-ui-runtime-css';
    node.textContent = `
      .mioos-shell-vue{position:relative;width:100vw;height:100vh;overflow:hidden;font-family:var(--font-ui,"Segoe UI",Tahoma,sans-serif);font-size:var(--font-size-ui,12px);background:var(--desktop-bg,#173a5d);color:var(--menu-text,#10243d)}
      .mioos-wallpaper-layer{position:absolute;inset:0;background-image:var(--desktop-wallpaper);background-size:cover;background-position:center;background-repeat:no-repeat;transition:background-image var(--theme-wallpaper-speed,280ms),filter var(--theme-wallpaper-speed,280ms)}
      .mioos-wallpaper-tint{position:absolute;inset:0;background:var(--desktop-overlay,rgba(255,255,255,.06));pointer-events:none}.mioos-desktop-surface{position:absolute;inset:0;z-index:2}.mioos-desktop-icon-vue{position:absolute;left:0;top:0;width:86px;min-height:84px;padding:6px;border:0;background:transparent;color:var(--icon-label-text,#fff);font-family:var(--font-icon-label,var(--font-ui));font-size:var(--font-size-icon-label,11px);text-align:center;cursor:default;user-select:none;transition:transform var(--theme-hover-speed,120ms),filter var(--theme-hover-speed,120ms)}
      .mioos-desktop-icon-vue:hover{filter:drop-shadow(0 0 7px var(--accent-soft,rgba(75,163,255,.45)))}.mioos-desktop-icon-vue.is-selected .mioos-desktop-icon-label{background:var(--accent-soft,rgba(75,163,255,.32));outline:1px solid color-mix(in srgb,var(--accent,#4ba3ff) 50%,transparent)}.mioos-desktop-icon-glyph{display:block;margin:0 auto 3px;font-size:36px;line-height:42px;width:52px;height:42px;filter:drop-shadow(0 1px 2px rgba(0,0,0,.35))}.mioos-desktop-icon-label{display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden;max-width:80px;margin:0 auto;padding:1px 4px;border-radius:4px;color:var(--icon-label-text,#fff);background:var(--icon-label-bg,rgba(0,0,0,.28));text-shadow:var(--icon-shadow,0 1px 2px rgba(0,0,0,.8));word-break:break-word}.mioos-desktop-icon-vue.is-large{width:98px}.mioos-desktop-icon-vue.is-small{width:74px}.mioos-desktop-icon-vue.is-large .mioos-desktop-icon-glyph{font-size:46px;height:50px}.mioos-desktop-icon-vue.is-small .mioos-desktop-icon-glyph{font-size:28px;height:34px}
      .mioos-taskbar-vue{position:fixed;z-index:4000;display:flex;align-items:center;gap:6px;height:var(--taskbar-height,48px);left:0;right:0;bottom:0;padding:5px 8px;box-sizing:border-box;color:var(--taskbar-text,#fff);background:var(--taskbar-effective-bg,var(--taskbar-bg,linear-gradient(#275aa6,#123a86)));border-top:1px solid var(--taskbar-border,rgba(255,255,255,.25));box-shadow:0 -8px 24px rgba(0,0,0,.28);backdrop-filter:blur(var(--taskbar-blur,8px))}.mioos-start-button-vue,.mioos-task-icon-vue,.mioos-task-item-vue,.mioos-task-clock-vue,.mioos-btn,.mioos-chip-btn{font:inherit;border:1px solid rgba(60,90,130,.45);border-radius:var(--button-radius,7px);background:var(--button-tint,linear-gradient(#fff,#dbeaff));color:var(--button-text,#111827);box-shadow:inset 0 1px 0 rgba(255,255,255,.7);cursor:pointer}.mioos-start-button-vue{height:36px;display:flex;align-items:center;gap:6px;padding:0 12px;font-weight:700}.mioos-taskbar-pinned-vue,.mioos-taskbar-windows-vue,.mioos-taskbar-tray-vue{display:flex;align-items:center;gap:5px;min-width:0}.mioos-taskbar-windows-vue{flex:1;overflow:hidden}.mioos-task-icon-vue{height:34px;min-width:36px;padding:0 8px}.mioos-task-item-vue{height:34px;max-width:180px;display:flex;align-items:center;gap:6px;padding:0 10px;overflow:hidden}.mioos-task-item-title{white-space:nowrap;overflow:hidden;text-overflow:ellipsis}.mioos-task-item-vue.is-active{outline:1px solid var(--accent,#4ba3ff)}.mioos-task-clock-vue{height:34px;padding:0 10px;background:rgba(255,255,255,.12);color:var(--taskbar-text,#fff)}
      .mioos-start-menu-vue{position:fixed;z-index:4500;width:var(--start-menu-width,380px);max-width:calc(100vw - 24px);max-height:calc(100vh - var(--taskbar-height,48px) - 20px);display:flex;flex-direction:column;overflow:hidden;border:1px solid var(--menu-border,rgba(255,255,255,.4));border-radius:12px;background:var(--menu-bg,rgba(248,251,255,.96));box-shadow:var(--menu-shadow,0 20px 50px rgba(0,0,0,.35));color:var(--menu-text,#10243d);font-family:var(--font-menu,var(--font-ui));font-size:var(--font-size-menu,12px);backdrop-filter:blur(14px)}.mioos-start-head-vue{display:flex;align-items:center;gap:10px;padding:10px 12px;color:#fff;background:linear-gradient(180deg,var(--start-menu-accent,var(--accent,#0b63f6)),color-mix(in srgb,var(--start-menu-accent,var(--accent,#0b63f6)) 62%,#001b3f));min-height:56px}.mioos-start-head-vue>div:last-child{display:flex;flex-direction:column;min-width:0}.mioos-start-avatar-vue{display:grid;place-items:center;width:38px;height:38px;border-radius:8px;background:rgba(255,255,255,.25);font-weight:700}.mioos-start-search-vue{display:grid;grid-template-columns:22px 1fr;align-items:center;gap:4px;margin:8px 10px}.mioos-start-search-vue input{min-width:0;height:28px;border:1px solid rgba(80,100,130,.45);border-radius:5px;padding:0 8px;background:var(--theme-field-bg,#fff);color:var(--theme-field-text,#111827)}.mioos-start-body-vue{display:grid;grid-template-columns:minmax(0,1fr) 124px;gap:8px;padding:0 10px 8px;min-height:0;overflow:hidden}.mioos-start-list-vue{min-height:0;overflow:auto;padding-right:2px}.mioos-start-group-vue{border-bottom:1px solid var(--menu-divider,rgba(0,0,0,.12));padding:3px 0}.mioos-start-group-vue summary{display:flex;align-items:center;justify-content:space-between;gap:8px;list-style:none;padding:4px 2px;font-weight:700;cursor:pointer}.mioos-start-group-vue summary::-webkit-details-marker{display:none}.mioos-start-group-vue summary span{font-weight:400;opacity:.72;font-size:10px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}.mioos-start-group-items-vue{display:flex;flex-direction:column;gap:2px}.mioos-start-entry-vue{display:grid;grid-template-columns:34px minmax(0,1fr);align-items:center;gap:7px;width:100%;min-height:42px;padding:5px 7px;border:1px solid transparent;border-radius:7px;background:transparent;color:inherit;text-align:left;line-height:1.2;box-shadow:none}.mioos-start-entry-vue:hover,.mioos-start-entry-vue.is-selected{background:var(--menu-hover,linear-gradient(#fff,#dcecff));border-color:color-mix(in srgb,var(--accent,#4ba3ff) 42%,transparent)}.mioos-start-entry-icon{display:grid;place-items:center;width:30px;height:30px;font-size:21px;overflow:hidden}.mioos-start-entry-vue>span:last-child{display:flex;flex-direction:column;min-width:0;gap:1px}.mioos-start-entry-vue strong{font-size:12px;font-weight:600;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}.mioos-start-entry-vue em{font-style:normal;font-size:10.5px;opacity:.72;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}.mioos-start-side-vue{display:flex;flex-direction:column;gap:5px;min-width:0;overflow:auto;border-left:1px solid var(--menu-divider,rgba(0,0,0,.12));padding-left:8px}.mioos-chip-btn{display:block;width:100%;min-height:26px;padding:4px 7px;text-align:left;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}.mioos-chip-btn.is-active{outline:1px solid var(--accent,#4ba3ff)}.mioos-start-panel-vue{overflow:auto;padding:8px 10px}.mioos-start-panel-group-vue{display:flex;flex-direction:column;gap:3px;margin-bottom:8px}.mioos-start-user-vue{display:flex;align-items:center;gap:8px;padding:8px 10px;border-top:1px solid var(--menu-divider,rgba(0,0,0,.12));background:rgba(255,255,255,.22)}
      .mioos-theme-studio-vue{height:100%;min-height:0;display:flex;flex-direction:column;overflow:hidden;background:var(--theme-surface,rgba(245,249,255,.92));color:var(--menu-text,#10243d);font-family:var(--font-ui,"Segoe UI",Tahoma,sans-serif)}.mioos-theme-studio-toolbar-vue{flex:0 0 auto;display:flex;align-items:center;justify-content:space-between;gap:12px;padding:8px 10px;border-bottom:1px solid var(--theme-panel-border,rgba(0,0,0,.12));background:var(--theme-surface-strong,rgba(255,255,255,.72))}.mioos-theme-studio-toolbar-copy{display:flex;flex-direction:column;min-width:0}.mioos-theme-studio-toolbar-copy span{font-size:11px;opacity:.75;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}.mioos-theme-studio-main-vue{flex:1 1 auto;min-height:0;display:grid;grid-template-columns:minmax(0,1fr) minmax(300px,36%);gap:10px;padding:10px;overflow:hidden}.mioos-theme-studio-editor-vue,.mioos-theme-studio-previewrail-vue{min-height:0;overflow:auto}.mioos-theme-tabs7{display:flex!important;flex-direction:column;min-height:0;overflow:visible}.mioos-theme-tabs7>menu{display:flex!important;flex-wrap:wrap!important;gap:2px;align-items:flex-end;min-height:0!important;height:auto!important;overflow:visible!important;margin:0 0 8px!important;padding:0!important;position:relative;z-index:5}.mioos-theme-tabs7>menu button{min-height:28px;padding:4px 10px;border:1px solid var(--theme-tab-border,rgba(0,0,0,.16));border-bottom-color:rgba(0,0,0,.18);border-radius:6px 6px 0 0;background:var(--theme-tab-bg,#eaf2ff);white-space:nowrap}.mioos-theme-tabs7>menu button[aria-selected=true]{background:var(--theme-tab-active-bg,#fff);font-weight:700}.mioos-theme-tabs7>article{min-height:0;overflow:visible;background:var(--theme-panel-bg,rgba(255,255,255,.55));border:1px solid var(--theme-panel-border,rgba(0,0,0,.12));border-radius:0 8px 8px 8px;padding:10px}.mioos-theme-studio-panel-vue{display:flex;flex-direction:column;gap:10px;min-width:0}.mioos-theme-row-vue{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:10px}.mioos-theme-row-vue .span-2{grid-column:1/-1}.mioos-theme-row-vue label,.mioos-theme-current-select-vue{display:flex;flex-direction:column;gap:3px;min-width:0;font-size:11px}.mioos-theme-row-vue input,.mioos-theme-row-vue select,.mioos-theme-current-select-vue select{min-height:28px;min-width:0;border:1px solid rgba(80,100,130,.45);border-radius:4px;padding:3px 6px;background:var(--theme-field-bg,#fff);color:var(--theme-field-text,#111827)}.mioos-theme-uploadbar-vue{display:flex;gap:8px;align-items:center;flex-wrap:wrap}.mioos-file-trigger-vue input{position:absolute;inline-size:1px;block-size:1px;opacity:0;pointer-events:none}.mioos-theme-studio-previewrail-vue{display:flex;flex-direction:column;gap:8px}.mioos-theme-preview-card-vue{background:var(--theme-preview-card-bg,rgba(255,255,255,.62));border:1px solid var(--theme-preview-card-border,rgba(0,0,0,.12));border-radius:10px;padding:8px;overflow:auto}.mioos-theme-studio-footer-vue{flex:0 0 auto;display:flex;align-items:center;justify-content:space-between;gap:12px;padding:8px 10px;border-top:1px solid var(--theme-panel-border,rgba(0,0,0,.12));background:var(--theme-surface-strong,rgba(255,255,255,.72))}.mioos-theme-studio-footer-actions-vue{display:flex;gap:8px}.mioos-btn{min-height:28px;padding:4px 10px}.mioos-btn.is-primary{outline:1px solid var(--accent,#4ba3ff)}
      @media (max-width:900px){.mioos-theme-studio-main-vue{grid-template-columns:1fr}.mioos-theme-studio-previewrail-vue{max-height:260px}.mioos-start-body-vue{grid-template-columns:1fr}.mioos-start-side-vue{display:none}.mioos-task-item-title,.mioos-start-button-vue strong{display:none}}
    `;
    document.head.appendChild(node);
  }

  function surfaceComponentKey(win) {
    var key = String((win || {}).appKey || 'generic');
    var modular = (window.MIOOSModules && typeof window.MIOOSModules.resolveSurface === 'function') ? window.MIOOSModules.resolveSurface(win, null) : '';
    if (modular) return modular;
    if (key === 'app-catalog' || key === 'ui-modules') return 'mioos-surface-ui-modules';
    if (key === 'permissions' || key === 'permissions-ui') return 'mioos-surface-permissions';
    if (key === 'sample-table' || key === 'table-samples' || key === 'patient-registration' || key === 'ui-elements') return 'mioos-surface-table';
    if (key === 'my-computer' || key === 'documents' || key === 'explorer' || key === 'home') return 'mioos-surface-explorer';
    if (key === 'terminal') return 'mioos-surface-terminal';
    if (key === 'theme-studio' || key === 'customize') return 'mioos-surface-theme';
    if (key === 'control-panel' || key === 'system-settings') return 'mioos-surface-system-settings';
    if (key === 'text-viewer' || key === 'image-viewer' || key === 'media-viewer' || key === 'pdf-viewer' || key === 'structured-viewer') return 'mioos-surface-viewer';
    if (key === 'backend-table' || key === 'table' || key === 'data-grid') return 'mioos-surface-table';
    if (key === 'transfers') return 'mioos-surface-transfers';
    return 'mioos-surface-generic';
  }

  window.MIOOSShellUI = {
    register: function (app) {
      ensureShellStyles();
      app.component('desktop-shell', {
        computed: {
          vm: function () { return root(this); },
          desktopDragging: function () {
            return !!((((this.vm || {}).desktopUi || {}).drag || {}).active);
          }
        },
        methods: {
          handleDesktopMouseDown: function (event) {
            if (!event || event.button !== 0) return;
            if (event.target && event.target.closest && event.target.closest('.mioos-window-vue, .mioos-taskbar-vue, .mioos-start-menu-vue, .mioos-popup-menu-vue')) return;
            this.vm.deselectAll();
          }
        },
        template: '' +
          '<div class="mioos-shell-vue" :class="[\'theme-\' + vm.currentShellThemeFamily(), { \'is-window-dragging\': vm.dragState.active, \'is-icon-dragging\': desktopDragging }]" @mousedown="handleDesktopMouseDown" @contextmenu.prevent="vm.openDesktopContextMenu($event)">' +
            '<div class="mioos-wallpaper-layer" :style="vm.desktopWallpaperStyle()"></div>' +
            '<div class="mioos-wallpaper-tint"></div>' +
            '<div v-if="vm.alertMessage" class="mioos-alert" aria-live="polite" role="status">' +
              '<strong>[[ vm.alertTitle ]]</strong>' +
              '<span>[[ vm.alertMessage ]]</span>' +
              '<button type="button" @click="vm.dismissAlert">[[ vm.t(\'alert.dismiss\') ]]</button>' +
            '</div>' +
            '<section v-if="vm.requiresSignin" class="mioos-auth-overlay" aria-hidden="false">' +
              '<div class="mioos-auth-card" role="dialog" aria-modal="true" :aria-label="vm.boot.product.name">' +
                '<div class="mioos-auth-head"><strong>[[ vm.boot.product.name ]]</strong><span>[[ vm.boot.product.subtitle ]]</span></div>' +
                '<template v-if="!vm.authPasswordChange.required">' +
                  '<p class="mioos-auth-copy">[[ vm.t(\'auth.requiredCopy\') ]]</p>' +
                  '<label class="mioos-auth-field"><span>[[ vm.t(\'auth.username\') ]]</span><input v-model="vm.authForm.username" type="text" autocomplete="username"></label>' +
                  '<label class="mioos-auth-field"><span>[[ vm.t(\'auth.password\') ]]</span><input v-model="vm.authForm.password" type="password" autocomplete="current-password"></label>' +
                  '<p v-if="vm.activeLoginPrivacyNotice()" class="mioos-auth-privacy">[[ vm.activeLoginPrivacyNotice() ]]</p><div class="mioos-auth-actions">' +
                    '<button type="button" class="mioos-auth-primary" @click="vm.submitSignin">[[ vm.t(\'auth.signin\') ]]</button>' +
                    '<button type="button" v-if="vm.boot.auth.guestLoginEnabled" @click="vm.submitGuestSignin">[[ vm.t(\'auth.continueGuest\') ]]</button>' +
                  '</div>' +
                '</template>' +
                '<template v-else>' +
                  '<p class="mioos-auth-copy">Password rotation is required before shell access can continue.</p>' +
                  '<label class="mioos-auth-field"><span>New password</span><input v-model="vm.authPasswordChange.newPassword" type="password" autocomplete="new-password"></label>' +
                  '<label class="mioos-auth-field"><span>Confirm password</span><input v-model="vm.authPasswordChange.confirmPassword" type="password" autocomplete="new-password"></label>' +
                  '<p v-if="vm.activeLoginPrivacyNotice()" class="mioos-auth-privacy">[[ vm.activeLoginPrivacyNotice() ]]</p><div class="mioos-auth-actions"><button type="button" class="mioos-auth-primary" @click="vm.submitPasswordChange">Change password</button></div>' +
                '</template>' +
              '</div>' +
            '</section>' +
            '<start-menu-popup v-if="vm.menuOpen"></start-menu-popup>' +
            '<popup-menu v-if="vm.desktopContextMenuState().open"></popup-menu>' +
            '<div v-if="vm.snapPreview.active" class="mioos-snap-preview" :data-snap-zone="vm.snapPreview.zone" :style="vm.snapPreviewStyle()"></div>' +
            '<div class="mioos-desktop-surface" :class="{ \'pointer-events-none\': vm.dragState.active }">' +
              '<desktop-icon v-for="entry in vm.desktopRenderEntries()" :key="entry.key" :icon="entry"></desktop-icon>' +
            '</div>' +
            '<window-frame v-for="win in vm.visibleWindows" :key="win.id" :window="win"></window-frame>' +
            '<taskbar-shell></taskbar-shell>' +
          '</div>'
      });

      app.component('desktop-icon', {
        props: ['icon'],
        computed: {
          vm: function () { return root(this); },
          iconStyle: function () {
            var pos = ((((this.vm || {}).desktopUi || {}).positions || {})[this.icon.key]) || { left: 16, top: 16 };
            return {
              '--x': ((+pos.left || 16) + 'px'),
              '--y': ((+pos.top || 16) + 'px'),
              transform: 'translate(var(--x), var(--y))'
            };
          },
          iconClasses: function () {
            return this.vm.desktopIconClass(this.icon);
          }
        },
        template: '' +
          '<button type="button" class="mioos-desktop-icon-vue" :class="iconClasses" :style="iconStyle" :title="labelOf(icon)" @click.stop="vm.selectDesktopEntry(icon)" @mousedown.stop="vm.beginDesktopIconDrag(icon, $event)" @contextmenu.prevent.stop="vm.openDesktopIconContextMenu(icon, $event)" @dblclick.stop="onOpen" @keydown.enter.prevent="onOpen">' +
            '<span class="mioos-desktop-icon-glyph">[[ iconGlyph(icon) ]]</span>' +
            '<span class="mioos-desktop-icon-label">[[ labelOf(icon) ]]</span>' +
          '</button>',
        methods: {
          labelOf: labelOf,
          iconGlyph: iconGlyph,
          onOpen: function () { var icon = this.icon; this.vm.openDesktopEntry(icon); }
        }
      });

      app.component('window-frame', {
        props: ['window'],
        data: function () {
          return { resizeEdges: ['n', 'ne', 'e', 'se', 's', 'sw', 'w', 'nw'] };
        },
        computed: {
          vm: function () { return root(this); },
          contentComponent: function () { return surfaceComponentKey(this.window); },
          family: function () { return this.vm.currentShellThemeFamily(); }
        },
        mounted: function () { this.primeSurface(); },
        updated: function () { this.primeSurface(); },
        methods: {
          primeSurface: function () {
            var vm = this.vm;
            var win = this.window;
            if (!win) return;
            if ((win.appKey === 'my-computer' || win.appKey === 'documents' || win.appKey === 'explorer' || win.appKey === 'home') && vm.bootstrapExplorerWindow) {
              vm.bootstrapExplorerWindow(win.id, false);
            }
            if (win.appKey === 'terminal' && vm.mountTerminalWindow) {
              vm.$nextTick(function () {
                vm.mountTerminalWindow(win.id);
                if (!vm.requiresSignin && !(((win.terminalState || {}).terminalId) || '') && !((win.terminalState || {}).busy)) {
                  vm.requestTerminalOpen(win.id, false);
                }
              });
            }
          }
        },
        template: '' +
          '<section class="mioos-window-vue" :class="vm.windowClass(window)" :style="vm.windowStyle(window)" role="dialog" :aria-label="window.title" :data-window-state="window.state" :data-window-app="window.appKey" @mousedown="vm.focusWindow(window.id)" @dragover="vm.onWindowDragOver(window, $event)" @drop="vm.onWindowDrop(window, $event)">' +
            '<header class="mioos-titlebar-vue" :class="[\'is-\' + family]" @mousedown.stop="vm.beginDrag(window, $event)" @dblclick.stop="vm.onWindowTitleDblClick(window.id)">' +
              '<div class="mioos-titlebar-copy-vue"><span class="mioos-titlebar-icon">[[ vm.appIcon(window.appKey) ]]</span><strong>[[ window.title ]]</strong></div>' +
              '<div class="mioos-window-actions-vue">' +
                '<button type="button" class="mioos-window-control is-minimize" :title="vm.t(\'action.minimize\')" @click.stop="vm.minimizeWindow(window.id)"><span>—</span></button>' +
                '<button type="button" class="mioos-window-control is-maximize" :title="vm.windowToggleLabel(window)" @click.stop="vm.toggleMaximize(window.id)"><span>□</span></button>' +
                '<button type="button" class="mioos-window-control is-close" :title="vm.t(\'action.close\')" @click.stop="vm.closeWindow(window.id)"><span>×</span></button>' +
              '</div>' +
            '</header>' +
            '<div class="mioos-window-content-vue"><component :is="contentComponent" :window="window"></component></div>' +
            '<span v-for="edge in resizeEdges" :key="edge" class="mioos-resize-handle-vue" :data-edge="edge" :data-resize-edge="edge" @pointerdown.stop.prevent="vm.beginResize(window, edge, $event)"></span>' +
          '</section>'
      });

      app.component('mioos-surface-explorer', {
        props: ['window'],
        computed: {
          vm: function () { return root(this); },
          state: function () { return this.vm.ensureExplorerWindowState(this.window) || {}; },
          items: function () { return this.vm.explorerVisibleItems(this.state); },
          folders: function () { return this.items.filter(function (item) { return String(item.kind || item.type || '').toLowerCase() === 'folder'; }); },
          preview: function () { return (this.state && this.state.preview) || {}; },
          quickPlaces: function () { return this.vm.explorerQuickPlaces(); },
          selectedKey: function () { return this.vm.explorerSelectedKey(this.state); }
        },
        mounted: function () { this.vm.bootstrapExplorerWindow(this.window.id, false); },
        methods: {
          itemKey: function (item) { return (item && (item.id || item.key || item.path || item.name)) || ''; },
          select: function (item) { this.vm.selectExplorerItem(this.window.id, item); },
          open: function (item) { this.vm.explorerOpenItem(this.window.id, item); },
          navigate: function (place) { this.vm.explorerNavigateToPlace(this.window.id, place.id); },
          sort: function (key) { this.vm.explorerSortBy(this.window.id, key); },
          setView: function (mode) { this.vm.explorerSetViewMode(this.window.id, mode); },
          rowMenu: function (item, event) { this.vm.openExplorerContextMenu(this.window.id, item, event); },
          blankMenu: function (event) { this.vm.openExplorerContextMenu(this.window.id, null, event); },
          sortMark: function (key) { return this.state.sortKey === key ? (this.state.sortDir === 'desc' ? '▼' : '▲') : ''; }
        },
        template: `
          <div class="mioos-surface mioos-surface-explorer mioos-explorer-native" @contextmenu.prevent="blankMenu($event)" @click="vm.closeExplorerContextMenu(window.id)">
            <nav class="mioos-explorer-menu-strip" role="menubar" aria-label="Explorer menu" @click.stop>
              <button role="menuitem" type="button">File</button>
              <button role="menuitem" type="button">Edit</button>
              <button role="menuitem" type="button">View</button>
              <button role="menuitem" type="button">Tools</button>
            </nav>
            <div class="mioos-explorer-toolbar" @click.stop>
              <button type="button" class="mioos-explorer-command" :disabled="!((state.history || []).length)" @click="vm.explorerGoBack(window.id)">‹ Back</button>
              <button type="button" class="mioos-explorer-command" :disabled="!((state.future || []).length)" @click="vm.explorerGoForward(window.id)">Forward ›</button>
              <button type="button" class="mioos-explorer-command" @click="vm.explorerGoUp(window.id)">Up</button>
              <button type="button" class="mioos-explorer-command" @click="vm.refreshExplorerWindow(window.id)">Refresh</button>
              <span class="mioos-explorer-toolbar-divider"></span>
              <button type="button" class="mioos-explorer-command" @click="vm.explorerPromptUpload(window.id)">Upload</button>
              <button type="button" class="mioos-explorer-command" :disabled="!state.selection" @click="vm.explorerDownloadSelected(window.id)">Download</button>
              <button type="button" class="mioos-explorer-command" @click="vm.explorerCreateFolder(window.id)">New Folder</button>
              <button type="button" class="mioos-explorer-command" :disabled="!state.selection" @click="vm.explorerRenameSelected(window.id)">Rename</button>
              <button type="button" class="mioos-explorer-command is-danger" :disabled="!state.selection" @click="vm.explorerDeleteSelected(window.id)">Delete</button>
            </div>
            <div class="mioos-explorer-address-row" @click.stop>
              <label>Address</label>
              <div class="mioos-explorer-addressbar" role="textbox" aria-label="Current folder">[[ (state.folder || {}).path || '/' ]]</div>
              <input class="mioos-explorer-search" type="search" v-model="state.searchTerm" placeholder="Search this folder" aria-label="Search this folder">
            </div>
            <div class="mioos-explorer-layout">
              <aside class="mioos-explorer-nav-pane" aria-label="Folders" @click.stop>
                <strong class="mioos-explorer-pane-title">Folders</strong>
                <ul class="mioos-explorer-tree-view" role="tree">
                  <li v-for="place in quickPlaces" :key="place.id" role="treeitem">
                    <button type="button" :class="{ 'is-active': state.folderId === place.id }" @click="navigate(place)"><span>[[ place.icon ]]</span><span>[[ place.label ]]</span></button>
                  </li>
                </ul>
                <strong class="mioos-explorer-pane-title" v-if="folders.length">This folder</strong>
                <ul class="mioos-explorer-tree-view mioos-explorer-tree-view-current" role="tree" v-if="folders.length">
                  <li v-for="folder in folders" :key="itemKey(folder)" role="treeitem">
                    <button type="button" @click="open(folder)"><span>📁</span><span>[[ folder.name || folder.title ]]</span></button>
                  </li>
                </ul>
                <div class="mioos-explorer-details-card" v-if="state.selection">
                  <strong>Details</strong>
                  <span>[[ state.selection.name || state.selection.title ]]</span>
                  <span>[[ vm.explorerItemTypeLabel(state.selection) ]]</span>
                  <span>[[ vm.explorerFormatSize(state.selection) || '—' ]]</span>
                </div>
              </aside>
              <section class="mioos-explorer-main" :class="'view-' + (state.viewMode || 'details')" @click.stop="vm.closeExplorerContextMenu(window.id)" @contextmenu.prevent="blankMenu($event)">
                <div class="mioos-explorer-viewbar" @click.stop>
                  <span>View:</span>
                  <button type="button" :class="{ 'is-active': state.viewMode === 'details' }" @click="setView('details')">Details</button>
                  <button type="button" :class="{ 'is-active': state.viewMode === 'icons' }" @click="setView('icons')">Icons</button>
                </div>
                <div class="mioos-explorer-empty" v-if="state.loading">Loading folder…</div>
                <div class="mioos-explorer-empty" v-else-if="state.error">[[ state.error ]]</div>
                <div class="mioos-explorer-empty" v-else-if="!items.length">This folder is empty.</div>
                <table v-else-if="(state.viewMode || 'details') === 'details'" class="mioos-explorer-listview" role="grid" aria-label="Folder contents">
                  <thead><tr>
                    <th><button type="button" @click="sort('name')">Name [[ sortMark('name') ]]</button></th>
                    <th><button type="button" @click="sort('type')">Type [[ sortMark('type') ]]</button></th>
                    <th><button type="button" @click="sort('size')">Size [[ sortMark('size') ]]</button></th>
                    <th><button type="button" @click="sort('modified')">Modified [[ sortMark('modified') ]]</button></th>
                  </tr></thead>
                  <tbody>
                    <tr v-for="item in items" :key="itemKey(item)" :class="{ 'is-selected': selectedKey === itemKey(item) }" @click.stop="select(item)" @dblclick.stop="open(item)" @contextmenu.prevent.stop="rowMenu(item, $event)">
                      <td><span class="mioos-explorer-row-icon">[[ vm.explorerItemGlyph(item) ]]</span><span class="mioos-explorer-row-name">[[ item.name || item.title ]]</span></td>
                      <td>[[ vm.explorerItemTypeLabel(item) ]]</td>
                      <td>[[ vm.explorerFormatSize(item) ]]</td>
                      <td>[[ item.modifiedLabel || item.modifiedAt || item.mtime || '' ]]</td>
                    </tr>
                  </tbody>
                </table>
                <div v-else class="mioos-explorer-icon-grid" role="list" aria-label="Folder contents">
                  <button v-for="item in items" :key="itemKey(item)" type="button" class="mioos-explorer-icon-tile" :class="{ 'is-selected': selectedKey === itemKey(item) }" @click.stop="select(item)" @dblclick.stop="open(item)" @contextmenu.prevent.stop="rowMenu(item, $event)">
                    <span class="mioos-explorer-icon-tile-glyph">[[ vm.explorerItemGlyph(item) ]]</span>
                    <span>[[ item.name || item.title ]]</span>
                  </button>
                </div>
              </section>
              <aside class="mioos-explorer-preview-pane" aria-label="Preview">
                <strong>[[ preview.title || 'Preview' ]]</strong>
                <pre v-if="preview.content" class="mioos-preview-pre">[[ preview.content ]]</pre>
                <img v-else-if="preview.imageSrc" :src="preview.imageSrc" alt="Preview" class="mioos-preview-image">
                <video v-else-if="preview.mediaSrc && preview.mediaKind === 'video'" :src="preview.mediaSrc" controls playsinline preload="metadata" class="mioos-preview-media"></video>
                <audio v-else-if="preview.mediaSrc && preview.mediaKind === 'audio'" :src="preview.mediaSrc" controls preload="metadata" class="mioos-preview-media"></audio>
                <div v-else class="mioos-explorer-empty">Pick a supported file to preview it here.</div>
              </aside>
            </div>
            <div class="mioos-explorer-statusbar" role="status">
              <span>[[ items.length ]] item<span v-if="items.length !== 1">s</span></span>
              <span v-if="state.selection">Selected: [[ state.selection.name || state.selection.title ]]</span>
              <span v-else>[[ (state.folder || {}).path || '/' ]]</span>
            </div>
            <ul v-if="(state.contextMenu || {}).open" class="mioos-explorer-context-menu can-hover" role="menu" :style="vm.explorerContextMenuStyle(state)" @click.stop>
              <li v-if="state.selection && ((state.contextMenu || {}).targetType === 'item')"><button type="button" role="menuitem" @click="vm.explorerContextOpen(window.id)">Open</button></li>
              <li v-if="state.selection && ((state.contextMenu || {}).targetType === 'item')"><button type="button" role="menuitem" @click="vm.explorerCopySelected(window.id)">Copy</button></li>
              <li v-if="state.selection && ((state.contextMenu || {}).targetType === 'item')"><button type="button" role="menuitem" @click="vm.explorerRenameSelected(window.id); vm.closeExplorerContextMenu(window.id)">Rename</button></li>
              <li v-if="state.selection && ((state.contextMenu || {}).targetType === 'item')"><button type="button" role="menuitem" @click="vm.explorerDeleteSelected(window.id); vm.closeExplorerContextMenu(window.id)">Delete</button></li>
              <li class="has-divider"><button type="button" role="menuitem" @click="vm.explorerCreateFolder(window.id); vm.closeExplorerContextMenu(window.id)">New Folder</button></li>
              <li><button type="button" role="menuitem" @click="vm.explorerPromptUpload(window.id); vm.closeExplorerContextMenu(window.id)">Upload</button></li>
              <li v-if="state.selection && ((state.contextMenu || {}).targetType === 'item')"><button type="button" role="menuitem" @click="vm.explorerDownloadSelected(window.id); vm.closeExplorerContextMenu(window.id)">Download</button></li>
              <li><button type="button" role="menuitem" @click="vm.explorerPasteIntoWindow(window.id)">Paste</button></li>
              <li class="has-divider"><button type="button" role="menuitem" @click="vm.explorerContextProperties(window.id)">Properties</button></li>
            </ul>
          </div>
        `
      });

      app.component('mioos-surface-terminal', {
        props: ['window'],
        computed: {
          vm: function () { return root(this); },
          terminalId: function () { return this.vm.terminalContainerId(this.window.id); },
          state: function () { return this.vm.ensureTerminalState(this.window.id) || {}; }
        },
        mounted: function () {
          var vm = this.vm;
          var windowId = this.window.id;
          vm.$nextTick(function () {
            vm.mountTerminalWindow(windowId);
            if (!vm.requiresSignin && !(((vm.ensureTerminalState(windowId) || {}).terminalId) || '') && !((vm.ensureTerminalState(windowId) || {}).busy)) {
              vm.requestTerminalOpen(windowId, false);
            }
          });
        },
        updated: function () {
          var vm = this.vm;
          vm.$nextTick(function () { vm.mountTerminalWindow(this.window.id); }.bind(this));
        },
        template: '' +
          '<div class="mioos-surface mioos-surface-terminal">' +
            '<div class="mioos-surface-toolbar">' +
              '<button type="button" class="mioos-btn" @click="vm.openTerminal(window.id, true)">New Session</button>' +
              '<button type="button" class="mioos-btn" @click="vm.pollTerminal(window.id)">Refresh</button>' +
              '<button type="button" class="mioos-btn" @click="vm.clearTerminalWindow(window.id)">Clear</button>' +
              '<button type="button" class="mioos-btn is-danger" @click="vm.closeTerminalWindow(window.id)">Close</button>' +
              '<span class="mioos-surface-status">[[ state.status || \'Terminal ready\' ]]</span>' +
            '</div>' +
            '<div class="mioos-terminal-stage-vue"><div :id="terminalId" class="mioos-terminal-host-vue"></div></div>' +
          '</div>'
      });

      app.component('mioos-surface-theme', {
        props: ['window'],
        mounted: function () {
          if (this.vm.themeStudioOpenSession) this.vm.themeStudioOpenSession();
        },
        computed: {
          vm: function () { return root(this); },
          store: function () { return this.vm.initThemeStudioStore(); },
          activeTheme: function () { return this.vm.themeStudioActiveTheme() || {}; },
          themeList: function () { return this.vm.themeStudioThemeList(); },
          previewIcons: function () { return this.vm.themeStudioPreviewIcons(); },
          previewWindow: function () { return (this.store && this.store.previewWindowState) || {}; },
          tabs: function () { return this.vm.themeStudioTabs(); },
          activeTab: function () { return this.vm.themeStudioActiveTab(); },
          groups: function () { return this.vm.startMenuGroups(); },
          selectedKey: function () { this.vm.startMenuEnsureSelection(); return ((this.vm.startMenuUi || {}).selectedKey) || ''; }
        },
        template: `
          <div class="mioos-surface mioos-surface-theme">
            <div class="mioos-theme-studio-vue win7">
              <header class="mioos-theme-studio-toolbar-vue">
                <div class="mioos-theme-studio-toolbar-copy">
                  <strong>Themes and Appearance</strong>
                  <span>Refine shell chrome, wallpapers, taskbar, start menu, and login visuals with live desktop and mobile previews.</span>
                </div>
                <div class="mioos-theme-studio-toolbar-actions">
                  <label class="mioos-theme-current-select-vue"><span>Theme</span><select :value="(activeTheme && activeTheme.id) || ''" @change="vm.themeStudioActivate($event.target.value, { persist: false, silent: true })">
                    <option v-for="theme in themeList" :key="theme.id" :value="theme.id">[[ theme.name ]]</option>
                  </select></label>
                </div>
              </header>

              <div class="mioos-theme-studio-main-vue">
                <section class="mioos-theme-studio-editor-vue">
                  <section class="tabs mioos-theme-tabs7">
                    <menu role="tablist" aria-label="Theme Studio tabs">
                      <button v-for="tab in tabs" :key="tab.key" role="tab" :aria-controls="'theme-tab-' + tab.key" :aria-selected="activeTab === tab.key ? 'true' : 'false'" @click="vm.themeStudioSetTab(tab.key)">[[ tab.label ]]</button>
                    </menu>

                    <article v-for="tab in tabs" :key="tab.key + '-panel'" role="tabpanel" :id="'theme-tab-' + tab.key" v-show="activeTab === tab.key">
                      <div class="mioos-theme-studio-panel-vue" v-if="tab.key === 'themes'">
                        <div class="mioos-theme-row-vue">
                          <label><span>Theme name</span><input type="text" :value="activeTheme.name || ''" @input="vm.themeStudioUpdateField('name', $event.target.value)"></label>
                          <label><span>Base preset</span><select :value="activeTheme.sourceId || activeTheme.id || 'glow'" @change="vm.themeStudioLoadBaseTheme($event.target.value)"><option value="vintage">Vintage</option><option value="glow">Glow</option><option value="curve">Curve</option><option value="panel">Panel</option></select></label>
                        </div>
                        <div class="mioos-theme-row-vue">
                          <div class="mioos-theme-mode-buttons-vue span-2" title="Each theme stores exactly two palettes: Light and Dark.">
                            <span class="mioos-theme-radio-label-vue">Theme mode</span>
                            <div class="mioos-theme-mode-actions-vue" role="group" aria-label="Theme mode">
                              <button type="button" class="mioos-chip-btn" :class="{ 'is-active': !activeTheme.darkEnabled }" @click="vm.themeStudioSetDarkEnabled(false)">Light</button>
                              <button type="button" class="mioos-chip-btn" :class="{ 'is-active': !!activeTheme.darkEnabled }" @click="vm.themeStudioSetDarkEnabled(true)">Dark</button>
                            </div>
                          </div>
                        </div>
                        <div class="mioos-theme-row-vue">
                          <label class="span-2"><span>Global font size</span><input type="range" min="10" max="18" step="1" :value="vm.themeStudioFontScaleValue()" @input="vm.themeStudioSetFontScale($event.target.value)"></label>
                          <div class="mioos-font-preview-vue span-2" :style="{ fontSize: vm.themeStudioFontScaleValue() + 'px' }">
                            <strong :style="{ fontFamily: vm.themeStudioFontValue('titlebar') }">Title bar sample</strong>
                            <span :style="{ fontFamily: vm.themeStudioFontValue('taskbar') }">Taskbar and Start menu text update live.</span>
                            <small :style="{ fontFamily: vm.themeStudioFontValue('icon') }">Desktop icons · Menus · Dialogs</small>
                          </div>
                        </div>
                        <div class="mioos-theme-row-vue">
                          <label><span>Desktop UI font</span><select :value="vm.themeStudioFontValue('ui')" @change="vm.themeStudioSetFontFamily('ui', $event.target.value)"><option v-for="font in vm.themeStudioFontOptions()" :key="font.value + '-ui'" :value="font.value">[[ font.label ]]</option></select></label>
                          <label><span>Title bar font</span><select :value="vm.themeStudioFontValue('titlebar')" @change="vm.themeStudioSetFontFamily('titlebar', $event.target.value)"><option v-for="font in vm.themeStudioFontOptions()" :key="font.value + '-title'" :value="font.value">[[ font.label ]]</option></select></label>
                          <label><span>Taskbar / Start font</span><select :value="vm.themeStudioFontValue('taskbar')" @change="vm.themeStudioSetFontFamily('taskbar', $event.target.value)"><option v-for="font in vm.themeStudioFontOptions()" :key="font.value + '-taskbar'" :value="font.value">[[ font.label ]]</option></select></label>
                          <label><span>Icon labels font</span><select :value="vm.themeStudioFontValue('icon')" @change="vm.themeStudioSetFontFamily('icon', $event.target.value)"><option v-for="font in vm.themeStudioFontOptions()" :key="font.value + '-icon'" :value="font.value">[[ font.label ]]</option></select></label>
                        </div>
                      </div>

                      <div class="mioos-theme-studio-panel-vue" v-else-if="tab.key === 'desktop'">
                        <div class="mioos-theme-row-vue">
                          <label><span>Wallpaper preset</span><select :value="activeTheme.wallpaperPreset || 'aurora'" @change="vm.themeStudioUpdateField('wallpaperPreset', $event.target.value)"><option value="meadow">Meadow</option><option value="aurora">Aurora</option><option value="graphite">Graphite</option><option value="ember">Ember</option><option value="custom-upload">Uploaded image</option></select></label>
                          <label><span>Wallpaper fit</span><select :value="activeTheme.wallpaperFit || 'cover'" @change="vm.themeStudioUpdateField('wallpaperFit', $event.target.value)"><option value="cover">Cover</option><option value="contain">Contain</option><option value="center">Center</option><option value="tile">Tile</option></select></label>
                        </div>
                        <div class="mioos-theme-uploadbar-vue">
                          <label role="button" tabindex="0" class="mioos-btn mioos-file-trigger-vue">
                            <input type="file" accept="image/*" @change="vm.themeStudioUploadField('wallpaperUrl', $event)">
                            Upload wallpaper
                          </label>
                          <button type="button" class="mioos-btn" @click="vm.themeStudioClearUploadedField('wallpaperUrl')">Clear wallpaper</button>
                        </div>
                        <div class="mioos-theme-row-vue">
                          <label><span>Desktop icon size</span><input type="range" min="36" max="72" step="1" :value="parseInt(vm.themeStudioTextValue('--desktop-icon-size', '48px'), 10) || 48" @input="vm.themeStudioUpdateVar('--desktop-icon-size', $event.target.value + 'px')"></label>
                          <label><span>Icon label shadow</span><input type="text" :value="vm.themeStudioTextValue('--icon-shadow', '0 1px 2px rgba(0,0,0,0.75)')" @input="vm.themeStudioUpdateVar('--icon-shadow', $event.target.value)"></label>
                        </div>
                      </div>

                      <div class="mioos-theme-studio-panel-vue" v-else-if="tab.key === 'appearance'">
                        <div class="mioos-theme-row-vue">
                          <label><span>Title bar gradient</span><input type="text" :value="vm.themeStudioTextValue('--titlebar-bg', '')" @input="vm.themeStudioUpdateVar('--titlebar-bg', $event.target.value)"></label>
                          <label><span>Title bar text</span><input type="color" :value="vm.themeStudioColorValue('--titlebar-text', '#10233f')" @input="vm.themeStudioUpdateVar('--titlebar-text', $event.target.value)"></label>
                          <label><span>Window background</span><input type="text" :value="vm.themeStudioTextValue('--window-bg', '')" @input="vm.themeStudioUpdateVar('--window-bg', $event.target.value)"></label>
                          <label><span>Window border</span><input type="color" :value="vm.themeStudioColorValue('--window-border', '#2456a6')" @input="vm.themeStudioUpdateVar('--window-border', $event.target.value)"></label>
                          <label><span>Window radius</span><input type="range" min="0" max="24" step="1" :value="parseInt(vm.themeStudioTextValue('--window-radius', '10px'), 10) || 10" @input="vm.themeStudioUpdateVar('--window-radius', $event.target.value + 'px')"></label>
                          <label><span>Window shadow</span><input type="text" :value="vm.themeStudioTextValue('--shadow-window', '')" @input="vm.themeStudioUpdateVar('--shadow-window', $event.target.value)"></label>
                        </div>
                      </div>

                      <div class="mioos-theme-studio-panel-vue" v-else-if="tab.key === 'taskbar'">
                        <div class="mioos-theme-row-vue">
                          <label><span>Taskbar position</span><select :value="((activeTheme.taskbarConfig || {}).position) || 'bottom'" @change="vm.themeStudioUpdateField('taskbarConfig.position', $event.target.value)"><option value="bottom">Bottom</option><option value="top">Top</option><option value="left">Left</option></select></label>
                          <label><span>Taskbar height</span><input type="range" min="36" max="72" step="1" :value="vm.taskbarHeightValue()" @input="vm.themeStudioUpdateField('taskbarConfig.height', +$event.target.value)"></label>
                          <label><span>Button style</span><select :value="((activeTheme.taskbarConfig || {}).buttonStyle) || 'xp'" @change="vm.themeStudioUpdateField('taskbarConfig.buttonStyle', $event.target.value)"><option value="xp">Classic bevel</option><option value="glow">Glass capsule</option><option value="curve">Rounded pill</option></select></label>
                          <label><span>Transparency</span><input type="range" min="0" max="1" step="0.01" :value="((activeTheme.taskbarConfig || {}).transparentAmount) || 0" @input="vm.themeStudioUpdateField('taskbarConfig.transparentAmount', +$event.target.value)"></label>
                        </div>
                        <div class="mioos-theme-hint-vue">Adjust both the live shell and the preview: transparency now changes the actual taskbar surface, while button style updates Start and running-window buttons.</div>
                      </div>

                      <div class="mioos-theme-studio-panel-vue" v-else-if="tab.key === 'start'">
                        <div class="mioos-theme-start-stylecards-vue">
                          <button type="button" class="mioos-theme-stylecard-vue" :class="{ 'is-active': (((activeTheme.startMenuConfig || {}).style) || 'classic') === 'classic' }" @click="vm.themeStudioUpdateField('startMenuConfig.style', 'classic')">
                            <strong>Classic nested</strong>
                            <span>Classic two-column launcher with expandable groups.</span>
                            <div class="mioos-theme-stylecard-mini-vue classic"><i></i><i></i><i></i></div>
                          </button>
                          <button type="button" class="mioos-theme-stylecard-vue" :class="{ 'is-active': (((activeTheme.startMenuConfig || {}).style) || 'classic') === 'popup' }" @click="vm.themeStudioUpdateField('startMenuConfig.style', 'popup')">
                            <strong>Popup launcher</strong>
                            <span>Centered application launcher with grouped actions and quick launch.</span>
                            <div class="mioos-theme-stylecard-mini-vue panel"><i></i><i></i><i></i></div>
                          </button>
                        </div>
                        <div class="mioos-theme-row-vue">
                          <label><span>Menu width</span><input type="range" min="300" max="760" step="10" :value="((activeTheme.startMenuConfig || {}).width) || 360" @input="vm.themeStudioUpdateField('startMenuConfig.width', +$event.target.value)"></label>
                          <label><span>Accent color</span><input type="color" :value="((activeTheme.startMenuConfig || {}).accentColor) || vm.themeStudioColorValue('--accent', '#0b63f6')" @input="vm.themeStudioUpdateField('startMenuConfig.accentColor', $event.target.value)"></label>
                          <label v-if="(((activeTheme.startMenuConfig || {}).style) || 'classic') === 'classic'"><span>Nested folders</span><select :value="(((activeTheme.startMenuConfig || {}).nested) === false ? 'off' : 'on')" @change="vm.themeStudioUpdateField('startMenuConfig.nested', $event.target.value === 'on')"><option value="on">Enabled</option><option value="off">Flattened</option></select></label>
                          <label v-else><span>Popup grouping</span><select :value="((activeTheme.startMenuConfig || {}).pinnedTileLayout) || 'grid'" @change="vm.themeStudioUpdateField('startMenuConfig.pinnedTileLayout', $event.target.value)"><option value="grid">Grid</option><option value="stack">Stacked</option><option value="columns">Columns</option></select></label>
                        </div>
                        <div class="mioos-theme-startmenu-mini-vue" :class="['style-' + ((((activeTheme.startMenuConfig || {}).style) || 'classic'))]">
                          <template v-if="(((activeTheme.startMenuConfig || {}).style) || 'classic') === 'classic'">
                            <div class="mioos-theme-classicmenu-vue">
                              <section class="mioos-theme-classicmenu-main-vue">
                                <details v-for="group in groups" :key="group.key + '-mini'" :open="group.open">
                                  <summary>[[ group.title ]]</summary>
                                  <div class="mioos-theme-startmenu-mini-items-vue">
                                    <span v-for="item in group.items" :key="item.key + '-mini'">[[ item.title ]]</span>
                                  </div>
                                </details>
                              </section>
                              <aside class="mioos-theme-classicmenu-side-vue">
                                <strong>Pinned</strong>
                                <span v-for="item in groups[0].items.slice(0,3)" :key="item.key + '-pin'">[[ item.title ]]</span>
                              </aside>
                            </div>
                          </template>
                          <template v-else>
                            <div class="mioos-theme-popupmenu-vue">
                              <div class="mioos-theme-popupmenu-head-vue">App menu</div>
                              <div class="mioos-theme-panelmenu-group-vue" v-for="group in groups" :key="group.key + '-popup-mini'">
                                <strong>[[ group.title ]]</strong>
                                <button type="button" class="mioos-start-entry-vue" v-for="item in group.items" :key="item.key + '-popup-item'">
                                  <span class="mioos-start-entry-icon">[[ item.icon ]]</span><span><strong>[[ item.title ]]</strong><em>[[ item.subtitle ]]</em></span>
                                </button>
                              </div>
                            </div>
                          </template>
                        </div>
                      </div>

                      <div class="mioos-theme-studio-panel-vue" v-else-if="tab.key === 'login'">
                        <div class="mioos-theme-uploadcards-vue">
                          <div class="mioos-theme-uploadcard-vue">
                            <div class="mioos-theme-uploadcard-illustration-vue wallpaper">Background</div>
                            <div class="mioos-theme-uploadcard-copy-vue"><strong>Login background image</strong><span>Shown full-screen behind the sign-in card.</span></div>
                            <div class="mioos-theme-uploadcard-actions-vue">
                              <label role="button" tabindex="0" class="mioos-btn mioos-file-trigger-vue">
                                <input type="file" accept="image/*" @change="vm.themeStudioUploadField('loginScreenConfig.wallpaperUrl', $event)">
                                Upload background
                              </label>
                              <button type="button" class="mioos-btn" @click="vm.themeStudioClearUploadedField('loginScreenConfig.wallpaperUrl')">Clear</button>
                            </div>
                          </div>
                          <div class="mioos-theme-uploadcard-vue">
                            <div class="mioos-theme-uploadcard-illustration-vue avatar">Avatar</div>
                            <div class="mioos-theme-uploadcard-copy-vue"><strong>Account avatar</strong><span>Displayed inside the login card above the account name.</span></div>
                            <div class="mioos-theme-uploadcard-actions-vue">
                              <label role="button" tabindex="0" class="mioos-btn mioos-file-trigger-vue">
                                <input type="file" accept="image/*" @change="vm.themeStudioUploadField('loginScreenConfig.avatarUrl', $event)">
                                Upload avatar
                              </label>
                              <button type="button" class="mioos-btn" @click="vm.themeStudioClearUploadedField('loginScreenConfig.avatarUrl')">Clear</button>
                            </div>
                          </div>
                          <div class="mioos-theme-uploadcard-vue span-2">
                            <div class="mioos-theme-uploadcard-illustration-vue notice">Notice</div>
                            <div class="mioos-theme-uploadcard-copy-vue"><strong>Privacy / warning banner image</strong><span>Appears in the login notice panel with your heading and message text.</span></div>
                            <div class="mioos-theme-uploadcard-actions-vue">
                              <label role="button" tabindex="0" class="mioos-btn mioos-file-trigger-vue">
                                <input type="file" accept="image/*" @change="vm.themeStudioUploadField('loginScreenConfig.warningImageUrl', $event)">
                                Upload banner image
                              </label>
                              <button type="button" class="mioos-btn" @click="vm.themeStudioClearUploadedField('loginScreenConfig.warningImageUrl')">Clear</button>
                            </div>
                          </div>
                        </div>
                        <div class="mioos-theme-row-vue">
                          <label><span>Login box style</span><select :value="((activeTheme.loginScreenConfig || {}).loginBoxStyle) || 'xp-transparent'" @change="vm.themeStudioUpdateField('loginScreenConfig.loginBoxStyle', $event.target.value)"><option value="xp-transparent">Transparent card</option><option value="glow-vibrant">Vibrant glass</option><option value="curve-minimal">Minimal panel</option></select></label>
                          <label><span>Avatar size</span><input type="range" min="48" max="112" step="2" :value="((activeTheme.loginScreenConfig || {}).avatarSize) || 72" @input="vm.themeStudioUpdateField('loginScreenConfig.avatarSize', +$event.target.value)"></label>
                          <label><span>Text color</span><input type="color" :value="((activeTheme.loginScreenConfig || {}).textColor) || '#ffffff'" @input="vm.themeStudioUpdateField('loginScreenConfig.textColor', $event.target.value)"></label>
                          <label><span>Warning heading</span><input type="text" :value="((activeTheme.loginScreenConfig || {}).warningTitle) || ''" @input="vm.themeStudioUpdateField('loginScreenConfig.warningTitle', $event.target.value)"></label>
                          <label class="span-2"><span>Privacy / warning message</span><textarea rows="4" :value="((activeTheme.loginScreenConfig || {}).privacyNotice) || ''" @input="vm.themeStudioUpdateField('loginScreenConfig.privacyNotice', $event.target.value)"></textarea></label>
                        </div>
                      </div>

                      <div class="mioos-theme-studio-panel-vue" v-else-if="tab.key === 'animation'">
                        <div class="mioos-theme-row-vue">
                          <label><span>Open animation</span><input type="range" min="100" max="500" step="10" :value="((activeTheme.animationSpeeds || {}).open) || 180" @input="vm.themeStudioUpdateField('animationSpeeds.open', +$event.target.value)"></label>
                          <label><span>Hover animation</span><input type="range" min="80" max="320" step="10" :value="((activeTheme.animationSpeeds || {}).hover) || 120" @input="vm.themeStudioUpdateField('animationSpeeds.hover', +$event.target.value)"></label>
                          <label><span>Menu animation</span><input type="range" min="100" max="420" step="10" :value="((activeTheme.animationSpeeds || {}).menu) || 160" @input="vm.themeStudioUpdateField('animationSpeeds.menu', +$event.target.value)"></label>
                          <label><span>Taskbar animation</span><input type="range" min="100" max="420" step="10" :value="((activeTheme.animationSpeeds || {}).taskbar) || 160" @input="vm.themeStudioUpdateField('animationSpeeds.taskbar', +$event.target.value)"></label>
                          <label><span>Wallpaper transition</span><input type="range" min="120" max="700" step="20" :value="((activeTheme.animationSpeeds || {}).wallpaper) || 280" @input="vm.themeStudioUpdateField('animationSpeeds.wallpaper', +$event.target.value)"></label>
                          <label><span>Minimize animation</span><input type="range" min="120" max="500" step="10" :value="((activeTheme.animationSpeeds || {}).minimize) || 180" @input="vm.themeStudioUpdateField('animationSpeeds.minimize', +$event.target.value)"></label>
                        </div>
                        <div class="mioos-theme-hint-vue">Animation timings update the preview live for windows, menus, wallpaper transitions, and the taskbar.</div>
                      </div>

                      <div class="mioos-theme-studio-panel-vue" v-else>
                        <div class="mioos-theme-row-vue">
                          <label><span>Class modifiers</span><input type="text" :value="vm.themeStudioClassModifiersText()" @input="vm.themeStudioSetClassModifiers($event.target.value)"></label>
                          <label><span>Extra CSS</span><textarea rows="6" :value="activeTheme.extraCss || ''" @input="vm.themeStudioUpdateField('extraCss', $event.target.value)"></textarea></label>
                          <label class="span-2"><span>Theme import / export JSON</span><textarea rows="12" :value="store.importBuffer || ''" @input="store.importBuffer = $event.target.value" placeholder="Export the active theme, fine-tune the JSON, then import it as a new detailed theme."></textarea></label>
                        </div>
                        <div class="mioos-theme-uploadbar-vue">
                          <button type="button" class="mioos-btn" @click="vm.themeStudioExportTheme(activeTheme.id)">Export active theme</button>
                          <button type="button" class="mioos-btn" @click="vm.themeStudioCopyImportBuffer()">Copy JSON</button>
                          <button type="button" class="mioos-btn" @click="vm.themeStudioImportTheme()">Import as new theme</button>
                        </div>
                        <div class="mioos-theme-hint-vue">The exported JSON now includes one shared theme plus exactly two variants: Light and Dark.</div>
                      </div>
                    </article>
                  </section>

                </section>

                <aside class="mioos-theme-studio-previewrail-vue">
                  <div class="tabs mioos-theme-tabs7 mioos-theme-previewtabs-vue">
                    <menu role="tablist" aria-label="Preview mode tabs">
                      <button role="tab" :aria-selected="vm.themeStudioPreviewTab() === 'desktop' ? 'true' : 'false'" @click="vm.themeStudioSetPreviewTab('desktop')">Desktop Preview</button>
                      <button role="tab" :aria-selected="vm.themeStudioPreviewTab() === 'mobile' ? 'true' : 'false'" @click="vm.themeStudioSetPreviewTab('mobile')">Mobile Preview</button>
                    </menu>
                    <article role="tabpanel">

                  <div class="mioos-theme-preview-card-vue" v-if="vm.themeStudioPreviewTab() === 'desktop'">
                    <strong>Desktop preview</strong>
                    <div class="mioos-theme-preview-stage-vue">
                      <div class="mioos-theme-preview-shell-vue" :class="['is-' + (activeTheme.base || 'win7'), 'style-' + vm.startMenuStyleType(), 'position-' + vm.taskbarPosition(), 'button-' + vm.taskbarButtonStyleType()]" :style="vm.themeStudioPreviewRootStyle()">
                        <div class="mioos-theme-preview-wallpaper-vue"></div>
                        <div class="mioos-theme-preview-icons-vue">
                          <div v-for="icon in previewIcons" :key="icon.key" class="mioos-theme-preview-icon-vue"><span>[[ icon.icon ]]</span><em>[[ icon.label ]]</em></div>
                        </div>
                        <section class="mioos-theme-preview-window-vue" :style="{ left: (previewWindow.x || 82) + 'px', top: (previewWindow.y || 64) + 'px', width: (previewWindow.w || 292) + 'px', height: (previewWindow.h || 190) + 'px' }">
                          <header class="mioos-theme-preview-titlebar-vue"><div class="mioos-theme-preview-titlecopy"><span>🗔</span><strong>[[ previewWindow.title || 'Sample Window' ]]</strong></div><div class="mioos-theme-preview-controls-vue"><i class="is-min"></i><i class="is-max"></i><i class="is-close"></i></div></header>
                          <div class="mioos-theme-preview-content-vue"><button type="button" class="mioos-btn">Action</button><label><span>Name</span><input type="text" value="Live preview" aria-label="Live preview input"></label><div class="mioos-theme-preview-menu-vue"><span>File</span><span>Edit</span><span>View</span></div></div>
                        </section>
                        <div class="mioos-theme-preview-startmenu-open-vue" :class="['style-' + vm.startMenuStyleType()]" v-if="activeTab === 'start' || activeTab === 'themes'">
                          <template v-if="vm.startMenuStyleType() === 'classic'">
                            <details v-for="group in groups" :key="group.key + '-preview'" :open="group.open">
                              <summary>[[ group.title ]]</summary>
                              <div class="mioos-theme-startmenu-mini-items-vue"><span v-for="item in group.items.slice(0, 3)" :key="item.key + '-preview'">[[ item.title ]]</span></div>
                            </details>
                          </template>
                          <template v-else>
                            <div class="mioos-theme-panelmenu-group-vue" v-for="group in groups" :key="group.key + '-preview-panel'">
                              <strong>[[ group.title ]]</strong>
                              <span v-for="item in group.items.slice(0, 3)" :key="item.key + '-preview'">[[ item.title ]]</span>
                            </div>
                          </template>
                        </div>
                        <div class="mioos-theme-login-preview-vue" v-if="activeTab === 'login'" :class="['style-' + (((activeTheme.loginScreenConfig || {}).loginBoxStyle) || 'xp-transparent')]">
                          <div class="mioos-theme-login-privacy-vue" v-if="((activeTheme.loginScreenConfig || {}).warningImageUrl) || ((activeTheme.loginScreenConfig || {}).warningTitle) || ((activeTheme.loginScreenConfig || {}).privacyNotice)"><img v-if="((activeTheme.loginScreenConfig || {}).warningImageUrl)" class="mioos-theme-warning-image-vue" :src="(activeTheme.loginScreenConfig || {}).warningImageUrl">
                            <strong>[[ ((activeTheme.loginScreenConfig || {}).warningTitle) || 'Privacy warning' ]]</strong>
                            <span>[[ ((activeTheme.loginScreenConfig || {}).privacyNotice) || 'Authorized use only.' ]]</span>
                          </div>
                          <div class="mioos-theme-login-card-vue">
                            <img v-if="((activeTheme.loginScreenConfig || {}).avatarUrl)" class="mioos-theme-login-avatar-img-vue" :src="(activeTheme.loginScreenConfig || {}).avatarUrl" :style="{ width: (((activeTheme.loginScreenConfig || {}).avatarSize) || 72) + 'px', height: (((activeTheme.loginScreenConfig || {}).avatarSize) || 72) + 'px' }">
                            <div v-else class="mioos-theme-login-avatar-vue" :style="{ width: (((activeTheme.loginScreenConfig || {}).avatarSize) || 72) + 'px', height: (((activeTheme.loginScreenConfig || {}).avatarSize) || 72) + 'px' }"></div>
                            <strong>User account</strong>
                            <button type="button" class="mioos-btn">Log On</button>
                          </div>
                        </div>
                        <footer class="mioos-theme-preview-taskbar-vue" :class="['button-' + vm.taskbarButtonStyleType()]"><button type="button" class="mioos-theme-preview-start-vue">Menu</button><div class="mioos-theme-preview-running-vue"><span></span><span></span><span></span></div><strong>4:00 PM</strong></footer>
                      </div>
                    </div>
                  </div>

                  <div class="mioos-theme-preview-card-vue is-mobile" v-else>
                    <strong>Mobile preview</strong>
                    <div class="mioos-theme-preview-stage-vue is-mobile">
                      <div class="mioos-theme-preview-shell-vue is-mobile" :class="['is-' + (activeTheme.base || 'win7'), 'style-' + vm.startMenuStyleType(), 'position-' + vm.taskbarPosition(), 'button-' + vm.taskbarButtonStyleType()]" :style="vm.themeStudioPreviewMobileRootStyle()">
                        <div class="mioos-theme-preview-wallpaper-vue"></div>
                        <div v-if="activeTab !== 'login'" class="mioos-theme-preview-icons-vue is-mobile">
                          <div v-for="icon in previewIcons.slice(0, 2)" :key="icon.key + '-mobile'" class="mioos-theme-preview-icon-vue"><span>[[ icon.icon ]]</span><em>[[ icon.label ]]</em></div>
                        </div>
                        <section v-if="activeTab !== 'login'" class="mioos-theme-preview-window-vue mobile-sample" :style="{ left: '18px', top: '88px', width: '178px', height: '160px' }">
                          <header class="mioos-theme-preview-titlebar-vue"><div class="mioos-theme-preview-titlecopy"><span>🗔</span><strong>Mail</strong></div><div class="mioos-theme-preview-controls-vue"><i class="is-min"></i><i class="is-max"></i><i class="is-close"></i></div></header>
                          <div class="mioos-theme-preview-content-vue"><label><span>Search</span><input type="text" value="Touch UI" aria-label="Touch UI"></label></div>
                        </section>
                        <div class="mioos-theme-login-preview-vue is-mobile" v-if="activeTab === 'login'" :class="['style-' + (((activeTheme.loginScreenConfig || {}).loginBoxStyle) || 'xp-transparent')]">
                          <div class="mioos-theme-login-privacy-vue" v-if="((activeTheme.loginScreenConfig || {}).warningImageUrl) || ((activeTheme.loginScreenConfig || {}).warningTitle) || ((activeTheme.loginScreenConfig || {}).privacyNotice)"><img v-if="((activeTheme.loginScreenConfig || {}).warningImageUrl)" class="mioos-theme-warning-image-vue" :src="(activeTheme.loginScreenConfig || {}).warningImageUrl">
                            <strong>[[ ((activeTheme.loginScreenConfig || {}).warningTitle) || 'Privacy warning' ]]</strong>
                            <span>[[ ((activeTheme.loginScreenConfig || {}).privacyNotice) || 'Authorized use only.' ]]</span>
                          </div>
                          <div class="mioos-theme-login-card-vue">
                            <img v-if="((activeTheme.loginScreenConfig || {}).avatarUrl)" class="mioos-theme-login-avatar-img-vue" :src="(activeTheme.loginScreenConfig || {}).avatarUrl" :style="{ width: (((activeTheme.loginScreenConfig || {}).avatarSize) || 64) + 'px', height: (((activeTheme.loginScreenConfig || {}).avatarSize) || 64) + 'px' }">
                            <div v-else class="mioos-theme-login-avatar-vue" :style="{ width: (((activeTheme.loginScreenConfig || {}).avatarSize) || 64) + 'px', height: (((activeTheme.loginScreenConfig || {}).avatarSize) || 64) + 'px' }"></div>
                            <strong>User account</strong>
                            <button type="button" class="mioos-btn">Log On</button>
                          </div>
                        </div>
                        <footer class="mioos-theme-preview-taskbar-vue" :class="['button-' + vm.taskbarButtonStyleType()]"><button type="button" class="mioos-theme-preview-start-vue">●</button><div class="mioos-theme-preview-running-vue"><span></span><span></span></div><strong>9:41</strong></footer>
                      </div>
                    </div>
                  </div>
                    </article>
                  </div>
                </aside>
              </div>

              <footer class="mioos-theme-studio-footer-vue">
                <div class="mioos-theme-studio-footer-copy-vue">Live preview updates immediately. Apply writes the current theme to the desktop; Save persists and closes.</div>
                <div class="mioos-theme-studio-footer-actions-vue">
                  <button type="button" class="mioos-btn" @click="vm.themeStudioCancel()">Cancel</button>
                  <button type="button" class="mioos-btn" @click="vm.themeStudioApplyToDesktop(activeTheme.id)">Apply</button>
                  <button type="button" class="mioos-btn is-primary" @click="vm.themeStudioSaveCustomTheme()">Save</button>
                </div>
              </footer>
            </div>
          </div>
`
      });

      app.component('mioos-surface-system-settings', {
        props: ['window'],
        computed: {
          vm: function () { return root(this); },
          groups: function () { return this.vm.systemSettingsGroupRows ? this.vm.systemSettingsGroupRows() : []; },
          activeGroup: function () { return this.vm.systemSettingsActiveGroup ? this.vm.systemSettingsActiveGroup() : { key: 'modules', title: 'Settings', description: '' }; },
          settings: function () { return this.vm.systemSettingsRowsForGroup ? this.vm.systemSettingsRowsForGroup(this.activeGroup.key) : []; },
          state: function () { return this.vm.systemSettings || {}; },
          canSave: function () { return !!((((this.state || {}).payload || {}).canSave)); }
        },
        mounted: function () {
          if (this.vm.systemSettingsLoad && !((this.state.payload || {}).settings || []).length) this.vm.systemSettingsLoad().catch(function () {});
        },
        methods: {
          setGroup: function (group) { this.vm.systemSettings.activeGroup = group.key; },
          inputId: function (setting) { return this.vm.systemSettingsInputId ? this.vm.systemSettingsInputId(setting) : setting.key; },
          summary: function (setting) { return this.vm.systemSettingsSettingSummary ? this.vm.systemSettingsSettingSummary(setting) : ''; },
          valueOf: function (setting) { return this.vm.systemSettingsDraftValue ? this.vm.systemSettingsDraftValue(setting) : setting.value; },
          setValue: function (setting, value) { if (this.vm.systemSettingsSetDraft) this.vm.systemSettingsSetDraft(setting, value); }
        },
        template: `
          <div class="mioos-surface mioos-surface-system-settings" role="region" aria-label="MIOOS System Settings">
            <header class="mioos-settings-head">
              <div><strong>System Settings</strong><span>Server-backed MIOOS configuration with explanations, validation, and admin safeguards.</span></div>
              <div class="mioos-settings-actions">
                <button type="button" class="mioos-btn" :disabled="state.loading || state.saving" @click="vm.systemSettingsLoad && vm.systemSettingsLoad()">Refresh</button>
                <button type="button" class="mioos-btn" :disabled="state.loading || state.saving" @click="vm.systemSettingsResetDraft && vm.systemSettingsResetDraft()">Reset draft</button>
                <button type="button" class="mioos-btn is-primary" :disabled="!canSave || state.loading || state.saving" @click="vm.systemSettingsSave && vm.systemSettingsSave()">[[ state.saving ? 'Saving…' : 'Save settings' ]]</button>
              </div>
            </header>
            <div class="mioos-settings-notice" v-if="!canSave">Only administrators can save settings. Values are still shown so operators can inspect the active contract.</div>
            <div class="mioos-settings-status is-error" v-if="state.error">[[ state.error ]]</div>
            <div class="mioos-settings-status" v-if="state.status">[[ state.status ]]</div>
            <div class="mioos-settings-loading" v-if="state.loading">Loading settings from the server…</div>
            <div class="mioos-settings-layout" v-else>
              <nav class="mioos-settings-tabs" aria-label="MIOOS setting groups">
                <button v-for="group in groups" :key="group.key" type="button" :class="{ 'is-active': activeGroup.key === group.key }" @click="setGroup(group)"><strong>[[ group.title ]]</strong><span>[[ group.description ]]</span></button>
              </nav>
              <section class="mioos-settings-panel" :aria-labelledby="'settings-group-' + activeGroup.key">
                <div class="mioos-settings-panel-title"><strong :id="'settings-group-' + activeGroup.key">[[ activeGroup.title ]]</strong><span>[[ activeGroup.description ]]</span></div>
                <article class="mioos-settings-row" v-for="setting in settings" :key="setting.key">
                  <div class="mioos-settings-copy">
                    <label :for="inputId(setting)">[[ setting.title ]]</label>
                    <p>[[ setting.description ]]</p>
                    <small>[[ summary(setting) ]]</small>
                    <code>[[ setting.path ]]</code>
                  </div>
                  <div class="mioos-settings-control">
                    <label v-if="setting.type === 'boolean'" class="mioos-settings-switch">
                      <input :id="inputId(setting)" type="checkbox" :checked="!!(+valueOf(setting))" :disabled="!canSave || state.saving" @change="setValue(setting, $event.target.checked)">
                      <span>[[ !!(+valueOf(setting)) ? 'Enabled' : 'Disabled' ]]</span>
                    </label>
                    <select v-else-if="setting.type === 'enum'" :id="inputId(setting)" :value="valueOf(setting)" :disabled="!canSave || state.saving" @change="setValue(setting, $event.target.value)">
                      <option v-for="option in setting.enum" :key="option" :value="option">[[ option ]]</option>
                    </select>
                    <input v-else-if="setting.type === 'integer'" :id="inputId(setting)" type="number" :min="setting.min" :max="setting.max" step="1" :value="valueOf(setting)" :disabled="!canSave || state.saving" @input="setValue(setting, $event.target.value)">
                    <input v-else :id="inputId(setting)" type="text" :value="valueOf(setting)" :disabled="true">
                    <span class="mioos-settings-current">Current: [[ setting.value ]]</span>
                  </div>
                </article>
                <div class="mioos-settings-empty" v-if="!settings.length">No settings are registered for this group.</div>
              </section>
            </div>
          </div>`
      });

      app.component('mioos-surface-transfers', {
        props: ['window'],
        computed: {
          vm: function () { return root(this); },
          rows: function () { return this.vm.transferQueueRows ? this.vm.transferQueueRows(12) : (this.vm.activeTransfers ? this.vm.activeTransfers() : []); },
          completed: function () { return this.vm.completedTransfers ? this.vm.completedTransfers() : []; }
        },
        template: '' +
          '<div class="mioos-surface mioos-surface-transfers">' +
            '<div class="mioos-classic-shell mioos-classic-transfers">' +
              '<div class="mioos-classic-panelhead">' +
                '<div><strong>File Transfer</strong><span>Queue progress, per-file activity, drag and drop uploads, and recovery actions.</span></div>' +
                '<div class="mioos-classic-toolbar-group">' +
                  '<button type="button" class="mioos-classic-tool" @click="vm.pauseAllTransfers && vm.pauseAllTransfers()">Pause All</button>' +
                  '<button type="button" class="mioos-classic-tool" @click="vm.resumePausedTransfers && vm.resumePausedTransfers()">Resume</button>' +
                  '<button type="button" class="mioos-classic-tool" @click="vm.cancelActiveTransfers && vm.cancelActiveTransfers()">Cancel Active</button>' +
                  '<button type="button" class="mioos-classic-tool" @click="vm.clearFinishedTransfers && vm.clearFinishedTransfers()">Clear Finished</button>' +
                '</div>' +
              '</div>' +
              '<div class="mioos-classic-transferstack">' +
                '<section class="mioos-classic-transferoverview">' +
                  '<div class="mioos-classic-transferoverview-copy mioos-classic-transferfacts"><strong>[[ vm.transferSummaryText ? vm.transferSummaryText() : \'No transfers\' ]]</strong><span>[[ vm.transferActiveCount ? vm.transferActiveCount() : rows.length ]] active • [[ vm.transferPausedCount ? vm.transferPausedCount() : 0 ]] paused • [[ vm.transferCompletedCount ? vm.transferCompletedCount() : completed.length ]] completed • [[ vm.transferFailedCount ? vm.transferFailedCount() : 0 ]] failed</span></div>' +
                  '<div class="mioos-classic-progress mioos-classic-progress--overall"><span :style="{ width: ((vm.overallTransferPercent ? vm.overallTransferPercent() : 0) + \'%\') }"></span></div>' +
                '</section>' +
                '<div class="mioos-classic-queue" v-if="rows.length">' +
                  '<div class="mioos-classic-queuerow is-head"><div>Name</div><div>Path</div><div>Progress</div><div>Status</div><div>Size</div></div>' +
                  '<div class="mioos-classic-transferrow" v-for="item in rows" :key="item.id" :data-status="item.status" :class="{ \'is-active\': [\'uploading\',\'downloading\',\'preparing\',\'finalizing\',\'verifying\'].indexOf(item.status) >= 0, \'is-success\': item.status === \'completed\', \'is-warning\': item.status === \'paused\' || item.status === \'queued\', \'is-error\': item.status === \'failed\' || item.status === \'cancelled\' }">' +
                    '<div class="mioos-classic-transfercopy"><strong :title="item.name">[[ item.name ]]</strong><small>[[ vm.transferTimestampLabel ? vm.transferTimestampLabel(item) : \'\' ]]</small></div>' +
                    '<div class="mioos-classic-queuepath" :title="vm.transferDirectionLabel ? vm.transferDirectionLabel(item) : item.kind">[[ vm.transferDirectionLabel ? vm.transferDirectionLabel(item) : item.kind ]]</div>' +
                    '<div class="mioos-classic-transferprogresscell"><div class="mioos-classic-progress"><span :style="{ width: ((vm.transferPercent ? vm.transferPercent(item) : (item.progress || 0)) + \'%\') }"></span></div><small class="mioos-classic-transferstatus">[[ vm.transferProgressLabel ? vm.transferProgressLabel(item) : ((item.progress || 0) + \'%\') ]]</small></div>' +
                    '<div class="mioos-classic-transferstatuscell">[[ vm.transferStatusCaption ? vm.transferStatusCaption(item) : (item.stage || item.status) ]]</div>' +
                    '<div class="mioos-classic-transfersize">[[ vm.formatBytesCompact ? vm.formatBytesCompact(item.totalBytes || 0) : (item.totalBytes || 0) ]]</div>' +
                    '<div class="mioos-classic-transferactions"><button type="button" class="mioos-classic-tool" v-if="vm.canPauseTransfer && vm.canPauseTransfer(item)" @click="vm.pauseTransfer(item)">Pause</button><button type="button" class="mioos-classic-tool" v-if="vm.canResumeTransfer && vm.canResumeTransfer(item)" @click="vm.resumeTransfer(item)">Resume</button><button type="button" class="mioos-classic-tool" v-if="vm.canRetryTransfer && vm.canRetryTransfer(item)" @click="vm.retryTransfer(item)">Retry</button><button type="button" class="mioos-classic-tool danger" v-if="vm.canCancelTransfer && vm.canCancelTransfer(item)" @click="vm.cancelTransfer(item)">Cancel</button></div>' +
                  '</div>' +
                '</div>' +
                '<div class="mioos-classic-empty" v-else>No transfer activity yet.</div>' +
                '<div class="mioos-classic-historylist" v-if="completed.length">' +
                  '<article class="mioos-classic-historyrow" v-for="item in completed" :key="item.id"><div class="mioos-classic-transfercopy"><strong>[[ item.name ]]</strong><small>[[ vm.transferDirectionLabel ? vm.transferDirectionLabel(item) : item.kind ]]</small></div><span class="mioos-classic-historystatus" :class="{ \'is-failed\': item.status === \'failed\' }">[[ item.status ]]</span><small>[[ vm.transferTimestampLabel ? vm.transferTimestampLabel(item) : \'\' ]]</small><button type="button" class="mioos-classic-tool" v-if="vm.canRetryTransfer && vm.canRetryTransfer(item)" @click="vm.retryTransfer(item)">Retry</button><button type="button" class="mioos-classic-tool" v-if="vm.canCancelTransfer && vm.canCancelTransfer(item)" @click="vm.cancelTransfer(item)">Cancel</button></article>' +
                '</div>' +
              '</div>' +
            '</div>' +
          '</div>'
      });

      app.component('mioos-surface-generic', {

        props: ['window'],
        computed: {
          vm: function () { return root(this); },
          summaryRows: function () {
            return [
              { label: 'App key', value: this.window.appKey || 'app' },
              { label: 'Window id', value: this.window.id || 'window' },
              { label: 'Theme', value: this.vm.activeThemeKey || (((this.vm.boot || {}).desktop || {}).themeKey) || 'xp-classic-blue' },
              { label: 'Profile', value: ((this.vm.boot || {}).product || {}).profile || 'dev' }
            ];
          }
        },
        template: '' +
          '<div class="mioos-surface mioos-surface-generic">' +
            '<div class="mioos-generic-hero"><strong>[[ window.title ]]</strong><span>This app surface is intentionally minimal while the shell primitives are being rebuilt.</span></div>' +
            '<div class="mioos-generic-grid">' +
              '<article v-for="row in summaryRows" :key="row.label" class="mioos-generic-card"><strong>[[ row.label ]]</strong><span>[[ row.value ]]</span></article>' +
            '</div>' +
          '</div>'
      });

      app.component('start-menu-popup', {
        computed: {
          vm: function () { return root(this); },
          entries: function () { return this.vm.filteredEntries || []; },
          groups: function () { return this.vm.startMenuGroups(); },
          selectedKey: function () { this.vm.startMenuEnsureSelection(); return ((this.vm.startMenuUi || {}).selectedKey) || ""; }
        },
        template: '' +
          '<aside class="mioos-start-menu-vue" :class="[\'is-\' + vm.currentShellThemeFamily(), \'style-\' + vm.startMenuStyleType(), \'position-\' + vm.taskbarPosition(), \'button-\' + vm.taskbarButtonStyleType()]" :style="vm.startMenuPopupStyle()" tabindex="-1" @keydown="vm.startMenuHandleKeydown($event)" @click.stop>' +
            '<div class="mioos-start-head-vue"><div class="mioos-start-avatar-vue">M</div><div><strong>[[ vm.boot.product.name ]]</strong><span>[[ vm.boot.product.subtitle ]]</span></div></div>' +
            '<label class="mioos-start-search-vue"><span>⌕</span><input v-model="vm.menuFilter" type="text" :placeholder="vm.t(\'search.placeholder\')" @keydown="vm.startMenuHandleKeydown($event)"></label>' +
            '<div class="mioos-start-body-vue" v-if="vm.startMenuStyleType() === \'classic\'">' +
              '<div class="mioos-start-list-vue">' +
                '<details v-for="group in groups" :key="group.key" class="mioos-start-group-vue" :open="group.open">' +
                  '<summary><strong>[[ group.title ]]</strong><span>[[ group.subtitle ]]</span></summary>' +
                  '<div class="mioos-start-group-items-vue">' +
                    '<button v-for="item in group.items" :key="item.key" type="button" class="mioos-start-entry-vue" @click="vm.startMenuOpenItem(item)" :class="{ \'is-selected\': selectedKey === item.key, \'is-disabled\': item.disabled }" :disabled="item.disabled"><span class="mioos-start-entry-icon">[[ item.icon ]]</span><span><strong>[[ item.title ]]</strong><em>[[ item.subtitle || item.key ]]</em></span></button>' +
                  '</div>' +
                '</details>' +
              '</div>' +
              '<aside class="mioos-start-side-vue">' +
                '<strong>Pinned</strong>' +
                '<button v-for="entry in entries.slice(0, 6)" :key="entry.key" type="button" class="mioos-chip-btn" @click="vm.startMenuOpenItem(entry)">[[ entry.title ]]</button>' +
                '<strong>Themes</strong>' +
                '<button v-for="theme in vm.shellThemeOptions()" :key="theme.key" type="button" class="mioos-chip-btn" :class="{ \'is-active\': vm.activeThemeKey === theme.key }" @click="vm.applyShellTheme(theme.key)">[[ theme.label ]]</button>' +
                '<strong>Language</strong>' +
                '<button v-for="locale in vm.localeOptions" :key="locale.code" type="button" class="mioos-chip-btn" :class="{ \'is-active\': (vm.currentLocale || {}).code === locale.code }" @click="vm.changeLocale(locale.code)">[[ locale.label ]]</button>' +
              '</aside>' +
            '</div>' +
            '<div class="mioos-start-panel-vue mioos-start-popup-vue" v-else>' +
              '<div class="mioos-start-panel-group-vue" v-for="group in groups" :key="group.key">' +
                '<strong>[[ group.title ]]</strong>' +
                '<button v-for="item in group.items" :key="item.key" type="button" class="mioos-start-entry-vue" @click="vm.startMenuOpenItem(item)" :class="{ \'is-selected\': selectedKey === item.key, \'is-disabled\': item.disabled }" :disabled="item.disabled"><span class="mioos-start-entry-icon">[[ item.icon ]]</span><span><strong>[[ item.title ]]</strong><em>[[ item.subtitle || item.key ]]</em></span></button>' +
              '</div>' +
            '</div>' +
            '<div class="mioos-start-user-vue" v-if="vm.authEnabled">' +
              '<template v-if="vm.boot.user.authenticated"><span>[[ (vm.boot.user || {}).displayName || \'User\' ]]</span><button type="button" class="mioos-btn" @click="vm.submitSignout">[[ vm.t(\'auth.signout\') ]]</button></template>' +
              '<template v-else><label class="mioos-auth-field compact"><span>[[ vm.t(\'auth.username\') ]]</span><input v-model="vm.authForm.username" type="text"></label><label class="mioos-auth-field compact"><span>[[ vm.t(\'auth.password\') ]]</span><input v-model="vm.authForm.password" type="password"></label><button type="button" class="mioos-btn" @click="vm.submitSignin">[[ vm.t(\'auth.signin\') ]]</button></template>' +
            '</div>' +
          '</aside>'
      });

      app.component('taskbar-shell', {
        computed: {
          vm: function () { return root(this); },
          windows: function () { return this.vm.taskbarWindows || []; },
          pinnedApps: function () { return (this.vm.launcherEntries || []).slice(0, 5); }
        },
        template: '' +
          '<footer class="mioos-taskbar-vue" :class="[\'is-\' + vm.currentShellThemeFamily(), \'position-\' + vm.taskbarPosition(), \'button-\' + vm.taskbarButtonStyleType()]" :style="vm.taskbarShellStyle()">' +
            '<button type="button" class="mioos-start-button-vue" @click.stop="vm.toggleMenu()"><span>◫</span><strong>[[ (vm.boot.desktop || {}).launcherLabel || \'Menu\' ]]</strong></button>' +
            '<div class="mioos-taskbar-pinned-vue">' +
              '<button v-for="app in pinnedApps" :key="app.key" type="button" class="mioos-task-icon-vue" :title="app.title" @click.stop="vm.openApp(app.key)"><span>[[ app.icon ]]</span></button>' +
            '</div>' +
            '<div class="mioos-taskbar-windows-vue">' +
              '<button v-for="win in windows" :key="win.id" type="button" class="mioos-task-item-vue" :class="{ \'is-active\': vm.activeWindowId === win.id && win.state !== \'minimized\' }" @click.stop="vm.taskbarToggle(win.id)"><span class="mioos-task-item-icon">[[ vm.appIcon(win.appKey) ]]</span><span class="mioos-task-item-title">[[ win.title ]]</span></button>' +
            '</div>' +
            '<div class="mioos-taskbar-tray-vue">' +
              '<button type="button" class="mioos-task-icon-vue" title="Show Desktop" @click.stop="vm.showDesktop()">⌄</button>' +
              '<button type="button" class="mioos-task-icon-vue" title="Theme Studio" @click.stop="vm.openApp(\'theme-studio\')">🎨</button>' +
              '<button type="button" class="mioos-task-clock-vue" @click.stop="vm.refreshView">[[ vm.clockText ]]</button>' +
            '</div>' +
          '</footer>'
      });

      app.component('popup-menu', {
        computed: {
          vm: function () { return root(this); },
          menu: function () { return this.vm.desktopContextMenuState(); }
        },
        template: '' +
          '<section class="mioos-popup-menu-vue" :style="vm.contextMenuStyle()" @click.stop>' +
            '<template v-if="menu.type === \'icon\'">' +
              '<button type="button" class="mioos-popup-action" @click="vm.contextOpenSelected()">Open</button>' +
              '<button type="button" class="mioos-popup-action" @click="vm.desktopRenameSelected()">Rename</button><button type="button" class="mioos-popup-action" @click="vm.contextDeleteIcon()">Delete</button>' +
              '<div class="mioos-popup-separator"></div>' +
            '</template>' +
            '<button type="button" class="mioos-popup-action" @click="vm.desktopCreateFolder()">New Folder</button><button type="button" class="mioos-popup-action" @click="vm.desktopCreateTextFile()">New Text File</button><div class="mioos-popup-separator"></div>' +
            '<button type="button" class="mioos-popup-action" @click="vm.refreshDesktopIcons()">Refresh</button>' +
            '<button type="button" class="mioos-popup-action" @click="vm.rearrangeDesktopIcons()">Rearrange Icons</button>' +
            '<button type="button" class="mioos-popup-action" @click="vm.sortDesktopEntries(\'name\')">Sort by Name</button>' +
            '<button type="button" class="mioos-popup-action" @click="vm.sortDesktopEntries(\'type\')">Sort by Type</button>' +
            '<div class="mioos-popup-separator"></div>' +
            '<button type="button" class="mioos-popup-action" @click="vm.setDesktopIconSize(\'small\'); vm.closeDesktopContextMenu()">Small Icons</button>' +
            '<button type="button" class="mioos-popup-action" @click="vm.setDesktopIconSize(\'medium\'); vm.closeDesktopContextMenu()">Medium Icons</button>' +
            '<button type="button" class="mioos-popup-action" @click="vm.setDesktopIconSize(\'large\'); vm.closeDesktopContextMenu()">Large Icons</button>' +
            '<div class="mioos-popup-separator"></div>' +
            '<button type="button" class="mioos-popup-action" @click="vm.contextPersonalize()">Personalize</button>' +
            '<button type="button" class="mioos-popup-action" @click="vm.contextControlPanel()">Control Panel</button>' +
          '</section>'
      });
    }
  };
})();
