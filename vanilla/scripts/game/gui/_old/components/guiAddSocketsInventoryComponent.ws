﻿class W3GuiAddSocketsInventoryComponent extends W3GuiPlayerInventoryComponent
{
	public var merchantInv : CInventoryComponent;
	private var maxUpgradedItems : array<SItemUniqueId>;
	
	protected /* override */ function ShouldShowItem( item : SItemUniqueId ):bool
	{
		var itemTags    	 : array <name>;
		var showItem 		 : bool;
		var slotsCount  	 : int;
		var isArmorOrWeapon  : bool;
		
		_inv.GetItemTags( item, itemTags );
		slotsCount = _inv.GetItemEnhancementSlotsCount( item );
		isArmorOrWeapon = _inv.IsItemAnyArmor(item) || _inv.IsItemWeapon(item);
		
		showItem = !itemTags.Contains( theGame.params.TAG_DONT_SHOW )
				&& !itemTags.Contains( theGame.params.TAG_DONT_SHOW_ONLY_IN_PLAYERS )
				&& !_inv.IsItemQuest( item )
				&& (slotsCount < _inv.GetSlotItemsLimit( item ) || maxUpgradedItems.Contains(item)) && isArmorOrWeapon;
		
		return showItem;
	}
	
	public /* override */ function SetInventoryFlashObjectForItem( item : SItemUniqueId, out flashObject : CScriptedFlashObject) : void
	{
		var invItem 	 : SInventoryItem;
		var isEquipped   : bool;
		
		super.SetInventoryFlashObjectForItem( item, flashObject );
		
		isEquipped = GetWitcherPlayer().IsItemEquipped(item);
		
		// #Y TEMP PRICE, TODO:
		invItem = _inv.GetItem( item );
		flashObject.SetMemberFlashInt( "actionPrice", merchantInv.GetItemPriceAddSlot( invItem ) );
		flashObject.SetMemberFlashBool( "isEquipped",  isEquipped);
		flashObject.SetMemberFlashInt( "socketsMaxCount", _inv.GetSlotItemsLimit( item ) );
		
		if ( maxUpgradedItems.Contains(item) )
		{
			flashObject.SetMemberFlashBool( "isReaded", true ); // grayout in grid
			flashObject.SetMemberFlashBool( "disableAction", true );
		}
	}
	
	public function AddSocket(item : SItemUniqueId) : void
	{
		_inv.AddSlot(item);
		
		if ( _inv.GetItemEnhancementSlotsCount( item ) >= _inv.GetSlotItemsLimit( item ) )
		{
			maxUpgradedItems.PushBack( item );
		}
	}
}