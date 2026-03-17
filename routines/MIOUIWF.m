MIOUIWF ; MIOUI workflow builders
 Q
 ;
ONBINIT(TCTX,KEY,TITLE,LEAD,PRILBL,PRIHREF,SECLBL,SECHREF)
 K TCTX("onboarding",$G(KEY))
 S TCTX("onboarding",$G(KEY),"title")=$G(TITLE)
 S TCTX("onboarding",$G(KEY),"lead")=$G(LEAD)
 S TCTX("onboarding",$G(KEY),"primaryLabel")=$G(PRILBL)
 S TCTX("onboarding",$G(KEY),"primaryHref")=$G(PRIHREF)
 S TCTX("onboarding",$G(KEY),"secondaryLabel")=$G(SECLBL)
 S TCTX("onboarding",$G(KEY),"secondaryHref")=$G(SECHREF)
 S TCTX("onboarding",$G(KEY),"badgeClass")=$$BADGE^MIOUITHEME("sky")
 Q
 ;
ONBSTEP(TCTX,KEY,IDX,TITLE,BODY,STATE)
 N TONE
 S TONE=$S($G(STATE)="complete":"emerald",$G(STATE)="current":"sky",$G(STATE)="warning":"amber",1:"slate")
 S TCTX("onboarding",$G(KEY),"step",+$G(IDX),"number")=+$G(IDX)
 S TCTX("onboarding",$G(KEY),"step",+$G(IDX),"title")=$G(TITLE)
 S TCTX("onboarding",$G(KEY),"step",+$G(IDX),"body")=$G(BODY)
 S TCTX("onboarding",$G(KEY),"step",+$G(IDX),"state")=$G(STATE)
 S TCTX("onboarding",$G(KEY),"step",+$G(IDX),"label")=$S($G(STATE)="current":"In progress",$G(STATE)="complete":"Complete",$G(STATE)="warning":"Attention",1:"Queued")
 S TCTX("onboarding",$G(KEY),"step",+$G(IDX),"badgeClass")=$$BADGE^MIOUITHEME(TONE)
 S TCTX("onboarding",$G(KEY),"step",+$G(IDX),"isCurrent")=$S($G(STATE)="current":1,1:0)
 S TCTX("onboarding",$G(KEY),"step",+$G(IDX),"isComplete")=$S($G(STATE)="complete":1,1:0)
 Q
 ;
ONBFINAL(TCTX,KEY)
 N I,TOT,COM,CUR
 S (I,TOT,COM,CUR)=0
 F  S I=$O(TCTX("onboarding",$G(KEY),"step",I)) Q:'I  D
 . S TOT=TOT+1
 . I +$G(TCTX("onboarding",$G(KEY),"step",I,"isComplete")) S COM=COM+1
 . I +$G(TCTX("onboarding",$G(KEY),"step",I,"isCurrent")) S CUR=I
 . S TCTX("onboarding",$G(KEY),"step",I,"stepLabel")="Step "_I_" of "_$S(TOT:TOT,1:1)
 S TCTX("onboarding",$G(KEY),"totalCount")=TOT
 S TCTX("onboarding",$G(KEY),"completeCount")=COM
 S TCTX("onboarding",$G(KEY),"currentStep")=CUR
 S TCTX("onboarding",$G(KEY),"summary")=COM_" of "_TOT_" complete"
 Q
 ;
