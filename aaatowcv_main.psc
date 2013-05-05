Scriptname aaatowCV_Main extends ReferenceAlias  

Import Game
Import towPlugin

GlobalVariable Property gvAFP  Auto  
;コンソールより set aaatowCVAPV to 1 で有効
;開始時に自動的にFPにする。

GlobalVariable Property gvABK Auto  
;コンソールより set aaatowCVABK to 1 で有効
;終了時PVが変更されていた場合に元に戻す。

GlobalVariable Property gvCA Auto  
;コンソールより set aaatowCVCA to 1 で有効
;カメラ変更時にNPCに注目する

bool bFP
bool bAPV
bool bABK
bool bCA

float fRotZ
float fRotX

int iPovKeyCode
float fAngleF = 120.0
;前方角度。この範囲外はSmoothするとカメラがNPCを外れた所にSmoothするため、カメラの移動のみ処理。ForceFirstPersonして終わらせる。

int _iLeft = 0
int _iRight = 1
			
Event OnInit()
	RegisterForMenu("Dialogue Menu")
EndEvent

Event OnPlayerLoadGame()
	RegisterForMenu("Dialogue Menu")
EndEvent

Event OnMenuOpen(string menuName)
	if (menuName != "Dialogue Menu")
		Return
	endif

	Actor aPlayer = Game.GetPlayer()

	bAPV = gvAFP.GetValue() as bool
	bABK = gvABK.GetValue() as bool
	bCA = gvCA.GetValue() as bool

	iPovKeyCode = Input.GetMappedKey("Toggle POV")
	RegisterForKey(iPovKeyCode)

	bFP = aPlayer.GetAnimationVariableInt("i1stPerson") as bool
	fRotZ = aPlayer.GetAngleZ()
	fRotX = aPlayer.GetAngleX()

	 if bAPV
		Actor aTarget = GetPlayerDialogueTarget()
		if aTarget != None
			int[] iAngle = new int[2]
			iAngle = AjeCam(fAngleF)
			if bCA
				if !(aPlayer.getHeadingAngle(aTarget) < iAngle[_iRight] && aPlayer.getHeadingAngle(aTarget) > iAngle[_iLeft]) && bCA
					PlayerLookAtNode(aTarget, "NPC Neck [Neck]",500)
					utility.wait(0.5)
					ForceFirstPerson()
				else
					PlayerLookAtNode(aTarget, "NPC Neck [Neck]")
					utility.wait(0.5)
					ForceFirstPersonSmooth()
				endif
			endif
		endif
	endif
EndEvent

Event OnMenuClose(string menuName)
	if menuName != "Dialogue Menu"
		Return
	endif

	Actor aPlayer = Game.GetPlayer()
	bool bFPNow = aPlayer.GetAnimationVariableInt("i1stPerson") as bool
	
	UnregisterForKey(iPovKeyCode)

	if bABK && (bFPNow != bFP)
		if bFPNow
			ForceThirdPersonSmooth()
		else
			ForceFirstPersonSmooth()
		endif
	endif
EndEvent

Event OnKeyDown(Int iKeyCode)
	Actor aPlayer = Game.GetPlayer()


	if iKeyCode == iPovKeyCode
		if aPlayer.GetAnimationVariableInt("i1stPerson") as bool
			ForceThirdPersonSmooth()
			SetCameraAngle(fRotZ, fRotX)
		else
			ForceFirstPersonSmooth()
			utility.wait(0.5)
			if bCA
				Actor aTarget = GetPlayerDialogueTarget()
				PlayerLookAtNode(aTarget, "NPC Neck [Neck]")
			endif
		endif
	endif
EndEvent

int[] Function AjeCam(float fSet)
	float fShoulderX	;crosshairがプレイヤーから見てどちらにあるか。 左側<0.0 真ん中<右側
	Actor aPlayer = Game.GetPlayer()

	if aPlayer.IsWeaponDrawn()
		fShoulderX = Utility.GetINIFloat("fOverShoulderCombatPosX:Camera")
	else
		fShoulderX = Utility.GetINIFloat("fOverShoulderPosX:Camera")
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

