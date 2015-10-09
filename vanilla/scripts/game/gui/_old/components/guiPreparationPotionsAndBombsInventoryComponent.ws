﻿/*
Copyright © CD Projekt RED 2015
*/

class W3GuiPreparationPotionsAndBombsInventoryComponent extends W3GuiPlayerInventoryComponent
{	
	protected function ShouldShowItem( item : SItemUniqueId ):bool
	{
		var bShow : bool;
		var itemName : name;
		itemName = _inv.GetItemName(item);
		
		if( _inv.IsItemQuickslotItem(item) ) 
		{
			bShow = true;
		}
		else
		{
			bShow = isPotionItem( item );
		}
		
		return bShow;
	}
}