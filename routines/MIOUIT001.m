MIOUIT001 ; registry coverage tests
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP
 S TOP='$D(FAIL),LOCAL=0
 D T001(.LOCAL)
 D T010(.LOCAL)
 D T020(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUIT001"
 I LOCAL S FAIL=1
 Q
 ;
T001(FAIL)
 N REG
 D LIST^MIOUIREG(.REG)
 D GE^MIOUIT000(.FAIL,"[T001][total count]",$$COUNT^MIOUIREG(.REG,""),50)
 D GE^MIOUIT000(.FAIL,"[T001][implemented count]",$$COUNT^MIOUIREG(.REG,"implemented"),34)
 D GE^MIOUIT000(.FAIL,"[T001][planned count]",$$COUNT^MIOUIREG(.REG,"planned"),1)
 Q
 ;
T010(FAIL)
 N REG,I
 D LIST^MIOUIREG(.REG)
 S I=0
 F  S I=$O(REG(I)) Q:'I  D
 . D NOTEMPTY^MIOUIT000(.FAIL,"[T010]["_$G(REG(I,"id"))_"][id]",$G(REG(I,"id")))
 . D NOTEMPTY^MIOUIT000(.FAIL,"[T010]["_$G(REG(I,"id"))_"][status]",$G(REG(I,"status")))
 . D NOTEMPTY^MIOUIT000(.FAIL,"[T010]["_$G(REG(I,"id"))_"][family]",$G(REG(I,"family")))
 . D NOTEMPTY^MIOUIT000(.FAIL,"[T010]["_$G(REG(I,"id"))_"][kind]",$G(REG(I,"kind")))
 . D NOTEMPTY^MIOUIT000(.FAIL,"[T010]["_$G(REG(I,"id"))_"][title]",$G(REG(I,"title")))
 . D NOTEMPTY^MIOUIT000(.FAIL,"[T010]["_$G(REG(I,"id"))_"][desc]",$G(REG(I,"desc")))
 . D NOTEMPTY^MIOUIT000(.FAIL,"[T010]["_$G(REG(I,"id"))_"][phase]",$G(REG(I,"phase")))
 . D NOTEMPTY^MIOUIT000(.FAIL,"[T010]["_$G(REG(I,"id"))_"][test]",$G(REG(I,"test")))
 Q
 ;
T020(FAIL)
 N REG,I
 D LIST^MIOUIREG(.REG)
 S I=$$FIND^MIOUIREG(.REG,"shell_sidebar")
 D EQ^MIOUIT000(.FAIL,"[T020][shell_sidebar status]",$G(REG(I,"status")),"implemented")
 D EQ^MIOUIT000(.FAIL,"[T020][shell_sidebar kind]",$G(REG(I,"kind")),"partial")
 S I=$$FIND^MIOUIREG(.REG,"claim_summary_card")
 D EQ^MIOUIT000(.FAIL,"[T020][claim_summary status]",$G(REG(I,"status")),"implemented")
 D EQ^MIOUIT000(.FAIL,"[T020][claim_summary test]",$G(REG(I,"test")),"MIOUIT012")
 S I=$$FIND^MIOUIREG(.REG,"trace_audit_builder")
 D EQ^MIOUIT000(.FAIL,"[T020][trace builder status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"premium_workflow_builder")
 D EQ^MIOUIT000(.FAIL,"[T020][premium builder status]",$G(REG(I,"status")),"implemented")
 D EQ^MIOUIT000(.FAIL,"[T020][premium builder test]",$G(REG(I,"test")),"MIOUIT017")
 S I=$$FIND^MIOUIREG(.REG,"detailed_grid_builder")
 D EQ^MIOUIT000(.FAIL,"[T020][grid builder status]",$G(REG(I,"status")),"implemented")
 D EQ^MIOUIT000(.FAIL,"[T020][grid builder test]",$G(REG(I,"test")),"MIOUIT018")
 S I=$$FIND^MIOUIREG(.REG,"detailed_data_grid")
 D EQ^MIOUIT000(.FAIL,"[T020][data grid status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"page_datagrid")
 D EQ^MIOUIT000(.FAIL,"[T020][datagrid page status]",$G(REG(I,"status")),"implemented")
 D EQ^MIOUIT000(.FAIL,"[T020][datagrid page test]",$G(REG(I,"test")),"MIOUIT018")
 Q
 ;
