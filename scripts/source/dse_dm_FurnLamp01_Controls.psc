ScriptName dse_dm_FurnLamp01_Controls extends dse_dm_ActiConnectedObject

Actor Property MountedActor Auto Hidden
Int Property Level=0 Auto Hidden
Int Property Limit=7 Auto Hidden

Event OnActorMounted(Actor Who, Int SlotNum)
	self.MountedActor = Who
	self.Level = SlotNum
	Return
EndEvent

Event OnActivate(ObjectReference What)

	self.Disable()
	self.Level += 1

	If(self.Level >= self.Limit)
		self.Level = 0
	EndIf

	;;;;;;;;

	self.Device.MountActor(self.MountedActor,self.Level)
	Return
EndEvent
