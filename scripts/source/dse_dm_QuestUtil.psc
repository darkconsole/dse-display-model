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

String Function ReadableTimeDelta(Float Time, Bool RealLife=FALSE)
{given a skyrim time (float of days) return a readble time frame. if asking for
"real life time" we will use the current timescale to calculate it. }

	String Output = ""
	Float Work = 0.0

	If(RealLife)
		Time /= Main.Timescale.GetValue()
	EndIf

	;;;;;;;;
	;;;;;;;;

	Work = Time

	If(Work > 1.0)
		Output += Math.Floor(Work) + " D,"
	EndIf
	Work = (Work - Math.Floor(Work)) * 24

	If(Work > 0.0)
		Output += Math.Floor(Work) + " H,"
	EndIf
	Work = (Work - Math.Floor(Work)) * 60

	If(Work > 0.0)
		Output += Math.Floor(Work) + " M"
	EndIf

	;; hillarious trick dealing with the above string since we have no
	;; trim function.
	Output = PapyrusUtil.StringJoin(PapyrusUtil.StringSplit(Output,",")," ")

	Return Output
EndFunction

Float Function GetPlayerHeight()

	Return 128 * Main.Player.GetScale()
EndFunction

Bool Function AndAll(Int Flagset, Int Needs)
{check that a set of flags has all the values we want.}

	Bool Result = Math.LogicalAnd(Flagset,Needs) == Needs

	Return Result
EndFunction

Bool Function AndAny(Int Flagset, Int Needs)
{check that a set of flags has any the values we want.}

	Bool Result = Math.LogicalAnd(Flagset,Needs) != 0

	Return Result
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; strings

String Function StringInsert(String Format, String InputList="")
{a cheeky af implementation of like an sprintf type thing but not.}

	Int Iter = 0
	Int Pos = -1
	String ToFind
	String[] Inputs

	;; short short circuit if we can.

	If(StringUtil.GetLength(InputList) == 0)
		Return Format
	EndIf

	;; rebuild a full string.

	Inputs = PapyrusUtil.StringSplit(InputList,"|")

	While(Iter < Inputs.Length)
		ToFind = "%" + (Iter+1)
		Pos = StringUtil.Find(Format,ToFind)

		;; substring with a length of 0 means full string so we had to test
		;; the position in case the token was the first thing in the string.

		If(Pos > -1)
			If(Pos > 0)
				Format = StringUtil.Substring(Format,0,Pos) + Inputs[Iter] + StringUtil.Substring(Format,(Pos+2))
			Else
				Format = Inputs[Iter] + StringUtil.Substring(Format,(Pos+2))
			EndIf
		EndIf

		Iter += 1
	EndWhile

	Return Format
EndFunction

String Function StringLookup(String Path, String InputList="")
{get a string from the translation file and run it through StringInsert.}

	String Format = JsonUtil.GetPathStringValue(self.FileStrings,Path,("MISSING STRING DMSE: " + Path))

	Return self.StringInsert(Format,InputList)
EndFunction

String Function StringLookupRandom(String Path, String InputList="")
{get a random string from the translation file and run it through StringInsert.}

	Int Count = JsonUtil.PathCount(self.FileStrings,Path)
	Int Selected = Utility.RandomInt(0,(Count - 1))
	String Format = JsonUtil.GetPathStringValue(self.FileStrings,(Path + "[" + Selected + "]"))

	Return self.StringInsert(Format,InputList)
EndFunction

Function PrintLookup(String KeyName, String InputList="")
{print a notification string from the translation file.}

	self.Print(self.StringLookup(KeyName,InputList))
EndFunction

Function PrintLookupRandom(String KeyName, String InputList="")
{print a random string from the translation file.}

	self.Print(self.StringLookupRandom(KeyName,InputList))
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Float Function ActorArousalGetTick(Actor Who)
{determine how much the actor arousal should be modified per script tick.}

	Float Tick

	If(Who == Main.Player)
		Tick = Main.Config.GetFloat(".ArousedTickFactorPlayer")
	Else
		Tick = Main.Config.GetFloat(".ArousedTickFactor")
	EndIF

	Return Tick
EndFunction

