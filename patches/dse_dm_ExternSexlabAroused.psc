ScriptName dse_dm_ExternSexlabAroused extends Quest Conditional
{version: disabled}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Bool Function GetPatchStatus() Global
{status of patch.}

	Return FALSE
EndFunction

Form Function GetArousalAPI(dse_dm_QuestController Main) Global
{get the arousal api object.}

	Return None
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Bool Function ActorArousalExhib(dse_dm_QuestController Main, Actor Who) Global
{ask sla if the actor is an exhibitionist.}

	Return FALSE
EndFunction

Int Function ActorArousalGet(dse_dm_QuestController Main, Actor Who) Global
{ask sla for an actor's arousal.}

	Return 0
EndFunction

Function ActorArousalUpdate(dse_dm_QuestController Main, Actor Who, Int Exposure, String Reason) Global
{tell sla to modify arousal.}

	Return
EndFunction
