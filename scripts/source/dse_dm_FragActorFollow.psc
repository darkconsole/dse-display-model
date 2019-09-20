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
	;;akSpeaker.ClearKeepOffsetFromActor()
	;;akSpeaker.SetAnimationVariableBool("bSprintOK",TRUE)
	;;akSpeaker.SetAnimationVariableBool("bEquipOK",TRUE)
	;;akSpeaker.ForceActorValue("SpeedMult",( akSpeaker.GetActorValue("SpeedMult") * 4 ))
	;;akSpeaker.ForceActorValue("CarryWeight", (akSpeaker.GetActorValue("CarryWeight") + 1))
Else
	DM.Util.BehaviourSet(akSpeaker,DM.PackageFollow)
	akSpeaker.AddToFaction(DM.FactionFollow)
	;;akSpeaker.KeepOffsetFromActor(DM.Player, afOffsetX = 0, afOffsetY =  100, afOffsetZ = 0, afCatchUpRadius = 150, afFollowRadius = 0)
	;;akSpeaker.SetAnimationVariableBool("bSprintOK",FALSE)
	;;akSpeaker.SetAnimationVariableBool("bEquipOK",FALSE)
	;;akSpeaker.ForceActorValue("SpeedMult",( akSpeaker.GetActorValue("SpeedMult") / 4 ))
	;;akSpeaker.ForceActorValue("CarryWeight", (akSpeaker.GetActorValue("CarryWeight") - 1))
EndIf

;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
