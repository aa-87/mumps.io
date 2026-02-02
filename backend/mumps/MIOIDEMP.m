MIOIDEMP ; MIO IDE MUMPS language services (parser-lite)
 ;
 ; This is an intentionally fast, "good enough" parser for IDE UX.
 ; It works on the document TEXT provided by the browser.
 ;
 ; Roadmap:
 ;   - v1: same-file labels, intrinsics docs, basic lint
 ;   - v2: project index + cross-file navigation
 ;   - v3: semantic locals/globals, type-ish hints, refactorings
 ;
 ; All outputs are shaped to match Monaco's expected structures.
 ;
 Q

 ; -----------------------------
 ; Utilities
 ; -----------------------------

GETP(P,N) Q $G(P(N))

TEXT(P) ; return text (string)
 Q $G(P("text"))

LGET(LINES,I) Q $G(LINES(I))

SPLIT(text,.LINES) ; split to LINES(1..n)
 K LINES
 N i,n S n=0
 F i=1:1:$L(text,$C(10)) S n=n+1,LINES(n)=$P(text,$C(10),i)
 I n=0 S LINES(1)=text,n=1
 Q n

TRIMR(s) ; trim right spaces/tabs
 N x S x=$G(s)
 F  Q:$E(x,$L(x))'=" "&($E(x,$L(x))'=$C(9))  S x=$E(x,1,$L(x)-1)
 Q x

ISINDENT(line) Q ($E(line,1)=" "!($E(line,1)=$C(9)))

ESCJSON(s) ; minimal, safe for hover strings (not full JSON escaping)
 N x S x=$G(s)
 S x=$TR(x,$C(9)," ")
 Q x

 ; -----------------------------
 ; Labels index (same file)
 ; -----------------------------

BUILDLABELS(LINES,N,.LBL) ; LBL(label)=line
 K LBL
 N i,line,label
 F i=1:1:N D
 . S line=$G(LINES(i))
 . I line="" Q
 . I $$ISINDENT(line) Q
 . I $E(line,1)=";" Q
 . S label=$$LABELAT(line)
 . I label'="" S LBL(label)=i
 Q

LABELAT(line) ; label at start: %?A... optionally +n included by caller
 N x,l
 S x=$G(line)
 ; strip leading spaces
 F  Q:$E(x,1)'=" "&($E(x,1)'=$C(9))  S x=$E(x,2,$L(x))
 ; first token up to space/tab
 S l=$P(x," ",1)
 S l=$P(l,$C(9),1)
 I l?1(1"%",1A)1(0AN,0"%") Q l
 Q ""

 ; -----------------------------
 ; Diagnostics (very fast v1)
 ; -----------------------------

DIAG(P,OUT) ; OUT("markers",i,...)...
 K OUT
 N text S text=$$TEXT(.P)
 N LINES,N S N=$$SPLIT(text,.LINES)
 N i,line,openQ,par,br
 S openQ=0,par=0,br=0
 N mi S mi=0

 F i=1:1:N D
 . S line=$G(LINES(i))
 . N j,ch
 . ; remove comment tail after ; (but keep if inside string)
 . N s S s=""
 . N inStr S inStr=0
 . F j=1:1:$L(line) D
 . . S ch=$E(line,j)
 . . I ch="\"" D  Q
 . . . ; MUMPS strings use doubled quotes "" to escape
 . . . I inStr,($E(line,j+1)="\"") S s=s_"\"\"",j=j+1 Q
 . . . S inStr='inStr S s=s_ch Q
 . . I 'inStr,ch=";" S j=$L(line)+1 Q
 . . S s=s_ch
 . S line=s

 . ; scan for simple balance errors
 . F j=1:1:$L(line) D
 . . S ch=$E(line,j)
 . . I ch="\"" S openQ='openQ Q
 . . I openQ Q
 . . I ch="(" S par=par+1 Q
 . . I ch=")" S par=par-1 I par<0 D MARK(.OUT,.mi,i,j,i,j+1,8,"Unexpected )") S par=0
 . . I ch="[" S br=br+1 Q
 . . I ch="]" S br=br-1 I br<0 D MARK(.OUT,.mi,i,j,i,j+1,8,"Unexpected ]") S br=0
 . Q

 I openQ D MARK(.OUT,.mi,N,1,N,2,8,"Unclosed string")
 I par>0 D MARK(.OUT,.mi,N,1,N,2,8,"Unclosed (")
 I br>0 D MARK(.OUT,.mi,N,1,N,2,8,"Unclosed [")
 Q

