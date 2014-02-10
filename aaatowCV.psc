Scriptname aaatowCV extends Quest  

bool property bSwitchPV auto	;switch to first person view when conversation.
int  property SwitchMode auto	;0:direct  1:smooth
float property fTR auto			;1.0:tracking npc
float property fSpeed auto
bool property bDebugMsg auto

formlist property UnswitchKeywordList auto
int property HasDragonKeyword auto	;0:do nothing 1:do not switch pv(only activate zoom fov) 2:exclude All

int[] property FoVSet auto
int[] property FoVSetDefault auto

Quest Property MainQuest auto