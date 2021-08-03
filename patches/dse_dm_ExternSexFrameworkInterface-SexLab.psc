ScriptName dse_dm_ExternSexFrameworkInterface extends Quest Conditional
{version: sexlab}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

String Function GetFrameworkType() Global
{ask what framework this patch is for}

	Return "sexlab"
EndFunction

Form Function GetFrameworkAPI(dse_dm_QuestController Main) Global
{get the framework api object.}

	Return Main.Util.GetFormFrom("SexLab.esm",0xd62)
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Bool Function ActorIsValid(dse_dm_QuestController Main, Actor Who) Global
{check if the actor can be adultified.}

	SexLabFramework SexLab = GetFrameworkAPI(Main) As SexLabFramework
	Int Result

	If(SexLab != NONE)
		Result = SexLab.ValidateActor(Who)

		If(Result < 0)
			Main.Util.PrintDebug(Who.GetDisplayName() + " did not pass SexLab's test: " + Result)
			Return FALSE
		EndIf

		Return TRUE
	EndIf

	Return !Who.IsChild()
EndFunction

Function ImmersiveExpression(dse_dm_QuestController Main, Actor Who, Bool Enable) Global
{set a face expression.}

	SexLabFramework SexLab = GetFrameworkAPI(Main) As SexLabFramework
	sslBaseExpression E

	If(Main.Util.ActorIsMouthControlled(Who))
		Return
	EndIf

	If(Enable)
		If(Utility.RandomInt(0,1) == 1)
			E = SexLab.GetExpressionByName("Shy")
			Main.Util.PrintDebug("ImmersiveExpression " + Who.GetDisplayName() + " Shy")
		Else
			E = SexLab.GetExpressionByName("Pained")
			Main.Util.PrintDebug("ImmersiveExpression " + Who.GetDisplayName() + " Pained")
		EndIf

		E.Apply(Who,50,Who.GetLeveledActorBase().GetSex())
		Return
	Else
		sslBaseExpression.ClearMFG(Who)
	EndIf

	Return
EndFunction

Function ImmersiveSoundMoan(dse_dm_QuestController Main, Actor Who, Bool Hard=FALSE) Global
{perform a sound effect.}

	SexLabFramework SexLab = GetFrameworkAPI(Main) As SexLabFramework
	sslBaseVoice Voice

	Voice = SexLab.PickVoice(Who)

	If(Hard)
		Voice.GetSound(100).Play(Who)
		Main.Util.PrintDebug("ImmersiveSoundMoan " + Who.GetDisplayName() + " Hard")
	Else
		Voice.GetSound(30).Play(Who)
		Main.Util.PrintDebug("ImmersiveSoundMoan " + Who.GetDisplayName() + " Soft")
	EndIf

	Return
EndFunction
