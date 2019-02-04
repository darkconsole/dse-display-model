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

	;;;;;;;;

	self.File = Main.Devices.GetFileByID(self.DeviceID)
	ActorCount = Main.Devices.GetDeviceActorSlotCount(self.File)

	self.Actors = PapyrusUtil.ActorArray(ActorCount)

	Main.Util.PrintDebug(self.DeviceID + " Prepare " + ActorCount + " actor slots")

	;;;;;;;;

	Main.Devices.Register(self)
	self.GotoState("Idle")
	self.RegisterForSingleUpdate(30)

	Main.Util.Print(self.DeviceID + " is ready.")
	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Bool Function IsLegit()
{game seems to let me force any object reference i want as this subscript type
so rather than randomly accessing properties that are empty i want to be able
to test if this is a legit furniture first.}

	Return self.HasKeyword(Main.KeywordFurniture)
EndFunction

Form Function GetGhostForm()
{get the ghost object for use during move mode}

	Return Main.Devices.GetDeviceGhost(self.File)
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

	self.MountActor(Who,Slot)

	Return
EndFunction

Function MountActor(Actor Who, Int Slot, Bool ForceObjects=FALSE)
{force an actor to use this device and slot.}

	Package Task
	String SlotName
	String DeviceName
	Bool AlreadyThere = FALSE
	Bool ConfigHeadTracking = FALSE
	Bool ToggleHeadTracking = FALSE

	;; make sure its empty (unless its the same actor to allow reapply)

	If(self.Actors[Slot] != None && self.Actors[Slot] != Who)
		Main.Util.Print(self.DeviceID + " slot " + Slot + " slot is not empty.")
		Return
	EndIf

	If(self.Actors[Slot] == Who)
		AlreadyThere = TRUE
	EndIf

	;; make sure we know what to do.

	Task = Main.Devices.GetDeviceActorSlotPackage(self.File,Slot)
	SlotName = Main.Devices.GetDeviceActorSlotName(self.File,Slot)
	DeviceName = Main.Devices.GetDeviceName(self.File)

	If(Task == None)
		Main.Util.PrintDebug("MountActor no package found for " + self.DeviceID + " " + Slot)
		Return
	EndIf

	;; disable headtracking.

	Who.SetHeadTracking(FALSE)
	ConfigHeadTracking = Main.Config.GetBool(".DeviceActorHeadTracking")
	ToggleHeadTracking = Who.IsInFaction(Main.FactionActorToggleHeadTracking)

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

	If(!AlreadyThere || ForceObjects)
		self.SpawnActorObjects(Who,Slot)
	EndIf

	If((ConfigHeadTracking && !ToggleHeadTracking) || (!ConfigHeadTracking && ToggleHeadTracking))
		If(Main.Devices.GetDeviceActorSlotHeadTracking(self.File,Slot))
			Who.SetHeadTracking(TRUE)
		EndIf
	EndIf

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

	self.ClearActorObjects(self.Actors[Slot],Slot)
	Main.Util.BehaviourSet(self.Actors[Slot],None)
	Main.Util.HighHeelsResume(self.Actors[Slot])
	Main.Util.ScaleResume(self.Actors[Slot])
	Main.Devices.UnregisterActor(self.Actors[Slot],self,Slot)
	self.Actors[Slot].SetHeadTracking(TRUE)

	Return
EndFunction

Function Refresh(Bool ForceObjects=FALSE)
{update any actors on this device to force them to be doing what we want them
to be doing.}

	Int Iter

	While(Iter < self.Actors.Length)
		If(self.Actors[Iter] != None)
			Main.Util.PrintDebug(self.DeviceID + " refresh actor " + Iter + " " + self.Actors[Iter].GetDisplayName())
			self.MountActor(self.Actors[Iter],Iter,ForceObjects)
		EndIf;
		Iter += 1
	EndWhile

	Return
EndFunction

Function ClearActorObjects(Actor Who, Int Slot=-1)
{clean up objects placed by this actor when it was mounted.}

	String DeviceKey
	Int ItemCount
	Int Iter
	ObjectReference Item

	;;;;;;;;

	If(Slot == -1)
		Main.Devices.GetActorSlot(Who)
	EndIf

	If(self.Actors[Slot] != Who)
		Main.Util.PrintDebug("ClearActorObjects " + Who.GetDisplayName() + " is not " + self.DeviceID + " " + Slot)
		Return
	EndIf

	;;;;;;;;

	DeviceKey = "DM3.DeviceObjects." + self.DeviceID 
	ItemCount = StorageUtil.FormListCount(Who,DeviceKey)

	Main.Util.PrintDebug("ClearActorObjects " + Who.GetDisplayName() + " " + DeviceKey + " has " + ItemCount + " objects")

	Iter = 0
	While(Iter < ItemCount)
		Item = StorageUtil.FormListGet(Who,DeviceKey,Iter) As ObjectReference

		If(Item != None)
			Item.Disable()
			Item.Delete()
			Main.Util.PrintDebug("ClearActorObjects " + Who.GetDisplayName() + " " + DeviceKey + " " + Iter)
		EndIf

		Iter += 1
	EndWhile

	StorageUtil.FormListClear(Who,DeviceKey)

	Return
