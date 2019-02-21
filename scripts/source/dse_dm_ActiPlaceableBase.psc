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
Float Property TimeAroused Auto Hidden
Float Property UpdateFreqIdle = 30.0 Auto Hidden
Float Property UpdateFreqUsed = 30.0 Auto Hidden

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

	Int ActorSlotCount

	;;;;;;;;

	;; get our key for accessing the json about this device.

	self.File = Main.Devices.GetFileByID(self.DeviceID)

	;; prepare an array for storing actors mounted to this device.

	ActorSlotCount = Main.Devices.GetDeviceActorSlotCount(self.File)
	self.Actors = PapyrusUtil.ActorArray(ActorSlotCount)

	self.TimeAroused = Utility.GetCurrentRealTime()
	self.UpdateFreqIdle = Main.Devices.GetDeviceUpdateFreqIdle(self.File)
	self.UpdateFreqUsed = Main.Devices.GetDeviceUpdateFreqUsed(self.File)

	;;;;;;;;

	;; register this device as placed in the world.

	Main.Devices.Register(self)

	;; change its state to idle and kick off the update loop for it.

	self.GotoState("Idle")

	;;;;;;;;

	Main.Util.Print(self.DeviceID + " is ready.")
	Return
EndFunction

Function Reload()

	Int Slot

	;; kick all the actors off.

	Slot = 0
	While(Slot < self.Actors.Length)
		If(self.Actors[Slot] != None)
			self.ReleaseActorSlot(Slot)
		EndIf

		Slot += 1
	EndWhile
	
	;; unregister ourself.

	Main.Devices.Register(self)

	self.Disable()
	self.GotoState("Initial")
	self.Enable(FALSE)

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

Bool Function IsUsed()
{check if this device is being used.}

	Int Iter = self.Actors.Length

	While(Iter > 0)
		Iter -= 1

		If(self.Actors[Iter] != None)
			Return TRUE
		EndIf
	EndWhile

	Return FALSE
EndFunction

Form Function GetGhostForm()
{get the ghost object for use during move mode}

	;; used by the positioning system. to genericify the api over there.

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

Int Function GetNextSlot(Actor Who=None)
{get the next empty slot on the device. if an actor is provided then it will
also return the slot that actor is in if they are already.}

	Int Iter = 0

	While(Iter < self.Actors.Length)
		If(self.Actors[Iter] == None)
			Return Iter
		EndIf

		If(Who != None && self.Actors[Iter] == Who)
			Return Iter
		EndIf

		Iter += 1
	EndWhile

	Return -1
Endfunction

Bool Function IsEmptySlot(Int Slot, Actor Who=None)
{check if this slot is empty or occupied by the same actor.}

	If(self.Actors[Slot] == None)
		Return TRUE
	EndIf

	If(Who != None && self.Actors[Slot] == Who)
		Return TRUE
	EndIf

	Return FALSE
EndFunction

Float Function GetScaleOverride()
{get the size this device has been set to.}

	Return StorageUtil.GetFloatValue(self,Main.DataKeyDeviceScale,1.0)
EndFunction

Function SetScaleOverride(Float Scale)
{set this device to be at a different size.}

	If(Scale != 1.0)
		StorageUtil.SetFloatValue(self,Main.DataKeyDeviceScale,Scale)
	Else
		StorageUtil.UnsetFloatValue(self,Main.DataKeyDeviceScale)
	EndIf

	Return
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
	Int Slot

	;; kick off any actors currently on it.

	Slot = 0
	While(Slot < self.Actors.Length)
		If(self.Actors[Slot] != None)
			self.ReleaseActorSlot(Slot)
		EndIf

		Slot += 1
	EndWhile

	;; and pick up the device.

	Main.Player.AddItem(DeviceItem,1)
	Main.Devices.Unregister(self)
	self.Disable()
	self.Delete()
	
	Return
EndFunction

