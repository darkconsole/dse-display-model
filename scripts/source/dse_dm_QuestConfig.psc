ScriptName dse_dm_QuestConfig extends Quest

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_dm_QuestController Property Main Auto
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Bool Property DebugMode = TRUE Auto Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

String Property FileConfig = "../../../configs/dse-display-model/settings/Default.json" AutoReadOnly Hidden
String Property FileCustom = "../../../configs/dse-display-model/settings/Custom.json" AutoReadOnly Hidden
Int[] Property FileID Auto Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnInit()
{handle resetting the mod configuration during initization and reset.}

	If(Main.IsStopped())
		Main.Util.PrintDebug("Aborting Config Init: Controller is not running.")
		Return
	EndIf
	
	self.ReloadConfigFile()

	Main.Util.PrintDebug("Config File Loaded")
	Return
EndEvent

Function ReloadConfigFile()
{force a refresh of the json config without saving any changes.}

	JsonUtil.Unload(self.FileConfig,FALSE,FALSE)
	JsonUtil.Load(self.FileConfig)

	JsonUtil.Unload(self.FileCustom,FALSE,FALSE)
	JsonUtil.Load(self.FileCustom)

	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function LoadFiles()

	Return
EndFunction

Bool Function GetBool(String Path, Bool Default=FALSE)
{fetch an boolean from the json config.}

	If(!Default)
		If(JsonUtil.IsPathNumber(self.FileCustom,Path) || JsonUtil.IsPathBool(self.FileCustom,Path))
			Return JsonUtil.GetPathBoolValue(self.FileCustom,Path)
		EndIf
	EndIf

	Return JsonUtil.GetPathBoolValue(self.FileConfig,Path)
EndFunction

Int Function GetInt(String Path, Bool Default=FALSE)
{fetch an integer from the json config.}

	If(!Default)
		If(JsonUtil.IsPathNumber(self.FileCustom,Path))
			Return JsonUtil.GetPathIntValue(self.FileCustom,Path)
		EndIf
	EndIf

	Return JsonUtil.GetPathIntValue(self.FileConfig,Path)
EndFunction

Float Function GetFloat(String Path, Bool Default=FALSE)
{fetch an float from the json config.}

	If(!Default)
		If(JsonUtil.IsPathNumber(self.FileCustom,Path))
			Return JsonUtil.GetPathFloatValue(self.FileCustom,Path)
		EndIf
	EndIf

	Return JsonUtil.GetPathFloatValue(self.FileConfig,Path)
EndFunction

String Function GetString(String Path, Bool Default=FALSE)
{fetch a string from the json config.}

	If(!Default)
		If(JsonUtil.IsPathString(self.FileCustom,Path))
			Return JsonUtil.GetPathStringValue(self.FileCustom,Path)
		EndIf
	EndIf

	Return JsonUtil.GetPathStringValue(self.FileConfig,Path)
EndFunction

Int Function GetCount(String Path, Bool Default=FALSE)
{fetch how many items are in the specified thing. you should probably only
use this on arrays.}

	If(!Default)
		If(JsonUtil.CanResolvePath(self.FileCustom,Path))
			Return JsonUtil.PathCount(self.FileCustom,Path)
		EndIf
	EndIf

	Return JsonUtil.PathCount(self.FileConfig,Path)
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Bool Function SetBool(String Path, Bool Value)

	JsonUtil.SetPathIntValue(self.FileCustom,Path,(Value as Int))
	JsonUtil.Save(self.FileCustom)
	
	Return Value
EndFunction

Int Function SetInt(String Path, Int Value)

	JsonUtil.SetPathIntValue(self.FileCustom,Path,Value)
	JsonUtil.Save(self.FileCustom)
	
	Return Value
EndFunction

Float Function SetFloat(String Path, Float Value)

	JsonUtil.SetPathFloatValue(self.FileCustom,Path,Value)
	JsonUtil.Save(self.FileCustom)
	
	Return Value
EndFunction

String Function SetString(String Path, String Value)

	JsonUtil.SetPathStringValue(self.FileCustom,Path,Value)
	JsonUtil.Save(self.FileCustom)
	
	Return Value
EndFunction

Function DeletePath(String Path)

	Main.Util.PrintDebug("Config.DeletePath " + Path)

	;; can resolve doesn't seem to return true unless it resolves into
	;; a datatype papyrus can digest.

	If(JsonUtil.CanResolvePath(self.FileCustom,Path) || JsonUtil.IsPathObject(self.FileCustom,Path))
		Main.Util.PrintDebug("JsonUtil.ClearPath " + Path)
		JsonUtil.ClearPath(self.FileCustom,Path)
	EndIf

	Return
EndFunction
