MIOTPLB ; # MIOTPLB
	;
	; Benchmark harness for MIOTPL (compile/render throughput + output size)
	; - Pure MUMPS, no external deps.
	;
	; Usage:
	;   D RUN^MIOTPLB
	;   D RUN^MIOTPLB(.CONF)
	;
	; CONF("bench","iters","compile") default 200
	; CONF("bench","iters","render")  default 1000
	; CONF("bench","warmup")          default 1 (run 1 warm render per case)
	;
	; Reports 3 "modes":
	;   MIN  : local TOK array, scalar output
	;   PERF : token-ref (global), scalar output
	;   BIG  : token-ref (global), REF output (chunked)
	;
	Q
	;
RUN(CONF) ;
	NEW BCONF M BCONF=CONF
	DO INITCONF(.BCONF)
	; ensure MIOTPL defaults are present, but avoid precompile during benchmarks
	SET BCONF("templates","precompileEnabled")=0
	DO START^MIOTPL(.BCONF)
	NEW PREF DO DEFPART(.PREF)
	NEW CASES DO DEFCASES(.CASES,PREF)
	DO REPORT(.BCONF,.CASES,PREF)
	QUIT
	;
INITCONF(CONF) ;
	; Bench defaults (tunable)
	IF '$DATA(CONF("bench","iters","compile")) SET CONF("bench","iters","compile")=200
	IF '$DATA(CONF("bench","iters","render"))  SET CONF("bench","iters","render")=1000
	IF '$DATA(CONF("bench","warmup"))          SET CONF("bench","warmup")=1
	; Output chunk for REF mode
	IF '$DATA(CONF("output","chunk"))          SET CONF("output","chunk")=8192
	QUIT
	;
DEFPART(PREF) ;
	; Build a partials/parents map under ^TMP so we can benchmark partials/parents without filesystem.
	; MIOTPL resolves both {{>partial}} and {{<parent}} through CTX("meta","partialsRef") when provided.
	NEW R SET R=$NA(^TMP($J,"MIOTPLB","partials"))
	KILL @R
	; Partial "p"
	SET @R@("p")="X{{name}}Y"
	; Parent template "base" with default {{$block}}
	SET @R@("base")="BASE:"_$C(10)_"{{$block}}"_$C(10)_"  default"_$C(10)_"{{/block}}"_$C(10)_":END"_$C(10)
	SET PREF=R
	QUIT
	;
DEFCASES(CASES,PREF) ;
	KILL CASES
	; (1) text only
	SET CASES(1,"name")="text-only"
	SET CASES(1,"tpl")="Hello, world!"_$C(10)
	; (2) variable
	SET CASES(2,"name")="var"
	SET CASES(2,"tpl")="Hello {{name}}!"_$C(10)
	; (3) list section
	SET CASES(3,"name")="list"
	SET CASES(3,"tpl")="{{#items}}{{.}},{{/items}}"_$C(10)
	; (4) partial
	SET CASES(4,"name")="partial"
	SET CASES(4,"tpl")="A{{>p}}B"_$C(10)
	; (5) parent + block override
	SET CASES(5,"name")="parent+block"
	SET CASES(5,"tpl")="{{<base}}"_$C(10)_"{{$block}}"_$C(10)_"  child {{name}}"_$C(10)_"{{/block}}"_$C(10)_"{{/base}}"_$C(10)
	; (6) variable lambda (name resolves via $$LNAME^MIOTPLB)
	SET CASES(6,"name")="lambda-var"
	SET CASES(6,"tpl")="Hello {{name}}!"_$C(10)
	; store pref
	SET CASES("meta","partialsRef")=$G(PREF)
	QUIT
	;
BUILDCTX(ID,PREF,CTX) ;
	KILL CTX
	; Provide partials map (covers partials + parents)
	IF $G(PREF)'="" SET CTX("meta","partialsRef")=PREF
	; Common scalars
	SET CTX("name")="Ahmed"
	; Per-case adjustments
	IF +$G(ID)=3 DO  ; list
	. NEW I FOR I=1:1:50 SET CTX("items",I)="item"_I
	IF +$G(ID)=6 DO  ; lambda-var
	. SET CTX("name")="$$LNAME^MIOTPLB"
	QUIT
	;
