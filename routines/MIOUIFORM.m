MIOUIFORM ; MIOUI form builders
 Q
 ;
INIT(TCTX,KEY,TITLE,LEAD,ACTION,METHOD)
 K TCTX("form",$G(KEY))
 S TCTX("form",$G(KEY),"title")=$G(TITLE)
 S TCTX("form",$G(KEY),"lead")=$G(LEAD)
 S TCTX("form",$G(KEY),"action")=$G(ACTION)
 S TCTX("form",$G(KEY),"method")=$S($G(METHOD)'="":METHOD,1:"post")
 Q
 ;
FIELD(TCTX,KEY,IDX,TYPE,NAME,LABEL,VALUE,PLACEHOLDER,HELP,ERR)
 N K S K=$G(KEY)
 S TCTX("form",K,"field",IDX,"type")=$G(TYPE)
 S TCTX("form",K,"field",IDX,"name")=$G(NAME)
 S TCTX("form",K,"field",IDX,"label")=$G(LABEL)
 S TCTX("form",K,"field",IDX,"value")=$G(VALUE)
 S TCTX("form",K,"field",IDX,"placeholder")=$G(PLACEHOLDER)
 S TCTX("form",K,"field",IDX,"help")=$G(HELP)
 S TCTX("form",K,"field",IDX,"hasHelp")=$S($G(HELP)'="":1,1:0)
 S TCTX("form",K,"field",IDX,"error")=$G(ERR)
 S TCTX("form",K,"field",IDX,"hasError")=$S($G(ERR)'="":1,1:0)
 S TCTX("form",K,"field",IDX,"isInput")=$S(TYPE="text"!(TYPE="email")!(TYPE="password")!(TYPE="number")!(TYPE="date"):1,1:0)
 S TCTX("form",K,"field",IDX,"isTextarea")=$S(TYPE="textarea":1,1:0)
 S TCTX("form",K,"field",IDX,"isSelect")=$S(TYPE="select":1,1:0)
 S TCTX("form",K,"field",IDX,"isCheckbox")=$S(TYPE="checkbox":1,1:0)
 S TCTX("form",K,"field",IDX,"isToggle")=$S(TYPE="toggle":1,1:0)
 Q
 ;
OPTION(TCTX,KEY,FIELDIDX,OPTIDX,VALUE,LABEL,SELECTED)
 S TCTX("form",$G(KEY),"field",FIELDIDX,"option",OPTIDX,"value")=$G(VALUE)
 S TCTX("form",$G(KEY),"field",FIELDIDX,"option",OPTIDX,"label")=$G(LABEL)
 S TCTX("form",$G(KEY),"field",FIELDIDX,"option",OPTIDX,"isSelected")=+$G(SELECTED)
 Q
 ;
CHECKED(TCTX,KEY,IDX,FLAG)
 S TCTX("form",$G(KEY),"field",IDX,"checked")=+$G(FLAG)
 Q
 ;
ACTION(TCTX,KEY,IDX,LABEL,TYPE,TONE)
 N CLS
 S CLS=$S($G(TONE)="primary":"primary-button",$G(TONE)="danger":"danger-button",1:"quick-button")
 S TCTX("form",$G(KEY),"actionBtn",IDX,"label")=$G(LABEL)
 S TCTX("form",$G(KEY),"actionBtn",IDX,"type")=$S($G(TYPE)'="":TYPE,1:"submit")
 S TCTX("form",$G(KEY),"actionBtn",IDX,"tone")=CLS
 S TCTX("form",$G(KEY),"actionBtn",IDX,"class")=CLS
 Q
 ;
FINAL(TCTX,KEY)
 N C,I,E
 S (C,I,E)=0
 F  S I=$O(TCTX("form",$G(KEY),"field",I)) Q:'I  D
 . S C=C+1
 . I +$G(TCTX("form",$G(KEY),"field",I,"hasError")) S E=E+1
 S TCTX("form",$G(KEY),"fieldCount")=C
 S TCTX("form",$G(KEY),"errorCount")=E
 S TCTX("form",$G(KEY),"hasFields")=$S(C>0:1,1:0)
 S TCTX("form",$G(KEY),"hasErrors")=$S(E>0:1,1:0)
 Q
 ;
