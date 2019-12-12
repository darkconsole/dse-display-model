ScriptName dse_dm_QuestController extends Quest

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_dm_QuestConfig Property Config Auto
dse_dm_QuestDeviceManager Property Devices Auto
dse_dm_QuestUtil Property Util Auto

SexLabFramework Property SexLab = None Auto Hidden
Quest Property Aroused = None Auto Hidden ;; slaFrameworkScr
Bool Property HasConsoleUtil = TRUE Auto Hidden
Bool Property OptValidateActor = TRUE Auto Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Actor Property Player Auto
Light Property LightFace Auto
Spell Property SpellActorMoan Auto
Spell Property SpellAssignNPC Auto
Spell Property SpellGrabObject Auto
Static Property MarkerGhost Auto
Static Property MarkerActive Auto
Keyword Property KeywordFurniture Auto
Faction Property FactionActorUsingDevice Auto
Faction Property FactionActorToggleLightFace Auto
Faction Property FactionActorToggleHeadTracking Auto
Faction Property FactionActorRandomSlotOnLoad Auto
Faction Property FactionActorOutfit Auto
Faction Property FactionFollow Auto
ImageSpaceModifier Property ImodModeAssign Auto
ImageSpaceModifier Property ImodModeMove Auto
Outfit Property OutfitNone Auto
Package Property PackageFollow Auto
FormList Property ListBookVendors Auto
Book Property BookDialogue Auto
GlobalVariable Property Timescale Auto


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

String Property KeyESP = "dse-display-model.esp" AutoReadOnly Hidden
String Property KeySplashGraphic = "dse-display-model/splash.dds" AutoReadOnly Hidden
String Property DataKeyGrabObjectTarget = "DM3.GrabObject.Target" AutoReadOnly Hidden
String Property DataKeyActorDevice = "DM3.Actor.Device" AutoReadOnly Hidden
String Property DataKeyActorOutfit1 = "DM3.Actor.Outfit1" AutoReadOnly Hidden
String Property DataKeyActorOutfit2 = "DM3.Actor.Outfit2" AutoReadOnly Hidden
String Property DataKeyDeviceList = "DM3.DeviceManager.List" AutoReadOnly Hidden
String Property DataKeyActorOverride = "DM3.Actor.Override" AutoReadOnly Hidden
String Property DataKeyActorMouth = "DM3.Actor.Mouth" AutoReadOnly Hidden
String Property DataKeyActorMoan = "DM3.Actor.Moan" AutoReadOnly Hidden
String Property DataKeyActorPlayerBondageTimer = "DM3.Actor.BondageClientStart" AutoReadOnly Hidden
String Property DataKeyActorBondageTimer = "DM3.Actor.BondageTimesStart" AutoReadOnly Hidden
String Property DataKeyActorEscapeAttempts = "DM3.Actor.EscapeAttempts" AutoReadOnly Hidden
String Property DataKeyDeviceScale = "DM3.Device.Scale" AutoReadOnly Hidden
String Property DataKeyStatTimeBound = "DM3.Stat.TimeBound" AutoReadOnly Hidden
String Property DataKeyAssignDevice = "DM3.AssignNPC.Device" AutoReadOnly Hidden
String Property DataKeyAssignSlot = "DM3.AssignNPC.Slot" AutoReadOnly Hidden

String Property EvAnimObjEquip = "AnimObjDraw" AutoReadOnly Hidden

String Property NioBoneHH         = "NPC" AutoReadOnly Hidden
String Property NioKeyCancelHH    = "DM3.CancelNioHH" AutoReadOnly Hidden
String Property NioKeyInternalHH  = "internal" AutoReadOnly Hidden
String Property NioBoneScale      = "NPC" AutoReadOnly Hidden
String Property NioKeyCancelScale = "DM3.CancelScale" AutoReadOnly Hidden
String Property NioKeyOverrideScale = "DM3.OverrideScale" AutoReadOnly Hidden

