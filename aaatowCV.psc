Scriptname aaatowCV extends Quest  

bool property bSwitchPV auto	;switch to first person view when conversation.
float property SwitchMode auto	;1:change fov  0:do nothing
float property fTR auto			;1.0:tracking npc
float property fSpeed auto
bool property bDebugMsg auto
bool property bReset auto
bool property bGetCurrent auto

float[] property fResetSetting auto

formlist property UnswitchKeywordList auto
int property HasDragonKeyword auto	;0:do nothing 1:do not switch pv(only activate zoom fov) 2:exclude All

int[] property FoVSet auto
int[] property FoVSetDefault auto

Quest Property MainQuest auto

Function ForceFirstPersonSmooth() global native
Function ForceThirdPersonSmooth() global native
Function ForceThirdPersonEX() global native
Function SetFOVSmooth(float fov, float fpfov, float delay) global native
Function SetCameraSpeed(float fSpeed) global native
Function LookAtRef(ObjectReference akRef, float fSpeed) global native
Function LookAtActor(ObjectReference akRef, float fSpeed) global native
float Function GetActorDistance(ObjectReference akRef) global native
bool Function IsFirstPerson() global native
bool Function IsDragonType(Actor akActor) global native
Function PapyrusTrace(string str) global native
