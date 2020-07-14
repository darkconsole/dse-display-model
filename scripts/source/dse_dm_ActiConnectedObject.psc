ScriptName dse_dm_ActiConnectedObject extends ObjectReference

dse_dm_ActiPlaceableBase Property Device Auto Hidden
Int Property Slot = -1 Auto Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; overload api
;; these functions are intended to be overwritten to do things that you want to
;; actually do when these happen.

Event OnLoad()

	Return
EndEvent

Function OnActorMounted(Actor Who, Int Slot)

	Return
EndFunction

Function OnActorReleased(Actor Who, Int Slot)

	Return
EndFunction

Function OnDeviceUpdate()

	Return
EndFunction