Function ActorArousalUpdate(Actor Who, Float Mult=1.0, Int Mode=0)
{update an actors arousal based on time.}

	Float Tick = (self.ActorArousalGetTick(Who) * Mult)
	Float TimeRate = 0.0
	String Reason = ""

	If(Mode != 0)
		;; -1 = exhausting, +1 = arousing.
		Tick *= Mode As Float
		Reason = "DMSE Bondage: Arousing = " + Mode
	Else
		;; non-exhib = exhausting, exhib = arousing.
		If(self.ActorArousalExhib(Who))
			Reason = "DMSE Bondage: Exhibitionist"
		Else
			Tick *= -1.0
			Reason = "DMSE Bondage: Exhausting"
		EndIf
	EndIf

	If(Main.Config.GetBool(".ArousedTickExposure"))
		self.ActorArousalInc(Who,(Tick as Int),Reason)
	EndIf

	If(Main.Config.GetBool(".ArousedTickTimeRate"))
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

Function ActorDisarm(Actor Who)
{packages seem to ignore the "weapons equipped" flag. that or it only prevents
them from equipping if not already equipped, as it clearly is not forcing them
unequipped.}

	;; this is reverse engineering from my outfit manager where i spent
	;; forever combatting how the game will equip something else to replace
	;; the slot you just unequipped, their "previous" item so this kinda
	;; makes the game forget what the previous item really was.

	If(Who.GetItemCount(Main.WeapNull) < 2)
		Who.AddItem(Main.WeapNull, 2, TRUE)
	EndIf

	Who.EquipItemEx(Main.WeapNull, 1, TRUE, FALSE)
	Who.EquipItemEx(Main.WeapNull, 2, TRUE, FALSE)
	Who.UnequipItemEx(Main.WeapNull, 1, TRUE)
	Who.UnequipItemEx(Main.WeapNull, 2, TRUE)

	;; shield
	Who.UnequipItemSlot(39)

	self.PrintDebug("Actor Disarmed")

	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Bool Function ActorIsMouthControlled(Actor Who)
{check if an actor is having their mouth controlled for the pose.}

	Return StorageUtil.GetStringValue(Who,Main.DataKeyActorMouth,Main.KeyActorMouthNormal) != Main.KeyActorMouthNormal
EndFunction

String Function ActorMouthGet(Actor Who)
{get the mouth value.}

	Return StorageUtil.GetStringValue(Who,Main.DataKeyActorMouth,Main.KeyActorMouthNormal)
EndFunction

Function ActorMouthApply(Actor Who)
{apply the mouth value.}

	String Mouth = self.ActorMouthGet(Who)

	;; prevents the game from allowing other things to mess
	;; with the face.
	Who.SetExpressionOverride(7,100)

	If(Mouth == Main.KeyActorMouthNormal)
		self.ActorMouthClear(Who,FALSE)
	ElseIf(Mouth == Main.KeyActorMouthOpen)
		Who.SetExpressionPhoneme(11,100)
	EndIf

	Main.Util.PrintDebug("[ActorMouthApply] " + Mouth + " on " + Who.GetDisplayName())

	Return
EndFunction

Function ActorMouthClear(Actor Who, Bool FullClear=TRUE)
{reset the expression.}

	If(FullClear)
		;; allows game to control actor face.
		Who.ClearExpressionOverride()
	EndIf

	;; this seems to do nothing...
	Who.ResetExpressionOverrides()

	;; so we shall brute force it.
	Who.SetExpressionPhoneme(11,0.0)

	Main.Util.PrintDebug("[ActorMouthClear] Reset Mouth on " + Who.GetDisplayName())
	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; utility helpers for accessing data that must be communicated via extern
;; scripts so patches can be used to provide framework choices.

Bool Function ActorIsValid(Actor Who)
{ExternSexFrameworkInterface: check if the actor is valid for use.}

	Return dse_dm_ExternSexFrameworkInterface.ActorIsValid(Main,Who)
EndFunction

Function ImmersiveExpression(Actor Who, Bool Enable)
{ExternSexFrameworkInteraface: play an expression on the actor face.}

	If(!Who.Is3dLoaded())
		Return
	EndIf

	If(self.ActorIsMouthControlled(Who))
		Return
	EndIf

	If(!Who.GetRace().HasKeywordString("ActorTypeNPC"))
		Return
	EndIf

	dse_dm_ExternSexFrameworkInterface.ImmersiveExpression(Main,Who,Enable)
	Return
