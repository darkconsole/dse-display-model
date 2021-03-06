ScriptName dse_dm_QuestDeviceManager extends Quest

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_dm_QuestController Property Main Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

String Property DeviceFileDir = "../../../configs/dse-display-model/devices" Auto Hidden
String[] Property Files Auto Hidden
String[] Property IDs Auto Hidden
String[] Property Names Auto Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function ScanFiles()
{indexes all the devices we have installed.}

	Int Iter
	String Filename

	;;;;;;;;

	;; find all the devices.

	Main.Util.PrintDebug("Scanning Device Files...")

	self.Files = JsonUtil.JsonInFolder(self.DeviceFileDir)
	PapyrusUtil.SortStringArray(self.Files)

	self.IDs = Utility.CreateStringArray(self.Files.Length)
	self.Names = Utility.CreateStringArray(self.Files.Length)

	;;;;;;;;

	Main.Util.PrintDebug("Indexing Device Files...")

	Iter = 0
	While(Iter < self.Files.Length)
		Filename = self.DeviceFileDir + "/" + self.Files[Iter]
		self.Files[Iter] = Filename
		self.IDs[Iter] = self.GetDeviceID(Filename)
		self.Names[Iter] = self.GetDeviceName(Filename)
		Main.Util.PrintDebug("Loaded " + self.Files[Iter])
		Main.Util.PrintDebug("Indexed " + self.IDs[Iter] + " " + self.Names[Iter])
		JsonUtil.Unload(Filename,FALSE,FALSE)
		Iter += 1
	EndWhile

	Main.Util.PrintDebug(self.Files.Length + " Device Files Indexed")

	Return
EndFunction

Function ReloadFile(String Filename)
{force a refresh of the json config without saving any changes.}

	JsonUtil.Unload(Filename,FALSE,FALSE)
	JsonUtil.Load(Filename)

	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; device meta

Function Register(dse_dm_ActiPlaceableBase Device)
{add a placed device to the tracking.}

	StorageUtil.FormListAdd(None,Main.DataKeyDeviceList,Device,FALSE)
	Return
EndFunction

Function Unregister(dse_dm_ActiPlaceableBase Device)
{remove a placed device from the tracking.}

	StorageUtil.UnsetFloatValue(Device,Main.DataKeyDeviceScale)
	StorageUtil.FormListRemove(None,Main.DataKeyDeviceList,Device,TRUE)
	Return
EndFunction

Int Function GetRegisteredDeviceCount()
{how many devices we got placed in the world.}

	Return StorageUtil.FormListCount(None,Main.DataKeyDeviceList)
EndFunction

dse_dm_ActiPlaceableBase Function GetNthRegisteredDevice(Int Offset)
{get the nth registered device.}

	Return StorageUtil.FormListGet(None,Main.DataKeyDeviceList,Offset) As dse_dm_ActiPlaceableBase
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; actor slot meta

Function RegisterActor(Actor Who, dse_dm_ActiPlaceableBase Device, Int Slot)
{register an actor to a device and flag it so it can be tracked.}

	;; make the device remember this actor.

	Device.Actors[Slot] = Who

	;; make the actor remember this device.

	StorageUtil.SetFormValue(Who,Main.DataKeyActorDevice,Device)
	StorageUtil.SetIntValue(Who,Main.DataKeyActorDevice,Slot)
	StorageUtil.SetStringValue(Who,Main.DataKeyActorMouth,self.GetDeviceActorSlotMouth(Device.File,Slot))
	StorageUtil.SetIntValue(Who,Main.DataKeyActorMoan,self.GetDeviceActorSlotMoan(Device.File,Slot) As Int)
	StorageUtil.FormListAdd(None,Main.DataKeyActorDevice,Who,FALSE)

	;; give us ways to query actor with factions.

	Who.AddToFaction(Main.FactionActorUsingDevice)

	If(self.GetDeviceActorSlotInteractionCount(Device.File,Slot) > 0)
		Who.AddToFaction(Main.FactionActorInteractable)
	EndIf

	;; see how a los based error check works out.

	Device.RegisterForLOS(Main.Player,Who)

	Main.Util.PrintDebug(Who.GetDisplayName() + " registered to " + Device.DeviceID + " slot " + Slot)
	Return
EndFunction

