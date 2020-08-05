Scriptname BardSongsScript extends Quest Conditional 

;----------------------------------------------------------------------------------------

Scene Property BardSongsBallad01Scene auto
Scene Property BardSongsBallad01WithIntroScene auto
Scene Property BardSongsDrinkingSong01Scene auto
Scene Property BardSongsDrinkingSong01WithIntroScene auto
Scene Property BardSongsDrinkingSong03Scene auto
Scene Property BardSongsDrinkingSong03WithIntroScene auto
Scene Property BardSongsDrinkingSong02Scene auto
Scene Property BardSongsDrinkingSong02WithIntroScene auto
Scene Property BardSongsInstrumentalFlute01 auto
Scene Property BardSongsInstrumentalFlute02 auto
Scene Property BardSongsInstrumentalLute01 auto
Scene Property BardSongsInstrumentalLute02 auto
Scene Property BardSongsInstrumentalDrum01 auto
Scene Property BardSongsInstrumentalDrum02 auto
Scene Property BardSongsInstrumentalFluteonly01 auto
Scene Property BardSongsInstrumentalFluteonly02 auto
Scene Property BardSongsInstrumentalBard2Drum01 auto
Scene Property BardSongsInstrumentalBard2Drum02 auto
Scene Property BardSongsInstrumentalWedding01 auto
Scene Property BardSongsInstrumentalWedding02 auto


;----------------------------------------------------------------------------------------

ReferenceAlias Property BardSongs_Bard  Auto 
ReferenceAlias Property BardSongsInstrumental_Bard  Auto 

ReferenceAlias Property BardSongs_Bard2  Auto 
ReferenceAlias Property BardSongsInstrumental_Bard2  Auto 

VoiceType Property FemaleYoungEager Auto 
voiceType Property MaleYoungEager Auto 

Quest Property MQ306 Auto
Quest Property MQ106 Auto
Quest Property MQ203 Auto

ActorBase Property TalsgarTheWanderer Auto

Actor Property Sven Auto
Actor Property Lurbuk Auto
Package Property MorthalLurbukSleep1x5 Auto

Faction Property CurrentFollowerFaction Auto

Keyword Property LocTypeInn Auto

;----------------------------------------------------------------------------------------

Location Property HaafingarHoldLocation Auto
Location Property WinterholdHoldLocation Auto
Location Property EastmarchHoldLocation Auto
Location Property RiftHoldLocation Auto
Location Property PaleHoldLocation Auto
Location Property ReachHoldLocation Auto
Location Property FalkreathHoldLocation Auto
Location Property WhiterunHoldLocation Auto
Location Property HjaalmarchHoldLocation Auto


Keyword Property CWOwner  Auto  

MusicType Property MUSTavernSILENCE Auto

;----------------------------------------------------------------------------------------

String Bard2SavedInstrument
Bool Bard2SavedPlayContinuous
int Bard2LastSongPlayed

String SavedInstrument
Bool SavedPlayContinuous
int SavedSongToPlay
Int LastSongPlayed
Bool ProcessingDialogueRequest
Bool StopSong = False

objectReference BardHandoff
String InstrumentHandoff
Bool PlayContinuousHandoff 
Int	SongToPlayHandoff
Bool ChangeSettingsHandoff

Float LocationOwner Conditional
Int Playing = 0 Conditional
Int InstrumentalSong = 1 Conditional
Int Bard2InstrumentalSong = 1 Conditional

;----------------------------------------------------------------------------------------


