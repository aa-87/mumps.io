MIOIDET009 ; MIOIDE ROI 3A shell render contract coverage
	D START Q
	;
START(FAIL)
	N TOP,LOCAL
	S TOP='$D(FAIL),LOCAL=0
	D T001(.LOCAL)
	D T010(.LOCAL)
	D T020(.LOCAL)
	I TOP D  Q
	. I 'LOCAL W !,"OK - MIOIDET009"
	I LOCAL S FAIL=1
	Q
	;
RENDER(OUT,ERR)
	N CONF,REQ,CTX,TCTX
	D CONFDEF^MIOIDE(.CONF)
	D MKFIX^MIOIDET000(.CONF)
	S REQ("query","name")="MIOIDXT1"
	D BUILDHOME^MIOIDED(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOIDER(.CONF,.TCTX,.OUT,.ERR)
	Q
	;
T001(FAIL)
	N OUT,ERR
	D RENDER(.OUT,.ERR)
	D TRUE^MIOIDET000(.FAIL,"[T001][render ok]",'$D(ERR))
	D HAS^MIOIDET000(.FAIL,"[T001][side splitter]",OUT,"side-splitter")
	D HAS^MIOIDET000(.FAIL,"[T001][dock splitter]",OUT,"dock-splitter")
	D HAS^MIOIDET000(.FAIL,"[T001][theme toggle]",OUT,"themeToggle")
	D HAS^MIOIDET000(.FAIL,"[T001][palette button]",OUT,"data-activity=""palette""")
	D HAS^MIOIDET000(.FAIL,"[T001][new terminal]",OUT,"btn-new-terminal")
	Q
	;
T010(FAIL)
	N OUT,ERR
	D RENDER(.OUT,.ERR)
	D HAS^MIOIDET000(.FAIL,"[T010][float terminal host]",OUT,"floatTerminalHost")
	D HAS^MIOIDET000(.FAIL,"[T010][float explorer]",OUT,"data-float-open=""explorer""")
	D HAS^MIOIDET000(.FAIL,"[T010][float debug]",OUT,"data-float-open=""debug""")
	D HAS^MIOIDET000(.FAIL,"[T010][palette hook]",OUT,"openPalette")
	D HAS^MIOIDET000(.FAIL,"[T010][keydown hook]",OUT,"document.addEventListener('keydown'")
	Q
	;
T020(FAIL)
	N OUT,ERR
	D RENDER(.OUT,.ERR)
	D HAS^MIOIDET000(.FAIL,"[T020][shortcut palette hook]",OUT,"k === 'p'")
	D HAS^MIOIDET000(.FAIL,"[T020][shortcut terminal hook]",OUT,"dispatchCommand('newterm')")
	D HAS^MIOIDET000(.FAIL,"[T020][monaco loader]",OUT,"data-mioide-monaco-loader")
	D HAS^MIOIDET000(.FAIL,"[T020][xterm loader]",OUT,"data-mioide-xterm")
	D HAS^MIOIDET000(.FAIL,"[T020][terminal connect]",OUT,"connectTerminal")
	Q
	;