CONFIRM(TCTX,KEY,TITLE,BODY,TONE,CONFLBL,CONFHREF,CANLBL,CANHREF)
 N BADGE,PANEL
 S BADGE=$$BADGE^MIOUITHEME($S($G(TONE)="":"amber",1:$G(TONE)))
 S PANEL=$$PANEL^MIOUITHEME($S($G(TONE)="":"amber",1:$G(TONE)))
 K TCTX("confirm",$G(KEY))
 S TCTX("confirm",$G(KEY),"title")=$G(TITLE)
 S TCTX("confirm",$G(KEY),"body")=$G(BODY)
 S TCTX("confirm",$G(KEY),"badgeClass")=BADGE
 S TCTX("confirm",$G(KEY),"panelClass")=PANEL
 S TCTX("confirm",$G(KEY),"confirmLabel")=$G(CONFLBL)
 S TCTX("confirm",$G(KEY),"confirmHref")=$G(CONFHREF)
 S TCTX("confirm",$G(KEY),"cancelLabel")=$G(CANLBL)
 S TCTX("confirm",$G(KEY),"cancelHref")=$G(CANHREF)
 Q
 ;
DROPINIT(TCTX,KEY,TITLE,PROMPT,ACCEPT,HELP)
 K TCTX("dropzone",$G(KEY))
 S TCTX("dropzone",$G(KEY),"title")=$G(TITLE)
 S TCTX("dropzone",$G(KEY),"prompt")=$G(PROMPT)
 S TCTX("dropzone",$G(KEY),"acceptedTypes")=$G(ACCEPT)
 S TCTX("dropzone",$G(KEY),"help")=$G(HELP)
 Q
 ;
DROPFILE(TCTX,KEY,IDX,NAME,SIZE,STATUS,TONE)
 N USE
 S USE=$S($G(TONE)'="":$G(TONE),$G(STATUS)="Ready":"emerald",$G(STATUS)="Needs review":"amber",1:"sky")
 S TCTX("dropzone",$G(KEY),"file",+$G(IDX),"name")=$G(NAME)
 S TCTX("dropzone",$G(KEY),"file",+$G(IDX),"size")=$G(SIZE)
 S TCTX("dropzone",$G(KEY),"file",+$G(IDX),"status")=$G(STATUS)
 S TCTX("dropzone",$G(KEY),"file",+$G(IDX),"badgeClass")=$$BADGE^MIOUITHEME(USE)
 S TCTX("dropzone",$G(KEY),"file",+$G(IDX),"tone")=USE
 Q
 ;
DROPFINAL(TCTX,KEY)
 N I,C,READY
 S (I,C,READY)=0
 F  S I=$O(TCTX("dropzone",$G(KEY),"file",I)) Q:'I  D
 . S C=C+1
 . I $G(TCTX("dropzone",$G(KEY),"file",I,"status"))="Ready" S READY=READY+1
 S TCTX("dropzone",$G(KEY),"fileCount")=C
 S TCTX("dropzone",$G(KEY),"readyCount")=READY
 S TCTX("dropzone",$G(KEY),"summary")=READY_" ready / "_C_" staged"
 Q
 ;
STEPNOTE(TCTX,IDX,HELP,ACTIONLABEL,ACTIONHREF)
 S TCTX("stepper",+$G(IDX),"help")=$G(HELP)
 S TCTX("stepper",+$G(IDX),"actionLabel")=$G(ACTIONLABEL)
 S TCTX("stepper",+$G(IDX),"actionHref")=$G(ACTIONHREF)
 Q
 ;
STEPFINAL(TCTX)
 N I,TOT,CUR
 S (I,TOT,CUR)=0
 F  S I=$O(TCTX("stepper",I)) Q:'I  S TOT=TOT+1 I +$G(TCTX("stepper",I,"isCurrent")) S CUR=I
 S I=0
 F  S I=$O(TCTX("stepper",I)) Q:'I  D
 . S TCTX("stepper",I,"total")=TOT
 . S TCTX("stepper",I,"ordinalLabel")="Step "_I_" of "_TOT
 . S TCTX("stepper",I,"isLast")=$S(I=TOT:1,1:0)
 . S TCTX("stepper",I,"connectorClass")=$S(I=TOT:"hidden",1:"block")
 S TCTX("stepperMeta","total")=TOT
 S TCTX("stepperMeta","current")=CUR
 Q
 ;
