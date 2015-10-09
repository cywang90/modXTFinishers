﻿/*
Copyright © CD Projekt RED 2015
*/








class W3HorseManager extends CPeristentEntity
{
	private autobind inv : CInventoryComponent = single;		
	private saved var horseAbilities : array<name>;				
	private saved var itemSlots : array<SItemUniqueId>;			
	private saved var wasSpawned : bool;						
	
	default wasSpawned = false;
	
	public function OnCreated()
	{
		itemSlots.Grow(EnumGetMax('EEquipmentSlots')+1);
		
		Debug_TraceInventories( "OnCreated" );
	}
	
	public function GetInventoryComponent() : CInventoryComponent
	{
		return inv;
	}
	
	
	public function ApplyHorseUpdateOnSpawn() : bool
	{
		var ids, items 		: array<SItemUniqueId>;
		var eqId  			: SItemUniqueId;
		var i 				: int;
		var horseInv 		: CInventoryComponent;
		var horse			: CNewNPC;
		
		horse = thePlayer.GetHorseWithInventory();
		if( !horse )
		{
			return false;
		}
		
		horseInv = horse.GetInventory();
		horseInv.GetAllItems(items);
		
		Debug_TraceInventories( "ApplyHorseUpdateOnSpawn ] BEFORE" );
		
		
		if (!wasSpawned)
		{
			for(i=items.Size()-1; i>=0; i-=1)
			{
				if ( horseInv.ItemHasTag(items[i], 'HorseTail') || horseInv.ItemHasTag(items[i], 'HorseReins') )
					continue;
				eqId = horseInv.GiveItemTo(inv, items[i], 1, false);
				EquipItem(eqId);
			}
			wasSpawned = true;
		}
		
		
		for(i=items.Size()-1; i>=0; i-=1)
		{
			if ( horseInv.ItemHasTag(items[i], 'HorseTail') || horseInv.ItemHasTag(items[i], 'HorseReins') )
				continue;
			horseInv.RemoveItem(items[i]);
		}
		
		
		for(i=0; i<itemSlots.Size(); i+=1)
		{
			if(inv.IsIdValid(itemSlots[i]))
			{
				ids = horseInv.AddAnItem(inv.GetItemName(itemSlots[i]));
				horseInv.MountItem(ids[0]);
			}
		}
	
		
		horseAbilities.Clear();
		horseAbilities = horse.GetAbilities(true);
		
		ReenableMountHorseInteraction( horse );

		Debug_TraceInventories( "ApplyHorseUpdateOnSpawn ] AFTER" );
				
		return true;
	}
	
	public function ReenableMountHorseInteraction( horse : CNewNPC )
	{
		var components : array< CComponent >;
		var ic : CInteractionComponent;
		var hc : W3HorseComponent;
		var i : int;

		if ( horse )
		{
			hc = horse.GetHorseComponent();
			if ( hc && !hc.GetUser() ) 
			{
				components = horse.GetComponentsByClassName( 'CInteractionComponent' );
				for ( i = 0; i < components.Size(); i += 1 )
				{
					ic = ( CInteractionComponent )components[ i ];
					if ( ic && ic.GetActionName() == "MountHorse" )
					{
						if ( !ic.IsEnabled() )
						{
							ic.SetEnabled( true );
						}
						return;
					}
				}
			}
		}
	}
	
	public function IsItemEquipped(id : SItemUniqueId) : bool
	{
		return itemSlots.Contains(id);
	}
	
	public function GetItemInSlot( slot : EEquipmentSlots ) : SItemUniqueId
	{
		if(slot == EES_InvalidSlot)
			return GetInvalidUniqueId();
		else
			return itemSlots[slot];
	}
	
	public function GetHorseAttributeValue(attributeName : name, excludeItems : bool) : SAbilityAttributeValue
	{
		var i : int;
		var dm : CDefinitionsManagerAccessor;
		var min, max, val : SAbilityAttributeValue;
	
		
		if(horseAbilities.Size() == 0)
		{
			if(thePlayer.GetHorseWithInventory())
			{
				horseAbilities = thePlayer.GetHorseWithInventory().GetAbilities(true);			
			}
			else if(!excludeItems)
			{
				
				for(i=0; i<itemSlots.Size(); i+=1)
				{
					if(itemSlots[i] != GetInvalidUniqueId())
					{
						val += inv.GetItemAttributeValue(itemSlots[i], attributeName);
					}
				}
				
				return val;
			}
		}
		
		dm = theGame.GetDefinitionsManager();
		
		for(i=0; i<horseAbilities.Size(); i+=1)
		{
			dm.GetAbilityAttributeValue(horseAbilities[i], attributeName, min, max);
			val += GetAttributeRandomizedValue(min, max);
		}
		
		
		if(excludeItems)
		{
			for(i=0; i<itemSlots.Size(); i+=1)
			{
				if(itemSlots[i] != GetInvalidUniqueId())
				{
					val -= inv.GetItemAttributeValue(itemSlots[i], attributeName);
				}
			}
		}
		
		return val;
	}
	
