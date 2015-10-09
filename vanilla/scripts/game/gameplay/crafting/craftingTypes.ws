/*
Copyright © CD Projekt RED 2015
*/





enum ECraftsmanType
{
	ECT_Undefined,
	ECT_Smith,
    ECT_Armorer,
    ECT_Crafter,
	ECT_Enchanter
}

enum ECraftingException
{
	ECE_NoException,
	ECE_TooLowCraftsmanLevel,
	ECE_MissingIngredient,
	ECE_TooFewIngredients,
	ECE_WrongCraftsmanType,
	ECE_NotEnoughMoney,
	ECE_UnknownSchematic,
	ECE_CookNotAllowed
}

function CraftingExceptionToString( result : ECraftingException ) : string
{
	switch ( result )
	{
		case ECE_NoException:			return "panel_crafting_craft_item";
		case ECE_TooLowCraftsmanLevel:	return "panel_crafting_exception_too_low_craftsman_level";
		case ECE_MissingIngredient:		return "panel_crafting_exception_missing_ingridient";
		case ECE_TooFewIngredients:		return "panel_crafting_exception_missing_ingridients";
		case ECE_WrongCraftsmanType:	return "panel_crafting_exception_wrong_craftsman_type";
		case ECE_NotEnoughMoney:		return "panel_crafting_exception_not_enough_money";
		case ECE_UnknownSchematic:		return "panel_crafting_exception_unknown_schematic";
		case ECE_CookNotAllowed:		return "panel_crafting_exception_cook_not_allowed";
	}
	return "";
}


struct SCraftAttribute{
	var attributeName : name;		
	var valAdditive : float;		
	var valMultiplicative : float;	
	var displayPercMul : bool;		
	var displayPercAdd : bool;		
};


enum ECraftsmanLevel
{
	ECL_Undefined,
	ECL_Journeyman,
	ECL_Master,
	ECL_Grand_Master
}

function ParseCraftsmanTypeStringToEnum(s : string) : ECraftsmanType
{
	switch(s)
	{
		case "Crafter" 	: return ECT_Crafter;
		case "Smith" 	: return ECT_Smith;
		case "Armorer" 	: return ECT_Armorer;
		case "Armourer"	: return ECT_Armorer; 
		case "Enchanter": return ECT_Enchanter; 
	}

	return ECT_Undefined;
}

function ParseCraftsmanLevelStringToEnum(s : string) : ECraftsmanLevel
{
	switch(s)
	{
		case "Journeyman" : return ECL_Journeyman;
		case "Master" : return ECL_Master;
		case "Grand Master" : return ECL_Grand_Master;
	}
	
	return ECL_Undefined;
}

function CraftsmanTypeToLocalizationKey(type : ECraftsmanType) : string
{
	switch( type )
	{
		case ECT_Crafter : return "map_location_craftman";
		case ECT_Smith : return "map_location_blacksmith";
		case ECT_Armorer : return "Armorer";
		case ECT_Enchanter : return "map_location_alchemic";
		default: return "map_location_craftman";
	}
	return "map_location_craftman";
}

function CraftsmanLevelToLocalizationKey(type : ECraftsmanLevel) : string
{
	switch( type )
	{
		case ECL_Journeyman : return "panel_shop_crating_level_journeyman";
		case ECL_Master : return "panel_shop_crating_level_master";
		case ECL_Grand_Master: return "panel_shop_crating_level_grand_master";
		default: return "";
	}
	return "";
}


struct SCraftingSchematic
{
	var craftedItemName			: name;					
	var craftedItemCount 		: int;					
	var requiredCraftsmanType	: ECraftsmanType;		
	var requiredCraftsmanLevel	: ECraftsmanLevel;		
	var baseCraftingPrice		: int;					
	var ingredients				: array<SItemParts>;	
	var schemName				: name;					
};

struct SItemUpgradeListElement
{
	var itemId : SItemUniqueId;
	var upgrade : SItemUpgrade;
};

struct SItemUpgrade
{
	var upgradeName : name;						
	var localizedName : name;					
	var localizedDescriptionName : name;		
	var cost : int;								
	var iconPath : string;						
	var ability : name;							
	var ingredients : array<SItemParts>;		
	var requiredUpgrades : array<name>;			
};

enum EItemUpgradeException
{
	EIUE_NoException,
	EIUE_NotEnoughGold,
	EIUE_MissingIngredient,
	EIUE_NotEnoughIngredient,
	EIUE_MissingRequiredUpgrades,
	EIUE_AlreadyPurchased,
	EIUE_ItemNotUpgradeable,
	EIUE_NoSuchUpgradeForItem
}


function IsCraftingSchematic(recipeName : name) : bool
{
	var dm : CDefinitionsManagerAccessor;
	var main : SCustomNode;
	var schematicNode : SCustomNode;
	var i, tmpInt : int;
	var tmpName : name;

	if(!IsNameValid(recipeName))
		return false;

	dm = theGame.GetDefinitionsManager();
	if ( dm.GetSubNodeByAttributeValueAsCName( schematicNode, 'crafting_schematics', 'name_name', recipeName ) )
	{
		return true;
	}
	
	return false;
}