Scriptname aaatowCV_Main extends ReferenceAlias  

aaatowCV Property CV Auto
Import aaatowCV

;  ----------- FUNCTIONS ----------- 
float Function GetFovByDistance(float fdistance)
	float result = 0.0
	int index = -1
	if (fDistance < 50)
		index = 0
	elseif (fDistance > 50 && fDistance <= 75)
		index = 1
	elseif (fDistance > 75 && fDistance <= 100)
		index = 2
	elseif (fDistance > 100 && fDistance <= 125)
		index = 3
	elseif (fDistance > 125 && fDistance <= 150)
		index = 4
	elseif (fDistance > 150)
		index = 5
	endif
	if (index > -1)
		result = CV.FoVSet[index]
	endif

	if (CV.bDebugMsg)
		DebugMessage("GetFovByDistance(fdistance):" + result)
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

Function ResetAllSetting()
	if (CV.bReset)
		CV.bReset = false
		bDialogue = false
		fWorldFovIni = Utility.GetINIFloat("fDefaultWorldFOV:Display")
		f1stPersonFovIni = Utility.GetINIFloat("fDefault1stPersonFOV:Display")
		MouseXScaleIni = Utility.GetINIFloat("fMouseHeadingXScale:Controls")
		MouseYScaleIni = Utility.GetINIFloat("fMouseHeadingYScale:Controls")

		if (CV.bDebugMsg)
			DebugMessage("[before] fWorldFovIni:" + fWorldFovIni + "f1stPersonFovIni:" + f1stPersonFovIni)
			DebugMessage("[before] MouseXScaleIni:" + MouseXScaleIni + "MouseYScaleIni:" + MouseYScaleIni)
		endif

		fWorldFovIni = CV.fResetSetting[0]
		f1stPersonFovIni = CV.fResetSetting[1]
		MouseXScaleIni = CV.fResetSetting[2]
		MouseYScaleIni = CV.fResetSetting[3]
		
		ResetFov()
		ResetMouseSensitivity()

		if (CV.bDebugMsg)
			DebugMessage("[after] fWorldFovIni:" + fWorldFovIni + "f1stPersonFovIni:" + f1stPersonFovIni)
			DebugMessage("[after] MouseXScaleIni:" + MouseXScaleIni + "MouseYScaleIni:" + MouseYScaleIni)
		endif
	endif
endFunction

bool Function IsHeadingAngle(ObjectReference Target)
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

;  ----------- VARIABLE ----------- 
ObjectReference aTarget
int KeyCode

bool bDialogue
bool startingFP
float fFov

float fWorldFovIni
float f1stPersonFovIni

float MouseXScaleIni
float MouseYScaleIni

; waste
bool bFP
bool bWorking
int TROnce
float fDist

;  ----------- EVENTS ----------- 
Event OnInit()
	if (CV.bReset)
		ResetAllSetting()
	endif
	RegisterForCameraState()
	RegisterForMenu("Dialogue Menu")

	fWorldFovIni = Utility.GetINIFloat("fDefaultWorldFOV:Display")
	f1stPersonFovIni = Utility.GetINIFloat("fDefault1stPersonFOV:Display")
	MouseXScaleIni = Utility.GetINIFloat("fMouseHeadingXScale:Controls")
	MouseYScaleIni = Utility.GetINIFloat("fMouseHeadingYScale:Controls")
EndEvent

Event OnPlayerLoadGame()
	if (CV.bReset)
		ResetAllSetting()
	endif
	RegisterForCameraState()
	RegisterForMenu("Dialogue Menu")

	fWorldFovIni = Utility.GetINIFloat("fDefaultWorldFOV:Display")
	f1stPersonFovIni = Utility.GetINIFloat("fDefault1stPersonFOV:Display")
	MouseXScaleIni = Utility.GetINIFloat("fMouseHeadingXScale:Controls")
	MouseYScaleIni = Utility.GetINIFloat("fMouseHeadingYScale:Controls")

endEvent

Event OnUpdate()
;
endEvent

