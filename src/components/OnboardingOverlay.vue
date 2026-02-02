<template>
  <transition name="onb-fade">
    <div v-if="open" class="onb" @mousedown.self="noop">
      <div class="shade" />

      <div class="spot" :style="spotStyle" />
      <div class="ring" :style="spotStyle" />

      <transition name="onb-pop">
        <div v-if="open" class="card" :style="cardStyle" role="dialog" aria-modal="true">
          <div class="head">
            <div class="title">{{ step.title }}</div>
            <div class="meta">{{ index + 1 }} / {{ steps.length }}</div>
          </div>

          <div class="body">
            <div class="text">{{ step.text }}</div>
            <div v-if="step.hint" class="hint">{{ step.hint }}</div>
          </div>

          <div class="dots">
            <button
              v-for="(s,i) in steps"
              :key="s.title + i"
              class="dot"
              :class="{ on: i === index }"
              @click="setIndex(i)"
              :aria-label="'Go to step ' + (i+1)"
            />
          </div>

          <div class="foot">
            <label class="chk">
              <input type="checkbox" v-model="dontShow" />
              <span>Don’t show again</span>
            </label>

            <button class="btn ghost" @click="skip">Skip</button>
            <div class="spacer" />
            <button class="btn" :disabled="index===0" @click="prev">Back</button>
            <button class="btn primary" @click="next">{{ index === steps.length - 1 ? 'Done' : 'Next' }}</button>
          </div>

          <div class="kbd">
            <span><span class="k">Esc</span> skip</span>
            <span><span class="k">←</span>/<span class="k">→</span> navigate</span>
            <span><span class="k">Enter</span> next</span>
          </div>
        </div>
      </transition>
    </div>
  </transition>
</template>

<script>
const LS_KEY = 'mioide:onboarding:v1'

export default {
  name: 'OnboardingOverlay',
  props: {
    forceOpen: { type: Boolean, default: false }
  },
  data () {
    return {
      open: false,
      index: 0,
      dontShow: true,
      rect: { x: 0, y: 0, w: 320, h: 120 },
      raf: null
    }
  },
  computed: {
    steps () {
      return [
        { sel: '[data-onb="activity"]', title: 'Activity Bar', text: 'Switch between Explorer, Search, Source Control, Extensions, and Settings.', hint: 'Try ⌘⇧E or ⌘⇧F.' },
        { sel: '[data-onb="sidebar"]', title: 'Explorer / Sidebar', text: 'Browse files and open tabs. This area resizes with the splitter.' },
        { sel: '[data-onb="tabs"]', title: 'Editor Tabs', text: 'Open files appear here. Use tabs to switch between files quickly.' },
        { sel: '[data-onb="cmdbar"]', title: 'Command Bar', text: 'Run, Debug, Stop, Format, and Save actions live here.', hint: 'These are UI stubs until backend wiring.' },
        { sel: '[data-onb="bottom"]', title: 'Bottom Panel', text: 'Output and Terminal stream here with ANSI colors via xterm.js.' },
        { sel: '[data-onb="status"]', title: 'Status Bar', text: 'Global status and Layout controls live here. The bar spans full width.' }
      ]
    },
    step () { return this.steps[this.index] || this.steps[0] },
    spotStyle () {
      const r = this.rect
      return { left: r.x + 'px', top: r.y + 'px', width: r.w + 'px', height: r.h + 'px' }
    },
    cardStyle () {
      const r = this.rect
      const pad = 14
      const vw = window.innerWidth || 1200
      const vh = window.innerHeight || 800
      const cardW = 360
      const cardH = 220

      let x = Math.min(Math.max(pad, r.x), vw - cardW - pad)
      let y = r.y + r.h + 14
      if (y + cardH + pad > vh) y = Math.max(pad, r.y - cardH - 14)
      if (x + cardW + pad > vw) x = Math.max(pad, r.x - cardW - 14)
      return { left: x + 'px', top: y + 'px' }
    }
  },
  watch: {
    forceOpen: {
      immediate: true,
      handler () { this.maybeOpen() }
    }
  },
  mounted () {
    this.maybeOpen()
    window.addEventListener('keydown', this.onKey, { passive: true })
    window.addEventListener('resize', this.measure, { passive: true })
    this.$nextTick(() => setTimeout(this.measure, 60))
  },
  beforeUnmount () {
    window.removeEventListener('keydown', this.onKey)
    window.removeEventListener('resize', this.measure)
    try { cancelAnimationFrame(this.raf) } catch (e) {}
  },
  methods: {
    noop () {},
    maybeOpen () {
      if (this.forceOpen) { this.open = true; this.index = 0; this.$nextTick(this.measure); return }
      const done = localStorage.getItem(LS_KEY)
      if (!done) { this.open = true; this.index = 0; this.$nextTick(this.measure) }
    },
    onKey (e) {
      if (!this.open) return
      if (e.key === 'Escape') return this.skip()
      if (e.key === 'Enter') return this.next()
      if (e.key === 'ArrowRight') return this.next()
      if (e.key === 'ArrowLeft') return this.prev()
    },
    measure () {
      if (!this.open) return
      const el = document.querySelector(this.step.sel)
      if (!el) { this.rect = { x: 120, y: 120, w: 380, h: 140 }; return }
      const b = el.getBoundingClientRect()
      const pad = 6
      this.rect = {
        x: Math.max(8, b.x - pad),
        y: Math.max(8, b.y - pad),
        w: Math.min((window.innerWidth || 1200) - 16, b.width + pad * 2),
        h: Math.min((window.innerHeight || 800) - 16, b.height + pad * 2)
      }
    },
    setIndex (i) {
      const next = Math.min(Math.max(0, i), this.steps.length - 1)
      this.index = next
      this.$nextTick(() => {
        try { cancelAnimationFrame(this.raf) } catch (e) {}
        this.raf = requestAnimationFrame(() => this.measure())
      })
    },
    prev () { this.setIndex(this.index - 1) },
    next () {
      if (this.index >= this.steps.length - 1) return this.finish(false)
      this.setIndex(this.index + 1)
    },
    skip () { this.finish(true) },
    finish (skipped) {
      try {
        if (this.dontShow) localStorage.setItem(LS_KEY, skipped ? 'skipped' : 'done')
        else localStorage.removeItem(LS_KEY)
      } catch (e) {}
      this.open = false
      this.$emit('done', { skipped: !!skipped })
    }
  }
}
</script>

