Scriptname aaatowCV_Main extends ReferenceAlias  

aaatowCV Property CV Auto

;  ----------- FUNCTIONS ----------- 
Function ForceFirstPersonSmooth() global native
Function ForceThirdPersonSmooth() global native
Function ForceThirdPersonEX() global native
Actor Function GetPlayerDialogueTarget() global native
Function SetFOVSmooth(float fov, float fpfov, float delay) global native
Function SetCameraSpeed(float fSpeed) global native
Function LookAtRef(ObjectReference akRef, float fSpeed) global native

float Function GetDistanceByState()
; 	Actor aPlayer = Game.GetPlayer()
; 	if !(aPlayer.GetSitState() == 3)
; ; 		return PlayerLookAtNode(aTarget, "NPC Neck [Neck]",1000)
; 		return aPlayer.GetDistance(aTarget)
; 	else
		float result = Game.GetPlayer().GetDistance(aTarget)
		if (CV.bDebugMsg)
			Debug.Notification("GetDistance:"+ result)
		endif
		return result
; 	endif
endFunction

float Function GetFovByDistance(float fdistance)
	float result = 0.0
	if fDistance < 50
		result = CV.FoVSet[0]
	elseif fDistance > 50 && fDistance <= 75
		result = CV.FoVSet[1]
	elseif fDistance > 75 && fDistance <= 100
		result = CV.FoVSet[2]
	elseif fDistance > 100 && fDistance <= 125
		result = CV.FoVSet[3]
	elseif fDistance > 125 && fDistance <= 150
		result = CV.FoVSet[4]
	elseif fDistance > 150
		result = CV.FoVSet[5]
	endif

	if (CV.bDebugMsg)
		Debug.Notification("GetFovByDistance(fDist):" + result)
	endif
	return result
endFunction

Function ResetFov()
	SetFOVSmooth(fWorldFovIni, f1stPersonFovIni, (CV.fSpeed * 1000))
endFunction

Function SetMouseSensitivity(float fov1)
	if fov1
		float fMulti = fov1 / fWorldFovIni
		float MouseXScale = MouseXScaleIni * fMulti
		float MouseYScale = MouseYScaleIni * fMulti
		Utility.SetINIFloat("fMouseHeadingXScale:Controls", MouseXScale)
		Utility.SetINIFloat("fMouseHeadingYScale:Controls", MouseYScale)
	endif
endFunction

Function ResetMouseSensitivity()
	Utility.SetINIFloat("fMouseHeadingXScale:Controls", MouseXScaleIni)
	Utility.SetINIFloat("fMouseHeadingYScale:Controls", MouseYScaleIni)
endFunction

bool Function IsHeadingAngle(Actor Target)
	Actor aPlayer = Game.GetPlayer()
	float fShoulderX	;クロスヘアがプレイヤーから見てどちらにあるか。 左側<0.0 真ん中<右側
	float fSet = 120.0
	if aPlayer.IsWeaponDrawn()
		fShoulderX = Utility.GetINIFloat("fOverShoulderCombatPosX:Camera")
	else
		fShoulderX = Utility.GetINIFloat("fOverShoulderPosX:Camera")
	endif

	int[] iResult = new int[2]
	if fShoulderX < 0.0	;Left 
		iResult[0] =  (-1 * ((fSet + fShoulderX) / 2) + fShoulderX) as int
		iResult[1] = (1 * ((fSet + fShoulderX) / 2)) as int
	elseif fShoulderX > 0.0	;Right
		iResult[0] =  (-1 * ((fSet - fShoulderX) / 2)) as int
		iResult[1] = (1 * ((fSet - fShoulderX) / 2) + fShoulderX) as int
	else	;Center
		iResult[0] = (-1 * (fSet / 2)) as int
		iResult[1] = (fSet / 2) as int
	endif
	if !(aPlayer.getHeadingAngle(Target) < iResult[1] && aPlayer.getHeadingAngle(Target) > iResult[0])
		return false
	else
		return true
	endif
endFunction

string Function GetPlayerPersonView()
	string str = none
	if (Game.GetCameraState() == 0)
		str = "1st"
	else
		str = "3rd"
	endif
	if (CV.bDebugMsg)
		Debug.Notification("Game.GetCameraState(): " + Game.GetCameraState())
	endif
	return str
endFunction


;  ----------- VARIABLE ----------- 
Actor aTarget
bool bZoomed
int KeyCode

bool bFP
float fDist
float fFov
int TROnce

float fWorldFovIni
float f1stPersonFovIni

float MouseXScaleIni
float MouseYScaleIni

;  ----------- EVENTS ----------- 
Event OnInit()
	RegisterForCameraState()
	RegisterForMenu("Dialogue Menu")
EndEvent

