Scriptname dse_dm_ActiPlaceableBase extends ObjectReference

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_dm_QuestController Property Main Auto Hidden
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

Event OnGainLOS(Actor Viewer, ObjectReference What)
EndEvent

Event OnLostLOS(Actor Viewer, ObjectReference What)
EndEvent

Event OnControlDown(String What)
EndEvent

Event OnControlUp(String What, Float Len)
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

	self.SpawnDeviceObjects()

	;;;;;;;;

	;; register this device as placed in the world.

	Main.Devices.Register(self)

	;; change its state to idle and kick off the update loop for it.

	self.GotoState("Idle")

	;;;;;;;;

	Main.Util.PrintDebug(self.DeviceID + " is ready.")
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

	Main.Devices.ReloadFile(self.File)
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

String Function GetDeviceStorageKey()
{get the storageutil key for this device.}

	Return "DM3.DeviceObjects." + self.DeviceID
EndFunction

Form Function GetGhostForm()
{get the ghost object for use during move mode}

	;; used by the positioning system. to genericify the api over there.

	Return Main.Devices.GetDeviceGhost(self.File)
EndFunction

Float Function GetGrabOffset()

	Return Main.Devices.GetDeviceGrabOffset(self.File) * self.GetScaleOverride()
EndFunction

Float Function GetHeightOffset(Actor Who)

	Return self.Z - Who.Z
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

Actor[] Function GetMountedActors()
{fetch a list of all the actors currently attached.}

	Int Iter = 0
	Int Count = self.GetMountedActorCount()
	Actor[] Result = PapyrusUtil.ActorArray(Count)

	Iter = 0
	Count = 0

	While(Iter < self.Actors.Length)
		If(self.Actors[Iter] != None)
			Result[Count] = self.Actors[Iter]
			Count += 1
		Endif
		Iter += 1
	EndWhile

	Return Result
EndFunction

Bool Function AreActorsLoaded()
{check if all the actors currently attached are loaded.}

	Int Iter = 0

	While(Iter < self.Actors.Length)
		If(self.Actors[Iter] != None && !self.Actors[Iter].Is3dLoaded())			
			Return FALSE
		EndIf

		Iter += 1
	EndWhile

	Return TRUE
EndFunction

Bool Function ForceActorsCell()
{check if all the actors currently attached are loaded.}

	Int Iter = 0

	While(Iter < self.Actors.Length)
		If(self.Actors[Iter] != None)
			If(self.Actors[Iter].GetParentCell() != self.GetParentCell())
				self.Actors[Iter].MoveTo(self)
				Main.Util.Print(self.Actors[Iter].GetDisplayName() + " had to be corrected via ForceActorsCell")
			EndIf
		EndIf

		Iter += 1
	EndWhile

	Return TRUE
EndFunction

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

Function MatchToActorSubscale(Actor Who)
{set this device to match a non-breaking scale override.}

	Float Scale = NetImmerse.GetNodeScale(Who,"NPC Root [Root]",FALSE)

	;; we used NetImmerse on purpose here because it basically always sees the final result
	;; of all the things that have been done without having to care what mod it came from.

	;; just in case something doesn't have this bone and it returns 0 or was just so gd small
	;; that it is impossible to see and click on.

	If(Scale < 0.1)
		Return
	EndIf

	;; so we will match the device to that scale.
	;; and then set the override so all addons get scaled.

	Main.Util.PrintDebug("MatchToActorSubscale: " + self.GetScaleOverride() + " * " + Scale + " = " + (Scale * self.GetScaleOverride()))

	Scale *= self.GetScaleOverride()
	self.SetScale(Scale)
	self.SetScaleOverride(Scale)

	Return
EndFunction

