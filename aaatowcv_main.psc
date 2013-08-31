Scriptname aaatowCV_Main extends ReferenceAlias  

Import Game
Import Utility

Function ForceFirstPersonSmooth() global native
Function ForceThirdPersonSmooth() global native
Function ForceThirdPersonEX() global native
Function SetCameraAngle(float afRotZ, float afRotX, float afWait=1000.0) global native
float Function PlayerLookAtNode(ObjectReference akRef, String Nodename, float afWait=1000.0) global native
Actor Function GetPlayerDialogueTarget() global native
float Function GetDefaultFOV() global native
float Function GetCurrentFOV() global native
Function SetFOVSmooth(float fov, float delay) global native


GlobalVariable Property gvAPV  Auto
GlobalVariable Property gvSP Auto	;fMouseWheelZoomSpeed:Camera
GlobalVariable Property gvFoV Auto
GlobalVariable Property gvTR Auto
GlobalVariable[] Property gvFovDist Auto
GlobalVariable Property gvMouseSensitivity Auto

float property fAPV Hidden
	float Function Get()
		Return gvAPV.GetValue()
	EndFunction
EndProperty

bool property bAPV Hidden
	bool Function Get()
		Return gvAPV.GetValue() as bool
	EndFunction
EndProperty

float property fTR Hidden
	float Function Get()
		Return gvTR.GetValue()
	EndFunction
EndProperty

bool property bFov Hidden
	bool Function Get()
		Return gvFoV.GetValue() as bool
	EndFunction
EndProperty


bool property bMouseSensitivity Hidden
	bool Function Get()
		Return gvMouseSensitivity.GetValue() as bool
	EndFunction
EndProperty

Actor aPlayer
Actor aTarget

bool bFP
bool bSit

float fAngleF = 120.0
bool bPVZoom
;前方角度。ここの処理は手抜き

float fZoomSpeed
float fZoomSpeedIni
int iPovKeyCode

float fDist
float fFov
float fFovIni

float MouseXScale
float MouseYScale
float MouseXScaleIni
float MouseYScaleIni

Event OnInit()
	RegisterForCameraState()
	RegisterForMenu("Dialogue Menu")
	aPlayer = GetPlayer()
EndEvent

Event OnMenuOpen(string menuName)
	if (menuName != "Dialogue Menu")
		return
	endif
	GetSetting()

	gotostate("dialogue")
	RegisterForKey(iPovKeyCode)
	
	aTarget = GetPlayerDialogueTarget()
	if aTarget == None
		gotostate("")
		return
	endif
	
	bPVZoom = IsPVZoom(aTarget, fAngleF)
	SetZoomSpeed(fZoomSpeed)

; 	if !bAPV
; 		gotostate("")
; 		return
; 	endif
	
	fDist = aPlayer.GetDistance(aTarget)
	if fAPV == 1.0	;FPV
		if bFP
			fFov = GetFovDistance()
			if (fFov as bool)
				SetFov(fFov)
				SetMouseSensitivity(fFov)
			endif
		endif

		if !bSit
			fDist = PlayerLookAtNode(aTarget, "NPC Neck [Neck]",1000)
		elseif bFP
			fDist = aPlayer.GetDistance(aTarget)
		endif

		if !bFP
			ChangePV("FP", bPVZoom)
		endif
	elseif fAPV == 2.0	;TPV
		if bFP
			fDist = PlayerLookAtNode(aTarget, "NPC Neck [Neck]",1000)
			waitmenumode(0.5)
			ChangePV("TP", bPVZoom)
		endif
	endif

	if fTR >= 1.0
		RegisterforSingleupdate(0.2)
	endif
EndEvent

Event OnMenuClose(string menuName)
	if menuName != "Dialogue Menu"
		Return
	endif

	gotostate("")
	UnregisterForKey(iPovKeyCode)
	aTarget = None

	if (fFov != 0.0)
		if (fFovIni != GetCurrentFOV())
			SetFov(fFovIni)
			SetMouseSensitivity(0.0)
		endif
	endif
	fFov = 0.0
	
	if bAPV
		if !Game.GetCameraState()	; is fp?
			if !bFP
				ChangePV("TP", bPVZoom)
			endif
		else
			if bFP
				ChangePV("FP", bPVZoom)
			endif
		endif
	endif

	SetZoomSpeed(fZoomSpeedIni)
EndEvent

Event OnUpdate()
endEvent

Event OnKeyDown(Int iKeyCode)
endEvent

Event OnPlayerCameraState(int oldState, int newState)
endevent

int TROnce

state dialogue
Event OnUpdate()
	float fCDist

	if fTR as bool
		if !bSit
			fCDist = PlayerLookAtNode(aTarget, "NPC Neck [Neck]",1000)
		else
			fCDist = fDist 
		endif
	; 	debug.Notification("fDist:"+fDist + "  fCDist:"+fCDist)

		if !(fDist - fCDist <= 10.0 && fDist - fCDist >= -10.0)
			fDist = fCDist
			TROnce = 0
		else
			TROnce += 1
		endif

		if TROnce < 5
			RegisterForSingleUpdate(0.2)
		elseif TROnce >= 5
			TROnce = 0
		endif
	endif
endEvent

Event OnKeyDown(Int iKeyCode)
	if iKeyCode == iPovKeyCode
		if !GetCameraState()
			if bFov
				SetFOVSmooth(fFovIni,-1)
				ChangePV("TP", bPVZoom)
			else
				ForceTP(fZoomSpeed)
			endif
			SetMouseSensitivity(0.0)
		else
			if bFov
				SetFOVSmooth(fFov,-1)
				ChangePV("FP", bPVZoom)
			else
				ForceFP(fZoomSpeed)
			endif
			SetMouseSensitivity(fFov)
			waitmenumode(0.5)
			fDist = PlayerLookAtNode(aTarget, "NPC Neck [Neck]",1000)
		endif
	endif