REPORT(CONF,CASES,PREF) ;
	NEW CI,RI,WARM
	SET CI=+$G(CONF("bench","iters","compile")) IF CI<1 SET CI=1
	SET RI=+$G(CONF("bench","iters","render"))  IF RI<1 SET RI=1
	SET WARM=+$G(CONF("bench","warmup"))
	NEW NOW SET NOW=$$TS()
	WRITE !,"MIOTPL Bench Report  ",NOW,!
	WRITE "Engine: ",$$VER(),!
	WRITE "Iters : compile=",CI," render=",RI," warmup=",WARM,!
	WRITE "Modes : MIN(local TOK->scalar), PERF(token-ref->scalar), BIG(token-ref->REF)",!
	WRITE $TR($J("",78)," ","-"),!
	WRITE $$HDR(),!
	WRITE $TR($J("",78)," ","-"),!
	NEW I SET I=0
	FOR  SET I=$ORDER(CASES(I)) QUIT:'I  DO
	. NEW NAME,TPL SET NAME=$G(CASES(I,"name")),TPL=$G(CASES(I,"tpl"))
	. NEW CTX DO BUILDCTX(I,PREF,.CTX)
	. DO ONECASE(.CONF,NAME,TPL,.CTX,.ROW,.ERR)
	. IF $DATA(ERR) DO  QUIT
	. . WRITE !,"[ERROR] ",NAME,": ",$G(ERR("code"))," ",$G(ERR("msg")),!
	. WRITE ROW,!
	WRITE $TR($J("",78)," ","-"),!
	QUIT
	;
HDR() ;
	; fixed-width header
	QUIT $J("CASE",14)_"  "_$J("TPL",6)_"  "_$J("MIN C",7)_" "_$J("MIN R",7)_" "_$J("MIN SZ",7)_"  "_$J("PERF C",7)_" "_$J("PERF R",7)_" "_$J("PERF SZ",7)_"  "_$J("BIG C",7)_" "_$J("BIG R",7)_" "_$J("BIG SZ",7)
	;
ONECASE(CONF,NAME,TPL,CTX,ROW,ERR) ;
	KILL ERR
	NEW TL SET TL=$L($G(TPL))
	; MIN
	NEW MINC,MINR,MINSZ
	DO BENCHMIN(.CONF,TPL,.CTX,.MINC,.MINR,.MINSZ,.ERR) QUIT:$DATA(ERR)
	; PERF
	NEW PERFC,PERFR,PERFSZ
	DO BENCHPERF(.CONF,NAME,TPL,.CTX,.PERFC,.PERFR,.PERFSZ,.ERR) QUIT:$DATA(ERR)
	; BIG
	NEW BIGC,BIGR,BIGSZ
	DO BENCHBIG(.CONF,NAME,TPL,.CTX,.BIGC,.BIGR,.BIGSZ,.ERR) QUIT:$DATA(ERR)
	SET ROW=$J($E($G(NAME),1,14),14)_"  "_$J(TL,6)_"  "_$$FM(MINC)_" "_$$FM(MINR)_" "_$J(MINSZ,7)_"  "_$$FM(PERFC)_" "_$$FM(PERFR)_" "_$J(PERFSZ,7)_"  "_$$FM(BIGC)_" "_$$FM(BIGR)_" "_$J(BIGSZ,7)
	QUIT
	;
