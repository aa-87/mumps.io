MIOUITMX ; advanced table mechanics builders and route
 Q
 ;
REG(CONF)
 N META
 K META S META("authRequired")=0,META("roles")=""
 D ADDM^MIOROUTE("GET","/mioui/advanced-table","ADVTABLE^MIOUITMX",.META)
 S ^MIO("ROUTE","RAW","GET","/mioui/advanced-table")="ADVTABLE^MIOUITMX"
 S ^MIO("ROUTE","META","GET","/mioui/advanced-table","authRequired")=0
 S ^MIO("ROUTE","META","GET","/mioui/advanced-table","roles")=""
 Q
 ;
ADVTABLE(DEV,CONF,REQ,CTX)
 N TCTX,OUT,ERR
 D BUILD(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/mioui_advanced_table.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 I $D(ERR) D RESPERR^MIOUIDEMO(.DEV,.CONF,.CTX,500,"template_error") Q
 D RESPHTML^MIOUIDEMO(.DEV,.CONF,.CTX,.OUT)
 Q
 ;
BUILD(CONF,REQ,CTX,TCTX)
 D BASE^MIOUICTX(.TCTX)
 D APPLY^MIOUITHEME(.CONF,.TCTX)
 D ACT^MIOUICTX(.TCTX,"tables")
 D PAGE^MIOUICTX(.TCTX,"MIOUI / Advanced table mechanics","Advanced table mechanics","Reusable advanced mechanics for very large server-owned tables: multi-sort, window jumps, resize cues, grouped rows, subtotal bands, and right-frozen summaries.","Advanced table mechanics")
 S TCTX("advTitle")="Advanced table mechanics"
 S TCTX("advLead")="Use these surfaces when the data table is too large and too important to push sort, paging, grouping, and aggregation logic into the browser."
 ; multi-sort
 S TCTX("sortTitle")="Multi-sort stack"
 S TCTX("sortLead")="The server owns the ordered sort stack so million-row audit and billing queues stay deterministic and re-open correctly."
 D SORT(.TCTX,1,"Charge","desc",1,"/mioui/advanced-table?sort=charge&dir=desc")
 D SORT(.TCTX,2,"Date of service","asc",2,"/mioui/advanced-table?sort=dos&dir=asc")
 D SORT(.TCTX,3,"Payer","asc",3,"/mioui/advanced-table?sort=payer&dir=asc")
 D SORT(.TCTX,4,"Claim ID","asc",4,"/mioui/advanced-table?sort=claim&dir=asc")
 ; virtual window navigator
 S TCTX("windowTitle")="Virtual window navigator"
 S TCTX("windowLead")="Large queues should jump between server-owned windows instead of pretending all rows are local."
 S TCTX("windowLabel")="Rows 125001-125250 of 1000000"
 S TCTX("windowPage")="Window 501 of 4000"
 D JUMP(.TCTX,1,"Jump -500 windows","/mioui/advanced-table?window=1")
 D JUMP(.TCTX,2,"Jump -50 windows","/mioui/advanced-table?window=451")
 D JUMP(.TCTX,3,"Previous window","/mioui/advanced-table?window=500")
 D JUMP(.TCTX,4,"Next window","/mioui/advanced-table?window=502")
 D JUMP(.TCTX,5,"Jump +50 windows","/mioui/advanced-table?window=551")
 D JUMP(.TCTX,6,"Last window","/mioui/advanced-table?window=4000")
 ; resize cues
 S TCTX("resizeTitle")="Column resize ruler"
 S TCTX("resizeLead")="Resize handles are cues only here. The server persists the chosen widths as part of the active saved view."
 D RESIZE(.TCTX,1,"Claim / patient","18rem","12rem","28rem")
 D RESIZE(.TCTX,2,"Date of service","10rem","8rem","14rem")
 D RESIZE(.TCTX,3,"Procedure","8rem","6rem","12rem")
 D RESIZE(.TCTX,4,"Charge","8rem","7rem","12rem")
 D RESIZE(.TCTX,5,"Allowed","8rem","7rem","12rem")
 D RESIZE(.TCTX,6,"Status","10rem","8rem","14rem")
 ; grouped rows
 S TCTX("groupTitle")="Grouped rows"
 S TCTX("groupLead")="Grouping lets operators reconcile large queues by payer, owner, or status without losing dense row scanning."
 D GROUP(.TCTX,1,"ALPHA HEALTH","128 rows","15,882.44")
 D GROW(.TCTX,1,1,"CLM-501001","99213","West pod","125.00")
 D GROW(.TCTX,1,2,"CLM-501002","93000","West pod","88.00")
 D GROW(.TCTX,1,3,"CLM-501003","99214","West pod","167.00")
 D GROUP(.TCTX,2,"MEDICARE","74 rows","9,412.18")
 D GROW(.TCTX,2,1,"CLM-501101","G0439","Audit lane","210.00")
 D GROW(.TCTX,2,2,"CLM-501102","99213","Audit lane","102.14")
 ; subtotals
 S TCTX("subtotalTitle")="Subtotal bands"
 S TCTX("subtotalLead")="Subtotal rows should stay visually distinct from claim rows so operators can scan group boundaries quickly."
 D SUB(.TCTX,1,"ALPHA HEALTH subtotal","128 rows","15,882.44","14,104.33")
 D SUB(.TCTX,2,"MEDICARE subtotal","74 rows","9,412.18","8,991.20")
 ; right frozen summary
 S TCTX("summaryTitle")="Right-frozen summary"
 S TCTX("summaryLead")="Sticky summary columns keep status and money visible even when the operator scrolls across a twenty-column table."
 D SUM(.TCTX,1,"Review status","Needs review")
 D SUM(.TCTX,2,"Charge total","25,294.62")
 D SUM(.TCTX,3,"Allowed total","23,095.53")
 D SUM(.TCTX,4,"Selected rows","42")
 D SUM(.TCTX,5,"Grouped by","Payer")
 D SUM(.TCTX,6,"Callback","resizeColumnWidth")
 Q
 ;
SORT(TCTX,IDX,LABEL,DIR,PRI,HREF)
 S TCTX("mxSort",+$G(IDX),"label")=$G(LABEL)
 S TCTX("mxSort",+$G(IDX),"dir")=$G(DIR)
 S TCTX("mxSort",+$G(IDX),"priority")=+$G(PRI)
 S TCTX("mxSort",+$G(IDX),"href")=$G(HREF)
 Q
 ;
JUMP(TCTX,IDX,LABEL,HREF)
 S TCTX("mxJump",+$G(IDX),"label")=$G(LABEL)
 S TCTX("mxJump",+$G(IDX),"href")=$G(HREF)
 Q
 ;
RESIZE(TCTX,IDX,LABEL,WIDTH,MINW,MAXW)
 S TCTX("mxResize",+$G(IDX),"label")=$G(LABEL)
 S TCTX("mxResize",+$G(IDX),"width")=$G(WIDTH)
 S TCTX("mxResize",+$G(IDX),"min")=$G(MINW)
 S TCTX("mxResize",+$G(IDX),"max")=$G(MAXW)
 Q
 ;
GROUP(TCTX,IDX,LABEL,COUNT,TOTAL)
 S TCTX("mxGroup",+$G(IDX),"label")=$G(LABEL)
 S TCTX("mxGroup",+$G(IDX),"count")=$G(COUNT)
 S TCTX("mxGroup",+$G(IDX),"total")=$G(TOTAL)
 Q
 ;
GROW(TCTX,GIDX,RIDX,CLAIM,CODE,OWNER,CHARGE)
 S TCTX("mxGroup",+$G(GIDX),"row",+$G(RIDX),"claim")=$G(CLAIM)
 S TCTX("mxGroup",+$G(GIDX),"row",+$G(RIDX),"code")=$G(CODE)
 S TCTX("mxGroup",+$G(GIDX),"row",+$G(RIDX),"owner")=$G(OWNER)
 S TCTX("mxGroup",+$G(GIDX),"row",+$G(RIDX),"charge")=$G(CHARGE)
 Q
 ;
SUB(TCTX,IDX,LABEL,COUNT,CHARGE,ALLOWED)
 S TCTX("mxSubtotal",+$G(IDX),"label")=$G(LABEL)
 S TCTX("mxSubtotal",+$G(IDX),"count")=$G(COUNT)
 S TCTX("mxSubtotal",+$G(IDX),"charge")=$G(CHARGE)
 S TCTX("mxSubtotal",+$G(IDX),"allowed")=$G(ALLOWED)
 Q
 ;
SUM(TCTX,IDX,LABEL,VALUE)
 S TCTX("mxSummary",+$G(IDX),"label")=$G(LABEL)
 S TCTX("mxSummary",+$G(IDX),"value")=$G(VALUE)
 Q
 ;
