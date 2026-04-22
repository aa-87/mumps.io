MIOOSI18N ; MIOOS i18n and locale helpers
	QUIT
	;
RESOLVE(CONF,REQ,CTX,LOC)
	NEW CODE
	KILL LOC
	SET CODE=$$CANON($$QPARAM(.REQ))
	IF CODE="" SET CODE=$$CANON($$COOKIE($GET(REQ("hdr","cookie")),"mioos_lang"))
	IF CODE="" SET CODE=$$HDRLANG($GET(REQ("hdr","accept-language")))
	IF CODE="" SET CODE=$$CANON($GET(CONF("mioos","i18n","default"),"en"))
	IF '$$ISSUP(CODE) SET CODE="en"
	SET LOC("code")=CODE
	SET LOC("dir")=$SELECT(CODE="ar":"rtl",1:"ltr")
	SET LOC("rtl")=$SELECT(CODE="ar":1,1:0)
	SET LOC("label")=$$LABEL(CODE)
	QUIT
	;
QPARAM(REQ)
	NEW X
	SET X=$GET(REQ("query","lang")) IF X'="" QUIT X
	SET X=$GET(REQ("query","locale")) IF X'="" QUIT X
	SET X=$GET(REQ("params","lang")) IF X'="" QUIT X
	SET X=$GET(REQ("params","locale")) IF X'="" QUIT X
	QUIT ""
	;
COOKIE(CSTR,NAME)
	NEW I,PAIR,KEY,VAL
	FOR I=1:1:$LENGTH($GET(CSTR),";") DO  QUIT:$GET(VAL)'=""
	. SET PAIR=$$TRIM^MIOUTIL($PIECE($GET(CSTR),";",I))
	. SET KEY=$$TRIM^MIOUTIL($PIECE(PAIR,"=",1))
	. IF KEY'=$GET(NAME) QUIT
	. SET VAL=$$TRIM^MIOUTIL($PIECE(PAIR,"=",2,999))
	QUIT $GET(VAL)
	;
HDRLANG(HDR)
	NEW I,TOKEN,CODE
	FOR I=1:1:$LENGTH($GET(HDR),",") DO  QUIT:$GET(CODE)'=""
	. SET TOKEN=$PIECE($PIECE($GET(HDR),",",I),";",1)
	. SET TOKEN=$$CANON(TOKEN)
	. IF $$ISSUP(TOKEN) SET CODE=TOKEN
	QUIT $GET(CODE)
	;
ISSUP(CODE)
	SET CODE=$$CANON($GET(CODE))
	QUIT $SELECT(CODE="en":1,CODE="ar":1,CODE="es":1,1:0)
	;
