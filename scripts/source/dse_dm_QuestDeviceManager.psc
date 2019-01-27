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

Int Function GetDeviceActorCount(String Filename)
{count how many actors this can hold out of a device file.}

	Return JsonUtil.PathCount(Filename,".Device.Actors")
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
