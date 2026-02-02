<template>
  <div class="terminal-wrap">
    <div ref="term" class="terminal-host"></div>
  </div>
</template>

<script>
import { Terminal } from '@xterm/xterm'
import { FitAddon } from '@xterm/addon-fit'
import '@xterm/xterm/css/xterm.css'

export default {
  name: 'TerminalPane',
  mounted () {
    this.fit = new FitAddon()
    this.term = new Terminal({
      cols: 80,
      convertEol: true,
      fontFamily: 'JetBrains Mono, Fira Code, monospace',
      fontSize: 13,
      theme: {
        background: 'transparent'
      }
    })
    this.term.loadAddon(this.fit)
    this.term.open(this.$refs.term)
    this.fit.fit()
    this.term.writeln('Welcome to MIO IDE terminal')
  },
  beforeUnmount () {
    try { this.term.dispose() } catch (e) {}
  }
}
</script>

<style scoped>
.terminal-wrap{
  height: 100%;
  width: 100%;
  display:flex;
  justify-content: flex-start;
  align-items: stretch;
}
.terminal-host{
  width: min(80ch, 100%);
  height: 100%;
}
</style>