Function RestoreFromActorSubscale(Actor Who)
{restore this device to match a non-breaking scale override.}

	Float Scale = NetImmerse.GetNodeScale(Who,"NPC Root [Root]",FALSE)

	Main.Util.PrintDebug("RestoreFromActorSubscale: " + self.GetScaleOverride() + " / " + Scale + " = " + (self.GetScaleOverride() / Scale))

	;; restore the device scale.

	self.SetScale(self.GetScaleOverride() / Scale)

	;; and restore the override.

	self.SetScaleOverride(self.GetScaleOverride() / Scale)

	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function Move()
{kick in the grab object system on this thing.}

	Float RotateMeMan
	Float LookMeDownMan

	;; this did not work. and i found people who could confirm that it won't ever
	;; change pitch in first person. just looks left or right.
	;;Game.DisablePlayerControls()
	;;Game.SetPlayerAiDriven(TRUE)
	;;Main.Player.SetHeadTracking(TRUE)
	;;Main.Player.SetLookAt(self,TRUE)
	;;Utility.Wait(0.5)
	;;Main.Player.ClearLookAt()
	;;Main.Player.SetHeadTracking(FALSE)
	;;Game.SetPlayerAiDriven(FALSE)
	;;Game.EnablePlayerControls()

	If(Main.Config.GetBool(".DeviceMoveAimCamera"))
		Game.ForceFirstPerson()
		RotateMeMan = Main.Player.GetAngleZ() + Main.Player.GetHeadingAngle(self)
		LookMeDownMan = 90 - (Math.atan( self.GetDistance(Main.Player) / (Main.Util.GetPlayerHeight() - self.GetHeightOffset(Main.Player) - self.GetGrabOffset()) ))

		;; this did not work. no matter what you give it, the game always sets the x (pitch) to 0 when done from scripting.
		;; Main.Player.SetAngle(LookMeDownMan,Main.Player.GetAngleY(),RotateMeMan)

		;; so here we are, yet again, another gd ConsoleUtil hack because wtf.
		ConsoleUtil.ExecuteCommand("player.setangle z " + RotateMeMan)
		ConsoleUtil.ExecuteCommand("player.setangle x " + LookMeDownMan)
	EndIf

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

	self.ClearDeviceObjects()

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
	Actor[] ActorList

	If(PlayersChoice == 1)
		self.Move()
	ElseIf(PlayersChoice == 2)
		self.PickUp()
	ElseIf(PlayersChoice == 3)
		self.AssignNPC()
	ElseIf(PlayersChoice == 4)
		self.AssignPlayer()
	ElseIf(PlayersChoice == 5)
		Value = self.ShowScaleMenu()
		If(Value > 0)

			;; force the scale we selected.
			self.SetScaleOverride((Value as Float) / 20.0)

			;; but then re-balance it with actor subscales.
			If(self.GetMountedActorCount() == 1)
				ActorList = self.GetMountedActors()
				self.MatchToActorSubscale(ActorList[0])
			Else
				Main.Util.ScaleOverride(self,self.GetScaleOverride())
			EndIf

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
			Main.Util.PrintDebug("ActivateByActor: " + self.DeviceID + " slot " + Slot + " is not empty.")
			Return
		EndIf
	EndIf

	;; bail if we don't have any free slots.

	If(Slot == -1)
		Main.Util.PrintDebug("ActivateByActor: " + self.DeviceID + " has no empty actor slots.")
		Return
	EndIf

	;; slot the actor.

	self.MountActor(Who,Slot)

	Return
EndFunction

Function InteractByPlayer(Int Slot)
{when the player tries to interact with a slotted npc.}

	Int PlayersChoice = self.ShowInteractMenu(Slot)

	If(PlayersChoice < 0)
		Return
	EndIf

	self.InteractActor(Main.Player,Slot,PlayersChoice)
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
		Main.Util.PrintDebug("MountActor: " + self.DeviceID + " " + Slot + " " + SlotName + " is not empty.")
		Return
	EndIf

	;; make sure this slot allows this race.

	If(!Main.Devices.GetDeviceActorSlotRaceAllowed(self.File,Slot,Who.GetRace()))
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
		Main.Util.PrintDebug("MountActor: no package found for " + self.DeviceID + " " + Slot)
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

	;; first scale the actor to the device scale override.

	Main.Util.ScaleCancel(Who)
	Main.Util.ScaleOverride(Who,self.GetScaleOverride())

	;; then scale the device to the actor's non-breaking scale.

	If(self.GetMountedActorCount() == 0)
		self.MatchToActorSubscale(Who)
	EndIf

	;; the infamous slomoroto anti-collision hack. this will put the actor
	;; above the device in a state where they have no collision for a long
	;; time, longer than anyone will likely ever be in the same room with a
	;; device by like a long long time (the 0.000001 rotation speed). this
	;; is the same trick sexlab uses during scenes.

	self.NotifyActorObjectsActorMounted(Who,Slot)

	Who.SetAngle(0.0,0.0,self.GetAngleZ())
	Who.TranslateTo(               \
		self.GetPositionX(),       \
		self.GetPositionY(),       \
		self.GetPositionZ(),       \
		self.GetAngleX(),          \
		self.GetAngleY(),          \
		(self.GetAngleZ() + 0.01), \
		10000,0.000001             \
	)

	;; assuming direct control

	Main.Devices.RegisterActor(Who,self,Slot)	
	Main.Util.HighHeelsCancel(Who)
	Main.Util.BehaviourSet(Who,Task)
	Main.Util.ImmersiveExpression(Who,FALSE)
	Main.Util.ActorMouthApply(Who)

	;; if the actor was already on this device and in this slot then we can
	;; skip spawning its objects as they should already be there.

	If(SameDeviceDiffSlot || ForceObjects)
		self.RemoveActorEquips(Who,Slot)
	EndIf

	If(!SameDeviceSameSlot || ForceObjects)
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
	Who.MoveTo(self)
	Who.RemoveFromFaction(Main.FactionFollow)
	Main.Util.ActorBondageTimerStart(Who)

	If(Who == Main.Player)
		self.RegisterForControl("Jump")
		Game.DisablePlayerControls(FALSE,TRUE,TRUE,FALSE,FALSE,FALSE,TRUE,FALSE,0)
		Game.ForceThirdPerson()
		self.PrintUpdateInfo(Who)
	EndIf

	Main.Util.PrintDebug("MountActor: " + Who.GetDisplayName() + " is now mounted to " + DeviceName + ": " + SlotName)
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
		Main.Util.PrintDebug("ReleaseActor: " + self.DeviceID + " " + Who.GetDisplayName() + " not found on device.")
	EndIf

	Return
