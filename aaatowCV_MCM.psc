Scriptname aaatowCV_MCM extends SKI_ConfigBase  

import Utility

GlobalVariable Property gvAPV  Auto
GlobalVariable Property gvABK  Auto
GlobalVariable Property gvCVCA  Auto
GlobalVariable Property gvCVSP Auto
GlobalVariable Property gvFoV Auto
GlobalVariable[] Property gvFovDist Auto

int iActivateID
int iAutomaticID
int iZoomSpeedID
int iChangeFovID

bool bActivate
bool bAutomatic
float fZoomSpeed
bool bChangeFov

int[] iFovDistID
float[] fFovDist
float[] fFovDistDef

int function GetVersion()
	return 1
endFunction

Event OnVersionUpdate(int a_version)

endEvent

Event OnConfigInit()
	if gvAPV.getvalue() > 0
		bAutomatic = True
	endif

; 	bActivate = True
	fZoomSpeed = GetINIFloat("fMouseWheelZoomSpeed:Camera")
	if fZoomSpeed > 3.0
		fZoomSpeed = 3.0
	endif
	
	iFovDistID = new int[6]

	fFovDist = new float[6]
	int index = 0
	while index < gvFovDist.length
		fFovDist[index] = gvFovDist[index].GetValue()
		index += 1
	endWhile

	fFovDistDef = new float[6]
	fFovDistDef[0] = 45
	fFovDistDef[1] = 40
	fFovDistDef[2] = 35
	fFovDistDef[3] = 30
	fFovDistDef[4] = 25
	fFovDistDef[5] = 20

endEvent

Event OnPageReset(String a_Page)
; 	If a_Page == ""
; 	endif

; 	======================== LEFT ========================

	SetCursorFillMode(TOP_TO_BOTTOM)
	AddHeaderOption("Face to face conversation")
; 	iActivateID = AddToggleOption("Activate", bActivate, OPTION_FLAG_DISABLED)
	iAutomaticID = AddToggleOption("Automatic", bAutomatic)
	iChangeFovID = AddToggleOption("Change FoV by distance to speaker", bChangeFov)
	iZoomSpeedID = AddSliderOption("Zoom Speed", fZoomSpeed, "{1}")

; 	======================== RIGHT ========================
	SetCursorPosition(1)
	if bChangeFov
		AddHeaderOption("Change FoV setting by distance.", OPTION_FLAG_NONE)
		iFovDistID[0] = AddSliderOption("50 Unit or less", fFovDist[0], "FoV {0}", OPTION_FLAG_NONE)
		iFovDistID[1] = AddSliderOption("Between 51 and 75", fFovDist[1], "FoV {0}", OPTION_FLAG_NONE)
		iFovDistID[2] = AddSliderOption("Between 76 and 100", fFovDist[2], "FoV {0}", OPTION_FLAG_NONE)
		iFovDistID[3] = AddSliderOption("Between 101 and 125", fFovDist[3], "FoV {0}", OPTION_FLAG_NONE)
		iFovDistID[4] = AddSliderOption("Between 126 and 150", fFovDist[4], "FoV {0}", OPTION_FLAG_NONE)
		iFovDistID[5] = AddSliderOption("Over 150 Unit", fFovDist[5], "FoV {0}", OPTION_FLAG_NONE)
	else
		AddHeaderOption("Change FoV setting by distance.", OPTION_FLAG_DISABLED)
		iFovDistID[0] = AddSliderOption("50 Unit or less", fFovDist[0], "FoV {0}", OPTION_FLAG_DISABLED)
		iFovDistID[1] = AddSliderOption("Between 51 and 75", fFovDist[1], "FoV {0}", OPTION_FLAG_DISABLED)
		iFovDistID[2] = AddSliderOption("Between 76 and 100", fFovDist[2], "FoV {0}", OPTION_FLAG_DISABLED)
		iFovDistID[3] = AddSliderOption("Between 101 and 125", fFovDist[3], "FoV {0}", OPTION_FLAG_DISABLED)
		iFovDistID[4] = AddSliderOption("Between 126 and 150", fFovDist[4], "FoV {0}", OPTION_FLAG_DISABLED)
		iFovDistID[5] = AddSliderOption("Over 150 Unit", fFovDist[5], "FoV {0}", OPTION_FLAG_DISABLED)
	endif
endEvent

event OnOptionSelect(int option)
	If option == iActivateID
		bActivate = !bActivate
		SetToggleOptionValue(option, bActivate)
	elseif option == iAutomaticID
		bAutomatic = !bAutomatic
		SetToggleOptionValue(option, bAutomatic)
	elseif option == iChangeFovID
		bChangeFov = !bChangeFov
		SetToggleOptionValue(option, bChangeFov)
		ForcePageReset()
	endif
endEvent

event OnOptionSliderOpen(int option)
	if (option == iZoomSpeedID)
		SetSliderDialogStartValue(fZoomSpeed)
		SetSliderDialogDefaultValue(0.8)
		SetSliderDialogRange(0.6, 3.0)
		SetSliderDialogInterval(0.1)
	endif

	int iCount = iFovDistID.find(option)
	if iCount != -1
		SetSliderDialogStartValue(fFovDist[iCount])
		SetSliderDialogDefaultValue(fFovDistDef[iCount])
		SetSliderDialogRange(10, 80)
		SetSliderDialogInterval(1)
	endif
endEvent

event OnOptionSliderAccept(int option, float value)
	if (option == iZoomSpeedID)
		fZoomSpeed = value
		SetSliderOptionValue(iZoomSpeedID, fZoomSpeed, "{1}")
	endIf

	int iCount = iFovDistID.find(option)
	if iCount != -1
		fFovDist[iCount] = value
; 		float fTemp = value
		SetSliderOptionValue(iFovDistID[iCount], fFovDist[iCount], "FoV {0}")
; 		fFovDist[iCount] = fTemp
	endif
endEvent

event OnOptionHighlight(int option)
	if option == iActivateID
; 		SetInfoText("activate")
	elseIf option == iAutomaticID
; 		SetInfoText("Autoatic")
	elseif option == iZoomSpeedID
; 		SetInfoText("ZoomSpeed")
	endif
endEvent

Event OnConfigClose()
	if bAutomatic
		gvAPV.setvalue(1.0)
		gvABK.setvalue(1.0)
		gvCVCA.setvalue(1.0)
	else
		gvAPV.setvalue(0.0)
		gvABK.setvalue(0.0)
		gvCVCA.setvalue(0.0)
	endif
	gvCVSP.Setvalue(fZoomSpeed)
	gvFov.Setvalue(bChangeFov as float)

	int iCount = 0
	while iCount < gvFovDist.length
		gvFovDist[iCount].SetValue(fFovDist[iCount])
		iCount += 1
	endWhile
EndEvent

