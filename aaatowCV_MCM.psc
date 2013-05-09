Scriptname aaatowCV_MCM extends SKI_ConfigBase  

GlobalVariable Property gvAPV  Auto
GlobalVariable Property gvCVSP Auto
GlobalVariable Property gvFoV Auto
GlobalVariable[] Property gvFovDist Auto

int iActionID
int iZoomSpeedID
int iChangeFovID

int iAction
bool bChangeFov

float fZoomSpeed

int[] iFovDistID
float[] fFovDist
float[] fFovDistDef

String[] strPV

int function GetVersion()
	return 2
endFunction

Event OnVersionUpdate(int a_version)

	if (a_version >= 2 && CurrentVersion < 2)
		strPV = new string[3]
		strPV[0] = "Do Nothing"
		strPV[1] = "First Person"
		strPV[2] = "Third Person"
	endif
endEvent

Event OnConfigInit()
	iFovDistID = new int[6]
	fFovDist = new float[6]
	fFovDist[0] = gvFovDist[0].GetValue()
	fFovDist[1] = gvFovDist[1].GetValue()
	fFovDist[2] = gvFovDist[2].GetValue()
	fFovDist[3] = gvFovDist[3].GetValue()
	fFovDist[4] = gvFovDist[4].GetValue()
	fFovDist[5] = gvFovDist[5].GetValue()

	fFovDistDef = new float[6]
	fFovDistDef[0] = 45
	fFovDistDef[1] = 40
	fFovDistDef[2] = 35
	fFovDistDef[3] = 30
	fFovDistDef[4] = 25
	fFovDistDef[5] = 20

	strPV = new string[3]
	strPV[0] = "Do Nothing"
	strPV[1] = "First Person"
	strPV[2] = "Third Person"
endEvent

Event OnPageReset(String a_Page)
; 	If a_Page == ""
; 	endif

	fZoomSpeed = Utility.GetINIFloat("fMouseWheelZoomSpeed:Camera")
	if fZoomSpeed > 3.0
		fZoomSpeed = 3.0
	endif
	
; 	======================== LEFT ========================

	SetCursorFillMode(TOP_TO_BOTTOM)
	AddHeaderOption("Face to face conversation")
	iActionID = AddTextOption("Action", strPV[iAction])
	iChangeFovID = AddToggleOption("Change FoV by distance to speaker", bChangeFov)
	iZoomSpeedID = AddSliderOption("Zoom Speed", fZoomSpeed, "{1}")

; 	======================== RIGHT ========================
	SetCursorPosition(1)
	if bChangeFov
		AddHeaderOption("Change FoV setting by distance.", OPTION_FLAG_NONE)
		iFovDistID[0] = AddSliderOption("50 Unit or less", fFovDist[0], "FoV {0}", OPTION_FLAG_NONE)
		iFovDistID[1] = AddSliderOption("Between 50 and 75", fFovDist[1], "FoV {0}", OPTION_FLAG_NONE)
		iFovDistID[2] = AddSliderOption("Between 75 and 100", fFovDist[2], "FoV {0}", OPTION_FLAG_NONE)
		iFovDistID[3] = AddSliderOption("Between 100 and 125", fFovDist[3], "FoV {0}", OPTION_FLAG_NONE)
		iFovDistID[4] = AddSliderOption("Between 125 and 150", fFovDist[4], "FoV {0}", OPTION_FLAG_NONE)
		iFovDistID[5] = AddSliderOption("Over 150 Unit", fFovDist[5], "FoV {0}", OPTION_FLAG_NONE)
	else
		AddHeaderOption("Change FoV setting by distance.", OPTION_FLAG_DISABLED)
		iFovDistID[0] = AddSliderOption("50 Unit or less", fFovDist[0], "FoV {0}", OPTION_FLAG_DISABLED)
		iFovDistID[1] = AddSliderOption("Between 50 and 75", fFovDist[1], "FoV {0}", OPTION_FLAG_DISABLED)
		iFovDistID[2] = AddSliderOption("Between 75 and 100", fFovDist[2], "FoV {0}", OPTION_FLAG_DISABLED)
		iFovDistID[3] = AddSliderOption("Between 100 and 125", fFovDist[3], "FoV {0}", OPTION_FLAG_DISABLED)
		iFovDistID[4] = AddSliderOption("Between 125 and 150", fFovDist[4], "FoV {0}", OPTION_FLAG_DISABLED)
		iFovDistID[5] = AddSliderOption("Over 150 Unit", fFovDist[5], "FoV {0}", OPTION_FLAG_DISABLED)
	endif
endEvent

event OnOptionSelect(int option)
	if Option == iActionID
		if iAction < strPV.length - 1
			iAction += 1
		else
			iAction = 0
		endif
		SetTextOptionValue(option, strPV[iAction])
		SetToggleOptionValue(option, bChangeFov)
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
		SetSliderOptionValue(iFovDistID[iCount], fFovDist[iCount], "FoV {0}")
	endif
endEvent

event OnOptionHighlight(int option)
	If option == iActionID
		SetInfoText("If you set this item, It will try to switch to setting when start a conversation with NPC.")
	elseif option == iChangeFovID
		SetInfoText("This feature needs to select 'First Person' of Action.")
	endif
endEvent

Event OnConfigClose()
	gvAPV.Setvalue(iAction as float)
	gvCVSP.Setvalue(fZoomSpeed)
	gvFov.Setvalue(bChangeFov as float)

	gvFovDist[0].SetValue(fFovDist[0])
	gvFovDist[1].SetValue(fFovDist[1])
	gvFovDist[2].SetValue(fFovDist[2])
	gvFovDist[3].SetValue(fFovDist[3])
	gvFovDist[4].SetValue(fFovDist[4])
	gvFovDist[5].SetValue(fFovDist[5])

EndEvent
