Scriptname aaatowCV_MCM extends SKI_ConfigBase  

aaatowCV property CV auto
int SwitchID
int ModeID
int DebugMsgID
int ResetID
int GetCurrentID
int SpeedID
int TrackingID
int[] DistID
int[] SaveSettingID

String[] sSwitchMode
String[] sTR

int function GetVersion()
	return 7
endFunction

Event OnVersionUpdate(int a_version)
	if !(a_version >= 7 && CurrentVersion < 7)
		return
	endif
	DistID = new int[6]
	SaveSettingID = new int[4]
	sTR = new string[2]
	sTR[0] = "$DoNothing"
	sTR[1] = "$Tracking"
	sSwitchMode = new string[2]
	sSwitchMode[0] = "$PovMode"
	sSwitchMode[1] = "$FovMode"
	GetCurrentValue()
endEvent

Event OnConfigInit()
	DistID = new int[6]
	SaveSettingID = new int[4]
	sTR = new string[2]
	sTR[0] = "$DoNothing"
	sTR[1] = "$Tracking"
	sSwitchMode = new string[2]
	sSwitchMode[0] = "$PovMode"
	sSwitchMode[1] = "$FovMode"
	GetCurrentValue()
endEvent

Event OnPageReset(String a_Page)
; 	======================== LEFT ========================
	SetCursorFillMode(TOP_TO_BOTTOM)
	AddHeaderOption("$FOVHeader")
	DistID[0] = AddSliderOption("$Distance0", CV.FoVSet[0], "$FOV")
	DistID[1] = AddSliderOption("$Distance1", CV.FoVSet[1], "$FOV")
	DistID[2] = AddSliderOption("$Distance2", CV.FoVSet[2], "$FOV")
	DistID[3] = AddSliderOption("$Distance3", CV.FoVSet[3], "$FOV")
	DistID[4] = AddSliderOption("$Distance4", CV.FoVSet[4], "$FOV")
	DistID[5] = AddSliderOption("$Distance5", CV.FoVSet[5], "$FOV")
	AddHeaderOption("$OptionHeader")
	SpeedID = AddSliderOption("$CameraTime", CV.fSpeed, "$SEC1")
	TrackingID = AddTextOption("$NPCTracking", sTR[CV.fTR as int])
; 	======================== RIGHT ========================
	SetCursorPosition(1)

	AddHeaderOption("$DebugHeader")
	SwitchID = AddToggleOption("$SwitchFP", CV.bSwitchPV)
	ModeID = AddTextOption("$SwitchMode", sSwitchMode[CV.SwitchMode as int])
	DebugMsgID = AddToggleOption("$DebugMessage", CV.bDebugMsg)

	AddHeaderOption("$ResetHeader")
	ResetID = AddToggleOption("$ResetSetting", CV.bReset)
	SaveSettingID[0] = AddSliderOption("fDefaultWorldFOV:Display", CV.fResetSetting[0], "$FOV")
	SaveSettingID[1] = AddSliderOption("fDefault1stPersonFOV:Display", CV.fResetSetting[1], "$FOV")
	SaveSettingID[2] = AddSliderOption("fMouseHeadingXScale:Controls", CV.fResetSetting[2], "{4}")
	SaveSettingID[3] = AddSliderOption("fMouseHeadingYScale:Controls", CV.fResetSetting[3], "{4}")
	GetCurrentID = AddToggleOption("$GetCurrentValue", CV.bGetCurrent)

; 	======================== RIGHT ========================

endEvent

event OnOptionSelect(int option)
	if (option == SwitchID)
		CV.bSwitchPV = !CV.bSwitchPV
		SetToggleOptionValue(option, CV.bSwitchPV)
	elseif (option == DebugMsgID)
		CV.bDebugMsg = !CV.bDebugMsg
		SetToggleOptionValue(option, CV.bDebugMsg)
	elseif (option == ResetID)
		CV.bReset = !CV.bReset
		SetToggleOptionValue(option, CV.bReset)
	elseif (option == GetCurrentID)
		CV.bGetCurrent = !CV.bGetCurrent
		SetToggleOptionValue(option, CV.bGetCurrent)
	elseif (option == ModeID)
		CV.SwitchMode = CycleTEXT(sSwitchMode, CV.SwitchMode)
		SetTextOptionValue(Option, sSwitchMode[CV.SwitchMode as int])
	elseif (option == TrackingID)
		CV.fTR = CycleTEXT(sTR, CV.fTR)
		SetTextOptionValue(Option, sTR[CV.fTR as int])
	endif
