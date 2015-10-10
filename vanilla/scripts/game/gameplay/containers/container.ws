/***********************************************************************/
/** Witcher Script file - Container controll class
/***********************************************************************/
/** Copyright © 2012 CDProjektRed
/** Author : Malgorzata Napiontek
/**			 Bartosz Bigaj
/**			 Tomasz Kozera
/***********************************************************************/

import class W3Container extends W3LockableEntity //@FIXME Bidon - apply loot window mechanics
{
	editable 			var isDynamic				: bool;					//set to true if container is dynamically created (e.g. loot bag)
																			//obsolete parameter --- > should be always false	//if false then once container is emptied you cannot use it anymore
	editable 			var skipInventoryPanel		: bool;					//if true then no inventory panel will be shown upon looting (forces auto loot)
	editable 			var focusModeHighlight		: EFocusModeVisibility;
	editable			var factOnContainerOpened	: string;
						var usedByCiri				: bool;
	editable			var allowToInjectBalanceItems : bool;
					default allowToInjectBalanceItems = false;					
	editable			var disableLooting			: bool;
	
	editable			var disableStealing			: bool;
					default	disableStealing			= true;
	
	protected saved 	var checkedForBonusMoney	: bool;					//set when container was tested for dropping bonus money
	
	private	saved		var	usedByClueStash 		: EntityHandle;

	protected optional autobind 	inv							: CInventoryComponent = single;
	protected optional autobind 	lootInteractionComponent 	: CInteractionComponent = "Loot";
	protected var isPlayingInteractionAnim : bool; default isPlayingInteractionAnim = false;
	private const var QUEST_HIGHLIGHT_FX : name;							//fx marking that container has a quest item

	hint skipInventoryPanel = "If set then the inventory panel will not be shown upon looting";
	hint isDynamic = "set to true if you want to destroy container when empty";
	hint focusModeHighlight = "FMV_Interactive: White, FMV_Clue: Red";
	
	default skipInventoryPanel = false;	
	default usedByCiri = false;	
	default focusModeHighlight = FMV_Interactive;
	default QUEST_HIGHLIGHT_FX = 'quest_highlight_fx';
	default disableLooting = false;
	
	import function SetIsQuestContainer( isQuest : bool );
	
	private const var SKIP_NO_DROP_NO_SHOW : bool;
	default SKIP_NO_DROP_NO_SHOW = true;
	
	event OnSpawned( spawnData : SEntitySpawnData ) 
	{		
		EnableVisualDebug( SHOW_Containers, true );
		super.OnSpawned(spawnData);
		
		//container cannot ever be looted - treat as decoration
		if(disableLooting)
		{
			SetFocusModeVisibility( FMV_None );
			StopQuestItemFx();
			if( lootInteractionComponent )
			{
				lootInteractionComponent.SetEnabled(false);
			}
			CheckLock();
		}
		else
		{
			UpdateContainer();
		}
	}
	
		
	event OnStreamIn()
	{
		super.OnStreamIn();
		
		UpdateContainer();
	}
	
	event OnSpawnedEditor( spawnData : SEntitySpawnData )
	{
		EnableVisualDebug( SHOW_Containers, true );
		super.OnSpawned( spawnData );	
	}
	
	event OnVisualDebug( frame : CScriptedRenderFrame, flag : EShowFlags )
	{
		frame.DrawText( GetName(), GetWorldPosition() + Vector( 0, 0, 1.0f ), Color( 255, 0, 255 ) );
		frame.DrawSphere( GetWorldPosition(), 1.0f, Color( 255, 0, 255 ) );
		return true;
	}
	
	function UpdateFactItems()
	{
		var i,j : int;
		var items : array<SItemUniqueId>;
		var tags : array<name>;
		var factName : string;
		
		//check for fact hidden items (not visible unless fact exists)
		if( inv && !disableLooting)
		{
			inv.GetAllItems( items );
		}
		
		for(i=0; i<items.Size(); i+=1)
		{
			tags.Clear();
			inv.GetItemTags(items[i], tags);	// inv exists here, cause if it wouldn't, we would iterate over empty array
			for(j=0; j<tags.Size(); j+=1)
			{
				factName = StrAfterLast(NameToString(tags[j]), "fact_hidden_");
				if(StrLen(factName) > 0)
				{
					if(FactsQuerySum(factName) > 0)
					{
						inv.RemoveItemTag(items[i], theGame.params.TAG_DONT_SHOW);
					}
					else
					{
						inv.AddItemTag(items[i], theGame.params.TAG_DONT_SHOW);
					}
						
					break;
				}
			}
		}
	}
	
	function InjectItemsOnLevels()
	{
		/*var playerLevel : int  = thePlayer.GetLevel() - 1; 
		var itemName 	: name = thePlayer.itemsPerLevel[playerLevel];
		
		if ( !inv.HasItem( itemName ) && 
			 !thePlayer.inv.HasItem( itemName ) && 
			 !thePlayer.itemsPerLevelGiven[playerLevel] &&
			 !( playerLevel > thePlayer.itemsPerLevel.Size() ) && 
             allowToInjectBalanceItems ) 
		{
			thePlayer.SetItemsPerLevelGiven(playerLevel);
			inv.AddAnItem( itemName, 1, true, true );
		}*/
	}
	
	// Called when entity gets within interaction range
	event OnInteractionActivated( interactionComponentName : string, activator : CEntity )
	{
		UpdateContainer();
		RebalanceItems();
		RemoveUnwantedItems();
		if ( DisableIfEmpty() )
		{
			// was destroyed inside DisableIfEmpty()
			return false;
		}
		
		super.OnInteractionActivated(interactionComponentName, activator);
		if(activator == thePlayer)
		{
			if ( inv && !disableLooting)
			{
				inv.UpdateLoot();
				
				if(!checkedForBonusMoney)
				{
					checkedForBonusMoney = true;
					CheckForBonusMoney(0);
				}
			}
			if(!disableLooting && (!thePlayer.IsInCombat() || IsEnabledInCombat()) )
				HighlightEntity();
			
			if ( interactionComponentName == "Medallion" && isMagicalObject )
				SenseMagic();
			
			if( (!IsEmpty() && !disableLooting) || lockedByKey)	//if empty and not reusable but locked then we still need to process it
			{
				ShowInteractionComponent();
			}
		}
	}
	
	// Called when entity leaves interaction range
	event OnInteractionDeactivated( interactionComponentName : string, activator : CEntity )
	{
		super.OnInteractionDeactivated(interactionComponentName, activator);
		
		if(activator == thePlayer)
		{
			UnhighlightEntity();
		}
	}
	
	// Returns true if container can be used during combat
	public final function IsEnabledInCombat() : bool
	{
		if( !lootInteractionComponent || disableLooting)
		{
			return false;
		}
		
		return lootInteractionComponent.IsEnabledInCombat();
	}
	
	public function InformClueStash()
	{
		var clueStash : W3ClueStash;
		clueStash = ( W3ClueStash )EntityHandleGet( usedByClueStash );
		if( clueStash )
		{
			clueStash.OnContainerEvent();
		}
	}
	
	event OnItemGiven(data : SItemChangedData)
	{
		super.OnItemGiven(data);
		
		if(isEnabled)
			UpdateContainer();
			
		InformClueStash();
	}
	
	function ReadSchematicsAndRecipes()
	{
	}
	
	
	event OnItemTaken(itemId : SItemUniqueId, quantity : int)
	{
		super.OnItemTaken(itemId, quantity);
		
		if(!HasQuestItem())
		{
			StopQuestItemFx();
		}
		
		InformClueStash();
	}
	
	event OnUpdateContainer()
	{
		
	}
	
	public function RequestUpdateContainer()
	{
		UpdateContainer();
	}
	
	protected final function UpdateContainer()
	{
		var medalion		: CComponent;
		var foliageComponent : CSwitchableFoliageComponent;
		var itemCategory : name;
		
		foliageComponent = ( CSwitchableFoliageComponent ) GetComponentByClassName( 'CSwitchableFoliageComponent' );
		
		if(!disableLooting)
			UpdateFactItems();
		
		if( inv && !disableLooting)
		{
			inv.UpdateLoot();
		}
		
		// container is always visible (full) when game is not active
		if ( !theGame.IsActive() || ( inv && !disableLooting && isEnabled && !inv.IsEmpty( SKIP_NO_DROP_NO_SHOW ) ) )
		{
			SetFocusModeVisibility( focusModeHighlight );
			AddTag('HighlightedByMedalionFX');
			
			if ( foliageComponent )
				foliageComponent.SetAndSaveEntry( 'full' );
			else
				ApplyAppearance("1_full");			
				
			if( HasQuestItem() )
			{
				SetIsQuestContainer( true );
				PlayQuestItemFx();
			}
		}
		else
		{
			SetFocusModeVisibility( FMV_None );
			
			if ( foliageComponent && !disableLooting)
				foliageComponent.SetAndSaveEntry( 'empty' );
			else
				ApplyAppearance("2_empty");
				
			StopQuestItemFx();
		}
		
		if ( !isMagicalObject ) // @FIXME Bidon - move to better place
		{
			medalion = GetComponent("Medallion");
			if(medalion)
			{
				medalion.SetEnabled( false );
			}
		}
		
		if(lootInteractionComponent)
		{
			if(disableLooting)
			{
				lootInteractionComponent.SetEnabled(false);
			}
			else
			{
				lootInteractionComponent.SetEnabled( inv && !inv.IsEmpty( SKIP_NO_DROP_NO_SHOW ) ) ; //Only enable "Loot" when there is content inside.
			}
		}
		
		if(!disableLooting)
			OnUpdateContainer();
			
		CheckForDimeritium();
		CheckLock();
		
	}
	
	function RebalanceItems()
	{
		var i : int;
		var items : array<SItemUniqueId>;
	
		if( inv && !disableLooting)
		{
			inv.AutoBalanaceItemsWithPlayerLevel();
			inv.GetAllItems( items );
		}
		
		for(i=0; i<items.Size(); i+=1)
		{
			// Adding abilities to masterwork / magical items
			if ( inv.GetItemModifierInt(items[i], 'ItemQualityModified') > 0 )
					continue;
					
			inv.AddRandomEnhancementToItem(items[i]);
		}
	}
	
	protected final function HighlightEntity()
	{
		isHighlightedByMedallion = true;
	}
	
	protected final function UnhighlightEntity()
	{
		StopEffect('medalion_detection_fx');
		StopEffect('medalion_fx');
		isHighlightedByMedallion = false;
	}
	
	public final function HasQuestItem() : bool
	{
		if( !inv || disableLooting)
		{
			return false;
		}			

		return inv.HasQuestItem();
	}
	
	public function CheckForDimeritium()
	{
		if (inv && !disableLooting)
		{
			if ( inv.HasItemByTag('Dimeritium'))
			{
				if (!this.HasTag('Potestaquisitor')) this.AddTag('Potestaquisitor');
			}
			else
			{
				if (this.HasTag('Potestaquisitor')) this.RemoveTag('Potestaquisitor');
			}
		}
		else
		{
			if (this.HasTag('Potestaquisitor')) this.RemoveTag('Potestaquisitor');
		}
	}
	
	// #B when returns false item is not transfered, so for example if we want container that gives only one item (or one item type) it should be checked in this function
	public final function OnTryToGiveItem( itemId : SItemUniqueId ) : bool 
	{
		return true; 
	}
	
	//Transfers all items from container to player's inventory
	public function TakeAllItems()
	{
		var targetInv : CInventoryComponent;
		var allItems	: array< SItemUniqueId >;
		var ciriEntity  : W3ReplacerCiri;
		var i : int;
		var itemsCategories : array< name >;
		var category : name;
		
		// Transfer items
		targetInv = thePlayer.inv;
		
		if( !inv || !targetInv )
		{
			return;
		}
		
		inv.GetAllItems( allItems );

		LogChannel( 'ITEMS___', ">>>>>>>>>>>>>> TakeAllItems " + allItems.Size() );
		
		for(i=0; i<allItems.Size(); i+=1)
		{						
			if( inv.ItemHasTag(allItems[i], 'Lootable' ) || !inv.ItemHasTag(allItems[i], 'NoDrop') && !inv.ItemHasTag(allItems[i], theGame.params.TAG_DONT_SHOW))
			{
				inv.NotifyItemLooted( allItems[ i ] );
				
				if( inv.ItemHasTag(allItems[i], 'HerbGameplay') )
				{
					category = 'herb';
				}
				else
				{
					category = inv.GetItemCategory(allItems[i]);
				}
				
				if( itemsCategories.FindFirst( category ) == -1 )
				{
					itemsCategories.PushBack( category );
				}
				inv.GiveItemTo(targetInv, allItems[i], inv.GetItemQuantity(allItems[i]), true, false, true );
			}
		}
		if( itemsCategories.Size() == 1 )
		{
			PlayItemEquipSound(itemsCategories[0]);
		}
		else
		{
			PlayItemEquipSound('generic');
		}
		
		LogChannel( 'ITEMS___', "<<<<<<<<<<<<<< TakeAllItems");
		
		InformClueStash();
	}
	
	public function Unlock( )
	{
		if( IsNameValid(keyItemName) && removeKeyOnUse )
		{
			// save state of this container
			SetIsQuestContainer( true );
		}
		super.Unlock();
	}
	
	// Called when some interaction occurs with this container
	event OnInteraction( actionName : string, activator : CEntity )
	{
		var processed : bool;
		var i,j : int;
		var m_schematicList, m_recipeList : array< name >;
		var itemCategory : name;
		var attr : SAbilityAttributeValue;
		
		if ( activator != thePlayer || isInteractionBlocked || IsEmpty() )
			return false;
			
		if ( activator == (W3ReplacerCiri)thePlayer )
		{
			skipInventoryPanel = true;
			usedByCiri = true;
		}
		
		if ( StrLen( factOnContainerOpened ) > 0 && !FactsDoesExist ( factOnContainerOpened ) && ( actionName == "Container" || actionName == "Unlock" ) )
		{
			FactsAdd ( factOnContainerOpened, 1, -1 );
		}
		
		//don't add recipes that you already have and items with to high level
		m_recipeList     = GetWitcherPlayer().GetAlchemyRecipes();
		m_schematicList = GetWitcherPlayer().GetCraftingSchematicsNames();
		
		// Process New Game+ Witcher sets schematics
		if ( FactsQuerySum("NewGamePlus") > 0 )
		{
			AddWolfNewGamePlusSchematics();
			KeepWolfWitcherSetSchematics(m_schematicList);
		}
		
		InjectItemsOnLevels();
		
		processed = super.OnInteraction(actionName, activator);
		if(processed)
			return true;		//handled by super
							
		if(actionName != "Container" && actionName != "GatherHerbs")
			return false;		
					
		ProcessLoot ();
		
		return true;
	}
	
	function RemoveUnwantedItems()
	{
		var allItems : array< SItemUniqueId >;
		var i,j : int;
		var m_schematicList, m_recipeList : array< name >;
		var itemName : name;
		
		if ( !HasTag('lootbag') )
		{
			m_recipeList     = GetWitcherPlayer().GetAlchemyRecipes();
			m_schematicList = GetWitcherPlayer().GetCraftingSchematicsNames();
			
			inv.GetAllItems( allItems );
			for ( i=0; i<allItems.Size(); i+=1 )
			{
				itemName = inv.GetItemName( allItems[i] );
			
				// recipes
				for( j = 0; j < m_recipeList.Size(); j+= 1 )
				{	
					if ( itemName == m_recipeList[j] )
					{
						inv.RemoveItem( allItems[i], inv.GetItemQuantity(  allItems[i] ) );
						inv.NotifyItemLooted( allItems[i] );
						//inv.AddAnItem( 'Crowns', RoundF(RandRangeF(4, 2)), true, true);
					}
				}
				// schematics
				for( j = 0; j < m_schematicList.Size(); j+= 1 )
				{	
					if ( itemName == m_schematicList[j] )
					{
						inv.RemoveItem( allItems[i], inv.GetItemQuantity(  allItems[i] ) );
						inv.NotifyItemLooted( allItems[i] );
						//inv.AddAnItem( 'Crowns', RoundF(RandRangeF(4, 2)), true, true);
					}	
				}
				
				if ( GetWitcherPlayer().GetLevel() - 1 > 1 && inv.GetItemLevel( allItems[i] ) == 1 && inv.ItemHasTag(allItems[i], 'Autogen') )
				{ // failsafe - when item is spawned in container and there is no player level yet - reset item and regenerate
					inv.RemoveItemCraftedAbility(allItems[i], 'autogen_steel_base');
					inv.RemoveItemCraftedAbility(allItems[i], 'autogen_silver_base');
					inv.RemoveItemCraftedAbility(allItems[i], 'autogen_armor_base');
					inv.RemoveItemCraftedAbility(allItems[i], 'autogen_pants_base');
					inv.RemoveItemCraftedAbility(allItems[i], 'autogen_gloves_base');
					inv.GenerateItemLevel(allItems[i], false);
				}
				
				// too many the same gwint cards collected already
				if ( inv.GetItemCategory(allItems[i]) == 'gwint' )
				{
					inv.ClearGwintCards();
				}
			}
		}
	}
	
	function ProcessLoot()
	{
		if(disableLooting)
			return;
			
		if(skipInventoryPanel || usedByCiri)
		{
			TakeAllItems();
			OnContainerClosed();			
		}
		else
		{
			ShowLoot();
		}
	}
	
	private function KeepWolfWitcherSetSchematics(out m_schematicList : array< name >)
	{
		var index : int;
		
		// Wolf
		index = m_schematicList.FindFirst('Wolf Armor schematic');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Witcher Wolf Jacket Upgrade schematic 1');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Witcher Wolf Jacket Upgrade schematic 2');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Witcher Wolf Jacket Upgrade schematic 3');
		if ( index > -1 ) m_schematicList.Erase( index );
		
		index = m_schematicList.FindFirst('Wolf Gloves schematic');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Witcher Wolf Gloves Upgrade schematic 1');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Witcher Wolf Gloves Upgrade schematic 2');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Witcher Wolf Gloves Upgrade schematic 3');
		if ( index > -1 ) m_schematicList.Erase( index );
		
		index = m_schematicList.FindFirst('Wolf Pants schematic');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Witcher Wolf Pants Upgrade schematic 1');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Witcher Wolf Pants Upgrade schematic 2');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Witcher Wolf Pants Upgrade schematic 3');
		if ( index > -1 ) m_schematicList.Erase( index );
		
		index = m_schematicList.FindFirst('Wolf Boots schematic');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Witcher Wolf Boots Upgrade schematic 1');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Witcher Wolf Boots Upgrade schematic 2');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Witcher Wolf Boots Upgrade schematic 3');
		if ( index > -1 ) m_schematicList.Erase( index );
		
		index = m_schematicList.FindFirst('Wolf School steel sword schematic');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Wolf School steel sword Upgrade schematic 1');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Wolf School steel sword Upgrade schematic 2');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Wolf School steel sword Upgrade schematic 3');
		if ( index > -1 ) m_schematicList.Erase( index );
		
		index = m_schematicList.FindFirst('Wolf School silver sword schematic');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Wolf School silver sword Upgrade schematic 1');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Wolf School silver sword Upgrade schematic 2');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Wolf School silver sword Upgrade schematic 3');
		if ( index > -1 ) m_schematicList.Erase( index );
	}
	
	private function AddWolfNewGamePlusSchematics()
	{
		var allItems	: array< SItemUniqueId >;
		var i	 		: int;
		var itemName	: name;
		
		inv.GetAllItems( allItems );
		for ( i=0; i<allItems.Size(); i+=1 )
		{	
			itemName = inv.GetItemName( allItems[i] );
		
			// Wolf Armors
			if ( itemName == 'Wolf Armor schematic' && !inv.HasItem('NGP Wolf Armor schematic') )
				inv.AddAnItem( 'NGP Wolf Armor schematic', 1, true, true);
			if ( itemName == 'Witcher Wolf Jacket Upgrade schematic 1' && !inv.HasItem('NGP Witcher Wolf Jacket Upgrade schematic 1') )
				inv.AddAnItem( 'NGP Witcher Wolf Jacket Upgrade schematic 1', 1, true, true);
			if ( itemName == 'Witcher Wolf Jacket Upgrade schematic 2' && !inv.HasItem('NGP Witcher Wolf Jacket Upgrade schematic 2') )
				inv.AddAnItem( 'NGP Witcher Wolf Jacket Upgrade schematic 2', 1, true, true);
			if ( itemName == 'Witcher Wolf Jacket Upgrade schematic 3' && !inv.HasItem('NGP Witcher Wolf Jacket Upgrade schematic 3') )
				inv.AddAnItem( 'NGP Witcher Wolf Jacket Upgrade schematic 3', 1, true, true);
				
			if ( itemName == 'Wolf Gloves schematic' && !inv.HasItem('NGP Wolf Gloves schematic') )
				inv.AddAnItem( 'NGP Wolf Gloves schematic', 1, true, true);
			if ( itemName == 'Witcher Wolf Gloves Upgrade schematic 1' && !inv.HasItem('NGP Witcher Wolf Gloves Upgrade schematic 1') )
				inv.AddAnItem( 'NGP Witcher Wolf Gloves Upgrade schematic 1', 1, true, true);
			if ( itemName == 'Witcher Wolf Gloves Upgrade schematic 2' && !inv.HasItem('NGP Witcher Wolf Gloves Upgrade schematic 2') )
				inv.AddAnItem( 'NGP Witcher Wolf Gloves Upgrade schematic 2', 1, true, true);
			if ( itemName == 'Witcher Wolf Gloves Upgrade schematic 3' && !inv.HasItem('NGP Witcher Wolf Gloves Upgrade schematic 3') )
				inv.AddAnItem( 'NGP Witcher Wolf Gloves Upgrade schematic 3', 1, true, true);
				
			if ( itemName == 'Wolf Pants schematic' && !inv.HasItem('NGP Wolf Pants schematic') )
				inv.AddAnItem( 'NGP Wolf Pants schematic', 1, true, true);
			if ( itemName == 'Witcher Wolf Pants Upgrade schematic 1' && !inv.HasItem('NGP Witcher Wolf Pants Upgrade schematic 1') )
				inv.AddAnItem( 'NGP Witcher Wolf Pants Upgrade schematic 1', 1, true, true);
			if ( itemName == 'Witcher Wolf Pants Upgrade schematic 2' && !inv.HasItem('NGP Witcher Wolf Pants Upgrade schematic 2') )
				inv.AddAnItem( 'NGP Witcher Wolf Pants Upgrade schematic 2', 1, true, true);
			if ( itemName == 'Witcher Wolf Pants Upgrade schematic 3' && !inv.HasItem('NGP Witcher Wolf Pants Upgrade schematic 3') )
				inv.AddAnItem( 'NGP Witcher Wolf Pants Upgrade schematic 3', 1, true, true);
				
			if ( itemName == 'Wolf Boots schematic' && !inv.HasItem('NGP Wolf Boots schematic') )
				inv.AddAnItem( 'NGP Wolf Boots schematic', 1, true, true);
			if ( itemName == 'Witcher Wolf Boots Upgrade schematic 1' && !inv.HasItem('NGP Witcher Wolf Boots Upgrade schematic 1') )
				inv.AddAnItem( 'NGP Witcher Wolf Boots Upgrade schematic 1', 1, true, true);
			if ( itemName == 'Witcher Wolf Boots Upgrade schematic 2' && !inv.HasItem('NGP Witcher Wolf Boots Upgrade schematic 2') )
				inv.AddAnItem( 'NGP Witcher Wolf Boots Upgrade schematic 2', 1, true, true);
			if ( itemName == 'Witcher Wolf Boots Upgrade schematic 3' && !inv.HasItem('NGP Witcher Wolf Boots Upgrade schematic 3') )
				inv.AddAnItem( 'NGP Witcher Wolf Boots Upgrade schematic 3', 1, true, true);	
				
			if ( itemName == 'Wolf School steel sword schematic' && !inv.HasItem('NGP Wolf School steel sword schematic') )
				inv.AddAnItem( 'NGP Wolf School steel sword schematic', 1, true, true);
			if ( itemName == 'Wolf School steel sword Upgrade schematic 1' && !inv.HasItem('NGP Wolf School steel sword Upgrade schematic 1') )
				inv.AddAnItem( 'NGP Wolf School steel sword Upgrade schematic 1', 1, true, true);
			if ( itemName == 'Wolf School steel sword Upgrade schematic 2' && !inv.HasItem('NGP Wolf School steel sword Upgrade schematic 2') )
				inv.AddAnItem( 'NGP Wolf School steel sword Upgrade schematic 2', 1, true, true);
			if ( itemName == 'Wolf School steel sword Upgrade schematic 3' && !inv.HasItem('NGP Wolf School steel sword Upgrade schematic 3') )
				inv.AddAnItem( 'NGP Wolf School steel sword Upgrade schematic 3', 1, true, true);	
				
			if ( itemName == 'Wolf School silver sword schematic' && !inv.HasItem('NGP Wolf School silver sword schematic') )
				inv.AddAnItem( 'NGP Wolf School silver sword schematic', 1, true, true);
			if ( itemName == 'Wolf School silver sword Upgrade schematic 1' && !inv.HasItem('NGP Wolf School silver sword Upgrade schematic 1') )
				inv.AddAnItem( 'NGP Wolf School silver sword Upgrade schematic 1', 1, true, true);
			if ( itemName == 'Wolf School silver sword Upgrade schematic 2' && !inv.HasItem('NGP Wolf School silver sword Upgrade schematic 2') )
				inv.AddAnItem( 'NGP Wolf School silver sword Upgrade schematic 2', 1, true, true);
			if ( itemName == 'Wolf School silver sword Upgrade schematic 3' && !inv.HasItem('NGP Wolf School silver sword Upgrade schematic 3') )
				inv.AddAnItem( 'NGP Wolf School silver sword Upgrade schematic 3', 1, true, true);	
		}
	}
	
	event OnStateChange( newState : bool )
	{
		if( lootInteractionComponent )
		{
			lootInteractionComponent.SetEnabled( newState );
		}
		
		super.OnStateChange( newState );
	}
	
	// Function showing the loot panel
	public final function ShowLoot()
	{
		var lootData : W3LootPopupData;
		
		lootData = new W3LootPopupData in this;
		
		lootData.targetContainer = this;
		
		theGame.RequestPopup('LootPopup', lootData);
		
		/*var hud : CR4ScriptedHud;
		var lootPopupModule : CR4HudModuleLootPopup;

		hud = (CR4ScriptedHud)theGame.GetHud();
		if( hud )
		{
			lootPopupModule = (CR4HudModuleLootPopup)hud.GetHudModule("LootPopupModule");
			lootPopupModule.Open( this );
		}*/
	}
	
	public function IsEmpty() : bool				{ return !inv || inv.IsEmpty( SKIP_NO_DROP_NO_SHOW ); }
	
	public function Enable(e : bool, optional skipInteractionUpdate : bool, optional questForcedEnable : bool)
	{
		if( !(e && questForcedEnable) )
		{
			//don't enable if container is empty and is not reusable
			if(e && IsEmpty() )
			{
				return;
			}
			else
			{
				UpdateContainer();
			}
		}
		
		super.Enable(e, skipInteractionUpdate);
	}
	
	// Called when the container is closed
	public function OnContainerClosed()
	{
		if(!HasQuestItem())
			StopQuestItemFx();
		
		DisableIfEmpty();
	}
	
	// returns true if container was destroyed
	protected function DisableIfEmpty() : bool
	{
		if(IsEmpty())
		{
			SetFocusModeVisibility( FMV_None );
			
			RemoveTag('HighlightedByMedalionFX');
			
			//disable highlights
			UnhighlightEntity();
			
			//disable container
			Enable(false);
			
			//change model if empty			
			ApplyAppearance("2_empty");
			
			if(isDynamic)
			{
				Destroy();
				return true;
			}
		}
		return false;
	}
	
	//adds additional money based on player bonuses
	protected final function CheckForBonusMoney(oldMoney : int)
	{
		var money, bonusMoney : int;
		
		if( !inv )
		{
			return;
		}
		
		money = inv.GetMoney() - oldMoney;
		if(money <= 0)
		{
			return;
		}
			
		bonusMoney = RoundMath(money * CalculateAttributeValue(thePlayer.GetAttributeValue('bonus_money')));
		if(bonusMoney > 0)
		{
			inv.AddMoney(bonusMoney);
		}
	}
	
	public final function PlayQuestItemFx()
	{
		PlayEffectSingle(QUEST_HIGHLIGHT_FX);
	}
	
	public final function StopQuestItemFx()
	{
		StopEffect(QUEST_HIGHLIGHT_FX);
	}
	
	public function GetSkipInventoryPanel():bool
	{
		return skipInventoryPanel;
	}
	
	public function CanShowFocusInteractionIcon() : bool
	{
		return inv && !disableLooting && isEnabled && !inv.IsEmpty( SKIP_NO_DROP_NO_SHOW );
	}
	
	public function RegisterClueStash( clueStash : W3ClueStash )
	{
		EntityHandleSet( usedByClueStash, clueStash );
	}
}