Event OnMenuOpen(string menuName)
	if (menuName == "Dialogue Menu")
		if (CV.bDebugMsg)
			Debug.Notification("OnMenuOpen(menuName):" + menuName)
		endif

		bZoomed = false
		bFP = !Game.GetCameraState()
		fWorldFovIni = Utility.GetINIFloat("fDefaultWorldFOV:Display")
		f1stPersonFovIni = Utility.GetINIFloat("fDefault1stPersonFOV:Display")
		MouseXScaleIni = Utility.GetINIFloat("fMouseHeadingXScale:Controls")
		MouseYScaleIni = Utility.GetINIFloat("fMouseHeadingYScale:Controls")
		KeyCode = Input.GetMappedKey("Toggle POV")

		aTarget = GetPlayerDialogueTarget()
		if aTarget
			gotostate("dialogue")
			RegisterForKey(KeyCode)
			if IsHeadingAngle(aTarget)
				if (CV.bSwitchPV)
					if (CV.bDebugMsg)
						Debug.Notification("SwitchMode :" + CV.SwitchMode)
					endif
					if (CV.SwitchMode)
						Game.ForceFirstPerson()
					else
						ForceFirstPersonSmooth()
					endif
				endif
				fDist = GetDistanceByState()
				fFov = GetFovByDistance(fDist)
				SetCameraSpeed(CV.fSpeed * 1000)
				LookAtRef(aTarget, (CV.fSpeed * 1000))
				if (CV.SwitchMode)
					bZoomed = true
					SetMouseSensitivity(fFov)
					SetFOVSmooth(fFov, fFov, (CV.fSpeed * 1000))
				endif
				if (CV.fTR && ((CV.fSpeed * 1000) > 0))
					RegisterforSingleupdate(0.2)
				endif
			else
				if (CV.bDebugMsg)
					Debug.Notification("IsHeadingAngle(aTarget):" + IsHeadingAngle(aTarget))
				endif
			endif
		endif
	endif
EndEvent

Event OnMenuClose(string menuName)
	if (menuName == "Dialogue Menu")
		if (CV.bDebugMsg)
			Debug.Notification("OnMenuClose(menuName):" + menuName)
		endif
		aTarget = None
		if GetState() == "dialogue"
			gotostate("")
			if (bFP)
				if (GetPlayerPersonView() == "3rd")
					if (CV.SwitchMode)
						Game.ForceFirstPerson()
					else
						ForceFirstPersonSmooth()
					endif
				endif
			else
				if (GetPlayerPersonView() == "1st")
					if (CV.SwitchMode)
						ForceThirdPersonEX()
					else
						ForceThirdPersonSmooth()
					endif
				endif
			endif
			if (bZoomed)
				bZoomed = false
				SetFOVSmooth(fWorldFovIni, f1stPersonFovIni, (CV.fSpeed * 1000))
				ResetMouseSensitivity()
			endif
		endif
		UnregisterForKey(KeyCode)
	endif
EndEvent

Event OnUpdate()
endEvent

Event OnKeyDown(Int iKeyCode)
endEvent

Event OnPlayerCameraState(int oldState, int newState)
endevent

state dialogue
Event OnBeginState()
	TROnce = 5
endEvent

Event OnEndState()
	TROnce = 0
endEvent

Event OnMenuOpen(string menuName)
endEvent

Event OnUpdate()
	float fDist2 = GetDistanceByState()
	if (TROnce)
		float diff = fDist - fDist2
		if ((-10.0 < diff) && (diff < 10.0))
			TROnce -= 1
			if (CV.bDebugMsg)
				Debug.Notification("TR Check [True] diff:" + diff + " TROnce:" + TROnce)
			endif
		else
			LookAtRef(aTarget, (CV.fSpeed * 1000))
			TROnce = 5
			fDist = fDist2
			if (CV.bDebugMsg)
				Debug.Notification("TR Check [False] diff:" + diff + " TROnce:" + TROnce)
			endif
		endif
		RegisterforSingleupdate(0.2)
	endif
endEvent

Event OnKeyDown(Int iKeyCode)
	if (iKeyCode == KeyCode)
		if (GetPlayerPersonView() == "1st")
			if (CV.SwitchMode)
				ForceThirdPersonEX()
				ResetMouseSensitivity()
			else
				ForceThirdPersonSmooth()
			endif
		else
			if (CV.SwitchMode)
				Game.ForceFirstPerson()
				SetMouseSensitivity(fFov)
			else
				ForceFirstPersonSmooth()
			endif
		endif
	endif
EndEvent

Event OnPlayerCameraState(int oldState, int newState)
	if (newState == 0 && oldState == 9) 		;3rd --> 1st
		fDist = GetDistanceByState()
		fFov = GetFovByDistance(fDist)
		LookAtRef(aTarget, (CV.fSpeed * 1000))
	elseif (newState == 9 && oldState == 0)		;1st --> 3rd
		fDist = GetDistanceByState()
		fFov = GetFovByDistance(fDist)
		LookAtRef(aTarget, (CV.fSpeed * 1000))
	endif
endEvent
endstate
