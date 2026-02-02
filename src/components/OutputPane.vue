<template>
  <div ref="host" class="term"></div>
</template>

<script>
import { Terminal } from '@xterm/xterm'
import { FitAddon } from '@xterm/addon-fit'
import '@xterm/xterm/css/xterm.css'
import ws from 'src/services/ws'

export default {
  name: 'OutputPane',
  mounted () {
    this.fit = new FitAddon()
    this.term = new Terminal({
      convertEol: true,
      cursorBlink: false,
      fontFamily: 'Ubuntu Mono, DejaVu Sans Mono, Liberation Mono, monospace',
      fontSize: 13,
      lineHeight: 1.1,
      scrollback: 4000,
      theme: { background: 'transparent' }
    })
    this.term.loadAddon(this.fit)
    this.term.open(this.$refs.host)
    this.fit.fit()

    this._ro = new ResizeObserver(() => { try { this.fit.fit() } catch (e) {} })
    this._ro.observe(this.$refs.host)

    ws.connect()
    this._off = ws.on('output', (m) => {
      const data = (m && (m.data || m.payload)) || ''
      if (data) this.term.write(data)
    })

    const demo = [
      '\x1b[32m[OK]\x1b[0m Output ready (WS topic: output)',
      '\x1b[33m[WARN]\x1b[0m Backend should send: {type:"output", data:"..."}',
      '\x1b[36m[INFO]\x1b[0m ANSI colors parsed by xterm'
    ]
    demo.forEach((l, i) => setTimeout(() => this.term.writeln(l), i * 600))
  },
  beforeUnmount () {
    try { this._off && this._off() } catch (e) {}
    try { this._ro && this._ro.disconnect() } catch (e) {}
    try { this.term && this.term.dispose() } catch (e) {}
  }
}
</script>

<style scoped>
.term { width: 100%; height: 100%; background: transparent; }
</style>
