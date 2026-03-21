MIOIDET003 ; MIOIDE render token tests
	D START Q
	;
START(FAIL)
	N TOP,LOCAL
	S TOP='$D(FAIL),LOCAL=0
	D T001(.LOCAL)
	D T010(.LOCAL)
	D T020(.LOCAL)
	D T030(.LOCAL)
	I TOP D  Q
	. I 'LOCAL W !,"OK - MIOIDET003"
	I LOCAL S FAIL=1
	Q
	;
T020(FAIL)
	N CONF,REQ,CTX,TCTX,OUT,ERR
	D CONFDEF^MIOIDE(.CONF)
	D BUILDHOME^MIOIDED(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOIDER(.CONF,.TCTX,.OUT,.ERR)
	D HAS^MIOIDET000(.FAIL,"[T020][palette overlay]",OUT,"paletteOverlay")
	D HAS^MIOIDET000(.FAIL,"[T020][dispatch command]",OUT,"dispatchCommand")
	D HAS^MIOIDET000(.FAIL,"[T020][ctrl reload]",OUT,"Ctrl+R")
	D HAS^MIOIDET000(.FAIL,"[T020][ctrl save]",OUT,"Ctrl+S")
	D HAS^MIOIDET000(.FAIL,"[T020][compile shortcut]",OUT,"Ctrl+Shift+B")
	D HAS^MIOIDET000(.FAIL,"[T020][new terminal shortcut]",OUT,"Ctrl+Shift+`")
	Q
	;
T030(FAIL)
	N CONF,REQ,CTX,TCTX,OUT,ERR
	D CONFDEF^MIOIDE(.CONF)
	D BUILDHOME^MIOIDED(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOIDER(.CONF,.TCTX,.OUT,.ERR)
	D HAS^MIOIDET000(.FAIL,"[T030][dock terminal host]",OUT,"dockTerminalHost")
	D HAS^MIOIDET000(.FAIL,"[T030][float terminal host]",OUT,"floatTerminalHost")
	D HAS^MIOIDET000(.FAIL,"[T030][float drag]",OUT,"wireFloatWindow")
	D HAS^MIOIDET000(.FAIL,"[T030][theme toggle id]",OUT,"themeToggle")
	D HAS^MIOIDET000(.FAIL,"[T030][line sync]",OUT,"syncLineInfo")
	D HAS^MIOIDET000(.FAIL,"[T030][sidebar splitter]",OUT,"sidebarSplitter")
	D HAS^MIOIDET000(.FAIL,"[T030][dock splitter]",OUT,"dockSplitter")
	D HAS^MIOIDET000(.FAIL,"[T030][monaco loader]",OUT,"loadMonaco")
	D HAS^MIOIDET000(.FAIL,"[T030][xterm loader]",OUT,"loadXterm")
	Q
	;

T001(FAIL)
	N CONF,REQ,CTX,TCTX,OUT,ERR
	D CONFDEF^MIOIDE(.CONF)
	D BUILDHOME^MIOIDED(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOIDER(.CONF,.TCTX,.OUT,.ERR)
	D TRUE^MIOIDET000(.FAIL,"[T001][render ok]",'$D(ERR))
	D HAS^MIOIDET000(.FAIL,"[T001][heading]",OUT,"MIOIDE Debug Workbench")
	D HAS^MIOIDET000(.FAIL,"[T001][explorer]",OUT,"Routine explorer")
	D HAS^MIOIDET000(.FAIL,"[T001][debug]",OUT,"Run and Debug")
	D HAS^MIOIDET000(.FAIL,"[T001][watch]",OUT,"WATCH")
	D HAS^MIOIDET000(.FAIL,"[T001][call stack]",OUT,"CALL STACK")
	D HAS^MIOIDET000(.FAIL,"[T001][palette]",OUT,"Command Palette")
	D HAS^MIOIDET000(.FAIL,"[T001][monaco]",OUT,"monaco-editor")
	D HAS^MIOIDET000(.FAIL,"[T001][xterm]",OUT,"xterm")
	D HAS^MIOIDET000(.FAIL,"[T001][output]",OUT,"OUTPUT")
	D HAS^MIOIDET000(.FAIL,"[T001][terminal]",OUT,"TERMINAL")
	D HAS^MIOIDET000(.FAIL,"[T001][theme]",OUT,"Toggle theme")
	D HAS^MIOIDET000(.FAIL,"[T001][new terminal]",OUT,"New terminal")
	D HAS^MIOIDET000(.FAIL,"[T001][reload]",OUT,"Reload current routine")
	D HAS^MIOIDET000(.FAIL,"[T001][tab close]",OUT,"data-close-tab=")
	Q
	;
T010(FAIL)
	N CONF,REQ,CTX,TCTX,OUT,ERR
	D CONFDEF^MIOIDE(.CONF)
	D BUILDHOME^MIOIDED(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOIDER(.CONF,.TCTX,.OUT,.ERR)
	D HAS^MIOIDET000(.FAIL,"[T010][dock output tab]",OUT,"data-dock-tab=""output""")
	D HAS^MIOIDET000(.FAIL,"[T010][dock terminal tab]",OUT,"data-dock-tab=""terminal""")
	D HAS^MIOIDET000(.FAIL,"[T010][float terminal]",OUT,"data-float-window=""terminal""")
	D HAS^MIOIDET000(.FAIL,"[T010][palette command]",OUT,"data-palette-command=""newterm""")
	D HAS^MIOIDET000(.FAIL,"[T010][theme function]",OUT,"setThemeMode")
	D HAS^MIOIDET000(.FAIL,"[T010][terminal function]",OUT,"createTerminalWindow")
	Q
	;