EndFunction

Function ImmersiveSoundMoan(Actor Who, Bool Hard=FALSE)
{ExternSexFrameworkInterface: play a moaning sound from the actor.}

	If(!Who.Is3dLoaded())
		Return
	EndIf

	dse_dm_ExternSexFrameworkInterface.ImmersiveSoundMoan(Main,Who,Hard)
	Return
EndFunction

Function ActorArousalInc(Actor Who, Int Exposure, String Reason="DM3 Arousal Mod")
{ExternSexlabAroused: update an actors arousal.}

	dse_dm_ExternSexlabAroused.ActorArousalUpdate(Main,Who,Exposure,Reason)
	Return
EndFunction

Int Function ActorArousalGet(Actor Who)
{ExternSexlabAroused: get an actors arousal.}

	Return dse_dm_ExternSexlabAroused.ActorArousalGet(Main,Who)
EndFunction

Bool Function ActorArousalExhib(Actor Who)
{ExternSexlabAroused: ask sla if the actor is an exhibitionist.}

	Return dse_dm_ExternSexlabAroused.ActorArousalExhib(Main,Who)
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

Function FreezeAllActors(Bool Freeze=TRUE, Bool LocalOnly=TRUE)
{mostly used by the wait menu to prevent them from doing crazy shit while
you wait in the same room as them.}

	Int Len = StorageUtil.FormListCount(None,Main.DataKeyActorDevice)
	Actor Who

	While(Len > 0)
		Len -= 1
		Who = StorageUtil.FormListGet(None,Main.DataKeyActorDevice,Len) As Actor

		If(Who != None)
			If(!LocalOnly || (LocalOnly && Who.GetParentCell() == Main.Player.GetParentCell()))
				self.FreezeActor(Who,Freeze)
			EndIf
		EndIf
	EndWhile

	Return
EndFunction

Function FreezeActor(Actor Who, Bool Freeze)
{prevent an actor from thinking.}

	;; the story behind the use of consoleutil is due to the Actor.EnableAI
	;; not working 1:1 as it did in oldrim. it does disable their ai, but
	;; it seems only partially or not as deeply as it used to. it used to
	;; prevent them from letting their packages control them during the wait
	;; or sleep process, but in sse it does not go that far. however manually
	;; targeting them with tai from the console worked. so. here we are.

	If(Main.HasConsoleUtil)
		If(Freeze && Who.IsAiEnabled())
			ConsoleUtil.SetSelectedReference(Who)
			ConsoleUtil.ExecuteCommand("tai")
		ElseIf(!Freeze && !Who.IsAiEnabled())
			ConsoleUtil.SetSelectedReference(Who)
			ConsoleUtil.ExecuteCommand("tai")
		EndIf
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
		Who.RemoveFromFaction(Main.FactionFollow)
		Who.RemoveFromFaction(Main.FactionStay)
		Who.SetDontMove(FALSE)
		Who.SetRestrained(FALSE)
		ActorUtil.RemovePackageOverride(Who,OldTask)
		ActorUtil.ClearPackageOverride(Who)
		StorageUtil.UnsetFormValue(Who,Main.DataKeyActorOverride)
		Main.Util.PrintDebug("BehaviourSet cleared old package off " + Who.GetDisplayName())
		Who.EvaluatePackage()
	EndIf

	;;;;;;;;

	If(Task != None)
		If(Who == Main.Player)
			Game.SetPlayerAIDriven(TRUE)
		Else
			If(Task == Main.PackageFollow)
				Who.AddToFaction(Main.FactionFollow)
			Else
				If(Task == Main.PackageStay)
					Who.AddToFaction(Main.FactionStay)
				EndIf

				Who.SetDontMove(TRUE)
				Who.SetRestrained(TRUE)
			EndIf
		EndIf

		Who.RegisterForUpdate(9001)
		StorageUtil.SetFormValue(Who,Main.DataKeyActorOverride,Task)
		ActorUtil.AddPackageOverride(Who,Task,100)
		Main.Util.PrintDebug("BehaviourSet applied new package on " + Who.GetDisplayName())
	Else
		If(Who == Main.Player)
			Game.SetPlayerAIDriven(FALSE)
		Else
			Who.SetHeadTracking(TRUE)
			Who.SetDontMove(FALSE)
			Who.SetRestrained(FALSE)
		EndIf

		Debug.SendAnimationEvent(Who,"IdleForceDefaultState")
		Who.UnregisterForUpdate()
		Main.Util.PrintDebug("BehaviourSet released " + Who.GetDisplayName())
	EndIf

	;;Utility.Wait(0.1)
	Who.EvaluatePackage()

	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function ActorBondageTimerStart(Actor Who)
{updates the tracking time that this actor enters bondage}

	If(Who == Main.Player)
		;; start tracking the client time for self bondage enforcement.
		StorageUtil.SetFloatValue(Who,Main.DataKeyActorPlayerBondageTimer,Utility.GetCurrentRealTime())
	EndIf

	StorageUtil.SetFloatValue(Who,Main.DataKeyActorBondageTimer,Utility.GetCurrentGameTime())
	Return