Event OnMenuOpen(string menuName)
	if (menuName != "Dialogue Menu")
		return
	endif

	if (CV.bDebugMsg)
		DebugMessage("OnMenuOpen(menuName):" + menuName)
	endif

	aTarget = Game.GetDialogueTarget()
	if (!aTarget)
		return
	endif

	if (!aTarget as Actor || !aTarget.IsInDialogueWithPlayer())
		aTarget = none
		return
	endif

	if (IsDragonType(aTarget as Actor))
		aTarget = none
		return
	endif
	
	KeyCode = Input.GetMappedKey("Toggle POV")
	RegisterForKey(KeyCode)
	SetCameraSpeed(CV.fSpeed * 1000)
	startingFP = IsFirstPerson()

	if (CV.fTR)
		RegisterForModEvent("Tracking", "OnTracking")
	endif

	if (!IsHeadingAngle(aTarget))
		if (CV.bDebugMsg)
			DebugMessage("IsHeadingAngle(aTarget):" + IsHeadingAngle(aTarget))
		endif
		return
	endif

	bDialogue = True
	
	if (CV.bSwitchPV)
		if (CV.bDebugMsg)
			DebugMessage("SwitchMode :" + CV.SwitchMode)
		endif
		if (CV.SwitchMode)
			Game.ForceFirstPerson()
		else
			ForceFirstPersonSmooth()
		endif
	endif

	float curDistance = Game.GetPlayer().GetDistance(aTarget)
	fFov = GetFovByDistance(curDistance)
	LookAtActor(aTarget, (CV.fSpeed * 1000))
	SendModEvent("Tracking", "0", curDistance)

	if (CV.SwitchMode)
		SetMouseSensitivity(fFov)
		SetFOVSmooth(fFov, fFov, (CV.fSpeed * 1000))
	endif
EndEvent

Event OnTracking(string eventName, string countStr, float orgDistance, Form sender)

	int counter = countStr as int
	if (!aTarget || !countStr || counter >= 5)
		return
	endif

	if (CV.bDebugMsg)
		DebugMessage("OnTracking:" + counter)
	endif
		
	utility.wait(0.2)

	if (!aTarget)
		return
	endif
	
	float curDistance = Game.GetPlayer().GetDistance(aTarget)
	float diff = orgDistance - curDistance

	if ((-10.0 < diff) && (diff < 10.0))
		counter += 1
		SendModEvent("Tracking", counter as string, curDistance)
		return
	endif

	LookAtActor(aTarget, (CV.fSpeed * 1000))
	SendModEvent("Tracking", "0", curDistance)
	return
endEvent

Event OnMenuClose(string menuName)
	if (menuName != "Dialogue Menu")
		return
	endif

	if (CV.bDebugMsg)
		DebugMessage("OnMenuClose(menuName):" + menuName)
	endif

	if (!bDialogue)
		aTarget = none
		return
	endif
	
	aTarget = none
	bDialogue = false
	UnregisterForModEvent("Tracking")
	UnregisterForKey(KeyCode)

	if (startingFP)
		if (!IsFirstPerson())
			if (CV.SwitchMode)
				Game.ForceFirstPerson()
			else
				ForceFirstPersonSmooth()
			endif
		endif
	else
		if (IsFirstPerson())
			if (CV.SwitchMode)
				ForceThirdPersonEX()
			else
				ForceThirdPersonSmooth()
			endif
		endif
	endif

	if (CV.SwitchMode)
		SetFOVSmooth(fWorldFovIni, f1stPersonFovIni, (CV.fSpeed * 1000))
		ResetMouseSensitivity()
	endif
EndEvent

Event OnKeyDown(Int iKeyCode)
	if (iKeyCode != KeyCode)
		return
	endif
	
	if (!bDialogue)
		return
	endif
	
	if (IsFirstPerson())
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
EndEvent

Event OnPlayerCameraState(int oldState, int newState)
	if (!bDialogue)
		return
	endif

	if (newState == 0 && oldState == 9) 		;3rd --> 1st
	elseif (newState == 9 && oldState == 0)		;1st --> 3rd
	else
		return
	endif

	float curDistance = Game.GetPlayer().GetDistance(aTarget)
	fFov = GetFovByDistance(curDistance)
	LookAtActor(aTarget, (CV.fSpeed * 1000))
endEvent

Function DebugMessage(string str)
PapyrusTrace(str)
Debug.Notification(str)
endFunction
