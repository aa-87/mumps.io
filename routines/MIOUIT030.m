MIOUIT030 ; ROI20 control-room dense layout tests
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP,ID
 S TOP='$D(FAIL),LOCAL=0
 D T001(.LOCAL)
 D T010(.LOCAL)
 D T020(.LOCAL)
 D T030(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUIT030"
 I LOCAL S FAIL=1
 Q
 ;
BASECONF(CONF)
 D CONFDEF^MIOUI(.CONF)
 D INIT^MIOUI(.CONF)
 Q
 ;
T001(FAIL)
 N CONF,REQ,CTX,TCTX
 D BASECONF(.CONF)
 D BUILD^MIOUICTR(.CONF,.REQ,.CTX,.TCTX)
 D EQ^MIOUIT000(.FAIL,"[T001][brief count]",$$COUNT^MIOUICTX($NA(TCTX("brief"))),3)
 D EQ^MIOUIT000(.FAIL,"[T001][heat count]",$$COUNT^MIOUICTX($NA(TCTX("heat"))),3)
 D EQ^MIOUIT000(.FAIL,"[T001][escal count]",$$COUNT^MIOUICTX($NA(TCTX("escal"))),3)
 D EQ^MIOUIT000(.FAIL,"[T001][exception count]",$$COUNT^MIOUICTX($NA(TCTX("exception"))),3)
 D EQ^MIOUIT000(.FAIL,"[T001][sweep count]",$$COUNT^MIOUICTX($NA(TCTX("sweep"))),3)
 D EQ^MIOUIT000(.FAIL,"[T001][footer callback]",$G(TCTX("footer","callback")),"openRouteCommandFooter")
 Q
 ;
T010(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D BASECONF(.CONF)
 D BUILD^MIOUICTR(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/mioui_control_room_layouts.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T010][render ok]",$D(ERR),0)
 D CONTAINS^MIOUIT000(.FAIL,"[T010][title]",OUT,"Control-room layouts")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][brief]",OUT,"Shift briefing ribbon")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][heat]",OUT,"Capacity heat grid")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][escal]",OUT,"Supervisor escalation stack")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][exception]",OUT,"Live exception lane")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][sweep]",OUT,"Resolution sweep board")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][footer]",OUT,"Route command footer")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][brief callback]",OUT,"openShiftCommandChecklist")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][heat callback]",OUT,"openCapacityHeatTeamB")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][escal callback]",OUT,"openEscalationAuth")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][exception callback]",OUT,"openExceptionCarrier")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][sweep callback]",OUT,"openSweepReady")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][footer callback]",OUT,"openRouteCommandFooter")
 Q
 ;
T020(FAIL)
 N CONF
 K ^MIO("ROUTE","RAW","GET","/mioui/control-room-layouts")
 D REG^MIOUICTR(.CONF)
 D EQ^MIOUIT000(.FAIL,"[T020][route target]",$G(^MIO("ROUTE","RAW","GET","/mioui/control-room-layouts")),"CTRL^MIOUICTR")
 D EQ^MIOUIT000(.FAIL,"[T020][route auth]",+$G(^MIO("ROUTE","META","GET","/mioui/control-room-layouts","authRequired")),0)
 Q
 ;
T030(FAIL)
 N REG,I,ID
 D LIST^MIOUIREG(.REG)
 S I=$$FIND^MIOUIREG(.REG,"control_room_layout_builder")
 D EQ^MIOUIT000(.FAIL,"[T030][builder status]",$G(REG(I,"status")),"implemented")
 D EQ^MIOUIT000(.FAIL,"[T030][builder phase]",$G(REG(I,"phase")),"P3")
 D EQ^MIOUIT000(.FAIL,"[T030][builder test]",$G(REG(I,"test")),"MIOUIT030")
 F ID="shift_briefing_ribbon","capacity_heat_grid","supervisor_escalation_stack","live_exception_lane","resolution_sweep_board","route_command_footer","page_control_room_layouts" D
 . S I=$$FIND^MIOUIREG(.REG,ID)
 . D EQ^MIOUIT000(.FAIL,"[T030]["_ID_" status]",$G(REG(I,"status")),"implemented")
 Q
 ;