EndFunction

Function ActorBondageTimerUpdate(Actor Who)
{update the tracking stat for total time spent based on the time start.}

	Float TimeStart = StorageUtil.GetFloatValue(Who,Main.DataKeyActorBondageTimer,0.0)
	Float TimeNow = Utility.GetCurrentGameTime()
	Float TimeDiff = TimeNow - TimeStart

	If(TimeStart > 0.0 && TimeNow > TimeStart)
		StorageUtil.AdjustFloatValue(Who,Main.DataKeyStatTimeBound,TimeDiff)
		StorageUtil.AdjustFloatValue(None,Main.DataKeyStatTimeBound,TimeDiff)
	EndIf

	If(Who == Main.Player)
		;; clear the client time for self bondage enforcement.
		StorageUtil.SetFloatValue(Who,Main.DataKeyActorPlayerBondageTimer,0.0)
	EndIf

	StorageUtil.SetFloatValue(Who,Main.DataKeyActorBondageTimer,0.0)
	Return
EndFunction

Float Function ActorBondageTimerGet(Actor Who)
{get the tracking time that this actor entered bondage}

	Return StorageUtil.GetFloatValue(Who,Main.DataKeyActorBondageTimer,-1.0)
EndFunction

Float Function ActorBondageTimerDelta(Actor Who)
{get the tracking time that this actor entered bondage}

	Float Now = Utility.GetCurrentGameTime()
	Float Then = self.ActorBondageTimerGet(Who)

	If(Then < 0.0)
		Return 0.0
	EndIf

	Return Now - Then
EndFunction

