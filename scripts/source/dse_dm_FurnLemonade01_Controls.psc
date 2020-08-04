ScriptName dse_dm_FurnLemonade01_Controls extends dse_dm_ActiConnectedObject

Potion Property PotionToAdd Auto
Int Property TimeToAdd=1800 Auto ;; 1800 = 30 minutes

Actor Property MountedActor Auto Hidden
Float Property LastTime=0.0 Auto Hidden

Event OnLoad()
	self.LastTime = Utility.GetCurrentRealTime()
	Return
EndEvent

Event OnActorMounted(Actor Who, Int SlotNum)
	self.MountedActor = Who
	self.LastTime = Utility.GetCurrentRealTime()
	Return
EndEvent

Event OnDeviceUpdate()

	Float Now = Utility.GetCurrentRealTime()

	If((Now - self.LastTime) >= self.TimeToAdd)
		self.LastTime = Now
		self.AddItem(self.PotionToAdd,1)
	EndIf

	Return
EndEvent
