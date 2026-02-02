<template>
  <div class="root">
    <div class="main">
      <div data-onb="activity" class="activity">
        <ActivityBar :active="sidebarActive" @select="setSidebarActive" />
      </div>

      <!--
        QSplitter layout (re-done from scratch to avoid "blank main area" issues):

        ActivityBar (fixed) + [ Left Sidebar | Center + Right ]
          - left splitter: model controls BEFORE (sidebar) width
          - right splitter: model controls AFTER (right sidebar) width (reverse)
          - bottom splitter: model controls AFTER (bottom) height (reverse, horizontal)
      -->

      <!-- Split #1: Left sidebar vs everything else -->
      <q-splitter
        v-model="leftSplit"
        unit="px"
        :limits="leftLimits"
        :disable="sidebarCollapsed"
        class="split split-left"
        separator-class="mio-sep"
      >
        <template v-slot:before>
          <div data-onb="sidebar" class="sidebarSurface" :class="{ collapsed: sidebarCollapsed }">
            <SidebarPane
              v-if="!sidebarCollapsed"
              :active="sidebarActive"
              @open-file="openFile"
            />
          </div>
        </template>

        <template v-slot:after>
          <!-- Split #2: Center vs Right sidebar (reverse => model controls AFTER pane) -->
          <q-splitter
            v-model="rightSplit"
            unit="px"
            :limits="rightLimits"
            :disable="!rightSidebarVisible"
            reverse
            class="split split-right"
            separator-class="mio-sep"
          >
            <template v-slot:before>
              <!-- Split #3: Editor vs Bottom panel (reverse+horizontal => model controls AFTER pane height) -->
              <q-splitter
                v-model="bottomSplit"
                unit="px"
                :limits="bottomLimits"
                horizontal
                reverse
                class="split split-bottom"
                separator-class="mio-sep"
              >
                <template v-slot:before>
                  <div class="centerWrap">
                    <div data-onb="tabs">
                      <EditorTabs
                        :tabs="editorTabs"
                        :active="editorActive"
                        @select="setEditorActive"
                        @close="closeEditorTab"
                        @reorder="reorderEditorTabs"
                        @command="openCommand"
                      />
                    </div>

                    <div data-onb="cmdbar">
                      <EditorCommandBar
                        :busy="busy"
                        @run="run"
                        @debug="debug"
                        @stop="stop"
                        @format="format"
                        @save="save"
                      />
                    </div>

                    <div class="workArea">
                      <EditorView />
                    </div>
                  </div>
                </template>

                <template v-slot:after>
                  <div data-onb="bottom" class="bottomSurface">
                    <BottomPanel
                      :bottomTabs="bottomTabs"
                      :bottomActive="bottomActive"
                      @select="setBottomActive"
                      @reorder="reorderBottomTabs"
                    />
                  </div>
                </template>
              </q-splitter>
            </template>

            <template v-slot:after>
              <div class="rightSurface" v-show="rightSidebarVisible">
                <RightSidebarPane :active="rightSidebarActive" />
              </div>
            </template>
          </q-splitter>
        </template>
      </q-splitter>
    </div>

    <div data-onb="status" class="statusWrap">
      <StatusBar
        :count="notifyCount"
        :views="views"
        :selectedView="selectedView"
        :wsState="wsState"
        @notify="toggleNotify"
        @save-view="saveView"
        @apply-view="applySelected"
        @delete-view="deleteView"
      />
    </div>

    <NotificationCenter />
    <div v-if="dragging" class="dragshield" />

    <!-- IMPORTANT: pass the open prop so the palette actually renders -->
    <CommandPalette :open="cmdOpen" @close="cmdOpen=false" @run="runCommand" />
    <OnboardingOverlay />
  </div>
</template>

<script>
import ActivityBar from 'components/ActivityBar.vue'
import SidebarPane from 'components/SidebarPane.vue'
import RightSidebarPane from 'components/RightSidebarPane.vue'
import BottomPanel from 'components/BottomPanel.vue'
import EditorTabs from 'components/EditorTabs.vue'
import EditorCommandBar from 'components/EditorCommandBar.vue'
import EditorView from 'components/EditorView.vue'
import CommandPalette from 'components/CommandPalette.vue'
import StatusBar from 'components/StatusBar.vue'
import NotificationCenter from 'components/NotificationCenter.vue'
import OnboardingOverlay from 'components/OnboardingOverlay.vue'
import ws from 'src/services/ws'