EndFunction

Function ReleaseActorSlot(Int Slot)
{release the specified slot from this device.}

	Float[] Pos = Main.Util.GetPositionAtDistance(self,50)

	If(Slot < 0 || Slot >= self.Actors.Length)
		Main.Util.PrintDebug("ReleaseActorSlot: " + self.DeviceID + " " + Slot + " out of range.")
		Return
	EndIf

	;; move them away.

	self.Actors[Slot].SetPosition(Pos[1],Pos[2],Pos[3])
	self.Actors[Slot].StopTranslation()

	;; clean up slot objects.

	self.ClearActorObjects(self.Actors[Slot],Slot)
	self.RemoveActorEquips(self.Actors[Slot],Slot)

	If(self.GetMountedActorCount() == 1)
		self.RestoreFromActorSubscale(self.Actors[Slot])
	EndIf

	;; let the actor behave normal again.

	If(self.Actors[Slot] == Main.Player)
		self.UnregisterForControl("Jump")
		Game.EnablePlayerControls()
	EndIf

	Main.Util.BehaviourSet(self.Actors[Slot],None)
	Main.Util.HighHeelsResume(self.Actors[Slot])
	Main.Util.ScaleResume(self.Actors[Slot])
	Main.Util.ScaleOverride(self.Actors[Slot],1.0)
	Main.Util.ImmersiveExpression(self.Actors[Slot],FALSE)
	Main.Util.ActorMouthClear(self.Actors[Slot])
	Main.Util.ActorBondageTimerUpdate(self.Actors[Slot])
	Main.Devices.UnregisterActor(self.Actors[Slot],self,Slot)
	self.NotifyActorObjectsActorReleased(self.Actors[Slot],Slot)

	Return
EndFunction

Function RandomiseMountedActor()
{randomise the currently mounted actor if there is one. the way it currently
works you should only use it on devices that only hold one at a time.}

	Int Slot = 0

	While(Slot < self.Actors.Length)
		If(self.Actors[Slot] != None)
			If(self.Actors[Slot].IsInFaction(Main.FactionActorRandomSlotOnLoad))
				Main.Util.PrintDebug("RandomiseMountedActor: " + self.Actors[Slot].GetDisplayName())
				self.MountActor(self.Actors[Slot],Utility.RandomInt(0,(self.Actors.Length - 1)))
			EndIf
			Return
		EndIf

		Slot += 1
	EndWhile

	Return
EndFunction

Function InteractActor(Actor Who, Int Slot, Int Ilot)
{force an actor to use this device and slot.}

	Package Task
	String DeviceName = Main.Devices.GetDeviceName(self.File)
	String SlotName = Main.Devices.GetDeviceActorSlotName(self.File,Slot)

	;; make sure we know what to do.

	Task = Main.Devices.GetDeviceActorSlotInteractionPackage(self.File,Slot,Ilot)

	If(Task == None)
		Main.Util.PrintDebug("InteractActor: no package found for " + self.DeviceID + " " + Slot + " " + Ilot)
		Return
	EndIf

	Who.SetHeadTracking(FALSE)
	Main.Util.ScaleCancel(Who)
	Main.Util.ScaleOverride(Who,self.GetScaleOverride())

	;;self.NotifyActorObjectsActorInteracting(Who,Slot,Ilot)

	Who.SetAngle(0.0,0.0,self.GetAngleZ())
	Who.TranslateTo(               \
		self.GetPositionX(),       \
		self.GetPositionY(),       \
		self.GetPositionZ(),       \
		self.GetAngleX(),          \
		self.GetAngleY(),          \
		(self.GetAngleZ() + 0.01), \
		10000,0.000001             \
	)

	Main.Util.HighHeelsCancel(Who)
	Main.Util.BehaviourSet(Who,Task)
	Main.Util.ImmersiveExpression(Who,FALSE)
	Main.Util.ActorMouthApply(Who)

	Who.MoveTo(self)

	If(Who == Main.Player)
		self.RegisterForControl("Jump")
		Game.DisablePlayerControls(FALSE,TRUE,TRUE,FALSE,FALSE,FALSE,TRUE,FALSE,0)
		Game.ForceThirdPerson()
		self.PrintUpdateInfo(Who)
	EndIf

	Main.Util.PrintDebug("InteractActor: " + Who.GetDisplayName() + " is now interacting with " + DeviceName + ": " + SlotName + " " + Ilot)
	Return
EndFunction

