﻿/*
Copyright © CD Projekt RED 2015
*/

import class CWitcherSword extends CItemEntity
{
	editable var padBacklightColor : Vector;
	
	var oilLevel : int;
	var runeCount : int;
	
	hint padBacklightColor = "PS4 backlight color. R,G,B [0-1]";
	
	import public function GetSwordType() : EWitcherSwordType;
	
	public function Initialize( actor : CActor )
	{
		var inv : CInventoryComponent;
		var swordCategory : name;
		var myItemId : SItemUniqueId;
		var stateName : name;
		var swordType : EWitcherSwordType;

		var abilities : array<name>;
		
		inv = (CInventoryComponent)( actor.GetComponentByClassName( 'CInventoryComponent' ) );
		
		swordType = GetSwordType();
		switch ( swordType )
		{
			case WST_Silver:
				swordCategory = 'silversword';
				break;
			case WST_Steel:
				swordCategory = 'steelsword';
				break;
		}
		myItemId = inv.GetItemByItemEntity( this );
		inv.GetItemAbilitiesWithTag( myItemId, theGame.params.OIL_ABILITY_TAG, abilities );
		ApplyOil( abilities );
		
		runeCount = inv.GetItemEnhancementCount( myItemId );
		UpdateEnhancements( runeCount );
		
		stateName = actor.GetCurrentStateName();
		
		if ( ( swordType == WST_Silver && stateName == 'CombatSilver' ) ||
			( swordType == WST_Steel && stateName == 'CombatSteel' ) )
		{
			PlayEffect('rune_blast_loop');
		}
		else
		{
			PlayEffect('rune_blast_long');
		}
	}
	
	event OnGrab()
	{
		super.OnGrab();
		
		Initialize( (CActor)GetParentEntity() );
		GetWitcherPlayer().ResetPadBacklightColor();
	}
	
	event OnPut()
	{
		super.OnPut();
		
		StopAllEffects();
		GetWitcherPlayer().ResetPadBacklightColor(true);
	}
	
	public function ApplyOil( oilAbilities : array<name> )
	{
		var i : int;
		var dm : CDefinitionsManagerAccessor;
		var oilFx : name;
		var min, max : SAbilityAttributeValue;
		
		dm = theGame.GetDefinitionsManager();
		dm.GetAbilitiesAttributeValue(oilAbilities, 'level', min, max);
		oilLevel = (int) CalculateAttributeValue(min);
		
		oilFx = GetOilFxName();
		PlayEffect(oilFx);
	}
	
	public function RemoveOil()
	{
		var oilFx : name;
		
		oilFx = GetOilFxName();
		StopEffect(oilFx);
		oilLevel = 0;
	}
	
	public function GetOilFxName() : name
	{
		var oilFx : name;
		
		switch (oilLevel)
		{	
			case 0:
				oilFx = 'oil_lvl0';
				break;
			case 1:
				oilFx = 'oil_lvl1';
				break;
			case 2:
				oilFx = 'oil_lvl2';
				break;
			case 3:
				oilFx = 'oil_lvl3';
				break;
		}
		
		return oilFx;
	}
	
		public function GetRuneFxName() : name
	{
		var runeFx : name;
		
		switch (runeCount)
		{	
			case 0:
				runeFx = 'rune_lvl0';
				break;
			case 1:
				runeFx = 'rune_lvl1';
				break;
			case 2:
				runeFx = 'rune_lvl2';
				break;
			case 3:
				runeFx = 'rune_lvl3';
				break;
		}
		
		return runeFx;
	}
	
	public function UpdateEnhancements( newRuneCount : int )
	{
		var fx : name;
		
		fx = GetRuneFxName();
		StopEffect( fx );
		runeCount = newRuneCount;
		fx = GetRuneFxName();
		PlayEffect( fx );
	}
}