ScriptName dse_dm_FurnLemonade01_TapContainer extends dse_dm_ActiConnectedObject

Potion Property PotionToAdd Auto
Int Property TimeToAdd=1200 Auto ;; 1200 = 20 minutes
Int Property PotionPrice=1 Auto  ;; gold to take from npcs

Actor Property Seller Auto Hidden
Float Property LastTime=0.0 Auto Hidden

Event OnLoad()

	Float Now = Utility.GetCurrentRealTime()

	If(self.LastTime > Now)
		;; this means the game was rebooted.
		self.LastTime = Now - self.LastTime
	EndIf

	self.SetActorOwner(Game.GetPlayer().GetActorBase())
	Return
EndEvent

Event OnDevicePickup()
{when this device is picked up transfer the contents of this container to the player.}

	Int ItemTypeIter = self.GetNumItems()
	Form Thing
	Int ThingCount

	While(ItemTypeIter > 0) 
		ItemTypeIter -= 1

		Thing = self.GetNthForm(ItemTypeIter)
		ThingCount = self.GetItemCount(Thing)

		self.RemoveItem(Thing,ThingCount,FALSE,self.Device.Main.Player)
	EndWhile

	Return
EndEvent

Event OnActorMounted(Actor Who, Int SlotNum)
{notice when an actor is added to this device.}

	self.Seller = Who
	self.LastTime = Utility.GetCurrentRealTime()
	Return
EndEvent

Event OnDeviceUpdate()
{periodic checks if we generate lemonade or not.}

	Float Now = Utility.GetCurrentRealTime()

	;; nobody on this device don't generate lemonade.
	;; technically we shouldn't even be getting device update events
	;; if nobody is mounted, but.

	If(self.Seller == None)
		self.LastTime = Now
		Return
	EndIf

	;; if enough time has passed then give us some 'nade.

	If((Now - self.LastTime) >= self.TimeToAdd)
		self.Device.Main.Util.PrintDebug(self.Seller.GetDisplayName() + " has produced a bottle of lemonade")
		self.AddItem(self.PotionToAdd,1)
		self.LastTime = Now
	EndIf

	Return
EndEvent
