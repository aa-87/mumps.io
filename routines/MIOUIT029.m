MIOUIT029 ; ROI19 multi-monitor dense layout tests
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP
 S TOP='$D(FAIL),LOCAL=0
 D T001(.LOCAL)
 D T010(.LOCAL)
 D T020(.LOCAL)
 D T030(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUIT029"
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
 D BUILD^MIOUIMMR(.CONF,.REQ,.CTX,.TCTX)
 D EQ^MIOUIT000(.FAIL,"[T001][monitor count]",$$COUNT^MIOUICTX($NA(TCTX("monitor"))),3)
 D EQ^MIOUIT000(.FAIL,"[T001][burst count]",$$COUNT^MIOUICTX($NA(TCTX("burst"))),3)
 D EQ^MIOUIT000(.FAIL,"[T001][wall count]",$$COUNT^MIOUICTX($NA(TCTX("wall"))),3)
 D EQ^MIOUIT000(.FAIL,"[T001][overwatch count]",$$COUNT^MIOUICTX($NA(TCTX("overwatch"))),3)
 D EQ^MIOUIT000(.FAIL,"[T001][failover count]",$$COUNT^MIOUICTX($NA(TCTX("failover"))),3)
 D EQ^MIOUIT000(.FAIL,"[T001][handshake count]",$$COUNT^MIOUICTX($NA(TCTX("handshake"))),3)
 D EQ^MIOUIT000(.FAIL,"[T001][monitor callback]",$G(TCTX("monitor",2,"callback")),"assignMonitorEvidence")
 Q
 ;
T010(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D BASECONF(.CONF)
 D BUILD^MIOUIMMR(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/mioui_multi_monitor_layouts.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T010][render ok]",$D(ERR),0)
 D CONTAINS^MIOUIT000(.FAIL,"[T010][title]",OUT,"Multi-monitor layouts")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][assignment]",OUT,"Monitor assignment grid")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][burst]",OUT,"Queue burst layout")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][wall]",OUT,"Evidence wall layout")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][overwatch]",OUT,"Supervisor overwatch layout")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][failover]",OUT,"Layout failover strip")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][handshake]",OUT,"Operator handshake board")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][monitor callback]",OUT,"assignMonitorEvidence")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][burst callback]",OUT,"openBurstQueueBoard")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][wall callback]",OUT,"focusEvidenceTrace")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][overwatch callback]",OUT,"openOverwatchHeatmap")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][failover callback]",OUT,"applyFailoverLaptop")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][handshake callback]",OUT,"openHandshakeLeadShift")
 Q
 ;
T020(FAIL)
 N CONF
 K ^MIO("ROUTE","RAW","GET","/mioui/multi-monitor-layouts")
 D REG^MIOUIMMR(.CONF)
 D EQ^MIOUIT000(.FAIL,"[T020][route target]",$G(^MIO("ROUTE","RAW","GET","/mioui/multi-monitor-layouts")),"MMR^MIOUIMMR")
 D EQ^MIOUIT000(.FAIL,"[T020][route auth]",+$G(^MIO("ROUTE","META","GET","/mioui/multi-monitor-layouts","authRequired")),0)
 Q
 ;
T030(FAIL)
 N REG,I
 D LIST^MIOUIREG(.REG)
 S I=$$FIND^MIOUIREG(.REG,"multi_monitor_layout_builder")
 D EQ^MIOUIT000(.FAIL,"[T030][builder status]",$G(REG(I,"status")),"implemented")
 D EQ^MIOUIT000(.FAIL,"[T030][builder phase]",$G(REG(I,"phase")),"P3")
 D EQ^MIOUIT000(.FAIL,"[T030][builder test]",$G(REG(I,"test")),"MIOUIT029")
 S I=$$FIND^MIOUIREG(.REG,"monitor_assignment_grid")
 D EQ^MIOUIT000(.FAIL,"[T030][assign status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"queue_burst_layout")
 D EQ^MIOUIT000(.FAIL,"[T030][burst status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"evidence_wall_layout")
 D EQ^MIOUIT000(.FAIL,"[T030][wall status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"supervisor_overwatch_layout")
 D EQ^MIOUIT000(.FAIL,"[T030][overwatch status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"layout_failover_strip")
 D EQ^MIOUIT000(.FAIL,"[T030][failover status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"operator_handshake_board")
 D EQ^MIOUIT000(.FAIL,"[T030][handshake status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"page_multi_monitor_layouts")
 D EQ^MIOUIT000(.FAIL,"[T030][page status]",$G(REG(I,"status")),"implemented")
 Q
 ;