EndEvent

Event OnPlayerCameraState(int oldState, int newState)
	if !bFov
		return
	elseif fAPV != 1.0	;TPV
		return
	elseif aTarget == None
		return
	endif

	if newState == 0 && oldState == 9	;FP
		int index = GetArrayNum(fDist)
		if index != -1
			fFov = gvFovDist[index].GetValue()
			if fFov != GetCurrentFOV()
				SetFOV(fFov)
				SetMouseSensitivity(fFov)
			endif
		endif
; 		aTarget = GetPlayerDialogueTarget()
		PlayerLookAtNode(aTarget, "NPC Neck [Neck]",1000)
		
	elseif newState == 9 && oldState == 0
		if fFovIni != GetCurrentFOV()
			SetFOV(fFovIni)
			SetMouseSensitivity(0.0)
			fFov = 0.0
		endif
	endif
endEvent
endstate

Function GetSetting()
	fZoomSpeed = gvSP.GetValue() as float
	fZoomSpeedIni = GetINIFloat("fMouseWheelZoomSpeed:Camera")
	iPovKeyCode = Input.GetMappedKey("Toggle POV")
	fFovIni = GetFov()
	MouseXScaleIni = GetINIFloat("fMouseHeadingXScale:Controls")
	MouseYScaleIni = GetINIFloat("fMouseHeadingYScale:Controls")

	bFP = !GetCameraState()
	bSit = (aPlayer.GetSitState() == 3) as bool
endFunction

function SetZoomSpeed(float speed)
	if fZoomSpeed != fZoomSpeedIni
		SetINIFloat("fMouseWheelZoomSpeed:Camera", speed)
	endif

endFunction

Function ForceFP(float fSpeed)
	if fSpeed == 3.0
		ForceFirstPerson()
	else
		ForceFirstPersonSmooth()
	endif
endFunction

Function ForceTP(float fSpeed)
	if fSpeed == 3.0
		ForceThirdPersonEX()
	else
		ForceThirdPersonSmooth()
	endif
endFunction

Function ChangePV(string mode, bool zoom)
	int iFov = gvFoV.GetValue() as int
	if mode == "TP"
; 		debug.Notification("zoom:"+zoom + "  iFov:"+iFov)
		if !zoom || iFov == 1
			ForceTP(3.0)
		else
			ForceTP(fZoomSpeed)
		endif
	else
; 		debug.Notification("zoom:"+zoom + "  iFov:"+iFov)
		if !zoom || iFov == 1
			ForceFP(3.0)
		else
			ForceFP(fZoomSpeed)
		endif
	endif
endFunction

float Function GetFovDistance()
	if bFov
		int index = GetArrayNum(fDist)
		if index != -1
			return gvFovDist[index].GetValue()
		endif
	endif
	return 0.0
endFunction

int Function GetArrayNum(float fDistance)
	if fDistance < 50
		return 0
	elseif fDistance > 50 && fDistance <= 75
		return 1
	elseif fDistance > 75 && fDistance <= 100
		return 2
	elseif fDistance > 100 && fDistance <= 125
		return 3
	elseif fDistance > 125 && fDistance <= 150
		return 4
	elseif fDistance > 150
		return 5
	endif
endFunction

float function GetFov()
	float result = GetCurrentFOV()	; fDefaultWorldFOV
; 	debug.Notification("GetCurrentFOV():"+result)
 	if result == 0.0
		result = GetDefaultFOV()	; fDefault1stPersonFOV
; 		debug.Notification("GetDefaultFOV():"+result)
		if result == 0.0
; 			debug.Notification("else:"+result)
			result = 65.0	;vanila setting
		endif
	endif
	return result
endfunction

Function SetFov(float fovpts)
	int iFov = gvFoV.GetValue() as int
	if iFov == 1
		float fZoomFOVSpeed = fZoomSpeed
		if fZoomFOVSpeed > 1.5
			fZoomFOVSpeed = 1.5
		endif
		SetFOVSmooth(fovpts,((2.0 - fZoomFOVSpeed) * 1000))
	elseif iFov == 2
		SetFOVSmooth(fovpts,-1)
	endif
endFunction

Function SetMouseSensitivity(float fovpts)
	if !bMouseSensitivity
		return
	endif
	
	float FOVmulti
	if fovpts != 0.0
		FOVmulti = fovpts / fFOVIni
	else
		FOVmulti = 1
	endif
	MouseXScale = MouseXScaleIni * FOVmulti
	MouseYScale = MouseYScaleIni * FOVmulti
	SetINIFloat("fMouseHeadingXScale:Controls", MouseXScale)
	SetINIFloat("fMouseHeadingYScale:Controls", MouseYScale)
endFunction

bool Function IsPVZoom(Actor Target, float fSet)
	float fShoulderX	;crosshairがプレイヤーから見てどちらにあるか。 左側<0.0 真ん中<右側

	if aPlayer.IsWeaponDrawn()
		fShoulderX = GetINIFloat("fOverShoulderCombatPosX:Camera")
	else
		fShoulderX = GetINIFloat("fOverShoulderPosX:Camera")
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

	if !(aPlayer.getHeadingAngle(Target) < iResult[1] && \
								aPlayer.getHeadingAngle(Target) > iResult[0])
		return false
	else
		return true
	endif
endFunction