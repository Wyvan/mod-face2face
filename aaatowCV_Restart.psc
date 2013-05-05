Scriptname aaatowCV_Restart extends ReferenceAlias  

Quest Property MainQuest  Auto  

Event OnPlayerLoadGame()
	if MainQuest.IsRunning()
		MainQuest.Stop()
		Utility.wait(1)
		MainQuest.Start()
	endif
endEvent