endEvent

event OnOptionSliderOpen(int option)
	if (option == SpeedID)
		SetSliderDialogStartValue(CV.fSpeed)
		SetSliderDialogDefaultValue(0.7)
		SetSliderDialogRange(0.0, 2.0)
		SetSliderDialogInterval(0.1)
	elseif ExistedInArray(DistID, option)
		int index = DistID.find(option)
		SetSliderDialogStartValue(CV.FoVSet[index])
		SetSliderDialogDefaultValue(CV.FoVSetDefault[index])
		SetSliderDialogRange(10, 80)
		SetSliderDialogInterval(1)
	elseif ExistedInArray(SaveSettingID, option)
		int index = SaveSettingID.find(option)
		if (index == 0 || index == 1)
			SetSliderDialogStartValue(CV.fResetSetting[index])
			SetSliderDialogRange(10, 100)
			SetSliderDialogInterval(1)
		else
			SetSliderDialogStartValue(CV.fResetSetting[index])
			SetSliderDialogRange(0, 2)
			SetSliderDialogInterval(0.005)
		endif
	endif
endEvent

event OnOptionSliderAccept(int option, float value)
	if (option == SpeedID)
		CV.fSpeed = value
		SetSliderOptionValue(SpeedID, CV.fSpeed, "$SEC1")
	elseif ExistedInArray(DistID,option)
		int index = DistID.find(option)
		CV.FoVSet[index] = value as int
		SetSliderOptionValue(DistID[index], CV.FoVSet[index], "$FOV")
	elseif ExistedInArray(SaveSettingID, option)
		int index = SaveSettingID.find(option)
		if (index == 0 || index == 1)
			CV.fResetSetting[index] = value as int
			SetSliderOptionValue(SaveSettingID[index], CV.fResetSetting[index], "$FOV")
		else
			CV.fResetSetting[index] = value as float
			SetSliderOptionValue(SaveSettingID[index], CV.fResetSetting[index], "{4}")
		endif
	endif
endEvent

Event OnOptionHighlight(int option)
	if (option == SwitchID)
		SetInfoText("$SwitchIDInfo")
	elseif (option == SpeedID)
		SetInfoText("$SpeedIDInfo")
	elseif (option == ModeID)
		SetInfoText("$ModeIDInfo")
	elseif (option == TrackingID)
		SetInfoText("$TrackingIDInfo")
	elseif (option == DebugMsgID)
		SetInfoText("$DebugMsgIDInfo")
	elseif ExistedInArray(DistID,option)
		SetInfoText("$DistIDInfo")
	endif
endEvent

Event OnConfigClose()
	RegisterForModEvent("CloseF2F", "OnCloseF2F")
	SendModEvent("CloseF2F")
EndEvent

Event OnCloseF2F(string eventName, string strArg, float numArg, Form sender)
	if CV.MainQuest.IsRunning()
		CV.MainQuest.Stop()
	endif

	if (CV.bGetCurrent)
		CV.bGetCurrent = false
		GetCurrentValue()
	endif
	
	CV.MainQuest.Start()
endEvent

Function GetCurrentValue()
	CV.fResetSetting[0] = Utility.GetINIFloat("fDefaultWorldFOV:Display")
	CV.fResetSetting[1] = Utility.GetINIFloat("fDefault1stPersonFOV:Display")
	CV.fResetSetting[2] = Utility.GetINIFloat("fMouseHeadingXScale:Controls")
	CV.fResetSetting[3] = Utility.GetINIFloat("fMouseHeadingYScale:Controls")
endFunction

float Function CycleTEXT(string[] s, float fnum)
	fnum += 1.0
	if fnum >= s.length
		fnum = 0.0
	endif
	return fnum
endFunction

bool Function ExistedInArray(int[] IDs, int opt)
	if IDs.find(opt) > -1
		return true
	endif
	return false
endFunction
