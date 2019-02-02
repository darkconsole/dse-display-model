ScriptName dse_dm_EffectActorMoan extends ActiveMagicEffect

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_dm_QuestController Property Main Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnEffectStart(Actor Who, Actor Caster)
	
	If(Main.Config.GetBool(".DeviceActorExpression"))
		Main.Util.ImmersiveExpression(Who,TRUE)
	EndIf

	If(Main.Config.GetBool(".DeviceActorMoan"))
		Main.Util.ImmersiveSoundMoan(Who,FALSE)
	EndIf

	Return
EndEvent

Event OnEffectFinish(Actor Who, Actor Caster)
	Main.Util.ImmersiveExpression(Who,FALSE)
	Return
EndEvent
