Scriptname aaatowCV_MCM extends SKI_ConfigBase  

aaatowCV property CV auto
int SwitchID
int ModeID
int DebugMsgID
int SpeedID
int TrackingID
int[] DistID

int NOT_FOUND = -1

String[] sSwitchMode
String[] sTR

int function GetVersion()
	return 5
endFunction

Event OnVersionUpdate(int a_version)
	if (a_version >= 5 && CurrentVersion < 5)
		MyInit()
	endif
endEvent

Event OnConfigInit()
	DistID = new int[6]
	sTR = new string[2]
	sTR[0] = "$DoNothing"
	sTR[1] = "$Tracking"
endEvent

function MyInit()

endFunction

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
	DebugMsgID = AddToggleOption("$DebugMessage", CV.bDebugMsg)
; 	ModeID = AddTextOption("$SwitchMode", sSwitchMode[CV.SwitchMode])

; 	======================== RIGHT ========================

endEvent

event OnOptionSelect(int option)
	if (option == SwitchID)
		CV.bSwitchPV = !CV.bSwitchPV
		SetToggleOptionValue(option, CV.bSwitchPV)
	elseif (option == DebugMsgID)
		CV.bDebugMsg = !CV.bDebugMsg
		SetToggleOptionValue(option, CV.bDebugMsg)
; 	elseif (option == ModeID)
; 		CV.SwitchMode = CycleTEXT(sSwitchMode, CV.SwitchMode)
; 		SetTextOptionValue(Option, sSwitchMode[CV.SwitchMode])
	elseif (option == TrackingID)
		CV.fTR = CycleTEXT(sTR, CV.fTR)
		SetTextOptionValue(Option, sTR[(CV.fTR as int)])
	endif
endEvent

event OnOptionSliderOpen(int option)
	if (option == SpeedID)
		SetSliderDialogStartValue(CV.fSpeed)
		SetSliderDialogDefaultValue(0.7)
		SetSliderDialogRange(0.0, 2.0)
		SetSliderDialogInterval(0.1)
	elseif (DistID.find(option) > NOT_FOUND)
		int index = DistID.find(option)
		SetSliderDialogStartValue(CV.FoVSet[index])
		SetSliderDialogDefaultValue(CV.FoVSetDefault[index])
		SetSliderDialogRange(10, 80)
		SetSliderDialogInterval(1)
	endif
endEvent

event OnOptionSliderAccept(int option, float value)
	if (option == SpeedID)
		CV.fSpeed = value
		SetSliderOptionValue(SpeedID, CV.fSpeed, "$SEC1")
	elseif DistID.find(option) > NOT_FOUND
		int index = DistID.find(option)
		CV.FoVSet[index] = value as int
		SetSliderOptionValue(DistID[index], CV.FoVSet[index], "$FOV")
	endIf
endEvent

Event OnOptionHighlight(int option)
	if (option == SwitchID)
		SetInfoText("$SwitchIDInfo")
	elseif (option == SpeedID)
		SetInfoText("$SpeedIDInfo")
; 	elseif (option == ModeID)
; 		SetInfoText("$ModeIDInfo")
	elseif (option == TrackingID)
		SetInfoText("$TrackingIDInfo")
	elseif (option == DebugMsgID)
		SetInfoText("$DebugMsgIDInfo")
	elseif DistID.find(option) > NOT_FOUND
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
	CV.MainQuest.Start()
endEvent

float Function CycleTEXT(string[] s, float fnum)
	fnum += 1.0
	if fnum >= s.length
		fnum = 0.0
	endif
	return fnum
endFunction