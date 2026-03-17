MIOUIDTGD ; detailed data-grid demo page and route
 Q
 ;
REG(CONF)
 N META
 K META S META("authRequired")=0,META("roles")=""
 D ADDM^MIOROUTE("GET","/mioui/datagrid","DATAGRID^MIOUIDTGD",.META)
 S ^MIO("ROUTE","RAW","GET","/mioui/datagrid")="DATAGRID^MIOUIDTGD"
 S ^MIO("ROUTE","META","GET","/mioui/datagrid","authRequired")=0
 S ^MIO("ROUTE","META","GET","/mioui/datagrid","roles")=""
 Q
 ;
DATAGRID(DEV,CONF,REQ,CTX)
 N TCTX,OUT,ERR
 D BUILD(.CONF,.REQ,.CTX,.TCTX)
 D RENDERPAGE^MIOTPL("pages/mioui_datagrid.html","layouts/mioui_app.html",.CONF,.TCTX,.OUT,.ERR)
 I $D(ERR) D RESPERR^MIOHTTP(.DEV,.CONF,.CTX,500,"template_error") Q
 D RESPHTML^MIOHTTP(.DEV,.CONF,.CTX,.OUT)
 Q
 ;
BUILD(CONF,REQ,CTX,TCTX)
 D BASE^MIOUICTX(.TCTX)
 D APPLY^MIOUITHEME(.CONF,.TCTX)
 D PAGE^MIOUICTX(.TCTX,"MIOUI / Detailed Data Grid","Detailed data grid","A first-pass high-density SSR grid for billing review, operator queues, and controlled export workflows.","Detailed table")
 ; standalone header contract
 S TCTX("pageHeader","eyebrow")="Detailed table"
 S TCTX("pageHeader","title")="Detailed claims grid"
 S TCTX("pageHeader","lead")="Combined operator surface with insights, selection summary, dense rows, row metadata, and action cells."
 S TCTX("pageHeader","meta",1,"label")="Density"
 S TCTX("pageHeader","meta",1,"value")="Dense"
 S TCTX("pageHeader","meta",1,"badgeClass")="badge-slate"
 S TCTX("pageHeader","meta",2,"label")="Sort"
 S TCTX("pageHeader","meta",2,"value")="Charge desc"
 S TCTX("pageHeader","meta",2,"badgeClass")="badge-sky"
 S TCTX("pageHeader","action",1,"label")="Open operators"
 S TCTX("pageHeader","action",1,"href")="/mioui/operators"
 S TCTX("pageHeader","action",1,"class")="quick-button"
 S TCTX("pageHeader","action",1,"isLink")=1
 S TCTX("pageHeader","action",2,"label")="Open billing preview"
 S TCTX("pageHeader","action",2,"href")="/mioui/billing"
 S TCTX("pageHeader","action",2,"class")="primary-button"
 S TCTX("pageHeader","action",2,"isLink")=1
 ; data-grid contract
 D INIT^MIOUIDTG(.TCTX,"main","Detailed claims grid","Operator-grade row density with server-owned state and compact review metadata.","No claims matched this view.")
 D INSIGHT^MIOUIDTG(.TCTX,"main",1,"Rendered rows",4,"sky")
 D INSIGHT^MIOUIDTG(.TCTX,"main",2,"Visible columns",5,"emerald")
 D INSIGHT^MIOUIDTG(.TCTX,"main",3,"Selected rows",2,"amber")
 D INSIGHT^MIOUIDTG(.TCTX,"main",4,"Warnings",1,"rose")
 D PREF^MIOUIDTG(.TCTX,"main",1,"Saved view","Pinned operator view")
 D PREF^MIOUIDTG(.TCTX,"main",2,"Sort","Charge desc")
 D PREF^MIOUIDTG(.TCTX,"main",3,"Ownership","Server-owned filters")
 D SUMMARY^MIOUIDTG(.TCTX,"main",2,"Use the summary bar for explicit bulk review actions without hiding row-level detail.")
 D SUMACT^MIOUIDTG(.TCTX,"main",1,"Publish selected","/mioui/billing","primary-button")
 D SUMACT^MIOUIDTG(.TCTX,"main",2,"Create batch","/mioui/operators","quick-button")
 D COL^MIOUIDTG(.TCTX,"main",1,"Claim / patient","left","18rem","",0)
 D COL^MIOUIDTG(.TCTX,"main",2,"Date of service","left","10rem","",0)
 D COL^MIOUIDTG(.TCTX,"main",3,"Code","left","8rem","",0)
 D COL^MIOUIDTG(.TCTX,"main",4,"Charge","right","8rem","desc",1)
 D COL^MIOUIDTG(.TCTX,"main",5,"Status","left","10rem","",0)
 ; rows
 D ROW^MIOUIDTG(.TCTX,"main",1,"CLM-3001","MARTIN, ELAINE","837P professional",1,"/mioui/billing#clm3001")
 D CELL^MIOUIDTG(.TCTX,"main",1,2,"2026-03-01",0)
 D CELL^MIOUIDTG(.TCTX,"main",1,3,"99213",1)
 D CELL^MIOUIDTG(.TCTX,"main",1,4,"125.00",1)
 D CELL^MIOUIDTG(.TCTX,"main",1,5,"Previewed",0)
 D ROWBADGE^MIOUIDTG(.TCTX,"main",1,"Previewed","sky")
 D ROWACT^MIOUIDTG(.TCTX,"main",1,1,"Open","/mioui/billing#clm3001","quick-button")
 D ROWACT^MIOUIDTG(.TCTX,"main",1,2,"Trace","/mioui/trace#clm3001","ghost-button")
 D ROW^MIOUIDTG(.TCTX,"main",2,"CLM-3002","HALL, JEROME","837P professional",0,"/mioui/billing#clm3002")
 D CELL^MIOUIDTG(.TCTX,"main",2,2,"2026-03-02",0)
 D CELL^MIOUIDTG(.TCTX,"main",2,3,"99214",1)
 D CELL^MIOUIDTG(.TCTX,"main",2,4,"220.55",1)
 D CELL^MIOUIDTG(.TCTX,"main",2,5,"Published",0)
 D ROWBADGE^MIOUIDTG(.TCTX,"main",2,"Published","emerald")
 D ROWACT^MIOUIDTG(.TCTX,"main",2,1,"Open","/mioui/billing#clm3002","quick-button")
 D ROW^MIOUIDTG(.TCTX,"main",3,"CLM-3003","RAO, NISHA","837P professional",0,"/mioui/billing#clm3003")
 D CELL^MIOUIDTG(.TCTX,"main",3,2,"2026-03-03",0)
 D CELL^MIOUIDTG(.TCTX,"main",3,3,"93000",1)
 D CELL^MIOUIDTG(.TCTX,"main",3,4,"89.10",1)
 D CELL^MIOUIDTG(.TCTX,"main",3,5,"Queued",0)
 D ROWBADGE^MIOUIDTG(.TCTX,"main",3,"Queued","slate")
 D ROWACT^MIOUIDTG(.TCTX,"main",3,1,"Open","/mioui/billing#clm3003","quick-button")
 D ROW^MIOUIDTG(.TCTX,"main",4,"CLM-3004","SANCHEZ, MARCO","837P professional",1,"/mioui/billing#clm3004")
 D CELL^MIOUIDTG(.TCTX,"main",4,2,"2026-03-04",0)
 D CELL^MIOUIDTG(.TCTX,"main",4,3,"97110",1)
 D CELL^MIOUIDTG(.TCTX,"main",4,4,"310.00",1)
 D CELL^MIOUIDTG(.TCTX,"main",4,5,"Needs review",0)
 D ROWBADGE^MIOUIDTG(.TCTX,"main",4,"Needs review","amber")
 D ROWACT^MIOUIDTG(.TCTX,"main",4,1,"Open","/mioui/billing#clm3004","quick-button")
 D ROWACT^MIOUIDTG(.TCTX,"main",4,2,"Fix export","/mioui/export","ghost-button")
 D FINAL^MIOUIDTG(.TCTX,"main")
 Q
 ;
