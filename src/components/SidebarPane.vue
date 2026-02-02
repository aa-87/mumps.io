<template>
  <section class="side">
    <header class="head">
      <span class="title">{{ title }}</span>
      <div class="head-actions">
        <MioTooltip text="Refresh"><button class="hbtn"><MioIcon name="bolt" /></button></MioTooltip>
      </div>
    </header>

    <div class="body">
      <div v-if="active === 'explorer'" class="tree">
        <div class="section">
          <button class="secthead" @click="open.project = !open.project">
            <MioIcon name="chevronDown" class="chev" :class="{ rot: !open.project }"/>
            <span>OPEN EDITORS</span>
          </button>
          <transition name="collapse">
            <div v-if="open.project" class="sectbody">
              <button class="node file" @click="openFile('welcome','Welcome.md')">
                <MioIcon name="file" /><span>Welcome.md</span>
              </button>
              <button class="node file" @click="openFile('main','main.m')">
                <MioIcon name="file" /><span>main.m</span><span class="dirty" />
              </button>
            </div>
          </transition>
        </div>

        <div class="section">
          <button class="secthead" @click="open.files = !open.files">
            <MioIcon name="chevronDown" class="chev" :class="{ rot: !open.files }"/>
            <span>PROJECT</span>
          </button>
          <transition name="collapse">
            <div v-if="open.files" class="sectbody">
              <div class="node folder"><MioIcon name="folder" /><span>src</span></div>

              <button class="node file indent" @click="openFile('MIOSRV','MIOSRV.m')">
                <MioIcon name="file" /><span>MIOSRV.m</span>
              </button>
              <button class="node file indent" @click="openFile('MIOIDE','MIOIDE.m')">
                <MioIcon name="file" /><span>MIOIDE.m</span>
              </button>

              <div class="node folder"><MioIcon name="folder" /><span>docs</span></div>
              <button class="node file indent" @click="openFile('README','README.md')">
                <MioIcon name="file" /><span>README.md</span>
              </button>
            </div>
          </transition>
        </div>
      </div>

      <div v-else-if="active === 'search'" class="search">
        <div class="searchbox">
          <MioIcon name="search" />
          <input class="inp" v-model="q" placeholder="Search" />
          <MioTooltip text="Search" kbd="Enter">
          <button class="go" @click="run">
            <MioIcon name="play" />
          </button>
        </MioTooltip>
        </div>

        <div class="opts">
          <label class="chk"><input type="checkbox" v-model="opt.caseSensitive"> <span>Case</span></label>
          <label class="chk"><input type="checkbox" v-model="opt.regex"> <span>Regex</span></label>
          <label class="chk"><input type="checkbox" v-model="opt.whole"> <span>Whole</span></label>
        </div>

        <transition name="fade">
          <div v-if="ran" class="results">
            <div class="resHead">{{ results.length }} results</div>
            <button
              v-for="r in results"
              :key="r.id + ':' + r.line"
              class="res"
              @click="openFile(r.id, r.file)"
            >
              <div class="fileline">
                <MioIcon name="file" />
                <span class="file">{{ r.file }}</span>
                <span class="line">:{{ r.line }}</span>
              </div>
              <div class="snippet">{{ r.snip }}</div>
            </button>

            <div v-if="results.length === 0" class="empty">No matches.</div>
          </div>
        </transition>
      </div>

      <div v-else class="pad">
        <div class="hint">{{ title }}</div>
        <div class="mini">Placeholder view.</div>
      </div>
    </div>
  </section>
</template>

<script>
import MioIcon from 'components/Icon.vue'
import MioTooltip from 'components/MioTooltip.vue'