export default {
  name: 'MainLayout',
  components: {
    OnboardingOverlay,
    ActivityBar,
    SidebarPane,
    RightSidebarPane,
    BottomPanel,
    EditorTabs,
    EditorCommandBar,
    CommandPalette,
    StatusBar,
    NotificationCenter,
    EditorView
  },

  data () {
    return {
      dragging: false,
      newViewName: '',
      selectedView: '',
      cmdOpen: false,
      notifyOpen: false,
      notifyCount: 3,
      busy: false,
      wsState: 'unknown'
    }
  },

  computed: {
    theme () { return this.$store.getters['layout/theme'] || 'dark' },

    leftLimits () { return this.sidebarCollapsed ? [0, 0] : [180, 560] },
    rightLimits () { return this.rightSidebarVisible ? [180, 520] : [0, 0] },
    bottomLimits () { return [120, 520] },

    // QSplitter needs two-way bindings; these proxy to Vuex.
    leftSplit: {
      get () { return this.$store.getters['layout/sidebarCollapsed'] ? 0 : this.$store.state.layout.splits.leftWidth },
      set (v) { if (!this.$store.getters['layout/sidebarCollapsed']) this.$store.commit('layout/setLeftWidth', v) }
    },
    rightSplit: {
      get () { return this.$store.getters['layout/rightSidebarVisible'] ? this.$store.state.layout.splits.rightWidth : 0 },
	      set (v) { if (this.$store.getters['layout/rightSidebarVisible']) this.$store.commit('layout/setRightWidth', v) }
    },
    bottomSplit: {
      get () { return this.$store.state.layout.splits.bottomHeight },
      set (v) { this.$store.commit('layout/setBottomHeight', v) }
    },

    views () { return this.$store.state.layout.views },

    bottomTabs () { return this.$store.getters['layout/bottomTabs'] },
    bottomActive () { return this.$store.getters['layout/bottomActive'] },

    sidebarActive () { return this.$store.getters['layout/sidebarActive'] },
    sidebarCollapsed () { return this.$store.getters['layout/sidebarCollapsed'] },

    rightSidebarActive () { return this.$store.getters['layout/rightSidebarActive'] },
    rightSidebarVisible () { return this.$store.getters['layout/rightSidebarVisible'] },

    editorTabs () { return this.$store.getters['editor/tabs'] || [] },
    editorActive () { return this.$store.getters['editor/active'] || '' }
  },

  mounted () {
    window.addEventListener('keydown', this.onKey)
    ws.connect()
    this._wsOff = ws.on('status', (s) => { this.wsState = (s && s.state) || 'unknown' })
  },

  beforeUnmount () {
    window.removeEventListener('keydown', this.onKey)
    try { this._wsOff && this._wsOff() } catch (e) {}
  },

  methods: {
    onKey (e) {
      // Ctrl+P / Cmd+P
      const isMac = navigator.platform.toLowerCase().includes('mac')
      const mod = isMac ? e.metaKey : e.ctrlKey
      if (mod && e.key.toLowerCase() === 'p') {
        e.preventDefault()
        this.openCommand()
      }
    },

    openCommand () { this.cmdOpen = true },
    toggleNotify () { this.notifyOpen = !this.notifyOpen },

    openFile ({ id, title }) {
      this.$store.dispatch('editor/openFile', { id, title })
    },

    run () { this.busy = true; this.notifyCount = Math.min(this.notifyCount + 1, 9) },
    debug () { this.busy = true; this.notifyCount = Math.min(this.notifyCount + 1, 9) },
    stop () { this.busy = false },
    format () { /* placeholder */ },
    save () { /* placeholder */ },

    runCommand (id) {
      if (id === 'toggleTheme') return this.toggleTheme()
      if (id === 'toggleSidebar') return this.toggleSidebar()
      if (id === 'toggleRight') return this.toggleRightSidebar()
      if (id === 'focusTerminal') return this.setBottomActive('terminal')
      if (id === 'focusOutput') return this.setBottomActive('output')
      if (id === 'run') return this.run()
      if (id === 'debug') return this.debug()
      if (id === 'stop') return this.stop()
      if (id === 'onboarding') {
        try { localStorage.removeItem('mioide:onboarding:v1') } catch (e) {}
        window.location.reload()
        return
      }
    },

    setSidebarActive (id) { this.$store.commit('layout/setSidebarActive', id) },
    toggleSidebar () { this.$store.commit('layout/toggleSidebarCollapsed') },

    toggleRightSidebar () { this.$store.commit('layout/toggleRightSidebarVisible') },

    toggleTheme () { this.$store.dispatch('layout/toggleTheme') },

    setBottomActive (id) { this.$store.commit('layout/setBottomActive', id) },
    reorderBottomTabs ({ from, to }) { this.$store.commit('layout/reorderBottomTabs', { from, to }) },

    setEditorActive (id) { this.$store.commit('editor/setActive', id) },
    closeEditorTab (id) { this.$store.commit('editor/closeTab', id) },
    reorderEditorTabs ({ from, to }) { this.$store.commit('editor/reorderTabs', { from, to }) },

    saveView (name) {
      const n = (name || this.newViewName).trim()
      if (!n) return
      this.$store.dispatch('layout/saveView', n)
      this.selectedView = n
      this.newViewName = ''
    },
    applySelected (name) {
      const v = name || this.selectedView
      if (!v) return
      this.selectedView = v
      this.$store.dispatch('layout/applyView', v)
    },
    deleteView (name) {
      const v = name || this.selectedView
      if (!v) return
      this.$store.dispatch('layout/deleteView', v)
      if (this.selectedView === v) this.selectedView = ''
    }
  }
}
</script>

