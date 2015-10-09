/*
Copyright © CD Projekt RED 2015
*/





state DrinkingPlayerContestant in CPlayer
{
	event OnEnterState( prevStateName : name )
	{
		parent.DisableLookAt();
		theSound.EnterGameState( ESGS_Minigame );
		
		Init();
	}
	
	event OnLeaveState( nextStateName : name )
	{
		theSound.LeaveGameState( ESGS_Minigame );
	}
	
	entry function Init()
	{
		parent.ActivateAndSyncBehavior('drinking_contestant');
	}
}