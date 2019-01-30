ScriptName dse_dm_QuestController extends Quest

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_dm_QuestConfig Property Config Auto
dse_dm_QuestDeviceManager Property Devices Auto
dse_dm_QuestUtil Property Util Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Actor Property Player Auto
Spell Property SpellAssignNPC Auto
Spell Property SpellGrabObject Auto
Static Property MarkerGhost Auto
Static Property MarkerActive Auto
Keyword Property KeywordFurniture Auto
Faction Property FactionActorUsingDevice Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

String Property KeyESP = "dse-display-model.esp" AutoReadOnly Hidden
String Property DataKeyGrabObjectTarget = "DM3.GrabObject.Target" AutoReadOnly Hidden
String Property DataKeyActorDevice = "DM3.Actor.Device" AutoReadOnly Hidden
String Property DataKeyDeviceList = "DM3.DeviceManager.List" AutoReadOnly Hidden
String Property DataKeyActorOverride = "DM3.Actor.Override" AutoReadOnly Hidden

String Property EvAnimObjEquip = "AnimObjDraw" AutoReadOnly Hidden

String Property NioBoneHH         = "NPC" AutoReadOnly Hidden
String Property NioKeyCancelHH    = "DM3.CancelNioHH" AutoReadOnly Hidden
String Property NioKeyInternalHH  = "internal" AutoReadOnly Hidden
String Property NioBoneScale      = "NPC" AutoReadOnly Hidden
String Property NioKeyCancelScale = "DM3.CancelScale" AutoReadOnly Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_dm_QuestController Function GetAPI() Global
	Return Game.GetFormFromFile(0xd61,"dse-display-model.esp") As dse_dm_QuestController
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
		self.Util.PrintDebug("MenuSelectPose Canceled")
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

	Menu.AddEntryItem("[Cancel]",NoParent)   ;; 0 cancel
	Menu.AddEntryItem("Move",NoParent)       ;; 1 move
	Menu.AddEntryItem("Pick Up",NoParent)    ;; 2 pickup
	Menu.AddEntryItem("Assign NPC",NoParent) ;; 3 assign
	Menu.AddEntryItem("Use",NoParent)        ;; 4 use

	;;;;;;;;

	Menu.OpenMenu()
	Result = Menu.GetResultInt()

	If(Result < 0)
		self.Util.PrintDebug("MenuDeviceIdleActivate Canceled")
		Return -1
	EndIf

	self.Util.PrintDebug("MenuDeviceIdleActivate Selected " + Result)

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
		self.Util.PrintDebug("MenuFromList Canceled")
		Return -1
	EndIf

	self.Util.PrintDebug("MenuFromList Selected " + Result)

	Return Result
EndFunction

