﻿/***********************************************************************/
/** Copyright © 2014
/** Author : Tomek Kozera
/***********************************************************************/

state Runes in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var SELECT, RUNE, SWORD : name;
	
		default SELECT 		= 'TutorialRunesSelectRune';
		default RUNE 		= 'TutorialRunesUseRune';
		default SWORD 		= 'TutorialRunesSelectSword';
		
	event OnEnterState( prevStateName : name )
	{
		var highlights : array<STutorialHighlight>;
		
		super.OnEnterState(prevStateName);
		
		highlights.Resize(1);
		highlights[0].x = 0.06;
		highlights[0].y = 0.145;
		highlights[0].width = 0.06;
		highlights[0].height = 0.09;
			
		ShowHint(SELECT, theGame.params.TUT_POS_INVENTORY_X, theGame.params.TUT_POS_INVENTORY_Y, ETHDT_Infinite, highlights);
	}
			
	event OnLeaveState( nextStateName : name )
	{
		CloseHint(SELECT);
		CloseHint(RUNE);
		CloseHint(SWORD);
		
		theGame.GetTutorialSystem().MarkMessageAsSeen(SELECT);
		theGame.GetTutorialSystem().MarkMessageAsSeen(SWORD);
		
		super.OnLeaveState(nextStateName);
	}
	
	event OnSelectedItem(itemId : SItemUniqueId)
	{
		if(IsCurrentHint(SELECT) && thePlayer.inv.ItemHasTag(itemId, 'WeaponUpgrade'))
		{
			//if selected rune
			CloseHint(SELECT);
			ShowHint(RUNE, theGame.params.TUT_POS_INVENTORY_X, theGame.params.TUT_POS_INVENTORY_Y, ETHDT_Infinite);
		}
		else if(IsCurrentHint(RUNE) && !thePlayer.inv.ItemHasTag(itemId, 'WeaponUpgrade'))
		{
			//if had rune selected but then changed selection to not a rune or when aborted selection menu and moved around
			CloseHint(RUNE);
			ShowHint(SELECT, theGame.params.TUT_POS_INVENTORY_X, theGame.params.TUT_POS_INVENTORY_Y, ETHDT_Infinite);
		}
	}
	
	event OnSelectingSword()
	{
		CloseHint(RUNE);
		ShowHint(SWORD, theGame.params.TUT_POS_INVENTORY_X, theGame.params.TUT_POS_INVENTORY_Y, ETHDT_Infinite);
	}
	
	event OnSelectingSwordAborted()
	{
		CloseHint(SWORD);
		ShowHint(RUNE, theGame.params.TUT_POS_INVENTORY_X, theGame.params.TUT_POS_INVENTORY_Y, ETHDT_Infinite);
	}
	
	event OnUpgradedItem()
	{
		QuitState();
	}
}

exec function tut_runes()
{
	TutorialMessagesEnable(true);
	theGame.GetTutorialSystem().TutorialStart(false);
	TutorialScript('runes', '');
	thePlayer.inv.AddAnItem('Veles rune',3);
	thePlayer.inv.AddAnItem('Gryphon School silver sword 3',1);
}