Function UnregisterActor(Actor Who, dse_dm_ActiPlaceableBase Device=None, Int Slot=-1)
{unregister an actor from a device and clean it up.}

	Int Iter = 0

	If(Device == None)
		Device = StorageUtil.GetFormValue(Who,Main.DataKeyActorDevice) As dse_dm_ActiPlaceableBase
		Slot = StorageUtil.GetIntValue(Who,Main.DataKeyActorDevice)
	EndIf

	;; make the actor forget this device.

	StorageUtil.UnsetFormValue(Who,Main.DataKeyActorDevice)
	StorageUtil.UnsetIntValue(Who,Main.DataKeyActorDevice)
	StorageUtil.UnsetStringValue(Who,Main.DataKeyActorMouth)
	StorageUtil.FormListRemove(None,Main.DataKeyActorDevice,Who,TRUE)

	;; remove actor factions.

	Who.RemoveFromFaction(Main.FactionActorUsingDevice)
	Who.RemoveFromFaction(Main.FactionActorInteractable)

	;; make the device forget this actor.

	Device.UnregisterForLOS(Main.Player,Who)

	While(Iter < Device.Actors.Length)
		If(Device.Actors[Iter] == Who)
			Device.Actors[Iter] = None
			Main.Util.PrintDebug(Who.GetDisplayName() + " unregistered from " + Device.DeviceID + " slot " + Iter)
		EndIf
		Iter += 1
	EndWhile

	Return
EndFunction

dse_dm_ActiPlaceableBase Function GetActorDevice(Actor Who)
{fetch the device this actor has been registered to.}

	Return StorageUtil.GetFormValue(Who,Main.DataKeyActorDevice) As dse_dm_ActiPlaceableBase
EndFunction

Int Function GetActorSlot(Actor Who)
{fetch the slot on a device this actor has been registered to.}

	Return StorageUtil.GetIntValue(Who,Main.DataKeyActorDevice,-1)
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; device properties

String Function GetDeviceID(String Filename)
{read the id property out of a device file.}

	Return JsonUtil.GetPathStringValue(Filename,".Device.ID")
EndFunction

String Function GetDeviceName(String Filename)
{read the name property out of a device file.}

	Form Object = self.GetDeviceActivator(Filename)

	If(!Object)
		Return ""
	EndIf

	Return Object.GetName()
EndFunction

Float Function GetDeviceGrabOffset(String Filename)
{read the look offset property of a device file.}

	Return JsonUtil.GetPathFloatValue(Filename,".Device.GrabOffset",0.0)
EndFunction

Activator Function GetDeviceActivator(String Filename)
{read the activator property out of a device file.}

	Return JsonUtil.GetPathFormValue(Filename,".Device.Activator") As Activator
EndFunction

Form Function GetDeviceInventoryItem(String Filename)
{read the activator property out of a device file.}

	Return JsonUtil.GetPathFormValue(Filename,".Device.Inventory")
EndFunction

Form Function GetDeviceGhost(String Filename)
{read the activator property out of a device file.}

	Return JsonUtil.GetPathFormValue(Filename,".Device.Ghost")
EndFunction

Float Function GetDeviceUpdateFreqIdle(String Filename)
{read the activator property out of a device file.}

	Return JsonUtil.GetPathFloatValue(Filename,".Device.UpdateFreqIdle",30.0)
EndFunction

Float Function GetDeviceUpdateFreqUsed(String Filename)
{read the activator property out of a device file.}

	Return JsonUtil.GetPathFloatValue(Filename,".Device.UpdateFreqUsed",30.0)
EndFunction

Bool Function GetDeviceRandomSlotOnLoad(String Filename)
{read the activator property out of a device file.}

	Return JsonUtil.GetPathBoolValue(Filename,".Device.RandomSlotOnLoad",false)
EndFunction

Bool Function GetDeviceRaceAllowed(String Filename, Race What)
{determine if this race is allowed on this device.}

	Int RaceCount = JsonUtil.PathCount(Filename,".Device.Races")
	Form RaceItem
	Int RaceIter

	;; if there is a list of races on the device root then check that
	;; the race in question is inside it.

	If(RaceCount > 0)
		RaceIter = 0
		While(RaceIter < RaceCount)
			RaceItem = JsonUtil.GetPathFormValue(Filename,".Device.Races[" + RaceIter + "]") As Race

			If(What == RaceItem)
				Return TRUE
			EndIf

			RaceIter += 1
		EndWhile

		Return FALSE
	EndIf

	;; if there was no list of races on the device root then try to make it only
	;; allow humanoids.

	;;If(What.HasKeywordString("ActorTypeNPC"))
	;;	Return TRUE
	;;EndIf

	Return TRUE
EndFunction