Function ActivateByPlayer()
{when the player clicks on this device.}

	Int PlayersChoice = Main.MenuDeviceIdleActivate()
	Int Value
	Int Iter

	If(PlayersChoice == 1)
		self.Move()
	ElseIf(PlayersChoice == 2)
		self.PickUp()
	ElseIf(PlayersChoice == 3)
		self.AssignNPC()
	ElseIf(PlayersChoice == 4)
		;;self.UseByPlayer()
	ElseIf(PlayersChoice == 5)
		Value = self.ShowScaleMenu()
		If(Value > 0)
			self.SetScaleOverride((Value as Float) / 20.0)
			Main.Util.ScaleOverride(self,self.GetScaleOverride())
			self.Disable()
			self.Enable(FALSE)
			self.ScaleActorObjects()
		EndIf
	ElseIf(PlayersChoice == 6)
		self.Reload()
	EndIf

	Return
EndFunction

Function ActivateByActor(Actor Who, Int Slot=-1)
{when an npc clicks on this device.}

	;; find out if we have any free slots. allow for an actor to reactivate
	;; a slot they are already in tho.

	If(Slot == -1)
		Slot = self.GetNextSlot(Who)
	Else
		If(!self.IsEmptySlot(Slot,Who))
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function MountActor(Actor Who, Int Slot, Bool ForceObjects=FALSE)
{force an actor to use this device and slot.}

	Package Task
	Bool ConfigHeadTracking = FALSE
	Bool ToggleHeadTracking = FALSE
	Bool SameDeviceSameSlot = FALSE
	Bool SameDeviceDiffSlot = FALSE
	dse_dm_ActiPlaceableBase OldDevice
	String DeviceName = Main.Devices.GetDeviceName(self.File)
	String SlotName = Main.Devices.GetDeviceActorSlotName(self.File,Slot)

	;; make sure its empty (unless its the same actor to allow reapply)

	If(!self.IsEmptySlot(Slot,Who))
		Main.Util.Print(self.DeviceID + " " + Slot + " " + SlotName + " is not empty.")
		Return
	EndIf

	;; handle attempting to slot actors already used by other devices.

	OldDevice = Main.Devices.GetActorDevice(Who)

	;; if they are already on this device take some notes.

	If(OldDevice == self)
		If(self.Actors[Slot] == Who)
			SameDeviceSameSlot = TRUE
		Else
			SameDeviceDiffSlot = TRUE
		EndIf
	EndIf

	;; if they are on another device then release them.

	If(OldDevice != None && OldDevice != self)
		OldDevice.ReleaseActor(Who)
	EndIf

	;; make sure we know what to do.

	Task = Main.Devices.GetDeviceActorSlotPackage(self.File,Slot)

	If(Task == None)
		Main.Util.PrintDebug("MountActor no package found for " + self.DeviceID + " " + Slot)
		Return
	EndIf

	If(SameDeviceDiffSlot)
		Main.Devices.UnregisterActor(Who,self)
	EndIf

	;; disable headtracking on the actor by default early on just to give
	;; processing this rest of this script time for the head to start turning
	;; back to neutral. we mainly care to waste time later on when spawning the
	;; face light if it is enabled.

	Who.SetHeadTracking(FALSE)

	;; determine a bunch of other things we want to know before proceeding.

	ConfigHeadTracking = Main.Config.GetBool(".DeviceActorHeadTracking")
	ToggleHeadTracking = Who.IsInFaction(Main.FactionActorToggleHeadTracking)

	;; scale actor to device.

	Main.Util.ScaleCancel(Who)
	Main.Util.ScaleOverride(Who,self.GetScaleOverride())

	;; the infamous slomoroto anti-collision hack. this will put the actor
	;; above the device in a state where they have no collision for a long
	;; time, longer than anyone will likely ever be in the same room with a
	;; device by like a long long time (the 0.000001 rotation speed). this
	;; is the same trick sexlab uses during scenes.

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
	Main.Util.BehaviourSet(Who,Task)
	Main.Util.ImmersiveExpression(Who,FALSE)
	Who.MoveTo(self)

	;; if the actor was already on this device and in this slot then we can
	;; skip spawning its objects as they should already be there.

	If(SameDeviceDiffSlot)
		self.ClearActorObjects(Who,Slot)
		self.RemoveActorEquips(Who,Slot)
	EndIf

	If(!SameDeviceSameSlot)
		self.SpawnActorObjects(Who,Slot)
	EndIf

	self.EquipActorEquips(Who,Slot)

	;; determine if we should turn headtracking back on. if globally
	;; headtracking is disabled then if they are in the faction they will
	;; get it enabled. if it is enabled globally then it will be disabled.
	;; however, devices are able to have a final say if headtracking should be
	;; enabled.

	If((ConfigHeadTracking && !ToggleHeadTracking) || (!ConfigHeadTracking && ToggleHeadTracking))
		If(Main.Devices.GetDeviceActorSlotHeadTracking(self.File,Slot))
			Who.SetHeadTracking(TRUE)
		EndIf
	EndIf

	;;;;;;;;

	self.RegisterForSingleUpdate(self.UpdateFreqUsed)

	Main.Util.Print(Who.GetDisplayName() + " is now mounted to " + DeviceName + ": " + SlotName)
	Return
