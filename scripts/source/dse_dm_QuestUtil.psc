ScriptName dse_dm_QuestUtil extends Quest

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_dm_QuestController Property Main Auto

String Property FileStrings = "../../../configs/dse-display-model/translations/English.json" AutoReadOnly Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; mostly debugging

Function Print(String Msg)

	Debug.Notification("[DMSE] " + Msg)
	Return
EndFunction

Function PrintDebug(String Msg)

	If(Main.Config.DebugMode)
		MiscUtil.PrintConsole("[DMSE] " + Msg)
		Debug.Trace("[DMSE] " + Msg)
	EndIf

	Return
EndFunction

Function PopupError(String Msg)
{display an error message that the user must address.}

	String Output = ""

	Output += "DMSE Error:\n"
	Output += Msg

	Debug.MessageBox(Output)
	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Form Function GetForm(Int FormID)
{get a specific form from the soulgem oven esp.}

	Return Game.GetFormFromFile(FormID,Main.KeyESP)
EndFunction

Form Function GetFormFrom(String ModName, Int FormID)
{gets a form from a specific mod.}

	If(!Game.IsPluginInstalled(ModName))
		Return NONE
	EndIf

	Return Game.GetFormFromFile(FormID,ModName)
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Float[] Function GetPositionData(ObjectReference What)
{get an object's positional data.}

	Float[] Output = new Float[4]

	Output[0] = What.GetAngleZ()
	Output[1] = What.GetPositionX()
	Output[2] = What.GetPositionY()
	Output[3] = What.GetPositionZ()

	Return Output
EndFunction

Float[] Function GetPositionAtDistance(ObjectReference What, Float Dist)
{get an objects positional data if it was to be pushed away the specified
distance from itself.}

	Float[] Data = self.GetPositionData(What)

	Data[1] = Data[1] + (Math.Sin(Data[0]) * Dist)
	Data[2] = Data[2] + (Math.Cos(Data[0]) * Dist)

	Return Data
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function HighHeelsCancel(ObjectReference Who)
{cancel nio high heels effect if it exists.}

	Int IsFemale = (Who as Actor).GetLeveledActorBase().GetSex()
	Float HS
	Float[] HH

	If(NiOverride.HasNodeTransformPosition(Who,FALSE,IsFemale,Main.NioBoneHH,Main.NioKeyInternalHH))
		;;HS = NiOverride.GetNodeTransformScale(Who,FALSE,IsFemale,Main.NioBoneHH,Main.NioKeyInternalHH)
		HH = NiOverride.GetNodeTransformPosition(Who,FALSE,IsFemale,Main.NioBoneHH,Main.NioKeyInternalHH)

		;;HS = 1 / HS
		HH[0] = -HH[0]
		HH[1] = -HH[1]
		HH[2] = -HH[2]

		NiOverride.AddNodeTransformPosition(Who,FALSE,IsFemale,Main.NioBoneHH,Main.NioKeyCancelHH,HH)
		;;NiOverride.AddNodeTransformScale(Who,FALSE,IsFemale,Main.NioBoneHH,Main.NioKeyCancelHH,HS)
		NiOverride.UpdateNodeTransform(Who,FALSE,IsFemale,Main.NioBoneHH)
	EndIf

	Return
EndFunction

Function HighHeelsResume(ObjectReference Who)
{allow nio high heels to resume.}

	Int IsFemale = (Who as Actor).GetLeveledActorBase().GetSex()

	NiOverride.RemoveNodeTransformPosition(Who,FALSE,IsFemale,Main.NioBoneHH,Main.NioKeyCancelHH)
	NiOverride.RemoveNodeTransformScale(Who,FALSE,IsFemale,Main.NioBoneHH,Main.NioKeyCancelHH)
	NiOverride.UpdateNodeTransform(Who,FALSE,IsFemale,Main.NioBoneHH)
	Return
EndFunction

Function ScaleCancel(ObjectReference What)
{use nio to neutralize actor heights because im sure SetScale still leaks and
crashes even in sse after too many uses. why would they fix anything not related
to creationclub.}

	Actor Who = What As Actor
	Float GameScale = What.GetScale()
	Int IsFemale = 0 
	Float Final

	;;;;;;;;

	If(Who != None)
		;; need more info if its an actor.
		IsFemale = Who.GetLeveledActorBase().GetSex()
		GameScale *= Who.GetLeveledActorBase().GetHeight()
	EndIf

	Final = 1 / GameScale

	Main.Util.PrintDebug("Util.ScaleCancel: " + Final)
	NiOverride.AddNodeTransformScale(Who,FALSE,IsFemale,Main.NioBoneScale,Main.NioKeyCancelScale,Final)
	NiOverride.UpdateNodeTransform(Who,FALSE,IsFemale,Main.NioBoneScale)

	Return
EndFunction

Function ScaleResume(ObjectReference What)
{allow custom scaling to resume.}

	Actor Who = What As Actor
	Int IsFemale = 0

	If(Who != None)
		IsFemale = Who.GetLeveledActorBase().GetSex()
	EndIf

	NiOverride.RemoveNodeTransformScale(Who,FALSE,IsFemale,Main.NioBoneScale,Main.NioKeyCancelScale)
	NiOverride.UpdateNodeTransform(Who,FALSE,IsFemale,Main.NioBoneScale)

	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function CloseAllMenus()
{stolen from AddItemMenu2. i had no idea. brilliant.}

	Game.DisablePlayerControls()
	Game.EnablePlayerControls()

	Return
EndFunction

Function UnequipShout(Actor Who)
{wrapper around how much of a pain in the ass it is to unequip the voice
slot spell.}

	If(Who.GetEquippedSpell(2) != None)
		Who.UnequipSpell(Who.GetEquippedSpell(2),2)
	EndIf

	If(Who.GetEquippedShout() != None)
		Who.UnequipShout(Who.GetEquippedShout())
	EndIf

	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function BehaviourSet(Actor Who, Package Task)
{force a specific package on an actor.}

	;; actorutil for sse seems to behave differently/incorrectly compared to
	;; how it behaved in oldrim. the priorities don't seem to really work
	;; and stacking packages on a priority don't fallback to previous packages
	;; anymore after removing them. before you could apply packages in 99 and 100
	;; and when you were done with 100 pop it off and 99 would take over. this
	;; doesn't seem to work properly in the sse version at all and i kind of given
	;; up hope it will be fixed so this is a super simple override system now.

	Package OldTask = StorageUtil.GetFormValue(Who,Main.DataKeyActorOverride) As Package

	If(OldTask != None)
		ActorUtil.RemovePackageOverride(Who,OldTask)
		StorageUtil.UnsetFormValue(Who,Main.DataKeyActorOverride)
		Main.Util.PrintDebug("BehaviourSet cleared old package off " + Who.GetDisplayName())
	EndIf

	;;;;;;;;

	If(Task != None)
		Who.SetDontMove(TRUE)
		Who.SetRestrained(TRUE)
		Who.RegisterForUpdate(9001)

		StorageUtil.SetFormValue(Who,Main.DataKeyActorOverride,Task)
		ActorUtil.AddPackageOverride(Who,Task,100)
		Main.Util.PrintDebug("BehaviourSet applied new package on " + Who.GetDisplayName())
	Else
		Who.SetDontMove(FALSE)
		Who.SetRestrained(FALSE)
		Debug.SendAnimationEvent(Who,"IdleForceDefaultState")
		Main.Util.PrintDebug("BehaviourSet released " + Who.GetDisplayName())
	EndIf

	Who.EvaluatePackage()

	Return
EndFunction