Int Function GetDeviceObjectCount(String Filename)
{get the package for a specific actor slot.}

	String Path = ".Device.Objects"

	Return PapyrusUtil.ClampInt(JsonUtil.PathCount(Filename,Path),0,9001)
EndFunction

Form Function GetDeviceObjectForm(String Filename, Int ItemSlot)
{get the package for a specific actor slot.}

	String Path = ".Device.Objects[" + ItemSlot + "].Form"

	Return JsonUtil.GetPathFormValue(Filename,Path)
EndFunction

Float[] Function GetDeviceObjectPosition(String Filename, Int ItemSlot)
{get the positional data for a specific actor slot.}

	Float[] Output = new Float[3]

	Output[0] = JsonUtil.GetPathFloatValue(Filename,".Device.Objects[" + ItemSlot + "].Pos[0]")
	Output[1] = JsonUtil.GetPathFloatValue(Filename,".Device.Objects[" + ItemSlot + "].Pos[1]")
	Output[2] = JsonUtil.GetPathFloatValue(Filename,".Device.Objects[" + ItemSlot + "].Pos[2]")

	Return Output
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; actor slots

Int Function GetDeviceActorCount(String Filename)
{check if there is an override on how many actors this can hold. this is if some
of the actor slots are actually being used for alternate animations.}

	Return JsonUtil.GetPathIntValue(Filename,".Device.ActorCount",self.GetDeviceActorSlotCount(Filename))
EndFunction

Int Function GetDeviceActorSlotCount(String Filename)
{count how many actors this can hold out of a device file.}

	Return JsonUtil.PathCount(Filename,".Device.Actors")
EndFunction

Package Function GetDeviceActorSlotPackage(String Filename, Int Slot)
{get the package for a specific actor slot.}

	String Path = ".Device.Actors[" + Slot + "].Package"

	Return JsonUtil.GetPathFormValue(Filename,Path) As Package
EndFunction

Float[] Function GetDeviceActorSlotPosition(String Filename, Int Slot)
{get the positional data for a specific actor slot.}

	Float[] Output = new Float[3]

	;; @todo

	Output[0] = 0.0
	Output[1] = 0.0
	Output[2] = 0.0

	Return Output
EndFunction

String Function GetDeviceActorSlotName(String Filename, Int Slot)
{get the name of a specific actor slot.}

	String Path = ".Device.Actors[" + Slot + "].Name"

	Return JsonUtil.GetPathStringValue(Filename,Path)
EndFunction

Bool Function GetDeviceActorSlotHeadTracking(String Filename, Int Slot)
{get if this is allowed to have head tracking.}

	String Path = ".Device.Actors[" + Slot + "].HeadTracking"

	If(!JsonUtil.IsPathBool(Filename,Path))
		Return TRUE
	EndIf

	Return JsonUtil.GetPathBoolValue(Filename,Path)
EndFunction

Bool Function GetDeviceActorSlotMoan(String Filename, Int Slot)
{get if this is allowed to have head tracking.}

	String Path = ".Device.Actors[" + Slot + "].Moan"

	If(!JsonUtil.IsPathBool(Filename,Path))
		Return TRUE
	EndIf

	Return JsonUtil.GetPathBoolValue(Filename,Path)
EndFunction

Int Function GetDeviceActorSlotArousing(String Filename, Int Slot)
{get if this slot has defined its arousal effect on an actor. 0 if
auto based on actor, 1 always arousing, -1 always calming.}

	String Path = ".Device.Actors[" + Slot + "].Arousing"

	Return JsonUtil.GetPathIntValue(Filename,Path,0)
EndFunction

Float Function GetDeviceActorSlotArousalMult(String Filename, Int Slot)
{get if this device should modify arousal faster or slower.}

	String Path = ".Device.Actors[" + Slot + "].ArousalMult"

	Return JsonUtil.GetPathFloatValue(Filename,Path,1.0)
EndFunction

String[] Function GetDeviceActorSlotNameList(String Filename)
{get a list of all the actor slot names.}

	Int Count = self.GetDeviceActorSlotCount(Filename)
	String[] Output = Utility.CreateStringArray(Count)
	Int Iter = 0

	While(Iter < Count)
		Output[Iter] = self.GetDeviceActorSlotName(Filename,Iter)
		Iter += 1
	EndWhile

	Return Output
EndFunction

String Function GetDeviceActorSlotMouth(String Filename, Int Slot)
{get the position we want the mouth for this actor.}

	String Path = ".Device.Actors[" + Slot + "].Mouth"

	Return JsonUtil.GetPathStringValue(Filename,Path,"normal")
EndFunction