Function DetractActor(Actor Who)
{force an actor to use this device and slot.}

	Float[] Pos = Main.Util.GetPositionAtDistance(self,50)

	;; move them away.

	Who.SetPosition(Pos[1],Pos[2],Pos[3])
	Who.StopTranslation()

	;; let the actor behave normal again.

	If(Who == Main.Player)
		self.UnregisterForControl("Jump")
		Game.EnablePlayerControls()
	EndIf

	Main.Util.BehaviourSet(Who,None)
	Main.Util.HighHeelsResume(Who)
	Main.Util.ScaleResume(Who)
	Main.Util.ScaleOverride(Who,1.0)
	Main.Util.ImmersiveExpression(Who,FALSE)
	Main.Util.ActorMouthClear(Who)

	;;self.NotifyActorObjectsActorDetracted(Who,Slot,Ilot)
	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function Refresh(Bool ForceObjects=FALSE)
{update any actors on this device to force them to be doing what we want them
to be doing.}

	Int Iter

	self.SpawnDeviceObjects()

	While(Iter < self.Actors.Length)
		If(self.Actors[Iter] != None)
			Main.Util.PrintDebug("Refresh: " + self.DeviceID + " " + Iter + " " + self.Actors[Iter].GetDisplayName())
			self.MountActor(self.Actors[Iter],Iter,ForceObjects)
		EndIf
		Iter += 1
	EndWhile

	Return
EndFunction

Function ClearDeviceObjects()
{clear the additional decoration objects for this furniture.}

	String DeviceKey = self.GetDeviceStorageKey()
	Int ItemCount = StorageUtil.FormListCount(self,DeviceKey)
	Int Iter
	ObjectReference Obj

	Iter = 0
	While(Iter < ItemCount)
		Obj = Storageutil.FormListGet(self,DeviceKey,Iter) As ObjectReference

		If(Obj != NONE)
			Obj.Disable()
			Obj.Delete()
		EndIf

		Iter += 1
	EndWhile

	StorageUtil.FormListClear(self,DeviceKey)
	Return
EndFunction

Function SpawnDeviceObjects()
{place the additional decoration objects this furniture needs.}

	Int Iter
	ObjectReference Obj

	String DeviceKey = self.GetDeviceStorageKey()
	Int ItemCount = Main.Devices.GetDeviceObjectCount(self.File)
	Form ItemForm
	dse_dm_ActiConnectedObject ItemCx

	self.ClearDeviceObjects()

	Iter = 0
	While(Iter < ItemCount)
		ItemForm = Main.Devices.GetDeviceObjectForm(self.File,Iter)

		If(ItemForm != NONE)
			Obj = self.PlaceAtMe(ItemForm)
		EndIf

		;; does this item have extra features
		If((Obj As dse_dm_ActiConnectedObject) != None)
			Main.Util.PrintDebug("SpawnDeviceObjects: " + DeviceKey + " " + Iter + " is Connected Object")
			ItemCx = Obj As dse_dm_ActiConnectedObject
			ItemCx.Device = self
			ItemCx.Slot = -69
		EndIf

		StorageUtil.FormListAdd(self,DeviceKey,Obj)
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
		Main.Util.PrintDebug("ClearActorObjects: no slot to clean was specified.")
		Return
	EndIf

	If(self.Actors[Slot] != Who)
		Main.Util.PrintDebug("ClearActorObjects: " + Who.GetDisplayName() + " is not " + self.DeviceID + " " + Slot)
		Return
	EndIf

	;;;;;;;;

	;; find the devices we want to delete.

	DeviceKey = "DM3.DeviceObjects." + self.DeviceID 
	ItemCount = StorageUtil.FormListCount(Who,DeviceKey)
	Main.Util.PrintDebug("ClearActorObjects: " + Who.GetDisplayName() + " " + DeviceKey + " has " + ItemCount + " objects")

	;; and delete them.

	Iter = 0
	While(Iter < ItemCount)
		Item = StorageUtil.FormListGet(Who,DeviceKey,Iter) As ObjectReference

		If(Item != None)
			Item.Disable()
			Item.Delete()
			Main.Util.PrintDebug("ClearActorObjects: " + Who.GetDisplayName() + " " + DeviceKey + " " + Iter)
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
	Float CurrentScale
	ObjectReference Item
	ObjectReference Marker
	Bool ConfigLightFace
	Bool ToggleLightFace
	dse_dm_ActiConnectedObject ItemCx

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
	CurrentScale = self.GetScaleOverride()
	Main.Util.PrintDebug("SpawnActorObjects: " + Who.GetDisplayName() + " " + DeviceKey + " needs " + ItemCount + " objects")

	;;;;;;;;

	;; place all the devices.

	Iter = 0
	While(Iter < ItemCount)

		;; figure out what item we want and where it should be.

		ItemForm = Main.Devices.GetDeviceActorSlotObjectForm(self.File,Slot,Iter)
		ItemPos = Main.Devices.GetDeviceActorSlotObjectPosition(self.File,Slot,Iter)
		ItemPos[0] = ItemPos[0] * CurrentScale
		ItemPos[1] = ItemPos[1] * CurrentScale
		ItemPos[2] = ItemPos[2] * CurrentScale

		If(ItemForm != None)

			;; place a marker down as a spawn point and move it to the location.
			Marker = self.PlaceAtMe(MarkerForm,1,TRUE,FALSE)
			Marker.MoveTo(self,ItemPos[0],ItemPos[1],ItemPos[2],TRUE)

			;; does this item have extra features
			If((Item As dse_dm_ActiConnectedObject) != None)
				Main.Util.PrintDebug("SpawnActorObjects: " + DeviceKey + " " + Iter + " is Connected Object")
				ItemCx = Item As dse_dm_ActiConnectedObject
				ItemCx.Device = self
				ItemCx.Slot = Slot
			EndIf

			;; spawn the item on the location.
			Item = Marker.PlaceAtMe(ItemForm,1,TRUE,TRUE)
			Item.Enable(FALSE)

			;; clean up the placement marker.
			Marker.Disable()
			Marker.Delete()

			;; determine if we should scale the object.
			Main.Util.ScaleOverride(Item,CurrentScale)

			;; make note of the object that belongs to this actor.
			StorageUtil.FormListAdd(Who,DeviceKey,Item)
			Main.Util.PrintDebug("SpawnActorObjects: " + Who.GetDisplayName() + " " + DeviceKey + " " + Iter + " (" + ItemPos[0] + "," + ItemPos[1] + "," + ItemPos[2] + ")")
		Else
			Main.Util.PrintDebug("SpawnActorObjects: " + Who.GetDisplayName() + " " + DeviceKey + " " + Iter + " not found")
		EndIf

		ItemCx = None
		Iter += 1
	EndWhile

	;; place a facelight if it is enabled globally or for this actor.

	If((ConfigLightFace && !ToggleLightFace) || (!ConfigLightFace && ToggleLightFace))
		Utility.Wait(2.0)
		Main.Util.PrintDebug("SpawnActorObjects: " + Who.GetDisplayName() + " " + DeviceKey + " adding face light")

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

