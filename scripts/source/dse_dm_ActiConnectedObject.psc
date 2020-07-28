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

Event OnActorMounted(Actor Who, Int SlotNum)

	Return
EndEvent

Event OnActorReleased(Actor Who, Int SlotNum)

	Return
EndEvent

Event OnDeviceUpdate()

	Return
EndEvent
