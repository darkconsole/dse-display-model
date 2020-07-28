ScriptName dse_dm_FurnTank01_Controls extends dse_dm_ActiConnectedObject

Message Property MessageBox Auto
Actor Property MountedActor Auto Hidden
Int Property Level=0 Auto Hidden

Event OnActorMounted(Actor Who, Int SlotNum)

	dse_dm_QuestController DM = dse_dm_QuestController.GetAPI()
	DM.Util.PrintDebug("FurnTank01.OnActorMounted: " + Who + " " + SlotNum)

	self.MountedActor = Who
	self.Level = SlotNum
	Return
EndEvent

Event OnActivate(ObjectReference What)

	dse_dm_QuestController DM = dse_dm_QuestController.GetAPI()
	Int Choice = self.MessageBox.Show()

	DM.Util.PrintDebug("FurnTank01.Activate: " + What)

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