int Function GetRandomSong(objectReference PassedBard)
	
	Int BardSongToPlay = LastSongPlayed

	While BardSongToPlay == LastSongPlayed 		
		If MQ306.GetStage() > 0 													;If we're past Sovngard you can play 10: Tale of the Tongues
			BardSongToPlay = Utility.RandomInt(2,10)
		Else		
			BardSongToPlay = Utility.RandomInt(2,9)								;If not randomize the rest.
		EndIf
		
		If PassedBard.GetVoiceType() == FemaleYoungEager &&  BardSongToPlay == 2		;If the song picked is "Age Of..." for FemaleYoungEager (who can't sing it) set it to "Ragnar" 
			BardSongToPlay = 1	
		EndIf
		If PassedBard.GetVoiceType() == MaleYoungEager &&  BardSongToPlay == 3			;If the song picked is "The Dragonborn..." for MaleYoungEager  (who can't sing it) set it to "Ragnar" 
			BardSongToPlay = 1
		EndIf
	
	Endwhile 

; 	debug.Trace("Returning Random Song #"+BardSongToPlay)
	Return (BardSongToPlay)

EndFunction

;----------------------------------------------------------------------------------------

Function PlayChosenSong(Int ChosenSong)


	Int Intro = Utility.RandomInt(0,1)
	If ChosenSong < 13
		LastSongPlayed = ChosenSong
	Else
		Bard2LastSongPlayed = ChosenSong
	EndIf

	If ChosenSong == 10
; 		debug.Trace("Playing Bard song 10: Tale of the Tongues")
		If Intro == 0
; 				debug.Trace("Playing Bard song 10 without intro")
			BardSongsBallad01Scene.Start()
		Else
; 				debug.Trace("Playing Bard song 1 with intro")
			BardSongsBallad01WithIntroScene.Start()
		EndIf
	EndIf

	If ChosenSong == 1
; 		debug.Trace("Playing Bard song 1: Ragnar The Red")
		If Intro == 0
; 				debug.Trace("Playing Bard song 1: Ragnar The Red without intro")
			BardSongsDrinkingSong02Scene.Start()
		Else
; 				debug.Trace("Playing Bard song 1: Ragnar The Red with intro")	
			BardSongsDrinkingSong02WithIntroScene.Start()
		EndIf
	EndIf

	If ChosenSong == 2
; 		debug.Trace("Playing Bard song 2: Age of...")
		If Intro == 0
; 				debug.Trace("Playing Bard song 2 without intro")
			BardSongsDrinkingSong03Scene.Start()
		Else
; 				debug.Trace("Playing Bard song 2 with intro")
			BardSongsDrinkingSong03WithIntroScene.Start()
		EndIf
	EndIf

	If ChosenSong == 3
; 		debug.Trace("Playing Bard song 3: The Dragonborn")
		If Intro == 0
; 				debug.Trace("Playing Bard song 3 without intro")
			BardSongsDrinkingSong01Scene.Start()
		Else
; 				debug.Trace("Playing Bard song 3 with intro")
			BardSongsDrinkingSong01WithIntroScene.Start()
		EndIf
	EndIf

	If ChosenSong == 4
; 			debug.Trace("Playing Bard song 4: Flute1")
		InstrumentalSong = Utility.RandomInt(1,6)
		BardSongsInstrumentalFlute01.Start()
	EndIf

	If ChosenSong == 5
; 			debug.Trace("Playing Bard song 5: Flute2")
		InstrumentalSong = Utility.RandomInt(1,6)
		BardSongsInstrumentalFlute02.Start()
	EndIf

	If ChosenSong == 6
; 			debug.Trace("Playing Bard song 6: Lute1")
		InstrumentalSong = Utility.RandomInt(1,4)
		BardSongsInstrumentalLute01.Start()
	EndIf

	If ChosenSong == 7
; 			debug.Trace("Playing Bard song 7: Lute2")
		InstrumentalSong = Utility.RandomInt(1,4)
		BardSongsInstrumentalLute02.Start()
	EndIf

	If ChosenSong == 8
; 			debug.Trace("Playing Bard song 8: Drum1")
		InstrumentalSong = Utility.RandomInt(1,3)
		BardSongsInstrumentalDrum01.Start()
	EndIf

	If ChosenSong == 9
; 			debug.Trace("Playing Bard song 9: Drum2")
		InstrumentalSong = Utility.RandomInt(1,3)
		BardSongsInstrumentalDrum02.Start()
	EndIf

	If ChosenSong == 11
; 			debug.Trace("Playing Bard song 11: FluteOnly1")
		InstrumentalSong = 1
		BardSongsInstrumentalFluteonly01.Start()
	EndIf

	If ChosenSong == 12
; 			debug.Trace("Playing Bard song 12: FluteOnly2")
		InstrumentalSong = 1
		BardSongsInstrumentalFluteonly02.Start()
	EndIf

	If ChosenSong == 13
; 			debug.Trace("Playing Bard song 13")
		Bard2InstrumentalSong = Utility.RandomInt(1,3)
		BardSongsInstrumentalBard2Drum01.Start()
	EndIf

	If ChosenSong == 14
; 			debug.Trace("Playing Bard song 14")
		Bard2InstrumentalSong = Utility.RandomInt(1,3)
		BardSongsInstrumentalBard2Drum02.Start()
	EndIf

	If ChosenSong == 15
; 			debug.Trace("Playing Bard song 15")
		Bard2InstrumentalSong = Utility.RandomInt(1,3)
		BardSongsInstrumentalWedding01.Start()
	EndIf

	If ChosenSong == 16
; 			debug.Trace("Playing Bard song 16")
		Bard2InstrumentalSong = Utility.RandomInt(1,3)
		BardSongsInstrumentalWedding02.Start()
	EndIf

EndFunction


;--------------------------------------------------------------------------------------

Function PlaySongRequest(objectReference Bard, String Instrument = "Any", Bool PlayContinuous = True, int SongToPlay = 0, Bool ChangeSettings = True)

		BardHandoff= Bard
		InstrumentHandoff = Instrument
		PlayContinuousHandoff = PlayContinuous
		SongToPlayHandoff = SongToPlay
		ChangeSettingsHandoff = ChangeSettings

		RegisterForSingleUpdate(1)

EndFunction


;--------------------------------------------------------------------------------------


Event OnUpdate()
	PlaySong(BardHandoff, InstrumentHandoff, PlayContinuousHandoff,SongToPlayHandoff, ChangeSettingsHandoff)
EndEvent



;---------------------------------------------------------------------------------------

Function PlaySong(objectReference Bard, String Instrument = "Any", Bool PlayContinuous = True, int SongToPlay = 0, Bool ChangeSettings = True)
; 	;Debug.tracestack()

	While Bard.IsInDialogueWithPlayer()
			if Changesettings == False && (Stopsong == True || SavedPlayContinuous == False)
				Return
			endif
			Utility.Wait(1)
; 			Debug.Trace("Playsongs is waiting...")
		EndWhile

; 	debug.Trace("Function Called. Stopsong is " + Stopsong)

	if Changesettings == False && (Stopsong == True || SavedPlayContinuous == False)
		Playing = 0
		Return
	endif

	If Bard == Lurbuk &&  Lurbuk.GetCurrentPackage() == MorthalLurbukSleep1x5
		Playing = 0
		Return     
	Endif



	if Changesettings == True	
		StopAllSongs()
	endif

	Playing = 1

	;; display model bard patch.
	;; i can go on for hours about how bad bethesda is at using their own shit.
	;; like to come up with a more generic solution so that its not display model
	;; specific but i'm not there yet. maybe some actor value or animation flag or
	;; another faction not really used. throwing them into CurrentFollowerFaction
	;; seems like a bad idea as it would unlock lots of features they should not
	;; really have.
	;; -- darkconsole

	dse_dm_QuestController DisplayModel = dse_dm_QuestController.GetAPI()

	If((Bard As Actor).IsInFaction(DisplayModel.FactionFollow) || (Bard As Actor).IsInFaction(DisplayModel.FactionActorUsingDevice))
		; Debug.Trace("Bard is controlled by Display Model. Aborting song.")
		Playing = 0
		Return
	EndIf

	;; end display model bard patch.

	If (Bard as Actor).IsInFaction(CurrentFollowerFaction)
; 		debug.Trace("Bard is a follower! Aborting song.")
		Playing = 0
		Return     
	Else
		BardSongs_Bard.forcerefto(Bard) 									;Force the passed in character into the aliases required to play
		BardSongsInstrumental_Bard.forcerefto(Bard) 
	Endif

	RegisterLocationOwner(Bard)

	If ChangeSettings == False 											;Allows the sytem to recall the function without changing the previous settings.
; 		debug.Trace("Using Previous Settings")
		Instrument = SavedInstrument
		PlayContinuous = SavedPlayContinuous
		SongToPlay = 0
	Else																	;Saves the settings of the original call.
; 		debug.Trace("Using New Settings")
		SavedInstrument = Instrument
		SavedPlayContinuous = PlayContinuous
	endif

	If (Bard as Actor).GetActorBase() == TalsgarTheWanderer
		 SavedPlayContinuous = False
	endif


; 		debug.Trace("Instrument is " + Instrument)
; 		debug.Trace("SongToPlay is " + SongToPlay)


	If Bard == Sven && MQ106.GetStage() >  20 && MQ106.Getstage() < 50
		If LastSongPlayed == 6
			SongToPlay = 7
		Else
			SongToPlay = 6
		endIf
	endif

	If Bard == Sven && MQ203.isrunning()   						;GetStage() >=  10 && MQ203.Getstage() < 40
		If LastSongPlayed == 6
			SongToPlay = 7
		Else
			SongToPlay = 6
		endIf
	endif


	If Instrument == "Instrumental"
; 		debug.Trace("Requested Instrumental")							;Randomly choose instrument to play if Instrumental was chosen
		SongToPlay = Utility.RandomInt(4,9) 
	endif

	If Instrument == "Flute"												;Play Flute song if Flute was chosen
; 		debug.Trace("Requested flute")
		If LastSongPlayed == 11
			SongToPlay = 12
		Else
			SongToPlay = 11
		endIf
	endif

	If Instrument == "Lute"												;Play Lute song if Lute was chosen
		If LastSongPlayed == 6
			SongToPlay = 7
		Else
			SongToPlay = 6
		endIf
	endif

	If Instrument == "Drum"												;Play Drum song if Drum was chosen
		If LastSongPlayed == 8
			SongToPlay = 9
		Else
			SongToPlay = 8
		endIf
	endif

; 	debug.Trace("SongToPlay is now " + SongToPlay)


	if SongToPlay == 0												;if a particular song hasn't been requested, get a random song.
; 		debug.Trace("Choosing Random Song")
		SongToPlay = GetRandomSong(Bard)      			
	endif			

; 	debug.Trace("Executing Play Chosen function Song " + SongToPlay)

	If (Bard as Actor).IsInFaction(CurrentFollowerFaction)
; 		debug.Trace("Bard is a follower! Aborting song.")
		Playing = 0
		Return     
	Endif

	If !Bard.Is3dLoaded()
; 		debug.Trace("Bard has no 3D! Aborting song.")
		Playing = 0
		Return     
	Endif


	PlayChosenSong(SongToPlay)
	
	Utility.Wait(1)
	StopSong = False


EndFunction


;--------------------------------------------------------------------------------------

Function StopAllSongs()

; 	Debug.Trace("StopAllSongs hapenning now.")	

	StopSong = True

	BardSongsBallad01Scene.Stop()
	BardSongsBallad01WithIntroScene.Stop()

	BardSongsDrinkingSong01Scene.Stop()
	BardSongsDrinkingSong01WithIntroScene.Stop()

	BardSongsDrinkingSong02Scene.Stop()
	BardSongsDrinkingSong02WithIntroScene.Stop()

	BardSongsDrinkingSong03Scene.Stop()
	BardSongsDrinkingSong03WithIntroScene.Stop()

	BardSongsInstrumentalFlute01.Stop()
	BardSongsInstrumentalFlute02.Stop()

	BardSongsInstrumentalLute01.Stop()
	BardSongsInstrumentalLute02.Stop()

	BardSongsInstrumentalDrum01.Stop()
	BardSongsInstrumentalDrum02.Stop()

	BardSongsInstrumentalFluteOnly01.Stop()
	BardSongsInstrumentalFluteOnly02.Stop()

	Playing = 0

EndFunction

;--------------------------------------------------------------------------------------

Function RegisterLocationOwner(objectreference BardToCheck)

	

	Location CurrentLocation 

	If BardToCheck.isInLocation(HaafingarHoldLocation)
		 CurrentLocation = HaafingarHoldLocation 

	ElseIf BardToCheck.isInLocation(WinterholdHoldLocation)
		 CurrentLocation = WinterholdHoldLocation

	ElseIf BardToCheck.isInLocation(EastmarchHoldLocation)
		 CurrentLocation = EastmarchHoldLocation

	ElseIf BardToCheck.isInLocation(RiftHoldLocation)
		 CurrentLocation = RiftHoldLocation

	ElseIf BardToCheck.isInLocation(PaleHoldLocation)
		 CurrentLocation = PaleHoldLocation

	ElseIf BardToCheck.isInLocation(ReachHoldLocation)
		 CurrentLocation = ReachHoldLocation

	ElseIf BardToCheck.isInLocation(FalkreathHoldLocation)
		 CurrentLocation = FalkreathHoldLocation

	ElseIf BardToCheck.isInLocation(WhiterunHoldLocation)
		 CurrentLocation = WhiterunHoldLocation

	ElseIf BardToCheck.isInLocation(HjaalmarchHoldLocation)
		 CurrentLocation = HjaalmarchHoldLocation
	Else
		CurrentLocation = WhiterunHoldLocation 
	Endif

	LocationOwner = CurrentLocation.GetKeywordData(CWOwner)

EndFunction



;--------------------------------------------------------------------------------------


Function Bard2PlaySong(objectReference Bard, String Instrument = "Any", Bool PlayContinuous = True, int SongToPlay = 0, Bool ChangeSettings = True)

	
	if Changesettings == False && (Stopsong == True || PlayContinuous == False)
		Return
	endif

	BardSongs_Bard2.forcerefto(Bard) 									;Force the passed in character into the aliases required to play
	BardSongsInstrumental_Bard2.forcerefto(Bard) 

	RegisterLocationOwner(Bard)

	If ChangeSettings == False 											;Allows the sytem to recall the function without changing the previous settings.
; 		debug.Trace("Using Previous Settings")
		Instrument = Bard2SavedInstrument
		PlayContinuous = Bard2SavedPlayContinuous
		SongToPlay = 0
	Else																	;Saves the settings of the original call.
; 		debug.Trace("Using New Settings")
		Bard2SavedInstrument = Instrument
		Bard2SavedPlayContinuous = PlayContinuous
	endif


	If Instrument == "Drum"												;Play Drum song if Drum was chosen
; 		debug.Trace("Bard2 recognized Instrument is " + Instrument)
		If Bard2LastSongPlayed == 13
			SongToPlay = 14
		Else
			SongToPlay = 13
		endIf
	endif

	If Instrument == "Flute"												;Play Flute song if Flute was chosen
		If Bard2LastSongPlayed == 15
			SongToPlay = 16
		Else
			SongToPlay = 15
		endIf
	endif

; 	debug.Trace("Bard2 Instrument is " + Instrument)
; 	debug.Trace("Bard2 SongToPlay is " + SongToPlay)

	If (Bard as Actor).IsInFaction(CurrentFollowerFaction) 
; 		debug.Trace("Bard is a follower! Aborting song.")
		Playing = 0
		Return     
	Endif
	
	;If !Bard.Is3dLoaded()
; 		;debug.Trace("Bard has no 3D! Aborting song.")
		;Playing = 0
		;Return     
	;Endif

	PlayChosenSong(SongToPlay)
	

EndFunction

;---------------------------------------------------------------------------------------------

Function StopInnMusic()
		Game.GetPlayer().GetCurrentLocation().HasKeyword(LocTypeInn)
		MUSTavernSilence.Add()

EndFunction

