;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname dse_dm_FragActorFollow Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
dse_dm_QuestController DM = dse_dm_QuestController.GetAPI()

If(akSpeaker.IsInFaction(DM.FactionFollow))
	DM.Util.BehaviourSet(akSpeaker,None)
	akSpeaker.RemoveFromFaction(DM.FactionFollow)
Else
	DM.Util.BehaviourSet(akSpeaker,DM.PackageFollow)
	akSpeaker.AddToFaction(DM.FactionFollow)
EndIf

;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