<style scoped>
.onb{ position: fixed; inset: 0; z-index: 30000; }
.shade{ position:absolute; inset:0; background: rgba(0,0,0,0.55); backdrop-filter: blur(2px); }
.spot{
  position:absolute;
  border-radius: 14px;
  background: transparent;
  box-shadow: 0 0 0 9999px rgba(0,0,0,0.55);
  transition: all 180ms ease;
}
.ring{
  position:absolute;
  border-radius: 14px;
  border: 1px solid color-mix(in srgb, var(--mio-accent) 55%, transparent);
  box-shadow: 0 18px 45px rgba(0,0,0,0.45), 0 0 0 2px color-mix(in srgb, var(--mio-accent) 18%, transparent) inset;
  transition: all 180ms ease;
  pointer-events: none;
}
.card{
  position:absolute;
  width: 360px;
  border-radius: 16px;
  border: 1px solid var(--mio-border);
  background: color-mix(in srgb, var(--mio-panel) 94%, black 6%);
  color: var(--mio-fg);
  box-shadow: 0 22px 60px rgba(0,0,0,0.55);
  overflow:hidden;
}
.head{
  height: 38px;
  display:flex;
  align-items:center;
  justify-content: space-between;
  padding: 0 12px;
  background: var(--mio-panel2);
  border-bottom: 1px solid var(--mio-border);
}
.title{ font-size: 13px; opacity: 0.95; }
.meta{ font-size: 12px; opacity: 0.7; font-family: var(--mio-mono); }
.body{ padding: 12px; }
.text{ font-size: 13px; opacity: 0.9; line-height: 1.35; }
.hint{ margin-top: 8px; font-size: 12px; opacity: 0.75; }

.dots{
  padding: 10px 12px 0;
  display:flex;
  gap: 6px;
  flex-wrap: wrap;
}
.dot{
  width: 8px;
  height: 8px;
  border-radius: 999px;
  border: 1px solid color-mix(in srgb, var(--mio-border) 70%, transparent);
  background: color-mix(in srgb, var(--mio-panel2) 55%, transparent);
  cursor: pointer;
  opacity: 0.7;
  transition: transform 120ms ease, opacity 120ms ease, background 120ms ease;
}
.dot:hover{ opacity: 0.95; transform: translateY(-1px); }
.dot.on{
  opacity: 1;
  background: color-mix(in srgb, var(--mio-accent) 55%, transparent);
  border-color: color-mix(in srgb, var(--mio-accent) 45%, var(--mio-border));
}

.foot{
  padding: 10px 12px;
  display:flex;
  align-items:center;
  gap: 8px;
  border-top: 1px solid var(--mio-border);
  background: color-mix(in srgb, var(--mio-panel2) 72%, transparent);
}
.chk{
  display:flex;
  align-items:center;
  gap: 6px;
  font-size: 12px;
  opacity: 0.8;
  user-select: none;
}
.chk input{ accent-color: var(--mio-accent); }

.spacer{ flex: 1; }
.btn{
  height: 28px;
  border-radius: 10px;
  border: 1px solid var(--mio-border);
  background: color-mix(in srgb, var(--mio-panel2) 60%, transparent);
  color: var(--mio-fg);
  font-size: 12px;
  padding: 0 10px;
  cursor: pointer;
  transition: transform 120ms ease, background 120ms ease;
}
.btn:hover{ transform: translateY(-1px); background: color-mix(in srgb, var(--mio-panel2) 45%, transparent); }
.btn:active{ transform: translateY(0) scale(0.98); }
.btn:disabled{ opacity: 0.4; cursor: not-allowed; transform:none; }
.btn.primary{
  border-color: color-mix(in srgb, var(--mio-accent) 45%, var(--mio-border));
  background: color-mix(in srgb, var(--mio-accent) 22%, transparent);
}
.btn.ghost{ opacity: 0.85; }

.kbd{
  padding: 0 12px 12px;
  display:flex;
  gap: 12px;
  flex-wrap: wrap;
  font-size: 11px;
  opacity: 0.7;
}
.k{
  font-family: var(--mio-mono);
  font-size: 11px;
  padding: 2px 6px;
  border-radius: 8px;
  border: 1px solid color-mix(in srgb, var(--mio-border) 70%, transparent);
  background: color-mix(in srgb, var(--mio-panel2) 65%, transparent);
  opacity: 0.95;
}
.onb-fade-enter-active, .onb-fade-leave-active{ transition: opacity 160ms ease; }
.onb-fade-enter-from, .onb-fade-leave-to{ opacity: 0; }
.onb-pop-enter-active{ transition: transform 180ms ease, opacity 180ms ease; }
.onb-pop-enter-from{ transform: translateY(6px) scale(0.98); opacity: 0; }
</style>
