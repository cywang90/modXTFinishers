﻿/***********************************************************************/
/** Copyright © 2014
/** Author : Tomek Kozera
/***********************************************************************/

state IngameMenuBestiary in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var OPEN_GLOSSARY, OPEN_BESTIARY, OPEN_GAME_MENU : name;
	
		default OPEN_GLOSSARY = 'TutorialBestiaryOpenGlossary';
		default OPEN_BESTIARY = 'TutorialBestiaryOpenBestiary';
		default OPEN_GAME_MENU = 'TutorialBestiaryOpenMenu';
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		CloseHint(OPEN_GAME_MENU);
				
		ShowHint(OPEN_GLOSSARY, 0.65f, 0.65f, ETHDT_Infinite);
	}
		
	event OnLeaveState( nextStateName : name )
	{
		CloseHint(OPEN_GLOSSARY);
		CloseHint(OPEN_BESTIARY);
		
		super.OnLeaveState(nextStateName);
	}
		
	event OnMenuOpening(menuName : name)
	{		
		if(menuName == 'GlossaryBestiaryMenu')
		{
			QuitState();
		}
		else if(menuName == 'GlossaryParent')
		{
			CloseHint(OPEN_GLOSSARY);
			ShowHint(OPEN_BESTIARY, 0.65f, 0.65f, ETHDT_Infinite);
		}
	}
	
	//abort
	event OnMenuClosing(menuName : name)
	{		
		if(menuName == 'GlossaryParent')
		{
			CloseHint(OPEN_GLOSSARY);
			ShowHint(OPEN_BESTIARY, 0.65f, 0.65f, ETHDT_Infinite);
		}
		else if(menuName == 'CommonMenu' && theGame.GameplayFactsQuerySum("closingHubMenu") > 0)
		{
			//if closing hub menu
			QuitState();
		}
	}
}