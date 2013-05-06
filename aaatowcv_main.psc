Scriptname aaatowCV_Main extends ReferenceAlias  

Import Game
Import towPlugin
Import Utility

GlobalVariable Property gvAFP  Auto  
;コンソールより set aaatowCVAPV to 1 で有効
;開始時に自動的にFPにする。

GlobalVariable Property gvABK Auto  
;コンソールより set aaatowCVABK to 1 で有効
;終了時PVが変更されていた場合に元に戻す。

GlobalVariable Property gvCA Auto  
;コンソールより set aaatowCVCA to 1 で有効
;カメラ変更時にNPCに注目する

GlobalVariable Property gvSP Auto  
;set aaatowCVSP to 0.8 でデフォルトに戻す
;fMouseWheelZoomSpeed:Camera

GlobalVariable Property gvFoV Auto
GlobalVariable[] Property gvFovDist Auto


float fZoomSpeedIni
float fZoomSpeed

bool bFP
bool bAPV
bool bABK
bool bCA

float fRotZ
float fRotX

int iPovKeyCode
float fAngleF = 120.0
;前方角度。この範囲外はSmoothするとカメラがNPCを外れた所にSmoothするため、カメラの移動のみ処理。ForceFirstPersonして終わらせる。
;もっと良い処理はないものか…

int _iLeft = 0
int _iRight = 1

float fFov
float fFovDef
float fDist

Event OnInit()
	RegisterForCameraState()
	RegisterForMenu("Dialogue Menu")
EndEvent

Event OnMenuOpen(string menuName)
	if (menuName != "Dialogue Menu")
		Return
	endif

	fFovDef = GetCurrentFOV()
	if fFovDef == 0.0
		fFovDef = GetDefaultFOV()
		if fFovDef == 0.0
			fFovDef = 65.0
		endif
	endif
	fZoomSpeedIni = GetINIFloat("fMouseWheelZoomSpeed:Camera")
	if fZoomSpeedIni == 0.0
		fZoomSpeedIni = 0.8	; default speed
	endif

	Actor aPlayer = Game.GetPlayer()

	bAPV = gvAFP.GetValue() as bool
	bABK = gvABK.GetValue() as bool
	bCA = gvCA.GetValue() as bool
	fZoomSpeed = gvSP.GetValue() as float

	iPovKeyCode = Input.GetMappedKey("Toggle POV")
	RegisterForKey(iPovKeyCode)

	bFP = !GetCameraState()
	fRotZ = aPlayer.GetAngleZ()
	fRotX = aPlayer.GetAngleX()

	 if bAPV
		Actor aTarget = GetPlayerDialogueTarget()
		if aTarget != None
			int[] iAngle = new int[2]
			iAngle = AjeCam(fAngleF)
			SetINIFloat("fMouseWheelZoomSpeed:Camera", fZoomSpeed)
			if bCA
				float fwait = 1000
				if !(aPlayer.getHeadingAngle(aTarget) < iAngle[_iRight] && aPlayer.getHeadingAngle(aTarget) > iAngle[_iLeft])
					fwait = 500
				endif

				if aPlayer.GetSitState() == 3 && gvFoV.GetValue() == 1.0
					fDist = aPlayer.GetDistance(aTarget)
				else
					fDist = PlayerLookAtNode(aTarget, "NPC Neck [Neck]",fwait)
					wait(0.5)
				endif

				if fwait == 500
					ForceFP(3.0)
				else
					ForceFP(fZoomSpeed)
				endif
			endif
		endif
	endif
EndEvent

Event OnMenuClose(string menuName)
	if menuName != "Dialogue Menu"
		Return
	endif

	UnregisterForKey(iPovKeyCode)
	bool bFPNow = !GetCameraState()
	if bABK
		if bFPNow == True
			if bFP == False
				ForceTP(fZoomSpeed)
			endif
		else
			if bFP == True
				ForceFP(fZoomSpeed)
			endif
		endif
		wait(0.5)
		SetINIFloat("fMouseWheelZoomSpeed:Camera", fZoomSpeedIni)
	endif
EndEvent


Event OnKeyDown(Int iKeyCode)
; 	Actor aPlayer = Game.GetPlayer()

	if iKeyCode == iPovKeyCode
		if !GetCameraState()
			ForceTP(fZoomSpeed)
; 			SetCameraAngle(fRotZ, fRotX)
		else
			ForceFP(fZoomSpeed)
			wait(0.5)
			if bCA
				Actor aTarget = GetPlayerDialogueTarget()
				fDist = PlayerLookAtNode(aTarget, "NPC Neck [Neck]")
			endif
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
	if gvFoV.GetValue() == 0.0
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
			PlayerLookAtNode(aTarget, "NPC Neck [Neck]",2000)
		endif
	elseif newState == 9 && oldState == 0
		if fFov != 0.0
			if fFovDef != GetCurrentFOV()
				SetCurrentFOV(fFovdef)
				fFov = 0.0
			endif
		endif
	endif
EndEvent

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
		
int[] Function AjeCam(float fSet)
	float fShoulderX	;crosshairがプレイヤーから見てどちらにあるか。 左側<0.0 真ん中<右側
	Actor aPlayer = Game.GetPlayer()

	if aPlayer.IsWeaponDrawn()
		fShoulderX = GetINIFloat("fOverShoulderCombatPosX:Camera")
	else
		fShoulderX = GetINIFloat("fOverShoulderPosX:Camera")
	endif

	int[] iResult = new int[2]
	if fShoulderX < 0.0	;Left 
		iResult[_iLeft] =  (-1 * ((fSet + fShoulderX) / 2) + fShoulderX) as int
		iResult[_iRight] = (1 * ((fSet + fShoulderX) / 2)) as int
	elseif fShoulderX > 0.0	;Right
		iResult[_iLeft] =  (-1 * ((fSet - fShoulderX) / 2)) as int
		iResult[_iRight] = (1 * ((fSet - fShoulderX) / 2) + fShoulderX) as int
	else	;Center
		iResult[_iLeft] = (-1 * (fSet / 2)) as int
		iResult[_iRight] = (fSet / 2) as int
	endif
	Return iResult
endFunction

