ScriptName dse_dm_FurnTheBoard01_ToggleBars extends dse_dm_ActiConnectedObject

dse_dm_QuestController Property Main Auto
ObjectReference Property PropBar Auto Hidden

Event OnActorMounted(Actor Who, Int SlotNum)

	Form Prop = Main.Util.GetForm(0x0141FD)
	ObjectReference Obj = Game.FindClosestReferenceOfType(Prop, self.X, self.Y, self.Z, 1.0)

	If(Obj != NONE)
		self.PropBar = Obj
		self.PropBar.Disable()
	EndIf

	Return
EndEvent

Event OnActorReleased(Actor Who, Int SlotNum)

	If(self.PropBar != NONE)
		self.PropBar.Enable()
	EndIf

	Return
EndEvent

