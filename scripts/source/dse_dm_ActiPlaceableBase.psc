Scriptname dse_dm_ActiPlaceableBase extends ObjectReference

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_dm_QuestController Property Main Auto
{link to the main api.}

String Property DeviceID="" Auto
{this should be set to the name of the json file that defines this device.}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; informational properties.

String Property File Auto Hidden
Form[] Property ObjectsIdle Auto Hidden
Form[] Property ObjectsUsed Auto Hidden

;; active tracking properties.

Actor[] Property Actors Auto Hidden
Form[] Property Objects Auto Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnLoad()
EndEvent

Event OnActivate(ObjectReference What)
EndEvent

Event OnUpdate()
EndEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function Prepare()
{handle setting everything up when furniture is placed.}

	Int ActorCount
	Int ObjectsIdleCount
	Int ObjectsUsedCount

	;;;;;;;;

	self.File = Main.Devices.GetFileByID(self.DeviceID)
	ActorCount = Main.Devices.GetDeviceActorSlotCount(self.File)
	ObjectsIdleCount = Main.Devices.GetDeviceObjectsIdleCount(self.File)
	ObjectsUsedCount = Main.Devices.GetDeviceObjectsUsedCount(self.File)

	self.Actors = PapyrusUtil.ActorArray(ActorCount)
	self.ObjectsIdle = Utility.CreateFormArray(ObjectsIdleCount)
	self.ObjectsUsed = Utility.CreateFormArray(ObjectsUsedCount)

	Main.Util.PrintDebug(self.DeviceID + " Prepare " + ActorCount + " actor slots")
	Main.Util.PrintDebug(self.DeviceID + " Prepare " + ObjectsIdleCount + " objects when idle")
	Main.Util.PrintDebug(self.DeviceID + " Prepare " + ObjectsUsedCount + " objects when used")

	;;;;;;;;

	Main.Devices.Register(self)
	self.GotoState("Idle")
	self.RegisterForSingleUpdate(30)

	Main.Util.Print(self.DeviceID + " is ready.")
	Return
EndFunction

Function PlaceObjectsIdle()
{place objects in the scene when the furniture is idle.}

	If(self.ObjectsIdle.Length == 0)
		Return
	EndIf

	Return
EndFunction

Function PlaceObjectsUsed()
{place objects in the scene when the furniture is in use.}

	If(self.ObjectsUsed.Length == 0)
		Return
	EndIf

	Return
EndFunction

Form Function GetGhostForm()
{get the ghost object for use during move mode}

	Return Main.Devices.GetDeviceGhost(self.File)
EndFunction

Bool Function IsLegit()
{game seems to let me force any object reference i want as this subscript type
so rather than randomly accessing properties that are empty i want to be able
to test if this is a legit furniture first.}

	Return self.HasKeyword(Main.KeywordFurniture)
EndFunction

Int Function GetMountedActorCount()
{get how many actors we have mounted.}

	Int Output = 0
	Int Iter = 0

	While(Iter < self.Actors.Length)
		If(self.Actors[Iter] != None)
			Output += 1
		EndIf

		Iter += 1
	EndWhile

	Return Output
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function Move()
{kick in the grab object system on this thing.}

	StorageUtil.SetFormValue(Main.Player,Main.DataKeyGrabObjectTarget,self)
	Main.Player.AddSpell(Main.SpellGrabObject)

	Return
EndFunction

Function PickUp()
{return the furniture to your inventory.}

	Form DeviceItem = Main.Devices.GetDeviceInventoryItem(self.File)

	Main.Player.AddItem(DeviceItem,1)
	Main.Devices.Unregister(self)
	self.Disable()
	self.Delete()
	
	Return
EndFunction

Function ActivateByPlayer()
{when the player clicks on this device.}

	Int PlayersChoice = Main.MenuDeviceIdleActivate()

	If(PlayersChoice == 1)
		self.Move()
	ElseIf(PlayersChoice == 2)
		self.PickUp()
	ElseIf(PlayersChoice == 3)
		self.AssignNPC()
	ElseIf(PlayersChoice == 4)
		;;self.UseByPlayer()
	EndIf

	Return