export default {
  name: 'SidebarPane',
  components: { MioIcon, MioTooltip },
  props: { active: { type: String, required: true } },

  data () {
    return {
      open: { project: true, files: true },
      q: '',
      ran: false,
      opt: { caseSensitive: false, regex: false, whole: false }
    }
  },

  computed: {
    title () {
      if (this.active === 'explorer') return 'EXPLORER'
      if (this.active === 'search') return 'SEARCH'
      if (this.active === 'scm') return 'SOURCE CONTROL'
      if (this.active === 'extensions') return 'EXTENSIONS'
      if (this.active === 'settings') return 'SETTINGS'
      return this.active.toUpperCase()
    },

    haystack () {
      return [
        { id: 'main', file: 'main.m', line: 12, snip: 'S ok=$$CHECK^MIOUTIL(user)' },
        { id: 'main', file: 'main.m', line: 88, snip: 'D RUN^MIOSRV(.args)' },
        { id: 'README', file: 'README.md', line: 7, snip: 'Command Palette (Ctrl+P / Cmd+P)' },
        { id: 'MIOSRV', file: 'MIOSRV.m', line: 33, snip: 'S ws=$$WSACCEPT^MIOSOCK(...)' }
      ]
    },

    results () {
      if (!this.ran) return []
      const q = this.q.trim()
      if (!q) return []
      const flags = this.opt.caseSensitive ? '' : 'i'
      let re = null

      try {
        if (this.opt.regex) re = new RegExp(q, flags)
        else {
          const esc = q.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
          re = new RegExp(this.opt.whole ? `\\b${esc}\\b` : esc, flags)
        }
      } catch (e) {
        return []
      }

      return this.haystack.filter(h => re.test(h.snip) || re.test(h.file))
    }
  },

  methods: {
    openFile (id, title) { this.$emit('open-file', { id, title }) },
    run () { this.ran = true }
  }
}
</script>

<style scoped>
.side { width: 100%; flex: 1 1 auto; min-width:0; height: 100%; min-height: 0; display: flex; flex-direction: column; background: var(--mio-panel); border-right: 1px solid var(--mio-border); }
.head { height: 34px; display:flex; align-items:center; justify-content: space-between; padding:0 10px; border-bottom: 1px solid var(--mio-border); background: var(--mio-panel2); user-select:none; }
.title { font-size: 12px; letter-spacing: 0.4px; opacity: 0.9; }
.head-actions{ display:inline-flex; align-items:center; gap:6px; }
.hbtn{
  width: 26px; height: 26px; border-radius: 8px;
  border: 1px solid var(--mio-border);
  background: color-mix(in srgb, var(--mio-panel2) 70%, transparent);
  color: var(--mio-fg);
  cursor: pointer;
  transition: transform 120ms ease, background 120ms ease;
}
.hbtn:hover{ background: color-mix(in srgb, var(--mio-panel2) 55%, transparent); transform: translateY(-1px); }

.body { flex: 1 1 auto; min-height: 0; overflow: auto; }
.pad { padding: 10px; }
.hint { font-size: 12px; opacity: 0.9; margin-bottom: 8px; }
.mini { font-size: 12px; opacity: 0.7; }

.tree{ padding: 8px 0; }
.section{ margin-bottom: 6px; }
.secthead{
  width: 100%;
  height: 30px;
  padding: 0 10px;
  border: none;
  background: transparent;
  color: var(--mio-fg);
  display:flex;
  align-items:center;
  gap: 8px;
  font-size: 11px;
  letter-spacing: 0.6px;
  opacity: 0.9;
  cursor: pointer;
  transition: background 140ms ease;
}
.secthead:hover{ background: color-mix(in srgb, var(--mio-panel2) 55%, transparent); }
.chev{ width: 14px; height: 14px; opacity: 0.8; transition: transform 140ms ease; }
.chev.rot{ transform: rotate(-90deg); }
.sectbody{ padding: 4px 0 6px; }