EndFunction

Function SpawnActorObjects(Actor Who, Int Slot)
{spawn objects for this actor when mounted.}

	String DeviceKey
	Int ItemCount
	Int Iter
	Form ItemForm
	Form MarkerForm
	Float[] ItemPos
	ObjectReference Item
	ObjectReference Marker
	Bool ConfigLightFace
	Bool ToggleLightFace

	;; we use the place-at-marker system to avoid some lag with the object fade-in
	;; when used with MoveTo and such. just place it in the final spot and be done.

	self.ClearActorObjects(Who,Slot)

	DeviceKey = "DM3.DeviceObjects." + self.DeviceID
	ItemCount = Main.Devices.GetDeviceActorSlotObjectCount(self.File,Slot)
	MarkerForm = Main.Util.GetFormFrom("Skyrim.esm",0x3B)
	ConfigLightFace = Main.Config.GetBool(".DeviceActorLightFace")
	ToggleLightFace = Who.IsInFaction(Main.FactionActorToggleLightFace)
	Main.Util.PrintDebug("SpawnActorObjects " + Who.GetDisplayName() + " " + DeviceKey + " needs " + ItemCount + " objects")

	Iter = 0
	While(Iter < ItemCount)
		ItemForm = Main.Devices.GetDeviceActorSlotObjectForm(self.File,Slot,Iter)
		ItemPos = Main.Devices.GetDeviceActorSlotObjectPosition(self.File,Slot,Iter)

		If(ItemForm != None)
			Marker = self.PlaceAtMe(MarkerForm,1,TRUE,FALSE)
			Marker.MoveTo(self,ItemPos[0],ItemPos[1],ItemPos[2],TRUE)

			Item = Marker.PlaceAtMe(ItemForm,1,TRUE,TRUE)
			Item.Enable(FALSE)
			Marker.Disable()
			Marker.Delete()

			StorageUtil.FormListAdd(Who,DeviceKey,Item)
			Main.Util.PrintDebug("SpawnActorObjects " + Who.GetDisplayName() + " " + DeviceKey + " " + Iter + " (" + ItemPos[0] + "," + ItemPos[1] + "," + ItemPos[2] + ")")
		EndIf

		Iter += 1
	EndWhile

	If((ConfigLightFace && !ToggleLightFace) || (!ConfigLightFace && ToggleLightFace))
		Utility.Wait(2.0)
		Main.Util.PrintDebug("SpawnActorObjects " + Who.GetDisplayName() + " " + DeviceKey + " adding face light")

		;; place a marker and align it to a node on the skeleton.
		Marker = self.PlaceAtMe(MarkerForm,1,TRUE,FALSE)
		Marker.MoveToNode(Who,"CME Neck [Neck]")

		;; move the marker away from the actor a bit in the direction its aligned.
		ItemPos = Main.Util.GetPositionAtDistance3D(Marker,40)
		Marker.SetPosition(ItemPos[1],ItemPos[2],ItemPos[3])

		;; place the lamp on the marker and clean up.
		Item = Marker.PlaceAtMe(Main.LightFace,1,TRUE,TRUE)
		Item.Enable(FALSE)
		Marker.Disable()
		Marker.Delete()

		StorageUtil.FormListAdd(Who,DeviceKey,Item)
	EndIf

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
			Main.SpellActorMoan.Cast(self.Actors[Slot],self.Actors[Slot])
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
			Main.Util.ActorArousalUpdate(self.Actors[Iter],TRUE)
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

	If(Main.Devices.GetDeviceActorSlotCount(self.File) == 1)
		Selected = 0
	Else
		Main.Util.Print("Select a position on the device...")
		Names = Main.Devices.GetDeviceActorSlotNameList(self.File)
		Selected = Main.MenuFromList(Names)

		If(Selected < 0)
			Main.Util.PrintDebug("AssignNPC no pose selected")
			Return
		EndIf
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