EndFunction

Function ReleaseActor(Actor Who)
{release the specified actor from this device.}

	Int Iter = 0
	Bool Found = FALSE

	;; search this device for this actor. if found, release it. we allow this
	;; to search the entire device just in case something weird happened as a
	;; way to passively clean up any fuckups.

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

	;; clean up slot objects.

	self.ClearActorObjects(self.Actors[Slot],Slot)
	self.RemoveActorEquips(self.Actors[Slot],Slot)

	;; let the actor behave normal again.

	Main.Util.BehaviourSet(self.Actors[Slot],None)
	Main.Util.HighHeelsResume(self.Actors[Slot])
	Main.Util.ScaleResume(self.Actors[Slot])
	Main.Util.ScaleOverride(self.Actors[Slot],1.0)
	Main.Util.ImmersiveExpression(self.Actors[Slot],FALSE)
	Main.Devices.UnregisterActor(self.Actors[Slot],self,Slot)

	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

	;; if no slot was specified ask the actor what slot they were in.

	If(Slot == -1)
		Slot = Main.Devices.GetActorSlot(Who)
	EndIf

	If(Slot == -1)
		Main.Util.PrintDebug("ClearActorObjects no slot to clean was specified.")
		Return
	EndIf

	If(self.Actors[Slot] != Who)
		Main.Util.PrintDebug("ClearActorObjects " + Who.GetDisplayName() + " is not " + self.DeviceID + " " + Slot)
		Return
	EndIf

	;;;;;;;;

	;; find the devices we want to delete.

	DeviceKey = "DM3.DeviceObjects." + self.DeviceID 
	ItemCount = StorageUtil.FormListCount(Who,DeviceKey)
	Main.Util.PrintDebug("ClearActorObjects " + Who.GetDisplayName() + " " + DeviceKey + " has " + ItemCount + " objects")

	;; and delete them.

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

	;; then forget about them.

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

	;; before spawning new devices clear out any old ones.

	self.ClearActorObjects(Who,Slot)

	;;;;;;;;

	DeviceKey = "DM3.DeviceObjects." + self.DeviceID
	ItemCount = Main.Devices.GetDeviceActorSlotObjectCount(self.File,Slot)
	MarkerForm = Main.Util.GetFormFrom("Skyrim.esm",0x3B)
	ConfigLightFace = Main.Config.GetBool(".DeviceActorLightFace")
	ToggleLightFace = Who.IsInFaction(Main.FactionActorToggleLightFace)
	Main.Util.PrintDebug("SpawnActorObjects " + Who.GetDisplayName() + " " + DeviceKey + " needs " + ItemCount + " objects")

	;;;;;;;;

	;; place all the devices.

	Iter = 0
	While(Iter < ItemCount)

		;; figure out what item we want and where it should be.

		ItemForm = Main.Devices.GetDeviceActorSlotObjectForm(self.File,Slot,Iter)
		ItemPos = Main.Devices.GetDeviceActorSlotObjectPosition(self.File,Slot,Iter)

		If(ItemForm != None)

			;; place a marker down as a spawn point and move it to the location.
			Marker = self.PlaceAtMe(MarkerForm,1,TRUE,FALSE)
			Marker.MoveTo(self,ItemPos[0],ItemPos[1],ItemPos[2],TRUE)

			;; spawn the item on the location.
			Item = Marker.PlaceAtMe(ItemForm,1,TRUE,TRUE)
			Item.Enable(FALSE)

			;; clean up the placement marker.
			Marker.Disable()
			Marker.Delete()

			;; determine if we should scale the object.
			Main.Util.ScaleOverride(Item,self.GetScaleOverride())

			;; make note of the object that belongs to this actor.
			StorageUtil.FormListAdd(Who,DeviceKey,Item)
			Main.Util.PrintDebug("SpawnActorObjects " + Who.GetDisplayName() + " " + DeviceKey + " " + Iter + " (" + ItemPos[0] + "," + ItemPos[1] + "," + ItemPos[2] + ")")

		Else
			Main.Util.PrintDebug("SpawnActorObjects " + Who.GetDisplayName() + " " + DeviceKey + " " + Iter + " not found")

		EndIf

		Iter += 1
	EndWhile

	;; place a facelight if it is enabled globally or for this actor.

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