	public function EquipItem(id : SItemUniqueId) : SItemUniqueId
	{
		var horse    : CActor;
		var ids      : array<SItemUniqueId>;
		var slot     : EEquipmentSlots;
		var itemName : name;
		var resMount : bool;
		var abls	 : array<name>;
		var i		 : int;
		var unequippedItem : SItemUniqueId;
	
		
		if(!inv.IsIdValid(id))
			return GetInvalidUniqueId();
			
		
		slot = GetHorseSlotForItem(id);
		if(slot == EES_InvalidSlot)
			return GetInvalidUniqueId();
		
		Debug_TraceInventories( "EquipItem ] " + inv.GetItemName( id ) + " - BEFORE" );
		
		
		if(inv.IsIdValid(itemSlots[slot]))
		{
			unequippedItem = UnequipItem(slot);
		}
			
		
		itemSlots[slot] = id;
		horse = thePlayer.GetHorseWithInventory();
		if(horse)
		{
			itemName = inv.GetItemName(id);
			ids = horse.GetInventory().AddAnItem(itemName);
			resMount = horse.GetInventory().MountItem(ids[0]);
			if (resMount)
			{
				horse.GetInventory().GetItemAbilities(ids[0], abls);
				for (i=0; i < abls.Size(); i+=1)
					horseAbilities.PushBack(abls[i]);
			}
		}
		else
		{
			inv.GetItemAbilities(id, abls);
			for (i=0; i < abls.Size(); i+=1)
					horseAbilities.PushBack(abls[i]);
		}
		
		
		theGame.GetGlobalEventsManager().OnScriptedEvent( SEC_OnItemEquipped );
		
		if(inv.IsItemHorseBag(id))
			GetWitcherPlayer().UpdateEncumbrance();
		
		Debug_TraceInventories( "EquipItem ] " + inv.GetItemName( id ) + " - AFTER" );
		
		return unequippedItem;
	}
	
	public function AddAbility(abilityName : name)
	{
		var horse : CNewNPC;
		
		horse = thePlayer.GetHorseWithInventory();
		if(horse)
		{
			horse.AddAbility(abilityName, true);
		}
		
		horseAbilities.PushBack(abilityName);
	}
	
	public function UnequipItem(slot : EEquipmentSlots) : SItemUniqueId
	{
		var itemName : name;
		var horse : CActor;
		var ids : array<SItemUniqueId>;
		var abls : array<name>;
		var i : int;
		var oldItem : SItemUniqueId;
		var newId : SItemUniqueId;
	
		
		if(slot == EES_InvalidSlot)
			return GetInvalidUniqueId();
			
		
		if(!inv.IsIdValid(itemSlots[slot]))
			return GetInvalidUniqueId();
			
		
		oldItem = itemSlots[slot];
		if(inv.IsItemHorseBag( itemSlots[slot] ))
			GetWitcherPlayer().UpdateEncumbrance();
		
		itemName = inv.GetItemName(itemSlots[slot]);
		itemSlots[slot] = GetInvalidUniqueId();
		horse = thePlayer.GetHorseWithInventory();
		
		Debug_TraceInventories( "UnequipItem ] " + itemName + " - BEFORE" );
		
		
		if( horse )
		{
			ids = horse.GetInventory().GetItemsByName( itemName );
			horse.GetInventory().UnmountItem( ids[ 0 ] );
			horse.GetInventory().RemoveItem( ids[ 0 ] );
		}
		
		
		{
			ids = inv.GetItemsByName( itemName );
			inv.GetItemAbilities( ids[ 0 ], abls );
			for( i = 0; i < abls.Size(); i += 1 )
			{
				horseAbilities.Remove( abls[ i ] );
			}
		}
		
		
		newId = inv.GiveItemTo(thePlayer.inv, oldItem, 1, false, true, false);

		
		theGame.GetGlobalEventsManager().OnScriptedEvent( SEC_OnItemEquipped );
		
		Debug_TraceInventories( "UnequipItem ] " + itemName + " - AFTER" );

		return newId;
	}
	
