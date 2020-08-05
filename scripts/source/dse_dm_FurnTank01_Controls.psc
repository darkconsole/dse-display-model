ScriptName dse_dm_FurnTank01_Controls extends dse_dm_ActiConnectedObject

Message Property MessageBox Auto
Actor Property MountedActor Auto Hidden
Int Property Level=0 Auto Hidden

Event OnActorMounted(Actor Who, Int SlotNum)

	self.MountedActor = Who
	self.Level = SlotNum
	Return
EndEvent

Event OnActivate(ObjectReference What)

	Int Choice = self.MessageBox.Show()

	;;;;;;;;

	If(Choice == 4)
		;; cancel.
		Return
	EndIf

	;;;;;;;;

	If(Choice == 0 && self.Level < 10)
		self.Level += 1
	EndIf

	If(Choice == 1 && self.Level > 0)
		self.Level -= 1
	EndIf

	If(Choice == 2)
		self.Level = 10
	EndIf

	If(Choice == 3)
		self.Level = 0
	EndIf

	;;;;;;;;

	self.Device.MountActor(self.MountedActor,self.Level)
	Return
EndEvent
