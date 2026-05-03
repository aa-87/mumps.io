TMODREG ; Register a table-backed module without frontend code
SEED(USER)
 NEW MOD
 SET USER=$GET(USER,"admin")
 ; First seed one of the sample datasets, for example: DO SEED^TBASICRO(USER)
 KILL MOD
 SET MOD("id")="user.sample.table"
 SET MOD("key")="user.sample.table"
 SET MOD("appKey")="user.sample.table"
 SET MOD("title")="My MUMPS Table"
 SET MOD("description")="Table-backed module registered from MUMPS globals."
 SET MOD("source")="user"
 SET MOD("category")="Examples"
 SET MOD("icon")="▦"
 SET MOD("componentKey")="table"
 SET MOD("surface")="mioos-surface-table"
 SET MOD("tableState","dataset")="sample-readonly"
 SET MOD("tableState","config","contract")="mioos-advanced-table-v8"
 SET MOD("tableState","config","transport")="websocket"
 SET MOD("tableState","config","mutateTransport")="websocket"
 SET MOD("tableState","config","defaultPageSize")=25
 ; Persist MOD with the user-module registry already used by this repo, or add the same nodes to an internal MIOOSMOD entry.
 QUIT
 ; How to make an icon appear: register MOD with key/appKey/title/icon and reload the module catalogue.
 ; How to open: sign in, open App Catalogue or Start Menu, choose My MUMPS Table.
 ; Validate: ZLINK "TMODREG" DO SEED^TMODREG("admin") ZLINK "MIOOSMOD" ZLINK "MIOOST" DO ^MIOOST