.node{
  height: 28px;
  padding: 0 10px;
  display:flex;
  align-items:center;
  gap: 8px;
  border-radius: 8px;
  margin: 2px 8px;
  cursor: pointer;
  transition: background 120ms ease, transform 120ms ease;
  border: none;
  background: transparent;
  color: var(--mio-fg);
  text-align: left;
  width: calc(100% - 16px);
}
.node:hover{ background: color-mix(in srgb, var(--mio-panel2) 65%, transparent); transform: translateX(2px); }
.node.folder{ opacity: 0.95; }
.node.file{ opacity: 0.92; }
.node.indent{ margin-left: 20px; width: calc(100% - 36px); }
.dirty{
  margin-left: auto;
  width: 7px;
  height: 7px;
  border-radius: 999px;
  background: color-mix(in srgb, var(--mio-accent) 70%, transparent);
  box-shadow: 0 0 0 2px color-mix(in srgb, var(--mio-accent) 20%, transparent);
  animation: blink 2.2s ease-in-out infinite;
}
@keyframes blink { 0%,100%{ opacity: 0.3; } 50%{ opacity: 1; } }

.collapse-enter-active, .collapse-leave-active{ transition: max-height 160ms ease, opacity 160ms ease; }
.collapse-enter-from, .collapse-leave-to{ max-height: 0; opacity: 0; }
.collapse-enter-to, .collapse-leave-from{ max-height: 500px; opacity: 1; }

/* Search */
.search{ padding: 10px; }
.searchbox{
  display:flex;
  align-items:center;
  gap: 8px;
  border: 1px solid var(--mio-border);
  background: color-mix(in srgb, var(--mio-panel2) 60%, transparent);
  border-radius: 12px;
  padding: 8px 8px;
}
.inp{ flex:1; height: 24px; border: none; background: transparent; color: var(--mio-fg); outline:none; font-size: 13px; }
.go{
  width: 30px; height: 26px;
  border-radius: 10px;
  border: 1px solid var(--mio-border);
  background: color-mix(in srgb, var(--mio-panel2) 70%, transparent);
  color: var(--mio-fg);
  cursor:pointer;
  transition: transform 120ms ease, background 120ms ease;
}
.go:hover{ transform: translateY(-1px); background: color-mix(in srgb, var(--mio-panel2) 50%, transparent); }
.opts{ display:flex; gap: 10px; margin-top: 8px; opacity: 0.85; }
.chk{ display:inline-flex; align-items:center; gap: 6px; font-size: 12px; }
.results{ margin-top: 10px; }
.resHead{ font-size: 12px; opacity: 0.75; margin-bottom: 8px; }
.res{
  width: 100%;
  text-align:left;
  border: 1px solid var(--mio-border);
  background: color-mix(in srgb, var(--mio-panel2) 50%, transparent);
  color: var(--mio-fg);
  border-radius: 12px;
  padding: 10px;
  margin-bottom: 8px;
  cursor:pointer;
  transition: transform 120ms ease, background 120ms ease;
}
.res:hover{ transform: translateY(-1px); background: color-mix(in srgb, var(--mio-panel2) 35%, transparent); }
.fileline{ display:flex; align-items:center; gap: 8px; font-size: 12px; opacity: 0.9; }
.file{ font-family: var(--mio-mono); }
.line{ opacity: 0.65; }
.snippet{ margin-top: 6px; font-size: 12px; opacity: 0.75; font-family: var(--mio-mono); }
.empty{ opacity: 0.7; font-size: 12px; padding: 8px 0; }
.fade-enter-active, .fade-leave-active{ transition: opacity 140ms ease; }
.fade-enter-from, .fade-leave-to{ opacity: 0; }

/* polish */
.header{
  background: color-mix(in srgb, var(--mio-panel2) 82%, transparent);
}
.item{
  border-radius: 10px;
  margin: 2px 4px;
  transition: background 140ms var(--mio-ease), transform 140ms var(--mio-ease);
}
.item:hover{
  background: color-mix(in srgb, var(--mio-panel2) 46%, transparent);
  transform: translateX(1px);
}
.item.active{
  background: color-mix(in srgb, var(--mio-accent) 14%, transparent);
  box-shadow: inset 0 0 0 1px color-mix(in srgb, var(--mio-accent) 22%, transparent);
}

</style>
