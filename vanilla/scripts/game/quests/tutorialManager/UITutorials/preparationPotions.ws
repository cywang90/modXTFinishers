﻿/***********************************************************************/
/** Copyright © 2014-2015
/** Author : Tomek Kozera
/***********************************************************************/

state Potions in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var CAN_EQUIP, SELECT_TAB, EQUIP_POTION, EQUIP_POTION_THUNDERBOLT, ON_EQUIPPED : name;
	private var isClosing, isForcedThunderbolt, skippingTabSelection : bool;
	
		default CAN_EQUIP 		= 'TutorialPotionCanEquip1';
		default SELECT_TAB 		= 'TutorialPotionCanEquip2';
		default EQUIP_POTION 	= 'TutorialPotionCanEquip3';
		default EQUIP_POTION_THUNDERBOLT = 'TutorialPotionCanEquip3Thunderbolt';
		default ON_EQUIPPED 	= 'TutorialPotionEquipped';
		
	event OnEnterState( prevStateName : name )
	{
		var witcher : W3PlayerWitcher;
		var currentTab : int;
		var itemOne, itemTwo, itemThree, itemFour : SItemUniqueId;
		
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		skippingTabSelection = false;
		isForcedThunderbolt = (FactsQuerySum("tut_forced_preparation") > 0);
		
		if(!isForcedThunderbolt) 
		{		
			witcher = GetWitcherPlayer();
			witcher.GetItemEquippedOnSlot(EES_Potion1, itemOne);
			witcher.GetItemEquippedOnSlot(EES_Potion2, itemTwo);
			witcher.GetItemEquippedOnSlot(EES_Potion3, itemThree);
			witcher.GetItemEquippedOnSlot(EES_Potion4, itemFour);
			
			if(witcher.inv.IsItemPotion(itemOne) || witcher.inv.IsItemPotion(itemTwo) || witcher.inv.IsItemPotion(itemThree) || witcher.inv.IsItemPotion(itemFour))
			{
				skippingTabSelection = true;
				
				//if potion already equipped only show info about using potions
				ShowHint(ON_EQUIPPED, theGame.params.TUT_POS_INVENTORY_X, theGame.params.TUT_POS_INVENTORY_Y-0.1);
				
				//but also fire additional tutorial about potion equipping for later time
				TutorialScript('secondPotionEquip', '');
			}
			else
			{
				currentTab = ( (CR4InventoryMenu) ((CR4MenuBase)theGame.GetGuiManager().GetRootMenu()).GetLastChild() ).GetCurrentlySelectedTab();
				if(currentTab == InventoryMenuTab_Potions)
				{
					skippingTabSelection = true;
					OnPotionTabSelected();
				}
				else
				{
					ShowHint(CAN_EQUIP, theGame.params.TUT_POS_INVENTORY_X, theGame.params.TUT_POS_INVENTORY_Y);
				}
			}
		}
		else	
		{
			theGame.GetTutorialSystem().uiHandler.LockLeaveMenu(true);
			
			//block alchemy - we don't want to get back here now
			thePlayer.BlockAction(EIAB_OpenAlchemy, 'tut_forced_preparation');
			
			theGame.GetTutorialSystem().UnmarkMessageAsSeen(EQUIP_POTION);
			ShowHint(CAN_EQUIP, theGame.params.TUT_POS_INVENTORY_X, theGame.params.TUT_POS_INVENTORY_Y);
		}
	}
			
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseHint(CAN_EQUIP);
		CloseHint(SELECT_TAB);
		CloseHint(EQUIP_POTION);
		CloseHint(EQUIP_POTION_THUNDERBOLT);
		CloseHint(ON_EQUIPPED);
		
		if(!skippingTabSelection)
			theGame.GetTutorialSystem().MarkMessageAsSeen(SELECT_TAB);
			
		theGame.GetTutorialSystem().MarkMessageAsSeen(EQUIP_POTION);
		
		if(isForcedThunderbolt)
			theGame.GetTutorialSystem().MarkMessageAsSeen(EQUIP_POTION_THUNDERBOLT);
		
		super.OnLeaveState(nextStateName);
	}
		
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		var highlights : array<STutorialHighlight>;		
		
		if(closedByParentMenu || isClosing)
			return true;
			
		if(hintName == CAN_EQUIP)
		{
			highlights.Resize(1);
			highlights[0].x = 0.09;
			highlights[0].y = 0.145;
			highlights[0].width = 0.06;
			highlights[0].height = 0.09;
			
			ShowHint(SELECT_TAB, theGame.params.TUT_POS_INVENTORY_X, theGame.params.TUT_POS_INVENTORY_Y, ETHDT_Infinite, highlights);
		}
		else if(hintName == ON_EQUIPPED)
		{
			//forced Thunderbolt tutorial
			if(isForcedThunderbolt)
			{
				theGame.GetTutorialSystem().ForcedAlchemyCleanup();
			}
			
			QuitState();
		}
	}
	
	event OnPotionTabSelected()
	{
		CloseHint(SELECT_TAB);
		
		if(isForcedThunderbolt)
			ShowHint(EQUIP_POTION_THUNDERBOLT, theGame.params.TUT_POS_INVENTORY_X, theGame.params.TUT_POS_INVENTORY_Y, ETHDT_Infinite);
		else
			ShowHint(EQUIP_POTION, theGame.params.TUT_POS_INVENTORY_X, theGame.params.TUT_POS_INVENTORY_Y, ETHDT_Infinite);
	}
	
	event OnPotionEquipped(potionItemName : name)
	{
		//in forced tutorial we wait only for proper potion
		if(isForcedThunderbolt && potionItemName != 'Thunderbolt 1')
			return false;
	
		CloseHint(EQUIP_POTION);
		CloseHint(EQUIP_POTION_THUNDERBOLT);
		theGame.GetTutorialSystem().MarkMessageAsSeen(EQUIP_POTION);
		ShowHint(ON_EQUIPPED, theGame.params.TUT_POS_INVENTORY_X, theGame.params.TUT_POS_INVENTORY_Y-0.1);
	}
}

exec function tut_pot()
{
	TutorialMessagesEnable(true);
	theGame.GetTutorialSystem().TutorialStart(false);
	TutorialScript('PotionsPreparation', '');
}
