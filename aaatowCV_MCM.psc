Scriptname aaatowCV_MCM extends SKI_ConfigBase  

GlobalVariable Property gvAPV  Auto
GlobalVariable Property gvTR Auto
GlobalVariable Property gvCVSP Auto
GlobalVariable Property gvFOV Auto
GlobalVariable[] Property gvFOVDist Auto

int iActionID
int iTrackingID
int iZoomSpeedID
int iChangeFOVID

int iAction
int iChangeFOV
int iTracking

float fZoomSpeed

int[] iFOVDistID
float[] fFOVDist
float[] fFOVDistDef

String[] strPV
String[] strTR
String[] strFOV

int function GetVersion()
	return 4
endFunction

Event OnVersionUpdate(int a_version)

	if (a_version >= 2 && CurrentVersion < 2)
		strPV = new string[3]
		strPV[0] = "Do Nothing"
		strPV[1] = "First Person"
		strPV[2] = "Third Person"
	endif

	if (a_version >= 3 && CurrentVersion < 3)
		strTR = new string[2]
		strTR[0] = "Do Nothing"
		strTR[1] = "Tracking"
; 		strTR[2] = "Approach(wip)"
	endif

	if (a_version >= 4 && CurrentVersion < 4)
		strFOV = new string[3]
		strFOV[0] = "Do Nothing"
		strFOV[1] = "Smooth"
		strFOV[2] = "Direct"
	endif
endEvent

Event OnConfigInit()
	iFOVDistID = new int[6]
	fFOVDist = new float[6]
	fFOVDist[0] = gvFOVDist[0].GetValue()
	fFOVDist[1] = gvFOVDist[1].GetValue()
	fFOVDist[2] = gvFOVDist[2].GetValue()
	fFOVDist[3] = gvFOVDist[3].GetValue()
	fFOVDist[4] = gvFOVDist[4].GetValue()
	fFOVDist[5] = gvFOVDist[5].GetValue()

	fZoomSpeed = gvCVSP.GetValue()

	fFOVDistDef = new float[6]
	fFOVDistDef[0] = 45
	fFOVDistDef[1] = 40
	fFOVDistDef[2] = 35
	fFOVDistDef[3] = 30
	fFOVDistDef[4] = 25
	fFOVDistDef[5] = 20

	strPV = new string[3]
	strPV[0] = "Do Nothing"
	strPV[1] = "First Person"
	strPV[2] = "Third Person"

	strTR = new string[2]
	strTR[0] = "Do Nothing"
	strTR[1] = "Tracking"
; 	strTR[2] = "Approach(wip)"

	strFOV = new string[3]
	strFOV[0] = "Do Nothing"
	strFOV[1] = "Smooth"
	strFOV[2] = "Direct"
endEvent

Event OnPageReset(String a_Page)

; 	======================== LEFT ========================

	SetCursorFillMode(TOP_TO_BOTTOM)
	AddHeaderOption("Face to face conversation")
	iActionID = AddTextOption("Action", strPV[iAction])
	iZoomSpeedID = AddSliderOption("Zoom Speed", fZoomSpeed, "{1}")
	iTrackingID = AddTextOption("Tracking", strTR[iTracking])
	iChangeFOVID = AddTextOption("Change FOV by distance", strFOV[iChangeFOV])