String Property KeyActorValueStamina = "Stamina" AutoReadOnly Hidden
String Property KeyMenuWait = "Sleep/Wait Menu" AutoReadOnly Hidden

String Property KeyActorMouthNormal = "normal" AutoReadOnly Hidden
String Property KeyActorMouthOpen = "open" AutoReadOnly Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_dm_QuestController Function GetAPI() Global
	Return Game.GetFormFromFile(0xd61,"dse-display-model.esp") As dse_dm_QuestController
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Bool Function CheckForDeps(Bool Popup)
{make sure we have everything we need installed.}

	Bool Output = TRUE

	If(!self.CheckForDeps_DontMergeOrEslThisShit())
		;; @todo - do something super annoying to the user.
		Debug.MessageBox(Util.StringLookup("MsgDontMergeShit"))
		Return FALSE
	EndIf

	If(!self.CheckForDeps_SKSE(Popup))
		Output = FALSE
	EndIf

	If(!self.CheckForDeps_SkyUI(Popup))
		Output = FALSE
	EndIf

	If(!self.CheckForDeps_SexLab(Popup))
		Output = FALSE
	EndIf

	If(!self.CheckForDeps_SexLabAroused(Popup))
		Output = FALSE
	EndIf

	If(!self.CheckForDeps_PapyrusUtil(Popup))
		Output = FALSE
	EndIf

	If(!self.CheckForDeps_RaceMenu(Popup))
		Output = FALSE
	EndIf

	If(!self.CheckForDeps_UIExtensions(Popup))
		Output = FALSE
	EndIf

	If(!self.CheckForDeps_ConsoleUtil(Popup))
		Output = FALSE
	EndIf

	Return Output
EndFunction

Bool Function CheckForDeps_DontMergeOrEslThisShit()
{detect if they merged this esp or attempted to esl it.}

	Form Magic = Util.GetForm(0x696969)

	If(Magic == NONE)
		Return FALSE
	EndIf

	Return TRUE
EndFunction

Bool Function CheckForDeps_SKSE(Bool Popup)
{make sure skse is new enough.}

	If(SKSE.GetScriptVersionRelease() < 56)
		If(Popup)
			Util.PopupError(Util.StringLookup("MsgUpdateSKSE"))
		EndIf

		Return FALSE
	EndIf

	Return TRUE
EndFunction

Bool Function CheckForDeps_SkyUI(Bool Popup)
{make sure we have ui extensions installed and up to date.}

	If(!Game.IsPluginInstalled("SkyUI_SE.esp"))
		If(Popup)
			Util.PopupError(Util.StringLookup("MsgUpdateSkyUI"))
		EndIf
		Return FALSE
	EndIf

	Return TRUE
EndFunction

Bool Function CheckForDeps_SexLab(Bool Popup)
{make sure we have sexlab installed and minimum version.}

	self.SexLab = Util.GetFormFrom("SexLab.esm",0xd62) As SexLabFramework

	;; check we even have sexlab.

	If(self.SexLab == NONE)
		If(Popup)
			Util.PopupError(Util.StringLookup("MsgUpdateSexLab"))
		EndIf

		Return FALSE
	EndIf

	;; check that the version of sexlab is good enough.

	If(self.SexLab.GetVersion() < 16202)
		If(Popup)
			self.Util.PopupError("Your SexLab needs to be updated. Install 1.63 SE Beta 2 or newer.")
		EndIf

		self.SexLab = NONE
		Return FALSE
	EndIf

	Return TRUE
EndFunction

