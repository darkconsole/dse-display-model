ScriptName dse_dm_ExternSexlabAroused extends Quest Conditional
{version: enabled}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Bool Function GetPatchStatus() Global
{status of patch.}

	Return TRUE
EndFunction

Form Function GetArousalAPI(dse_dm_QuestController Main) Global
{get the arousal api object.}

	slaFrameworkScr Aroused = Main.Util.GetFormFrom("SexLabAroused.esm",0x4290f) as slaFrameworkScr

	Return Aroused
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Bool Function ActorArousalExhib(dse_dm_QuestController Main, Actor Who) Global
{ask sla if the actor is an exhibitionist.}

	slaFrameworkScr Aroused = GetArousalAPI(Main) as slaFrameworkScr

	If(Aroused != NONE)
		Return Aroused.IsActorExhibitionist(Who)
	EndIf

	Return FALSE
EndFunction

Int Function ActorArousalGet(dse_dm_QuestController Main, Actor Who) Global
{ask sla for an actor's arousal.}

	slaFrameworkScr Aroused = GetArousalAPI(Main) as slaFrameworkScr

	If(Aroused != None)
		Return Aroused.GetActorExposure(Who)
	EndIf

	Return 0
EndFunction

Function ActorArousalUpdate(dse_dm_QuestController Main, Actor Who, Int Exposure, String Reason) Global
{tell sla to modify arousal.}

	slaFrameworkScr Aroused = GetArousalAPI(Main) as slaFrameworkScr

	If(Aroused)
		Aroused.UpdateActorExposure(Who,Exposure,Reason)
	EndIf

	Return
EndFunction
