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