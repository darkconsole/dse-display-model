ScriptName dse_dm_ItemPlaceableBase extends ObjectReference

String Property DeviceID Auto

Event OnEquipped(Actor Who)

	dse_dm_QuestController Main = dse_dm_QuestController.GetAPI()
	String DeviceFile = Main.Devices.GetFileByID(self.DeviceID)
	Activator DeviceActivator
	Form DeviceItem
	Float[] Where
	ObjectReference Object
	ObjectReference Here

	;; get the root thing to place.
	
	DeviceActivator = Main.Devices.GetDeviceActivator(DeviceFile)
	DeviceItem = Main.Devices.GetDeviceInventoryItem(DeviceFile)

	If(DeviceActivator == None)
		Main.Util.Print("device activator not found")
		Return
	EndIf

	Main.Util.CloseAllMenus()

	;; figure out where it needs to be.

	Where = Main.Util.GetPositionAtDistance(Who,160)

	;; place a point in the world.

	Here = Who.PlaceAtMe(Main.Util.GetFormFrom("Skyrim.esm",0x3B))
	Here.SetPosition(Where[1],Where[2],Where[3])
	Here.SetAngle(0,0,(Where[0] + 180))

	;; place the activator at the final point.

	Object = Here.PlaceAtMe(DeviceActivator,1,TRUE,FALSE)

	;; cleanup.

	Who.RemoveItem(DeviceItem,1)
	Here.Disable()
	Here.Delete()

	Return
EndEvent