Function ScaleActorObjects()
{resize all the actor objects.}

	Float ScaleTo = self.GetScaleOverride()
	String DeviceKey = "DM3.DeviceObjects." + self.DeviceID
	Int ObjectCount
	ObjectReference Object
	Int Ater
	Int Oter

	Ater = 0
	While(Ater < self.Actors.Length)
		If(self.Actors[Ater] != None)
			ObjectCount = StorageUtil.FormListCount(self.Actors[Ater],DeviceKey)

			Oter = 0
			While(Oter < ObjectCount)
				Object = StorageUtil.FormListGet(self.Actors[Ater],DeviceKey,Oter) As ObjectReference

				If(Object != None)
					Main.Util.ScaleOverride(Object,ScaleTo)
				EndIf

				Oter += 1
			EndWhile
		EndIf

		Ater += 1
	EndWhile

	Return
EndFunction

Function EquipActorEquips(Actor Who, Int Slot)
{spawn objects for this actor when mounted.}

	String DeviceKey
	Int ItemCount
	Int Iter
	Form ItemForm

	;;;;;;;;

	DeviceKey = "DM3.DeviceEquips." + self.DeviceID
	ItemCount = Main.Devices.GetDeviceActorSlotEquipCount(self.File,Slot)
	Main.Util.PrintDebug("EquipActorEquips " + Who.GetDisplayName() + " " + DeviceKey + " needs " + ItemCount + " equips")

	;;;;;;;;

	;; place all the devices.

	Iter = 0
	While(Iter < ItemCount)

		ItemForm = Main.Devices.GetDeviceActorSlotEquipForm(self.File,Slot,Iter)

		If(ItemForm != None)
			Who.EquipItem(ItemForm,TRUE,TRUE)
			StorageUtil.FormListAdd(Who,DeviceKey,ItemForm)
			Main.Util.PrintDebug("EquipActorEquips " + Who.GetDisplayName() + " " + DeviceKey + " " + Iter )
		Else
			Main.Util.PrintDebug("EquipActorEquips " + Who.GetDisplayName() + " " + DeviceKey + " " + Iter + " not found")
		EndIf

		Iter += 1
	EndWhile

	Return
EndFunction

