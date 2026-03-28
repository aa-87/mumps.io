# MIOMIDE Monaco render fix

This patch focuses on page rendering correctness:

- gives Monaco a dedicated full-height editor host
- keeps the explorer and bottom panel from collapsing the main editor region
- hides the file context menu until explicitly opened
- loads the first discovered routine into Monaco on page boot
- keeps an editor fallback visible if Monaco fails to load
- returns joined `source` text from the routine load API for easier editor model updates
