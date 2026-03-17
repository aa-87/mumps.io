MIOUITHEME ; MIOUI theme defaults and semantic tone helpers
 Q
 ;
DEFAULTS(CONF)
 I '$D(CONF("mioui","enabled")) S CONF("mioui","enabled")=1
 I $G(CONF("mioui","theme","default"))="" S CONF("mioui","theme","default")="dark"
 I $G(CONF("mioui","density"))="" S CONF("mioui","density")="dense"
 I '$D(CONF("mioui","motion","enabled")) S CONF("mioui","motion","enabled")=1
 I '$D(CONF("mioui","onboarding","enabled")) S CONF("mioui","onboarding","enabled")=1
 I '$D(CONF("mioui","table","defaultPageSize")) S CONF("mioui","table","defaultPageSize")=25
 I '$D(CONF("mioui","table","pageSize",1)) S CONF("mioui","table","pageSize",1)=25
 I '$D(CONF("mioui","table","pageSize",2)) S CONF("mioui","table","pageSize",2)=50
 I '$D(CONF("mioui","table","pageSize",3)) S CONF("mioui","table","pageSize",3)=100
 I $G(CONF("mioui","format","currencySymbol"))="" S CONF("mioui","format","currencySymbol")="$"
 I $G(CONF("mioui","format","date"))="" S CONF("mioui","format","date")="YYYY-MM-DD"
 Q
 ;
APPLY(CONF,TCTX)
 N MODE,DENSITY
 D DEFAULTS^MIOUITHEME(.CONF)
 S MODE=$G(TCTX("theme","mode")) I MODE="" S MODE=$G(CONF("mioui","theme","default"),"dark")
 S DENSITY=$G(TCTX("theme","density")) I DENSITY="" S DENSITY=$G(CONF("mioui","density"),"dense")
 S TCTX("theme","mode")=$$MODE(MODE)
 S TCTX("theme","density")=$$DENSITY(DENSITY)
 S TCTX("theme","toggleLabel")=$S(TCTX("theme","mode")="dark":"Light mode",1:"Dark mode")
 S TCTX("theme","densityLabel")=$$DENSITYLBL(TCTX("theme","density"))
 Q
 ;
MODE(NAME)
 N X S X=$ZCONVERT($G(NAME),"L")
 I X="light" Q "light"
 Q "dark"
 ;
DENSITY(NAME)
 N X S X=$ZCONVERT($G(NAME),"L")
 I X="normal"!(X="spacious") Q X
 Q "dense"
 ;
DENSITYLBL(NAME)
 I $G(NAME)="normal" Q "Normal density"
 I $G(NAME)="spacious" Q "Spacious density"
 Q "Dense density"
 ;
TONE(NAME)
 N X S X=$ZCONVERT($G(NAME),"L")
 I X="sky"!(X="emerald")!(X="amber")!(X="rose")!(X="violet")!(X="slate")!(X="neutral") Q X
 Q "slate"
 ;
BADGE(NAME)
 N X S X=$$TONE($G(NAME))
 I X="neutral" S X="slate"
 Q "badge-"_X
 ;
PANEL(NAME)
 N X S X=$$TONE($G(NAME))
 I X="neutral" S X="slate"
 Q "tone-"_X
 ;
