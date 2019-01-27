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
		Iter += 1
	EndWhile

	Main.Util.PrintDebug(self.Files.Length + " Device Files Indexed")

	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

String Function GetDeviceID(String Filename)

	Return JsonUtil.GetPathStringValue(Filename,".ID")
EndFunction

String Function GetDeviceName(String Filename)

	Return JsonUtil.GetPathStringValue(Filename,".Name")
EndFunction

Int Function GetDeviceActorCount(String Filename)
	
	JsonUtil.PathCount(Filename,".Actors")
EndFunction

Int Function GetDeviceObjectsIdleCount(String Filename)
	
	JsonUtil.PathCount(Filename,".ObjectsIdle")
EndFunction

Int Function GetDeviceObjectsUseCount(String Filename)
	
	JsonUtil.PathCount(Filename,".ObjectsUsed")
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

String Function GetFile(String Filename)
{given a filename return the full filepath if it exists or none if not.}

	String Full = self.DeviceFileDir + "/" + Filename
	Int Iter = 0

	While(Iter < self.Files.Length)
		If(self.Files[Iter] == Filename)
			Return Full
		EndIf

		Iter += 1
	EndWhile

	Return ""
EndFunction