EndFunction

Function ActivateByActor(Actor Who, Int Slot=-1)
{when an npc clicks on this device.}

	Int Iter = 0

	;; find out if we have any free slots. allow for an actor to reactivate
	;; a slot they are already in tho.

	If(Slot == -1)
		While(Iter < self.Actors.Length)
			If(self.Actors[Iter] == None || self.Actors[Iter] == Who)
				Slot = Iter
			EndIf
			Iter += 1
		EndWhile
	Else
		If(self.Actors[Slot] != None && self.Actors[Slot] != Who)
			Main.Util.Print(self.DeviceID + " slot " + Slot + " is not empty.")
			Return
		EndIf
	EndIf

	;; bail if we don't have any free slots.

	If(Slot == -1)
		Main.Util.Print(self.DeviceID + " has no empty actor slots.")
		Return
	EndIf

	;; slot the actor.

	self.UseByActor(Who,Slot)

	Return
EndFunction

Function UseByActor(Actor Who, Int Slot)
{force an actor to use this device and slot.}

	Package Task
	String SlotName
	String DeviceName

	;; make sure its empty (unless its the same actor to allow reapply)

	If(self.Actors[Slot] != None && self.Actors[Slot] != Who)
		Main.Util.Print(self.DeviceID + " slot " + Slot + " slot is not empty.")
		Return
	EndIf

	;; make sure we know what to do.

	Task = Main.Devices.GetDeviceActorSlotPackage(self.File,Slot)
	SlotName = Main.Devices.GetDeviceActorSlotName(self.File,Slot)
	DeviceName = Main.Devices.GetDeviceName(self.File)

	If(Task == None)
		Main.Util.PrintDebug("UseByActor no package found for " + self.DeviceID + " " + Slot)
		Return
	EndIf

	;; the infamous slomoroto anti-collision hack.

	Who.SplineTranslateTo(         \
		self.GetPositionX(),       \
		self.GetPositionY(),       \
		self.GetPositionZ(),       \
		self.GetAngleX(),          \
		self.GetAngleY(),          \
		(self.GetAngleZ() + 0.01), \
		1.0,10000,0.000001         \
	)

	;; assuming direct control

	Main.Devices.RegisterActor(Who,self,Slot)	
	Main.Util.HighHeelsCancel(Who)
	Main.Util.ScaleCancel(Who)
	Main.Util.BehaviourSet(Who,Task)
	Who.MoveTo(self)

	Main.Util.Print(Who.GetDisplayName() + " is now mounted to " + DeviceName + ": " + SlotName)
	Return
EndFunction

Function ReleaseActor(Actor Who)
{release the specified actor from this device.}

	Int Iter = 0
	Bool Found = FALSE

	While(Iter < self.Actors.Length)
		If(self.Actors[Iter] == Who)
			self.ReleaseActorSlot(Iter)
			Found = TRUE
		EndIf

		Iter += 1
	EndWhile

	If(!Found)
		Main.Util.PrintDebug(self.DeviceID + " ReleaseActor " + Who.GetDisplayName() + " not found on device.")
	EndIf

	Return
EndFunction

Function ReleaseActorSlot(Int Slot)
{release the specified slot from this device.}

	Float[] Pos = Main.Util.GetPositionAtDistance(self,50)

	If(Slot < 0 || Slot >= self.Actors.Length)
		Main.Util.PrintDebug(self.DeviceID + " ReleaseSlot " + Slot + " out of range.")
		Return
	EndIf

	;; move them away.

	self.Actors[Slot].SetPosition(Pos[1],Pos[2],Pos[3])
	self.Actors[Slot].StopTranslation()

	;; reset their behaviour.

	Main.Util.BehaviourSet(self.Actors[Slot],None)
	Main.Util.HighHeelsResume(self.Actors[Slot])
	Main.Util.ScaleResume(self.Actors[Slot])
	Main.Devices.UnregisterActor(self.Actors[Slot],self,Slot)

	Return
