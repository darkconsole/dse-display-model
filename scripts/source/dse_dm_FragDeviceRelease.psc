;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname dse_dm_FragDeviceRelease Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
dse_dm_QuestController Main = dse_dm_QuestController.GetAPI()
dse_dm_ActiPlaceableBase Device = Main.Devices.GetActorDevice(akSpeaker)

If(Device != None)
	Device.ReleaseActor(akSpeaker)

	;; if it was not a current follower then apply the dm follow.
	If(Main.Config.GetBool(".DeviceActorReleaseFollow"))
		If(!akSpeaker.IsInFaction(Main.GameCurrentFollowerFaction))
			Main.Util.BehaviourSet(akSpeaker,Main.PackageFollow)
			akSpeaker.AddToFaction(Main.FactionFollow)
		EndIf
	EndIf

EndIf
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