Function SpawnActorObjectForm(Actor Who, Int Slot, Form What)
{spawn a specific object form and assign it to the specific actor and slot
so that it will get cleaned up later when the actor is dismounted.}

	String DeviceKey = "DM3.DeviceObjects." + self.DeviceID
	Float Scale = self.GetScaleOverride()
	ObjectReference Item

	;;;;;;;;

	Item = self.PlaceAtMe(What,1,TRUE,TRUE)
	Item.Enable(FALSE)

	Main.Util.ScaleOverride(Item,Scale)
	StorageUtil.FormListAdd(Who,DeviceKey,Item)

	Return
EndFunction

Function NotifyActorObjectsActorMounted(Actor Who, Int Slot)
{notify any connected objects that an actor was mounted.}

	String DeviceKey = self.GetDeviceStorageKey() 
	dse_dm_ActiConnectedObject Item
	Int ItemCount = 0
	Int Ater = 0
	Int Iter = 0

	;;;;;;;;

	Item = ((self As ObjectReference) As dse_dm_ActiConnectedObject)
	If(Item != None)
		Item.OnActorMounted(Who,Slot)
	EndIf

	While(Ater < self.Actors.Length)
		If(self.Actors[Ater] != None)
			Iter = 0
			ItemCount = StorageUtil.FormListCount(self.Actors[Ater],DeviceKey)

			While(Iter < ItemCount)
				Item = StorageUtil.FormlistGet(self.Actors[Ater],DeviceKey,Iter) As dse_dm_ActiConnectedObject

				If(Item != None)
					Item.OnActorMounted(Who,Slot)
				EndIf

				Iter += 1
			EndWhile
		EndIf

		Ater += 1
	EndWhile

	Return
EndFunction

Function NotifyActorObjectsActorReleased(Actor Who, Int Slot)
{notify any connected objects that an actor was mounted.}

	String DeviceKey = self.GetDeviceStorageKey() 
	dse_dm_ActiConnectedObject Item
	Int ItemCount = 0
	Int Ater = 0
	Int Iter = 0

	;;;;;;;;

	Item = ((self As ObjectReference) As dse_dm_ActiConnectedObject)
	If(Item != None)
		Item.OnActorReleased(Who,Slot)
	EndIf

	While(Ater < self.Actors.Length)
		If(self.Actors[Ater] != None)
			Iter = 0
			ItemCount = StorageUtil.FormListCount(self.Actors[Ater],DeviceKey)

			While(Iter < ItemCount)
				Item = StorageUtil.FormlistGet(self.Actors[Ater],DeviceKey,Iter) As dse_dm_ActiConnectedObject

				If(Item != None)
					Item.OnActorReleased(Who,Slot)
				EndIf

				Iter += 1
			EndWhile
		EndIf

		Ater += 1
	EndWhile

	Return
EndFunction

