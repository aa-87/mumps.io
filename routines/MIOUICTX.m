MIOUICTX ; MIOUI shared SSR context builders
 Q
 ;
BASE(TCTX)
 K TCTX
 S TCTX("app","name")="MIOUI"
 S TCTX("app","tagline")="SSR-first Tailwind UI package for dense MUMPS business applications"
 S TCTX("app","version")=$$VERSION^MIOUI()
 S TCTX("shell","eyebrow")="MUMPS.IO / MIOUI"
 S TCTX("shell","menuLabel")="Open navigation"
 S TCTX("shell","helpLabel")="Open component help"
 S TCTX("shell","showSearch")=1
 S TCTX("shell","searchPlaceholder")="Search components, pages, and patterns"
 S TCTX("footer","links",1,"label")="Home"
 S TCTX("footer","links",1,"href")="/mioui"
 S TCTX("footer","links",2,"label")="Components"
 S TCTX("footer","links",2,"href")="/mioui/components"
 S TCTX("footer","links",3,"label")="Tables"
 S TCTX("footer","links",3,"href")="/mioui/tables"
 S TCTX("footer","links",4,"label")="Forms"
 S TCTX("footer","links",4,"href")="/mioui/forms"
 S TCTX("footer","links",5,"label")="Export"
 S TCTX("footer","links",5,"href")="/mioui/export"
 S TCTX("footer","links",6,"label")="Billing"
 S TCTX("footer","links",6,"href")="/mioui/billing"
 D NAV(.TCTX)
 D PAGE(.TCTX,"MIOUI","MIOUI","SSR UI system","Package home")
 Q
 ;
NAV(TCTX)
 K TCTX("nav")
 S TCTX("nav",1,"key")="home"
 S TCTX("nav",1,"label")="Home"
 S TCTX("nav",1,"href")="/mioui"
 S TCTX("nav",1,"hint")="Overview and package status"
 S TCTX("nav",2,"key")="components"
 S TCTX("nav",2,"label")="Components"
 S TCTX("nav",2,"href")="/mioui/components"
 S TCTX("nav",2,"hint")="Panels, badges, alerts, tabs, timelines"
 S TCTX("nav",3,"key")="tables"
 S TCTX("nav",3,"label")="Tables"
 S TCTX("nav",3,"href")="/mioui/tables"
 S TCTX("nav",3,"hint")="Dense table, filter, bulk, audit patterns"
 S TCTX("nav",4,"key")="forms"
 S TCTX("nav",4,"label")="Forms"
 S TCTX("nav",4,"href")="/mioui/forms"
 S TCTX("nav",4,"hint")="Field, select, toggle, section, action footer"
 S TCTX("nav",5,"key")="export"
 S TCTX("nav",5,"label")="Export"
 S TCTX("nav",5,"href")="/mioui/export"
 S TCTX("nav",5,"hint")="Field catalog, order editor, sticky actions"
 S TCTX("nav",6,"key")="billing"
 S TCTX("nav",6,"label")="Billing"
 S TCTX("nav",6,"href")="/mioui/billing"
 S TCTX("nav",6,"hint")="Claim, service line, diagnostics, artifacts"
 Q
 ;
ACT(TCTX,KEY)
 N I
 S I=0
 F  S I=$O(TCTX("nav",I)) Q:'I  S TCTX("nav",I,"isActive")=$S($G(TCTX("nav",I,"key"))=$G(KEY):1,1:0)
 Q
 ;
PAGE(TCTX,TITLE,HEADING,LEAD,EYEBROW)
 S TCTX("page","title")=$G(TITLE)
 S TCTX("page","heading")=$G(HEADING)
 S TCTX("page","lead")=$G(LEAD)
 S TCTX("page","eyebrow")=$G(EYEBROW)
 Q
 ;
TAB(TCTX,IDX,LABEL,HREF,ACTIVE)
 S TCTX("tabs",IDX,"label")=$G(LABEL)
 S TCTX("tabs",IDX,"href")=$G(HREF)
 S TCTX("tabs",IDX,"isActive")=+$G(ACTIVE)
 Q
 ;
STEP(TCTX,IDX,TITLE,BODY,STATE)
 N BADGE
 S BADGE=$S($G(STATE)="complete":"badge-emerald",$G(STATE)="current":"badge-sky",1:"badge-slate")
 S TCTX("stepper",IDX,"number")=+$G(IDX)
 S TCTX("stepper",IDX,"title")=$G(TITLE)
 S TCTX("stepper",IDX,"body")=$G(BODY)
 S TCTX("stepper",IDX,"state")=$G(STATE)
 S TCTX("stepper",IDX,"label")=$G(STATE)
 S TCTX("stepper",IDX,"badgeClass")=BADGE
 S TCTX("stepper",IDX,"isCurrent")=$S($G(STATE)="current":1,1:0)
 S TCTX("stepper",IDX,"isComplete")=$S($G(STATE)="complete":1,1:0)
 Q
 ;
TIMELINE(TCTX,IDX,STAMP,TITLE,BODY,TONE)
 S TCTX("timeline",IDX,"stamp")=$G(STAMP)
 S TCTX("timeline",IDX,"title")=$G(TITLE)
 S TCTX("timeline",IDX,"body")=$G(BODY)
 S TCTX("timeline",IDX,"tone")=$$BADGE^MIOUITHEME($G(TONE))
 Q
 ;
ALERT(TCTX,IDX,KIND,TITLE,BODY)
 S TCTX("alert",IDX,"kind")=$G(KIND)
 S TCTX("alert",IDX,"label")=$G(KIND)
 S TCTX("alert",IDX,"title")=$G(TITLE)
 S TCTX("alert",IDX,"body")=$G(BODY)
 S TCTX("alert",IDX,"badgeClass")=$$BADGE^MIOUITHEME($G(KIND))
 S TCTX("alert",IDX,"panelClass")=$$PANEL^MIOUITHEME($G(KIND))
 Q
 ;
COUNT(REF)
 N N,C
 S C=0,N=0
 F  S N=$O(@REF@(N)) Q:'N  S C=C+1
 Q C
 ;