Float Function ActorBondagePlayerTimerGet()
{get the tracking time that this actor entered bondage the player's real life time}

	Return StorageUtil.GetFloatValue(Main.Player,Main.DataKeyActorPlayerBondageTimer,-1.0)
EndFunction

Float Function ActorBondagePlayerTimerDelta(Bool InSeconds=FALSE)
{get the tracking time that this actor entered bondage the players real life time.
default is it returns the value in days passed like the game time is. returns seconds
passed if the arg is set true.}

	Float Now = Utility.GetCurrentRealTime()
	Float Then = self.ActorBondagePlayerTimerGet()

	If(Then < 0.0)
		Return 0.0
	EndIf

	If(InSeconds)
		Return (Now - Then)
	EndIf

	Return (Now - Then) / 86400
EndFunction

Float Function ActorBondageTimeTotal(Actor Who)
{return the time spent in bondage stat}

	return StorageUtil.GetFloatValue(Who,Main.DataKeyStatTimeBound,0.0)
EndFunction

Function ActorBondageTimeReset(Actor Who)
{reset the bondage stat to 0}

	StorageUtil.SetFloatValue(Who,Main.DataKeyActorBondageTimer,0.0)
	StorageUtil.SetFloatValue(Who,Main.DataKeyStatTimeBound,0.0)
	Return
EndFunction

Bool Function ActorEscapeAttempt(Actor Who)
{roll to see if an escape attempt was successful.}

	If(Who == Main.Player)
		Return self.ActorEscapeAttemptPlayer(Who)
	EndIf

	;; atm npc escape is always false. someone might appreciate the possible
	;; gamification of it though so this kinda sits here waiting for implementation.

	Return self.ActorEscapeAttemptNPC(Who)
EndFunction

Bool Function ActorEscapeAttemptNPC(Actor Who)
{roll an escape attempt for the an npc.}

	Return FALSE
EndFunction

Bool Function ActorEscapeAttemptPlayer(Actor Who)
{roll an escape attempt for the player.}

	Float Stamina = Who.GetActorValue(Main.KeyActorValueStamina)
	Float StaminaMax = Who.GetBaseActorValue(Main.KeyActorValueStamina)
	Float StaminaCost = Main.Config.GetFloat(".BondageEscapeStaminaMinimum")
	Float StaminaFactor = Main.Config.GetFloat(".BondageEscapeStaminaFactor")
	Float StaminaPercent = PapyrusUtil.ClampFloat((Stamina / StaminaMax),0.0,1.0)
	Float ArousalFactor = Main.Config.GetFloat(".BondageEscapeArousalFactor")
	Float ArousalPercent = PapyrusUtil.ClampFloat((self.ActorArousalGet(Who) / 100.0),0.0,1.0)
	Float TimeMinimum = Main.Config.GetFloat(".BondageEscapeTimeMinimum")
	Float TimePassed = Main.Util.ActorBondagePlayerTimerDelta(TRUE)
	Float Chance = Main.Config.GetFloat(".BondageEscapeChancePlayer")
	Float ChanceMax = 100.0
	Float Roll = 0.0
	Float StaminaMod = 0.0
	Float ArousalMod = 0.0
	Int ArousalFailure = Main.Config.GetInt(".BondageEscapeFailureArousal")
	Int ArousalSuccess = Main.Config.GetInt(".BondageEscapeSuccessArousal")

	;; do you even have enough energy to try.

	If(Stamina < StaminaCost)
		Main.Util.PrintDebug(Who.GetDisplayName() + " not enough stamina to escape.")
		Return FALSE
	EndIf

	StorageUtil.AdjustIntValue(Who,Main.DataKeyActorEscapeAttempts,1)
	Who.DamageActorValue(Main.KeyActorValueStamina,StaminaCost)
	self.ImmersiveSoundMoan(Who,FALSE)

	;; have you waited long enough?
	;; this is intentionally placed to allow you to waste your stamina and
	;; arousal if you're trying to be a little shit.

	If(TimePassed < TimeMinimum)
		If(ArousalFailure != 0)
			Main.Util.ActorArousalInc(Who,ArousalFailure)
		EndIf
		Main.Util.PrintDebug(Who.GetDisplayName() + " hasn't waited long enough to escape.")
		Return FALSE
	EndIf

	;; roll a chance.

	StaminaMod = (StaminaMax * (1 - StaminaPercent)) * StaminaFactor
	If(dse_dm_ExternSexlabAroused.GetPatchStatus())
		ArousalMod = (StaminaMax * (ArousalPercent - ArousalFactor)) * ArousalFactor
	EndIf

	ChanceMax += StaminaMod + ArousalMod

	Roll = Utility.RandomFloat(0.0,ChanceMax)
	Main.Util.PrintDebug(Who.GetDisplayName() + " Roll: " + Roll + " <= " + Chance + ", ChanceMax: " + ChanceMax + " (StaminaMod: " + StaminaMod + ", ArousalMod: " + ArousalMod + ")")

	If(Roll <= Chance)
		If(ArousalSuccess != 0)
			Main.Util.ActorArousalInc(Who,ArousalSuccess)
		EndIf
		Return TRUE
	EndIf

	If(ArousalFailure != 0)
		Main.Util.ActorArousalInc(Who,ArousalFailure)
	EndIf

	Return FALSE
EndFunction

Float Function GetActorValueMax(Actor Who, String ValueName)
{get the max value of whatever actor value.}

	Float Max = Who.GetBaseActorValue(ValueName)

	;; this does not take into consideration buffs.
	;; GetActorValuePercentage's result is questionable.

	Return Max
EndFunction
