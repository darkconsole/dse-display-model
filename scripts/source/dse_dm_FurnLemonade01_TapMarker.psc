ScriptName dse_dm_FurnLemonade01_TapMarker extends dse_dm_ActiConnectedObject

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Int Property FuckOffFactor=2 Auto
{chance an actor will fuck off after getting some lemonade.}

Int Property Price=1 Auto
{how much gold to take from npcs.}

Container Property StorageType Auto
{type of StorageType container from ck.}

Keyword Property KeywordLocationTown Auto
{location keyword for open locations like riverwood.}

Keyword Property KeywordLocationCity Auto
{location keyword for zoned locations like whiterun.}

Keyword Property KeywordLocationInn Auto
{location keyword for inns.}

Int Property PassiveTime=300 Auto ;; every 5 minutes
{how much time should pass to earn gold while unloaded.}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Actor Property Seller Auto Hidden
ObjectReference Property Storage Auto Hidden
Float Property LastTime=0.0 Auto Hidden
Location Property Here Auto Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Bool Function FindTheStorageBox()
{try to find a storage box for the lemonade.}

	If(self.Storage == NONE)
		self.Storage = Game.FindClosestReferenceOfType(self.StorageType,self.X,self.Y,self.Z,69)
	EndIf

	If(Storage == NONE)
		Return FALSE
	EndIf

	Return TRUE
EndFunction

Function FindTheLocation()
{find the location where this stand was set up.}

	self.Here = self.GetCurrentLocation()
	Return
EndFunction

Function FuckOffMate(Actor Who)
{leave some for the rest of us.}

	;; trick the actor who got some lemonade to fuck off, or else they will stand
	;; there for literally ever never stopping to drink.

	If(Utility.RandomInt(0,self.FuckOffFactor) > 0)
		self.Disable()
		self.Device.Main.Util.BehaviourSet(Who,self.Device.Main.PackageDoNothing)
		Utility.Wait(0.35)
		self.Device.Main.Util.BehaviourSet(Who,NONE)
		Utility.Wait(6.00)
		self.Enable()
	EndIf

	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnLoad()
{helo moto.}

	Float Now = Utility.GetCurrentRealTime()

	If(self.LastTime > Now)
		;; this means the game was rebooted.
		self.LastTime = Now - self.LastTime
	EndIf

	self.FindTheStorageBox()
	self.FindTheLocation()
	Return
EndEvent

Event OnActorMounted(Actor Who, Int SlotNum)
{keep track of who is brewing lemonade.}

	self.Seller = Who
	self.LastTime = Utility.GetCurrentRealTime()
	self.FindTheStorageBox()
	self.FindTheLocation()
	Return
EndEvent

Event OnActivate(ObjectReference Whom)
{sell some fukken lemonade.}

	Actor Who = Whom As Actor

	;;;;;;;;

	If(Who == NONE)
		self.Device.Main.Util.PrintDebug("Lemonade Stand " + self + " not activated by an actor.")
		Return
	EndIf

	If(!self.FindTheStorageBox())
		self.Device.Main.Util.PrintDebug("Lemonade Stand " + self + " cannot find a deposit box.")
		self.FuckOffMate(Who)
		Return
	EndIf

	;;;;;;;;

	;; give us the money we earned.

	self.Device.Main.Util.PrintDebug(self.Seller.GetDisplayName() + " sold some lemonade.")
	self.Storage.AddItem(self.Device.Main.ItemGold,self.Price)
	self.FuckOffMate(Who)

	Return
EndEvent

Event OnDeviceUpdate()
{continue selling some fukken lemonade.}

	Float Now = Utility.GetCurrentRealTime()
	Int Earning = 0

	If(self.Device.Is3dLoaded())
		;; if the 3d is loaded we're close enough for passive ai to sandbox
		;; to the device.
		Return
	EndIf

	If((Now - self.LastTime) >= self.PassiveTime)
		;; enough time has passed lets try to earn some gold.

		If(self.Here.HasKeyword(self.KeywordLocationInn))
			;; inns are high traffic areas, they will earn double.
			Earning = self.Price * 2
		ElseIf(self.Here.HasKeyword(self.KeywordLocationCity))
			;; cities are very busy and will earn double.
			Earning = self.Price * 2
		ElseIf(self.Here.HasKeyword(self.KeywordLocationTown))
			;; towns are low traffic areas, they will earn the base amount.
			Earning = self.Price
		EndIf

		If(Earning > 0)
			;; if we have earned some money give it to us.
			self.Device.Main.Util.PrintDebug(self.Seller.GetDisplayName() + "'s lemonade stand earned some money while you were out.")
			self.Storage.AddItem(self.Device.Main.ItemGold,Earning)
		EndIf

		self.LastTime = Now
	EndIf

	Return
EndEvent