MARK(OUT,MI,sl,sc,el,ec,sev,msg)
 S MI=MI+1
 S OUT("markers",MI,"startLineNumber")=sl
 S OUT("markers",MI,"startColumn")=sc
 S OUT("markers",MI,"endLineNumber")=el
 S OUT("markers",MI,"endColumn")=ec
 S OUT("markers",MI,"severity")=sev
 S OUT("markers",MI,"message")=msg
 Q

 ; -----------------------------
 ; Completion (v1)
 ; -----------------------------

COMP(P,OUT)
 K OUT
 N text S text=$$TEXT(.P)
 N LINES,N S N=$$SPLIT(text,.LINES)
 N LBL D BUILDLABELS(.LINES,N,.LBL)

 N line,col S line=+$G(P("position","line")) I line<1 S line=1
 S col=+$G(P("position","column")) I col<1 S col=1
 N cur S cur=$G(LINES(line))
 N before S before=$E(cur,1,col-1)

 ; If completion after DO/GOTO -> suggest labels
 N mode S mode=""
 I before?1".".E S mode="label" ; dot blocks still label-call contexts
 I before?.E1" "1(1"do",1"d",1"goto",1"g")1" ".E S mode="label"

 N i S i=0
 I mode="label" D
 . N lab S lab=""
 . F  S lab=$O(LBL(lab)) Q:lab=""  D
 . . D ADDSUG(.OUT,.i,lab,12,lab,"Label")
 . Q

 ; Always include baseline keywords + intrinsics (small set)
 N kw
 F kw="set","kill","new","do","goto","if","for","quit","write","read","merge","open","close" D
 . D ADDSUG(.OUT,.i,kw,14,kw,"Command")
 F kw="$GET","$ORDER","$DATA","$PIECE","$TEXT","$FIND","$EXTRACT","$LENGTH","$JUSTIFY" D
 . D ADDSUG(.OUT,.i,kw,1,kw,"Intrinsic")
 Q

ADDSUG(OUT,I,label,kind,insert,detail)
 S I=I+1
 S OUT("suggestions",I,"label")=label
 S OUT("suggestions",I,"kind")=kind
 S OUT("suggestions",I,"insertText")=insert
 S OUT("suggestions",I,"detail")=detail
 Q

 ; -----------------------------
 ; Hover (v1)
 ; -----------------------------

HOVER(P,OUT)
 K OUT
 N text S text=$$TEXT(.P)
 N LINES,N S N=$$SPLIT(text,.LINES)
 N line,col S line=+$G(P("position","line")) I line<1 S line=1
 S col=+$G(P("position","column")) I col<1 S col=1
 N cur S cur=$G(LINES(line))
 N w,sc,ec D WORDAT(cur,col,.w,.sc,.ec)
 I w="" Q

 N u S u=$ZCONVERT(w,"U")
 N doc S doc=""
 I u="$GET" S doc="Returns value of a variable; optional default if undefined. Example: $GET(x,0)"
 I u="$ORDER" S doc="Iterates subscripts of a local/global array. Example: set s=$ORDER(^G(s))"
 I u="$PIECE" S doc="Extracts delimited pieces from a string. Example: $PIECE(str,\"^\",2)"
 I u="$DATA" S doc="Returns definedness of a variable/global node (0,1,10,11)."
 I doc="" Q

 S OUT("range","startLineNumber")=line
 S OUT("range","startColumn")=sc
 S OUT("range","endLineNumber")=line
 S OUT("range","endColumn")=ec
 S OUT("contents",1,"value")="**"_u_"**"
 S OUT("contents",2,"value")=$$ESCJSON(doc)
 Q