Function NotifyActorObjectsDeviceUpdate()
{notify any connected objects that a periodic update has happened.}

	String DeviceKey = self.GetDeviceStorageKey() 
	dse_dm_ActiConnectedObject Item
	Int ItemCount = 0
	Int Ater = 0
	Int Iter = 0

	;;;;;;;;

	Item = ((self As ObjectReference) As dse_dm_ActiConnectedObject)
	If(Item != None)
		Item.OnDeviceUpdate()
	EndIf

	While(Ater < self.Actors.Length)
		If(self.Actors[Ater] != None)
			Iter = 0
			ItemCount = StorageUtil.FormListCount(self.Actors[Ater],DeviceKey)

			While(Iter < ItemCount)
				Item = StorageUtil.FormlistGet(self.Actors[Ater],DeviceKey,Iter) As dse_dm_ActiConnectedObject

				If(Item != None)
					Item.OnDeviceUpdate()
				EndIf

				Iter += 1
			EndWhile
		EndIf

		Ater += 1
	EndWhile

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
	Main.Util.PrintDebug("EquipActorEquips: " + Who.GetDisplayName() + " " + DeviceKey + " needs " + ItemCount + " equips")

	;;;;;;;;

	;; place all the devices.

	Iter = 0
	While(Iter < ItemCount)

		ItemForm = Main.Devices.GetDeviceActorSlotEquipForm(self.File,Slot,Iter)

		If(ItemForm != None)
			Who.EquipItem(ItemForm,TRUE,TRUE)
			StorageUtil.FormListAdd(Who,DeviceKey,ItemForm)
			Main.Util.PrintDebug("EquipActorEquips: " + Who.GetDisplayName() + " " + DeviceKey + " " + Iter )
		Else
			Main.Util.PrintDebug("EquipActorEquips: " + Who.GetDisplayName() + " " + DeviceKey + " " + Iter + " not found")
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
		Main.Util.PrintDebug("RemoveActorEquips: no slot to clean was specified.")
		Return
	EndIf

	If(self.Actors[Slot] != Who)
		Main.Util.PrintDebug("RemoveActorEquips: " + Who.GetDisplayName() + " is not " + self.DeviceID + " " + Slot)
		Return
	EndIf

	;;;;;;;;

	;; find the devices we want to delete.

	DeviceKey = "DM3.DeviceEquips." + self.DeviceID 
	ItemCount = StorageUtil.FormListCount(Who,DeviceKey)
	Main.Util.PrintDebug("RemoveActorEquips: " + Who.GetDisplayName() + " " + DeviceKey + " has " + ItemCount + " equips")

	;; and delete them.

	Iter = 0
	While(Iter < ItemCount)
		Item = StorageUtil.FormListGet(Who,DeviceKey,Iter)

		If(Item != None)
			Who.RemoveItem(Item,99,TRUE)
			Main.Util.PrintDebug("RemoveActorEquips: " + Who.GetDisplayName() + " " + DeviceKey + " " + Iter)
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
	Bool DoArousal = Main.Config.GetBool(".DeviceActorAroused")
	Bool DoMoan = Main.Config.GetBool(".DeviceActorMoan")
	Int ArousalMode = 0
	Float ArousalMult = 1.0
	Int Iter = 0

	;; handle the case where the game has been restarted and that real time
	;; counter has started over.

	If(self.TimeAroused > Now)
		self.TimeAroused = Now - 69
		;; giggity giggity.
	EndIf

	;; no actors nothing to do goodbye.

	If(ActorCount == 0)
		Main.Util.PrintDebug("HandlePeriodicUpdates: " + self.GetName() + " skipped - no actors mounted.")
		Return 
	EndIf

	;;;;;;;;

	;; throttled events regardless of the device update frequency.

	If((Now - self.TimeAroused) >= 30.0)
		self.TimeAroused = Now

		Iter = 0
		While(Iter < self.Actors.Length)
			If(self.Actors[Iter] != None)
				If(DoArousal)
					ArousalMode = Main.Devices.GetDeviceActorSlotArousing(self.File,Iter)
					ArousalMult = Main.Devices.GetDeviceActorSlotArousalMult(self.File,Iter)
					Main.Util.ActorArousalUpdate(self.Actors[Iter],ArousalMult,ArousalMode)
				EndIf

				self.PrintUpdateInfo(self.Actors[Iter])
				self.TryArousalRelease(self.Actors[Iter])
			EndIf

			Iter += 1
		EndWhile
	EndIf

	;;;;;;;;

	If(DoMoan)
		self.Moan()
	EndIf

	self.NotifyActorObjectsDeviceUpdate()
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
				If(self.Actors[Slot].Is3dLoaded() && self.Actors[Slot].IsNearPlayer())
					Main.SpellActorMoan.Cast(self.Actors[Slot],self.Actors[Slot])
					Return
				EndIf
			EndIf
		EndIf

		Iter += 1
	EndWhile

	Return
EndFunction

Function TryArousalRelease(Actor Who)
{try to automatically release when arousal is zero.}

	Float TimeMinimum = 0.0
	Float TimePassed = 0.0
	Bool Release = FALSE

	If(Main.Util.ActorArousalGet(Who) <= 0.0)
		If(Who == Main.Player && Main.Config.GetBool(".BondageEscapeArousalPlayer"))
			TimeMinimum = Main.Config.GetFloat(".BondageEscapeTimeMinimum")
			TimePassed = Main.Util.ActorBondagePlayerTimerDelta(TRUE)
			If(TimePassed >= TimeMinimum)
				Release = TRUE
			EndIf
		ElseIf(Main.Config.GetBool(".BondageEscapeArousalNPC"))
			Release = TRUE
		EndIf
	EndIf

	If(Release)
		Main.Util.PrintDebug("TryArousalRelease: " + Who.GetDisplayName() + " released due empty arousal.")
		self.ReleaseActor(Who)
	EndIf

	Return
