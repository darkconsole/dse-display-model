ScriptName dse_dm_FurnLemonade01_TapContainer extends dse_dm_ActiConnectedObject
{script for the main cointainer of the lemonade stand. it handles the passive
generation of bottles of lemonade and stores them in itself. it also handles
dumping anything inside itself to the player when a display model furniture is
picked up.}

Potion Property PotionToAdd Auto
Int Property TimeToAdd=1200 Auto ;; 1200 = 20 minutes

Actor Property Seller Auto Hidden
Float Property LastTime=0.0 Auto Hidden
ObjectReference Property GoldStorage Auto Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Float Function FindTimeSinceLastTime(Float Now=0.0)
{find how long its been since our last check.}

	If(Now == 0.0)
		Now = Utility.GetCurrentRealTime()
	EndIf

	;; first handle a condition where the game has been
	;; rebooted since last time the device was checked.

	If(self.LastTime > Now)
		self.LastTime = Now - self.LastTime
	EndIf

	Return Now - self.LastTime
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnLoad()

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
	Int HowMany = 1

	;; nobody on this device don't generate lemonade.
	;; technically we shouldn't even be getting device update events
	;; if nobody is mounted, but.

	If(self.Seller == None)
		self.LastTime = Now
		Return
	EndIf

	;; if enough time has passed then give us some 'nade.

	If(self.FindTimeSinceLastTime(Now) >= self.TimeToAdd)
		StorageUtil.AdjustIntValue(self.Seller,"DMSE.LemonadeStand.Bottles",HowMany)
		self.Device.Main.Util.PrintDebug(self.Seller.GetDisplayName() + " has produced a bottle of lemonade")
		self.AddItem(self.PotionToAdd,HowMany)
		self.LastTime = Now
	EndIf

	Return
EndEvent
