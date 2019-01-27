Scriptname dse_dm_QuestMCM extends SKI_ConfigBase

dse_dm_QuestController Property Main Auto

Event OnGameReload()
{things to do when the game is loaded from disk.}

	parent.OnGameReload()

	;; check if any devices have been added lately.
	Main.Devices.ScanFiles()

	Return
EndEvent

Event OnConfigInit()
{things to do when the menu initalises (is opening)}

	self.Pages = new String[1]
	
	self.Pages[0] = "$DM3_Menu_General"

	Return
EndEvent

Event OnConfigOpen()
{things to do when the menu actually opens.}

	self.OnConfigInit()

	Return
EndEvent

Event OnConfigClose()
{things to do when the menu closes.}

	Return
EndEvent

Event OnPageReset(String page)
{when a different tab is selected in the menu.}

	self.UnloadCustomContent()

	If(Page == "$DM3_Menu_General")
		self.ShowPageGeneral()
	EndIf

	Return
EndEvent

Function ShowPageGeneral()

	Return
EndFunction