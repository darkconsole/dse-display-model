ScriptName dse_dm_ExternSexlabAroused extends Quest Conditional

Bool Function GetPatchStatus() Global
{status of patch.}

	Return TRUE
EndFunction

Bool Function ActorArousalExhib(dse_dm_QuestController Main, Actor Who) Global
{ask sla if the actor is an exhibitionist.}

	Return (Main.Aroused as slaFrameworkScr).IsActorExhibitionist(Who)
EndFunction

Int Function ActorArousalGet(dse_dm_QuestController Main, Actor Who) Global
{ask sla for an actor's arousal.}

	If(Main.Aroused == None)
		Return 0
	EndIf

	Return (Main.Aroused as slaFrameworkScr).GetActorExposure(Who)
EndFunction

Function ActorArousalUpdate(dse_dm_QuestController Main, Actor Who, Int Exposure, String Reason) Global
{tell sla to modify arousal.}

	(Main.Aroused as slaFrameworkScr).UpdateActorExposure(Who,Exposure,Reason)
	Return
EndFunction