EndFunction

Function PrintUpdateInfo(Actor Who)

	Bool DoTimer = Main.Config.GetBool(".BondagePrintPlayerTimer")
	Bool DoArousal = Main.Config.GetBool(".BondagePrintPlayerArousal") && Main.Config.GetBool(".DeviceActorAroused")
	String Output = ""

	If(Who == Main.Player)
		If(DoTimer)
			Output += Main.Util.StringLookup("InfoTimeBound",Main.Util.ReadableTimeDelta(Main.Util.ActorBondagePlayerTimerDelta()))
		EndIf

		If(DoArousal)
			If(Output != "")
				Output += Main.Util.StringLookup("InfoSeparator")
			EndIf
			Output += Main.Util.StringLookup("InfoArousal",(Main.Util.ActorArousalGet(Main.Player) as String))
		EndIf
	EndIf

	If(Output != "")
		Main.Util.Print(Output)
	EndIf

	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function AssignNPC(Bool IsPlayer=FALSE)
{begin the npc selection process.}

	String[] Names
	Int Selected
	Int NameIter
	Int DeviceActorMax = Main.Devices.GetDeviceActorCount(self.File)

	;; make sure this device even has enough open free spots.

	If(self.GetMountedActorCount() >= Main.Devices.GetDeviceActorCount(self.File))
		Debug.MessageBox(Main.Util.StringLookup("MsgDeviceFull"))
		Return
	EndIf

	;; if this device only has one slot then auto select that slot as the slot
	;; to use. else pop up the menu that will list them for selection.	

	If(DeviceActorMax == 1 && Main.Devices.GetDeviceActorSlotCount(self.File) == 1)
		Selected = 0
	Else
		Main.Util.Print(Main.Util.StringLookup("MsgDeviceSelectSlot"))
		Names = Main.Devices.GetDeviceActorSlotNameList(self.File)

		;; modify the slot names to show them empty or who occupies.

		NameIter = 0
		While(NameIter < Names.Length)
			If(self.Actors[NameIter] != None)
				Names[NameIter] = Main.Util.StringLookup("LabelSlotOccupied",(Names[NameIter] + "|" + self.Actors[NameIter].GetDisplayName()))
			Else
				If(DeviceActorMax > 1)
					Names[NameIter] = Main.Util.StringLookup("LabelSlotEmpty",Names[NameIter])
				EndIf
			EndIf
			NameIter += 1
		EndWhile

		;; present the list for choosing.

		Selected = Main.MenuFromList(Names)
		If(Selected < 0)
			Debug.MessageBox(Main.Util.StringLookup("MsgDeviceSelectSlotNone"))
			Return
		EndIf
	EndIf

	;; sanity check on slot range.

	If(Selected >= self.Actors.Length)
		Main.Util.PrintDebug("AssignNPC " + Selected + " out of slot range (" + self.Actors.Length + ")")
		Return
	EndIf

	;; check to make sure the slot is even available.

	If(self.Actors[Selected] != None)
		Debug.MessageBox(Main.Util.StringLookup("MsgDeviceSlotOccupiedBy",self.Actors[Selected].GetDisplayName()))
		Return
	EndIf

	;; check that the race is allowed.

	If(IsPlayer)
		self.ActivateByActor(Main.Player,Selected)
	Else
		;; throw some data out that the assignment spell will then read out.
		StorageUtil.SetFormValue(Main.Player,Main.DataKeyAssignDevice,self)
		StorageUtil.SetIntValue(Main.Player,Main.DataKeyAssignSlot,Selected)
		;; and begin the assignment spell.
		Main.Util.Print(Main.Util.StringLookup("MsgDeviceSelectNPC"))
		Main.Player.AddSpell(Main.SpellAssignNPC)
	EndIf

	Return
EndFunction

Function AssignPlayer()
{begin the player mounting process.}
	
	self.AssignNPC(TRUE)

	Return
EndFunction

Int Function ShowScaleMenu()
{pop up the menu listing of scales to set the device to.}

	String[] Items = new String[41]
	Int Value
	Int Iter

	Items[0] = Main.Util.StringLookup("LabelScaleCurrent",Main.Util.FloatToString((self.GetScaleOverride() * 100.0)))

	Iter = 1
	While(Iter < 41)
		Items[Iter] = Main.Util.StringLookup("LabelScaleChoice",((Iter * 5) as String))
		Iter += 1
	EndWhile

	Value = Main.MenuFromList(Items)

	Return Value
EndFunction

