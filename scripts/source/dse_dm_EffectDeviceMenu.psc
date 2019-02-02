ScriptName dse_dm_EffectDeviceMenu extends ActiveMagicEffect

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_dm_QuestController Property Main Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnEffectStart(Actor Who, Actor Caster)

	Int DeviceIndex
	String DeviceFile
	Activator DeviceActivator
	Float[] Where
	ObjectReference Object
	ObjectReference Here

	;;;;;;;;

	DeviceIndex = Main.MenuDeviceSelect(None)

	If(DeviceIndex < 0)
		Main.Util.Print("no device selected")
		Return
	EndIf

	;;;;;;;;

	DeviceFile = Main.Devices.GetFileByIndex(DeviceIndex)

	If(DeviceFile == "")
		Main.Util.Print("device index " + DeviceIndex + " not found")
		Return
	EndIf

	;;;;;;;;

	;; get the root thing to place.
	
	DeviceActivator = Main.Devices.GetDeviceActivator(DeviceFile)

	If(DeviceActivator == None)
		Main.Util.Print("device activator not found")
		Return
	EndIf

	;; figure out where it needs to be.

	Where = Main.Util.GetPositionAtDistance(Who,Main.Config.GetFloat(".DeviceDropDistance"))

	;; place a point in the world.

	Here = Who.PlaceAtMe(Main.Util.GetFormFrom("Skyrim.esm",0x3B))
	Here.SetPosition(Where[1],Where[2],Where[3])
	Here.SetAngle(0,0,(Where[0] + 180))

	;; place the activator at the final point.

	Object = Here.PlaceAtMe(DeviceActivator,1,TRUE,FALSE)

	;; cleanup.

	Here.Disable()
	Here.Delete()

	Return
EndEvent
