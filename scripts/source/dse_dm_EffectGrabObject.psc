ScriptName dse_dm_EffectGrabObject extends ActiveMagicEffect

dse_dm_QuestController Property Main Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; thing to try from furniture dialog fragment:

;; dcc_dm_QuestController Main = dcc_dm_QuestController.Get()
;; Main.Player.AddSpell(SpellGrabObject)
;; (Main.Player As dcc_dm_EffectGrabObject).GrabEnable(akSpeaker);

;; idk if that casting trick will work.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; the various objects we are going to act upon.

Actor Property Origin Auto Hidden
{most likely the player.}

dse_dm_ActiPlaceableBase Property What Auto Hidden
{the thing we want to move.}

ObjectReference Property Where Auto Hidden
{marks the current movement position and provides a mountpoint for additional
visuals during the process.}

ObjectReference Property Undo Auto Hidden
{marks the original location before attempting to move it.}

ObjectReference Property Ghost Auto Hidden
{banana for scale.}

Bool Property Running Auto Hidden
{short circuit setinel.}

Float Property Delay Auto Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; the detected hotkeys we will use.

Int Property KeyToggle = 0 Auto Hidden
Int Property KeyRotLeft = 0 Auto Hidden
Int Property KeyRotRight = 0 Auto Hidden
Int Property KeyZoomIn = 0 Auto Hidden
Int Property KeyZoomOut = 0 Auto Hidden
Int Property KeyCancel = 0 Auto Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; various fields for the current state of affairs.

Float[] Property StatePos Auto Hidden
{heading angle, pos x, pos y, pos z}

Float Property StateDist = 200.0 Auto Hidden
{distance from origin}

Float Property StateOffsetV = 64.0 Auto Hidden
{offset to try and center objects.}

Float Property StateStartV = 0.0 Auto Hidden
Float Property StateStartH = 0.0 Auto Hidden
Float Property StateStartZ = 0.0 Auto Hidden
Float Property StateStartE = 0.0 Auto Hidden

;; states for keys being held down.

Float Property StateRot = 0.0 Auto Hidden
Float Property StatePush = 0.0 Auto Hidden
Bool Property StateRotLeft = FALSE Auto Hidden
Bool Property StateRotRight = FALSE Auto Hidden
Bool Property StateZoomIn = FALSE Auto Hidden
Bool Property StateZoomOut = FALSE Auto Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnEffectStart(Actor Who, Actor From)
{when move mode is enabled.}

	dse_dm_ActiPlaceableBase Object

	self.Origin = Who
	self.What = None
	self.Where = None
	self.Undo = None
	self.Ghost = None
	self.Running = FALSE
	self.Delay = 0.001

	self.RegisterForControlKeys()
	self.GimpUserControls()

	;; check if we forced a reference

	Object = StorageUtil.GetFormValue(self.Origin,Main.DataKeyGrabObjectTarget) as dse_dm_ActiPlaceableBase

	;; try and grab an object if needed.

	If(Object == None)
		Object = Game.GetCurrentCrosshairRef() As dse_dm_ActiPlaceableBase
	EndIf

	;; make sure we have an object.

	If(Object == None)
		Main.Util.Print("No object to target.")
		self.Origin.RemoveSpell(Main.SpellGrabObject)
		Return		
	EndIf

	;; make sure the object is legit.

	If(!Object.IsLegit())
		Main.Util.Print("Object is not a valid DM movable thing.")
		self.Origin.RemoveSpell(Main.SpellGrabObject)
		Return
	EndIf

	;; go go go

	self.GrabEnable(Object)

	Return
EndEvent

Event OnEffectFinish(Actor Who, Actor From)
{when move mode is disabled.}

	;; control key unregistration is automatic on spell removal.

	StorageUtil.UnsetFormValue(Who,Main.DataKeyGrabObjectTarget)
	self.RestoreUserControls()

	Return
EndEvent

Event OnKeyDown(Int KeyCode)
{when the player presses a key.}

	If(KeyCode == self.KeyToggle)
		If(self.What == None)
			;;self.GrabEnable()
		Else
			self.GrabDisable()
		EndIf
	ElseIf(KeyCode == self.KeyRotLeft)
		self.StateRot = 5
	ElseIf(KeyCode == self.KeyRotRight)
		self.StateRot = -5
	ElseIf(KeyCode == self.KeyZoomIn)
		self.StatePush = -5
	ElseIf(KeyCode == self.KeyZoomOut)
		self.StatePush = 5
	Elseif(KeyCode == self.KeyCancel)
		If(self.What)
			self.GrabDisable(TRUE)
		EndIf
	EndIf

	Return
EndEvent

