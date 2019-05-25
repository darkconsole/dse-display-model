ScriptName dse_dm_EffectAssignNPC extends ActiveMagicEffect

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_dm_QuestController Property Main Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Int Property KeyToggle = 0 Auto Hidden
Int Property KeyCancel = 0 Auto Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnEffectStart(Actor Who, Actor Caster)
{circuits activated}

	self.GimpUserControls()
	self.RegisterForControlKeys()
	Main.ImodModeAssign.Apply(1.0)

	Return
EndEvent

Event OnEffectFinish(Actor Who, Actor Caster)
{byebye now}

	StorageUtil.UnsetFormValue(Main.Player,"DM3.AssignNPC.Device")
	StorageUtil.UnsetIntValue(Main.Player,"DM3.AssignNPC.Slot")

	self.RestoreUserControls()
	Main.ImodModeAssign.Remove()

	Return
EndEvent

Event OnKeyDown(Int KeyCode)
{when the player presses a key.}

	Return
EndEvent

Event OnKeyUp(Int KeyCode, Float Dur)
{when the player releases a key.}

	If(KeyCode == self.KeyCancel)
		Main.Player.RemoveSpell(Main.SpellAssignNPC)
	ElseIf(KeyCode == self.KeyToggle)
		self.Assign()
	EndIf

	Return
EndEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function Assign()
{assign to a device}

	dse_dm_ActiPlaceableBase Device = StorageUtil.GetFormValue(Main.Player,"DM3.AssignNPC.Device") As dse_dm_ActiPlaceableBase
	Int Slot = StorageUtil.GetIntValue(Main.Player,"DM3.AssignNPC.Slot",-1)
	Actor Who = Game.GetCurrentCrosshairRef() As Actor

	;;;;;;;;

	If(Who == None)
		Main.Util.PrintDebug("EffectAssignNPC no actor selected")
		Main.Player.RemoveSpell(Main.SpellAssignNPC)
		Return
	EndIf

	If(Device == None)
		Main.Util.PrintDebug("EffectAssignNPC missing device reference")
		Main.Player.RemoveSpell(Main.SpellAssignNPC)
		Return
	EndIf

	If(Slot < 0)
		Main.Util.PrintDebug("EffectAssignNPC missing device slot")
		Main.Player.RemoveSpell(Main.SpellAssignNPC)
		Return
	EndIf

	;;;;;;;;

	Device.ActivateByActor(Who,Slot)
	Main.Player.RemoveSpell(Main.SpellAssignNPC)

	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function RegisterForControlKeys()
{register for input}

	self.KeyToggle = Input.GetMappedKey("Ready Weapon")
	self.KeyCancel = Input.GetMappedKey("Sneak")

	self.RegisterForKey(self.KeyToggle)
	self.RegisterForKey(self.KeyCancel)

	Return
EndFunction

Function GimpUserControls()
{gimp some of the player's controls to make use cleaner looking.}	

	Game.DisablePlayerControls( \
		abMovement    = false, \
		abFighting    = true, \
		abCamSwitch   = true, \
		abLooking     = false, \
		abSneaking    = true, \
		abMenu        = true, \
		abActivate    = false, \
		abJournalTabs = true \
	)

	Main.Util.UnequipShout(Main.Player)
	Main.Player.SheatheWeapon()

	Return
EndFunction

Function RestoreUserControls()
{allow the player full access again.}

	Game.EnablePlayerControls()

	Return
EndFunction
