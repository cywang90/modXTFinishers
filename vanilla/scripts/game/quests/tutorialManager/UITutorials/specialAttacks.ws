﻿/***********************************************************************/
/** Copyright © 2014
/** Author : Tomek Kozera
/***********************************************************************/

state SpecialAttacks in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var SPECIALS, ALTERNATES : name;

		default ALTERNATES 			= 'TutorialAlternateSigns';
		default SPECIALS 			= 'TutorialSpecialAttacks';
		
	event OnLeaveState( nextStateName : name )
	{		
		CloseHint(SPECIALS);
		CloseHint(ALTERNATES);
		
		//no super - don't unregister listener when quitting
		//instead unregister only if both seen
		
		if(theGame.GetTutorialSystem().HasSeenTutorial(SPECIALS) && theGame.GetTutorialSystem().HasSeenTutorial(ALTERNATES))
		{
			theGame.GetTutorialSystem().uiHandler.UnregisterUIHint(GetStateName());
		}
	}
		
	public final function OnBoughtSkill(skill : ESkill)
	{
		if(skill == S_Sword_s01 || skill == S_Sword_s02)
		{
			ShowHint(SPECIALS, theGame.params.TUT_POS_CHAR_DEV_X, 0.47f, ETHDT_Input);
			theGame.GetTutorialSystem().MarkMessageAsSeen(SPECIALS);
		}
		else if(skill == S_Magic_s01 || skill == S_Magic_s02 || skill == S_Magic_s03 || skill == S_Magic_s04 || skill == S_Magic_s05)
		{
			ShowHint(ALTERNATES, theGame.params.TUT_POS_CHAR_DEV_X, theGame.params.TUT_POS_CHAR_DEV_Y, ETHDT_Input);
			theGame.GetTutorialSystem().MarkMessageAsSeen(ALTERNATES);
		}
	}
}