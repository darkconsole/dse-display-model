Scriptname dse_dm_QuestMCM extends SKI_ConfigBase

dse_dm_QuestController Property Main Auto

Event OnGameReload()
{things to do when the game is loaded from disk.}

	parent.OnGameReload()

	;; dependency check
	Main.CheckForDeps(TRUE)

	;; restarting the game we have to restart the timer
	;; due to how the real time timer counts since the
	;; game started.
	If(Main.Devices.GetActorDevice(Main.Player) != None)
		Main.Util.ActorBondageTimerStart(Main.Player)
	EndIf

	;; check if any devices have been added lately.
	Main.Devices.ScanFiles()

	;; add books to vendors.
	Main.InstallVendorItems()

	Return
EndEvent

Event OnConfigInit()
{things to do when the menu initalises (is opening)}

	self.Pages = new String[3]
	
	self.Pages[0] = "$DM3_Menu_General"
	self.Pages[1] = "$DM3_Menu_Stats"
	self.Pages[2] = "$DM3_Menu_Splash"

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
	ElseIf(Page == "$DM3_Menu_Stats")
		self.ShowPageStats()
	ElseIf(Page == "$DM3_Menu_Splash")
		self.ShowPageSplash()
	EndIf

	Return
EndEvent

Function ShowPageGeneral()

	Return
EndFunction

Function ShowPageStats()

	Float TimeTotal = 0.0
	Float ActorCount = StorageUtil.FormListCount(None,Main.DataKeyActorDevice)
	Int Iter
	Actor Who
	Float TimeSpent

	;; some cleanup just in case.

	StorageUtil.FormListRemove(None,Main.DataKeyActorDevice,None,TRUE)

	;;;;;;;;

	;; first have everyone update their calcs.

	Iter = 0

	While(Iter < ActorCount)
		Who = StorageUtil.FormListGet(None,Main.DataKeyActorDevice,Iter) As Actor

		If(Who != None)
			Main.Util.ActorBondageTimerUpdate(Who)
			Main.Util.ActorBondageTimerStart(Who)
		EndIf

		Iter += 1
	EndWhile

	;; now make a list.

	self.SetTitleText("$DM3_Menu_Stats")
	self.SetCursorFillMode(LEFT_TO_RIGHT)
	self.SetCursorPosition(0)

	self.AddHeaderOption("$DM3_Menu_StatsGlobalStats")
	self.AddHeaderOption("")

	self.AddTextOption("$DM3_Menu_StatActorCount","")
	self.AddTextOption("",Main.Util.FloatToString(ActorCount,0))
	self.AddTextOption("$DM3_Menu_StatsTotalTime","")
	self.AddTextOption(Main.Util.ReadableTimeDelta(Main.Util.ActorBondageTimeTotal(None),FALSE),Main.Util.ReadableTimeDelta(Main.Util.ActorBondageTimeTotal(None),TRUE))
	self.AddTextOption("$DM3_Menu_StatsPlayerTime","")
	self.AddTextOption(Main.Util.ReadableTimeDelta(Main.Util.ActorBondageTimeTotal(Main.Player),FALSE),Main.Util.ReadableTimeDelta(Main.Util.ActorBondageTimeTotal(Main.Player),TRUE))
	self.AddTextOption("$DM3_Menu_StatsPlayerEscapeAttempts","")
	self.AddTextOption("",Main.Util.FloatToString(StorageUtil.GetIntValue(Main.Player,Main.DataKeyActorEscapeAttempts),0))
	self.AddEmptyOption()
	self.AddEmptyOption()

	self.AddHeaderOption("$DM3_Menu_StatsActorStats")
	self.AddHeaderOption("")

	Iter = 0
	While(Iter < ActorCount)
		Who = StorageUtil.FormListGet(None,Main.DataKeyActorDevice,Iter) As Actor
		TimeSpent = Main.Util.ActorBondageTimeTotal(Who)

		If(Who != None)
			self.AddTextOption(Who.GetDisplayName(),"")
			self.AddTextOption(Main.Util.ReadableTimeDelta(TimeSpent,FALSE),Main.Util.ReadableTimeDelta(TimeSpent,TRUE))
		EndIf

		Iter += 1
	EndWhile

	Return
EndFunction

Function ShowPageSplash()

	Return
EndFunction