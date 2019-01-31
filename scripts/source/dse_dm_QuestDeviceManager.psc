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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function Register(dse_dm_ActiPlaceableBase Device)
{add a placed device to the tracking.}

	StorageUtil.FormListAdd(None,Main.DataKeyDeviceList,Device,FALSE)
	Return
EndFunction

Function Unregister(dse_dm_ActiPlaceableBase Device)
{remove a placed device from the tracking.}

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

Function RegisterActor(Actor Who, dse_dm_ActiPlaceableBase Device, Int Slot)

	;; make the device remember this actor.

	Device.Actors[Slot] = Who

	;; make the actor remember this device.

	StorageUtil.SetFormValue(Who,Main.DataKeyActorDevice,Device)
	StorageUtil.SetIntValue(Who,Main.DataKeyActorDevice,Slot)

	;; give us ways to query actor with factions.

	Who.AddToFaction(Main.FactionActorUsingDevice)

	Main.Util.PrintDebug(Who.GetDisplayName() + " registered to " + Device.DeviceID + " slot " + Slot)
	Return
EndFunction

Function UnregisterActor(Actor Who, dse_dm_ActiPlaceableBase Device=None, Int Slot=-1)

	Int Iter = 0

	If(Device == None)
		Device = StorageUtil.GetFormValue(Who,Main.DataKeyActorDevice) As dse_dm_ActiPlaceableBase
		Slot = StorageUtil.GetIntValue(Who,Main.DataKeyActorDevice)
	EndIf

	;; make the actor forget this device.

	StorageUtil.UnsetFormValue(Who,Main.DataKeyActorDevice)
	StorageUtil.UnsetIntValue(Who,Main.DataKeyActorDevice)

	;; remove actor factions.

	Who.RemoveFromFaction(Main.FactionActorUsingDevice)

	;; make the device forget this actor.

	;;Device.Actors[Slot] = None

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

	Return StorageUtil.GetFormValue(Who,Main.DataKeyActorDevice) As dse_dm_ActiPlaceableBase
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

String Function GetDeviceID(String Filename)
{read the id property out of a device file.}

	Return JsonUtil.GetPathStringValue(Filename,".Device.ID")
EndFunction

String Function GetDeviceName(String Filename)
{read the name property out of a device file.}

	Return JsonUtil.GetPathStringValue(Filename,".Device.Name")
EndFunction

Activator Function GetDeviceActivator(String Filename)
{read the activator property out of a device file.}

	Return JsonUtil.GetPathFormValue(Filename,".Device.Activator") As Activator
EndFunction

Form Function GetDeviceGhost(String Filename)
{read the activator property out of a device file.}

	Return JsonUtil.GetPathFormValue(Filename,".Device.Ghost")
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

Int Function GetDeviceObjectsIdleCount(String Filename)
{count how many idle objects this uses out of a device file.}

	Return JsonUtil.PathCount(Filename,".Device.ObjectsIdle")
EndFunction

Int Function GetDeviceObjectsUsedCount(String Filename)
{count how many used objects this uses out of a device file.}

	Return JsonUtil.PathCount(Filename,".Device.ObjectsUsed")
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