<style scoped>
.root {
  height: 100%;
  width: 100%;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.main {
  flex: 1;
  min-height: 0;
  display: flex;
  overflow: hidden;
  background: color-mix(in srgb, var(--mio-panel) 98%, transparent);
}

.activity { flex: 0 0 auto; }

.split { height: 100%; min-height: 0; min-width: 0; }
.split-left{ flex: 1; }
.split-right{width: calc(100% - 6px);}
.split-bottom{ width: 100%; }
.centerWrap { height: 100%; min-height: 0; display: flex; flex-direction: column; }
.workArea {
  flex: 1;
  min-height: 0;
  min-width: 0;
  display: flex;
  overflow: hidden;
  background: var(--mio-editor-bg);
  box-shadow: inset 0 0 0 1px color-mix(in srgb, var(--mio-border) 55%, transparent);
}

.sidebarSurface{
  height: 100%;
  min-height: 0;
  background: var(--mio-sidebar-bg);
  border-right: 1px solid var(--mio-hairline);
  overflow: hidden;
}
.rightSurface{
  height: 100%;
  min-height: 0;
  background: var(--mio-rightpanel-bg);
  border-left: 1px solid var(--mio-hairline);
  overflow: hidden;
}
.bottomSurface{
  height: 100%;
  min-height: 0;
  background: color-mix(in srgb, var(--mio-panel) 96%, transparent);
  border-top: 1px solid var(--mio-hairline);
  overflow: hidden;
}

/* QSplitter separator */
:deep(.mio-sep){
  background: var(--mio-hairline);
}
:deep(.q-splitter__separator){
  background: var(--mio-hairline);
}
:deep(.q-splitter__separator:hover){
  background: color-mix(in srgb, var(--mio-accent) 22%, var(--mio-hairline) 78%);
}
:deep(.q-splitter__separator-area){
  background: transparent;
}

/* Keep the separator easy to grab */
:deep(.q-splitter__separator){
  width: 6px;
}
:deep(.q-splitter--horizontal .q-splitter__separator){
  width: auto;
  height: 6px;
}

/* Status + overlays */
.statusWrap { width: 100%; flex: 0 0 auto; }
.dragshield { position: fixed; inset: 0; background: transparent; z-index: 25000; cursor: default; }
</style>
