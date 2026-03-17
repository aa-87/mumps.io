MIOUIDEMO ; MIOUI demo routes and page builders
	Q
	;
REG(CONF)
	N META
	K META S META("authRequired")=0,META("roles")=""
	D REG1("GET","/mioui","HOME^MIOUIDEMO",.META)
	D REG1("GET","/mioui/components","COMP^MIOUIDEMO",.META)
	D REG1("GET","/mioui/tables","TABLES^MIOUIDEMO",.META)
	D REG1("GET","/mioui/forms","FORMS^MIOUIDEMO",.META)
	D REG1("GET","/mioui/export","EXPORT^MIOUIDEMO",.META)
	D REG1("GET","/mioui/billing","BILLING^MIOUIDEMO",.META)
	D REG1("GET","/mioui/workflows","WORKFLOWS^MIOUIDEMO",.META)
	D REG1("GET","/mioui/operators","OPERATORS^MIOUIDEMO",.META)
	D REG1("GET","/mioui/trace","TRACE^MIOUIDEMO",.META)
	D REG1("GET","/mioui/premium","PREMIUM^MIOUIDEMO",.META)
	D REG1("GET","/mioui/large-table","LARGETABLE^MIOUIDEMO",.META)
	D REG1("GET","/mioui/million-table","MILLIONTABLE^MIOUIDEMO",.META)
	D REG1("GET","/mioui/code-menus","CODEMENUS^MIOUIDEMO",.META)
	D REG1("GET","/mioui/charts","CHARTS^MIOUIDEMO",.META)
	Q
	;
REG1(METHOD,PATH,TARGET,META)
	D ADDM^MIOROUTE($G(METHOD),$G(PATH),$G(TARGET),.META)
	S ^MIO("ROUTE","RAW",$G(METHOD),$G(PATH))=$G(TARGET)
	S ^MIO("ROUTE","META",$G(METHOD),$G(PATH),"authRequired")=+$G(META("authRequired"))
	S ^MIO("ROUTE","META",$G(METHOD),$G(PATH),"roles")=$G(META("roles"))
	Q
	;
