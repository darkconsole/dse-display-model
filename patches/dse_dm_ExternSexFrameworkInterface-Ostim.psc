ScriptName dse_dm_ExternSexFrameworkInterface extends Quest Conditional
{version: sexlab}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

String Function GetFrameworkType() Global
{ask what framework this patch is for}

	Return "ostim"
EndFunction

Form Function GetFrameworkAPI(dse_dm_QuestController Main) Global
{get the framework api object.}

	Return OUtils.GetOStim()
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Bool Function ActorIsValid(dse_dm_QuestController Main, Actor Who) Global
{check if the actor can be adultified.}

	OsexIntegrationMain OStim = GetFrameworkAPI(Main) As OsexIntegrationMain

	If(OStim != NONE)
		Return OStim.IsChild(Who)
	EndIf

	Return !Who.IsChild()
EndFunction

Function ImmersiveExpression(dse_dm_QuestController Main, Actor Who, Bool Enable) Global
{set a face expression.}

	;; todo

	Return
EndFunction

Function ImmersiveSoundMoan(dse_dm_QuestController Main, Actor Who, Bool Hard=FALSE) Global
{perform a sound effect.}

	;; todo

	Return
EndFunction
