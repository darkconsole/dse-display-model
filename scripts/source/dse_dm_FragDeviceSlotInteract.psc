;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname dse_dm_FragDeviceSlotInteract Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
dse_dm_QuestController Main = dse_dm_QuestController.GetAPI()
dse_dm_ActiPlaceableBase Device = Main.Devices.GetActorDevice(akSpeaker)
Int Slot = Main.Devices.GetActorSlot(akSpeaker)

Device.InteractByPlayer(Slot)

;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