Int Function ShowInteractMenu(Int Slot)
{open slot interaction menu}

	UIListMenu Menu = UIExtensions.GetMenu("UIListMenu",TRUE) as UIListMenu
	Int NoParent = -1
	Int Result

	Int ICount
	String IName
	Int Iter

	;;;;;;;;

	Menu.AddEntryItem(Main.Util.StringLookup("LabelDeviceMenuCancel"),NoParent)

	ICount = Main.Devices.GetDeviceActorSlotInteractionCount(self.File,Slot)
	Iter = 0

	While(Iter < ICount)
		IName = Main.Devices.GetDeviceActorSlotInteractionName(self.File,Slot,Iter)
		Menu.AddEntryitem(IName,NoParent)
		Iter += 1
	EndWhile

	;;;;;;;;

	Menu.OpenMenu()
	Result = Menu.GetResultInt() - 1

	If(Result < 0)
		Main.Util.PrintDebug("ShowInteractMenu: Canceled")
		Return -1
	EndIf

	Main.Util.PrintDebug("ShowInteractMenu: Selected " + Result)
	Return Result
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

		self.Main = dse_dm_QuestController.GetAPI()
		
		If(self.DeviceID == "")
			Debug.MessageBox("OnLoad: DeviceID was not set.")
			Return
		EndIf

		Main.Util.PrintDebug("OnLoad: " + self.DeviceID + " Load First Time")
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
		
		Int Stalling

		;; handle making sure our 3d is loaded.

		Stalling = 0
		
		While(!self.Is3dLoaded() && Stalling < 30)
			Utility.Wait(0.1)
			Stalling += 1
		EndWhile

		;; then check they are even nearby.

		self.ForceActorsCell()

		;; handle making sure the actors are loaded.

		Stalling = 0

		While(!self.AreActorsLoaded() && Stalling < 30)
			Utility.Wait(0.1)
			Stalling += 1
		EndWhile

		Main.Util.PrintDebug("OnLoad: " + self.DeviceID + " Load While Idle")
		self.TimeAroused = Utility.GetCurrentRealTime()
		self.Refresh()

		If(Main.Devices.GetDeviceActorCount(self.File) == 1)
			If(Main.Devices.GetDeviceRandomSlotOnLoad(self.File))
				self.RandomiseMountedActor()
			EndIf
		EndIf

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

	Event OnGainLOS(Actor Viewer, ObjectReference What)
	{when an actor is registered to a device, this device gets registered for when
	the player gains line of sight on any of the actors. we are going to try using
	this to fix wandering actors because the SSE ActorUtil is less than stellar.}

		;; our main problem seems to be that the ai is free to do as it wishes
		;; while the game is in the black load screen because actorutil isn't
		;; forcing the packages in time like it did in le. we will first try
		;; to combat that with a cell check. if the actor managed to roam out of
		;; the cell of the device just move them back we don't really care if
		;; they are aligned and mounted right now since they are off screen.
		;; the device's onload itself will handle that the next time we actually
		;; go inside... probably.

		If((What As Actor) != None)
			If(self.GetParentCell() != What.GetParentCell())
				;; actor ran away.
				What.MoveTo(self)
				Main.Util.PrintDebug("OnGainLOS: " + What.GetDisplayName() + " had to be corrected via LOS Check")
			Else
				;; re-enable actor ai while looking at them.
				;;Main.Util.PrintDebug("OnGainLOS: " + What.GetDisplayName() + " Enabled By LOS")
				;;Main.Util.FreezeActor(What As Actor,FALSE)
			EndIf
		ElseIf((What As dse_dm_ActiPlaceableBase) != None)
			;; idea, check its actors are aligned.
			;; los is not currently registered on the device itself.
			;; only consider this if the OnLoad ForceActorsCells isn't
			;; getting the job done.
		EndIf

		Return
	EndEvent

	Event OnLostLOS(Actor Viewer, ObjectReference What)
		;; idea - experiment with disabling an actor's ai while they are out
		;; of visual range if we really need to stop radiant roaming. something
		;; like if not in same cell as player then tai them. our gain method above
		;; would then need to toggle that back on.

		;; probably need to wrap this with an option. it messes with my outfit manager.

		Actor Who = What As Actor

		If(Who != None)
			;;Main.Util.PrintDebug(Who.GetDisplayName() + " Disabled By LOS")
			;;Main.Util.FreezeActor(Who,TRUE)
		EndIf

		Return
	EndEvent

	Event OnControlDown(String What)
	EndEvent

	Event OnControlUp(String What, Float Len)

		ObjectReference Bed

		If(What == "Jump")
			If(Main.Devices.GetActorSlot(Main.Player) < 0)
				;; player is interacting
				self.DetractActor(Main.Player)
			Else
				;; player is bondaged
				If(Len < 2.0)
					If(Main.Util.ActorEscapeAttempt(Main.Player))
						self.ReleaseActor(Main.Player)
					EndIf

					self.PrintUpdateInfo(Main.Player)
				Else
					Bed = Main.Player.PlaceAtMe(Main.InvisibleBed,1,TRUE,FALSE)
					Bed.Activate(Main.Player)
					Utility.Wait(0.1)
					Bed.Delete()
				EndIf
			EndIf
		EndIf

	EndEvent

EndState