Bool Function CheckForDeps_SexLabAroused(Bool Popup)
{make sure we have sexlab aroused installed.}

	;; aroused is not required for functioning so it is a soft fail.

	Quest ArousedAPI = Util.GetFormFrom("SexLabAroused.esm",0x4290f) as Quest

	;; check we even have aroused.

	If(ArousedAPI == NONE)
		Return TRUE
	EndIf

	self.Aroused = ArousedAPI

	;; check that the version of aroused is good enough.

	;;If(self.Aroused.GetVersion() < 20140124)
	;;	If(Popup)
	;;		self.Util.PopupError("Your SexLab Aroused needs to be updated. Install V27b newer.")
	;;	EndIf
	;;
	;;	self.Aroused = NONE
	;;	Return TRUE
	;;EndIf

	Return TRUE
EndFunction

Bool Function CheckForDeps_PapyrusUtil(Bool Popup)
{make sure papyrus util is new enough. mostly to detect if someone overwrote
the one that comes in sexlab with an old version.}

	If(PapyrusUtil.GetScriptVersion() < 34)
		If(Popup)
			Util.PopupError(Util.StringLookup("MsgUpdatePapyrusUtil"))
			Return FALSE
		EndIf
	EndIf

	Return TRUE
EndFunction

Bool Function CheckForDeps_RaceMenu(Bool Popup)
{make sure we have racemenu installed and up to date.}

	Bool Output = TRUE

	;; hard fail if no racemenu.

	If(!Game.IsPluginInstalled("RaceMenu.esp"))
		If(Popup)
			Util.PopupError(Util.StringLookup("MsgUpdateRaceMenu"))
		EndIf
		Output = FALSE
	EndIf

	If(NiOverride.GetScriptVersion() < 6)
		If(Popup)
			Util.PopupError(Util.StringLookup("MsgUpdateNIO"))
		EndIf
		Output = FALSE
	EndIf

	Return Output
EndFunction

Bool Function CheckForDeps_UIExtensions(Bool Popup)
{make sure we have ui extensions installed and up to date.}

	If(!Game.IsPluginInstalled("UIExtensions.esp"))
		If(Popup)
			Util.PopupError(Util.StringLookup("MsgUpdateUIExt"))
		EndIf
		Return FALSE
	EndIf

	Return TRUE
EndFunction

Bool Function CheckForDeps_ConsoleUtil(Bool Popup)
{make sure we have console util installed.}

	If(SKSE.GetPluginVersion("ConsoleUtilSSE") < 0)
		If(Popup)
			Util.PopupError(Util.StringLookup("MsgUpdateConsoleUtil"))
		EndIf
		self.HasConsoleUtil = FALSE
		Return FALSE
	EndIf

	Return TRUE
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function InstallVendorItems()

	Int Iter
	FormList CurrentList
	LeveledItem CurrentLvld
	Int CountAdds = 0

	;;;;;;;;

	Iter = self.ListBookVendors.GetSize()
	While(Iter > 0)
		Iter -= 1

		CurrentLvld = self.ListBookVendors.GetAt(Iter) As LeveledItem
		If(CurrentLvld != None && !Util.LeveledListHas(CurrentLvld,self.BookDialogue))
			CurrentLvld.AddForm(self.BookDialogue,1,1)
			CountAdds += 1
		EndIf

		CurrentList = self.ListBookVendors.GetAt(Iter) As FormList
		If(CurrentList != None && !CurrentList.HasForm(self.BookDialogue))
			CurrentList.AddForm(self.BookDialogue)
			CountAdds += 1
		EndIf
	EndWhile

	;;;;;;;;

	;;If(CountAdds > 0)
		Util.PrintDebug("InstallVendorItems: " + CountAdds + " items added to lists.")
	;;EndIf

	Return
EndFunction

Function RegisterForThings()
{indeed.}

	self.UnregisterForMenu(self.KeyMenuWait)
	self.RegisterForMenu(self.KeyMenuWait)

	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Actor Function MenuTargetGet(Actor Who=None)
{determine if we should target someone.}

	If(Who == None)
		Who = Game.GetCurrentCrosshairRef() as Actor
	EndIf

	If(Who == None)
		Who = self.Player
	EndIf

	Return Who
EndFunction