Function RemoveActorEquips(Actor Who, Int Slot=-1)
{clean up objects placed by this actor when it was mounted.}

	String DeviceKey
	Int ItemCount
	Int Iter
	Form Item

	;;;;;;;;

	;; if no slot was specified ask the actor what slot they were in.

	If(Slot == -1)
		Slot = Main.Devices.GetActorSlot(Who)
	EndIf

	If(Slot == -1)
		Main.Util.PrintDebug("RemoveActorEquips no slot to clean was specified.")
		Return
	EndIf

	If(self.Actors[Slot] != Who)
		Main.Util.PrintDebug("RemoveActorEquips " + Who.GetDisplayName() + " is not " + self.DeviceID + " " + Slot)
		Return
	EndIf

	;;;;;;;;

	;; find the devices we want to delete.

	DeviceKey = "DM3.DeviceEquips." + self.DeviceID 
	ItemCount = StorageUtil.FormListCount(Who,DeviceKey)
	Main.Util.PrintDebug("RemoveActorEquips " + Who.GetDisplayName() + " " + DeviceKey + " has " + ItemCount + " equips")

	;; and delete them.

	Iter = 0
	While(Iter < ItemCount)
		Item = StorageUtil.FormListGet(Who,DeviceKey,Iter)

		If(Item != None)
			Who.RemoveItem(Item,99,TRUE)
			Main.Util.PrintDebug("RemoveActorEquipos " + Who.GetDisplayName() + " " + DeviceKey + " " + Iter)
		EndIf

		Iter += 1
	EndWhile

	;; then forget about them.

	StorageUtil.FormListClear(Who,DeviceKey)

	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function HandlePeriodicUpdates()
{handle things this device needs to do on the timer.}

	Int ActorCount = self.GetMountedActorCount()
	Float Now = Utility.GetCurrentRealTime()

	;; no actors nothing to do good bye.

	If(ActorCount == 0)
		Return 
	EndIf

	;;;;;;;;

	If((Now - self.TimeAroused) > 30)
		self.UpdateArousals()
		self.TimeAroused = Now
	EndIf

	self.Moan()

	Return
EndFunction

Function Moan()
{do a moaning sound effect from one of the actors on the device.}

	Int Iter = 0
	Int Slot = -1

	;; choose a random slot to do the moan. will try up to 16 times until it
	;; accidentally picks a slot that has an actor in it. there is technically
	;; a chance it wont end up moaning at all but its super slim you'd think
	;; given most devices will only have one slot lol.

	If(!self.Is3dLoaded())
		Return
	EndIf

	While(Iter < 16)
		Slot = Utility.RandomInt(0,(self.Actors.Length - 1))

		If(self.Actors[Slot] != None)
			If(StorageUtil.GetIntValue(self.Actors[Slot],Main.DataKeyActorMoan,1) == 1)
				Main.SpellActorMoan.Cast(self.Actors[Slot],self.Actors[Slot])
				Return
			EndIf
		EndIf

		Iter += 1
	EndWhile

	Return
EndFunction

Function UpdateArousals()
{update arousal on all actors on this device.}

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

	;; if this device only has one slot then auto select that slot as the slot
	;; to use. else pop up the menu that will list them for selection.

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

	;; throw some data out that the assignment spell will then read out.

	StorageUtil.SetFormValue(Main.Player,"DM3.AssignNPC.Device",self)
	StorageUtil.SetIntValue(Main.Player,"DM3.AssignNPC.Slot",Selected)

	;; and begin the assignment spell.

	Main.Util.Print("Select an NPC to assign...")
	Main.Player.AddSpell(Main.SpellAssignNPC)

	Return
EndFunction

Int Function ShowScaleMenu()
{pop up the menu listing of scales to set the device to.}

	String[] Items = new String[41]
	Int Value
	Int Iter

	Items[0] = "[Current: " + Main.Util.FloatToString((self.GetScaleOverride() * 100.0)) + "%]"

	Iter = 1
	While(Iter < 41)
		Items[Iter] = (Iter * 5) + "%"
		Iter += 1
	EndWhile

	Value = Main.MenuFromList(Items)

	Return Value
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; when this device is first placed on the ground it is in this Initial state
;; automatically. this state will handle the first-time load by catching the
;; OnLoad event. it then uses then OnUpdate timer to trigger setting the device
;; up in a new thread.

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

;; once the initialization has been complete the device will be shifted into
;; this Idle state. this still will catch the OnLoad events to handle refreshing
;; the device since initialization has already been done. this state will also
;; handle catching this device being interacted with as well as maintain the
;; periodic loop that will be used to update whatever data we want on actors
;; on this device.

State Idle

	Event OnLoad()
		{handle the device being re-loaded.}
		
		Main.Util.PrintDebug(self.DeviceID + " Load While Idle")
		self.TimeAroused = Utility.GetCurrentRealTime()
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

		Float UpdateFreq = self.UpdateFreqIdle

		If(self.IsUsed())
			UpdateFreq = self.UpdateFreqUsed

			self.HandlePeriodicUpdates()			
			self.RegisterForSingleUpdate(UpdateFreq)
		EndIf

		Return
	EndEvent

EndState
