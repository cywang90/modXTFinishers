/*
Copyright © CD Projekt RED 2015
*/





state DrinkingBartender in CNewNPC
{
	event OnEnterState( prevStateName : name )
	{
		parent.DisableLookAt();
		DrinkingBartenderStateInit();		
	}
	
	entry function DrinkingBartenderStateInit()
	{
		parent.ActivateAndSyncBehavior('npc_drinking_minigame_bartender');
	}
}