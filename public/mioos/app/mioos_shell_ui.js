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

  function surfaceComponentKey(win) {
    var key = String((win || {}).appKey || 'generic');
    if (key === 'my-computer' || key === 'documents' || key === 'explorer') return 'mioos-surface-explorer';
    if (key === 'terminal') return 'mioos-surface-terminal';
    if (key === 'theme-studio') return 'mioos-surface-theme';
    if (key === 'text-viewer' || key === 'image-viewer' || key === 'media-viewer' || key === 'pdf-viewer' || key === 'structured-viewer') return 'mioos-surface-viewer';
    if (key === 'transfers') return 'mioos-surface-transfers';
    return 'mioos-surface-generic';
  }

  window.MIOOSShellUI = {
    register: function (app) {
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
                  '<div class="mioos-auth-actions">' +
                    '<button type="button" class="mioos-auth-primary" @click="vm.submitSignin">[[ vm.t(\'auth.signin\') ]]</button>' +
                    '<button type="button" v-if="vm.boot.auth.guestLoginEnabled" @click="vm.submitGuestSignin">[[ vm.t(\'auth.continueGuest\') ]]</button>' +
                  '</div>' +
                '</template>' +
                '<template v-else>' +
                  '<p class="mioos-auth-copy">Password rotation is required before shell access can continue.</p>' +
                  '<label class="mioos-auth-field"><span>New password</span><input v-model="vm.authPasswordChange.newPassword" type="password" autocomplete="new-password"></label>' +
                  '<label class="mioos-auth-field"><span>Confirm password</span><input v-model="vm.authPasswordChange.confirmPassword" type="password" autocomplete="new-password"></label>' +
                  '<div class="mioos-auth-actions"><button type="button" class="mioos-auth-primary" @click="vm.submitPasswordChange">Change password</button></div>' +
                '</template>' +
              '</div>' +
            '</section>' +
            '<start-menu-popup v-if="vm.menuOpen"></start-menu-popup>' +
            '<popup-menu v-if="vm.desktopContextMenuState().open"></popup-menu>' +
            '<div v-if="vm.snapPreview.active" class="mioos-snap-preview" :data-snap-zone="vm.snapPreview.zone" :style="vm.snapPreviewStyle()"></div>' +
            '<div class="mioos-desktop-surface" :class="{ \'pointer-events-none\': vm.dragState.active }">' +
              '<desktop-icon v-for="entry in vm.desktopEntries" :key="entry.key" :icon="entry"></desktop-icon>' +
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
          onOpen: function () { this.vm.openApp(this.icon.key); }
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
            if ((win.appKey === 'my-computer' || win.appKey === 'documents' || win.appKey === 'explorer') && vm.bootstrapExplorerWindow) {
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
          items: function () { return (this.state && this.state.items) || []; },
          preview: function () { return (this.state && this.state.preview) || {}; }
        },
        mounted: function () { this.vm.bootstrapExplorerWindow(this.window.id, false); },
        methods: {
          select: function (item) { this.vm.selectExplorerItem(this.window.id, item); },
          open: function (item) { this.vm.explorerOpenItem(this.window.id, item); }
        },
        template: '' +
          '<div class="mioos-surface mioos-surface-explorer">' +
            '<div class="mioos-surface-toolbar">' +
              '<button type="button" class="mioos-btn" @click="vm.explorerGoUp(window.id)">Up</button>' +
              '<button type="button" class="mioos-btn" @click="vm.refreshExplorerWindow(window.id)">Refresh</button>' +
              '<button type="button" class="mioos-btn" @click="vm.explorerPromptUpload(window.id)">Upload</button>' +
              '<button type="button" class="mioos-btn" @click="vm.explorerCreateFolder(window.id)">New Folder</button>' +
              '<button type="button" class="mioos-btn" :disabled="!state.selection" @click="vm.explorerRenameSelected(window.id)">Rename</button>' +
              '<button type="button" class="mioos-btn is-danger" :disabled="!state.selection" @click="vm.explorerDeleteSelected(window.id)">Delete</button>' +
            '</div>' +
            '<div class="mioos-addressbar-vue"><span>[[ (state.folder || {}).path || \'/\' ]]</span></div>' +
            '<div class="mioos-explorer-grid-vue">' +
              '<aside class="mioos-explorer-sidebar-vue">' +
                '<strong>Details</strong>' +
                '<template v-if="state.selection">' +
                  '<span>[[ state.selection.name || state.selection.title ]]</span>' +
                  '<span>[[ state.selection.kind || state.selection.type || \'file\' ]]</span>' +
                  '<span>[[ state.selection.mime || \'application/octet-stream\' ]]</span>' +
                  '<span>[[ state.selection.sizeLabel || state.selection.sizeBytes || \'—\' ]]</span>' +
                '</template>' +
                '<span v-else>Select a file to preview it.</span>' +
              '</aside>' +
              '<section class="mioos-explorer-list-vue">' +
                '<div class="mioos-explorer-empty" v-if="state.loading">Loading folder…</div>' +
                '<div class="mioos-explorer-empty" v-else-if="state.error">[[ state.error ]]</div>' +
                '<div class="mioos-explorer-empty" v-else-if="!items.length">This folder is empty.</div>' +
                '<button v-for="item in items" :key="item.id || item.key" type="button" class="mioos-explorer-row-vue" :class="{ \'is-selected\': state.selection && (state.selection.id || state.selection.key) === (item.id || item.key) }" @click="select(item)" @dblclick="open(item)">' +
                  '<span class="mioos-explorer-row-icon">[[ vm.explorerItemGlyph(item) ]]</span>' +
                  '<span class="mioos-explorer-row-main"><strong>[[ item.name || item.title ]]</strong><em>[[ item.mime || item.kind || item.type || \'file\' ]]</em></span>' +
                  '<span class="mioos-explorer-row-size">[[ item.sizeLabel || item.sizeBytes || \'\' ]]</span>' +
                '</button>' +
              '</section>' +
              '<aside class="mioos-explorer-preview-vue">' +
                '<strong>[[ preview.title || \'Preview\' ]]</strong>' +
                '<pre v-if="preview.content" class="mioos-preview-pre">[[ preview.content ]]</pre>' +
                '<img v-else-if="preview.imageSrc" :src="preview.imageSrc" alt="Preview" class="mioos-preview-image">' +
                '<video v-else-if="preview.mediaSrc && preview.mediaKind === \'video\'" :src="preview.mediaSrc" controls class="mioos-preview-media"></video>' +
                '<audio v-else-if="preview.mediaSrc && preview.mediaKind === \'audio\'" :src="preview.mediaSrc" controls class="mioos-preview-media"></audio>' +
                '<div v-else class="mioos-explorer-empty">Pick a supported file to preview it here.</div>' +
              '</aside>' +
            '</div>' +
          '</div>'
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
        computed: {
          vm: function () { return root(this); },
          store: function () { return this.vm.initThemeStudioStore(); },
          activeTheme: function () { return this.vm.themeStudioActiveTheme() || {}; },
          themeList: function () { return this.vm.themeStudioThemeList(); },
          previewIcons: function () { return this.vm.themeStudioPreviewIcons(); },
          previewWindow: function () { return (this.store && this.store.previewWindowState) || {}; },
          tabs: function () { return this.vm.themeStudioTabs(); },
          activeTab: function () { return this.vm.themeStudioActiveTab(); }
        },
        template: `
          <div class="mioos-surface mioos-surface-theme">
            <div class="mioos-theme-studio-vue">
              <header class="mioos-theme-studio-toolbar-vue">
                <div class="mioos-theme-studio-toolbar-copy"><strong>Theme Studio</strong><span>Live authoring for shell chrome, wallpaper, windows, taskbar, menus, and icon labels.</span></div>
                <div class="mioos-theme-studio-toolbar-actions">
                  <button type="button" class="mioos-btn" @click="vm.themeStudioDuplicateTheme(activeTheme.id)">Duplicate</button>
                  <button type="button" class="mioos-btn" @click="vm.themeStudioCreateNewTheme('New Theme')">Save as New</button>
                  <button type="button" class="mioos-btn" @click="vm.themeStudioResetToBase()">Reset to Base</button>
                  <button type="button" class="mioos-btn" @click="vm.themeStudioExportTheme(activeTheme.id)">Export</button>
                  <button type="button" class="mioos-btn" @click="vm.themeStudioImportTheme()">Import</button>
                  <button type="button" class="mioos-btn is-primary" @click="vm.themeStudioApplyToDesktop(activeTheme.id)">Apply to Desktop</button>
                </div>
              </header>
              <div class="mioos-theme-studio-layout-vue">
                <aside class="mioos-theme-studio-sidebar-vue">
                  <div class="mioos-theme-studio-sidebar-head"><strong>Themes</strong><span>Base presets remain locked. Editing one automatically forks it into a custom draft.</span></div>
                  <div class="mioos-theme-studio-list-vue">
                    <button v-for="theme in themeList" :key="theme.id" type="button" class="mioos-theme-studio-themecard" :class="{ 'is-active': vm.themeStudioIsActive(theme.id) }" @click="vm.themeStudioActivate(theme.id, { persist: false, silent: true })">
                      <span class="mioos-theme-studio-themechip">[[ (theme.base || 'win7').toUpperCase() ]]</span>
                      <strong>[[ theme.name ]]</strong>
                      <em>[[ theme.locked ? 'Base theme' : 'Custom theme' ]]</em>
                    </button>
                  </div>
                  <div class="mioos-theme-studio-quick-vue">
                    <strong>Load base preset</strong>
                    <div class="mioos-theme-studio-quick-grid">
                      <button type="button" class="mioos-chip-btn" @click="vm.themeStudioLoadBaseTheme('windows-xp')">Windows XP</button>
                      <button type="button" class="mioos-chip-btn" @click="vm.themeStudioLoadBaseTheme('windows-7')">Windows 7</button>
                      <button type="button" class="mioos-chip-btn" @click="vm.themeStudioLoadBaseTheme('mac-os')">macOS</button>
                      <button type="button" class="mioos-chip-btn" @click="vm.themeStudioLoadBaseTheme('ubuntu')">Ubuntu</button>
                    </div>
                  </div>
                </aside>
                <section class="mioos-theme-studio-preview-vue">
                  <div class="mioos-theme-preview-stage-vue">
                    <div class="mioos-theme-preview-shell-vue" :class="['is-' + (activeTheme.base || 'win7')]" :style="vm.themeStudioPreviewRootStyle()">
                      <div class="mioos-theme-preview-wallpaper-vue"></div>
                      <div class="mioos-theme-preview-icons-vue">
                        <div v-for="icon in previewIcons" :key="icon.key" class="mioos-theme-preview-icon-vue"><span>[[ icon.icon ]]</span><em>[[ icon.label ]]</em></div>
                      </div>
                      <section class="mioos-theme-preview-window-vue" :style="{ left: (previewWindow.x || 82) + 'px', top: (previewWindow.y || 64) + 'px', width: (previewWindow.w || 292) + 'px', height: (previewWindow.h || 190) + 'px' }">
                        <header class="mioos-theme-preview-titlebar-vue"><div class="mioos-theme-preview-titlecopy"><span>🗔</span><strong>[[ previewWindow.title || 'Sample Window' ]]</strong></div><div class="mioos-theme-preview-controls-vue"><i class="is-min"></i><i class="is-max"></i><i class="is-close"></i></div></header>
                        <div class="mioos-theme-preview-content-vue"><button type="button" class="mioos-btn">Action</button><label><span>Name</span><input type="text" value="Live preview" aria-label="Live preview input"></label><div class="mioos-theme-preview-menu-vue"><span>File</span><span>Edit</span><span>View</span></div></div>
                      </section>
                      <footer class="mioos-theme-preview-taskbar-vue"><button type="button" class="mioos-theme-preview-start-vue">Menu</button><div class="mioos-theme-preview-running-vue"><span></span><span></span><span></span></div><strong>4:00 PM</strong></footer>
                    </div>
                  </div>
                </section>
                <section class="mioos-theme-studio-editor-vue">
                  <div class="mioos-theme-studio-tabs-vue">
                    <button v-for="tab in tabs" :key="tab.key" type="button" class="mioos-chip-btn" :class="{ 'is-active': activeTab === tab.key }" @click="vm.themeStudioSetTab(tab.key)">[[ tab.label ]]</button>
                  </div>
                  <div class="mioos-theme-studio-panel-vue" v-if="activeTab === 'global'">
                    <div class="mioos-field-grid two-col">
                      <label><span>Theme name</span><input type="text" :value="activeTheme.name || ''" @input="vm.themeStudioUpdateField('name', $event.target.value)"></label>
                      <label><span>Font stack</span><input type="text" :value="activeTheme.fontStack || ''" @input="vm.themeStudioUpdateField('fontStack', $event.target.value)"></label>
                      <label><span>Wallpaper preset</span><select :value="activeTheme.wallpaperPreset || 'aurora'" @change="vm.themeStudioUpdateField('wallpaperPreset', $event.target.value)"><option value="bliss">Bliss</option><option value="aurora">Aurora</option><option value="solid-graphite">Graphite</option><option value="ubuntu-warm">Ubuntu Warm</option><option value="custom-url">Custom URL</option></select></label>
                      <label><span>Wallpaper URL</span><input type="text" :value="activeTheme.wallpaperUrl || ''" @input="vm.themeStudioUpdateField('wallpaperUrl', $event.target.value)"></label>
                      <label><span>Wallpaper fit</span><select :value="activeTheme.wallpaperFit || 'cover'" @change="vm.themeStudioUpdateField('wallpaperFit', $event.target.value)"><option value="cover">Cover</option><option value="contain">Contain</option><option value="center">Center</option><option value="tile">Tile</option></select></label>
                      <label><span>Preview scale</span><input type="range" min="0.72" max="1" step="0.01" :value="activeTheme.previewScale || 0.86" @input="vm.themeStudioUpdateField('previewScale', +$event.target.value)"></label>
                    </div>
                  </div>
                  <div class="mioos-theme-studio-panel-vue" v-else-if="activeTab === 'window'">
                    <div class="mioos-field-grid two-col">
                      <label><span>Titlebar gradient</span><input type="text" :value="vm.themeStudioTextValue('--titlebar-bg', '')" @input="vm.themeStudioUpdateVar('--titlebar-bg', $event.target.value)"></label>
                      <label><span>Inactive titlebar</span><input type="text" :value="vm.themeStudioTextValue('--titlebar-inactive', '')" @input="vm.themeStudioUpdateVar('--titlebar-inactive', $event.target.value)"></label>
                      <label><span>Window background</span><input type="text" :value="vm.themeStudioTextValue('--window-bg', '')" @input="vm.themeStudioUpdateVar('--window-bg', $event.target.value)"></label>
                      <label><span>Window border</span><input type="color" :value="vm.themeStudioColorValue('--window-border', '#2456a6')" @input="vm.themeStudioUpdateVar('--window-border', $event.target.value)"></label>
                      <label><span>Window radius</span><input type="range" min="0" max="24" step="1" :value="parseInt(vm.themeStudioTextValue('--window-radius', '10px'), 10) || 10" @input="vm.themeStudioUpdateVar('--window-radius', $event.target.value + 'px')"></label>
                      <label><span>Glass opacity</span><input type="range" min="0" max="1" step="0.01" :value="parseFloat(vm.themeStudioTextValue('--glass-opacity', '0.2')) || 0" @input="vm.themeStudioUpdateVar('--glass-opacity', $event.target.value)"></label>
                      <label class="span-2"><span>Window shadow</span><input type="text" :value="vm.themeStudioTextValue('--shadow-window', '')" @input="vm.themeStudioUpdateVar('--shadow-window', $event.target.value)"></label>
                    </div>
                  </div>
                  <div class="mioos-theme-studio-panel-vue" v-else-if="activeTab === 'buttons'">
                    <div class="mioos-field-grid two-col">
                      <label><span>Accent</span><input type="color" :value="vm.themeStudioColorValue('--accent', '#0b63f6')" @input="vm.themeStudioUpdateVar('--accent', $event.target.value)"></label>
                      <label><span>Accent glow</span><input type="text" :value="vm.themeStudioTextValue('--accent-soft', '')" @input="vm.themeStudioUpdateVar('--accent-soft', $event.target.value)"></label>
                      <label><span>Button radius</span><input type="range" min="0" max="999" step="1" :value="parseInt(vm.themeStudioTextValue('--button-radius', '8px'), 10) || 8" @input="vm.themeStudioUpdateVar('--button-radius', $event.target.value + 'px')"></label>
                      <label><span>Button tint</span><input type="text" :value="vm.themeStudioTextValue('--button-tint', '')" @input="vm.themeStudioUpdateVar('--button-tint', $event.target.value)"></label>
                      <label><span>Button hover tint</span><input type="text" :value="vm.themeStudioTextValue('--button-tint-hover', '')" @input="vm.themeStudioUpdateVar('--button-tint-hover', $event.target.value)"></label>
                      <label><span>Minimize button</span><input type="color" :value="vm.themeStudioColorValue('--control-min', '#f2d25a')" @input="vm.themeStudioUpdateVar('--control-min', $event.target.value)"></label>
                      <label><span>Maximize button</span><input type="color" :value="vm.themeStudioColorValue('--control-max', '#7ecb61')" @input="vm.themeStudioUpdateVar('--control-max', $event.target.value)"></label>
                      <label><span>Close button</span><input type="color" :value="vm.themeStudioColorValue('--control-close', '#e06d5c')" @input="vm.themeStudioUpdateVar('--control-close', $event.target.value)"></label>
                    </div>
                  </div>
                  <div class="mioos-theme-studio-panel-vue" v-else-if="activeTab === 'menus'">
                    <div class="mioos-field-grid two-col">
                      <label><span>Menu background</span><input type="text" :value="vm.themeStudioTextValue('--menu-bg', '')" @input="vm.themeStudioUpdateVar('--menu-bg', $event.target.value)"></label>
                      <label><span>Menu border</span><input type="text" :value="vm.themeStudioTextValue('--menu-border', '')" @input="vm.themeStudioUpdateVar('--menu-border', $event.target.value)"></label>
                      <label><span>Menu text</span><input type="color" :value="vm.themeStudioColorValue('--menu-text', '#10233f')" @input="vm.themeStudioUpdateVar('--menu-text', $event.target.value)"></label>
                      <label><span>Menu hover</span><input type="text" :value="vm.themeStudioTextValue('--menu-hover', '')" @input="vm.themeStudioUpdateVar('--menu-hover', $event.target.value)"></label>
                      <label><span>Divider</span><input type="text" :value="vm.themeStudioTextValue('--menu-divider', '')" @input="vm.themeStudioUpdateVar('--menu-divider', $event.target.value)"></label>
                      <label><span>Popup shadow</span><input type="text" :value="vm.themeStudioTextValue('--menu-shadow', '')" @input="vm.themeStudioUpdateVar('--menu-shadow', $event.target.value)"></label>
                    </div>
                  </div>
                  <div class="mioos-theme-studio-panel-vue" v-else-if="activeTab === 'taskbar'">
                    <div class="mioos-field-grid two-col">
                      <label><span>Taskbar background</span><input type="text" :value="vm.themeStudioTextValue('--taskbar-bg', '')" @input="vm.themeStudioUpdateVar('--taskbar-bg', $event.target.value)"></label>
                      <label><span>Taskbar text</span><input type="color" :value="vm.themeStudioColorValue('--taskbar-text', '#ffffff')" @input="vm.themeStudioUpdateVar('--taskbar-text', $event.target.value)"></label>
                      <label><span>Taskbar height</span><input type="range" min="36" max="72" step="1" :value="parseInt(vm.themeStudioTextValue('--taskbar-height', '48px'), 10) || 48" @input="vm.themeStudioUpdateVar('--taskbar-height', $event.target.value + 'px')"></label>
                      <label><span>Desktop icon size</span><input type="range" min="36" max="64" step="1" :value="parseInt(vm.themeStudioTextValue('--desktop-icon-size', '48px'), 10) || 48" @input="vm.themeStudioUpdateVar('--desktop-icon-size', $event.target.value + 'px')"></label>
                      <label><span>Icon label background</span><input type="text" :value="vm.themeStudioTextValue('--icon-label-bg', '')" @input="vm.themeStudioUpdateVar('--icon-label-bg', $event.target.value)"></label>
                      <label><span>Icon label text</span><input type="color" :value="vm.themeStudioColorValue('--icon-label-text', '#ffffff')" @input="vm.themeStudioUpdateVar('--icon-label-text', $event.target.value)"></label>
                    </div>
                  </div>
                  <div class="mioos-theme-studio-panel-vue" v-else>
                    <div class="mioos-field-grid two-col">
                      <label><span>Class modifiers</span><input type="text" :value="vm.themeStudioClassModifiersText()" @input="vm.themeStudioSetClassModifiers($event.target.value)"></label>
                      <label><span>Animation speed (minimize)</span><input type="range" min="120" max="420" step="10" :value="((activeTheme.animationSpeeds || {}).minimize) || 180" @input="vm.themeStudioUpdateField('animationSpeeds.minimize', +$event.target.value)"></label>
                      <label><span>Animation speed (progress)</span><input type="range" min="120" max="420" step="10" :value="((activeTheme.animationSpeeds || {}).progress) || 220" @input="vm.themeStudioUpdateField('animationSpeeds.progress', +$event.target.value)"></label>
                      <label><span>Extra CSS</span><textarea rows="6" :value="activeTheme.extraCss || ''" @input="vm.themeStudioUpdateField('extraCss', $event.target.value)"></textarea></label>
                      <label class="span-2"><span>Import / Export buffer</span><textarea rows="8" :value="store.importBuffer || ''" @input="store.importBuffer = $event.target.value"></textarea></label>
                    </div>
                    <div class="mioos-theme-studio-footer-vue">
                      <button type="button" class="mioos-btn" :disabled="activeTheme.locked" @click="vm.themeStudioSaveCustomTheme()">Save custom theme</button>
                      <button type="button" class="mioos-btn is-danger" :disabled="activeTheme.locked" @click="vm.themeStudioDeleteCustomTheme(activeTheme.id)">Delete custom theme</button>
                    </div>
                  </div>
                </section>
              </div>
            </div>
          </div>`
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
          entries: function () { return this.vm.filteredEntries || []; }
        },
        template: '' +
          '<aside class="mioos-start-menu-vue" :class="[\'is-\' + vm.currentShellThemeFamily()]" @click.stop>' +
            '<div class="mioos-start-head-vue"><div class="mioos-start-avatar-vue">M</div><div><strong>[[ vm.boot.product.name ]]</strong><span>[[ vm.boot.product.subtitle ]]</span></div></div>' +
            '<label class="mioos-start-search-vue"><span>⌕</span><input v-model="vm.menuFilter" type="text" :placeholder="vm.t(\'search.placeholder\')"></label>' +
            '<div class="mioos-start-body-vue">' +
              '<div class="mioos-start-list-vue">' +
                '<button v-for="entry in entries" :key="entry.key" type="button" class="mioos-start-entry-vue" @click="vm.openApp(entry.key)"><span class="mioos-start-entry-icon">[[ entry.icon ]]</span><span><strong>[[ entry.title ]]</strong><em>[[ entry.subtitle || entry.key ]]</em></span></button>' +
              '</div>' +
              '<aside class="mioos-start-side-vue">' +
                '<strong>Themes</strong>' +
                '<button v-for="theme in vm.shellThemeOptions()" :key="theme.key" type="button" class="mioos-chip-btn" :class="{ \'is-active\': vm.activeThemeKey === theme.key }" @click="vm.applyShellTheme(theme.key)">[[ theme.label ]]</button>' +
                '<strong>Language</strong>' +
                '<button v-for="locale in vm.localeOptions" :key="locale.code" type="button" class="mioos-chip-btn" :class="{ \'is-active\': (vm.currentLocale || {}).code === locale.code }" @click="vm.changeLocale(locale.code)">[[ locale.label ]]</button>' +
                '<div class="mioos-start-user-vue" v-if="vm.authEnabled">' +
                  '<template v-if="vm.boot.user.authenticated"><span>[[ (vm.boot.user || {}).displayName || \'User\' ]]</span><button type="button" class="mioos-btn" @click="vm.submitSignout">[[ vm.t(\'auth.signout\') ]]</button></template>' +
                  '<template v-else><label class="mioos-auth-field compact"><span>[[ vm.t(\'auth.username\') ]]</span><input v-model="vm.authForm.username" type="text"></label><label class="mioos-auth-field compact"><span>[[ vm.t(\'auth.password\') ]]</span><input v-model="vm.authForm.password" type="password"></label><button type="button" class="mioos-btn" @click="vm.submitSignin">[[ vm.t(\'auth.signin\') ]]</button></template>' +
                '</div>' +
              '</aside>' +
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
          '<footer class="mioos-taskbar-vue" :class="[\'is-\' + vm.currentShellThemeFamily()]">' +
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
              '<button type="button" class="mioos-popup-action" @click="vm.contextDeleteIcon()">Remove shortcut</button>' +
              '<div class="mioos-popup-separator"></div>' +
            '</template>' +
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
