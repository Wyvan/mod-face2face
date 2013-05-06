Scriptname aaatowCV_Main extends ReferenceAlias  

Import Game
Import towPlugin
Import Utility

GlobalVariable Property gvAPV  Auto
GlobalVariable Property gvSP Auto	;fMouseWheelZoomSpeed:Camera
GlobalVariable Property gvFoV Auto
GlobalVariable[] Property gvFovDist Auto

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

int Property iPovKeyCode Hidden
	int Function Get()
		return Input.GetMappedKey("Toggle POV")
	EndFunction
EndProperty

float property fZoomSpeed Hidden
	float Function Get()
		Return gvSP.GetValue() as float
	EndFunction
EndProperty

float property fZoomSpeedIni Hidden
	float Function Get()
		Return GetINIFloat("fMouseWheelZoomSpeed:Camera")
	EndFunction
	Function Set(float value)
		if value == 0.0
			fZoomSpeedIni = 0.8	; default speed
		endif
	EndFunction
EndProperty

float property bFov Hidden
	float Function Get()
		Return gvFoV.GetValue()
	EndFunction
EndProperty

Actor aPlayer
bool bFP

float fRotZ
float fRotX
float fAngleF = 120.0
;前方角度。この範囲外はSmoothするとカメラがNPCを外れた所にSmoothするため、カメラの移動のみ処理。ForceFirstPersonして終わらせる。
;手抜き

float fDist
float fFov
float fFovIni

Event OnInit()
	RegisterForCameraState()
	RegisterForMenu("Dialogue Menu")
	aPlayer = GetPlayer()
EndEvent

Event OnMenuOpen(string menuName)
	if (menuName != "Dialogue Menu")
		return
	endif

	RegisterForKey(iPovKeyCode)

	float fwait
	fFovIni = GetCurrentFOV()
	if fFovIni == 0.0
		fFovIni = GetDefaultFOV()
		if fFovIni == 0.0
			fFovIni = 65.0
		endif
	endif
	fRotZ = aPlayer.GetAngleZ()
	fRotX = aPlayer.GetAngleX()
	bFP = !GetCameraState()

	Actor aTarget = GetPlayerDialogueTarget()
	if aTarget != None
		SetINIFloat("fMouseWheelZoomSpeed:Camera", fZoomSpeed)
		fwait = GetWait(aTarget, fAngleF)
		if bAPV
			fDist = aPlayer.GetDistance(aTarget)
			if fAPV == 0.0 ;do nothing 
				;nop
			elseif fAPV == 1.0	;TPV
				if bFP
					if bFov
						int index = GetArrayNum(fDist)
						if index != -1
							fFov = gvFovDist[index].GetValue()
							SetCurrentFOV(fFov)
						endif
						fDist = PlayerLookAtNode(aTarget, "NPC Neck [Neck]",1000);2000
					endif
				else
					if aPlayer.GetSitState() != 3
						fDist = PlayerLookAtNode(aTarget, "NPC Neck [Neck]",1000)
						wait(0.5)
						ChangePV("FP", fwait)
					endif
				endif
			elseif fAPV == 2.0	;FPV
				if !bFP
					;nop
				else
					if aPlayer.GetSitState() != 3
						fDist = PlayerLookAtNode(aTarget, "NPC Neck [Neck]",1000)
						wait(0.5)
						ChangePV("TP", fwait)
					endif
				endif
			elseif fAPV == 3.0 ;both? 
			endif
		endif
	endif
EndEvent

Event OnMenuClose(string menuName)
	if menuName != "Dialogue Menu"
		Return
	elseif aPlayer.GetSitState() == 3
		return
	endif
	UnregisterForKey(iPovKeyCode)

	if bAPV
		if !Game.GetCameraState()	; is fp?
			if !bFP
				ForceTP(fZoomSpeed)
			endif
		else
			if bFP
				ForceFP(fZoomSpeed)
			endif
		endif
		wait(0.5)
		SetINIFloat("fMouseWheelZoomSpeed:Camera", fZoomSpeedIni)
	endif

	if fFov != 0.0
		if fFovIni != GetCurrentFOV()
			SetCurrentFOV(fFovIni)
			fFov = 0.0
		endif
	endif
	
EndEvent


Event OnKeyDown(Int iKeyCode)
	if iKeyCode == iPovKeyCode
		if !GetCameraState()
			ForceTP(fZoomSpeed)
; 			SetCameraAngle(fRotZ, fRotX)
		else
			ForceFP(fZoomSpeed)
			wait(0.5)
			Actor aTarget = GetPlayerDialogueTarget()
			fDist = PlayerLookAtNode(aTarget, "NPC Neck [Neck]")
		endif
	endif
EndEvent


; Event OnSit(ObjectReference akFurniture)
; 	if akFurniture.HasKeyword(FurnitureForce3rdPerson)
; 		debug.Notification("We just sat on " + akFurniture)
; 		bForce3rdFurniture = true
; 	endif
; endEvent

Event OnPlayerCameraState(int oldState, int newState)
	if !bFov
		return
	elseif fAPV != 1.0	;TPV
		return
	elseif GetPlayer().IsInKillMove()
		return
	endif

	if newState == 0 && oldState == 9	;FP
		Actor aTarget = GetPlayerDialogueTarget()
		if aTarget != None
			int index = GetArrayNum(fDist)
			if index != -1
				fFov = gvFovDist[index].GetValue()
				SetCurrentFOV(fFov)
			endif

			float wait = 1000
			PlayerLookAtNode(aTarget, "NPC Neck [Neck]",wait);2000
		endif
	elseif newState == 9 && oldState == 0
		if fFov != 0.0
			if fFovIni != GetCurrentFOV()
				SetCurrentFOV(fFovIni)
				fFov = 0.0
			endif
		endif
	endif
endEvent

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

Function ChangePV(string mode, float wait)
	if mode == "TP"
		if wait == 500
			ForceTP(3.0)
		else
			ForceTP(fZoomSpeed)
		endif
	else
		if wait == 500
			ForceFP(3.0)
		else
			ForceFP(fZoomSpeed)
		endif
	endif
endFunction

int Function GetArrayNum(float fDistance)
	if fDistance <= 50
		return 0
	elseif fDistance >= 51 && fDistance <= 75
		return 1
	elseif fDistance >= 76 && fDistance <= 100
		return 2
	elseif fDistance >= 101 && fDistance <= 125
		return 3
	elseif fDistance >= 126 && fDistance <= 150
		return 4
	elseif fDistance >= 151
		return 5
	endif
endFunction


float Function GetWait(Actor Target, float fSet)
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
		return 500
	else
		return 1000
	endif
endFunction