ScriptName dse_dm_QuestController extends Quest

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_dm_QuestConfig Property Config Auto
dse_dm_QuestDeviceManager Property Devices Auto
dse_dm_QuestUtil Property Util Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Actor Property Player Auto

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
	Result = UIExtensions.OpenMenu("UIListMenu",Who)

	If(Result >= 0)
		self.Util.PrintDebug("MenuSelectPose: " + Result + " " + self.Devices.IDs[Result] + " " + self.Devices.Names[Result] + " selected")
	Else
		self.Util.PrintDebug("MenuSelectPose Canceled")
	EndIf

	Return Result
EndFunction

