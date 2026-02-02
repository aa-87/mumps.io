<template>
  <span class="icon" v-html="icons[name] || icons.file" />
</template>

<script>
const icons = {
  file: `<svg viewBox="0 0 24 24"><path d="M6 2h9l5 5v15H6z" fill="none" stroke="currentColor" stroke-width="1.6"/></svg>`,
  folder: `<svg viewBox="0 0 24 24"><path d="M3 6h7l2 2h9v10H3z" fill="none" stroke="currentColor" stroke-width="1.6"/></svg>`,
  explorer: `<svg viewBox="0 0 24 24"><path d="M4 4h16v16H4z" fill="none" stroke="currentColor" stroke-width="1.6"/></svg>`,
  search: `<svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="6" fill="none" stroke="currentColor" stroke-width="1.6"/><path d="M20 20l-4.2-4.2" stroke="currentColor" stroke-width="1.6"/></svg>`,
  git: `<svg viewBox="0 0 24 24"><circle cx="6" cy="6" r="2"/><circle cx="18" cy="18" r="2"/><path d="M6 6l12 12" stroke="currentColor" stroke-width="1.6"/></svg>`,
  extensions: `<svg viewBox="0 0 24 24"><path d="M4 4h16v16H4z" fill="none" stroke="currentColor" stroke-width="1.6"/><path d="M8 8h8v8H8z" stroke="currentColor" stroke-width="1.6"/></svg>`,
  settings: `<svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"/><path d="M4 12h2m12 0h2M12 4v2m0 12v2" stroke="currentColor" stroke-width="1.6"/></svg>`,
  play: `<svg viewBox="0 0 24 24"><path d="M7 5l12 7-12 7z"/></svg>`,
  debug: `<svg viewBox="0 0 24 24"><circle cx="12" cy="13" r="4"/><path d="M12 3v6" stroke="currentColor" stroke-width="1.6"/></svg>`,
  stop: `<svg viewBox="0 0 24 24"><rect x="6" y="6" width="12" height="12"/></svg>`,
  save: `<svg viewBox="0 0 24 24"><path d="M6 4h12v16H6z" fill="none" stroke="currentColor" stroke-width="1.6"/></svg>`,
  format: `<svg viewBox="0 0 24 24"><path d="M6 6h12M8 10h8M10 14h4M6 18h12" stroke="currentColor" stroke-width="1.6"/></svg>`,
  bolt: `<svg viewBox="0 0 24 24"><path d="M13 2L4 14h7l-1 8 10-14h-7z"/></svg>`,
  account: `<svg viewBox="0 0 24 24"><circle cx="12" cy="8" r="4"/><path d="M4 20c2-4 14-4 16 0"/></svg>`,
  close: `<svg viewBox="0 0 24 24"><path d="M6 6l12 12M18 6l-12 12" stroke="currentColor" stroke-width="1.6"/></svg>`
}

export default {
  name: 'MioIcon',
  props: { name: { type: String, required: true } },
  data () { return { icons } }
}
</script>

<style scoped>
.icon {
  display: inline-flex;
  width: 16px;
  height: 16px;
}
.icon svg {
  width: 100%;
  height: 100%;
  fill: currentColor;
}
</style>
