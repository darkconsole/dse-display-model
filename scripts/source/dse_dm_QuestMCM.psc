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
	If(Main.Player.IsInFaction(Main.FactionActorUsingDevice))
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

Event OnPageReset(String Page)
{when a different tab is selected in the menu.}

	self.UnloadCustomContent()

	If(Page == "$DM3_Menu_General")
		self.ShowPageGeneral()
	ElseIf(Page == "$DM3_Menu_Stats")
		self.ShowPageStats()
	Else
		self.ShowPageSplash()
	EndIf

	Return
EndEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnOptionSelect(Int Item)
	Bool Val = FALSE
	Int Data = -1

	;;;;;;;;

	If(Item == DeviceActorAroused)
		Val = !GetBool(".DeviceActorAroused")
		Main.Config.SetBool(".DeviceActorAroused",Val)
	ElseIf(Item == ArousedTickExposure)
		Val = !GetBool(".ArousedTickExposure")
		Main.Config.SetBool(".ArousedTickExposure",Val)
	ElseIf(Item == ArousedTickTimeRate)
		Val = !GetBool(".ArousedTickTimeRate")
		Main.Config.SetBool(".ArousedTickTimeRate",Val)
	ElseIf(Item == BondagePlayer)
		Val = !GetBool(".BondagePlayer")
		Main.Config.SetBool(".BondagePlayer",Val)
	ElseIf(Item == BondageEscapeArousalPlayer)
		Val = !GetBool(".BondageEscapeArousalPlayer")
		Main.Config.SetBool(".BondageEscapeArousalPlayer",Val)
	ElseIf(Item == BondageEscapeArousalNPC)
		Val = !GetBool(".BondageEscapeArousalNPC")
		Main.Config.SetBool(".BondageEscapeArousalNPC",Val)
	ElseIf(Item == BondageEscapeArousalNPC)
		Val = !GetBool(".BondageEscapeArousalNPC")
		Main.Config.SetBool(".BondageEscapeArousalNPC",Val)
	ElseIf(Item == BondagePrintPlayerTimer)
		Val = !GetBool(".BondagePrintPlayerTimer")
		Main.Config.SetBool(".BondagePrintPlayerTimer",Val)
	ElseIf(Item == BondagePrintPlayerArousal)
		Val = !GetBool(".BondagePrintPlayerArousal")
		Main.Config.SetBool(".BondagePrintPlayerArousal",Val)
	ElseIf(Item == DeviceActorMoan)
		Val = !GetBool(".DeviceActorMoan")
		Main.Config.SetBool(".DeviceActorMoan",Val)
	ElseIf(Item == DeviceActorExpression)
		Val = !GetBool(".DeviceActorExpression")
		Main.Config.SetBool(".DeviceActorExpression",Val)
	EndIf

	;;;;;;;;

	self.SetToggleOptionValue(Item,Val)
	Return
EndEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnOptionSliderOpen(Int Item)
	Float Val = 0.0
	Float Min = 0.0
	Float Max = 0.0
	Float Interval = 0.0

	If(Item == ArousedTickFactorPlayer)
		Val = GetFloat(".ArousedTickFactorPlayer")
		Min = 0.0
		Max = 10.0
		Interval = 1.0
	ElseIf(Item == ArousedTickFactor)
		Val = GetFloat(".ArousedTickFactor")
		Min = 0.0
		Max = 10.0
		Interval = 1.0
	ElseIf(Item == BondageEscapeChancePlayer)
		Val = GetFloat(".BondageEscapeChancePlayer")
		Min = 1.0
		Max = 100.0
		Interval = 1.0
	ElseIf(Item == BondageEscapeStaminaMinimum)
		Val = GetFloat(".BondageEscapeStaminaMinimum")
		Min = 0.0
		Max = 100.0
		Interval = 1.0
	ElseIf(Item == BondageEscapeStaminaFactor)
		Val = GetFloat(".BondageEscapeStaminaFactor")
		Min = 0.0
		Max = 1.0
		Interval = 0.01
	ElseIf(Item == BondageEscapeArousalFactor)
		Val = GetFloat(".BondageEscapeArousalFactor")
		Min = 0.0
		Max = 1.0
		Interval = 0.01
	ElseIf(Item == BondageEscapeSuccessArousal)
		Val = GetFloat(".BondageEscapeSuccessArousal")
		Min = -50.0
		Max = 50.0
		Interval = 1.0
	ElseIf(Item == BondageEscapeFailureArousal)
		Val = GetFloat(".BondageEscapeFailureArousal")
		Min = -50.0
		Max = 50.0
		Interval = 1.0
	ElseIf(Item == BondageEscapeTimeMinimum)
		Val = GetFloat(".BondageEscapeTimeMinimum") / 60
		Min = 0.0
		Max = 30.0
		Interval = 0.5
	ElseIf(Item == DeviceDropDistance)
		Val = GetFloat(".DeviceDropDistance")
		Min = 25.0
		Max = 200.0
		Interval = 1.0
	EndIf

	SetSliderDialogStartValue(Val)
	SetSliderDialogRange(Min,Max)
	SetSliderDialogInterval(Interval)
	Return
EndEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnOptionSliderAccept(Int Item, Float Val)
	String Fmt = "{0}"

	If(Item == ArousedTickFactorPlayer)
		Main.Config.SetFloat(".ArousedTickFactorPlayer",Val)
	ElseIf(Item == ArousedTickFactor)
		Main.Config.SetFloat(".ArousedTickFactor",Val)
	ElseIf(Item == BondageEscapeChancePlayer)
		Fmt = "{0}%"
		Main.Config.SetFloat(".BondageEscapeChancePlayer",Val)
	ElseIf(Item == BondageEscapeStaminaMinimum)
		Main.Config.SetFloat(".BondageEscapeStaminaMinimum",Val)
	ElseIf(Item == BondageEscapeStaminaFactor)
		Fmt = "{2}"
		Main.Config.SetFloat(".BondageEscapeStaminaFactor",Val)
	ElseIf(Item == BondageEscapeArousalFactor)
		Fmt = "{2}"
		Main.Config.SetFloat(".BondageEscapeArousalFactor",Val)
	ElseIf(Item == BondageEscapeSuccessArousal)
		Main.Config.SetFloat(".BondageEscapeSuccessArousal",Val)
	ElseIf(Item == BondageEscapeFailureArousal)
		Main.Config.SetFloat(".BondageEscapeFailureArousal",Val)
	ElseIf(Item == BondageEscapeTimeMinimum)
		Fmt = "{1}"
		Main.Config.SetFloat(".BondageEscapeTimeMinimum",(Val * 60))
	ElseIf(Item == DeviceDropDistance)
		Main.Config.SetFloat(".DeviceDropDistance",Val)
	EndIf

	SetSliderOptionValue(Item,Val,Fmt)
	Return
EndEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnOptionHighlight(Int Item)
	
	String Txt = "$DM3_Mod_TitleFull"

	If(Item == DeviceActorAroused)
		Txt = "$DM3_MenuTip_DeviceActorAroused"
	ElseIf(Item == ArousedTickExposure)
		Txt = "$DM3_MenuTip_ArousedTickExposure"
	ElseIf(Item == ArousedTickTimeRate)
		Txt = "$DM3_MenuTip_ArousedTickTimeRate"
	ElseIf(Item == ArousedTickFactor)
		Txt = "$DM3_MenuTip_ArousedTickFactor"
	ElseIf(Item == ArousedTickFactorPlayer)
		Txt = "$DM3_MenuTip_ArousedTickFactorPlayer"
	ElseIf(Item == BondagePlayer)
		Txt = "$DM3_MenuTip_BondagePlayer"
	ElseIf(Item == BondageEscapeChancePlayer)
		Txt = "$DM3_MenuTip_BondageEscapeChancePlayer"
	ElseIf(Item == BondageEscapeStaminaMinimum)
		Txt = "$DM3_MenuTip_BondageEscapeStaminaMinimum"
	ElseIf(Item == BondageEscapeStaminaFactor)
		Txt = "$DM3_MenuTip_BondageEscapeStaminaFactor"
	ElseIf(Item == BondageEscapeArousalFactor)
		Txt = "$DM3_MenuTip_BondageEscapeArousalFactor"
	ElseIf(Item == BondageEscapeSuccessArousal)
		Txt = "$DM3_MenuTip_BondageEscapeSuccessArousal"
	ElseIf(Item == BondageEscapeFailureArousal)
		Txt = "$DM3_MenuTip_BondageEscapeFailureArousal"
	ElseIf(Item == BondageEscapeArousalPlayer)
		Txt = "$DM3_MenuTip_BondageEscapeArousalPlayer"
	ElseIf(Item == BondageEscapeArousalNPC)
		Txt = "$DM3_MenuTip_BondageEscapeArousalNPC"
	ElseIf(Item == BondageEscapeTimeMinimum)
		Txt = "$DM3_MenuTip_BondageEscapeTimeMinimum"
	ElseIf(Item == BondagePrintPlayerTimer)
		Txt = "$DM3_MenuTip_BondagePrintPlayerTimer"
	ElseIf(Item == BondagePrintPlayerArousal)
		Txt = "$DM3_MenuTip_BondagePrintPlayerArousal"
	ElseIf(Item == DeviceDropDistance)
		Txt = "$DM3_MenuTip_DeviceDropDistance"
	ElseIf(Item == DeviceActorMoan)
		Txt = "$DM3_MenuTip_DeviceActorMoan"
	ElseIf(Item == DeviceActorExpression)
		Txt = "$DM3_MenuTip_DeviceActorExpression"
	EndIf

	self.SetInfoText(Txt)
	Return
EndEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Bool Function GetBool(String What)
	Return Main.Config.GetBool(What)
EndFunction

Float Function GetFloat(String What)
	Return Main.Config.GetFloat(What)
EndFunction

Int Function GetInt(String What)
	Return Main.Config.GetInt(What)
EndFunction

String Function GetString(String What)
	Return Main.Config.GetString(What)
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Int DeviceDropDistance
Int DeviceActorMoan
Int DeviceActorExpression

Int DeviceActorAroused
Int ArousedTickExposure
Int ArousedTickTimeRate
Int ArousedTickFactorPlayer
Int ArousedTickFactor

Int BondagePlayer
Int BondageEscapeChancePlayer
Int BondageEscapeStaminaMinimum
Int BondageEscapeStaminaFactor
Int BondageEscapeArousalFactor
Int BondageEscapeSuccessArousal
Int BondageEscapeFailureArousal
Int BondageEscapeArousalPlayer
Int BondageEscapeArousalNPC
Int BondageEscapeTimeMinimum
Int BondagePrintPlayerTimer
Int BondagePrintPlayerArousal

Function ShowPageGeneral()

	self.SetTitleText("$DM3_Menu_General")
	self.SetCursorFillMode(TOP_TO_BOTTOM)

	self.SetCursorPosition(0)
	self.AddHeaderOption("Basic")
	DeviceDropDistance = self.AddSliderOption("Furniture Drop Distance",GetFloat(".DeviceDropDistance"),"{0}")
	DeviceActorMoan = self.AddToggleOption("Enable Moans",GetBool(".DeviceActorMoan"))
	DeviceActorExpression = self.AddToggleOption("Enable Expressions",GetBool(".DeviceActorExpression"))

	self.AddHeaderOption("SexLab Aroused")
	DeviceActorAroused = self.AddToggleOption("Enable",GetBool(".DeviceActorAroused"))
	ArousedTickExposure = self.AddToggleOption("Manage Exposure",GetBool(".ArousedTickExposure"))
	ArousedTickTimeRate = self.AddToggleOption("Manage Time Rate",GetBool(".ArousedTickTimeRate"))
	ArousedTickFactorPlayer = self.AddSliderOption("Player Arousal Factor",GetFloat(".ArousedTickFactorPlayer"),"{0}")
	ArousedTickFactor = self.AddSliderOption("NPC Arousal Factor",GetFloat(".ArousedTickFactor"),"{0}")

	self.SetCursorPosition(1)
	self.AddHeaderOption("Self Bondage")
	BondagePlayer = self.AddToggleOption("Enable",Main.Config.GetBool(".BondagePlayer"))
	BondageEscapeChancePlayer = self.AddSliderOption("Base Escape Chance",GetFloat(".BondageEscapeChancePlayer"),"{0}%")
	BondageEscapeStaminaMinimum = self.AddSliderOption("Escape Stamina Required",GetFloat(".BondageEscapeStaminaMinimum"),"{0}")
	BondageEscapeStaminaFactor = self.AddSliderOption("Escape Stamina Factor",GetFloat(".BondageEscapeStaminaFactor"),"{2}")
	BondageEscapeArousalFactor = self.AddSliderOption("Escape Arousal Factor",GetFloat(".BondageEscapeArousalFactor"),"{2}")
	BondageEscapeSuccessArousal = self.AddSliderOption("Escape Success Arousal",GetFloat(".BondageEscapeSuccessArousal"),"{0}")
	BondageEscapeFailureArousal = self.AddSliderOption("Escape Failure Arousal",GetFloat(".BondageEscapeFailureArousal"),"{0}")
	BondageEscapeTimeMinimum = self.AddSliderOption("Min Time Before Escape", (GetFloat(".BondageEscapeTimeMinimum") / 60) ,"{1}")
	BondageEscapeArousalPlayer = self.AddToggleOption("Auto Dismount At 0 Arousal",GetBool(".BondageEscapeArousalPlayer"))
	BondageEscapeArousalNPC = -69 ;;self.AddToggleOption("Release NPC At 0 Arousal",GetBool(".BondageEscapeArousalNPC"))
	BondagePrintPlayerTimer = self.AddToggleOption("Show Timer Updates",GetBool(".BondagePrintPlayerTimer"))
	BondagePrintPlayerArousal = self.AddToggleOption("Show Timer Arousal",GetBool(".BondagePrintPlayerArousal"))

	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function ShowPageSplash()

	self.LoadCustomContent(Main.KeySplashGraphic)
	Return
EndFunction