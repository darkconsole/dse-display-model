ScriptName dse_dm_FurnLemonade01_Controls extends dse_dm_ActiConnectedObject

Potion Property PotionToAdd Auto
Int Property TimeToAdd=1200 Auto ;; 1200 = 20 minutes
Int Property PotionPrice=1 Auto  ;; gold to take from npcs

Actor Property MountedActor Auto Hidden
Float Property LastTime=0.0 Auto Hidden

Event OnLoad()

	Float Now = Utility.GetCurrentRealTime()

	If(self.LastTime > Now)
		;; this means the game was rebooted.
		self.LastTime = Now
	EndIf

	self.SetActorOwner(Game.GetPlayer().GetActorBase())
	Return
EndEvent

Event OnActorMounted(Actor Who, Int SlotNum)
	self.MountedActor = Who
	Return
EndEvent

Event OnDeviceUpdate()

	Float Now = Utility.GetCurrentRealTime()

	If((Now - self.LastTime) >= self.TimeToAdd)
		self.Device.Main.Util.PrintDebug(self.MountedActor + " has produced a bottle of lemonade")
		self.AddItem(self.PotionToAdd,1)
		self.LastTime = Now
	EndIf

	Return
EndEvent