CANON(CODE)
	SET CODE=$$LOW^MIOUTIL($$TRIM^MIOUTIL($GET(CODE)))
	SET CODE=$TRANSLATE(CODE,"_","-")
	IF CODE["-" SET CODE=$PIECE(CODE,"-",1)
	QUIT $EXTRACT(CODE,1,2)
	;
LABEL(CODE)
	SET CODE=$$CANON($GET(CODE))
	QUIT $SELECT(CODE="ar":"العربية",CODE="es":"Español",1:"English")
	;
SUPPORTED(ROOT,DEFAULT)
	KILL @ROOT
	SET @ROOT@(1,"code")="en"
	SET @ROOT@(1,"label")=$$LABEL("en")
	SET @ROOT@(1,"dir")="ltr"
	SET @ROOT@(1,"isDefault")=$SELECT($$CANON($GET(DEFAULT))="en":1,1:0)
	SET @ROOT@(2,"code")="ar"
	SET @ROOT@(2,"label")=$$LABEL("ar")
	SET @ROOT@(2,"dir")="rtl"
	SET @ROOT@(2,"isDefault")=$SELECT($$CANON($GET(DEFAULT))="ar":1,1:0)
	SET @ROOT@(3,"code")="es"
	SET @ROOT@(3,"label")=$$LABEL("es")
	SET @ROOT@(3,"dir")="ltr"
	SET @ROOT@(3,"isDefault")=$SELECT($$CANON($GET(DEFAULT))="es":1,1:0)
	QUIT
	;
CATALOG(CODE,ROOT)
	KILL @ROOT
	SET @ROOT@("product.subtitle")=$$TXT(CODE,"product.subtitle","MUMPS-powered web desktop shell")
	SET @ROOT@("page.desktop")=$$TXT(CODE,"page.desktop","Desktop")
	SET @ROOT@("launcher.menu")=$$TXT(CODE,"launcher.menu","Menu")
	SET @ROOT@("alert.dismiss")=$$TXT(CODE,"alert.dismiss","Dismiss")
	SET @ROOT@("auth.requiredCopy")=$$TXT(CODE,"auth.requiredCopy","This desktop is configured to require authentication before protected shell windows can be opened.")
	SET @ROOT@("auth.username")=$$TXT(CODE,"auth.username","Username")
	SET @ROOT@("auth.password")=$$TXT(CODE,"auth.password","Password")
	SET @ROOT@("auth.signin")=$$TXT(CODE,"auth.signin","Sign in")
	SET @ROOT@("auth.signout")=$$TXT(CODE,"auth.signout","Sign out")
	SET @ROOT@("auth.continueGuest")=$$TXT(CODE,"auth.continueGuest","Continue as guest")
	SET @ROOT@("auth.guest")=$$TXT(CODE,"auth.guest","Guest")
	SET @ROOT@("auth.notSignedIn")=$$TXT(CODE,"auth.notSignedIn","Not signed in")
	SET @ROOT@("auth.roles")=$$TXT(CODE,"auth.roles","Roles")
	SET @ROOT@("auth.state.signedInAs")=$$TXT(CODE,"auth.state.signedInAs","Signed in as")
	SET @ROOT@("auth.state.required")=$$TXT(CODE,"auth.state.required","Sign in required")
	SET @ROOT@("auth.state.guest")=$$TXT(CODE,"auth.state.guest","Desktop available without sign-in")
	SET @ROOT@("search.placeholder")=$$TXT(CODE,"search.placeholder","Search programs and actions")
	SET @ROOT@("section.system")=$$TXT(CODE,"section.system","System")
	SET @ROOT@("system.profile")=$$TXT(CODE,"system.profile","Profile")
	SET @ROOT@("system.theme")=$$TXT(CODE,"system.theme","Theme")
	SET @ROOT@("system.socket")=$$TXT(CODE,"system.socket","Socket")
	SET @ROOT@("system.session")=$$TXT(CODE,"system.session","Session")
	SET @ROOT@("socket.live")=$$TXT(CODE,"socket.live","Live")
	SET @ROOT@("socket.offline")=$$TXT(CODE,"socket.offline","Offline")
	SET @ROOT@("common.none")=$$TXT(CODE,"common.none","none")
	SET @ROOT@("common.guest")=$$TXT(CODE,"common.guest","Guest")
	SET @ROOT@("common.anonymous")=$$TXT(CODE,"common.anonymous","Anonymous")
	SET @ROOT@("action.refreshDesktop")=$$TXT(CODE,"action.refreshDesktop","Refresh desktop")
	SET @ROOT@("action.open")=$$TXT(CODE,"action.open","Open")
	SET @ROOT@("action.minimize")=$$TXT(CODE,"action.minimize","Minimize")
	SET @ROOT@("action.maximize")=$$TXT(CODE,"action.maximize","Maximize")
	SET @ROOT@("action.restore")=$$TXT(CODE,"action.restore","Restore")
	SET @ROOT@("action.close")=$$TXT(CODE,"action.close","Close")
	SET @ROOT@("desktop.icons")=$$TXT(CODE,"desktop.icons","Desktop icons")
	SET @ROOT@("tray.socketLive")=$$TXT(CODE,"tray.socketLive","Socket live")
	SET @ROOT@("tray.socketOffline")=$$TXT(CODE,"tray.socketOffline","Socket offline")
	SET @ROOT@("tray.signedIn")=$$TXT(CODE,"tray.signedIn","Signed in")
	SET @ROOT@("tray.anonymous")=$$TXT(CODE,"tray.anonymous","Anonymous")
	SET @ROOT@("tray.panel")=$$TXT(CODE,"tray.panel","System tray")
	SET @ROOT@("section.pinned")=$$TXT(CODE,"section.pinned","Pinned apps")
	SET @ROOT@("section.openWindows")=$$TXT(CODE,"section.openWindows","Open windows")
	SET @ROOT@("action.pauseAll")=$$TXT(CODE,"action.pauseAll","Pause all")
	SET @ROOT@("action.resumeAll")=$$TXT(CODE,"action.resumeAll","Resume all")
	SET @ROOT@("action.cancelActive")=$$TXT(CODE,"action.cancelActive","Cancel active")
	SET @ROOT@("dialog.confirm")=$$TXT(CODE,"dialog.confirm","Confirm")
	SET @ROOT@("dialog.cancel")=$$TXT(CODE,"dialog.cancel","Cancel")
	SET @ROOT@("locale.language")=$$TXT(CODE,"locale.language","Language")
	SET @ROOT@("locale.english")=$$TXT(CODE,"locale.english","English")
	SET @ROOT@("locale.arabic")=$$TXT(CODE,"locale.arabic","Arabic")
	SET @ROOT@("locale.spanish")=$$TXT(CODE,"locale.spanish","Spanish")
	SET @ROOT@("alerts.bootError.title")=$$TXT(CODE,"alerts.bootError.title","Boot error")
	SET @ROOT@("alerts.bootError.message")=$$TXT(CODE,"alerts.bootError.message","Unable to parse the server boot contract.")
	SET @ROOT@("alerts.socketError.title")=$$TXT(CODE,"alerts.socketError.title","Socket error")
	SET @ROOT@("alerts.socketError.message")=$$TXT(CODE,"alerts.socketError.message","Unable to open the primary websocket.")
	SET @ROOT@("alerts.shellEventError.title")=$$TXT(CODE,"alerts.shellEventError.title","Shell event error")
	SET @ROOT@("alerts.shellEventError.message")=$$TXT(CODE,"alerts.shellEventError.message","Unsupported shell event.")
	SET @ROOT@("alerts.viewRefreshFailed.title")=$$TXT(CODE,"alerts.viewRefreshFailed.title","View refresh failed")
	SET @ROOT@("alerts.viewRefreshFailed.message")=$$TXT(CODE,"alerts.viewRefreshFailed.message","The shell view model could not be refreshed.")
	SET @ROOT@("alerts.signinFailed.title")=$$TXT(CODE,"alerts.signinFailed.title","Sign in failed")
	SET @ROOT@("alerts.signinFailed.message")=$$TXT(CODE,"alerts.signinFailed.message","The username or password was rejected.")
	SET @ROOT@("alerts.guestSigninFailed.title")=$$TXT(CODE,"alerts.guestSigninFailed.title","Guest sign in failed")
	SET @ROOT@("alerts.guestSigninFailed.message")=$$TXT(CODE,"alerts.guestSigninFailed.message","Guest access is not available.")
	SET @ROOT@("alerts.signoutFailed.title")=$$TXT(CODE,"alerts.signoutFailed.title","Sign out failed")
	SET @ROOT@("alerts.signoutFailed.message")=$$TXT(CODE,"alerts.signoutFailed.message","The local session could not be cleared.")
	SET @ROOT@("alerts.passwordChangeFailed.title")=$$TXT(CODE,"alerts.passwordChangeFailed.title","Password change failed")
	SET @ROOT@("alerts.passwordChangeFailed.message")=$$TXT(CODE,"alerts.passwordChangeFailed.message","The password could not be changed using the current rotation token.")
	SET @ROOT@("alerts.signinRequired.title")=$$TXT(CODE,"alerts.signinRequired.title","Sign in required")
	SET @ROOT@("alerts.signinRequired.open")=$$TXT(CODE,"alerts.signinRequired.open","Authenticate before opening protected shell windows.")
	SET @ROOT@("alerts.signinRequired.use")=$$TXT(CODE,"alerts.signinRequired.use","Authenticate before using protected shell windows.")
	SET @ROOT@("view.summary.headline")=$$TXT(CODE,"view.summary.headline","Production shell foundation")
	SET @ROOT@("view.summary.subheadline")=$$TXT(CODE,"view.summary.subheadline","Server-authored boot contract, thin Vue 3 shell, websocket-first transport, and local auth sessions.")
	SET @ROOT@("view.documents.1.title")=$$TXT(CODE,"view.documents.1.title","Desktop contract")
	SET @ROOT@("view.documents.1.detail")=$$TXT(CODE,"view.documents.1.detail","Routes, theme, apps, windows, locale, and auth posture are authored by MUMPS.")
	SET @ROOT@("view.documents.2.title")=$$TXT(CODE,"view.documents.2.title","Session posture")
	SET @ROOT@("view.documents.2.detail")=$$TXT(CODE,"view.documents.2.detail","The shell keeps a pooled websocket transport with dedicated app sockets and optional local JWT cookie sessions for sign-in.")
	SET @ROOT@("view.documents.3.title")=$$TXT(CODE,"view.documents.3.title","Front-end model")
	SET @ROOT@("view.documents.3.detail")=$$TXT(CODE,"view.documents.3.detail","Vue Options API UMD renders the current server contract without markup placeholders.")
	SET @ROOT@("view.controlPanel.1.title")=$$TXT(CODE,"view.controlPanel.1.title","Theme")
	SET @ROOT@("view.controlPanel.2.title")=$$TXT(CODE,"view.controlPanel.2.title","Font")
	SET @ROOT@("view.controlPanel.3.title")=$$TXT(CODE,"view.controlPanel.3.title","Transport")
	SET @ROOT@("view.controlPanel.4.title")=$$TXT(CODE,"view.controlPanel.4.title","Authentication")
	SET @ROOT@("terminal.headline")=$$TXT(CODE,"terminal.headline","MUMPS terminal path ready")
	SET @ROOT@("terminal.subheadline")=$$TXT(CODE,"terminal.subheadline","Open the window from the taskbar or Menu; live shell transport stays on the pooled websocket boundary.")
	SET @ROOT@("terminal.newSession")=$$TXT(CODE,"terminal.newSession","New session")
	SET @ROOT@("terminal.clear")=$$TXT(CODE,"terminal.clear","Clear")
	SET @ROOT@("terminal.status.opening")=$$TXT(CODE,"terminal.status.opening","Opening")
	SET @ROOT@("terminal.status.connected")=$$TXT(CODE,"terminal.status.connected","Connected")
	SET @ROOT@("terminal.status.closed")=$$TXT(CODE,"terminal.status.closed","Closed")
	SET @ROOT@("alerts.terminalOpenFailed.title")=$$TXT(CODE,"alerts.terminalOpenFailed.title","Terminal open failed")
	SET @ROOT@("alerts.terminalOpenFailed.message")=$$TXT(CODE,"alerts.terminalOpenFailed.message","The terminal window could not be opened.")
	SET @ROOT@("alerts.terminalCommandFailed.title")=$$TXT(CODE,"alerts.terminalCommandFailed.title","Terminal command failed")
	SET @ROOT@("alerts.terminalCommandFailed.message")=$$TXT(CODE,"alerts.terminalCommandFailed.message","The terminal command did not complete.")
	SET @ROOT@("alerts.terminalOffline.title")=$$TXT(CODE,"alerts.terminalOffline.title","Terminal offline")
	SET @ROOT@("alerts.terminalOffline.message")=$$TXT(CODE,"alerts.terminalOffline.message","The primary websocket is not connected.")
	SET @ROOT@("app.my-computer.title")=$$TXT(CODE,"app.my-computer.title","My Computer")
	SET @ROOT@("app.my-computer.subtitle")=$$TXT(CODE,"app.my-computer.subtitle","Browse drives, folders, and shell locations")
	SET @ROOT@("app.documents.title")=$$TXT(CODE,"app.documents.title","My Documents")
	SET @ROOT@("app.documents.subtitle")=$$TXT(CODE,"app.documents.subtitle","Personal workspace documents")
	SET @ROOT@("app.control-panel.title")=$$TXT(CODE,"app.control-panel.title","Control Panel")
	SET @ROOT@("app.control-panel.subtitle")=$$TXT(CODE,"app.control-panel.subtitle","Desktop settings and shell behavior")
	SET @ROOT@("app.terminal.title")=$$TXT(CODE,"app.terminal.title","Terminal")
	SET @ROOT@("app.terminal.subtitle")=$$TXT(CODE,"app.terminal.subtitle","Websocket-backed MUMPS terminal surface")
	SET @ROOT@("app.debug-center.title")=$$TXT(CODE,"app.debug-center.title","Debug Center")
	SET @ROOT@("app.debug-center.subtitle")=$$TXT(CODE,"app.debug-center.subtitle","Server snapshot, command registry, and recent websocket activity")
	QUIT
	;
TXT(CODE,KEY,DEFAULT)
	NEW OUT
	SET CODE=$$CANON($GET(CODE))
	SET OUT=$$LOOKUP(CODE,KEY)
	IF OUT="" SET OUT=$$LOOKUP("en",KEY)
	IF OUT="" SET OUT=$GET(DEFAULT)
	QUIT OUT
	;
LOOKUP(CODE,KEY)
	NEW I,LINE,TXT,SEC,OUT,K,V
	SET SEC="",OUT=""
	FOR I=1:1 DO  QUIT:TXT=""!(OUT'="")
	. SET LINE=$TEXT(TABLE+I)
	. SET TXT=$PIECE(LINE,";;",2,999)
	. IF TXT="" QUIT
	. IF TXT="***" SET TXT="" QUIT
	. IF $EXTRACT(TXT,1)="[" DO  QUIT
	. . SET SEC=$EXTRACT(TXT,2,$LENGTH(TXT)-1)
	. IF SEC'=$GET(CODE) QUIT
	. SET K=$PIECE(TXT,"=",1),V=$PIECE(TXT,"=",2,999)
	. IF K=$GET(KEY) SET OUT=V
	QUIT OUT
	;
TABLE
	;;[en]
	;;product.subtitle=MUMPS-powered web desktop shell
	;;page.desktop=Desktop
	;;launcher.menu=Menu
	;;alert.dismiss=Dismiss
	;;auth.requiredCopy=This desktop is configured to require authentication before protected shell windows can be opened.;
	;;auth.username=Username
	;;auth.password=Password
	;;auth.signin=Sign in
	;;auth.signout=Sign out
	;;auth.continueGuest=Continue as guest
	;;auth.guest=Guest
	;;auth.notSignedIn=Not signed in
	;;auth.roles=Roles
	;;auth.state.signedInAs=Signed in as
	;;auth.state.required=Sign in required
	;;auth.state.guest=Desktop available without sign-in
	;;search.placeholder=Search programs and actions
	;;section.system=System
	;;system.profile=Profile
	;;system.theme=Theme
	;;system.socket=Socket
	;;system.session=Session
	;;socket.live=Live
	;;socket.offline=Offline
	;;common.none=none
	;;common.guest=Guest
	;;common.anonymous=Anonymous
	;;action.refreshDesktop=Refresh desktop
	;;action.open=Open
	;;action.minimize=Minimize
	;;action.maximize=Maximize
	;;action.restore=Restore
	;;action.close=Close
	;;desktop.icons=Desktop icons
	;;tray.socketLive=Socket live
	;;tray.socketOffline=Socket offline
	;;tray.signedIn=Signed in
	;;tray.anonymous=Anonymous
;;tray.panel=System tray
;;section.pinned=Pinned apps
;;section.openWindows=Open windows
;;action.pauseAll=Pause all
;;action.resumeAll=Resume all
;;action.cancelActive=Cancel active
;;dialog.confirm=Confirm
;;dialog.cancel=Cancel
	;;locale.language=Language
	;;locale.english=English
	;;locale.arabic=Arabic
	;;locale.spanish=Spanish
	;;alerts.bootError.title=Boot error
	;;alerts.bootError.message=Unable to parse the server boot contract.;
	;;alerts.socketError.title=Socket error
	;;alerts.socketError.message=Unable to open the primary websocket.;
	;;alerts.shellEventError.title=Shell event error
	;;alerts.shellEventError.message=Unsupported shell event.;
	;;alerts.viewRefreshFailed.title=View refresh failed
	;;alerts.viewRefreshFailed.message=The shell view model could not be refreshed.;
	;;alerts.signinFailed.title=Sign in failed
	;;alerts.signinFailed.message=The username or password was rejected.;
	;;alerts.guestSigninFailed.title=Guest sign in failed
	;;alerts.guestSigninFailed.message=Guest access is not available.;
	;;alerts.signoutFailed.title=Sign out failed
	;;alerts.signoutFailed.message=The local session could not be cleared.;
	;;alerts.signinRequired.title=Sign in required
	;;alerts.signinRequired.open=Authenticate before opening protected shell windows.;
	;;alerts.signinRequired.use=Authenticate before using protected shell windows.;
	;;view.summary.headline=Production shell foundation
	;;view.summary.subheadline=Server-authored boot contract, thin Vue 3 shell, websocket-first transport, and local auth sessions.;
	;;view.documents.1.title=Desktop contract
	;;view.documents.1.detail=Routes, theme, apps, windows, locale, and auth posture are authored by MUMPS.;
	;;view.documents.2.title=Session posture
	;;view.documents.2.detail=The shell keeps a pooled websocket transport with dedicated app sockets and optional local JWT cookie sessions for sign-in.;
	;;view.documents.3.title=Front-end model
	;;view.documents.3.detail=Vue Options API UMD renders the current server contract without markup placeholders.;
	;;view.controlPanel.1.title=Theme
	;;view.controlPanel.2.title=Font
	;;view.controlPanel.3.title=Transport
	;;view.controlPanel.4.title=Authentication
	;;terminal.headline=MUMPS terminal path ready
	;;terminal.subheadline=Open the window from the taskbar or Menu; live shell transport stays on the pooled websocket boundary.;
	;;terminal.newSession=New session
	;;terminal.clear=Clear
	;;terminal.status.opening=Opening
	;;terminal.status.connected=Connected
	;;terminal.status.closed=Closed
	;;alerts.terminalOpenFailed.title=Terminal open failed
	;;alerts.terminalOpenFailed.message=The terminal window could not be opened.;
	;;alerts.terminalCommandFailed.title=Terminal command failed
	;;alerts.terminalCommandFailed.message=The terminal command did not complete.;
	;;alerts.terminalOffline.title=Terminal offline
	;;alerts.terminalOffline.message=The primary websocket is not connected.;
	;;app.my-computer.title=My Computer
	;;app.my-computer.subtitle=Browse drives, folders, and shell locations
	;;app.documents.title=My Documents
	;;app.documents.subtitle=Personal workspace documents
	;;app.control-panel.title=Control Panel
	;;app.control-panel.subtitle=Desktop settings and shell behavior
	;;app.terminal.title=Terminal
	;;app.terminal.subtitle=Websocket-backed MUMPS terminal surface
;;app.debug-center.title=Debug Center
;;app.debug-center.subtitle=Server snapshot, command registry, and recent websocket activity
	;;[ar]
	;;product.subtitle=بيئة سطح مكتب ويب مدعومة بواسطة MUMPS
	;;page.desktop=سطح المكتب
	;;launcher.menu=القائمة
	;;alert.dismiss=إغلاق
	;;auth.requiredCopy=تم إعداد سطح المكتب هذا ليتطلب المصادقة قبل فتح نوافذ النظام المحمية.;
	;;auth.username=اسم المستخدم
	;;auth.password=كلمة المرور
	;;auth.signin=تسجيل الدخول
	;;auth.signout=تسجيل الخروج
	;;auth.continueGuest=المتابعة كضيف
	;;auth.guest=ضيف
	;;auth.notSignedIn=غير مسجل الدخول
	;;auth.roles=الأدوار
	;;auth.state.signedInAs=تم تسجيل الدخول باسم
	;;auth.state.required=تسجيل الدخول مطلوب
	;;auth.state.guest=سطح المكتب متاح بدون تسجيل دخول
	;;search.placeholder=ابحث عن البرامج والإجراءات
	;;section.system=النظام
	;;system.profile=الملف
	;;system.theme=السمة
	;;system.socket=المقبس
	;;system.session=الجلسة
	;;socket.live=متصل
	;;socket.offline=غير متصل
	;;common.none=لا يوجد
	;;common.guest=ضيف
	;;common.anonymous=مجهول
	;;action.refreshDesktop=تحديث سطح المكتب
	;;action.open=فتح
	;;action.minimize=تصغير
	;;action.maximize=تكبير
	;;action.restore=استعادة
	;;action.close=إغلاق
	;;desktop.icons=أيقونات سطح المكتب
	;;tray.socketLive=المقبس متصل
	;;tray.socketOffline=المقبس غير متصل
	;;tray.signedIn=تم تسجيل الدخول
	;;tray.anonymous=مجهول
;;tray.panel=علبة النظام
;;section.pinned=التطبيقات المثبتة
;;section.openWindows=النوافذ المفتوحة
;;action.pauseAll=إيقاف الكل
;;action.resumeAll=استئناف الكل
;;action.cancelActive=إلغاء النشط
;;dialog.confirm=تأكيد
;;dialog.cancel=إلغاء
	;;locale.language=اللغة
	;;locale.english=الإنجليزية
	;;locale.arabic=العربية
	;;locale.spanish=الإسبانية
	;;alerts.bootError.title=خطأ في التمهيد
	;;alerts.bootError.message=تعذر تحليل عقد التمهيد الصادر من الخادم.;
	;;alerts.socketError.title=خطأ في المقبس
	;;alerts.socketError.message=تعذر فتح مقبس الويب الأساسي.;
	;;alerts.shellEventError.title=خطأ في حدث الواجهة
	;;alerts.shellEventError.message=حدث واجهة غير مدعوم.;
	;;alerts.viewRefreshFailed.title=فشل تحديث العرض
	;;alerts.viewRefreshFailed.message=تعذر تحديث نموذج عرض الواجهة.;
	;;alerts.signinFailed.title=فشل تسجيل الدخول
	;;alerts.signinFailed.message=تم رفض اسم المستخدم أو كلمة المرور.;
	;;alerts.guestSigninFailed.title=فشل دخول الضيف
	;;alerts.guestSigninFailed.message=دخول الضيف غير متاح.;
	;;alerts.signoutFailed.title=فشل تسجيل الخروج
	;;alerts.signoutFailed.message=تعذر مسح الجلسة المحلية.;
	;;alerts.signinRequired.title=تسجيل الدخول مطلوب
	;;alerts.signinRequired.open=قم بالمصادقة قبل فتح نوافذ النظام المحمية.;
	;;alerts.signinRequired.use=قم بالمصادقة قبل استخدام نوافذ النظام المحمية.;
	;;view.summary.headline=أساس واجهة إنتاجية
	;;view.summary.subheadline=عقد تمهيد مؤلف من الخادم وواجهة Vue 3 خفيفة ونقل يعتمد على WebSocket وجلسات مصادقة محلية.;
	;;view.documents.1.title=عقد سطح المكتب
	;;view.documents.1.detail=المسارات والسمة والتطبيقات والنوافذ واللغة ووضع المصادقة كلها مؤلفة بواسطة MUMPS.;
	;;view.documents.2.title=وضع الجلسة
	;;view.documents.2.detail=تحتفظ الواجهة بمقبس ويب أساسي واحد وجلسات JWT محلية اختيارية لتسجيل الدخول.;
	;;view.documents.3.title=نموذج الواجهة الأمامية
	;;view.documents.3.detail=يقوم Vue Options API UMD بعرض عقد الخادم الحالي بدون عناصر ترميزية مؤقتة.;
	;;view.controlPanel.1.title=السمة
	;;view.controlPanel.2.title=الخط
	;;view.controlPanel.3.title=النقل
	;;view.controlPanel.4.title=المصادقة
	;;terminal.headline=مسار طرفية MUMPS جاهز
	;;terminal.subheadline=افتح النافذة من شريط المهام أو القائمة؛ النقل المباشر للواجهة يجب أن يبقى على حدود WebSocket.;
	;;terminal.newSession=جلسة جديدة
	;;terminal.clear=مسح
	;;terminal.status.opening=جارٍ الفتح
	;;terminal.status.connected=متصل
	;;terminal.status.closed=مغلق
	;;alerts.terminalOpenFailed.title=فشل فتح الطرفية
	;;alerts.terminalOpenFailed.message=تعذر فتح نافذة الطرفية.;
	;;alerts.terminalCommandFailed.title=فشل أمر الطرفية
	;;alerts.terminalCommandFailed.message=لم يكتمل أمر الطرفية.;
	;;alerts.terminalOffline.title=الطرفية غير متصلة
	;;alerts.terminalOffline.message=مقبس الويب الأساسي غير متصل.;
	;;app.my-computer.title=جهاز الكمبيوتر
	;;app.my-computer.subtitle=استعراض الأقراص والمجلدات ومواقع النظام
	;;app.documents.title=مستنداتي
	;;app.documents.subtitle=مستندات مساحة العمل الشخصية
	;;app.control-panel.title=لوحة التحكم
	;;app.control-panel.subtitle=إعدادات سطح المكتب وسلوك الواجهة
	;;app.terminal.title=الطرفية
	;;app.terminal.subtitle=واجهة طرفية MUMPS معتمدة على WebSocket
	;;[es]
	;;product.subtitle=Entorno de escritorio web impulsado por MUMPS
	;;page.desktop=Escritorio
	;;launcher.menu=Menú
	;;alert.dismiss=Cerrar
	;;auth.requiredCopy=Este escritorio está configurado para requerir autenticación antes de abrir ventanas protegidas del sistema.;
	;;auth.username=Usuario
	;;auth.password=Contraseña
	;;auth.signin=Iniciar sesión
	;;auth.signout=Cerrar sesión
	;;auth.continueGuest=Continuar como invitado
	;;auth.guest=Invitado
	;;auth.notSignedIn=No has iniciado sesión
	;;auth.roles=Roles
	;;auth.state.signedInAs=Sesión iniciada como
	;;auth.state.required=Inicio de sesión obligatorio
	;;auth.state.guest=El escritorio está disponible sin iniciar sesión
	;;search.placeholder=Buscar programas y acciones
	;;section.system=Sistema
	;;system.profile=Perfil
	;;system.theme=Tema
	;;system.socket=Socket
	;;system.session=Sesión
	;;socket.live=Activo
	;;socket.offline=Sin conexión
	;;common.none=ninguno
	;;common.guest=Invitado
	;;common.anonymous=Anónimo
	;;action.refreshDesktop=Actualizar escritorio
	;;action.open=Abrir
	;;action.minimize=Minimizar
	;;action.maximize=Maximizar
	;;action.restore=Restaurar
	;;action.close=Cerrar
	;;desktop.icons=Iconos del escritorio
	;;tray.socketLive=Socket activo
	;;tray.socketOffline=Socket sin conexión
	;;tray.signedIn=Con sesión
	;;tray.anonymous=Anónimo
;;tray.panel=Bandeja del sistema
;;section.pinned=Aplicaciones fijadas
;;section.openWindows=Ventanas abiertas
;;action.pauseAll=Pausar todo
;;action.resumeAll=Reanudar todo
;;action.cancelActive=Cancelar activos
;;dialog.confirm=Confirmar
;;dialog.cancel=Cancelar
	;;locale.language=Idioma
	;;locale.english=Inglés
	;;locale.arabic=Árabe
	;;locale.spanish=Español
	;;alerts.bootError.title=Error de arranque
	;;alerts.bootError.message=No se pudo interpretar el contrato de arranque del servidor.;
	;;alerts.socketError.title=Error de socket
	;;alerts.socketError.message=No se pudo abrir el websocket principal.;
	;;alerts.shellEventError.title=Error del shell
	;;alerts.shellEventError.message=Evento del shell no compatible.;
	;;alerts.viewRefreshFailed.title=Falló la actualización
	;;alerts.viewRefreshFailed.message=No se pudo actualizar el modelo de vista del shell.;
	;;alerts.signinFailed.title=Falló el inicio de sesión
	;;alerts.signinFailed.message=El usuario o la contraseña fueron rechazados.;
	;;alerts.guestSigninFailed.title=Falló el acceso de invitado
	;;alerts.guestSigninFailed.message=El acceso de invitado no está disponible.;
	;;alerts.signoutFailed.title=Falló el cierre de sesión
	;;alerts.signoutFailed.message=No se pudo limpiar la sesión local.;
	;;alerts.signinRequired.title=Inicio de sesión obligatorio
	;;alerts.signinRequired.open=Autentícate antes de abrir ventanas protegidas del shell.;
	;;alerts.signinRequired.use=Autentícate antes de usar ventanas protegidas del shell.;
	;;view.summary.headline=Base del shell de producción
	;;view.summary.subheadline=Contrato de arranque definido por el servidor, shell delgado en Vue 3, transporte prioritario por websocket y sesiones locales de autenticación.;
	;;view.documents.1.title=Contrato del escritorio
	;;view.documents.1.detail=Las rutas, el tema, las apps, las ventanas, el idioma y la postura de autenticación son definidos por MUMPS.;
	;;view.documents.2.title=Postura de sesión
	;;view.documents.2.detail=El shell mantiene un websocket principal y sesiones locales opcionales con cookie JWT para iniciar sesión.;
	;;view.documents.3.title=Modelo de front-end
	;;view.documents.3.detail=Vue Options API UMD representa el contrato actual del servidor sin marcadores de relleno.;
	;;view.controlPanel.1.title=Tema
	;;view.controlPanel.2.title=Fuente
	;;view.controlPanel.3.title=Transporte
	;;view.controlPanel.4.title=Autenticación
	;;terminal.headline=Ruta de terminal MUMPS lista
	;;terminal.subheadline=Abre la ventana desde la barra de tareas o el Menú; el transporte en vivo del shell debe permanecer en el borde websocket.;
	;;terminal.newSession=Nueva sesión
	;;terminal.clear=Limpiar
	;;terminal.status.opening=Abriendo
	;;terminal.status.connected=Conectado
	;;terminal.status.closed=Cerrado
	;;alerts.terminalOpenFailed.title=No se pudo abrir la terminal
	;;alerts.terminalOpenFailed.message=No se pudo abrir la ventana de terminal.;
	;;alerts.terminalCommandFailed.title=Falló el comando de terminal
	;;alerts.terminalCommandFailed.message=El comando de terminal no se completó.;
	;;alerts.terminalOffline.title=Terminal sin conexión
	;;alerts.terminalOffline.message=El websocket principal no está conectado.;
	;;app.my-computer.title=Mi PC
	;;app.my-computer.subtitle=Explorar discos, carpetas y ubicaciones del shell
	;;app.documents.title=Mis documentos
	;;app.documents.subtitle=Documentos personales del espacio de trabajo
	;;app.control-panel.title=Panel de control
	;;app.control-panel.subtitle=Ajustes del escritorio y comportamiento del shell
	;;app.terminal.title=Terminal
	;;app.terminal.subtitle=Superficie de terminal MUMPS respaldada por websocket
	;;***
	;