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

Bool Function LeveledListHas(LeveledItem List, Form SomeShit)
{because nobody thought a HasForm for LeveledItem was worth adding appartently.}

	Int Len = List.GetNumForms()

	While(Len > 0)
		Len -= 1

		If(List.GetNthForm(Len) == SomeShit)
			Return TRUE
		EndIf
	EndWhile

	Return FALSE
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

Float[] Function GetPositionAtDistance3D(ObjectReference What, Float Dist)
{get an objects positional data if it was to be pushed away the specified
distance from itself.}

	Float[] Data = self.GetPositionData(What)

	;x = x + offset_x * cos_ry * cos_rz - offset_x * sin_rx * sin_ry * sin_rz - offset_y * cos_rx * sin_rz + offset_z * sin_ry * cos_rz + offset_z * sin_rx * cos_ry * sin_rz;
	;y = y + offset_x * cos_ry * sin_rz + offset_x * sin_rx * sin_ry * cos_rz + offset_y * cos_rx * cos_rz + offset_z * sin_ry * sin_rz - offset_z * sin_rx * cos_ry * cos_rz;
	;z = z - (offset_x * cos_rx * sin_ry) + (offset_y * sin_rx) + (offset_z * cos_rx * cos_ry);

	Data[1] = Data[1] + (Math.Sin(Data[0]) * Dist)
	Data[2] = Data[2] + (Math.Cos(Data[0]) * Dist)
	Data[3] = Data[3] - ( (Dist * Math.Cos(What.GetAngleX()) * Math.Cos(What.GetAngleY())) * Math.Sin(What.GetAngleX())) 

	Return Data
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; maths

Int Function RoundToInt(Float Val)
{round a float to an integer.}

	Return Math.Floor(Val + 0.5)
EndFunction

Float Function RoundTo(Float Val, Int Dec=0)
{round a float to a specified number of decimal places.}

	Float Bump = Math.Pow(10,Dec) As Float

	Return (Math.Floor((Val * Bump) + 0.5) As Float) / Bump
EndFunction

Float Function FloorTo(Float Val, Int Dec=0)
{floor a float to a specified number of decimal places.}

	Float Bump = Math.Pow(10,Dec) As Float

	Return (Math.Floor(Val * Bump) As Float) / Bump
EndFunction

String Function FloatToString(Float Val, Int Dec=0)
{"convert" a float into a string - e.g. get a printable float
that cuts off all the ending zeroes the game adds when casting
a float into a string directly.}

	Int Last = Math.Floor(Val)
	String Output = Last As String

	If(Dec > 0 && Val != Last)
		Output += "."

		While(Dec > 0)
			Val = (Val - Last) * 10
			Last = Math.Floor(Val)
			Output += Last As String

			Dec -= 1
		EndWhile
	EndIf

	Return Output
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Float Function ActorArousalGetTick(Actor Who)
{determine how much the actor arousal should be modified per script tick.}

	Float Tick = 1.0 

	If(Main.Aroused == None)
		Return 0.0
	EndIf

	Tick *= Main.Config.GetFloat(".ArousedTickFactor")

	If(!(Main.Aroused as slaFrameworkScr).IsActorExhibitionist(Who))
		Tick *= -1.0
	EndIf

	Return Tick
EndFunction

Function ActorArousalUpdate(Actor Who, Bool Lower=TRUE)
{update an actors arousal.}

	Float Tick = self.ActorArousalGetTick(Who)
	Float TimeRate = 0.0

	If(!Lower)
		Tick *= -1;
	EndIf

	If(Main.Aroused && Main.Config.GetBool(".ArousedTickExposure"))
		;; exposure goes up or down based on exhibitionist status.
		(Main.Aroused as slaFrameworkScr).UpdateActorExposure(Who,(Tick as Int),"Arousal Mod By DM3")
	EndIf

	If(Main.Aroused && Main.Config.GetBool(".ArousedTickTimeRate"))
		;; time rate however always goes down.
		TimeRate = ((Math.Abs(Tick) / 4) * -1) 
		StorageUtil.AdjustFloatValue(Who,"SLAroused.TimeRate",TimeRate)
		If(StorageUtil.GetFloatValue(Who,"SLAroused.TimeRate") < 0)
			StorageUtil.SetFloatValue(Who,"SLAroused.TimeRate",0.0)
		EndIf
	EndIf

	Return