WORDAT(line,col,WORD,SC,EC)
 N i,s,e,ch
 S WORD="",SC=col,EC=col
 I line="" Q
 I col>$L(line)+1 S col=$L(line)+1
 ; expand left
 S s=col
 F i=col:-1:1 S ch=$E(line,i) Q:ch'?1AN&(ch'="%")&(ch'="$")  S s=i
 ; expand right
 S e=col-1
 F i=col:1:$L(line) S ch=$E(line,i) Q:ch'?1AN&(ch'="%")&(ch'="$")  S e=i
 I e<s Q
 S WORD=$E(line,s,e)
 S SC=s,EC=e+1
 Q

 ; -----------------------------
 ; Symbols / Outline (v1)
 ; -----------------------------

SYMBOLS(P,OUT)
 K OUT
 N text S text=$$TEXT(.P)
 N LINES,N S N=$$SPLIT(text,.LINES)
 N i,line,label
 N si S si=0
 F i=1:1:N D
 . S line=$G(LINES(i))
 . I $$ISINDENT(line) Q
 . S label=$$LABELAT(line) I label="" Q
 . S si=si+1
 . S OUT("symbols",si,"name")=label
 . S OUT("symbols",si,"kind")=12 ; Function
 . S OUT("symbols",si,"range","startLineNumber")=i
 . S OUT("symbols",si,"range","startColumn")=1
 . S OUT("symbols",si,"range","endLineNumber")=i
 . S OUT("symbols",si,"range","endColumn")=$L(line)+1
 . S OUT("symbols",si,"selectionRange")=OUT("symbols",si,"range")
 Q

 ; -----------------------------
 ; Definition / References (same file, labels)
 ; -----------------------------

DEF(P,OUT)
 K OUT
 N text S text=$$TEXT(.P)
 N LINES,N S N=$$SPLIT(text,.LINES)
 N LBL D BUILDLABELS(.LINES,N,.LBL)
 N line,col S line=+$G(P("position","line")) I line<1 S line=1
 S col=+$G(P("position","column")) I col<1 S col=1
 N cur S cur=$G(LINES(line))
 N w,sc,ec D WORDAT(cur,col,.w,.sc,.ec)
 I w="" Q
 N tgtLine S tgtLine=$G(LBL(w)) I tgtLine<1 Q
 N tgtText S tgtText=$G(LINES(tgtLine))
 S OUT("location","range","startLineNumber")=tgtLine
 S OUT("location","range","startColumn")=1
 S OUT("location","range","endLineNumber")=tgtLine
 S OUT("location","range","endColumn")=$L(tgtText)+1
 Q

REFS(P,OUT)
 K OUT
 N text S text=$$TEXT(.P)
 N LINES,N S N=$$SPLIT(text,.LINES)
 N line,col S line=+$G(P("position","line")) I line<1 S line=1
 S col=+$G(P("position","column")) I col<1 S col=1
 N cur S cur=$G(LINES(line))
 N w,sc,ec D WORDAT(cur,col,.w,.sc,.ec)
 I w="" Q

 N i,ri S ri=0
 N pat S pat="\b"_w_"\b"
 ; naive: scan for label token in DO/GOTO and definition
 N wL S wL=$ZCONVERT(w,"L")
 F i=1:1:N D
 . N s S s=$G(LINES(i))
 . I s="" Q
 . ; definition at line start
 . I '$$ISINDENT(s),$$LABELAT(s)=w D
 . . D ADDREF(.OUT,.ri,i,1,i,$L(w)+1)
 . ; calls: do/goto, including abbreviated d/g
 . N lo S lo=$ZCONVERT(s,"L")
 . N p
 . S p=$F(lo,"do "_wL) I p>0 D ADDREF(.OUT,.ri,i,p-$L(wL),i,p)
 . S p=$F(lo,"d "_wL) I p>0 D ADDREF(.OUT,.ri,i,p-$L(wL),i,p)
 . S p=$F(lo,"goto "_wL) I p>0 D ADDREF(.OUT,.ri,i,p-$L(wL),i,p)
 . S p=$F(lo,"g "_wL) I p>0 D ADDREF(.OUT,.ri,i,p-$L(wL),i,p)
 Q

ADDREF(OUT,RI,sl,sc,el,ec)
 S RI=RI+1
 S OUT("references",RI,"range","startLineNumber")=sl
 S OUT("references",RI,"range","startColumn")=sc
 S OUT("references",RI,"range","endLineNumber")=el
 S OUT("references",RI,"range","endColumn")=ec
 Q

 ; -----------------------------
 ; Formatting (v1, safe)
 ; -----------------------------

FORMAT(P,OUT)
 K OUT
 N text S text=$$TEXT(.P)
 N LINES,N S N=$$SPLIT(text,.LINES)
 N i,line
 N out S out=""
 F i=1:1:N D
 . S line=$$TRIMR($G(LINES(i)))
 . ; replace leading tabs with 2 spaces for deterministic diffs
 . N lead,rest
 . S lead=$P(line,$C(9),1)
 . I $F(line,$C(9))>0 D
 . . ; naive: convert all tabs to 2 spaces
 . . S line=$TR(line,$C(9),"  ")
 . S out=out_line_$C(10)
 ; drop final newline to match Monaco expectations
 I $E(out,$L(out))=$C(10) S out=$E(out,1,$L(out)-1)
 S OUT("text")=out
 Q