; 	======================== RIGHT ========================
	SetCursorPosition(1)
	if iChangeFOV as bool
		AddHeaderOption("Change FOV setting by distance.", OPTION_FLAG_NONE)
		iFOVDistID[0] = AddSliderOption("50 Unit or less", fFOVDist[0], "FOV {0}", OPTION_FLAG_NONE)
		iFOVDistID[1] = AddSliderOption("Between 50 and 75", fFOVDist[1], "FOV {0}", OPTION_FLAG_NONE)
		iFOVDistID[2] = AddSliderOption("Between 75 and 100", fFOVDist[2], "FOV {0}", OPTION_FLAG_NONE)
		iFOVDistID[3] = AddSliderOption("Between 100 and 125", fFOVDist[3], "FOV {0}", OPTION_FLAG_NONE)
		iFOVDistID[4] = AddSliderOption("Between 125 and 150", fFOVDist[4], "FOV {0}", OPTION_FLAG_NONE)
		iFOVDistID[5] = AddSliderOption("Over 150 Unit", fFOVDist[5], "FOV {0}", OPTION_FLAG_NONE)
	else
		AddHeaderOption("Change FOV setting by distance.", OPTION_FLAG_DISABLED)
		iFOVDistID[0] = AddSliderOption("50 Unit or less", fFOVDist[0], "FOV {0}", OPTION_FLAG_DISABLED)
		iFOVDistID[1] = AddSliderOption("Between 50 and 75", fFOVDist[1], "FOV {0}", OPTION_FLAG_DISABLED)
		iFOVDistID[2] = AddSliderOption("Between 75 and 100", fFOVDist[2], "FOV {0}", OPTION_FLAG_DISABLED)
		iFOVDistID[3] = AddSliderOption("Between 100 and 125", fFOVDist[3], "FOV {0}", OPTION_FLAG_DISABLED)
		iFOVDistID[4] = AddSliderOption("Between 125 and 150", fFOVDist[4], "FOV {0}", OPTION_FLAG_DISABLED)
		iFOVDistID[5] = AddSliderOption("Over 150 Unit", fFOVDist[5], "FOV {0}", OPTION_FLAG_DISABLED)
	endif
endEvent

event OnOptionSelect(int option)
	if Option == iActionID
		iAction = SetNumArray(strPV, iAction)
		SetTextOptionValue(option, strPV[iAction])
	elseif option == iChangeFOVID
		iChangeFOV = SetNumArray(strFOV, iChangeFOV)
		SetTextOptionValue(option, strFOV[iChangeFOV])
		if iChangeFOV == 0 || iChangeFOV == 1
			ForcePageReset()
		endif
	elseif option == iTrackingID
		iTracking = SetNumArray(strTR, iTracking)
		SetTextOptionValue(option, strTR[iTracking])
	endif
endEvent

event OnOptionSliderOpen(int option)
	if option == iZoomSpeedID
		SetSliderDialogStartValue(fZoomSpeed)
		SetSliderDialogDefaultValue(0.8)
		SetSliderDialogRange(0.6, 3.0)
		SetSliderDialogInterval(0.1)
	endif

	int iCount = iFOVDistID.find(option)
	if iCount != -1
		SetSliderDialogStartValue(fFOVDist[iCount])
		SetSliderDialogDefaultValue(fFOVDistDef[iCount])
		SetSliderDialogRange(10, 80)
		SetSliderDialogInterval(1)
	endif
endEvent

event OnOptionSliderAccept(int option, float value)
	if (option == iZoomSpeedID)
		fZoomSpeed = value
		SetSliderOptionValue(iZoomSpeedID, fZoomSpeed, "{1}")
	endIf

	int iCount = iFOVDistID.find(option)
	if iCount != -1
		fFOVDist[iCount] = value
		SetSliderOptionValue(iFOVDistID[iCount], fFOVDist[iCount], "FOV {0}")
	endif
endEvent

event OnOptionHighlight(int option)
	If option == iActionID
		SetInfoText("If you set this item, It will try to switch to setting when start a conversation with NPC.")
	elseif option == iChangeFOVID
		SetInfoText("This feature needs to select 'First Person' of Action.")
	elseif option == iZoomSpeedID
		SetInfoText("3.0 = Instant.")
	endif
endEvent

Event OnConfigClose()
	gvAPV.Setvalue(iAction as float)
	if fZoomSpeed == 0.0
		fZoomSpeed = 0.8
	endif
	gvCVSP.Setvalue(fZoomSpeed)
	gvFOV.Setvalue(iChangeFOV as float)
	gvTR.Setvalue(iTracking as float)

	gvFOVDist[0].SetValue(fFOVDist[0])
	gvFOVDist[1].SetValue(fFOVDist[1])
	gvFOVDist[2].SetValue(fFOVDist[2])
	gvFOVDist[3].SetValue(fFOVDist[3])
	gvFOVDist[4].SetValue(fFOVDist[4])
	gvFOVDist[5].SetValue(fFOVDist[5])
EndEvent


int Function SetNumArray(String[] strs,int iCur)
	if iCur < strs.length - 1
		iCur += 1
	else
		iCur = 0
	endif
	Return iCur
endFunction