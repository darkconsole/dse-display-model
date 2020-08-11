ScriptName dse_dm_FurnLemonade01_TapMarker extends dse_dm_ActiConnectedObject
{script for the furniture marker that attracts npcs to buy lemonade. it will handle
taking the npc's money as well as simulation of earning money while you are away
from the city.}

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

Event OnActorReleased(Actor Who, Int SlotNum)
{just a simple way to get the career totals for now.}

	Int Earned = StorageUtil.GetIntValue(Who,"DMSE.LemonadeStand.Gold")
	Int Produced = StorageUtil.GetIntValue(Who,"DMSE.LemonadeStand.Bottles")
	String Msg = Who.GetDisplayName()

	Msg += " has produced " + Produced + " bottles"
	Msg += " and earned " + Earned + "g in their lemonade career." 

	self.Device.Main.Util.Print(Msg)
	Return
EndEvent

Event OnActivate(ObjectReference Whom)
{sell some fukken lemonade.}

	Actor Who = Whom As Actor
	Int Earning = self.Price

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

	self.Device.Main.Util.PrintDebug(self.Seller.GetDisplayName() + " sold a lemonade for " + Earning + "g.")
	self.Storage.AddItem(self.Device.Main.ItemGold,Earning)
	self.FuckOffMate(Who)

	Return
EndEvent

Event OnDeviceUpdate()
{continue selling some fukken lemonade.}

	Float Now = Utility.GetCurrentRealTime()
	Int Earn = 0
	Int EarnMult = 1
	Int Earning

	If(self.Device.Is3dLoaded())
		;; if the 3d is loaded we're close enough for passive ai to sandbox
		;; to the device.
		Return
	EndIf

	If(self.FindTimeSinceLastTime(Now) >= self.PassiveTime)
		;; enough time has passed lets try to earn some gold.

		If(self.Here.HasKeyword(self.KeywordLocationInn))
			;; inns are high traffic areas and have a chance to earn double.
			;; but there is also chance innkeepers will steal from you since
			;; you put that shit up in their business and left it. you probably
			;; didn't even ask them so its your own fault.
			Earn = self.Price
			EarnMult = Utility.RandomInt(0,2)
		ElseIf(self.Here.HasKeyword(self.KeywordLocationCity))
			;; cities have lots of foot traffic and have a chance to earn more
			;; but there is also a chance people are staying home to not get
			;; the coronavirus.
			Earn = self.Price
			EarnMult = Utility.RandomInt(0,3)
		ElseIf(self.Here.HasKeyword(self.KeywordLocationTown))
			;; towns are low traffic areas, they will earn the base amount.
			;; but the people there appreciate your attempt to stimulate their
			;; economy so while it earns less, it earns it consistently.
			Earn = self.Price
			EarnMult = 1
		EndIf

		If(Earn > 0)
			;; if we have earned some money give it to us.
			Earning = Earn * EarnMult

			StorageUtil.AdjustIntValue(self.Seller,"DMSE.LemonadeStand.Gold",Earning)
			self.Device.Main.Util.PrintDebug(self.Seller.GetDisplayName() + "'s lemonade stand earned " + Earning + "g while you were out.")
			self.Storage.AddItem(self.Device.Main.ItemGold,Earning)
		EndIf

		self.LastTime = Now
	EndIf

	Return
EndEvent
