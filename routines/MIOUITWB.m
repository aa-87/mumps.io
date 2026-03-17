MIOUITWB ; table workbench builders and route
 Q
 ;
REG(CONF)
 N META
 K META S META("authRequired")=0,META("roles")=""
 D ADDM^MIOROUTE("GET","/mioui/table-workbench","TABLEWB^MIOUITWB",.META)
 S ^MIO("ROUTE","RAW","GET","/mioui/table-workbench")="TABLEWB^MIOUITWB"
 S ^MIO("ROUTE","META","GET","/mioui/table-workbench","authRequired")=0
 S ^MIO("ROUTE","META","GET","/mioui/table-workbench","roles")=""
 Q
 ;
TABLEWB(DEV,CONF,REQ,CTX)
 N TCTX,OUT,ERR
 D BUILD(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/mioui_table_workbench.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 I $D(ERR) D RESPERR^MIOUIDEMO(.DEV,.CONF,.CTX,500,"template_error") Q
 D RESPHTML^MIOUIDEMO(.DEV,.CONF,.CTX,.OUT)
 Q
 ;
BUILD(CONF,REQ,CTX,TCTX)
 D BASE^MIOUICTX(.TCTX)
 D APPLY^MIOUITHEME(.CONF,.TCTX)
 D ACT^MIOUICTX(.TCTX,"tables")
 D PAGE^MIOUICTX(.TCTX,"MIOUI / Table workbench","Table workbench","Combined elements around very large server-owned data tables: queue metrics, query builder, saved views, bulk actions, row inspector, and export-current-view state.","Detailed table workbench")
 ; queue metrics
 D METRIC(.TCTX,1,"Visible rows","250","Current window","sky")
 D METRIC(.TCTX,2,"Selected rows","128","Bulk scope","emerald")
 D METRIC(.TCTX,3,"Active filters","6","Scoped result set","amber")
 D METRIC(.TCTX,4,"Sort rules","3","Ordered server sort","violet")
 ; query rules
 S TCTX("workbench","queryTitle")="Query builder"
 S TCTX("workbench","queryLead")="Server-owned rules keep very large queues deterministic, auditable, and easy to re-open later."
 D RULE(.TCTX,1,"status","in","Queued, Previewed, Published")
 D RULE(.TCTX,2,"payer_name","contains","Alpha Health")
 D RULE(.TCTX,3,"procedure_code","equals","99213")
 D RULE(.TCTX,4,"owner_region","equals","West")
 ; active chips
 D CHIP(.TCTX,1,"status: previewed")
 D CHIP(.TCTX,2,"payer: Alpha Health")
 D CHIP(.TCTX,3,"procedure: 99213")
 D CHIP(.TCTX,4,"region: West")
 ; saved views
 S TCTX("workbench","viewsTitle")="Saved views"
 D VIEW(.TCTX,1,"My preview queue","Primary operator queue",1,"24,812 rows","/mioui/large-table?view=preview")
 D VIEW(.TCTX,2,"West 99213 review","High-scan west region queue",0,"8,104 rows","/mioui/large-table?view=west-99213")
 D VIEW(.TCTX,3,"Published audit sample","Pinned audit slice for finance",0,"1,240 rows","/mioui/large-table?view=audit-sample")
 ; bulk actions
 S TCTX("workbench","bulk","title")="Bulk actions"
 S TCTX("workbench","bulk","selectedLabel")="128 selected rows"
 S TCTX("workbench","bulk","lead")="Bulk actions should always reflect the exact current selection, filter scope, and view ownership."
 D BACT(.TCTX,1,"Publish selected","applyBulkPublish","/mioui/billing","primary-button")
 D BACT(.TCTX,2,"Assign reviewer","assignReviewer","/mioui/operators","quick-button")
 D BACT(.TCTX,3,"Clear selection","clearSelectedRows","/mioui/table-workbench","ghost-button")
 ; row inspector
 S TCTX("workbench","inspect","title")="Row inspector"
 S TCTX("workbench","inspect","subtitle")="Selected claim / patient"
 D FACT(.TCTX,1,"Claim","CLM-884210")
 D FACT(.TCTX,2,"Patient","MARTIN, ALEX")
 D FACT(.TCTX,3,"Payer","Alpha Health")
 D FACT(.TCTX,4,"Date of service","2026-03-11")
 D FACT(.TCTX,5,"Procedure","99213")
 D FACT(.TCTX,6,"Charge","125.00")
 D IACT(.TCTX,1,"Open preview","/mioui/billing","primary-button")
 D IACT(.TCTX,2,"Open trace","/mioui/trace","quick-button")
 ; export current view
 S TCTX("workbench","export","title")="Export current view"
 S TCTX("workbench","export","summary")="Exactly export the active filters, sort stack, visible columns, and selection state of the current queue."
 S TCTX("workbench","export","query")="status in (queued,previewed,published) AND payer_name contains 'Alpha Health' AND procedure_code = 99213"
 S TCTX("workbench","export","sort")="charge desc, date_of_service asc, claim_id asc"
 S TCTX("workbench","export","columns")="Claim, Patient, DOS, Procedure, Charge, Status, Payer, Owner"
 D EACT(.TCTX,1,"Export CSV","exportCurrentViewCsv","/mioui/export","primary-button")
 D EACT(.TCTX,2,"Export audit package","exportCurrentViewAudit","/mioui/trace","quick-button")
 D EACT(.TCTX,3,"Copy API query","copyCurrentViewQuery","/mioui/table-workbench","ghost-button")
 Q
 ;
METRIC(TCTX,IDX,LABEL,VALUE,NOTE,TONE)
 S TCTX("workbench","metric",+$G(IDX),"label")=$G(LABEL)
 S TCTX("workbench","metric",+$G(IDX),"value")=$G(VALUE)
 S TCTX("workbench","metric",+$G(IDX),"note")=$G(NOTE)
 S TCTX("workbench","metric",+$G(IDX),"badgeClass")=$$BADGE^MIOUITHEME($S($G(TONE)'="":$G(TONE),1:"slate"))
 Q
 ;
RULE(TCTX,IDX,FIELD,OPERATOR,VALUE)
 S TCTX("workbench","rule",+$G(IDX),"field")=$G(FIELD)
 S TCTX("workbench","rule",+$G(IDX),"operator")=$G(OPERATOR)
 S TCTX("workbench","rule",+$G(IDX),"value")=$G(VALUE)
 Q
 ;
CHIP(TCTX,IDX,LABEL)
 S TCTX("workbench","chip",+$G(IDX),"label")=$G(LABEL)
 S TCTX("workbench","chip",+$G(IDX),"class")="badge badge-slate"
 Q
 ;
VIEW(TCTX,IDX,LABEL,NOTE,ACTIVE,COUNT,HREF)
 S TCTX("workbench","view",+$G(IDX),"label")=$G(LABEL)
 S TCTX("workbench","view",+$G(IDX),"note")=$G(NOTE)
 S TCTX("workbench","view",+$G(IDX),"rowCount")=$G(COUNT)
 S TCTX("workbench","view",+$G(IDX),"href")=$G(HREF)
 S TCTX("workbench","view",+$G(IDX),"isActive")=+$G(ACTIVE)
 S TCTX("workbench","view",+$G(IDX),"badgeClass")=$S(+$G(ACTIVE):"badge badge-sky",1:"badge badge-slate")
 S TCTX("workbench","view",+$G(IDX),"stateLabel")=$S(+$G(ACTIVE):"Active",1:"Saved")
 Q
 ;
BACT(TCTX,IDX,LABEL,CALLBACK,HREF,CLASS)
 S TCTX("workbench","bulk","action",+$G(IDX),"label")=$G(LABEL)
 S TCTX("workbench","bulk","action",+$G(IDX),"callback")=$G(CALLBACK)
 S TCTX("workbench","bulk","action",+$G(IDX),"href")=$G(HREF)
 S TCTX("workbench","bulk","action",+$G(IDX),"class")=$S($G(CLASS)'="":$G(CLASS),1:"quick-button")
 Q
 ;
FACT(TCTX,IDX,LABEL,VALUE)
 S TCTX("workbench","inspect","fact",+$G(IDX),"label")=$G(LABEL)
 S TCTX("workbench","inspect","fact",+$G(IDX),"value")=$G(VALUE)
 Q
 ;
IACT(TCTX,IDX,LABEL,HREF,CLASS)
 S TCTX("workbench","inspect","action",+$G(IDX),"label")=$G(LABEL)
 S TCTX("workbench","inspect","action",+$G(IDX),"href")=$G(HREF)
 S TCTX("workbench","inspect","action",+$G(IDX),"class")=$S($G(CLASS)'="":$G(CLASS),1:"quick-button")
 Q
 ;
EACT(TCTX,IDX,LABEL,CALLBACK,HREF,CLASS)
 S TCTX("workbench","export","action",+$G(IDX),"label")=$G(LABEL)
 S TCTX("workbench","export","action",+$G(IDX),"callback")=$G(CALLBACK)
 S TCTX("workbench","export","action",+$G(IDX),"href")=$G(HREF)
 S TCTX("workbench","export","action",+$G(IDX),"class")=$S($G(CLASS)'="":$G(CLASS),1:"quick-button")
 Q
 ;