Int Function MenuDeviceSelect(Actor Who=None)
{open the actor stats menu.}

	UIListMenu Menu = UIExtensions.GetMenu("UIListMenu",TRUE) as UIListMenu
	Int NoParent = -1
	Int Iter
	Int Result

	Who = self.MenuTargetGet(Who)

	;;;;;;;;

	Iter = 0
	While(Iter < self.Devices.Names.Length)
		Menu.AddEntryItem(self.Devices.Names[Iter],NoParent)
		Iter += 1
	EndWhile

	;;;;;;;;

	self.Util.PrintDebug("MenuSelectPose: " + self.Devices.Names.Length + " poses loaded")

	Menu.OpenMenu()
	Result = Menu.GetResultInt()

	If(Result < 0)
		self.Util.PrintDebug("MenuSelectPose: Canceled")
		Return -1
	EndIf

	self.Util.PrintDebug("MenuSelectPose: " + Result + " " + self.Devices.IDs[Result] + " " + self.Devices.Names[Result] + " selected")

	Return Result
EndFunction

Int Function MenuDeviceIdleActivate()
{open the actor stats menu.}

	UIListMenu Menu = UIExtensions.GetMenu("UIListMenu",TRUE) as UIListMenu
	Int NoParent = -1
	Int Result

	;;;;;;;;

	Menu.AddEntryItem(Util.StringLookup("LabelDeviceMenuCancel"),NoParent)      ;; 0 cancel
	Menu.AddEntryItem(Util.StringLookup("LabelDeviceMenuMove"),NoParent)          ;; 1 move
	Menu.AddEntryItem(Util.StringLookup("LabelDeviceMenuPickUp"),NoParent)       ;; 2 pickup
	Menu.AddEntryItem(Util.StringLookup("LabelDeviceMenuAssignNPC"),NoParent)    ;; 3 assign
	Menu.AddEntryItem(Util.StringLookup("LabelDeviceMenuUse"),NoParent)           ;; 4 use
	Menu.AddEntryItem(Util.StringLookup("LabelDeviceMenuScale"),NoParent)  ;; 5 scale up
	Menu.AddEntryItem(Util.StringLookup("LabelDeviceMenuReload"),NoParent) ;; 6 reload device


	;;;;;;;;

	Menu.OpenMenu()
	Result = Menu.GetResultInt()

	If(Result < 0)
		self.Util.PrintDebug("MenuDeviceIdleActivate: Canceled")
		Return -1
	EndIf

	self.Util.PrintDebug("MenuDeviceIdleActivate: Selected " + Result)

	Return Result
EndFunction

Int Function MenuFromList(String[] Items)
{open the actor stats menu.}

	UIListMenu Menu = UIExtensions.GetMenu("UIListMenu",TRUE) as UIListMenu
	Int NoParent = -1
	Int Iter = 0
	Int Result

	;;;;;;;;

	While(Iter < Items.Length)
		Menu.AddEntryItem(Items[Iter],NoParent)
		Iter += 1
	EndWhile

	;;;;;;;;

	Menu.OpenMenu()
	Result = Menu.GetResultInt()

	If(Result < 0)
		self.Util.PrintDebug("MenuFromList: Canceled")
		Return -1
	EndIf

	self.Util.PrintDebug("MenuFromList: Selected " + Result)

	Return Result
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnMenuOpen(String Name)
{handler for our menu hack}

	If(Name == self.KeyMenuWait)
		Util.PrintDebug("OnMenuOpen: Wait Menu Open")
		Util.FreezeAllActors(TRUE,TRUE)
	EndIf

	Return
EndEvent

Event OnMenuClose(String Name)
{handler for our menu hack}

	If(Name == self.KeyMenuWait)
		Util.PrintDebug("OnMenuClose: Wait Menu Close")
		Utility.Wait(0.25)
		Util.FreezeAllActors(FALSE,TRUE)
	EndIf

	Return
EndEvent

