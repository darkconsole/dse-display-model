ScriptName dse_dm_FurnLemonade01_TapMarker extends dse_dm_ActiConnectedObject

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Int Property FuckOffFactor=2 Auto
{chance an actor will fuck off after getting some lemonade.}

Int Property Price=1 Auto
{how much gold to take from npcs.}

MiscObject Property Gold Auto
{currency form from ck.}

Container Property DepositBox Auto
{type of depositbox container from ck.}

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
		self.Storage = Game.FindClosestReferenceOfType(self.DepositBox,self.X,self.Y,self.Z,69)
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

	dse_dm_QuestController DM = dse_dm_QuestController.GetAPI()

	;; trick the actor who got some lemonade to fuck off, or else they will stand
	;; there for literally ever never stopping to drink.

	If(Utility.RandomInt(0,self.FuckOffFactor) > 0)
		self.Disable()
		DM.Util.BehaviourSet(Who,DM.PackageDoNothing)
		Utility.Wait(0.35)
		DM.Util.BehaviourSet(Who,NONE)
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
	self.FindTheStorageBox()
	self.FindTheLocation()
	Return
EndEvent

Event OnDeviceUpdate()
{handle making money passively while out of town.}

	dse_dm_QuestController DM = dse_dm_QuestController.GetAPI()
	Float Now = Utility.GetCurrentRealTime()
	Int Earning = 0

	If(self.Is3dLoaded())
		;; if the 3d is loaded we're close enough for passive ai to sandbox
		;; to the device.
		Return
	EndIf

	If((self.LastTime > Now) || ((Now - self.LastTime) >= self.PassiveTime))
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
			Debug.Notification(self.Seller.GetDisplayName() + "'s lemonade stand earned some money while you were out.")
			DM.Util.PrintDebug(self.Seller.GetDisplayName() + "'s lemonade stand earned some money while you were out.")
			self.Storage.AddItem(self.Gold,Earning)
		EndIf

		self.LastTime = Now
	EndIf

	Return
EndEvent

Event OnActivate(ObjectReference Whom)
{sell some fukken lemonade.}

	dse_dm_QuestController DM = dse_dm_QuestController.GetAPI()
	Actor Who = Whom As Actor

	;;;;;;;;

	If(Who == NONE)
		DM.Util.PrintDebug("Lemonade Stand " + self + " not activated by an actor.")
		Return
	EndIf

	If(!self.FindTheStorageBox())
		DM.Util.PrintDebug("Lemonade Stand " + self + " cannot find a deposit box.")
		self.FuckOffMate(Who)
		Return
	EndIf

	;;;;;;;;

	;; give us the money we earned.

	DM.Util.PrintDebug(self.Seller.GetDisplayName() + " sold some lemonade.")
	self.Storage.AddItem(self.Gold,self.Price)
	self.FuckOffMate(Who)

	Return
EndEvent