EndFunction

Function ActorToggleFaction(Actor Who, Faction What)
{add the actor to a faction if not in it, remove them from it if they are.}

	If(Who.IsInFaction(What))
		Who.RemoveFromFaction(What)
	Else
		Who.AddToFaction(What)
	EndIf

	Return
EndFunction

Function ActorOutfitStop(Actor Who, Bool Strip=TRUE)
{disable an actors original outfit, saving it for later.}

	ActorBase Base = Who.GetLeveledActorBase()
	Outfit Current1 = Base.GetOutfit(FALSE)
	Outfit Current2 = Base.GetOutfit(TRUE)

	If(Current1 == Main.OutfitNone)
		Return
	EndIf

	Base.SetOutfit(Main.OutfitNone,FALSE)
	Base.SetOutfit(Main.OutfitNone,TRUE)
	Who.AddToFaction(Main.FactionActorOutfit)

	If(Strip)
		Who.UnequipAll()
	EndIf

	StorageUtil.SetFormValue(Who,Main.DataKeyActorOutfit1,Current1)
	StorageUtil.SetFormValue(Who,Main.DataKeyActorOutfit2,Current2)
	Return
EndFunction

Function ActorOutfitResume(Actor Who)
{restore an actor's default outfit.}

	ActorBase Base = Who.GetLeveledActorBase()
	Outfit Original1 = StorageUtil.GetFormValue(Who,Main.DataKeyActorOutfit1) as Outfit
	Outfit Original2 = StorageUtil.GetFormValue(Who,Main.DataKeyActorOutfit2) as Outfit

	If(Original1 != None)
		Base.SetOutfit(Original1,FALSE)
		self.ActorOutfitEquip(Who,Original1)
		Who.RemoveFromFaction(Main.FactionActorOutfit)
	EndIf

	If(Original2 != None)
		Base.SetOutfit(Original2,TRUE)
	EndIf

	Return
EndFunction

Function ActorOutfitEquip(Actor Who, Outfit Items)
{equip an outfit part by part.}

	Int Count = Items.GetNumParts()

	;; assuming these are 0 indexed...

	While(Count > 0)
		Who.EquipItem(Items.GetNthPart(Count - 1))
		Count -= 1
	EndWhile

	Return
EndFunction

Bool Function ActorIsValid(Actor Who)
{check if the actor is valid for use.}

	Int SexLabSays

	If(Main.OptValidateActor)
		SexLabSays = Main.SexLab.ValidateActor(Who)

		If(SexLabSays < 0)
			self.PrintDebug(Who.GetDisplayName() + " did not pass sexlab's test: " + SexLabSays)
			Return FALSE
		EndIf
	EndIf

	Return TRUE
EndFunction

sslBaseExpression Function ImmersiveExpression(Actor Who, Bool Enable)
{play an expression on the actor face.}

	sslBaseExpression E

	If(!Who.Is3dLoaded())
		Return None
	EndIf

	If(Enable)
		If(Utility.RandomInt(0,1) == 1)
			E = Main.SexLab.GetExpressionByName("Shy")
			;;self.PrintDebug("ImmersiveExpression " + Who.GetDisplayName() + " Shy")
		Else
			E = Main.SexLab.GetExpressionByName("Pained")
			;;self.PrintDebug("ImmersiveExpression " + Who.GetDisplayName() + " Pained")
		EndIf

		E.Apply(Who,50,Who.GetLeveledActorBase().GetSex())
		Return E
	Else
		sslBaseExpression.ClearMFG(Who)
	EndIf

	Return None
EndFunction

Function ImmersiveSoundMoan(Actor Who, Bool Hard=FALSE)
{play a moaning sound from the actor.}

	sslBaseVoice Voice

	If(!Who.Is3dLoaded())
		Return
	EndIf

	Voice = Main.SexLab.PickVoice(Who)

	If(Hard)
		Voice.GetSound(100).Play(Who)
		;;self.PrintDebug("ImmersiveSoundMoan " + Who.GetDisplayName() + " Hard")
	Else
		Voice.GetSound(30).Play(Who)
		;;self.PrintDebug("ImmersiveSoundMoan " + Who.GetDisplayName() + " Soft")
	EndIf

	Return
EndFunction

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

Function ScaleOverride(ObjectReference What, Float Scale)

	Actor Who = What As Actor
	Int IsFemale = 0

	If(Who != None)
		IsFemale = Who.GetLeveledActorBase().GetSex()
		If(Scale != 1.0)
			NiOverride.AddNodeTransformScale(Who,FALSE,IsFemale,"NPC",Main.NioKeyOverrideScale,Scale)
		Else
			NiOverride.RemoveNodeTransformScale(Who,FALSE,IsFemale,"NPC",Main.NioKeyOverrideScale)
		EndIf
		;;self.PrintDebug("ScaleOverride NiOverride " + Who.GetDisplayName() + " " + Scale)
		NiOverride.UpdateNodeTransform(Who,FALSE,IsFemale,"NPC")
	Else
		;;self.PrintDebug("ScaleOverride SetScale " + What.GetName() + " " + Scale)
		What.SetScale(Scale)
	EndIf

	Return
EndFunction

Function ScaleCancel(ObjectReference What)
{use nio to neutralize actor heights because im sure SetScale still leaks and
crashes even in sse after too many uses. why would they fix anything not related
to creationclub.}

	Actor Who = What As Actor
	Float GameScale = What.GetScale()
	String Node = Main.NioBoneScale
	Int IsFemale = 0
	Float Final

	;;;;;;;;

	If(Who != None)
		;; need more info if its an actor.
		IsFemale = Who.GetLeveledActorBase().GetSex()
		;;GameScale *= Who.GetLeveledActorBase().GetHeight()
	EndIf

	Final = 1 / GameScale

	;;Main.Util.PrintDebug("Util.ScaleCancel " + Who.GetDisplayName() + " (" + What.GetScale() + ", " + Who.GetLeveledActorBase().GetHeight() + ") = " + Final)
	NiOverride.AddNodeTransformScale(Who,FALSE,IsFemale,Node,Main.NioKeyCancelScale,Final)
	NiOverride.UpdateNodeTransform(Who,FALSE,IsFemale,Node)

	Return
EndFunction

Function ScaleResume(ObjectReference What)
{allow custom scaling to resume.}

	Actor Who = What As Actor
	String Node = Main.NioBoneScale
	Int IsFemale = 0

	If(Who != None)
		IsFemale = Who.GetLeveledActorBase().GetSex()
	EndIf

	NiOverride.RemoveNodeTransformScale(Who,FALSE,IsFemale,Node,Main.NioKeyCancelScale)
	NiOverride.UpdateNodeTransform(Who,FALSE,IsFemale,Node)

	Return
EndFunction

Function ScaleToActor(ObjectReference What, Actor Who)
{scale an object to the actor's size.}

	What.SetScale(Who.GetScale())
	Return
EndFunction

Function ScaleToNormal(ObjectReference What)
{scale an object back to normal size.}

	What.SetScale(1.0)
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
		ActorUtil.ClearPackageOverride(Who)
		StorageUtil.UnsetFormValue(Who,Main.DataKeyActorOverride)
		Main.Util.PrintDebug("BehaviourSet cleared old package off " + Who.GetDisplayName())
		Who.EvaluatePackage()
	EndIf

	;;;;;;;;

	If(Task != None)
		If(Task != Main.PackageFollow)
			Who.SetDontMove(TRUE)
			Who.SetRestrained(TRUE)
		EndIf

		Who.RegisterForUpdate(9001)
		StorageUtil.SetFormValue(Who,Main.DataKeyActorOverride,Task)
		ActorUtil.AddPackageOverride(Who,Task,100)
		Main.Util.PrintDebug("BehaviourSet applied new package on " + Who.GetDisplayName())
	Else
		Who.SetHeadTracking(TRUE)
		Who.SetDontMove(FALSE)
		Who.SetRestrained(FALSE)
		Debug.SendAnimationEvent(Who,"IdleForceDefaultState")
		Who.UnregisterForUpdate()
		Main.Util.PrintDebug("BehaviourSet released " + Who.GetDisplayName())
	EndIf

	Utility.Wait(0.01)
	Who.EvaluatePackage()

	Return
EndFunction