EndFunction

Function Refresh()
{update any actors on this device to force them to be doing what we want them
to be doing.}

	Int Iter

	While(Iter < self.Actors.Length)
		If(self.Actors[Iter] != None)
			Main.Util.PrintDebug(self.DeviceID + " refresh actor " + Iter + " " + self.Actors[Iter].GetDisplayName())
			self.UseByActor(self.Actors[Iter],Iter)
		EndIf;
		Iter += 1
	EndWhile

	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function HandlePeriodicUpdates()

	Int ActorCount = self.GetMountedActorCount()

	;;;;;;;;

	If(ActorCount == 0)
		Return 
	EndIf

	;;;;;;;;

	self.UpdateArousals()
	self.Moan()

	Return
EndFunction

Function Moan()
{do a moaning sound effect from one of the actors on the device.}

	Int Iter = 0
	Int Slot = -1

	;; choose a random slot to do the moan. will try up to 16
	;; times until it accidentally picks a slot tha thas an
	;; actor in it.

	While(Iter < 16)
		Slot = Utility.RandomInt(0,(self.Actors.Length - 1))

		If(self.Actors[Slot] != None)
			;; @todo moan
			Return
		EndIf

		Iter += 1
	EndWhile

	Return
EndFunction

Function UpdateArousals()
{update arousal on actors.}

	Int Iter = 0

	While(Iter < self.Actors.Length)
		If(self.Actors[Iter] != None)
			;; @todo update sexlab arousal
		EndIf

		Iter += 1
	EndWhile

	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function AssignNPC()
{begin the npc selection process.}

	String[] Names
	Int Selected

	;;;;;;;;

	Main.Util.Print("Select a position on the device...")
	Names = Main.Devices.GetDeviceActorSlotNameList(self.File)
	Selected = Main.MenuFromList(Names)

	If(Selected < 0)
		Main.Util.PrintDebug("AssignNPC no pose selected")
		Return
	EndIf

	If(Selected >= self.Actors.Length)
		Main.Util.PrintDebug("AssignNPC " + Selected + " out of slot range (" + self.Actors.Length + ")")
		Return
	EndIf

	If(self.Actors[Selected] != None)
		Main.Util.PrintDebug("AssignNPC " + Selected + " is already occupied by " + self.Actors[Selected].GetDisplayName())
		Return
	EndIf

	;;;;;;;;

	StorageUtil.SetFormValue(Main.Player,"DM3.AssignNPC.Device",self)
	StorageUtil.SetIntValue(Main.Player,"DM3.AssignNPC.Slot",Selected)

	Main.Util.Print("Select an NPC to assign...")
	Main.Player.AddSpell(Main.SpellAssignNPC)

	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Auto State Initial

	Event OnLoad()
		{handle the device being spawned in the world.}
		
		If(self.DeviceID == "")
			Debug.MessageBox("DeviceID was not set.")
			Return
		EndIf

		Main.Util.PrintDebug(self.DeviceID + " Load First Time")
		self.UnregisterForUpdate()
		self.RegisterForSingleUpdate(0.25)
		Return
	EndEvent

	Event OnUpdate()
		{finish setting up the device.}

		self.Prepare()
		Return
	EndEvent

EndState

State Idle

	Event OnLoad()
		{handle the device being re-loaded.}
		
		Main.Util.PrintDebug(self.DeviceID + " Load While Idle")
		self.Refresh()

		Return
	EndEvent

	Event OnActivate(ObjectReference What)

		If(What == Main.Player)
			self.ActivateByPlayer()
		Else
			self.ActivateByActor(What as Actor)
		Endif

		Return
	EndEvent

	Event OnUpdate()
		self.HandlePeriodicUpdates()
		self.RegisterForSingleUpdate(30)
		Return
	EndEvent

EndState

State Used

EndState
