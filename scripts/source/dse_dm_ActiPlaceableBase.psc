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

	self.PlaceObjectsIdle()
	Main.Devices.Register(self)
	self.GotoState("Idle")

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

Function Move()
{kick in the grab object system on this thing.}

	StorageUtil.SetFormValue(Main.Player,Main.DataKeyGrabObjectTarget,self)
	Main.Player.AddSpell(Main.SpellGrabObject)

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function ActivateByPlayer()

	Int PlayersChoice = Main.MenuDeviceIdleActivate()

	If(PlayersChoice == 1)
		self.Move()
	ElseIf(PlayersChoice == 2)
		;;self.PickUp()
	ElseIf(PlayersChoice == 3)
		self.AssignNPC()
	ElseIf(PlayersChoice == 4)
		;;self.UseByPlayer()
	EndIf

	Return
EndFunction

Function ActivateByActor(Actor Who, Int Slot=-1)

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
		If(self.Actors[Iter] != None && self.Actors[Iter] != Who)
			Main.Util.Print(self.DeviceID + " slot " + Slot + " slot is not empty.")
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

	Package Task

	;; make sure its empty (unless its the same actor to allow reapply)

	If(self.Actors[Slot] != None && self.Actors[Slot] != Who)
		Main.Util.Print(self.DeviceID + " slot " + Slot + " slot is not empty.")
		Return
	EndIf

	;; make sure we know what to do.

	Task = Main.Devices.GetDeviceActorSlotPackage(self.File,Slot)

	If(Task == None)
		Main.Util.PrintDebug("UseByActor no package found for " + self.DeviceID + " " + Slot)
		Return
	EndIf

	;; assuming direct control
	
	Main.Devices.RegisterActor(Who,self,Slot)
	Main.Util.BehaviourSet(Who,Task)
	Main.Util.HighHeelsCancel(Who)
	Main.Util.ScaleCancel(Who)

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

	Who.MoveTo(self)

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

	Float[] Pos = Main.Util.GetPositionAtDistance(self,128)

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function AssignNPC()

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
		
		Int Iter

		Main.Util.PrintDebug(self.DeviceID + " Load While Idle")

		While(Iter < self.Actors.Length)
			self.UseByActor(self.Actors[Iter],Iter)
			Iter += 1
		EndWhile

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

EndState

State Used

EndState