BENCHMIN(CONF,TPL,CTX,MSCOM,MSREN,OUTSZ,ERR) ;
	KILL ERR
	NEW CI,RI,WARM SET CI=+$G(CONF("bench","iters","compile")),RI=+$G(CONF("bench","iters","render")),WARM=+$G(CONF("bench","warmup"))
	IF CI<1 SET CI=1 IF RI<1 SET RI=1
	NEW I,TS,TE,EL
	SET TS=$$NOWUS()
	F I=1:1:CI DO  QUIT:$DATA(ERR)
	. NEW TOK KILL TOK
	. DO COMPILE^MIOTPL($G(TPL),.TOK,.ERR)
	SET TE=$$NOWUS() QUIT:$DATA(ERR)
	SET EL=TE-TS
	SET MSCOM=$$MSPER(EL,CI)
	NEW TOK KILL TOK
	DO COMPILE^MIOTPL($G(TPL),.TOK,.ERR) QUIT:$DATA(ERR)
	IF WARM DO  QUIT:$DATA(ERR)
	. NEW OUT
	. DO EVAL^MIOTPL(.TOK,.CONF,.CTX,.OUT,.ERR)
	SET TS=$$NOWUS()
	F I=1:1:RI DO  QUIT:$DATA(ERR)
	. NEW OUT
	. DO EVAL^MIOTPL(.TOK,.CONF,.CTX,.OUT,.ERR)
	SET TE=$$NOWUS() QUIT:$DATA(ERR)
	SET EL=TE-TS
	SET MSREN=$$MSPER(EL,RI)
	NEW OUT DO EVAL^MIOTPL(.TOK,.CONF,.CTX,.OUT,.ERR) QUIT:$DATA(ERR)
	SET OUTSZ=$L($G(OUT))
	QUIT
	;
BENCHPERF(CONF,NAME,TPL,CTX,MSCOM,MSREN,OUTSZ,ERR) ;
	KILL ERR
	NEW CI,RI,WARM SET CI=+$G(CONF("bench","iters","compile")),RI=+$G(CONF("bench","iters","render")),WARM=+$G(CONF("bench","warmup"))
	IF CI<1 SET CI=1 IF RI<1 SET RI=1
	NEW TREF SET TREF=$NA(^TMP($J,"MIOTPLB","tokref",NAME))
	NEW I,TS,TE,EL
	SET TS=$$NOWUS()
	F I=1:1:CI DO  QUIT:$DATA(ERR)
	. DO COMPIREF(TPL,TREF,.ERR)
	SET TE=$$NOWUS() QUIT:$DATA(ERR)
	SET EL=TE-TS
	SET MSCOM=$$MSPER(EL,CI)
	DO COMPIREF(TPL,TREF,.ERR) QUIT:$DATA(ERR)
	NEW PMAX SET PMAX=+$$PMAXREF(TREF)
	NEW HTOK SET HTOK("ref")=TREF,HTOK("pmax")=PMAX
	IF WARM DO  QUIT:$DATA(ERR)
	. NEW OUT
	. DO EVAL^MIOTPL(.HTOK,.CONF,.CTX,.OUT,.ERR)
	SET TS=$$NOWUS()
	F I=1:1:RI DO  QUIT:$DATA(ERR)
	. NEW OUT
	. DO EVAL^MIOTPL(.HTOK,.CONF,.CTX,.OUT,.ERR)
	SET TE=$$NOWUS() QUIT:$DATA(ERR)
	SET EL=TE-TS
	SET MSREN=$$MSPER(EL,RI)
	NEW OUT DO EVAL^MIOTPL(.HTOK,.CONF,.CTX,.OUT,.ERR) QUIT:$DATA(ERR)
	SET OUTSZ=$L($G(OUT))
	QUIT
	;
