MIOUITSX ; review sync and annotation builders and route
 Q
 ;
REG(CONF)
 N META
 K META S META("authRequired")=0,META("roles")=""
 D ADDM^MIOROUTE("GET","/mioui/table-review-sync","REVIEWSYNC^MIOUITSX",.META)
 S ^MIO("ROUTE","RAW","GET","/mioui/table-review-sync")="REVIEWSYNC^MIOUITSX"
 S ^MIO("ROUTE","META","GET","/mioui/table-review-sync","authRequired")=0
 S ^MIO("ROUTE","META","GET","/mioui/table-review-sync","roles")=""
 Q
 ;
REVIEWSYNC(DEV,CONF,REQ,CTX)
 N TCTX,OUT,ERR
 D BUILD(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/mioui_table_review_sync.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 I $D(ERR) D RESPERR^MIOUIDEMO(.DEV,.CONF,.CTX,500,"template_error") Q
 D RESPHTML^MIOUIDEMO(.DEV,.CONF,.CTX,.OUT)
 Q
 ;
BUILD(CONF,REQ,CTX,TCTX)
 D BASE^MIOUICTX(.TCTX)
 D APPLY^MIOUITHEME(.CONF,.TCTX)
 D ACT^MIOUICTX(.TCTX,"tables")
 D PAGE^MIOUICTX(.TCTX,"MIOUI / Table review sync","Table review sync","Facet counts, inline annotations, width presets, row comparison, and split trace synchronization for data-intensive review queues.","Table review sync")
 S TCTX("syncTitle")="Table review sync"
 S TCTX("syncLead")="Use these combined surfaces when operators need to move between a large review grid and the trace evidence behind specific rows and cells."
 ; facets
 S TCTX("sync","facetTitle")="Facet counts"
 S TCTX("sync","facetLead")="Facet bars keep the server-owned count picture visible while operators narrow million-row queues by status, payer, owner, and procedure."
 S TCTX("sync","facetClearHref")="/mioui/table-review-sync?clear=1"
 D FACET(.TCTX,1,"Status","Previewed",24812,1,"/mioui/table-review-sync?facet=status:previewed")
 D FACET(.TCTX,2,"Payer","Alpha Health",8104,1,"/mioui/table-review-sync?facet=payer:alpha")
 D FACET(.TCTX,3,"Region","West",5401,0,"/mioui/table-review-sync?facet=region:west")
 D FACET(.TCTX,4,"Procedure","99213",2140,1,"/mioui/table-review-sync?facet=procedure:99213")
 ; inline notes
 S TCTX("sync","notesTitle")="Inline cell notes"
 S TCTX("sync","notesLead")="Annotations belong next to the row and column they explain, not buried in a separate comment queue."
 D NOTE(.TCTX,1,"CLM-884210","Allowed amount","Variance confirmed with payer portal.","openCellNote",1)
 D NOTE(.TCTX,2,"CLM-884215","Procedure","99213 verified against source file.","openCellNote",0)
 D NOTE(.TCTX,3,"CLM-884219","Owner","Moved to west pod after QA review.","openCellNote",0)
 ; presets
 S TCTX("sync","presetTitle")="Width presets and density packs"
 S TCTX("sync","presetLead")="Very wide tables need persistent width presets and density packs so different roles can reopen the same queue without re-tuning the screen."
 D PRESET(.TCTX,1,"Review compact","applyWidthPreset","claim=18rem;patient=14rem;status=10rem",1)
 D PRESET(.TCTX,2,"Finance totals","applyWidthPreset","charge=9rem;allowed=9rem;variance=9rem",0)
 D PRESET(.TCTX,3,"Audit detail","applyWidthPreset","trace=20rem;source=16rem;payer=14rem",0)
 D DPACK(.TCTX,1,"Dense","applyDensityPack","29px rows",1)
 D DPACK(.TCTX,2,"Comfort","applyDensityPack","36px rows",0)
 D DPACK(.TCTX,3,"Presentation","applyDensityPack","44px rows",0)
 ; compare rows
 S TCTX("sync","compareTitle")="Compare two rows"
 S TCTX("sync","compareLead")="Operators often need to compare a current claim against a sibling, re-bill, or prior submission without leaving the review surface."
 D ROWFACT(.TCTX,"left",1,"Claim","CLM-884210")
 D ROWFACT(.TCTX,"left",2,"Patient","MARTIN, ALEX")
 D ROWFACT(.TCTX,"left",3,"DOS","2026-03-11")
 D ROWFACT(.TCTX,"left",4,"Procedure","99213")
 D ROWFACT(.TCTX,"left",5,"Charge","125.00")
 D ROWFACT(.TCTX,"right",1,"Claim","CLM-884211")
 D ROWFACT(.TCTX,"right",2,"Patient","MARTIN, ALEX")
 D ROWFACT(.TCTX,"right",3,"DOS","2026-03-18")
 D ROWFACT(.TCTX,"right",4,"Procedure","99214")
 D ROWFACT(.TCTX,"right",5,"Charge","167.00")
 D DIFF(.TCTX,1,"Procedure changed","99213 -> 99214","warning")
 D DIFF(.TCTX,2,"Charge changed","125.00 -> 167.00","info")
 D DIFF(.TCTX,3,"DOS moved","2026-03-11 -> 2026-03-18","sky")
 ; split sync
 S TCTX("sync","splitTitle")="Split grid / trace synchronization"
 S TCTX("sync","splitLead")="Split view keeps the active grid row and the trace evidence synchronized so operators can review cause and effect without losing context."
 D GRIDROW(.TCTX,1,"CLM-884210","99213","Previewed",1)
 D GRIDROW(.TCTX,2,"CLM-884211","99214","Needs review",0)
 D GRIDROW(.TCTX,3,"CLM-884215","93000","Published",0)
 D TRACESTEP(.TCTX,1,"837 parse","Segment SV1 read successfully","syncTraceToRow")
 D TRACESTEP(.TCTX,2,"Profile transform","Allowed amount normalized from payer rules","syncTraceToRow")
 D TRACESTEP(.TCTX,3,"CSV preview","Output row generated for review bundle","syncTraceToRow")
 S TCTX("sync","split","callbackA")="syncTraceToRow"
 S TCTX("sync","split","callbackB")="syncRowToTrace"
 Q
 ;
FACET(TCTX,IDX,GROUP,LABEL,COUNT,ACTIVE,HREF)
 S TCTX("sync","facet",+$G(IDX),"group")=$G(GROUP)
 S TCTX("sync","facet",+$G(IDX),"label")=$G(LABEL)
 S TCTX("sync","facet",+$G(IDX),"count")=$G(COUNT)
 S TCTX("sync","facet",+$G(IDX),"href")=$G(HREF)
 S TCTX("sync","facet",+$G(IDX),"isActive")=+$G(ACTIVE)
 S TCTX("sync","facet",+$G(IDX),"badgeClass")=$S(+$G(ACTIVE):"badge badge-sky",1:"badge badge-slate")
 Q
 ;
NOTE(TCTX,IDX,ROW,COLUMN,TEXT,CALLBACK,ACTIVE)
 S TCTX("sync","note",+$G(IDX),"row")=$G(ROW)
 S TCTX("sync","note",+$G(IDX),"column")=$G(COLUMN)
 S TCTX("sync","note",+$G(IDX),"text")=$G(TEXT)
 S TCTX("sync","note",+$G(IDX),"callback")=$G(CALLBACK)
 S TCTX("sync","note",+$G(IDX),"isActive")=+$G(ACTIVE)
 S TCTX("sync","note",+$G(IDX),"badgeClass")=$S(+$G(ACTIVE):"badge badge-amber",1:"badge badge-slate")
 Q
 ;
PRESET(TCTX,IDX,LABEL,CALLBACK,DETAIL,ACTIVE)
 S TCTX("sync","preset",+$G(IDX),"label")=$G(LABEL)
 S TCTX("sync","preset",+$G(IDX),"callback")=$G(CALLBACK)
 S TCTX("sync","preset",+$G(IDX),"detail")=$G(DETAIL)
 S TCTX("sync","preset",+$G(IDX),"isActive")=+$G(ACTIVE)
 S TCTX("sync","preset",+$G(IDX),"class")=$S(+$G(ACTIVE):"primary-button",1:"quick-button")
 Q
 ;
DPACK(TCTX,IDX,LABEL,CALLBACK,DETAIL,ACTIVE)
 S TCTX("sync","density",+$G(IDX),"label")=$G(LABEL)
 S TCTX("sync","density",+$G(IDX),"callback")=$G(CALLBACK)
 S TCTX("sync","density",+$G(IDX),"detail")=$G(DETAIL)
 S TCTX("sync","density",+$G(IDX),"isActive")=+$G(ACTIVE)
 S TCTX("sync","density",+$G(IDX),"badgeClass")=$S(+$G(ACTIVE):"badge badge-emerald",1:"badge badge-slate")
 Q
 ;
ROWFACT(TCTX,SIDE,IDX,LABEL,VALUE)
 S TCTX("sync","compare",$G(SIDE),"fact",+$G(IDX),"label")=$G(LABEL)
 S TCTX("sync","compare",$G(SIDE),"fact",+$G(IDX),"value")=$G(VALUE)
 Q
 ;
DIFF(TCTX,IDX,LABEL,VALUE,TONE)
 S TCTX("sync","compare","diff",+$G(IDX),"label")=$G(LABEL)
 S TCTX("sync","compare","diff",+$G(IDX),"value")=$G(VALUE)
 S TCTX("sync","compare","diff",+$G(IDX),"badgeClass")=$$BADGE^MIOUITHEME($S($G(TONE)'="":$G(TONE),1:"slate"))
 Q
 ;
GRIDROW(TCTX,IDX,CLAIM,CODE,STATUS,ACTIVE)
 S TCTX("sync","split","row",+$G(IDX),"claim")=$G(CLAIM)
 S TCTX("sync","split","row",+$G(IDX),"code")=$G(CODE)
 S TCTX("sync","split","row",+$G(IDX),"status")=$G(STATUS)
 S TCTX("sync","split","row",+$G(IDX),"isActive")=+$G(ACTIVE)
 S TCTX("sync","split","row",+$G(IDX),"rowClass")=$S(+$G(ACTIVE):"border-sky-400/40 bg-sky-500/10",1:"border-white/10")
 Q
 ;
TRACESTEP(TCTX,IDX,LABEL,DETAIL,CALLBACK)
 S TCTX("sync","split","trace",+$G(IDX),"label")=$G(LABEL)
 S TCTX("sync","split","trace",+$G(IDX),"detail")=$G(DETAIL)
 S TCTX("sync","split","trace",+$G(IDX),"callback")=$G(CALLBACK)
 Q
 ;