Bool Function GetDeviceActorSlotRaceAllowed(String Filename, Int Slot, Race What)
{determine if this race is allowed on this device.}

	Int RaceCount = JsonUtil.PathCount(Filename,".Device.Actors[" + Slot + "].Races")
	Form RaceItem
	Int RaceIter

	;; if there is a list of races on this device slot then check that
	;; the race in question is inside it.

	If(RaceCount > 0)
		RaceIter = 0
		While(RaceIter < RaceCount)
			RaceItem = JsonUtil.GetPathFormValue(Filename,".Device.Actors[" + Slot + "].Races[" + RaceIter + "]") As Race

			If(What == RaceItem)
				Return TRUE
			EndIf

			RaceIter += 1
		EndWhile

		Return FALSE
	EndIf

	;; if there was no list of races on this device slot then try to make it only
	;; allow humanoids.

	If(What.HasKeywordString("ActorTypeNPC"))
		Return TRUE
	EndIf

	Return FALSE
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; actor slot objects

Int Function GetDeviceActorSlotEquipCount(String Filename, Int Slot)
{get the package for a specific actor slot.}

	String Path = ".Device.Actors[" + Slot + "].Equips"

	Return PapyrusUtil.ClampInt(JsonUtil.PathCount(Filename,Path),0,9001)
EndFunction

Form Function GetDeviceActorSlotEquipForm(String Filename, Int Slot, Int ItemSlot)
{get the package for a specific actor slot.}

	String Path = ".Device.Actors[" + Slot + "].Equips[" + ItemSlot + "].Form"

	Return JsonUtil.GetPathFormValue(Filename,Path)
EndFunction

Int Function GetDeviceActorSlotObjectCount(String Filename, Int Slot)
{get the package for a specific actor slot.}

	String Path = ".Device.Actors[" + Slot + "].Objects"

	Return PapyrusUtil.ClampInt(JsonUtil.PathCount(Filename,Path),0,9001)
EndFunction

Form Function GetDeviceActorSlotObjectForm(String Filename, Int Slot, Int ItemSlot)
{get the package for a specific actor slot.}

	String Path = ".Device.Actors[" + Slot + "].Objects[" + ItemSlot + "].Form"

	Return JsonUtil.GetPathFormValue(Filename,Path)
EndFunction

Float[] Function GetDeviceActorSlotObjectPosition(String Filename, Int Slot, Int ItemSlot)
{get the positional data for a specific actor slot.}

	Float[] Output = new Float[3]

	Output[0] = JsonUtil.GetPathFloatValue(Filename,".Device.Actors[" + Slot + "].Objects[" + ItemSlot + "].Pos[0]")
	Output[1] = JsonUtil.GetPathFloatValue(Filename,".Device.Actors[" + Slot + "].Objects[" + ItemSlot + "].Pos[1]")
	Output[2] = JsonUtil.GetPathFloatValue(Filename,".Device.Actors[" + Slot + "].Objects[" + ItemSlot + "].Pos[2]")

	Return Output
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Int Function GetDeviceActorSlotInteractionCount(String Filename, Int Slot)
{count how many actors this can hold out of a device file.}

	Return JsonUtil.PathCount(Filename,".Device.Actors[" + Slot + "].Interactions")
EndFunction

String Function GetDeviceActorSlotInteractionName(String Filename, Int Slot, Int Ilot)
{count how many actors this can hold out of a device file.}

	String Path = ".Device.Actors[" + Slot + "].Interactions[" + Ilot + "].Name"

	Return JsonUtil.GetPathStringValue(Filename,Path)
EndFunction

Package Function GetDeviceActorSlotInteractionPackage(String Filename, Int Slot, Int Ilot)
{count how many actors this can hold out of a device file.}

	String Path = ".Device.Actors[" + Slot + "].Interactions[" + Ilot + "].Package"

	Return JsonUtil.GetPathFormValue(Filename,Path) As Package
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

String Function GetFileByID(String DeviceID)
{get the json filename from the device id name.}

	String Full = self.DeviceFileDir + "/" + DeviceID + ".json"

	Return Full
EndFunction

String Function GetFileByIndex(Int DeviceIndex)
{get the json filename by the index in the thing.}

	;; note: do not use device index as a long term reference. if a device is
	;; added or removed from the mod and you were tracking it by its index
	;; it may now be out of range or pointing to the wrong device. this is
	;; mainly for instant feedback things like the menu system.

	If(DeviceIndex < 0 || DeviceIndex >= self.Files.Length)
		Return ""
	EndIf

	Return self.Files[DeviceIndex]
EndFunction
