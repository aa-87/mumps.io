MIOUICOLT004 ; Collaboration chat token coverage tests
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP
 S TOP='$D(FAIL),LOCAL=0
 D T200(.LOCAL)
 D T210(.LOCAL)
 D T220(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUICOLT004"
 I LOCAL S FAIL=1
 Q
 ;
T200(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D CONFDEF^MIOUI(.CONF)
 D BUILDCH^MIOUICOLD(.CONF,.REQ,.CTX,.TCTX,"standard")
 D RENDER^MIOUICOL("pages/miouicol_chat.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T200][render ok]",$D(ERR),0)
 D TOK(.FAIL,"[T200][standard]",OUT)
 Q
 ;
T210(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D CONFDEF^MIOUI(.CONF)
 D BUILDCH^MIOUICOLD(.CONF,.REQ,.CTX,.TCTX,"dense")
 D RENDER^MIOUICOL("pages/miouicol_chat_dense.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T210][render ok]",$D(ERR),0)
 D TOK(.FAIL,"[T210][dense]",OUT)
 D HAS^MIOUIT000(.FAIL,"[T210][variant]",OUT,"Dense chat review")
 Q
 ;
T220(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D CONFDEF^MIOUI(.CONF)
 D BUILDCH^MIOUICOLD(.CONF,.REQ,.CTX,.TCTX,"balanced")
 D RENDER^MIOUICOL("pages/miouicol_chat_balanced.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T220][render ok]",$D(ERR),0)
 D TOK(.FAIL,"[T220][balanced]",OUT)
 D HAS^MIOUIT000(.FAIL,"[T220][variant]",OUT,"Balanced chat workspace")
 Q
 ;
TOK(FAIL,LABEL,OUT)
 D HAS^MIOUIT000(.FAIL,LABEL_"[title]",OUT,"Blue Horizon Imaging denial coordination")
 D HAS^MIOUIT000(.FAIL,LABEL_"[participants]",OUT,"4 active participants")
 D HAS^MIOUIT000(.FAIL,LABEL_"[reply preview]",OUT,"Reply preview")
 D HAS^MIOUIT000(.FAIL,LABEL_"[quoted]",OUT,"Quoted message")
 D HAS^MIOUIT000(.FAIL,LABEL_"[attachment]",OUT,"Eligibility summary PDF")
 D HAS^MIOUIT000(.FAIL,LABEL_"[thread]",OUT,"4 replies")
 D HAS^MIOUIT000(.FAIL,LABEL_"[system]",OUT,"System event")
 D HAS^MIOUIT000(.FAIL,LABEL_"[unread]",OUT,"3 unread messages")
 D HAS^MIOUIT000(.FAIL,LABEL_"[internal]",OUT,"Internal note")
 D HAS^MIOUIT000(.FAIL,LABEL_"[mention]",OUT,"Care coordination")
 D HAS^MIOUIT000(.FAIL,LABEL_"[read state]",OUT,"Read by Owen Brooks")
 D HAS^MIOUIT000(.FAIL,LABEL_"[typing]",OUT,"Jordan Reyes is typing")
 D HAS^MIOUIT000(.FAIL,LABEL_"[composer]",OUT,"Message composer")
 D HAS^MIOUIT000(.FAIL,LABEL_"[send]",OUT,"Send update")
 Q
 ;