BENCHBIG(CONF,NAME,TPL,CTX,MSCOM,MSREN,OUTSZ,ERR) ;
	KILL ERR
	NEW CI,RI,WARM SET CI=+$G(CONF("bench","iters","compile")),RI=+$G(CONF("bench","iters","render")),WARM=+$G(CONF("bench","warmup"))
	IF CI<1 SET CI=1 IF RI<1 SET RI=1
	NEW TREF SET TREF=$NA(^TMP($J,"MIOTPLB","tokref",NAME))
	NEW I,TS,TE,EL
	SET TS=$$NOWUS()
	F I=1:1:CI DO  QUIT:$DATA(ERR)
	. DO COMPIREF(TPL,TREF,.ERR)
	SET TE=$$NOWUS() QUIT:$DATA(ERR)
	SET EL=TE-TS
	SET MSCOM=$$MSPER(EL,CI)
	DO COMPIREF(TPL,TREF,.ERR) QUIT:$DATA(ERR)
	NEW PMAX SET PMAX=+$$PMAXREF(TREF)
	NEW HTOK SET HTOK("ref")=TREF,HTOK("pmax")=PMAX
	NEW OREF SET OREF=$NA(^TMP($J,"MIOTPLB","outref",NAME))
	IF WARM DO  QUIT:$DATA(ERR)
	. NEW DUM
	. DO EVALX^MIOTPL(.HTOK,.CONF,.CTX,"R",.DUM,OREF,.ERR)
	SET TS=$$NOWUS()
	F I=1:1:RI DO  QUIT:$DATA(ERR)
	. NEW DUM
	. DO EVALX^MIOTPL(.HTOK,.CONF,.CTX,"R",.DUM,OREF,.ERR)
	SET TE=$$NOWUS() QUIT:$DATA(ERR)
	SET EL=TE-TS
	SET MSREN=$$MSPER(EL,RI)
	NEW DUM
	DO EVALX^MIOTPL(.HTOK,.CONF,.CTX,"R",.DUM,OREF,.ERR) QUIT:$DATA(ERR)
	SET OUTSZ=$$REFLEN(OREF)
	QUIT
	;
COMPIREF(TPL,TREF,ERR) ;
	KILL ERR
	NEW TOK KILL TOK
	DO COMPILE^MIOTPL($G(TPL),.TOK,.ERR) QUIT:$DATA(ERR)
	KILL @TREF
	MERGE @TREF=TOK
	QUIT
	;
PMAXREF(TREF) ;
	NEW PM SET PM=+$G(@TREF@("meta","pmax"))
	IF 'PM DO
	. NEW I,MAX SET (I,MAX)=0
	. FOR  SET I=$O(@TREF@(I)) QUIT:I=""  IF I?1.N,I>MAX SET MAX=I
	. SET PM=MAX
	. SET @TREF@("meta","pmax")=PM
	QUIT PM
	;
REFLEN(ROOT) ;
	NEW LEN,S SET LEN=0,S=0
	FOR  SET S=$O(@ROOT@(S)) QUIT:S=""  DO
	. QUIT:'(S?1.N)
	. SET LEN=LEN+$L($G(@ROOT@(S)))
	QUIT LEN
	;
NOWUS() ;
	NEW H,D,SEC,TS,FR,US
	SET H=$H,D=+$P(H,",",1),SEC=+$P(H,",",2)
	; $ZTIMESTAMP has sub-second precision on YottaDB; if unavailable, we fall back to 0.
	SET TS=""
	NEW $ET SET $ET='S TS="", $ECODE=""'
	SET TS=$ZTIMESTAMP
	SET $ET=""
	SET FR=$P(TS,".",2)
	IF FR'="" SET FR=$E(FR_"000000",1,6),US=+FR
	ELSE  SET US=0
	QUIT (((D*86400)+SEC)*1000000)+US
	;
MSPER(ELUS,ITERS) ;
	IF +$G(ITERS)<1 QUIT 0
	QUIT (ELUS/ITERS)/1000
	;
FM(X) ;
	NEW V SET V=+$J(+$G(X),0,2)
	QUIT $J(V,7)
	;
TS() ;
	NEW H,D,S,SS,HH,MM
	SET H=$H,D=+$P(H,",",1),S=+$P(H,",",2)
	SET HH=S\3600,MM=(S#3600)\60,SS=S#60
	QUIT "day#"_D_" "_$J(HH,2)_":"_$J(MM,2)_":"_$J(SS,2)
	;
VER() ;
	NEW V SET V=""
	; Avoid LABELMISSING if VERSION() was not added to MIOTPL
	IF $T(VERSION^MIOTPL)'="" SET V=$$VERSION^MIOTPL()
	IF V="" SET V="MIOTPL (no VERSION() label)"
	QUIT V
	;
	;
; Demo lambda used by case (6)
LNAME() ;
	QUIT "Ahmed"