	public function Debug_TraceInventory( inventory : CInventoryComponent, optional categoryName : name )
	{
		var i : int;
		var itemsNames : array< name >;
		var items : array< SItemUniqueId >;
		if( categoryName == '' )
		{
			itemsNames = inventory.GetItemsNames();
			for( i = 0; i < itemsNames.Size(); i+=1 )
			{
				LogChannel( 'Dbg_HorseInv', itemsNames[ i ] );
			}
		}
		else
		{
			items = inventory.GetItemsByCategory( categoryName );
			for( i = 0; i < items.Size(); i+=1 )
			{
				LogChannel( 'Dbg_HorseInv', inventory.GetItemName( items[ i ] ) );
			}
		}
	}
	
	public function Debug_TraceInventories( optional heading : string )
	{
		
		return; 
		
	
		if( heading != "" )
		{
			LogChannel( 'Dbg_HorseInv', "----------------------------------] " + heading );
		}
	
		if( thePlayer && thePlayer.GetHorseWithInventory() )
		{
			LogChannel( 'Dbg_HorseInv', "] Entity Inventory" );
			LogChannel( 'Dbg_HorseInv', "----------------------------------" );
			
			Debug_TraceInventory( thePlayer.GetHorseWithInventory().GetInventory() );
			
			
			LogChannel( 'Dbg_HorseInv', "" );
		}
		
		if( inv )
		{
			LogChannel( 'Dbg_HorseInv', "] Manager Inventory" );
			LogChannel( 'Dbg_HorseInv', "----------------------------------" );
			
			Debug_TraceInventory( inv );
			
			
			LogChannel( 'Dbg_HorseInv', "" );
		}
	}
	
	public function MoveItemToHorse(id : SItemUniqueId, optional quantity : int) : SItemUniqueId
	{
		return thePlayer.inv.GiveItemTo(inv, id, quantity, false, true, false);
	}
	
	public function MoveItemFromHorse(id : SItemUniqueId, optional quantity : int) : SItemUniqueId
	{
		return inv.GiveItemTo(thePlayer.inv, id, quantity, false, true, false);
	}
	
	public function GetHorseSlotForItem(id : SItemUniqueId) : EEquipmentSlots
	{
		return inv.GetHorseSlotForItem(id);
	}
	
		
	public final function HorseRemoveItemByName(itemName : name, quantity : int)
	{
		var ids : array<SItemUniqueId>;
		var slot : EEquipmentSlots;
		
		ids = inv.GetItemsIds(itemName);
		slot = GetHorseSlotForItem(ids[0]);
		UnequipItem(slot);
		
		inv.RemoveItemByName(itemName, quantity);
	}
	
	
	public final function HorseRemoveItemByCategory(itemCategory : name, quantity : int)
	{
		var ids : array<SItemUniqueId>;
		var slot : EEquipmentSlots;
		
		Debug_TraceInventories( "HorseRemoveItemByCategory ] " + itemCategory + " - BEFORE" );
		
		ids = inv.GetItemsByCategory(itemCategory);
		slot = GetHorseSlotForItem(ids[0]);
		UnequipItem(slot);
		
		inv.RemoveItemByCategory(itemCategory, quantity);
		
		Debug_TraceInventories( "HorseRemoveItemByCategory ] " + itemCategory + " - AFTER" );
	}
	
	
	public final function HorseRemoveItemByTag(itemTag : name, quantity : int)
	{
		var ids : array<SItemUniqueId>;
		var slot : EEquipmentSlots;
		
		Debug_TraceInventories( "HorseRemoveItemByTag ] " + itemTag + " - BEFORE" );
		
		ids = inv.GetItemsByTag(itemTag);
		slot = GetHorseSlotForItem(ids[0]);
		UnequipItem(slot);
		
		inv.RemoveItemByTag(itemTag, quantity);
		
		Debug_TraceInventories( "HorseRemoveItemByTag ] " + itemTag + " - AFTER" );
	}
	
	public function GetAssociatedInventory() : CInventoryComponent
	{
		return GetWitcherPlayer().GetInventory();
	}
}