Event OnKeyUp(Int KeyCode, Float Dur)
{when the player releases a key.}

	If(KeyCode == self.KeyToggle)
		;; nothing
	ElseIf(KeyCode == self.KeyRotLeft)
		self.StateRot = 0
	ElseIf(KeyCode == self.KeyRotRight)
		self.StateRot = 0
	ElseIf(KeyCode == self.KeyZoomIn)
		self.StatePush = 0
	ElseIf(KeyCode == self.KeyZoomOut)
		self.StatePush = 0
	ElseIf(KeyCode == self.KeyCancel)
		If(Dur > 1.0)
			(self.Origin as Actor).RemoveSpell(Main.SpellGrabObject)
		EndIf
	EndIf

	Return
EndEvent

Event OnUpdate()
{we are using this merely to kick the hard loop into a new thread.}

	self.GoGoGadget()
	Return
EndEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function GoGoGadget()
{this is the hard loop that does the literal heavy lifting. it is going about
as fast as papyrus' shitty little legs can carry it.}

	;;ObjectReference RememberMe = self.What

	;;Main.Util.Print("Grabbed " + RememberMe.GetDisplayName())

	While(self.Running)

		;; update the position data.

		self.PositionAtDistance()

		;; commit the move.

		If(self.Running)
			self.Where.TranslateTo(                                   \
				self.StatePos[1], self.StatePos[2], self.StatePos[3], \
				0, 0, self.StatePos[0],                               \
				600, 90                                               \
			)
		EndIf

		;; @todo - try setting the ghost to use where as its vehicle
		;; instead of another position thing. may not work on static.
		;; if not consider testing MovableStatic. if not then this is
		;; that.

		If(self.Running)
			self.Ghost.TranslateTo(                                   \
				self.StatePos[1], self.StatePos[2], self.StatePos[3], \
				0, 0, self.StatePos[0],                               \
				600, 90                                               \
			)
		EndIf

		;; give the loop a breather.

		If(self.Delay != 0.0)
			Utility.Wait(self.Delay)
		EndIf

		;;self.RegisterForSingleUpdate(0.0)
		;;Return
	EndWhile

	;;Main.Util.Print("Dropped " + RememberMe.GetDisplayName())

	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function GimpUserControls()
{gimp some of the player's controls to make use cleaner looking.}	

	Game.DisablePlayerControls( \
		abMovement    = false, \
		abFighting    = true, \
		abCamSwitch   = true, \
		abLooking     = false, \
		abSneaking    = true, \
		abMenu        = true, \
		abActivate    = true, \
		abJournalTabs = true \
	)

	Main.Util.UnequipShout(self.Origin as Actor)
	(self.Origin As Actor).SheatheWeapon()

	Return
EndFunction

Function RestoreUserControls()
{allow the player full access again.}

	Game.EnablePlayerControls()

	Return
EndFunction

Function RegisterForControlKeys()
{register for keybindings.}

	self.KeyToggle = Input.GetMappedKey("Ready Weapon")
	self.KeyRotLeft = Input.GetMappedKey("Left Attack/Block")
	self.KeyRotRight = Input.GetMappedKey("Right Attack/Block")
	self.KeyZoomIn = Input.GetMappedKey("Shout")
	self.KeyZoomOut = Input.GetMappedKey("Sprint")
	self.KeyCancel = Input.GetMappedKey("Sneak")

	self.RegisterForKey(self.KeyToggle)
	self.RegisterForKey(self.KeyRotLeft)
	self.RegisterForKey(self.KeyRotRight)
	self.RegisterForKey(self.KeyZoomIn)
	self.RegisterForKey(self.KeyZoomOut)
	self.RegisterForKey(self.KeyCancel)

	Return
EndFunction

Function UnregisterForControlKeys()
{unregister for keybindings.}

	Return

	self.UnregisterForKey(self.KeyToggle)
	self.UnregisterForKey(self.KeyRotLeft)
	self.UnregisterForKey(self.KeyRotRight)
	self.UnregisterForKey(self.KeyZoomIn)
	self.UnregisterForKey(self.KeyZoomOut)
	self.UnregisterForKey(self.KeyCancel)

	Return
EndFunction

Function PositionAtDistance()
{modify the state position data for the movement to use.}

	;; if you make this process too fast the while loop wont allow the
	;; script to catch any changes in the states fast enough, so i'm actually
	;; using an external function call here on purpose just to force the thread
	;; lock to break with the position data func from util.
	self.StatePos = Main.Util.GetPositionData(self.Origin)

	;; offset the actor if we didn't grab it exactly center.
	self.StatePos[0] = self.StatePos[0] + self.StateStartH

	;; consider changes in height both start position and walking upstairs.
	self.StatePos[3] = self.StatePos[3] + (self.StateStartZ - self.StateStartE)

	;; if we are holding down a zoom key apply it to the distance.
	self.StateDist += self.StatePush

	;; find the spot x units away from where we are standing in the dir we are facing.
	self.StatePos[1] = self.StatePos[1] + (Math.Sin(self.StatePos[0]) * self.StateDist)
	self.StatePos[2] = self.StatePos[2] + (Math.Cos(self.StatePos[0]) * self.StateDist)
	
	;; looking up or down, raise or lower the object
	self.StatePos[3] = self.StatePos[3] + ((self.Origin.GetAngleX() - self.StateStartV) * (self.StateDist / -50)) 

	;; get the object's rotation and apply rotation if holding down the rot key.
	self.StatePos[0] = self.Where.GetAngleZ() + self.StateRot

	Return
EndFunction

Function GrabEnable(dse_dm_ActiPlaceableBase Obj)
{pick up the targeted object.}

	Form GhostForm
	Int WaitIter

	;;;;;;;;

	;; get what we want to move.

	self.What = Obj

	If(self.What == None)
		Main.Util.PrintDebug("GrabEnable no target selected")
		self.Origin.RemoveSpell(Main.SpellGrabObject)
		Return
	EndIf

	If(!self.What.HasKeyword(Main.KeywordFurniture))
		Main.Util.PrintDebug("GrabEnable target was not DM Furniture")
		self.Origin.RemoveSpell(Main.SpellGrabObject)
		Return
	EndIf

	GhostForm = self.What.GetGhostForm()

	If(GhostForm == None)
		Main.Util.PrintDebug("GrabEnable unable to find ghost form")
		self.Origin.RemoveSpell(Main.SpellGrabObject)
		Return
	EndIf

	;;;;;;;;

	self.StateStartV = self.Origin.GetAngleX()
	self.StateStartH = self.Origin.GetHeadingAngle(self.What)
	self.StateStartZ = self.What.GetPositionZ()
	self.StateStartE = self.Origin.GetPositionZ()
	self.StateDist = Math.SqRt(Math.Pow((self.What.GetPositionX()-self.Origin.GetPositionX()),2)+Math.Pow((self.What.GetPositionY()-self.Origin.GetPositionY()),2))

	;; leave an undo marker.

	self.Undo = self.What.PlaceAtMe(Main.MarkerGhost,1,TRUE,TRUE)

	;; build a ghost model for visual representation

	self.Ghost = self.What.PlaceAtMe(GhostForm,1,TRUE,TRUE)

	;; build a vehicle to move it.

	self.Where = self.What.PlaceAtMe(Main.MarkerActive,1,TRUE,TRUE)

	;; get them enabled.

	self.Ghost.Enable(FALSE)
	self.Undo.Enable(FALSE)
	self.Where.Enable(FALSE)

;;	WaitIter = 0
;;	While(WaitIter < 12 && (!self.Ghost.Is3dLoaded() || !self.Undo.Is3dLoaded() || !self.Where.Is3dLoaded()))
;;		Main.Util.PrintDebug("GrabEnable waiting for 3D to load " + WaitIter)
;;		Utility.Wait(0.25)
;;		WaitIter += 1
;;	EndWhile
	
	;; kick off a new thread.

	self.Running = TRUE
	self.RegisterForSingleUpdate(0.1)

	Return
EndFunction

Function GrabDisable(Bool UndoMove=FALSE)
{drops the object currently being manhandled.}

	If(!self.Running)
		self.Origin.RemoveSpell(Main.SpellGrabObject)
		Return
	EndIf

	;; lock the objects down.

	self.Running = FALSE
	self.Ghost.StopTranslation()
	self.Where.StopTranslation()

	;; move the original to the new spot.

	If(!UndoMove)
		;; doing a moveto or setposition causes objects to reload themselves
		;; which not only reloads the 3d but resets the script states on them.
		;; this trick will slide the object over to avoid that.

		self.What.SetMotionType(self.What.Motion_Keyframed)
		self.What.TranslateToRef(self.Where,10000,0)

		Utility.Wait(0.25)
		self.What.StopTranslation()
		;;self.What.SetMotionType(self.What.Motion_Fixed)

		self.What.Refresh()
	EndIf

	;; clean up

	self.Ghost.Disable()
	self.Ghost.Delete()
	self.Ghost = None

	self.Where.Disable()
	self.Where.Delete()
	self.Where = None

	self.Undo.Disable()
	self.Undo.Delete()
	self.Undo = None

	self.Origin.RemoveSpell(Main.SpellGrabObject)
	Return
EndFunction
