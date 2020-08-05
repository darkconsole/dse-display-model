ScriptName dse_dm_FurnSingleMountDisableDeco extends dse_dm_ActiConnectedObject

;; this script is an extension of the connected object script. it is designed to
;; find an object of a type you specify and disable it when an actor is mounted
;; to the furniture. it is designed for single actor furniture that need to only
;; disable one object.

;; 1) add script to the activator of a furniture that likely contains like an empty nif.
;; 2) set the properties in ck to point to the kind of object this will search for.

;; example: the display model rocking horse

;; 1) the actual furniture object has no meshes in
;; it, just collision.

;; 2) that object has this script and this script is
;; looking for the static decoration that is the 3d
;; visuals of the rocking horse device itself.

;; 3) when an actor is mounted, that decoration is
;; disabled, because the animation uses an animated
;; object prn'd to npc so that it appears to rock.

;; 4) when an actor is dismounted, that decoration
;; is re-enabled.

Activator Property ObjectToFind Auto
ObjectReference Property ObjectFound Auto Hidden

Event OnActorMounted(Actor Who, Int Slot)

	self.ObjectFound = Game.FindClosestReferenceOfType(self.ObjectToFind,self.X,self.Y,self.Z,69)

	If(self.ObjectFound == NONE)
		self.Device.Main.Util.Print("Couldn't Find Shit Yo")
		Return
	EndIf

	self.ObjectFound.Disable()
	Return
EndEvent

Event OnActorReleased(Actor Who, Int Slot)

	If(self.ObjectFound != NONE)
		self.ObjectFound.Enable()
		Return
	EndIf

	Return
EndEvent
