ScriptName dse_dm_QuestDeviceManager extends Quest

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

String Property DeviceFileDir = "../../../configs/dse-display-model/devices" Auto Hidden
String[] Property DeviceFiles Auto Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function ScanDeviceFiles()
{indexes all the devices we have installed.}

	Int Iter

	;;;;;;;;

	;; find all the devices.

	self.DeviceFiles = JsonUtil.JsonInFolder(self.DeviceFileDir)
	PapyrusUtil.SortStringArray(self.DeviceFiles)

	;;;;;;;;

	;; convert the device paths to their full jsonutil path.

	Iter = 0
	While(Iter < self.DeviceFiles.Length)
		self.DeviceFiles[Iter] = self.DeviceFileDir + "/" + self.DeviceFiles[Iter]
		Iter += 1
	EndWhile

	Return
EndFunction

String Function GetDeviceFile(String Filename)
{given a filename return the full filepath if it exists or none if not.}

	String Full = self.DeviceFileDir + "/" + Filename
	Int Iter = 0

	While(Iter < self.DeviceFiles.Length)
		If(self.DeviceFiles[Iter] == Full)
			Return Full
		EndIf

		Iter += 1
	EndWhile

	Return ""
EndFunction
