MIOUIT005 ; table contract tests
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP
 S TOP='$D(FAIL),LOCAL=0
 D T001(.LOCAL)
 D T010(.LOCAL)
 D T020(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUIT005"
 I LOCAL S FAIL=1
 Q
 ;
T001(FAIL)
 N TCTX
 D INIT^MIOUITBL(.TCTX,"claims","Claims","No rows")
 D COL^MIOUITBL(.TCTX,"claims",1,"Claim","left")
 D COL^MIOUITBL(.TCTX,"claims",2,"Charge","right")
 D CELL^MIOUITBL(.TCTX,"claims",1,1,"CLM-1")
 D CELL^MIOUITBL(.TCTX,"claims",1,2,"10.00")
 D ROWHREF^MIOUITBL(.TCTX,"claims",1,"/claims/1")
 D ROWBADGE^MIOUITBL(.TCTX,"claims",1,"Previewed","sky")
 D FINAL^MIOUITBL(.TCTX,"claims")
 D EQ^MIOUIT000(.FAIL,"[T001][title]",$G(TCTX("table","claims","title")),"Claims")
 D EQ^MIOUIT000(.FAIL,"[T001][rows]",+$G(TCTX("table","claims","rowCount")),1)
 D EQ^MIOUIT000(.FAIL,"[T001][align]",$G(TCTX("table","claims","col",2,"align")),"right")
 D EQ^MIOUIT000(.FAIL,"[T001][has href]",+$G(TCTX("table","claims","row",1,"hasHref")),1)
 D EQ^MIOUIT000(.FAIL,"[T001][badge]",$G(TCTX("table","claims","row",1,"badgeClass")),"badge-sky")
 Q
 ;
T010(FAIL)
 N TCTX
 D INIT^MIOUITBL(.TCTX,"audit","Audit","Empty")
 D FILTER^MIOUITBL(.TCTX,"audit",1,"ok","ok",1)
 D BULK^MIOUITBL(.TCTX,"audit","Selected",2)
 D FINAL^MIOUITBL(.TCTX,"audit")
 D EQ^MIOUIT000(.FAIL,"[T010][filter active]",+$G(TCTX("table","audit","filter",1,"isActive")),1)
 D EQ^MIOUIT000(.FAIL,"[T010][has filters]",+$G(TCTX("table","audit","hasFilters")),1)
 D EQ^MIOUIT000(.FAIL,"[T010][bulk count]",+$G(TCTX("table","audit","bulk","count")),2)
 D EQ^MIOUIT000(.FAIL,"[T010][has bulk]",+$G(TCTX("table","audit","hasBulk")),1)
 D EQ^MIOUIT000(.FAIL,"[T010][no rows]",+$G(TCTX("table","audit","hasRows")),0)
 Q
 ;
T020(FAIL)
 N TCTX
 D INIT^MIOUITBL(.TCTX,"claims","Claims","No rows")
 D TOOLBAR^MIOUITBL(.TCTX,"claims","Table tools","Summary text","jane","Search claims, patients, and payers")
 D TOOLACT^MIOUITBL(.TCTX,"claims",1,"Save view","/claims?save=1","primary-button")
 D FILTERMETA^MIOUITBL(.TCTX,"claims","Filter set","Server-shaped filters")
 D BULK^MIOUITBL(.TCTX,"claims","selected",2)
 D BULKACT^MIOUITBL(.TCTX,"claims",1,"Publish selected","/claims/publish","primary-button")
 D PAGER^MIOUITBL(.TCTX,"claims",1,25,89,"","/claims?page=2")
 D EQ^MIOUIT000(.FAIL,"[T020][toolbar]",+$G(TCTX("table","claims","hasToolbar")),1)
 D EQ^MIOUIT000(.FAIL,"[T020][toolbar action]",$G(TCTX("table","claims","toolbar","action",1,"label")),"Save view")
 D EQ^MIOUIT000(.FAIL,"[T020][filter title]",$G(TCTX("table","claims","filters","title")),"Filter set")
 D EQ^MIOUIT000(.FAIL,"[T020][bulk action]",$G(TCTX("table","claims","bulk","action",1,"label")),"Publish selected")
 D EQ^MIOUIT000(.FAIL,"[T020][pager last]",+$G(TCTX("table","claims","pager","lastPage")),4)
 D EQ^MIOUIT000(.FAIL,"[T020][pager next]",+$G(TCTX("table","claims","pager","hasNext")),1)
 D EQ^MIOUIT000(.FAIL,"[T020][pager start]",+$G(TCTX("table","claims","pager","start")),1)
 D EQ^MIOUIT000(.FAIL,"[T020][pager stop]",+$G(TCTX("table","claims","pager","stop")),25)
 Q
 ;