HOME(DEV,CONF,REQ,CTX)
	N TCTX,OUT,ERR
	D BUILDHOME(.CONF,.REQ,.CTX,.TCTX)
	D RENDER("pages/mioui_home.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) D RESPERR(.DEV,.CONF,.CTX,500,"template_error") Q
	D RESPHTML(.DEV,.CONF,.CTX,.OUT)
	Q
	;
COMP(DEV,CONF,REQ,CTX)
	N TCTX,OUT,ERR
	D BUILDCOMP(.CONF,.REQ,.CTX,.TCTX)
	D RENDER("pages/mioui_components.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) D RESPERR(.DEV,.CONF,.CTX,500,"template_error") Q
	D RESPHTML(.DEV,.CONF,.CTX,.OUT)
	Q
	;
TABLES(DEV,CONF,REQ,CTX)
	N TCTX,OUT,ERR
	D BUILDTABLES(.CONF,.REQ,.CTX,.TCTX)
	D RENDER("pages/mioui_tables.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) D RESPERR(.DEV,.CONF,.CTX,500,"template_error") Q
	D RESPHTML(.DEV,.CONF,.CTX,.OUT)
	Q
	;
FORMS(DEV,CONF,REQ,CTX)
	N TCTX,OUT,ERR
	D BUILDFORMS(.CONF,.REQ,.CTX,.TCTX)
	D RENDER("pages/mioui_forms.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) D RESPERR(.DEV,.CONF,.CTX,500,"template_error") Q
	D RESPHTML(.DEV,.CONF,.CTX,.OUT)
	Q
	;
EXPORT(DEV,CONF,REQ,CTX)
	N TCTX,OUT,ERR
	D BUILDEXPORT(.CONF,.REQ,.CTX,.TCTX)
	D RENDER("pages/mioui_export.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) D RESPERR(.DEV,.CONF,.CTX,500,"template_error") Q
	D RESPHTML(.DEV,.CONF,.CTX,.OUT)
	Q
	;
BILLING(DEV,CONF,REQ,CTX)
	N TCTX,OUT,ERR
	D BUILDBILL(.CONF,.REQ,.CTX,.TCTX)
	D RENDER("pages/mioui_billing.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) D RESPERR(.DEV,.CONF,.CTX,500,"template_error") Q
	D RESPHTML(.DEV,.CONF,.CTX,.OUT)
	Q
	;
WORKFLOWS(DEV,CONF,REQ,CTX)
	N TCTX,OUT,ERR
	D BUILDWORK(.CONF,.REQ,.CTX,.TCTX)
	D RENDER("pages/mioui_workflows.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) D RESPERR(.DEV,.CONF,.CTX,500,"template_error") Q
	D RESPHTML(.DEV,.CONF,.CTX,.OUT)
	Q
	;
OPERATORS(DEV,CONF,REQ,CTX)
	N TCTX,OUT,ERR
	D BUILDOPS(.CONF,.REQ,.CTX,.TCTX)
	D RENDER("pages/mioui_operators.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) D RESPERR(.DEV,.CONF,.CTX,500,"template_error") Q
	D RESPHTML(.DEV,.CONF,.CTX,.OUT)
	Q
	;
TRACE(DEV,CONF,REQ,CTX)
	N TCTX,OUT,ERR
	D BUILDTRACE(.CONF,.REQ,.CTX,.TCTX)
	D RENDER("pages/mioui_trace.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) D RESPERR(.DEV,.CONF,.CTX,500,"template_error") Q
	D RESPHTML(.DEV,.CONF,.CTX,.OUT)
	Q
	;
PREMIUM(DEV,CONF,REQ,CTX)
	N TCTX,OUT,ERR
	D BUILDPREMIUM(.CONF,.REQ,.CTX,.TCTX)
	D RENDER("pages/mioui_premium.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) D RESPERR(.DEV,.CONF,.CTX,500,"template_error") Q
	D RESPHTML(.DEV,.CONF,.CTX,.OUT)
	Q
	;
LARGETABLE(DEV,CONF,REQ,CTX)
	N TCTX,OUT,ERR
	D BUILDLARGE(.CONF,.REQ,.CTX,.TCTX)
	D RENDER("pages/mioui_large_table.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) D RESPERR(.DEV,.CONF,.CTX,500,"template_error") Q
	D RESPHTML(.DEV,.CONF,.CTX,.OUT)
	Q
	;
MILLIONTABLE(DEV,CONF,REQ,CTX)
	N TCTX,OUT,ERR
	D BUILDMILLION(.CONF,.REQ,.CTX,.TCTX)
	D RENDER("pages/mioui_million_table.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) M ^ERR=ERR D RESPERR(.DEV,.CONF,.CTX,500,"template_error") Q
	D RESPHTML(.DEV,.CONF,.CTX,.OUT)
	Q
	;
CODEMENUS(DEV,CONF,REQ,CTX)
	N TCTX,OUT,ERR
	D BUILDCODE(.CONF,.REQ,.CTX,.TCTX)
	D RENDER("pages/mioui_code_menus.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) D RESPERR(.DEV,.CONF,.CTX,500,"template_error") Q
	D RESPHTML(.DEV,.CONF,.CTX,.OUT)
	Q
	;
CHARTS(DEV,CONF,REQ,CTX)
	N TCTX,OUT,ERR
	D BUILDCHARTS(.CONF,.REQ,.CTX,.TCTX)
	D RENDER("pages/mioui_chart_variants.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) D RESPERR(.DEV,.CONF,.CTX,500,"template_error") Q
	D RESPHTML(.DEV,.CONF,.CTX,.OUT)
	Q
	;
RENDER(PAGE,CONF,CTX,TCTX,OUT,ERR)
	D INIT^MIOUI(.CONF)
	D RENDERPAGE^MIOTPL($G(PAGE),"layouts/mioui_app.html",.CONF,.TCTX,.OUT,.ERR)
	Q
	;
BUILDHOME(CONF,REQ,CTX,TCTX)
	D BASE^MIOUICTX(.TCTX)
	D APPLY^MIOUITHEME(.CONF,.TCTX)
	D ACT^MIOUICTX(.TCTX,"home")
	D PAGE^MIOUICTX(.TCTX,"MIOUI / Home","MIOUI","Tailwind-based SSR UI package for dense billing and workflow applications.","Package overview")
	D STAT^MIOUIPANEL(.TCTX,1,"Foundation components",30,"sky","/mioui/components")
	D STAT^MIOUIPANEL(.TCTX,2,"Table patterns",19,"emerald","/mioui/tables")
	D STAT^MIOUIPANEL(.TCTX,3,"Form patterns",16,"amber","/mioui/forms")
	D STAT^MIOUIPANEL(.TCTX,4,"Export UX",4,"sky","/mioui/export")
	D STAT^MIOUIPANEL(.TCTX,5,"Billing blueprints",6,"violet","/mioui/billing")
	D STAT^MIOUIPANEL(.TCTX,6,"Operator ergonomics",6,"amber","/mioui/operators")
	S TCTX("catalog",1,"name")="Shell and navigation"
	S TCTX("catalog",1,"desc")="Sidebar, header, breadcrumbs, subnav, footer, and utility rails for SSR apps."
	S TCTX("catalog",2,"name")="Dense data surfaces"
	S TCTX("catalog",2,"desc")="High-scan tables, stat strips, activity feeds, diagnostics, and audit views."
	S TCTX("catalog",3,"name")="Form system"
	S TCTX("catalog",3,"desc")="Text, select, textarea, checkbox, toggle, section, checkbox groups, and sticky action footer patterns."
	S TCTX("catalog",4,"name")="Export UX"
	S TCTX("catalog",4,"desc")="Field catalog, selected-field order editor, naming rules, and reusable export profile summary cards."
	S TCTX("catalog",5,"name")="Billing adapters"
	S TCTX("catalog",5,"desc")="Claim summary, service line table, diagnostics bucket, artifact manifest, and publish-plan cards."
	D STEP^MIOUICTX(.TCTX,1,"Seed a base shell","Start with BASE^MIOUICTX and APPLY^MIOUITHEME so every page gets the same shell contract.","complete")
	D STEP^MIOUICTX(.TCTX,2,"Shape page data on the server","Use MIOUITBL, MIOUIFORM, and MIOUIPANEL to normalize SSR view-models before render.","complete")
	D STEP^MIOUICTX(.TCTX,3,"Render with MIOTPL","Keep pages thin and partial-driven so dense screens stay predictable and testable.","current")
	D TIMELINE^MIOUICTX(.TCTX,1,"Now","P1 primitives completed","Badges, buttons, empty states, alerts, tabs, steppers, table tools, and field help/error are now reusable partials.","sky")
	D TIMELINE^MIOUICTX(.TCTX,2,"Now","Profile editor and export UX","Checkbox groups, selected-field order editor, sticky footer, and export profile summary are now reusable export surfaces.","violet")
	D TIMELINE^MIOUICTX(.TCTX,3,"Now","Workflow polish","Onboarding modal, confirm dialog, file dropzone, and improved stepper contracts are now reusable workflow surfaces.","emerald")
	D TIMELINE^MIOUICTX(.TCTX,4,"Now","Dense operator ergonomics","Saved views, column chooser, split detail panels, activity feeds, page headers, and shell sub-navigation are now reusable surfaces.","amber")
	D TIMELINE^MIOUICTX(.TCTX,5,"Now","Trace and audit depth","Timelines, trace summary surfaces, grouped evidence, and deeper audit review tables are now reusable.","violet")
	D TIMELINE^MIOUICTX(.TCTX,6,"Now","Very large table system","Large-table pagination, filters, sort ownership, density, pinned column, row expansion, and page totals are now reusable.","amber")
	D TIMELINE^MIOUICTX(.TCTX,7,"Next ROI","Advanced table review depth","Focus shifts to multi-sort, virtual windows, grouping, and export-current-view patterns.","violet")
	Q
	;
BUILDCOMP(CONF,REQ,CTX,TCTX)
	D BASE^MIOUICTX(.TCTX)
	D APPLY^MIOUITHEME(.CONF,.TCTX)
	D ACT^MIOUICTX(.TCTX,"components")
	D PAGE^MIOUICTX(.TCTX,"MIOUI / Components","Component catalog","Panels, badges, alerts, tabs, steppers, and empty states built for SSR reuse.","Component gallery")
	; badge demos
	S TCTX("badgeDemo",1,"badgeClass")="badge-slate",TCTX("badgeDemo",1,"label")="Queued"
	S TCTX("badgeDemo",2,"badgeClass")="badge-sky",TCTX("badgeDemo",2,"label")="Previewed"
	S TCTX("badgeDemo",3,"badgeClass")="badge-emerald",TCTX("badgeDemo",3,"label")="Published"
	S TCTX("badgeDemo",4,"badgeClass")="badge-amber",TCTX("badgeDemo",4,"label")="Needs review"
	S TCTX("badgeDemo",5,"badgeClass")="badge-rose",TCTX("badgeDemo",5,"label")="Blocked"
	; button demos
	S TCTX("buttonDemo",1,"label")="Primary action",TCTX("buttonDemo",1,"href")="/mioui/forms",TCTX("buttonDemo",1,"class")="primary-button",TCTX("buttonDemo",1,"isLink")=1
	S TCTX("buttonDemo",2,"label")="Secondary action",TCTX("buttonDemo",2,"href")="/mioui/components#feedback",TCTX("buttonDemo",2,"class")="quick-button",TCTX("buttonDemo",2,"isLink")=1
	S TCTX("buttonDemo",3,"label")="Ghost action",TCTX("buttonDemo",3,"href")="/mioui/components#workflow",TCTX("buttonDemo",3,"class")="ghost-button",TCTX("buttonDemo",3,"isLink")=1
	S TCTX("buttonDemo",4,"label")="Danger action",TCTX("buttonDemo",4,"type")="button",TCTX("buttonDemo",4,"class")="danger-button"
	D ALERT^MIOUICTX(.TCTX,1,"sky","Info","Use semantic tones for system state, not arbitrary colors.")
	D ALERT^MIOUICTX(.TCTX,2,"amber","Warning","Reserve warning panels for operator attention, not every secondary message.")
	D ALERT^MIOUICTX(.TCTX,3,"rose","Error","Error surfaces should explain what failed and what action is possible next.")
	D TAB^MIOUICTX(.TCTX,1,"Foundation","/mioui/components",1)
	S TCTX("tabs",1,"count")=6
	D TAB^MIOUICTX(.TCTX,2,"Workflow","/mioui/components#workflow",0)
	S TCTX("tabs",2,"count")=3
	D TAB^MIOUICTX(.TCTX,3,"Feedback","/mioui/components#feedback",0)
	S TCTX("tabs",3,"count")=4
	D STEP^MIOUICTX(.TCTX,1,"Queued","File staged but not yet published.","complete")
	D STEP^MIOUICTX(.TCTX,2,"Preview","Claims, lines, diagnostics, and trace visible.","current")
	D STEP^MIOUICTX(.TCTX,3,"Publish","Artifacts locked and available for audit download.","queued")
	D STEPNOTE^MIOUIWF(.TCTX,1,"Staging stays local until the operator confirms publish.","Review staging","/mioui/workflows")
	D STEPNOTE^MIOUIWF(.TCTX,2,"Preview should highlight warnings without hiding core claim facts.","Open billing preview","/mioui/billing")
	D STEPNOTE^MIOUIWF(.TCTX,3,"Publish should stay explicit and auditable for billing operators.","Open confirm surface","/mioui/workflows#publish")
	D STEPFINAL^MIOUIWF(.TCTX)
	D EMPTY^MIOUIPANEL(.TCTX,"emptyState","No jobs matched this filter","Try widening the date range or clearing status chips.","Clear filters","/mioui/tables")
	D KV^MIOUIPANEL(.TCTX,"detail",1,"Package","MIOUI")
	D KV^MIOUIPANEL(.TCTX,"detail",2,"Render engine","MIOTPL")
	D KV^MIOUIPANEL(.TCTX,"detail",3,"Density","Dense by default")
	D KV^MIOUIPANEL(.TCTX,"detail",4,"Primary audience","Billing and workflow operators")
	D TIMELINE^MIOUICTX(.TCTX,1,"08:10","Template context built","Server normalizes shell, page, and component contracts before render.","sky")
	D TIMELINE^MIOUICTX(.TCTX,2,"08:12","Page rendered","Layout and partials produce stable HTML with small client helpers only.","emerald")
	Q
	;
BUILDTABLES(CONF,REQ,CTX,TCTX)
	D BASE^MIOUICTX(.TCTX)
	D APPLY^MIOUITHEME(.CONF,.TCTX)
	D ACT^MIOUICTX(.TCTX,"tables")
	D PAGE^MIOUICTX(.TCTX,"MIOUI / Tables","Dense tables","Server-shaped tables for operational review, audit, export, and billing screens.","Table patterns")
	D INIT^MIOUITBL(.TCTX,"claims","Claims review","No claims matched the current query.")
	D TOOLBAR^MIOUITBL(.TCTX,"claims","Table tools","High-density list surface with search, actions, and server pagination.","jane doe","Search claims, patients, and payers")
	D TOOLACT^MIOUITBL(.TCTX,"claims",1,"Export CSV","/mioui/tables?export=claims","quick-button")
	D TOOLACT^MIOUITBL(.TCTX,"claims",2,"Save view","/mioui/tables?view=save","primary-button")
	D FILTERMETA^MIOUITBL(.TCTX,"claims","Filter set","Shape status chips, date windows, and search values on the server so pages stay predictable.")
	D FILTER^MIOUITBL(.TCTX,"claims",1,"Queued","queued",0)
	D FILTER^MIOUITBL(.TCTX,"claims",2,"Previewed","previewed",1)
	D FILTER^MIOUITBL(.TCTX,"claims",3,"Published","published",0)
	D BULK^MIOUITBL(.TCTX,"claims","selected",2)
	D BULKACT^MIOUITBL(.TCTX,"claims",1,"Publish selected","/mioui/billing","primary-button")
	D BULKACT^MIOUITBL(.TCTX,"claims",2,"Clear selection","/mioui/tables","quick-button")
	D COL^MIOUITBL(.TCTX,"claims",1,"Claim","left")
	D COL^MIOUITBL(.TCTX,"claims",2,"Patient","left")
	D COL^MIOUITBL(.TCTX,"claims",3,"DOS","left")
	D COL^MIOUITBL(.TCTX,"claims",4,"Charge","right")
	D COL^MIOUITBL(.TCTX,"claims",5,"Status","left")
	D CELL^MIOUITBL(.TCTX,"claims",1,1,"CLM-1001")
	D CELL^MIOUITBL(.TCTX,"claims",1,2,"JANE DOE")
	D CELL^MIOUITBL(.TCTX,"claims",1,3,"2026-03-01")
	D CELL^MIOUITBL(.TCTX,"claims",1,4,"125.00")
	D CELL^MIOUITBL(.TCTX,"claims",1,5,"Previewed")
	D ROWHREF^MIOUITBL(.TCTX,"claims",1,"/mioui/billing#claim-preview")
	D ROWBADGE^MIOUITBL(.TCTX,"claims",1,"Previewed","sky")
	D CELL^MIOUITBL(.TCTX,"claims",2,1,"CLM-1002")
	D CELL^MIOUITBL(.TCTX,"claims",2,2,"JOHN SMITH")
	D CELL^MIOUITBL(.TCTX,"claims",2,3,"2026-03-02")
	D CELL^MIOUITBL(.TCTX,"claims",2,4,"88.20")
	D CELL^MIOUITBL(.TCTX,"claims",2,5,"Published")
	D ROWBADGE^MIOUITBL(.TCTX,"claims",2,"Published","emerald")
	D FINAL^MIOUITBL(.TCTX,"claims")
	D PAGER^MIOUITBL(.TCTX,"claims",1,25,89,"","/mioui/tables?page=2")
	D INIT^MIOUITBL(.TCTX,"audit","Audit log","No audit activity.")
	D COL^MIOUITBL(.TCTX,"audit",1,"When","left")
	D COL^MIOUITBL(.TCTX,"audit",2,"Actor","left")
	D COL^MIOUITBL(.TCTX,"audit",3,"Action","left")
	D COL^MIOUITBL(.TCTX,"audit",4,"Result","left")
	D CELL^MIOUITBL(.TCTX,"audit",1,1,"2026-03-16 08:12")
	D CELL^MIOUITBL(.TCTX,"audit",1,2,"operator.demo")
	D CELL^MIOUITBL(.TCTX,"audit",1,3,"Published job 1048")
	D CELL^MIOUITBL(.TCTX,"audit",1,4,"ok")
	D ROWBADGE^MIOUITBL(.TCTX,"audit",1,"ok","emerald")
	D CELL^MIOUITBL(.TCTX,"audit",2,1,"2026-03-16 08:03")
	D CELL^MIOUITBL(.TCTX,"audit",2,2,"operator.demo")
	D CELL^MIOUITBL(.TCTX,"audit",2,3,"Opened preview")
	D CELL^MIOUITBL(.TCTX,"audit",2,4,"ok")
	D ROWBADGE^MIOUITBL(.TCTX,"audit",2,"ok","sky")
	D FINAL^MIOUITBL(.TCTX,"audit")
	Q
	;
BUILDFORMS(CONF,REQ,CTX,TCTX)
	D BASE^MIOUICTX(.TCTX)
	D APPLY^MIOUITHEME(.CONF,.TCTX)
	D ACT^MIOUICTX(.TCTX,"forms")
	D PAGE^MIOUICTX(.TCTX,"MIOUI / Forms","Form system","High-density SSR forms for filters, profile editors, and workflow setup pages.","Form patterns")
	D INIT^MIOUIFORM(.TCTX,"profile","Export profile","Shape operator-facing CSV output without leaving the SSR flow.","/mioui/forms","post")
	D FIELD^MIOUIFORM(.TCTX,"profile",1,"text","name","Profile name","Claims Review","Friendly name visible to operators.","Short and specific","")
	D FIELD^MIOUIFORM(.TCTX,"profile",2,"select","exportMode","Export mode","claim_summary","","Choose one rendering profile.","")
	D OPTION^MIOUIFORM(.TCTX,"profile",2,1,"claim_summary","Claim summary",1)
	D OPTION^MIOUIFORM(.TCTX,"profile",2,2,"line_detail","Line detail",0)
	D OPTION^MIOUIFORM(.TCTX,"profile",2,3,"custom","Custom",0)
	D FIELD^MIOUIFORM(.TCTX,"profile",3,"textarea","selectedFields","Selected fields","claim_id,total_charge,patient_last","One field key per comma-separated token.","Order matters for export output.","At least one field key is required.")
	D FIELD^MIOUIFORM(.TCTX,"profile",4,"checkbox","includeHeaders","Include header row","1","","Write CSV headers into the first row.","")
	D CHECKED^MIOUIFORM(.TCTX,"profile",4,1)
	D FIELD^MIOUIFORM(.TCTX,"profile",5,"toggle","quoteAll","Quote all columns","0","","Enable when downstream importers are strict.","")
	D ACTION^MIOUIFORM(.TCTX,"profile",1,"Save profile","submit","primary")
	D ACTION^MIOUIFORM(.TCTX,"profile",2,"Reset","reset","secondary")
	D FINAL^MIOUIFORM(.TCTX,"profile")
	D INIT^MIOUIFORM(.TCTX,"filter","Review filters","Compact query bar for list and history pages.","/mioui/tables","get")
	D FIELD^MIOUIFORM(.TCTX,"filter",1,"text","q","Search","subscriber, claim, payer","Type a claim id, payer, or patient.","","")
	D FIELD^MIOUIFORM(.TCTX,"filter",2,"date","fromDate","From date","2026-03-01","","","")
	D FIELD^MIOUIFORM(.TCTX,"filter",3,"date","toDate","To date","2026-03-16","","","")
	D ACTION^MIOUIFORM(.TCTX,"filter",1,"Apply","submit","primary")
	D ACTION^MIOUIFORM(.TCTX,"filter",2,"Clear","reset","secondary")
	D FINAL^MIOUIFORM(.TCTX,"filter")
	Q
	;
BUILDCHARTS(CONF,REQ,CTX,TCTX)
	D BASE^MIOUICTX(.TCTX)
	D APPLY^MIOUITHEME(.CONF,.TCTX)
	D ACT^MIOUICTX(.TCTX,"components")
	D PAGE^MIOUICTX(.TCTX,"MIOUI / Charts","Chart variants","Reusable SSR chart, graph, and KPI surfaces for operator dashboards, billing analytics, and dense review workspaces.","Chart lab")
	S TCTX("pageTitle")="Chart and graph variants"
	S TCTX("pageIntro")="Dense SSR chart surfaces for bars, stacks, lines, area trends, pie and donut summaries, heatmaps, bullets, funnels, waterfall bridges, histograms, box-range summaries, radar score profiles, and sparkline tables. The chart lab stays theme-aware so the same variants remain readable in both dark and light operator shells."
	S TCTX("heroCallback")="openChartVariantStudio"
	S TCTX("chartStat",1,"label")="Chart families" S TCTX("chartStat",1,"value")=13
	S TCTX("chartStat",2,"label")="Tracked measures" S TCTX("chartStat",2,"value")=39
	S TCTX("chartStat",3,"label")="Threshold rules" S TCTX("chartStat",3,"value")=16
	S TCTX("chartStat",4,"label")="Pinned boards" S TCTX("chartStat",4,"value")=10
	S TCTX("chartStat",5,"label")="Drill paths" S TCTX("chartStat",5,"value")=20
	S TCTX("chartStat",6,"label")="Saved variants" S TCTX("chartStat",6,"value")=15
	S TCTX("chartCallback",1,"token")="openChartVariantStudio"
	S TCTX("chartCallback",2,"token")="changeChartDateWindow"
	S TCTX("chartCallback",3,"token")="switchChartGranularity"
	S TCTX("chartCallback",4,"token")="toggleChartSeries"
	S TCTX("chartCallback",5,"token")="filterChartPopulation"
	S TCTX("chartCallback",6,"token")="compareChartSegments"
	S TCTX("chartCallback",7,"token")="saveChartThresholds"
	S TCTX("chartCallback",8,"token")="exportChartSnapshot"
	S TCTX("chartCallback",9,"token")="pinChartToDashboard"
	S TCTX("chartCallback",10,"token")="drillIntoChartPoint"
	S TCTX("chartCallback",11,"token")="annotateChartRunRate"
	S TCTX("chartCallback",12,"token")="cycleChartPalette"
	S TCTX("chartCallback",13,"token")="rebaseVarianceBridge"
	S TCTX("chartCallback",14,"token")="toggleDistributionBands"
	S TCTX("chartCallback",15,"token")="changeBenchmarkOverlay"
	S TCTX("chartCallback",16,"token")="switchRadarProfile"
	S TCTX("bar","title")="Horizontal bar comparisons"
	S TCTX("bar","desc")="Fast scan for queues, denial classes, and payer segments where exact counts matter more than shape alone."
	S TCTX("bar","item",1,"label")="Eligibility" S TCTX("bar","item",1,"pct")=84 S TCTX("bar","item",1,"value")="2,140" S TCTX("bar","item",1,"toneClass")="bg-sky-500"
	S TCTX("bar","item",2,"label")="Authorization" S TCTX("bar","item",2,"pct")=63 S TCTX("bar","item",2,"value")="1,608" S TCTX("bar","item",2,"toneClass")="bg-violet-500"
	S TCTX("bar","item",3,"label")="Medical necessity" S TCTX("bar","item",3,"pct")=47 S TCTX("bar","item",3,"value")="1,202" S TCTX("bar","item",3,"toneClass")="bg-amber-500"
	S TCTX("bar","item",4,"label")="Timely filing" S TCTX("bar","item",4,"pct")=28 S TCTX("bar","item",4,"value")="711" S TCTX("bar","item",4,"toneClass")="bg-rose-500"
	S TCTX("stack","title")="Stacked resolution mix"
	S TCTX("stack","desc")="Single-row comparisons for multi-status outcome mix across pods or payers."
	S TCTX("stack","row",1,"label")="North pod"
	S TCTX("stack","row",1,"segment",1,"pct")=46 S TCTX("stack","row",1,"segment",1,"toneClass")="bg-emerald-500" S TCTX("stack","row",1,"segment",1,"label")="Paid"
	S TCTX("stack","row",1,"segment",2,"pct")=29 S TCTX("stack","row",1,"segment",2,"toneClass")="bg-sky-500" S TCTX("stack","row",1,"segment",2,"label")="Previewed"
	S TCTX("stack","row",1,"segment",3,"pct")=17 S TCTX("stack","row",1,"segment",3,"toneClass")="bg-amber-500" S TCTX("stack","row",1,"segment",3,"label")="Need review"
	S TCTX("stack","row",1,"segment",4,"pct")=8 S TCTX("stack","row",1,"segment",4,"toneClass")="bg-rose-500" S TCTX("stack","row",1,"segment",4,"label")="Blocked"
	S TCTX("stack","row",2,"label")="West pod"
	S TCTX("stack","row",2,"segment",1,"pct")=38 S TCTX("stack","row",2,"segment",1,"toneClass")="bg-emerald-500" S TCTX("stack","row",2,"segment",1,"label")="Paid"
	S TCTX("stack","row",2,"segment",2,"pct")=33 S TCTX("stack","row",2,"segment",2,"toneClass")="bg-sky-500" S TCTX("stack","row",2,"segment",2,"label")="Previewed"
	S TCTX("stack","row",2,"segment",3,"pct")=18 S TCTX("stack","row",2,"segment",3,"toneClass")="bg-amber-500" S TCTX("stack","row",2,"segment",3,"label")="Need review"
	S TCTX("stack","row",2,"segment",4,"pct")=11 S TCTX("stack","row",2,"segment",4,"toneClass")="bg-rose-500" S TCTX("stack","row",2,"segment",4,"label")="Blocked"
	S TCTX("line","title")="Run-rate line trend"
	S TCTX("line","desc")="Seven-point line chart for daily throughput, recoveries, or aging trend movement."
	S TCTX("line","polyline")="10,86 58,74 106,70 154,54 202,49 250,36 298,28"
	S TCTX("line","point",1,"label")="Mon" S TCTX("line","point",1,"value")="182"
	S TCTX("line","point",2,"label")="Tue" S TCTX("line","point",2,"value")="196"
	S TCTX("line","point",3,"label")="Wed" S TCTX("line","point",3,"value")="201"
	S TCTX("line","point",4,"label")="Thu" S TCTX("line","point",4,"value")="228"
	S TCTX("line","point",5,"label")="Fri" S TCTX("line","point",5,"value")="241"
	S TCTX("line","point",6,"label")="Sat" S TCTX("line","point",6,"value")="266"
	S TCTX("line","point",7,"label")="Sun" S TCTX("line","point",7,"value")="279"
	S TCTX("area","title")="Area forecast band"
	S TCTX("area","desc")="Filled trend for projected collections, completion curves, or cumulative release value."
	S TCTX("area","polyline")="10,92 58,80 106,76 154,63 202,58 250,49 298,34"
	S TCTX("area","polygon")="10,110 10,92 58,80 106,76 154,63 202,58 250,49 298,34 298,110"
	S TCTX("area","note")="Forecast stays within threshold until the Friday batch closes."
	S TCTX("pie","title")="Pie and donut summaries"
	S TCTX("pie","desc")="Part-to-whole view for payer share, queue ownership, or denial category composition."
	S TCTX("pie","gradient")="conic-gradient(#38bdf8 0 34%, #14b8a6 34% 58%, #f59e0b 58% 81%, #f43f5e 81% 100%)"
	S TCTX("pie","centerTop")="4.8k"
	S TCTX("pie","centerBottom")="open items"
	S TCTX("pie","slice",1,"label")="Commercial" S TCTX("pie","slice",1,"value")="34%" S TCTX("pie","slice",1,"toneClass")="bg-sky-500"
	S TCTX("pie","slice",2,"label")="Medicare" S TCTX("pie","slice",2,"value")="24%" S TCTX("pie","slice",2,"toneClass")="bg-teal-500"
	S TCTX("pie","slice",3,"label")="Medicaid" S TCTX("pie","slice",3,"value")="23%" S TCTX("pie","slice",3,"toneClass")="bg-amber-500"
	S TCTX("pie","slice",4,"label")="Other" S TCTX("pie","slice",4,"value")="19%" S TCTX("pie","slice",4,"toneClass")="bg-rose-500"
	S TCTX("heat","title")="Heatmap activity grid"
	S TCTX("heat","desc")="Compact intensity matrix for day-of-week productivity or payer-response concentration."
	S TCTX("heat","week",1,"day",1,"toneClass")="bg-slate-700" S TCTX("heat","week",1,"day",1,"count")=8
	S TCTX("heat","week",1,"day",2,"toneClass")="bg-sky-800" S TCTX("heat","week",1,"day",2,"count")=14
	S TCTX("heat","week",1,"day",3,"toneClass")="bg-sky-600" S TCTX("heat","week",1,"day",3,"count")=22
	S TCTX("heat","week",1,"day",4,"toneClass")="bg-emerald-600" S TCTX("heat","week",1,"day",4,"count")=27
	S TCTX("heat","week",1,"day",5,"toneClass")="bg-amber-500" S TCTX("heat","week",1,"day",5,"count")=19
	S TCTX("heat","week",1,"day",6,"toneClass")="bg-slate-700" S TCTX("heat","week",1,"day",6,"count")=5
	S TCTX("heat","week",1,"day",7,"toneClass")="bg-slate-800" S TCTX("heat","week",1,"day",7,"count")=2
	S TCTX("heat","week",2,"day",1,"toneClass")="bg-sky-800" S TCTX("heat","week",2,"day",1,"count")=16
	S TCTX("heat","week",2,"day",2,"toneClass")="bg-sky-600" S TCTX("heat","week",2,"day",2,"count")=23
	S TCTX("heat","week",2,"day",3,"toneClass")="bg-emerald-600" S TCTX("heat","week",2,"day",3,"count")=29
	S TCTX("heat","week",2,"day",4,"toneClass")="bg-emerald-500" S TCTX("heat","week",2,"day",4,"count")=31
	S TCTX("heat","week",2,"day",5,"toneClass")="bg-amber-500" S TCTX("heat","week",2,"day",5,"count")=21
	S TCTX("heat","week",2,"day",6,"toneClass")="bg-slate-700" S TCTX("heat","week",2,"day",6,"count")=9
	S TCTX("heat","week",2,"day",7,"toneClass")="bg-slate-800" S TCTX("heat","week",2,"day",7,"count")=3
	S TCTX("heat","week",3,"day",1,"toneClass")="bg-sky-800" S TCTX("heat","week",3,"day",1,"count")=18
	S TCTX("heat","week",3,"day",2,"toneClass")="bg-sky-600" S TCTX("heat","week",3,"day",2,"count")=26
	S TCTX("heat","week",3,"day",3,"toneClass")="bg-emerald-600" S TCTX("heat","week",3,"day",3,"count")=33
	S TCTX("heat","week",3,"day",4,"toneClass")="bg-emerald-500" S TCTX("heat","week",3,"day",4,"count")=35
	S TCTX("heat","week",3,"day",5,"toneClass")="bg-amber-500" S TCTX("heat","week",3,"day",5,"count")=24
	S TCTX("heat","week",3,"day",6,"toneClass")="bg-slate-700" S TCTX("heat","week",3,"day",6,"count")=12
	S TCTX("heat","week",3,"day",7,"toneClass")="bg-slate-800" S TCTX("heat","week",3,"day",7,"count")=4
	S TCTX("bullet","title")="Bullet and target grid"
	S TCTX("bullet","desc")="Target-vs-actual bars for aging, payments, denial overturn, or productivity goals."
	S TCTX("bullet","item",1,"label")="Collections" S TCTX("bullet","item",1,"actualPct")=74 S TCTX("bullet","item",1,"targetPct")=82 S TCTX("bullet","item",1,"actual")="$184k" S TCTX("bullet","item",1,"target")="$200k"
	S TCTX("bullet","item",2,"label")="First-pass rate" S TCTX("bullet","item",2,"actualPct")=68 S TCTX("bullet","item",2,"targetPct")=76 S TCTX("bullet","item",2,"actual")="92.4%" S TCTX("bullet","item",2,"target")="95.0%"
	S TCTX("bullet","item",3,"label")="Appeal win rate" S TCTX("bullet","item",3,"actualPct")=57 S TCTX("bullet","item",3,"targetPct")=63 S TCTX("bullet","item",3,"actual")="61%" S TCTX("bullet","item",3,"target")="67%"
	S TCTX("funnel","title")="Funnel stage board"
	S TCTX("funnel","desc")="Step-down volume view for intake-to-release workflows and triage pipelines."
	S TCTX("funnel","stage",1,"label")="Loaded" S TCTX("funnel","stage",1,"value")="8,420" S TCTX("funnel","stage",1,"pct")=100 S TCTX("funnel","stage",1,"toneClass")="bg-sky-500/80"
	S TCTX("funnel","stage",2,"label")="Parsed" S TCTX("funnel","stage",2,"value")="7,980" S TCTX("funnel","stage",2,"pct")=88 S TCTX("funnel","stage",2,"toneClass")="bg-sky-500/70"
	S TCTX("funnel","stage",3,"label")="Validated" S TCTX("funnel","stage",3,"value")="6,441" S TCTX("funnel","stage",3,"pct")=72 S TCTX("funnel","stage",3,"toneClass")="bg-violet-500/70"
	S TCTX("funnel","stage",4,"label")="Published" S TCTX("funnel","stage",4,"value")="5,908" S TCTX("funnel","stage",4,"pct")=61 S TCTX("funnel","stage",4,"toneClass")="bg-emerald-500/70"
	S TCTX("waterfall","title")="Waterfall variance bridge"
	S TCTX("waterfall","desc")="Sequential variance view for monthly release value, backlog movement, or payment-plan forecast changes."
	S TCTX("waterfall","step",1,"label")="Expected release" S TCTX("waterfall","step",1,"detail")="Baseline plan" S TCTX("waterfall","step",1,"startPct")=0 S TCTX("waterfall","step",1,"widthPct")=64 S TCTX("waterfall","step",1,"barClass")="chart-waterfall-total" S TCTX("waterfall","step",1,"value")="$1.92M" S TCTX("waterfall","step",1,"valueClass")="chart-value"
	S TCTX("waterfall","step",2,"label")="Mix shift" S TCTX("waterfall","step",2,"detail")="Higher public-payer share" S TCTX("waterfall","step",2,"startPct")=60.3 S TCTX("waterfall","step",2,"widthPct")=3.7 S TCTX("waterfall","step",2,"barClass")="chart-waterfall-negative" S TCTX("waterfall","step",2,"value")="-$110k" S TCTX("waterfall","step",2,"valueClass")="text-rose-500"
	S TCTX("waterfall","step",3,"label")="Coding fixes" S TCTX("waterfall","step",3,"detail")="Recovered under-coded encounters" S TCTX("waterfall","step",3,"startPct")=60.3 S TCTX("waterfall","step",3,"widthPct")=2.8 S TCTX("waterfall","step",3,"barClass")="chart-waterfall-positive" S TCTX("waterfall","step",3,"value")="+$84k" S TCTX("waterfall","step",3,"valueClass")="text-emerald-500"
	S TCTX("waterfall","step",4,"label")="Timely filing" S TCTX("waterfall","step",4,"detail")="Expired submission window" S TCTX("waterfall","step",4,"startPct")=61.7 S TCTX("waterfall","step",4,"widthPct")=1.4 S TCTX("waterfall","step",4,"barClass")="chart-waterfall-negative" S TCTX("waterfall","step",4,"value")="-$42k" S TCTX("waterfall","step",4,"valueClass")="text-rose-500"
	S TCTX("waterfall","step",5,"label")="Appeal overturn" S TCTX("waterfall","step",5,"detail")="Recovered high-value denials" S TCTX("waterfall","step",5,"startPct")=61.7 S TCTX("waterfall","step",5,"widthPct")=4.2 S TCTX("waterfall","step",5,"barClass")="chart-waterfall-positive" S TCTX("waterfall","step",5,"value")="+$126k" S TCTX("waterfall","step",5,"valueClass")="text-emerald-500"
	S TCTX("waterfall","step",6,"label")="Actual release" S TCTX("waterfall","step",6,"detail")="Net posted result" S TCTX("waterfall","step",6,"startPct")=0 S TCTX("waterfall","step",6,"widthPct")=65.9 S TCTX("waterfall","step",6,"barClass")="chart-waterfall-total" S TCTX("waterfall","step",6,"value")="$1.98M" S TCTX("waterfall","step",6,"valueClass")="chart-value"
	S TCTX("waterfall","rule")="Bridge stays anchored to expected release unless the reviewer rebases to actual cash postings."
	S TCTX("waterfall","legendPositive")="Positive bridge"
	S TCTX("waterfall","legendNegative")="Negative bridge"
	S TCTX("waterfall","legendTotal")="Baseline and actual"
	S TCTX("hist","title")="Histogram distribution"
	S TCTX("hist","desc")="Distribution view for claim value, unit counts, or days-in-A/R where spread matters more than ordered sequence."
	S TCTX("hist","yMax")="420 claims"
	S TCTX("hist","bucket",1,"label")="0-7" S TCTX("hist","bucket",1,"pct")=28 S TCTX("hist","bucket",1,"count")=118 S TCTX("hist","bucket",1,"toneClass")="bg-sky-500"
	S TCTX("hist","bucket",2,"label")="8-14" S TCTX("hist","bucket",2,"pct")=56 S TCTX("hist","bucket",2,"count")=235 S TCTX("hist","bucket",2,"toneClass")="bg-sky-400"
	S TCTX("hist","bucket",3,"label")="15-21" S TCTX("hist","bucket",3,"pct")=84 S TCTX("hist","bucket",3,"count")=352 S TCTX("hist","bucket",3,"toneClass")="bg-violet-500"
	S TCTX("hist","bucket",4,"label")="22-28" S TCTX("hist","bucket",4,"pct")=100 S TCTX("hist","bucket",4,"count")=418 S TCTX("hist","bucket",4,"toneClass")="bg-emerald-500"
	S TCTX("hist","bucket",5,"label")="29-35" S TCTX("hist","bucket",5,"pct")=72 S TCTX("hist","bucket",5,"count")=301 S TCTX("hist","bucket",5,"toneClass")="bg-amber-500"
	S TCTX("hist","bucket",6,"label")="36-42" S TCTX("hist","bucket",6,"pct")=48 S TCTX("hist","bucket",6,"count")=202 S TCTX("hist","bucket",6,"toneClass")="bg-rose-500"
	S TCTX("hist","bucket",7,"label")="43+" S TCTX("hist","bucket",7,"pct")=26 S TCTX("hist","bucket",7,"count")=109 S TCTX("hist","bucket",7,"toneClass")="bg-slate-500"
	S TCTX("hist","bandLabel")="Target aging band"
	S TCTX("hist","bandRange")="15 to 28 days"
	S TCTX("box","title")="Box-range summary"
	S TCTX("box","desc")="Quartile and whisker summary for payer turnaround, payment lag, or denial-resolution time."
	S TCTX("box","scaleMin")="0"
	S TCTX("box","scaleMid")="24"
	S TCTX("box","scaleMax")="48 days"
	S TCTX("box","minPct")=9
	S TCTX("box","q1Pct")=24
	S TCTX("box","medianPct")=46
	S TCTX("box","q3Pct")=68
	S TCTX("box","maxPct")=87
	S TCTX("box","summary",1,"label")="Min" S TCTX("box","summary",1,"value")="4d"
	S TCTX("box","summary",2,"label")="Q1" S TCTX("box","summary",2,"value")="11d"
	S TCTX("box","summary",3,"label")="Median" S TCTX("box","summary",3,"value")="22d"
	S TCTX("box","summary",4,"label")="Q3" S TCTX("box","summary",4,"value")="33d"
	S TCTX("box","summary",5,"label")="Max" S TCTX("box","summary",5,"value")="42d"
	S TCTX("box","note")="Useful when averages hide a long-tail payer or facility."
	S TCTX("radar","title")="Radar score profile"
	S TCTX("radar","desc")="Multi-axis score view for access, coding, documentation, denials, and follow-up readiness."
	S TCTX("radar","polygon")="100,22 162,58 150,130 100,164 50,130 38,58"
	S TCTX("radar","overlay")="100,10 190,62 172,146 100,194 28,146 10,62"
	S TCTX("radar","axis",1,"label")="Access" S TCTX("radar","axis",1,"left")="96px" S TCTX("radar","axis",1,"top")="0px" S TCTX("radar","axis",1,"score")="82"
	S TCTX("radar","axis",2,"label")="Coding" S TCTX("radar","axis",2,"left")="174px" S TCTX("radar","axis",2,"top")="42px" S TCTX("radar","axis",2,"score")="74"
	S TCTX("radar","axis",3,"label")="Docs" S TCTX("radar","axis",3,"left")="164px" S TCTX("radar","axis",3,"top")="130px" S TCTX("radar","axis",3,"score")="69"
	S TCTX("radar","axis",4,"label")="Denials" S TCTX("radar","axis",4,"left")="90px" S TCTX("radar","axis",4,"top")="184px" S TCTX("radar","axis",4,"score")="88"
	S TCTX("radar","axis",5,"label")="Appeals" S TCTX("radar","axis",5,"left")="8px" S TCTX("radar","axis",5,"top")="130px" S TCTX("radar","axis",5,"score")="63"
	S TCTX("radar","axis",6,"label")="Follow-up" S TCTX("radar","axis",6,"left")="-2px" S TCTX("radar","axis",6,"top")="42px" S TCTX("radar","axis",6,"score")="77"
	S TCTX("radar","legendCurrent")="Current month"
	S TCTX("radar","legendBenchmark")="Benchmark overlay"
	S TCTX("radar","profileLabel")="Manager composite"
	S TCTX("spark","title")="Sparkline comparison table"
	S TCTX("spark","desc")="Tabular chart variant for multi-metric review where tiny trend lines live beside exact values."
	S TCTX("spark","row",1,"metric")="Days in A/R" S TCTX("spark","row",1,"value")="31.2" S TCTX("spark","row",1,"delta")="-1.8" S TCTX("spark","row",1,"polyline")="4,20 24,22 44,18 64,16 84,14 104,12"
	S TCTX("spark","row",2,"metric")="Net collection" S TCTX("spark","row",2,"value")="94.1%" S TCTX("spark","row",2,"delta")="+0.7" S TCTX("spark","row",2,"polyline")="4,24 24,23 44,20 64,18 84,15 104,11"
	S TCTX("spark","row",3,"metric")="Denial rate" S TCTX("spark","row",3,"value")="6.4%" S TCTX("spark","row",3,"delta")="-0.4" S TCTX("spark","row",3,"polyline")="4,12 24,14 44,16 64,18 84,19 104,21"
	Q
	;
	;
	;
BUILDTRACE(CONF,REQ,CTX,TCTX)
	D BASE^MIOUICTX(.TCTX)
	D APPLY^MIOUITHEME(.CONF,.TCTX)
	D PAGE^MIOUICTX(.TCTX,"MIOUI / Trace","Trace and audit depth","Trace tables, audit timelines, grouped evidence, and compact detail cards for deep SSR review flows.","Trace and audit")
	D SUMINIT^MIOUITRA(.TCTX,"main","Trace summary","High-level coverage, round-trip state, and review depth before operators publish canonical artifacts.")
	D SUMSTAT^MIOUITRA(.TCTX,"main",1,"Coverage",4,"sky")
	D SUMSTAT^MIOUITRA(.TCTX,"main",2,"Warnings",1,"amber")
	D SUMSTAT^MIOUITRA(.TCTX,"main",3,"Artifacts",3,"emerald")
	D SUMSTAT^MIOUITRA(.TCTX,"main",4,"Round-trip","Clean","violet")
	D SUMFINAL^MIOUITRA(.TCTX,"main")
	D CARDINIT^MIOUITRA(.TCTX,"main","Trace detail","Compact summary for the selected claim, profile, and round-trip evidence that operators need during deep review.","sky")
	D CARDFIELD^MIOUITRA(.TCTX,"main",1,"Claim","CLM-1001")
	D CARDFIELD^MIOUITRA(.TCTX,"main",2,"Profile","Claim summary")
	D CARDFIELD^MIOUITRA(.TCTX,"main",3,"Job","JOB-1048")
	D CARDFIELD^MIOUITRA(.TCTX,"main",4,"Round-trip report","roundtrip-report.json")
	D CARDACT^MIOUITRA(.TCTX,"main",1,"Open billing preview","/mioui/billing","primary-button")
	D CARDACT^MIOUITRA(.TCTX,"main",2,"Download report","/mioui/trace?download=1","quick-button")
	D CARDFINAL^MIOUITRA(.TCTX,"main")
	D LGINIT^MIOUITRA(.TCTX,"main","Grouped evidence","Group artifacts and review buckets so audit context stays compact on dense SSR pages.")
	D LGROUP^MIOUITRA(.TCTX,"main",1,"Canonical artifacts","Stable deliverables for downstream review.","sky")
	D LGROW^MIOUITRA(.TCTX,"main",1,1,"claims.csv","Primary claim export","emerald")
	D LGROW^MIOUITRA(.TCTX,"main",1,2,"roundtrip-report.json","Trace evidence package","violet")
	D LGROUP^MIOUITRA(.TCTX,"main",2,"Warning buckets","Open review items before final publish.","amber")
	D LGROW^MIOUITRA(.TCTX,"main",2,1,"SV201","Modifier review needed on one line","amber")
	D LGROW^MIOUITRA(.TCTX,"main",2,2,"CSV001","Header row confirmed by active profile","sky")
	D LGFINAL^MIOUITRA(.TCTX,"main")
	D TLINIT^MIOUITRA(.TCTX,"main","Audit timeline","Time-ordered operator actions, evidence generation, and publish checkpoints for audit review.")
	D TLITEM^MIOUITRA(.TCTX,"main",1,"08:12","Preview opened","Operator opened CLM-1001 and reviewed claim and line output.","sky")
	D TLITEM^MIOUITRA(.TCTX,"main",2,"08:19","Trace generated","roundtrip-report.json written for deep validation.","violet")
	D TLITEM^MIOUITRA(.TCTX,"main",3,"08:24","Warning reviewed","SV201 reviewed before publish remained available.","amber")
	D TLFINAL^MIOUITRA(.TCTX,"main")
	D TBINIT^MIOUITRA(.TCTX,"main","Trace table","Dense source-to-output mapping for round-trip review and evidence scanning.","No trace rows.")
	D TBCOL^MIOUITRA(.TCTX,"main",1,"Path","left")
	D TBCOL^MIOUITRA(.TCTX,"main",2,"Source","left")
	D TBCOL^MIOUITRA(.TCTX,"main",3,"Output","left")
	D TBCOL^MIOUITRA(.TCTX,"main",4,"Status","left")
	D TBCELL^MIOUITRA(.TCTX,"main",1,1,"2400/SV1/03")
	D TBCELL^MIOUITRA(.TCTX,"main",1,2,"99213")
	D TBCELL^MIOUITRA(.TCTX,"main",1,3,"procedure_code")
	D TBCELL^MIOUITRA(.TCTX,"main",1,4,"mapped")
	D TBCELL^MIOUITRA(.TCTX,"main",2,1,"2300/CLM/02")
	D TBCELL^MIOUITRA(.TCTX,"main",2,2,"125.00")
	D TBCELL^MIOUITRA(.TCTX,"main",2,3,"total_charge")
	D TBCELL^MIOUITRA(.TCTX,"main",2,4,"mapped")
	D TBCELL^MIOUITRA(.TCTX,"main",3,1,"report/roundtrip")
	D TBCELL^MIOUITRA(.TCTX,"main",3,2,"roundtrip-report.json")
	D TBCELL^MIOUITRA(.TCTX,"main",3,3,"artifact_manifest")
	D TBCELL^MIOUITRA(.TCTX,"main",3,4,"ready")
	D TBFINAL^MIOUITRA(.TCTX,"main")
	Q
	;
	;
BUILDPREMIUM(CONF,REQ,CTX,TCTX)
	D BASE^MIOUICTX(.TCTX)
	D APPLY^MIOUITHEME(.CONF,.TCTX)
	D PAGE^MIOUICTX(.TCTX,"MIOUI / Premium","Premium workflow enhancements","Command bars, advanced filter drawers, inline toasts, and inline diff cards for dense review workflows.","Premium workflow")
	D BARINIT^MIOUIPRM(.TCTX,"main","Quick actions and shortcuts","Keep high-frequency operator actions near the page title without pushing the workflow into heavy client code.")
	D BARGROUP^MIOUIPRM(.TCTX,"main",1,"Quick actions","Most-used actions for batch review and publish flows.")
	D BARACT^MIOUIPRM(.TCTX,"main",1,1,"Create review batch","/mioui/premium?batch=1","primary-button")
	D BARACT^MIOUIPRM(.TCTX,"main",1,2,"Save current view","/mioui/premium?save=1","quick-button")
	D BARACT^MIOUIPRM(.TCTX,"main",1,3,"Open trace review","/mioui/trace","ghost-button")
	D BARGROUP^MIOUIPRM(.TCTX,"main",2,"Shortcuts","Stable keyboard-ready actions that can remain SSR-first.")
	D BARACT^MIOUIPRM(.TCTX,"main",2,1,"Preview selected","/mioui/billing","quick-button")
	D BARACT^MIOUIPRM(.TCTX,"main",2,2,"Export current queue","/mioui/export","ghost-button")
	D BARFINAL^MIOUIPRM(.TCTX,"main")
	D FDINIT^MIOUIPRM(.TCTX,"main","Advanced filters","Keep secondary filters compact until operators need a deeper narrowing pass.")
	D FDSECTION^MIOUIPRM(.TCTX,"main",1,"Review state","Status and readiness controls for high-volume billing queues.")
	D FDFIELD^MIOUIPRM(.TCTX,"main",1,1,"Status","Previewed, Publishable","Two stable statuses are active for this queue.")
	D FDFIELD^MIOUIPRM(.TCTX,"main",1,2,"Priority","High, Medium","Saved views can lock this field by default.")
	D FDSECTION^MIOUIPRM(.TCTX,"main",2,"Date and payer","Date-range and payer filters used during daily reconciliation.")
	D FDFIELD^MIOUIPRM(.TCTX,"main",2,1,"Date of service","2026-03-01 to 2026-03-16","Common billing date window for this view.")
	D FDFIELD^MIOUIPRM(.TCTX,"main",2,2,"Payer","ALPHA HEALTH","Pinned for the current review batch.")
	D FDFINAL^MIOUIPRM(.TCTX,"main")
	D TOAST^MIOUIPRM(.TCTX,"main","success","Saved view updated","The high-risk queue now loads with your last used columns and review filters.",1)
	D DIFFINIT^MIOUIPRM(.TCTX,"main","Inline diff review","Compare corrected values without leaving the selected-record workflow.")
	D DIFFROW^MIOUIPRM(.TCTX,"main",1,"Subscriber last name","DOE","DOE-SMITH",1)
	D DIFFROW^MIOUIPRM(.TCTX,"main",2,"Claim frequency","1","1",0)
	D DIFFROW^MIOUIPRM(.TCTX,"main",3,"Payer name","ALPHA HEALTH","ALPHA HEALTH PLAN",1)
	D DIFFFINAL^MIOUIPRM(.TCTX,"main")
	Q
	;
	;
BUILDLARGE(CONF,REQ,CTX,TCTX)
	D BASE^MIOUICTX(.TCTX)
	D APPLY^MIOUITHEME(.CONF,.TCTX)
	D ACT^MIOUICTX(.TCTX,"tables")
	D PAGE^MIOUICTX(.TCTX,"MIOUI / Large table","Very large SSR table","High-volume billing and operator table with server pagination, filtering, ordering, sorting, totals, and row expansion.","Large table")
	D PHEADER^MIOUIOPS(.TCTX,"large","Large table","Very large claims queue","Dense SSR queue surface for billing operations where filters, sorts, pagination, and visible column order remain server-owned.")
	D PHEADMETA^MIOUIOPS(.TCTX,"large",1,"Total",24812,"slate")
	D PHEADMETA^MIOUIOPS(.TCTX,"large",2,"Page",3,"sky")
	D PHEADMETA^MIOUIOPS(.TCTX,"large",3,"Per page",100,"amber")
	D PHEADACT^MIOUIOPS(.TCTX,"large",1,"Open detailed grid","/mioui/datagrid","quick-button")
	D PHEADACT^MIOUIOPS(.TCTX,"large",2,"Open trace review","/mioui/trace","primary-button")
	D VIEWSINIT^MIOUIOPS(.TCTX,"large","Saved views","Operator-ready presets for large queues and reconciliation passes.")
	D VIEW^MIOUIOPS(.TCTX,"large",1,"My preview queue","/mioui/large-table?view=preview",0,842)
	D VIEW^MIOUIOPS(.TCTX,"large",2,"Needs review","/mioui/large-table?view=review",1,311)
	D VIEW^MIOUIOPS(.TCTX,"large",3,"High charge","/mioui/large-table?view=charge",0,88)
	D VIEW^MIOUIOPS(.TCTX,"large",4,"Round-trip gaps","/mioui/large-table?view=trace",0,17)
	D VIEWSFINAL^MIOUIOPS(.TCTX,"large")
	D INIT^MIOUILGT(.TCTX,"main","Large claims queue","Very large table contract with explicit server state, row expansion, totals, density, saved views, and visible column ordering.","No claims matched the current queue.")
	D INSIGHT^MIOUILGT(.TCTX,"main",1,"Rendered rows",100,"sky")
	D INSIGHT^MIOUILGT(.TCTX,"main",2,"Visible columns",7,"emerald")
	D INSIGHT^MIOUILGT(.TCTX,"main",3,"Selected rows",3,"amber")
	D INSIGHT^MIOUILGT(.TCTX,"main",4,"Active filters",4,"violet")
	D PREF^MIOUILGT(.TCTX,"main",1,"Saved view","Needs review")
	D PREF^MIOUILGT(.TCTX,"main",2,"Owner","West pod")
	D PREF^MIOUILGT(.TCTX,"main",3,"Sort","Charge desc")
	D PREF^MIOUILGT(.TCTX,"main",4,"Mode","Server-owned")
	D SUMMARY^MIOUILGT(.TCTX,"main",3,"Selection stays page-aware while totals and filters remain authoritative for the full queue.")
	D SUMACT^MIOUILGT(.TCTX,"main",1,"Publish selected","/mioui/billing","primary-button")
	D SUMACT^MIOUILGT(.TCTX,"main",2,"Export current page","/mioui/export","quick-button")
	D STATE^MIOUILGT(.TCTX,"main","status:needs-review owner:west charge>100",3,100,24812,"charge","desc")
	D NAV^MIOUILGT(.TCTX,"main","/mioui/large-table?page=2","/mioui/large-table?page=4")
	D PEROPT^MIOUILGT(.TCTX,"main",1,"50 / page",0,"/mioui/large-table?per=50")
	D PEROPT^MIOUILGT(.TCTX,"main",2,"100 / page",1,"/mioui/large-table?per=100")
	D PEROPT^MIOUILGT(.TCTX,"main",3,"250 / page",0,"/mioui/large-table?per=250")
	D DENSITY^MIOUILGT(.TCTX,"main",1,"Dense",1,"/mioui/large-table?density=dense")
	D DENSITY^MIOUILGT(.TCTX,"main",2,"Comfortable",0,"/mioui/large-table?density=comfortable")
	D DENSITY^MIOUILGT(.TCTX,"main",3,"Audit",0,"/mioui/large-table?density=audit")
	D FILTERGROUP^MIOUILGT(.TCTX,"main",1,"Status")
	D FILTEROPT^MIOUILGT(.TCTX,"main",1,1,"Needs review",311,1,"/mioui/large-table?status=needs-review")
	D FILTEROPT^MIOUILGT(.TCTX,"main",1,2,"Previewed",842,0,"/mioui/large-table?status=previewed")
	D FILTEROPT^MIOUILGT(.TCTX,"main",1,3,"Published",19640,0,"/mioui/large-table?status=published")
	D FILTERGROUP^MIOUILGT(.TCTX,"main",2,"Owner")
	D FILTEROPT^MIOUILGT(.TCTX,"main",2,1,"West pod",477,1,"/mioui/large-table?owner=west")
	D FILTEROPT^MIOUILGT(.TCTX,"main",2,2,"East pod",390,0,"/mioui/large-table?owner=east")
	D FILTEROPT^MIOUILGT(.TCTX,"main",2,3,"Escalations",22,0,"/mioui/large-table?owner=escalations")
	D FILTERGROUP^MIOUILGT(.TCTX,"main",3,"Facility")
	D FILTEROPT^MIOUILGT(.TCTX,"main",3,1,"Main clinic",188,0,"/mioui/large-table?facility=main")
	D FILTEROPT^MIOUILGT(.TCTX,"main",3,2,"North rehab",64,0,"/mioui/large-table?facility=north")
	D FILTEROPT^MIOUILGT(.TCTX,"main",3,3,"Telehealth",59,0,"/mioui/large-table?facility=tele")
	D ACTIVEFILTER^MIOUILGT(.TCTX,"main",1,"Needs review","/mioui/large-table?clear=status")
	D ACTIVEFILTER^MIOUILGT(.TCTX,"main",2,"West pod","/mioui/large-table?clear=owner")
	D ACTIVEFILTER^MIOUILGT(.TCTX,"main",3,"Charge > 100","/mioui/large-table?clear=charge")
	D ACTIVEFILTER^MIOUILGT(.TCTX,"main",4,"30 day DOS","/mioui/large-table?clear=dos")
	D COL^MIOUILGT(.TCTX,"main",1,"claim","Claim / patient","left","19rem",0,"","/mioui/large-table?sort=claim",1)
	D COL^MIOUILGT(.TCTX,"main",2,"dos","Date of service","left","10rem",0,"","/mioui/large-table?sort=dos",0)
	D COL^MIOUILGT(.TCTX,"main",3,"code","Code","left","8rem",0,"","/mioui/large-table?sort=code",0)
	D COL^MIOUILGT(.TCTX,"main",4,"payer","Payer","left","12rem",0,"","/mioui/large-table?sort=payer",0)
	D COL^MIOUILGT(.TCTX,"main",5,"charge","Charge","right","8rem",1,"desc","/mioui/large-table?sort=charge",0)
	D COL^MIOUILGT(.TCTX,"main",6,"status","Status","left","10rem",0,"","/mioui/large-table?sort=status",0)
	D COL^MIOUILGT(.TCTX,"main",7,"owner","Owner","left","10rem",0,"","/mioui/large-table?sort=owner",0)
	D ORDER^MIOUILGT(.TCTX,"main",1,"Claim / patient",0,"/mioui/large-table?move=claim-up","/mioui/large-table?move=claim-down")
	D ORDER^MIOUILGT(.TCTX,"main",2,"Date of service",0,"/mioui/large-table?move=dos-up","/mioui/large-table?move=dos-down")
	D ORDER^MIOUILGT(.TCTX,"main",3,"Code",0,"/mioui/large-table?move=code-up","/mioui/large-table?move=code-down")
	D ORDER^MIOUILGT(.TCTX,"main",4,"Payer",0,"/mioui/large-table?move=payer-up","/mioui/large-table?move=payer-down")
	D ORDER^MIOUILGT(.TCTX,"main",5,"Charge",1,"/mioui/large-table?move=charge-up","/mioui/large-table?move=charge-down")
	D ORDER^MIOUILGT(.TCTX,"main",6,"Status",0,"/mioui/large-table?move=status-up","/mioui/large-table?move=status-down")
	D ORDER^MIOUILGT(.TCTX,"main",7,"Owner",0,"/mioui/large-table?move=owner-up","/mioui/large-table?move=owner-down")
	D ROW^MIOUILGT(.TCTX,"main",1,"CLM-84031","MARTIN, ELAINE","837P professional / batch Q32",1,1,"/mioui/billing#clm84031")
	D IDCELL^MIOUILGT(.TCTX,"main",1,1,1)
	D CELL^MIOUILGT(.TCTX,"main",1,2,"2026-03-01","left","",0)
	D CELL^MIOUILGT(.TCTX,"main",1,3,"99213","left","strong",0)
	D CELL^MIOUILGT(.TCTX,"main",1,4,"ALPHA HEALTH","left","",0)
	D CELL^MIOUILGT(.TCTX,"main",1,5,"125.00","right","strong",0)
	D CELL^MIOUILGT(.TCTX,"main",1,6,"Needs review","left","",0)
	D CELL^MIOUILGT(.TCTX,"main",1,7,"West pod","left","muted",0)
	D ROWBADGE^MIOUILGT(.TCTX,"main",1,"Needs review","amber")
	D ROWACT^MIOUILGT(.TCTX,"main",1,1,"Open","/mioui/billing#clm84031","quick-button")
	D ROWACT^MIOUILGT(.TCTX,"main",1,2,"Trace","/mioui/trace#clm84031","ghost-button")
	D DETAIL^MIOUILGT(.TCTX,"main",1,"Expanded row detail","Service line notes, diagnostics, and artifact links stay inline for faster operator review.")
	D ROW^MIOUILGT(.TCTX,"main",2,"CLM-84032","HALL, JEROME","837P professional / batch Q32",1,0,"/mioui/billing#clm84032")
	D IDCELL^MIOUILGT(.TCTX,"main",2,1,1)
	D CELL^MIOUILGT(.TCTX,"main",2,2,"2026-03-02","left","",0)
	D CELL^MIOUILGT(.TCTX,"main",2,3,"99214","left","strong",0)
	D CELL^MIOUILGT(.TCTX,"main",2,4,"ALPHA HEALTH","left","",0)
	D CELL^MIOUILGT(.TCTX,"main",2,5,"220.55","right","strong",0)
	D CELL^MIOUILGT(.TCTX,"main",2,6,"Previewed","left","",0)
	D CELL^MIOUILGT(.TCTX,"main",2,7,"West pod","left","muted",0)
	D ROWBADGE^MIOUILGT(.TCTX,"main",2,"Previewed","sky")
	D ROWACT^MIOUILGT(.TCTX,"main",2,1,"Open","/mioui/billing#clm84032","quick-button")
	D ROW^MIOUILGT(.TCTX,"main",3,"CLM-84033","SANCHEZ, MARCO","837P professional / batch Q33",0,0,"/mioui/billing#clm84033")
	D IDCELL^MIOUILGT(.TCTX,"main",3,1,1)
	D CELL^MIOUILGT(.TCTX,"main",3,2,"2026-03-03","left","",0)
	D CELL^MIOUILGT(.TCTX,"main",3,3,"97110","left","strong",0)
	D CELL^MIOUILGT(.TCTX,"main",3,4,"MEDICARE","left","",0)
	D CELL^MIOUILGT(.TCTX,"main",3,5,"310.00","right","strong",0)
	D CELL^MIOUILGT(.TCTX,"main",3,6,"Queued","left","",0)
	D CELL^MIOUILGT(.TCTX,"main",3,7,"Escalations","left","muted",0)
	D ROWBADGE^MIOUILGT(.TCTX,"main",3,"Queued","slate")
	D ROWACT^MIOUILGT(.TCTX,"main",3,1,"Open","/mioui/billing#clm84033","quick-button")
	D ROW^MIOUILGT(.TCTX,"main",4,"CLM-84034","RAO, NISHA","837P professional / batch Q33",1,0,"/mioui/billing#clm84034")
	D IDCELL^MIOUILGT(.TCTX,"main",4,1,1)
	D CELL^MIOUILGT(.TCTX,"main",4,2,"2026-03-04","left","",0)
	D CELL^MIOUILGT(.TCTX,"main",4,3,"93000","left","strong",0)
	D CELL^MIOUILGT(.TCTX,"main",4,4,"NOVA PLAN","left","",0)
	D CELL^MIOUILGT(.TCTX,"main",4,5,"89.10","right","strong",0)
	D CELL^MIOUILGT(.TCTX,"main",4,6,"Published","left","",0)
	D CELL^MIOUILGT(.TCTX,"main",4,7,"West pod","left","muted",0)
	D ROWBADGE^MIOUILGT(.TCTX,"main",4,"Published","emerald")
	D ROWACT^MIOUILGT(.TCTX,"main",4,1,"Open","/mioui/billing#clm84034","quick-button")
	D ROW^MIOUILGT(.TCTX,"main",5,"CLM-84035","OWENS, JADA","837P professional / batch Q34",0,0,"/mioui/billing#clm84035")
	D IDCELL^MIOUILGT(.TCTX,"main",5,1,1)
	D CELL^MIOUILGT(.TCTX,"main",5,2,"2026-03-05","left","",0)
	D CELL^MIOUILGT(.TCTX,"main",5,3,"99203","left","strong",0)
	D CELL^MIOUILGT(.TCTX,"main",5,4,"ALPHA HEALTH","left","",0)
	D CELL^MIOUILGT(.TCTX,"main",5,5,"145.50","right","strong",0)
	D CELL^MIOUILGT(.TCTX,"main",5,6,"Needs review","left","",0)
	D CELL^MIOUILGT(.TCTX,"main",5,7,"West pod","left","muted",0)
	D ROWBADGE^MIOUILGT(.TCTX,"main",5,"Needs review","amber")
	D ROWACT^MIOUILGT(.TCTX,"main",5,1,"Open","/mioui/billing#clm84035","quick-button")
	D TOTAL^MIOUILGT(.TCTX,"main",1,"Page totals","left",1)
	D TOTAL^MIOUILGT(.TCTX,"main",2,"100 rows","left",0)
	D TOTAL^MIOUILGT(.TCTX,"main",3,"5 visible","left",0)
	D TOTAL^MIOUILGT(.TCTX,"main",4,"3 payers","left",0)
	D TOTAL^MIOUILGT(.TCTX,"main",5,"890.15","right",1)
	D TOTAL^MIOUILGT(.TCTX,"main",6,"3 selected","left",1)
	D TOTAL^MIOUILGT(.TCTX,"main",7,"West pod","left",0)
	D FINAL^MIOUILGT(.TCTX,"main")
	Q
	;
	;
BUILDMILLION(CONF,REQ,CTX,TCTX)
	D BASE^MIOUICTX(.TCTX)
	D APPLY^MIOUITHEME(.CONF,.TCTX)
	D ACT^MIOUICTX(.TCTX,"tables")
	D PAGE^MIOUICTX(.TCTX,"MIOUI / Million table","Million-row data table","Standalone SSR component for one-million-row queues with server paging, searching, filtering, ordering, sorting, expanding, and selected-column callbacks.","Million-row table")
	D PHEADER^MIOUIOPS(.TCTX,"million","Standalone component","Million-row claims queue","Configurable server-shaped data table component for one-million-row billing and operator datasets.")
	D PHEADMETA^MIOUIOPS(.TCTX,"million",1,"Rows","1,000,000","slate")
	D PHEADMETA^MIOUIOPS(.TCTX,"million",2,"Columns",20,"sky")
	D PHEADMETA^MIOUIOPS(.TCTX,"million",3,"Per page",250,"amber")
	D PHEADACT^MIOUIOPS(.TCTX,"million",1,"Open large table","/mioui/large-table","quick-button")
	D PHEADACT^MIOUIOPS(.TCTX,"million",2,"Open detailed grid","/mioui/datagrid","primary-button")
	D INIT^MIOUIMLT(.TCTX,"main","Million-row queue","Standalone data-table component for the largest billing and reconciliation queues where the server owns paging, search, filter, ordering, sorting, row expansion, and column callbacks.","No rows matched this server-owned query.")
	D CONFIG^MIOUIMLT(.TCTX,"main","claims-million-grid",1000000,20,250,4000,"alpha health 99213 west","charge","desc")
	D FEATURE^MIOUIMLT(.TCTX,"main",1,"Server-side paging","Page 4000 of 4000","sky")
	D FEATURE^MIOUIMLT(.TCTX,"main",2,"Visible rows",250,"emerald")
	D FEATURE^MIOUIMLT(.TCTX,"main",3,"Selected columns",8,"amber")
	D FEATURE^MIOUIMLT(.TCTX,"main",4,"Active filters",5,"violet")
	D SEARCH^MIOUIMLT(.TCTX,"main","alpha health 99213 west","Search claims, patients, payers, and codes","/mioui/million-table?clear=q")
	D WINDOW^MIOUIMLT(.TCTX,"main",4000,250,1000000)
	D NAV^MIOUIMLT(.TCTX,"main","/mioui/million-table?page=3999","")
	D PEROPT^MIOUIMLT(.TCTX,"main",1,"100 / page",0,"/mioui/million-table?per=100")
	D PEROPT^MIOUIMLT(.TCTX,"main",2,"250 / page",1,"/mioui/million-table?per=250")
	D PEROPT^MIOUIMLT(.TCTX,"main",3,"500 / page",0,"/mioui/million-table?per=500")
	D SORTSTACK^MIOUIMLT(.TCTX,"main",1,"charge","desc",1,"/mioui/million-table?sort=charge&dir=desc")
	D SORTSTACK^MIOUIMLT(.TCTX,"main",2,"date_of_service","asc",2,"/mioui/million-table?sort=dos&dir=asc")
	D SORTSTACK^MIOUIMLT(.TCTX,"main",3,"payer","asc",3,"/mioui/million-table?sort=payer&dir=asc")
	D FILTERGROUP^MIOUIMLT(.TCTX,"main",1,"Status filters")
	D FILTEROPT^MIOUIMLT(.TCTX,"main",1,1,"Needs review",214,1,"/mioui/million-table?status=needs-review")
	D FILTEROPT^MIOUIMLT(.TCTX,"main",1,2,"Previewed",740,0,"/mioui/million-table?status=previewed")
	D FILTEROPT^MIOUIMLT(.TCTX,"main",1,3,"Published",998612,0,"/mioui/million-table?status=published")
	D FILTERGROUP^MIOUIMLT(.TCTX,"main",2,"Payer")
	D FILTEROPT^MIOUIMLT(.TCTX,"main",2,1,"ALPHA HEALTH",28111,1,"/mioui/million-table?payer=alpha")
	D FILTEROPT^MIOUIMLT(.TCTX,"main",2,2,"MEDICARE",422091,0,"/mioui/million-table?payer=medicare")
	D FILTEROPT^MIOUIMLT(.TCTX,"main",2,3,"NOVA PLAN",118902,0,"/mioui/million-table?payer=nova")
	D FILTERGROUP^MIOUIMLT(.TCTX,"main",3,"Owner")
	D FILTEROPT^MIOUIMLT(.TCTX,"main",3,1,"West pod",180,1,"/mioui/million-table?owner=west")
	D FILTEROPT^MIOUIMLT(.TCTX,"main",3,2,"East pod",144,0,"/mioui/million-table?owner=east")
	D FILTEROPT^MIOUIMLT(.TCTX,"main",3,3,"Escalations",19,0,"/mioui/million-table?owner=esc")
	D ACTIVEFILTER^MIOUIMLT(.TCTX,"main",1,"Needs review","/mioui/million-table?clear=status")
	D ACTIVEFILTER^MIOUIMLT(.TCTX,"main",2,"ALPHA HEALTH","/mioui/million-table?clear=payer")
	D ACTIVEFILTER^MIOUIMLT(.TCTX,"main",3,"West pod","/mioui/million-table?clear=owner")
	D ACTIVEFILTER^MIOUIMLT(.TCTX,"main",4,"Charge > 100","/mioui/million-table?clear=charge")
	D ACTIVEFILTER^MIOUIMLT(.TCTX,"main",5,"99213","/mioui/million-table?clear=code")
	D CALLBACK^MIOUIMLT(.TCTX,"main",1,"Pin selected columns","pinSelectedColumns","/mioui/million-table?action=pin","primary-button")
	D CALLBACK^MIOUIMLT(.TCTX,"main",2,"Export selected columns","exportSelectedColumns","/mioui/million-table?action=export-columns","quick-button")
	D CALLBACK^MIOUIMLT(.TCTX,"main",3,"Apply formatter","applyColumnPreset","/mioui/million-table?action=formatter","ghost-button")
	D SELCOL^MIOUIMLT(.TCTX,"main",1,"Claim / patient","Pinned identity column",1,"/mioui/million-table?col=claim-up","/mioui/million-table?col=claim-down")
	D SELCOL^MIOUIMLT(.TCTX,"main",2,"Date of service","Visible + sortable",1,"/mioui/million-table?col=dos-up","/mioui/million-table?col=dos-down")
	D SELCOL^MIOUIMLT(.TCTX,"main",3,"CPT / HCPCS","Visible + sortable",1,"/mioui/million-table?col=cpt-up","/mioui/million-table?col=cpt-down")
	D SELCOL^MIOUIMLT(.TCTX,"main",4,"Charge","Visible + right aligned",1,"/mioui/million-table?col=charge-up","/mioui/million-table?col=charge-down")
	D SELCOL^MIOUIMLT(.TCTX,"main",5,"Allowed","Visible + right aligned",1,"/mioui/million-table?col=allowed-up","/mioui/million-table?col=allowed-down")
	D SELCOL^MIOUIMLT(.TCTX,"main",6,"Payer","Visible + filterable",1,"/mioui/million-table?col=payer-up","/mioui/million-table?col=payer-down")
	D SELCOL^MIOUIMLT(.TCTX,"main",7,"Status","Visible + faceted",1,"/mioui/million-table?col=status-up","/mioui/million-table?col=status-down")
	D SELCOL^MIOUIMLT(.TCTX,"main",8,"Owner","Visible + callback",1,"/mioui/million-table?col=owner-up","/mioui/million-table?col=owner-down")
	D COL^MIOUIMLT(.TCTX,"main",1,"claim","Claim / patient","left","18rem",1,"","/mioui/million-table?sort=claim",1,1)
	D COL^MIOUIMLT(.TCTX,"main",2,"member","Member ID","left","10rem",0,"","/mioui/million-table?sort=member",1,0)
	D COL^MIOUIMLT(.TCTX,"main",3,"dos","Date of service","left","10rem",0,"","/mioui/million-table?sort=dos",1,0)
	D COL^MIOUIMLT(.TCTX,"main",4,"cpt","CPT / HCPCS","left","8rem",0,"","/mioui/million-table?sort=cpt",1,0)
	D COL^MIOUIMLT(.TCTX,"main",5,"mod","Modifier","left","7rem",0,"","/mioui/million-table?sort=mod",1,0)
	D COL^MIOUIMLT(.TCTX,"main",6,"units","Units","right","6rem",0,"","/mioui/million-table?sort=units",1,0)
	D COL^MIOUIMLT(.TCTX,"main",7,"charge","Charge","right","8rem",1,"desc","/mioui/million-table?sort=charge",1,0)
	D COL^MIOUIMLT(.TCTX,"main",8,"allowed","Allowed","right","8rem",0,"","/mioui/million-table?sort=allowed",1,0)
	D COL^MIOUIMLT(.TCTX,"main",9,"payer","Payer","left","12rem",0,"","/mioui/million-table?sort=payer",1,0)
	D COL^MIOUIMLT(.TCTX,"main",10,"status","Status","left","10rem",0,"","/mioui/million-table?sort=status",1,0)
	D COL^MIOUIMLT(.TCTX,"main",11,"owner","Owner","left","10rem",0,"","/mioui/million-table?sort=owner",1,0)
	D COL^MIOUIMLT(.TCTX,"main",12,"queue","Queue","left","9rem",0,"","/mioui/million-table?sort=queue",1,0)
	D COL^MIOUIMLT(.TCTX,"main",13,"facility","Facility","left","10rem",0,"","/mioui/million-table?sort=facility",1,0)
	D COL^MIOUIMLT(.TCTX,"main",14,"file","File","left","12rem",0,"","/mioui/million-table?sort=file",1,0)
	D COL^MIOUIMLT(.TCTX,"main",15,"batch","Batch","left","9rem",0,"","/mioui/million-table?sort=batch",1,0)
	D COL^MIOUIMLT(.TCTX,"main",16,"trace","Trace","left","9rem",0,"","/mioui/million-table?sort=trace",1,0)
	D COL^MIOUIMLT(.TCTX,"main",17,"export","Export","left","10rem",0,"","/mioui/million-table?sort=export",1,0)
	D COL^MIOUIMLT(.TCTX,"main",18,"age","Age","right","6rem",0,"","/mioui/million-table?sort=age",1,0)
	D COL^MIOUIMLT(.TCTX,"main",19,"updated","Updated","left","10rem",0,"","/mioui/million-table?sort=updated",1,0)
	D COL^MIOUIMLT(.TCTX,"main",20,"notes","Notes","left","14rem",0,"","/mioui/million-table?sort=notes",1,0)
	D MROW^MIOUIMLT(.TCTX,"main",1,"CLM-999751","MARTIN, ELAINE","Batch Z99 / west pod",1,1,"/mioui/billing#clm999751")
	D MCELL^MIOUIMLT(.TCTX,"main",1,1,"","left","",1)
	D MCELL^MIOUIMLT(.TCTX,"main",1,2,"M-881201","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",1,3,"2026-03-11","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",1,4,"99213","left","strong",0)
	D MCELL^MIOUIMLT(.TCTX,"main",1,5,"25","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",1,6,"1","right","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",1,7,"125.00","right","strong",0)
	D MCELL^MIOUIMLT(.TCTX,"main",1,8,"102.14","right","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",1,9,"ALPHA HEALTH","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",1,10,"Needs review","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",1,11,"West pod","left","muted",0)
	D MCELL^MIOUIMLT(.TCTX,"main",1,12,"High-risk","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",1,13,"Main clinic","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",1,14,"837p-20260311-99.edi","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",1,15,"Z99","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",1,16,"TRC-991","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",1,17,"CSV ready","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",1,18,"2d","right","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",1,19,"2026-03-17","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",1,20,"Missing payer note","left","",0)
	D MROWBADGE^MIOUIMLT(.TCTX,"main",1,"Needs review","amber")
	D MROWACT^MIOUIMLT(.TCTX,"main",1,1,"Open","/mioui/billing#clm999751","quick-button")
	D MROWACT^MIOUIMLT(.TCTX,"main",1,2,"Trace","/mioui/trace#clm999751","ghost-button")
	D MDETAIL^MIOUIMLT(.TCTX,"main",1,"Expanded row detail","Line notes, trace anchors, and callback-ready column metadata stay inline for million-row queue review.")
	D MROW^MIOUIMLT(.TCTX,"main",2,"CLM-999752","HALL, JEROME","Batch Z99 / west pod",0,0,"/mioui/billing#clm999752")
	D MCELL^MIOUIMLT(.TCTX,"main",2,1,"","left","",1)
	D MCELL^MIOUIMLT(.TCTX,"main",2,2,"M-881202","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",2,3,"2026-03-12","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",2,4,"99214","left","strong",0)
	D MCELL^MIOUIMLT(.TCTX,"main",2,5,"95","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",2,6,"1","right","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",2,7,"220.55","right","strong",0)
	D MCELL^MIOUIMLT(.TCTX,"main",2,8,"180.11","right","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",2,9,"ALPHA HEALTH","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",2,10,"Previewed","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",2,11,"West pod","left","muted",0)
	D MCELL^MIOUIMLT(.TCTX,"main",2,12,"Standard","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",2,13,"Main clinic","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",2,14,"837p-20260311-99.edi","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",2,15,"Z99","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",2,16,"TRC-992","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",2,17,"CSV ready","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",2,18,"1d","right","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",2,19,"2026-03-17","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",2,20,"Ready for export","left","",0)
	D MROWBADGE^MIOUIMLT(.TCTX,"main",2,"Previewed","sky")
	D MROWACT^MIOUIMLT(.TCTX,"main",2,1,"Open","/mioui/billing#clm999752","quick-button")
	D MROW^MIOUIMLT(.TCTX,"main",3,"CLM-999753","RAO, NISHA","Batch Z99 / west pod",1,0,"/mioui/billing#clm999753")
	D MCELL^MIOUIMLT(.TCTX,"main",3,1,"","left","",1)
	D MCELL^MIOUIMLT(.TCTX,"main",3,2,"M-881203","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",3,3,"2026-03-13","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",3,4,"93000","left","strong",0)
	D MCELL^MIOUIMLT(.TCTX,"main",3,5,"","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",3,6,"1","right","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",3,7,"89.10","right","strong",0)
	D MCELL^MIOUIMLT(.TCTX,"main",3,8,"73.90","right","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",3,9,"ALPHA HEALTH","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",3,10,"Needs review","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",3,11,"West pod","left","muted",0)
	D MCELL^MIOUIMLT(.TCTX,"main",3,12,"Escalation","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",3,13,"North rehab","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",3,14,"837p-20260311-99.edi","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",3,15,"Z99","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",3,16,"TRC-993","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",3,17,"Pending","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",3,18,"5h","right","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",3,19,"2026-03-17","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",3,20,"Review CPT note","left","",0)
	D MROWBADGE^MIOUIMLT(.TCTX,"main",3,"Needs review","amber")
	D MROWACT^MIOUIMLT(.TCTX,"main",3,1,"Open","/mioui/billing#clm999753","quick-button")
	D MROWACT^MIOUIMLT(.TCTX,"main",3,2,"Queue","/mioui/operators#queue","ghost-button")
	D MROW^MIOUIMLT(.TCTX,"main",4,"CLM-999754","OWENS, JADA","Batch Z99 / west pod",0,0,"/mioui/billing#clm999754")
	D MCELL^MIOUIMLT(.TCTX,"main",4,1,"","left","",1)
	D MCELL^MIOUIMLT(.TCTX,"main",4,2,"M-881204","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",4,3,"2026-03-14","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",4,4,"97110","left","strong",0)
	D MCELL^MIOUIMLT(.TCTX,"main",4,5,"GP","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",4,6,"2","right","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",4,7,"310.00","right","strong",0)
	D MCELL^MIOUIMLT(.TCTX,"main",4,8,"250.00","right","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",4,9,"ALPHA HEALTH","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",4,10,"Published","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",4,11,"West pod","left","muted",0)
	D MCELL^MIOUIMLT(.TCTX,"main",4,12,"Standard","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",4,13,"Telehealth","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",4,14,"837p-20260311-99.edi","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",4,15,"Z99","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",4,16,"TRC-994","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",4,17,"CSV sent","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",4,18,"3h","right","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",4,19,"2026-03-17","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",4,20,"No active notes","left","",0)
	D MROWBADGE^MIOUIMLT(.TCTX,"main",4,"Published","emerald")
	D MROWACT^MIOUIMLT(.TCTX,"main",4,1,"Open","/mioui/billing#clm999754","quick-button")
	D MROW^MIOUIMLT(.TCTX,"main",5,"CLM-999755","SANCHEZ, MARCO","Batch Z99 / west pod",0,0,"/mioui/billing#clm999755")
	D MCELL^MIOUIMLT(.TCTX,"main",5,1,"","left","",1)
	D MCELL^MIOUIMLT(.TCTX,"main",5,2,"M-881205","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",5,3,"2026-03-15","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",5,4,"99203","left","strong",0)
	D MCELL^MIOUIMLT(.TCTX,"main",5,5,"","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",5,6,"1","right","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",5,7,"145.50","right","strong",0)
	D MCELL^MIOUIMLT(.TCTX,"main",5,8,"118.02","right","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",5,9,"ALPHA HEALTH","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",5,10,"Previewed","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",5,11,"West pod","left","muted",0)
	D MCELL^MIOUIMLT(.TCTX,"main",5,12,"Follow-up","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",5,13,"Main clinic","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",5,14,"837p-20260311-99.edi","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",5,15,"Z99","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",5,16,"TRC-995","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",5,17,"CSV ready","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",5,18,"1h","right","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",5,19,"2026-03-17","left","",0)
	D MCELL^MIOUIMLT(.TCTX,"main",5,20,"Ready for batch","left","",0)
	D MROWBADGE^MIOUIMLT(.TCTX,"main",5,"Previewed","sky")
	D MROWACT^MIOUIMLT(.TCTX,"main",5,1,"Open","/mioui/billing#clm999755","quick-button")
	D FINAL^MIOUIMLT(.TCTX,"main")
	Q
	;
RESPHTML(DEV,CONF,CTX,OUT)
	D RESPTXT(.DEV,.CONF,.CTX,.OUT,"text/html; charset=utf-8") Q
	;
RESPTXT(DEV,CONF,CTX,OUT,CTYPE)
	N HEAD S HEAD("Content-Type")=$G(CTYPE)
	D RESPX^MIOHTTP(.DEV,.CONF,200,.HEAD,$G(OUT),$G(CTX("request_id")),.CTX) Q
	;
RESPERR(DEV,CONF,CTX,STATUS,ERRTXT)
	N OBJ S OBJ("ok")=0,OBJ("error")=$G(ERRTXT)
	D RESPJSONX^MIOHTTP(.DEV,.CONF,+$G(STATUS),.OBJ,$G(CTX("request_id")),.CTX) Q
	;
	;
	;
BUILDEXPORT(CONF,REQ,CTX,TCTX)
	D BASE^MIOUICTX(.TCTX)
	D APPLY^MIOUITHEME(.CONF,.TCTX)
	D ACT^MIOUICTX(.TCTX,"export")
	D PAGE^MIOUICTX(.TCTX,"MIOUI / Export","Export UX","Reusable field-selection and export editing surfaces for dense billing workflows.","Profile editor")
	D SUMINIT^MIOUIEXP(.TCTX,"main","Export profile summary","Compact output rules, selected-field counts, and file naming rules for CSV profile review.")
	D SUMSTAT^MIOUIEXP(.TCTX,"main",1,"Mode","Claim summary","sky")
	D SUMSTAT^MIOUIEXP(.TCTX,"main",2,"Selected fields",4,"emerald")
	D SUMSTAT^MIOUIEXP(.TCTX,"main",3,"Delimiter","Comma","amber")
	D SUMSTAT^MIOUIEXP(.TCTX,"main",4,"Header row","Included","violet")
	D SUMRULE^MIOUIEXP(.TCTX,"main",1,"File naming","claims_review_{{date}}.csv")
	D SUMRULE^MIOUIEXP(.TCTX,"main",2,"Quote mode","Minimal quoting")
	D SUMRULE^MIOUIEXP(.TCTX,"main",3,"Empty values","Leave blank")
	D CHKINIT^MIOUIEXP(.TCTX,"fieldCatalog","Field catalog","Choose the export fields operators need without leaving the SSR editor flow.")
	D CHKITEM^MIOUIEXP(.TCTX,"fieldCatalog",1,"claim_id","Claim ID","Stable claim-level identifier used by downstream QA sheets.",1)
	D CHKITEM^MIOUIEXP(.TCTX,"fieldCatalog",2,"patient_last","Patient last name","Useful for operator review and spreadsheet grouping.",1)
	D CHKITEM^MIOUIEXP(.TCTX,"fieldCatalog",3,"date_of_service","Date of service","High-value billing field for daily reconciliation.",1)
	D CHKITEM^MIOUIEXP(.TCTX,"fieldCatalog",4,"total_charge","Total charge","Include the summed billed charge for quick balance checks.",1)
	D CHKITEM^MIOUIEXP(.TCTX,"fieldCatalog",5,"payer_name","Payer name","Helpful for payer-segmented work queues.",0)
	D CHKITEM^MIOUIEXP(.TCTX,"fieldCatalog",6,"claim_frequency","Claim frequency","Optional field for advanced claim audit exports.",0)
	D CHKFINAL^MIOUIEXP(.TCTX,"fieldCatalog")
	D ORDINIT^MIOUIEXP(.TCTX,"selectedFields","Selected field order","Explicit row order keeps export columns predictable and easy to test.")
	D ORDITEM^MIOUIEXP(.TCTX,"selectedFields",1,"Claim ID","claim_id")
	D ORDITEM^MIOUIEXP(.TCTX,"selectedFields",2,"Patient last name","patient_last")
	D ORDITEM^MIOUIEXP(.TCTX,"selectedFields",3,"Date of service","date_of_service")
	D ORDITEM^MIOUIEXP(.TCTX,"selectedFields",4,"Total charge","total_charge")
	D ORDFINAL^MIOUIEXP(.TCTX,"selectedFields")
	D INIT^MIOUIFORM(.TCTX,"naming","Naming rules","Keep export naming stable for local installs, automation folders, and audit review.","/mioui/export","post")
	D FIELD^MIOUIFORM(.TCTX,"naming",1,"text","prefix","File prefix","claims_review","Short prefix that stays stable across environments.","","")
	D FIELD^MIOUIFORM(.TCTX,"naming",2,"select","dateToken","Date token","yyyymmdd","Append a date token to every export filename.","","")
	D OPTION^MIOUIFORM(.TCTX,"naming",2,1,"yyyymmdd","YYYYMMDD",1)
	D OPTION^MIOUIFORM(.TCTX,"naming",2,2,"iso8601","ISO 8601",0)
	D OPTION^MIOUIFORM(.TCTX,"naming",2,3,"none","No date token",0)
	D ACTION^MIOUIFORM(.TCTX,"naming",1,"Apply naming rule","submit","primary")
	D FINAL^MIOUIFORM(.TCTX,"naming")
	D FOOTINIT^MIOUIEXP(.TCTX,"profile","Sticky actions","Keep primary actions visible while operators scan selected fields and naming rules.")
	D FOOTACT^MIOUIEXP(.TCTX,"profile",1,"Save profile","/mioui/export?save=1","primary-button")
	D FOOTACT^MIOUIEXP(.TCTX,"profile",2,"Preview sample","/mioui/export?preview=1","quick-button")
	D FOOTACT^MIOUIEXP(.TCTX,"profile",3,"Cancel","/mioui/forms","ghost-button")
	Q
	;
BUILDWORKX(CONF,REQ,CTX,TCTX)
	D BASE^MIOUICTX(.TCTX)
	D APPLY^MIOUITHEME(.CONF,.TCTX)
	D PAGE^MIOUICTX(.TCTX,"MIOUI / Workflows","Workflow polish","Reusable first-run and file-staging surfaces for dense SSR workflow applications.","Workflow surfaces")
	D ONBINIT^MIOUIWF(.TCTX,"firstRun","First-run onboarding","Guide new operators through setup, preview, and publish without leaving the SSR flow.","Continue setup","/mioui/workflows?step=2","Skip for now","/mioui")
	D ONBSTEP^MIOUIWF(.TCTX,"firstRun",1,"Connect input folders","Point the workspace at a local or mapped folder where inbound files arrive.","complete")
	D ONBSTEP^MIOUIWF(.TCTX,"firstRun",2,"Review preview settings","Confirm claim preview, line preview, and export profile defaults before first use.","current")
	D ONBSTEP^MIOUIWF(.TCTX,"firstRun",3,"Publish a sample batch","Create canonical artifacts and verify naming, diagnostics, and audit outputs.","queued")
	D ONBSTEP^MIOUIWF(.TCTX,"firstRun",4,"Invite operators","Share a consistent workflow once the first local run looks correct.","queued")
	D ONBFINAL^MIOUIWF(.TCTX,"firstRun")
	D CONFIRM^MIOUIWF(.TCTX,"publish","Publish staged files","Publishing will write canonical artifacts, update audit history, and expose downloads to operators.","amber","Publish artifacts","/mioui/workflows?publish=1","Cancel","/mioui/workflows")
	D DROPINIT^MIOUIWF(.TCTX,"staging","File staging","Drop files here or browse a local folder to stage a batch for preview.","837, 835, CSV, TXT","Files remain local until the operator confirms publish.")
	D DROPFILE^MIOUIWF(.TCTX,"staging",1,"alpha-claim-batch.837","148 KB","Ready","emerald")
	D DROPFILE^MIOUIWF(.TCTX,"staging",2,"secondary-review.csv","42 KB","Needs review","amber")
	D DROPFILE^MIOUIWF(.TCTX,"staging",3,"payer-notes.txt","4 KB","Ready","sky")
	D DROPFINAL^MIOUIWF(.TCTX,"staging")
	D STEP^MIOUICTX(.TCTX,1,"Stage","Collect files into a stable batch before any validation or export work begins.","complete")
	D STEP^MIOUICTX(.TCTX,2,"Preview","Inspect claim rows, service lines, diagnostics, and output rules.","current")
	D STEP^MIOUICTX(.TCTX,3,"Confirm","Review publish intent and make destructive actions explicit.","queued")
	D STEP^MIOUICTX(.TCTX,4,"Publish","Write artifacts and expose the final manifest for download and audit.","queued")
	D STEPNOTE^MIOUIWF(.TCTX,1,"Dropzone state should stay visible while operators scan incoming files.","View staging","/mioui/workflows#staging")
	D STEPNOTE^MIOUIWF(.TCTX,2,"Preview keeps the operator in context without hiding diagnostics.","Open preview","/mioui/billing")
	D STEPNOTE^MIOUIWF(.TCTX,3,"Every publish path should include a confirmation surface.","Open confirm dialog","/mioui/workflows#publish")
	D STEPNOTE^MIOUIWF(.TCTX,4,"Final publish should leave a clear artifact manifest and audit trail.","Review artifacts","/mioui/billing#artifacts")
	D STEPFINAL^MIOUIWF(.TCTX)
	D ALERT^MIOUICTX(.TCTX,1,"sky","Workflow note","First-run flows should stay short, numbered, and explicit.")
	D ALERT^MIOUICTX(.TCTX,2,"amber","Confirmation note","Destructive or publish actions should always explain what will happen next.")
	Q
	;
	;
BUILDOPS(CONF,REQ,CTX,TCTX)
	D BASE^MIOUICTX(.TCTX)
	D APPLY^MIOUITHEME(.CONF,.TCTX)
	D PAGE^MIOUICTX(.TCTX,"MIOUI / Operators","Dense operator ergonomics","Saved views, column chooser, split detail panels, activity feeds, and shell framing for high-volume list/detail work.","Operator tools")
	D PHEADER^MIOUIOPS(.TCTX,"main","Dense operator workflows","Operator workspace","Persist scanning preferences, keep selected-record detail in view, and reduce context switches on high-volume review screens.")
	D PHEADMETA^MIOUIOPS(.TCTX,"main",1,"Queue","18 queued","sky")
	D PHEADMETA^MIOUIOPS(.TCTX,"main",2,"Ready","12 publishable","emerald")
	D PHEADMETA^MIOUIOPS(.TCTX,"main",3,"Attention","3 warnings","amber")
	D PHEADACT^MIOUIOPS(.TCTX,"main",1,"Open billing preview","/mioui/billing","primary-button")
	D PHEADACT^MIOUIOPS(.TCTX,"main",2,"Open export profile","/mioui/export","quick-button")
	D SUBINIT^MIOUIOPS(.TCTX,"main","Queue health")
	D SUBITEM^MIOUIOPS(.TCTX,"main",1,"Queues","/mioui/operators#queues",1)
	D SUBITEM^MIOUIOPS(.TCTX,"main",2,"Selected detail","/mioui/operators#detail",0)
	D SUBITEM^MIOUIOPS(.TCTX,"main",3,"Activity","/mioui/operators#activity",0)
	D SUBFINAL^MIOUIOPS(.TCTX,"main")
	D VIEWSINIT^MIOUIOPS(.TCTX,"main","Saved views","Server-shaped presets help operators switch between dense worklists without rebuilding the same filters every time.")
	D VIEW^MIOUIOPS(.TCTX,"main",1,"My preview queue","/mioui/operators?view=preview",1,12)
	D VIEW^MIOUIOPS(.TCTX,"main",2,"Needs review","/mioui/operators?view=review",0,5)
	D VIEW^MIOUIOPS(.TCTX,"main",3,"Published today","/mioui/operators?view=published",0,29)
	D VIEWSFINAL^MIOUIOPS(.TCTX,"main")
	D CHINIT^MIOUIOPS(.TCTX,"main","Visible columns","Choose only the fields needed for the current review pass and keep wide datasets readable.")
	D CHITEM^MIOUIOPS(.TCTX,"main",1,"Claim","Primary claim identifier",1)
	D CHITEM^MIOUIOPS(.TCTX,"main",2,"Date of service","Operator scan anchor",1)
	D CHITEM^MIOUIOPS(.TCTX,"main",3,"Payer","Top-level routing context",1)
	D CHITEM^MIOUIOPS(.TCTX,"main",4,"Subscriber","Useful for mismatch review",0)
	D CHITEM^MIOUIOPS(.TCTX,"main",5,"Total charge","High-value scan field",1)
	D CHFINAL^MIOUIOPS(.TCTX,"main")
	D SPLITINIT^MIOUIOPS(.TCTX,"main","Split detail panel","Keep a dense list on the left and the selected claim summary on the right.","Selected claim")
	D SPLITSUM^MIOUIOPS(.TCTX,"main",1,"Claim","CLM-1001")
	D SPLITSUM^MIOUIOPS(.TCTX,"main",2,"Status","Previewed")
	D SPLITSUM^MIOUIOPS(.TCTX,"main",3,"Diagnostics","2 warnings")
	D SPLITFIELD^MIOUIOPS(.TCTX,"main",1,"Date of service","2026-03-12")
	D SPLITFIELD^MIOUIOPS(.TCTX,"main",2,"Procedure","99213")
	D SPLITFIELD^MIOUIOPS(.TCTX,"main",3,"Total charge","$125.00")
	D SPLITFIELD^MIOUIOPS(.TCTX,"main",4,"Payer","ACME HEALTH")
	D SPLITFINAL^MIOUIOPS(.TCTX,"main")
	D FEEDINIT^MIOUIOPS(.TCTX,"main","Operator activity","Compact event stream for claim review, publish, and audit actions.")
	D FEEDITEM^MIOUIOPS(.TCTX,"main",1,"08:24","View saved","My preview queue selected for morning pass.","sky")
	D FEEDITEM^MIOUIOPS(.TCTX,"main",2,"08:29","Claim opened","CLM-1001 moved into the split detail panel.","emerald")
	D FEEDITEM^MIOUIOPS(.TCTX,"main",3,"08:33","Warning reviewed","SV201 warning acknowledged before publish.","amber")
	D FEEDFINAL^MIOUIOPS(.TCTX,"main")
	Q
	;
	;
	;
	;
BUILDOPSX(CONF,REQ,CTX,TCTX)
	D BASE^MIOUICTX(.TCTX)
	D APPLY^MIOUITHEME(.CONF,.TCTX)
	D PAGE^MIOUICTX(.TCTX,"MIOUI / Operators","Dense operator ergonomics","Saved views, column chooser, split detail panels, activity feeds, and shell framing for high-volume list/detail work.","Operator tools")
	D PHEADER^MIOUIOPS(.TCTX,"main","Dense operator workflows","Operator workspace","Persist scanning preferences, keep selected-record detail in view, and reduce context switches on high-volume review screens.")
	D PHEADMETA^MIOUIOPS(.TCTX,"main",1,"Queue","18 queued","sky")
	D PHEADMETA^MIOUIOPS(.TCTX,"main",2,"Ready","12 publishable","emerald")
	D PHEADMETA^MIOUIOPS(.TCTX,"main",3,"Attention","3 warnings","amber")
	D PHEADACT^MIOUIOPS(.TCTX,"main",1,"Open billing preview","/mioui/billing","primary-button")
	D PHEADACT^MIOUIOPS(.TCTX,"main",2,"Open export profile","/mioui/export","quick-button")
	D SUBINIT^MIOUIOPS(.TCTX,"main","Queue health")
	D SUBITEM^MIOUIOPS(.TCTX,"main",1,"Queues","/mioui/operators#queues",1)
	D SUBITEM^MIOUIOPS(.TCTX,"main",2,"Selected detail","/mioui/operators#detail",0)
	D SUBITEM^MIOUIOPS(.TCTX,"main",3,"Activity","/mioui/operators#activity",0)
	D SUBFINAL^MIOUIOPS(.TCTX,"main")
	D VIEWSINIT^MIOUIOPS(.TCTX,"main","Saved views","Server-shaped presets help operators switch between dense worklists without rebuilding the same filters every time.")
	D VIEW^MIOUIOPS(.TCTX,"main",1,"My preview queue","/mioui/operators?view=preview",1,12)
	D VIEW^MIOUIOPS(.TCTX,"main",2,"Needs review","/mioui/operators?view=review",0,5)
	D VIEW^MIOUIOPS(.TCTX,"main",3,"Published today","/mioui/operators?view=published",0,29)
	D VIEWSFINAL^MIOUIOPS(.TCTX,"main")
	D CHINIT^MIOUIOPS(.TCTX,"main","Visible columns","Choose only the fields needed for the current review pass and keep wide datasets readable.")
	D CHITEM^MIOUIOPS(.TCTX,"main",1,"Claim","Primary claim identifier",1)
	D CHITEM^MIOUIOPS(.TCTX,"main",2,"Date of service","Operator scan anchor",1)
	D CHITEM^MIOUIOPS(.TCTX,"main",3,"Payer","Top-level routing context",1)
	D CHITEM^MIOUIOPS(.TCTX,"main",4,"Subscriber","Useful for mismatch review",0)
	D CHITEM^MIOUIOPS(.TCTX,"main",5,"Total charge","High-value scan field",1)
	D CHFINAL^MIOUIOPS(.TCTX,"main")
	D SPLITINIT^MIOUIOPS(.TCTX,"main","Split detail panel","Keep a dense list on the left and the selected claim summary on the right.","Selected claim")
	D SPLITSUM^MIOUIOPS(.TCTX,"main",1,"Claim","CLM-1001")
	D SPLITSUM^MIOUIOPS(.TCTX,"main",2,"Status","Previewed")
	D SPLITSUM^MIOUIOPS(.TCTX,"main",3,"Diagnostics","2 warnings")
	D SPLITFIELD^MIOUIOPS(.TCTX,"main",1,"Date of service","2026-03-12")
	D SPLITFIELD^MIOUIOPS(.TCTX,"main",2,"Procedure","99213")
	D SPLITFIELD^MIOUIOPS(.TCTX,"main",3,"Total charge","$125.00")
	D SPLITFIELD^MIOUIOPS(.TCTX,"main",4,"Payer","ACME HEALTH")
	D SPLITFINAL^MIOUIOPS(.TCTX,"main")
	D FEEDINIT^MIOUIOPS(.TCTX,"main","Operator activity","Compact event stream for claim review, publish, and audit actions.")
	D FEEDITEM^MIOUIOPS(.TCTX,"main",1,"08:24","View saved","My preview queue selected for morning pass.","sky")
	D FEEDITEM^MIOUIOPS(.TCTX,"main",2,"08:29","Claim opened","CLM-1001 moved into the split detail panel.","emerald")
	D FEEDITEM^MIOUIOPS(.TCTX,"main",3,"08:33","Warning reviewed","SV201 warning acknowledged before publish.","amber")
	D FEEDFINAL^MIOUIOPS(.TCTX,"main")
	Q
	;
	;
	;
	;
BUILDCODE(CONF,REQ,CTX,TCTX)
	D BASE^MIOUICTX(.TCTX)
	D APPLY^MIOUITHEME(.CONF,.TCTX)
	D ACT^MIOUICTX(.TCTX,"tables")
	D PAGE^MIOUICTX(.TCTX,"MIOUI / Code menus","Code menu variants","Reusable SSR code-menu surfaces for CRUD-heavy setup tables, payer mappings, editor variations, and governed maintenance workflows.","Code menu lab")
	S TCTX("pageTitle")="Code menu variants"
	S TCTX("pageIntro")="Typical CRUD-heavy code menus for billing and operator software, including search, ordering, add/edit/delete actions, custom fields, mappings, effective dating, import staging, inline editing, side-drawer forms, compare-and-merge review, and approval queues."
	S TCTX("heroCallback")="openCodeMenuStudio"
	S TCTX("codeStat",1,"label")="Active code sets"
	S TCTX("codeStat",1,"value")=18
	S TCTX("codeStat",2,"label")="Custom fields"
	S TCTX("codeStat",2,"value")=27
	S TCTX("codeStat",3,"label")="Mapped payers"
	S TCTX("codeStat",3,"value")=9
	S TCTX("codeStat",4,"label")="Pending changes"
	S TCTX("codeStat",4,"value")=6
	S TCTX("codeStat",5,"label")="Future versions"
	S TCTX("codeStat",5,"value")=4
	S TCTX("codeStat",6,"label")="Staged imports"
	S TCTX("codeStat",6,"value")=2
	S TCTX("codeStat",7,"label")="Draft edits"
	S TCTX("codeStat",7,"value")=11
	S TCTX("codeStat",8,"label")="Approval queue"
	S TCTX("codeStat",8,"value")=5
	S TCTX("callback",1,"token")="addCodeRow"
	S TCTX("callback",2,"token")="editSelectedCode"
	S TCTX("callback",3,"token")="deleteSelectedCodes"
	S TCTX("callback",4,"token")="searchCodeCatalog"
	S TCTX("callback",5,"token")="reorderCodeSet"
	S TCTX("callback",6,"token")="saveCodeCustomFields"
	S TCTX("callback",7,"token")="openCodeChangeHistory"
	S TCTX("callback",8,"token")="exportCodeMenuView"
	S TCTX("callback",9,"token")="scheduleCodeEffectiveDate"
	S TCTX("callback",10,"token")="publishFutureCodeVersion"
	S TCTX("callback",11,"token")="saveCodeDependencyRules"
	S TCTX("callback",12,"token")="previewDeleteImpact"
	S TCTX("callback",13,"token")="archiveRetiredCodes"
	S TCTX("callback",14,"token")="importCodeSetSpreadsheet"
	S TCTX("callback",15,"token")="validateImportedCodeRows"
	S TCTX("callback",16,"token")="commitImportedCodes"
	S TCTX("callback",17,"token")="openInlineCodeEditor"
	S TCTX("callback",18,"token")="saveInlineCodeRow"
	S TCTX("callback",19,"token")="openCodeSideDrawer"
	S TCTX("callback",20,"token")="createCodeMenuEntry"
	S TCTX("callback",21,"token")="compareIncomingCodeSet"
	S TCTX("callback",22,"token")="mergeSelectedCodeDiffs"
	S TCTX("callback",23,"token")="submitCodeApprovalBatch"
	S TCTX("callback",24,"token")="approveCodeChangeSet"
	S TCTX("callback",25,"token")="rejectCodeChangeSet"
	S TCTX("master","title")="Master catalog"
	S TCTX("master","desc")="Flat code-list view for frequent maintenance with search, ordering, and bulk actions."
	S TCTX("master","search")="Search reason code, modifier, queue, or status"
	S TCTX("master","order")="Label A-Z"
	S TCTX("master","empty")="No codes matched the current search."
	S TCTX("master","action","add")="addCodeRow"
	S TCTX("master","action","edit")="editSelectedCode"
	S TCTX("master","action","delete")="deleteSelectedCodes"
	S TCTX("master","action","export")="exportCodeMenuView"
	S TCTX("master","row",1,"code")="ARC-01"
	S TCTX("master","row",1,"label")="Appeal required"
	S TCTX("master","row",1,"type")="Follow-up"
	S TCTX("master","row",1,"status")="Active"
	S TCTX("master","row",1,"order")="010"
	S TCTX("master","row",1,"tone")="emerald"
	S TCTX("master","row",2,"code")="ELG-12"
	S TCTX("master","row",2,"label")="Eligibility pending"
	S TCTX("master","row",2,"type")="Queue"
	S TCTX("master","row",2,"status")="Review"
	S TCTX("master","row",2,"order")="020"
	S TCTX("master","row",2,"tone")="amber"
	S TCTX("master","row",3,"code")="MCD-77"
	S TCTX("master","row",3,"label")="Medicaid crossover"
	S TCTX("master","row",3,"type")="Payer"
	S TCTX("master","row",3,"status")="Inactive"
	S TCTX("master","row",3,"order")="090"
	S TCTX("master","row",3,"tone")="rose"
	S TCTX("hier","title")="Hierarchy control"
	S TCTX("hier","desc")="Parent-child code structures for denial families, routing groups, and staged escalation menus."
	S TCTX("hier","action","add")="addCodeRow"
	S TCTX("hier","action","reorder")="reorderCodeSet"
	S TCTX("hier","group",1,"name")="Denial family"
	S TCTX("hier","group",1,"item",1,"label")="Authorization"
	S TCTX("hier","group",1,"item",1,"meta")="AUTH-100 / order 010"
	S TCTX("hier","group",1,"item",2,"label")="Medical necessity"
	S TCTX("hier","group",1,"item",2,"meta")="MED-210 / order 020"
	S TCTX("hier","group",2,"name")="Route bucket"
	S TCTX("hier","group",2,"item",1,"label")="Collector queue"
	S TCTX("hier","group",2,"item",1,"meta")="COL-01 / order 030"
	S TCTX("hier","group",2,"item",2,"label")="QA hold"
	S TCTX("hier","group",2,"item",2,"meta")="QA-07 / order 040"
	S TCTX("hier","group",3,"name")="Escalation stage"
	S TCTX("hier","group",3,"item",1,"label")="Supervisor review"
	S TCTX("hier","group",3,"item",1,"meta")="SUP-01 / order 050"
	S TCTX("hier","group",3,"item",2,"label")="Manager approval"
	S TCTX("hier","group",3,"item",2,"meta")="MGR-02 / order 060"
	S TCTX("cross","title")="Crosswalk workspace"
	S TCTX("cross","desc")="Local-to-payer mappings with effective dates and conflict cues."
	S TCTX("cross","action","add")="addCodeRow"
	S TCTX("cross","action","edit")="editSelectedCode"
	S TCTX("cross","action","delete")="deleteSelectedCodes"
	S TCTX("cross","row",1,"local")="FUP-ELIG"
	S TCTX("cross","row",1,"external")="271-PEND"
	S TCTX("cross","row",1,"payer")="Apex Health"
	S TCTX("cross","row",1,"effective")="2026-01-01"
	S TCTX("cross","row",1,"status")="Mapped"
	S TCTX("cross","row",1,"tone")="emerald"
	S TCTX("cross","row",2,"local")="FUP-AUTH"
	S TCTX("cross","row",2,"external")="AUTH-REQ"
	S TCTX("cross","row",2,"payer")="Ridge Admin"
	S TCTX("cross","row",2,"effective")="2026-02-10"
	S TCTX("cross","row",2,"status")="Review"
	S TCTX("cross","row",2,"tone")="amber"
	S TCTX("cross","row",3,"local")="FUP-COB"
	S TCTX("cross","row",3,"external")=""
	S TCTX("cross","row",3,"payer")="Summit Plan"
	S TCTX("cross","row",3,"effective")=""
	S TCTX("cross","row",3,"status")="Missing"
	S TCTX("cross","row",3,"tone")="rose"
	S TCTX("custom","title")="Custom field studio"
	S TCTX("custom","desc")="Manage extra fields that appear beside the core code columns without rewriting the base menu."
	S TCTX("custom","action","save")="saveCodeCustomFields"
	S TCTX("custom","action","search")="searchCodeCatalog"
	S TCTX("custom","field",1,"name")="requires_note"
	S TCTX("custom","field",1,"type")="toggle"
	S TCTX("custom","field",1,"required")="Yes"
	S TCTX("custom","field",1,"list")="Visible"
	S TCTX("custom","field",1,"order")="010"
	S TCTX("custom","field",2,"name")="aging_bucket"
	S TCTX("custom","field",2,"type")="select"
	S TCTX("custom","field",2,"required")="No"
	S TCTX("custom","field",2,"list")="Visible"
	S TCTX("custom","field",2,"order")="020"
	S TCTX("custom","field",3,"name")="owner_role"
	S TCTX("custom","field",3,"type")="text"
	S TCTX("custom","field",3,"required")="No"
	S TCTX("custom","field",3,"list")="Hidden"
	S TCTX("custom","field",3,"order")="090"
	S TCTX("effective","title")="Effective dating studio"
	S TCTX("effective","desc")="Future-date changes, superseded rows, and activation windows for fee schedules, route codes, and payer-specific menus."
	S TCTX("effective","action","schedule")="scheduleCodeEffectiveDate"
	S TCTX("effective","action","publish")="publishFutureCodeVersion"
	S TCTX("effective","action","archive")="archiveRetiredCodes"
	S TCTX("effective","row",1,"code")="ARC-01"
	S TCTX("effective","row",1,"version")="v3"
	S TCTX("effective","row",1,"window")="2026-04-01 → open"
	S TCTX("effective","row",1,"state")="Scheduled"
	S TCTX("effective","row",2,"code")="ELG-12"
	S TCTX("effective","row",2,"version")="v2"
	S TCTX("effective","row",2,"window")="2026-03-01 → 2026-03-31"
	S TCTX("effective","row",2,"state")="Active"
	S TCTX("effective","row",3,"code")="MCD-77"
	S TCTX("effective","row",3,"version")="v1"
	S TCTX("effective","row",3,"window")="2025-11-01 → 2026-02-29"
	S TCTX("effective","row",3,"state")="Superseded"
	S TCTX("depend","title")="Dependency rules"
	S TCTX("depend","desc")="Conditional field logic for companion codes, required notes, owner rules, and mutually exclusive status combinations."
	S TCTX("depend","action","save")="saveCodeDependencyRules"
	S TCTX("depend","action","preview")="previewDeleteImpact"
	S TCTX("depend","rule",1,"name")="Requires note when ARC-01 is active"
	S TCTX("depend","rule",1,"if")="status=Active and code=ARC-01"
	S TCTX("depend","rule",1,"then")="requires_note=Yes"
	S TCTX("depend","rule",2,"name")="Owner role hidden for payer-neutral rows"
	S TCTX("depend","rule",2,"if")="type=Follow-up and payer=*"
	S TCTX("depend","rule",2,"then")="owner_role=Hidden"
	S TCTX("depend","rule",3,"name")="QA hold blocks collector route"
	S TCTX("depend","rule",3,"if")="route=QA-07"
	S TCTX("depend","rule",3,"then")="collector_queue=Disabled"
	S TCTX("import","title")="Import staging workspace"
	S TCTX("import","desc")="Spreadsheet intake variation for bulk code maintenance with row validation, duplicate detection, and controlled commit."
	S TCTX("import","action","import")="importCodeSetSpreadsheet"
	S TCTX("import","action","validate")="validateImportedCodeRows"
	S TCTX("import","action","commit")="commitImportedCodes"
	S TCTX("import","batch",1,"name")="payer_reason_codes_april.xlsx"
	S TCTX("import","batch",1,"rows")=144
	S TCTX("import","batch",1,"issues")="3 warnings / 1 duplicate"
	S TCTX("import","batch",1,"state")="Ready for QA"
	S TCTX("import","batch",2,"name")="collector_routes_refresh.csv"
	S TCTX("import","batch",2,"rows")=37
	S TCTX("import","batch",2,"issues")="0 warnings"
	S TCTX("import","batch",2,"state")="Validated"
	S TCTX("retire","title")="Retirement and delete control"
	S TCTX("retire","desc")="Governed archive and delete variation with downstream impact preview before hard removal."
	S TCTX("retire","action","preview")="previewDeleteImpact"
	S TCTX("retire","action","archive")="archiveRetiredCodes"
	S TCTX("retire","action","delete")="deleteSelectedCodes"
	S TCTX("retire","impact",1,"target")="MCD-77"
	S TCTX("retire","impact",1,"refs")="7 payer mappings"
	S TCTX("retire","impact",1,"resolution")="Archive then remap"
	S TCTX("retire","impact",2,"target")="QA-07"
	S TCTX("retire","impact",2,"refs")="2 escalation branches"
	S TCTX("retire","impact",2,"resolution")="Replace hierarchy parent"
	S TCTX("inline","title")="Inline row editor"
	S TCTX("inline","desc")="Fast spreadsheet-like editing variation for high-volume code maintenance where operators change one field at a time without leaving the table."
	S TCTX("inline","action","open")="openInlineCodeEditor"
	S TCTX("inline","action","save")="saveInlineCodeRow"
	S TCTX("inline","action","compare")="compareIncomingCodeSet"
	S TCTX("inline","row",1,"code")="ARC-01"
	S TCTX("inline","row",1,"field")="label"
	S TCTX("inline","row",1,"before")="Appeal required"
	S TCTX("inline","row",1,"after")="Appeal and review required"
	S TCTX("inline","row",1,"state")="Draft"
	S TCTX("inline","row",2,"code")="ELG-12"
	S TCTX("inline","row",2,"field")="owner_role"
	S TCTX("inline","row",2,"before")=""
	S TCTX("inline","row",2,"after")="collector"
	S TCTX("inline","row",2,"state")="Pending"
	S TCTX("inline","row",3,"code")="QA-07"
	S TCTX("inline","row",3,"field")="status"
	S TCTX("inline","row",3,"before")="Review"
	S TCTX("inline","row",3,"after")="Active"
	S TCTX("inline","row",3,"state")="Ready"
	S TCTX("drawer","title")="Side-drawer editor"
	S TCTX("drawer","desc")="Add and edit variation that keeps the menu visible while operators fill a dense side drawer with core fields, custom fields, and governance flags."
	S TCTX("drawer","action","open")="openCodeSideDrawer"
	S TCTX("drawer","action","create")="createCodeMenuEntry"
	S TCTX("drawer","action","delete")="deleteSelectedCodes"
	S TCTX("drawer","field",1,"label")="Code"
	S TCTX("drawer","field",1,"value")="AUTH-310"
	S TCTX("drawer","field",2,"label")="Label"
	S TCTX("drawer","field",2,"value")="Authorization escalation"
	S TCTX("drawer","field",3,"label")="Type"
	S TCTX("drawer","field",3,"value")="Follow-up"
	S TCTX("drawer","field",4,"label")="Owner role"
	S TCTX("drawer","field",4,"value")="supervisor"
	S TCTX("drawer","field",5,"label")="Requires note"
	S TCTX("drawer","field",5,"value")="Yes"
	S TCTX("drawer","field",6,"label")="Approval"
	S TCTX("drawer","field",6,"value")="Manager required"
	S TCTX("compare","title")="Compare and merge review"
	S TCTX("compare","desc")="Side-by-side diff variation for vendor imports, payer refreshes, and environment promotion where operators merge only selected changes."
	S TCTX("compare","action","compare")="compareIncomingCodeSet"
	S TCTX("compare","action","merge")="mergeSelectedCodeDiffs"
	S TCTX("compare","action","submit")="submitCodeApprovalBatch"
	S TCTX("compare","row",1,"code")="ELG-12"
	S TCTX("compare","row",1,"current")="Eligibility pending"
	S TCTX("compare","row",1,"incoming")="Eligibility pending / portal"
	S TCTX("compare","row",1,"decision")="Merge"
	S TCTX("compare","row",2,"code")="MCD-77"
	S TCTX("compare","row",2,"current")="Medicaid crossover"
	S TCTX("compare","row",2,"incoming")="Medicaid crossover legacy"
	S TCTX("compare","row",2,"decision")="Hold"
	S TCTX("compare","row",3,"code")="QA-07"
	S TCTX("compare","row",3,"current")="QA hold"
	S TCTX("compare","row",3,"incoming")="QA hold / payer mismatch"
	S TCTX("compare","row",3,"decision")="Review"
	S TCTX("approve","title")="Approval queue"
	S TCTX("approve","desc")="Governance variation for promoted code changes that need supervisor or manager sign-off before they become active."
	S TCTX("approve","action","submit")="submitCodeApprovalBatch"
	S TCTX("approve","action","approve")="approveCodeChangeSet"
	S TCTX("approve","action","reject")="rejectCodeChangeSet"
	S TCTX("approve","item",1,"batch")="APR-2026-0317-A"
	S TCTX("approve","item",1,"scope")="4 route codes / 2 custom fields"
	S TCTX("approve","item",1,"owner")="ops.manager"
	S TCTX("approve","item",1,"state")="Awaiting approval"
	S TCTX("approve","item",2,"batch")="APR-2026-0317-B"
	S TCTX("approve","item",2,"scope")="1 payer crosswalk / 3 labels"
	S TCTX("approve","item",2,"owner")="qa.supervisor"
	S TCTX("approve","item",2,"state")="Needs revision"
	S TCTX("approve","item",3,"batch")="APR-2026-0317-C"
	S TCTX("approve","item",3,"scope")="Vendor import merge set"
	S TCTX("approve","item",3,"owner")="collector.lead"
	S TCTX("approve","item",3,"state")="Ready to submit"
	S TCTX("audit","title")="Change history"
	S TCTX("audit","desc")="Add/edit/delete review log for code maintenance with actor, reason, and recovery actions."
	S TCTX("audit","action","open")="openCodeChangeHistory"
	S TCTX("audit","action","restore")="editSelectedCode"
	S TCTX("audit","entry",1,"when")="2026-03-17 09:14"
	S TCTX("audit","entry",1,"actor")="qa.supervisor"
	S TCTX("audit","entry",1,"verb")="Deleted"
	S TCTX("audit","entry",1,"target")="MCD-77"
	S TCTX("audit","entry",1,"reason")="Merged into payer-neutral follow-up code"
	S TCTX("audit","entry",2,"when")="2026-03-17 08:52"
	S TCTX("audit","entry",2,"actor")="ops.manager"
	S TCTX("audit","entry",2,"verb")="Edited"
	S TCTX("audit","entry",2,"target")="ELG-12"
	S TCTX("audit","entry",2,"reason")="Updated routing priority and note requirement"
	S TCTX("audit","entry",3,"when")="2026-03-17 08:30"
	S TCTX("audit","entry",3,"actor")="collector.lead"
	S TCTX("audit","entry",3,"verb")="Added"
	S TCTX("audit","entry",3,"target")="ARC-01"
	S TCTX("audit","entry",3,"reason")="New appeal queue bucket for manual review"
	S TCTX("matrix","title")="Variant matrix"
	S TCTX("matrix","row",1,"label")="Master catalog"
	S TCTX("matrix","row",1,"search")="Yes"
	S TCTX("matrix","row",1,"order")="Yes"
	S TCTX("matrix","row",1,"crud")="Full"
	S TCTX("matrix","row",1,"custom")="Optional"
	S TCTX("matrix","row",2,"label")="Hierarchy control"
	S TCTX("matrix","row",2,"search")="Scoped"
	S TCTX("matrix","row",2,"order")="Nested"
	S TCTX("matrix","row",2,"crud")="Full"
	S TCTX("matrix","row",2,"custom")="Optional"
	S TCTX("matrix","row",3,"label")="Crosswalk workspace"
	S TCTX("matrix","row",3,"search")="Yes"
	S TCTX("matrix","row",3,"order")="Effective date"
	S TCTX("matrix","row",3,"crud")="Map CRUD"
	S TCTX("matrix","row",3,"custom")="No"
	S TCTX("matrix","row",4,"label")="Custom field studio"
	S TCTX("matrix","row",4,"search")="Yes"
	S TCTX("matrix","row",4,"order")="Field order"
	S TCTX("matrix","row",4,"crud")="Field CRUD"
	S TCTX("matrix","row",4,"custom")="Primary"
	S TCTX("matrix","row",5,"label")="Effective dating studio"
	S TCTX("matrix","row",5,"search")="Version"
	S TCTX("matrix","row",5,"order")="Window"
	S TCTX("matrix","row",5,"crud")="Version CRUD"
	S TCTX("matrix","row",5,"custom")="Optional"
	S TCTX("matrix","row",6,"label")="Dependency rules"
	S TCTX("matrix","row",6,"search")="Rule name"
	S TCTX("matrix","row",6,"order")="Priority"
	S TCTX("matrix","row",6,"crud")="Rule CRUD"
	S TCTX("matrix","row",6,"custom")="Derived"
	S TCTX("matrix","row",7,"label")="Import staging workspace"
	S TCTX("matrix","row",7,"search")="File/batch"
	S TCTX("matrix","row",7,"order")="Upload time"
	S TCTX("matrix","row",7,"crud")="Stage/commit"
	S TCTX("matrix","row",7,"custom")="Mapped"
	S TCTX("matrix","row",8,"label")="Retirement and delete control"
	S TCTX("matrix","row",8,"search")="Impact"
	S TCTX("matrix","row",8,"order")="Risk first"
	S TCTX("matrix","row",8,"crud")="Archive/delete"
	S TCTX("matrix","row",8,"custom")="No"
	S TCTX("matrix","row",9,"label")="Change history"
	S TCTX("matrix","row",9,"search")="Actor/date"
	S TCTX("matrix","row",9,"order")="Newest first"
	S TCTX("matrix","row",9,"crud")="Restore"
	S TCTX("matrix","row",9,"custom")="No"
	S TCTX("matrix","row",10,"label")="Inline row editor"
	S TCTX("matrix","row",10,"search")="Cell focus"
	S TCTX("matrix","row",10,"order")="Grid order"
	S TCTX("matrix","row",10,"crud")="Inline edit"
	S TCTX("matrix","row",10,"custom")="Optional"
	S TCTX("matrix","row",11,"label")="Side-drawer editor"
	S TCTX("matrix","row",11,"search")="Contextual"
	S TCTX("matrix","row",11,"order")="Drawer sections"
	S TCTX("matrix","row",11,"crud")="Create/edit"
	S TCTX("matrix","row",11,"custom")="Full"
	S TCTX("matrix","row",12,"label")="Compare and merge review"
	S TCTX("matrix","row",12,"search")="Diff target"
	S TCTX("matrix","row",12,"order")="Risk first"
	S TCTX("matrix","row",12,"crud")="Merge batch"
	S TCTX("matrix","row",12,"custom")="Mapped"
	S TCTX("matrix","row",13,"label")="Approval queue"
	S TCTX("matrix","row",13,"search")="Batch/state"
	S TCTX("matrix","row",13,"order")="Oldest first"
	S TCTX("matrix","row",13,"crud")="Approve/reject"
	S TCTX("matrix","row",13,"custom")="Governed"
	Q
	;
BUILDEXPORTX(CONF,REQ,CTX,TCTX)
	D BASE^MIOUICTX(.TCTX)
	D APPLY^MIOUITHEME(.CONF,.TCTX)
	D ACT^MIOUICTX(.TCTX,"export")
	D PAGE^MIOUICTX(.TCTX,"MIOUI / Export","Export UX","Reusable field-selection and export editing surfaces for dense billing workflows.","Profile editor")
	D SUMINIT^MIOUIEXP(.TCTX,"main","Export profile summary","Compact output rules, selected-field counts, and file naming rules for CSV profile review.")
	D SUMSTAT^MIOUIEXP(.TCTX,"main",1,"Mode","Claim summary","sky")
	D SUMSTAT^MIOUIEXP(.TCTX,"main",2,"Selected fields",4,"emerald")
	D SUMSTAT^MIOUIEXP(.TCTX,"main",3,"Delimiter","Comma","amber")
	D SUMSTAT^MIOUIEXP(.TCTX,"main",4,"Header row","Included","violet")
	D SUMRULE^MIOUIEXP(.TCTX,"main",1,"File naming","claims_review_{{date}}.csv")
	D SUMRULE^MIOUIEXP(.TCTX,"main",2,"Quote mode","Minimal quoting")
	D SUMRULE^MIOUIEXP(.TCTX,"main",3,"Empty values","Leave blank")
	D CHKINIT^MIOUIEXP(.TCTX,"fieldCatalog","Field catalog","Choose the export fields operators need without leaving the SSR editor flow.")
	D CHKITEM^MIOUIEXP(.TCTX,"fieldCatalog",1,"claim_id","Claim ID","Stable claim-level identifier used by downstream QA sheets.",1)
	D CHKITEM^MIOUIEXP(.TCTX,"fieldCatalog",2,"patient_last","Patient last name","Useful for operator review and spreadsheet grouping.",1)
	D CHKITEM^MIOUIEXP(.TCTX,"fieldCatalog",3,"date_of_service","Date of service","High-value billing field for daily reconciliation.",1)
	D CHKITEM^MIOUIEXP(.TCTX,"fieldCatalog",4,"total_charge","Total charge","Include the summed billed charge for quick balance checks.",1)
	D CHKITEM^MIOUIEXP(.TCTX,"fieldCatalog",5,"payer_name","Payer name","Helpful for payer-segmented work queues.",0)
	D CHKITEM^MIOUIEXP(.TCTX,"fieldCatalog",6,"claim_frequency","Claim frequency","Optional field for advanced claim audit exports.",0)
	D CHKFINAL^MIOUIEXP(.TCTX,"fieldCatalog")
	D ORDINIT^MIOUIEXP(.TCTX,"selectedFields","Selected field order","Explicit row order keeps export columns predictable and easy to test.")
	D ORDITEM^MIOUIEXP(.TCTX,"selectedFields",1,"Claim ID","claim_id")
	D ORDITEM^MIOUIEXP(.TCTX,"selectedFields",2,"Patient last name","patient_last")
	D ORDITEM^MIOUIEXP(.TCTX,"selectedFields",3,"Date of service","date_of_service")
	D ORDITEM^MIOUIEXP(.TCTX,"selectedFields",4,"Total charge","total_charge")
	D ORDFINAL^MIOUIEXP(.TCTX,"selectedFields")
	D INIT^MIOUIFORM(.TCTX,"naming","Naming rules","Keep export naming stable for local installs, automation folders, and audit review.","/mioui/export","post")
	D FIELD^MIOUIFORM(.TCTX,"naming",1,"text","prefix","File prefix","claims_review","Short prefix that stays stable across environments.","","")
	D FIELD^MIOUIFORM(.TCTX,"naming",2,"select","dateToken","Date token","yyyymmdd","Append a date token to every export filename.","","")
	D OPTION^MIOUIFORM(.TCTX,"naming",2,1,"yyyymmdd","YYYYMMDD",1)
	D OPTION^MIOUIFORM(.TCTX,"naming",2,2,"iso8601","ISO 8601",0)
	D OPTION^MIOUIFORM(.TCTX,"naming",2,3,"none","No date token",0)
	D ACTION^MIOUIFORM(.TCTX,"naming",1,"Apply naming rule","submit","primary")
	D FINAL^MIOUIFORM(.TCTX,"naming")
	D FOOTINIT^MIOUIEXP(.TCTX,"profile","Sticky actions","Keep primary actions visible while operators scan selected fields and naming rules.")
	D FOOTACT^MIOUIEXP(.TCTX,"profile",1,"Save profile","/mioui/export?save=1","primary-button")
	D FOOTACT^MIOUIEXP(.TCTX,"profile",2,"Preview sample","/mioui/export?preview=1","quick-button")
	D FOOTACT^MIOUIEXP(.TCTX,"profile",3,"Cancel","/mioui/forms","ghost-button")
	Q
	;
BUILDBILL(CONF,REQ,CTX,TCTX)
	D BASE^MIOUICTX(.TCTX)
	D APPLY^MIOUITHEME(.CONF,.TCTX)
	D ACT^MIOUICTX(.TCTX,"billing")
	D PAGE^MIOUICTX(.TCTX,"MIOUI / Billing","Billing blueprints","Claim, line, diagnostics, and artifact patterns tailored for dense SSR review flows.","Billing adapters")
	D STAT^MIOUIPANEL(.TCTX,1,"Claims",2,"sky","")
	D STAT^MIOUIPANEL(.TCTX,2,"Lines",3,"emerald","")
	D STAT^MIOUIPANEL(.TCTX,3,"Warnings",1,"amber","")
	D STAT^MIOUIPANEL(.TCTX,4,"Errors",0,"violet","")
	D CLAIM^MIOUIBIL(.TCTX,1,"CLM-1001","JANE DOE","ALPHA HEALTH","2026-03-01","125.00","Previewed","sky")
	D CLAIM^MIOUIBIL(.TCTX,2,"CLM-1002","JOHN SMITH","BETA HEALTH","2026-03-02","88.20","Publishable","emerald")
	D INIT^MIOUITBL(.TCTX,"serviceLine","Service lines","No service line rows.")
	D COL^MIOUITBL(.TCTX,"serviceLine",1,"Claim","left")
	D COL^MIOUITBL(.TCTX,"serviceLine",2,"Line","left")
	D COL^MIOUITBL(.TCTX,"serviceLine",3,"Procedure","left")
	D COL^MIOUITBL(.TCTX,"serviceLine",4,"Date of service","left")
	D COL^MIOUITBL(.TCTX,"serviceLine",5,"Charge","right")
	D CELL^MIOUITBL(.TCTX,"serviceLine",1,1,"CLM-1001")
	D CELL^MIOUITBL(.TCTX,"serviceLine",1,2,"1")
	D CELL^MIOUITBL(.TCTX,"serviceLine",1,3,"99213")
	D CELL^MIOUITBL(.TCTX,"serviceLine",1,4,"2026-03-01")
	D CELL^MIOUITBL(.TCTX,"serviceLine",1,5,"75.00")
	D CELL^MIOUITBL(.TCTX,"serviceLine",2,1,"CLM-1001")
	D CELL^MIOUITBL(.TCTX,"serviceLine",2,2,"2")
	D CELL^MIOUITBL(.TCTX,"serviceLine",2,3,"87070")
	D CELL^MIOUITBL(.TCTX,"serviceLine",2,4,"2026-03-01")
	D CELL^MIOUITBL(.TCTX,"serviceLine",2,5,"50.00")
	D CELL^MIOUITBL(.TCTX,"serviceLine",3,1,"CLM-1002")
	D CELL^MIOUITBL(.TCTX,"serviceLine",3,2,"1")
	D CELL^MIOUITBL(.TCTX,"serviceLine",3,3,"97110")
	D CELL^MIOUITBL(.TCTX,"serviceLine",3,4,"2026-03-02")
	D CELL^MIOUITBL(.TCTX,"serviceLine",3,5,"88.20")
	D FINAL^MIOUITBL(.TCTX,"serviceLine")
	D VALSUM^MIOUIBIL(.TCTX,1,0,2,1,"Publishable","emerald")
	D DIAG^MIOUIBIL(.TCTX,"warning",1,"SV201","One line is missing a modifier but remains publishable under the current profile.","2400/SV1/03","Review payer rules before release.")
	D DIAG^MIOUIBIL(.TCTX,"info",1,"CSV001","Header row will be written because the selected profile includes column names.","profile/includeHeaders","No action needed.")
	D META^MIOUIBIL(.TCTX,1,"Profile","Claim summary")
	D META^MIOUIBIL(.TCTX,2,"Output naming","{{source_base}}-claims-{{job_id}}.csv")
	D META^MIOUIBIL(.TCTX,3,"Delimiter","Comma")
	D META^MIOUIBIL(.TCTX,4,"Headers","Included")
	D ARTMETA^MIOUIBIL(.TCTX,"canonical","Canonical artifacts","Stable output set for audit and downstream workflows.","sky")
	D ARTROW^MIOUIBIL(.TCTX,"canonical",1,"claims.csv","CSV","/efuzy/download/1/claims","csv")
	D ARTROW^MIOUIBIL(.TCTX,"canonical",2,"lines.csv","CSV","/efuzy/download/1/lines","csv")
	D ARTMETA^MIOUIBIL(.TCTX,"report","Reports","Operator-facing validation and round-trip checks.","violet")
	D ARTROW^MIOUIBIL(.TCTX,"report",1,"roundtrip-report.json","JSON","/efuzy/download/1/report","json")
	Q
	;
BUILDWORK(CONF,REQ,CTX,TCTX)
	D BASE^MIOUICTX(.TCTX)
	D APPLY^MIOUITHEME(.CONF,.TCTX)
	D PAGE^MIOUICTX(.TCTX,"MIOUI / Workflows","Workflow polish","Reusable first-run and file-staging surfaces for dense SSR workflow applications.","Workflow surfaces")
	D ONBINIT^MIOUIWF(.TCTX,"firstRun","First-run onboarding","Guide new operators through setup, preview, and publish without leaving the SSR flow.","Continue setup","/mioui/workflows?step=2","Skip for now","/mioui")
	D ONBSTEP^MIOUIWF(.TCTX,"firstRun",1,"Connect input folders","Point the workspace at a local or mapped folder where inbound files arrive.","complete")
	D ONBSTEP^MIOUIWF(.TCTX,"firstRun",2,"Review preview settings","Confirm claim preview, line preview, and export profile defaults before first use.","current")
	D ONBSTEP^MIOUIWF(.TCTX,"firstRun",3,"Publish a sample batch","Create canonical artifacts and verify naming, diagnostics, and audit outputs.","queued")
	D ONBSTEP^MIOUIWF(.TCTX,"firstRun",4,"Invite operators","Share a consistent workflow once the first local run looks correct.","queued")
	D ONBFINAL^MIOUIWF(.TCTX,"firstRun")
	D CONFIRM^MIOUIWF(.TCTX,"publish","Publish staged files","Publishing will write canonical artifacts, update audit history, and expose downloads to operators.","amber","Publish artifacts","/mioui/workflows?publish=1","Cancel","/mioui/workflows")
	D DROPINIT^MIOUIWF(.TCTX,"staging","File staging","Drop files here or browse a local folder to stage a batch for preview.","837, 835, CSV, TXT","Files remain local until the operator confirms publish.")
	D DROPFILE^MIOUIWF(.TCTX,"staging",1,"alpha-claim-batch.837","148 KB","Ready","emerald")
	D DROPFILE^MIOUIWF(.TCTX,"staging",2,"secondary-review.csv","42 KB","Needs review","amber")
	D DROPFILE^MIOUIWF(.TCTX,"staging",3,"payer-notes.txt","4 KB","Ready","sky")
	D DROPFINAL^MIOUIWF(.TCTX,"staging")
	D STEP^MIOUICTX(.TCTX,1,"Stage","Collect files into a stable batch before any validation or export work begins.","complete")
	D STEP^MIOUICTX(.TCTX,2,"Preview","Inspect claim rows, service lines, diagnostics, and output rules.","current")
	D STEP^MIOUICTX(.TCTX,3,"Confirm","Review publish intent and make destructive actions explicit.","queued")
	D STEP^MIOUICTX(.TCTX,4,"Publish","Write artifacts and expose the final manifest for download and audit.","queued")
	D STEPNOTE^MIOUIWF(.TCTX,1,"Dropzone state should stay visible while operators scan incoming files.","View staging","/mioui/workflows#staging")
	D STEPNOTE^MIOUIWF(.TCTX,2,"Preview keeps the operator in context without hiding diagnostics.","Open preview","/mioui/billing")
	D STEPNOTE^MIOUIWF(.TCTX,3,"Every publish path should include a confirmation surface.","Open confirm dialog","/mioui/workflows#publish")
	D STEPNOTE^MIOUIWF(.TCTX,4,"Final publish should leave a clear artifact manifest and audit trail.","Review artifacts","/mioui/billing#artifacts")
	D STEPFINAL^MIOUIWF(.TCTX)
	D ALERT^MIOUICTX(.TCTX,1,"sky","Workflow note","First-run flows should stay short, numbered, and explicit.")
	D ALERT^MIOUICTX(.TCTX,2,"amber","Confirmation note","Destructive or publish actions should always explain what will happen next.")
	Q
	;