Scriptname dse_dm_ActiPlaceableBase extends ObjectReference

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_dm_QuestController Property Main Auto
{link to the main api.}

String Property DeviceID="" Auto
{this should be set to the name of the json file that defines this device.}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; informational properties.

String Property File Auto Hidden
Form[] Property ObjectsIdle Auto Hidden
Form[] Property ObjectsUsed Auto Hidden

;; active tracking properties.

Form[] Property Actors Auto Hidden
Form[] Property Objects Auto Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnLoad()
EndEvent

Event OnActivate(ObjectReference What)
EndEvent

Event OnUpdate()
EndEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function Prepare()

	Int ActorCount
	Int ObjectsIdleCount
	Int ObjectsUsedCount

	;;;;;;;;

	self.File = Main.Devices.GetFileByID(self.DeviceID)
	ActorCount = Main.Devices.GetDeviceActorCount(self.File)
	ObjectsIdleCount = Main.Devices.GetDeviceObjectsIdleCount(self.File)
	ObjectsUsedCount = Main.Devices.GetDeviceObjectsUsedCount(self.File)

	self.Actors = Utility.CreateFormArray(ActorCount)
	self.ObjectsIdle = Utility.CreateFormArray(ObjectsIdleCount)
	self.ObjectsUsed = Utility.CreateFormArray(ObjectsUsedCount)

	Main.Util.PrintDebug(self.DeviceID + " Prepare " + ActorCount + " actor slots")
	Main.Util.PrintDebug(self.DeviceID + " Prepare " + ObjectsIdleCount + " objects when idle")
	Main.Util.PrintDebug(self.DeviceID + " Prepare " + ObjectsUsedCount + " objects when used")

	;;;;;;;;

	self.PlaceObjectsIdle()
	self.GotoState("Idle")
	Return
EndFunction

Function PlaceObjectsIdle()
{place objects in the scene when the furniture is idle.}

	If(self.ObjectsIdle.Length == 0)
		Return
	EndIf

	Return
EndFunction

Function PlaceObjectsUsed()
{place objects in the scene when the furniture is in use.}

	If(self.ObjectsUsed.Length == 0)
		Return
	EndIf

	Return
EndFunction

Function MoveThisThing()

	StorageUtil.SetFormValue(Main.Player,Main.DataKeyGrabObjectTarget,self)
	Main.Player.AddSpell(Main.SpellGrabObject)

	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Auto State Initial

	Event OnLoad()
		{handle the device being spawned in the world.}
		
		If(self.DeviceID == "")
			Debug.MessageBox("DeviceID was not set.")
			Return
		EndIf

		self.UnregisterForUpdate()
		self.RegisterForSingleUpdate(0.25)
		Return
	EndEvent

	Event OnUpdate()
		{finish setting up the device.}

		self.Prepare()
		Return
	EndEvent

EndState

State Idle

	Event OnActivate(ObjectReference What)

		Int Selected = Main.MenuDeviceIdleActivate()

		If(Selected == 1)
			self.MoveThisThing()
		EndIf

		Return
	EndEvent

EndState

State Used

EndState
