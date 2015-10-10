/***********************************************************************/
/** Copyright © 2012
/** Author : Tomasz Kozera
/***********************************************************************/

// Exceptions that may occur during cooking process
enum EAlchemyExceptions
{
	EAE_NoException,	
	EAE_MissingIngredient,
	EAE_NotEnoughIngredients,	
	EAE_NoRecipe,
	EAE_CannotCookMore,
	EAE_CookNotAllowed,
	EAE_InCombat,
	EAE_Mounted
}

// Struct representing alchemy recipe
struct SAlchemyRecipe
{
	var cookedItemName : name;							//name of the item that will be cooked
	var cookedItemType : EAlchemyCookedItemType;		//type of cooked item
	var cookedItemIconPath : string;
	var cookedItemQuantity : int;						//how many items are cooked at once
	var recipeName : name;								//name of the recipe
	var recipeIconPath : string;
	var typeName : name;								//type of recipe, needed for levels
	var level : int;									//recipe level
	var requiredIngredients : array<SItemParts>;		//(fixed) ingredients required or empty if nothing required
};

enum EAlchemyCookedItemType // #B remove substance add mutagen
{
	EACIT_Undefined,
	EACIT_Potion,
	EACIT_Bomb,
	EACIT_Oil,
EACIT_Substance,		//not used anymore
	EACIT_Bolt,
	EACIT_MutagenPotion,
	EACIT_Alcohol,
	EACIT_Quest
}

struct SCookable
{
	var type : EAlchemyCookedItemType;
	var cnt : int;
};

function AlchemyCookedItemTypeStringToEnum(nam : string) : EAlchemyCookedItemType
{
	switch(nam)
	{
		case "potion" 			: return EACIT_Potion;
		case "petard"   		: return EACIT_Bomb;
		case "oil"    			: return EACIT_Oil;
		case "Substance" 		: return EACIT_Substance;
		case "bolt"				: return EACIT_Bolt;
		case "mutagen_potion" 	: return EACIT_MutagenPotion;
		case "alcohol"			: return EACIT_Alcohol;
		case "quest"			: return EACIT_Quest;
		default	     			: return EACIT_Undefined;
	}
}

function AlchemyCookedItemTypeEnumToName( type : EAlchemyCookedItemType) : name
{
	switch (type)
	{
		case EACIT_Potion			: return 'potion';
		case EACIT_Bomb				: return 'petard';
		case EACIT_Oil				: return 'oil';
		case EACIT_Substance		: return 'Substance';
		case EACIT_Bolt				: return 'bolt';
		case EACIT_MutagenPotion 	: return 'mutagen_potion';
		case EACIT_Alcohol 			: return 'alcohol';
		case EACIT_Quest			: return 'quest';
		default	     				: return '___'; // #B they are needed ?
	}
}

function AlchemyCookedItemTypeToLocKey( type : EAlchemyCookedItemType ) : string
{
	switch (type)
	{
		case EACIT_Potion			: return "panel_alchemy_tab_potions";
		case EACIT_Bomb				: return "panel_alchemy_tab_bombs";
		case EACIT_Oil				: return "panel_alchemy_tab_oils";
		case EACIT_Substance		: return "item_category_Substance";
		case EACIT_Bolt				: return "item_category_bolt";
		case EACIT_MutagenPotion 	: return "panel_inventory_filter_type_decoctions";
		case EACIT_Alcohol 			: return "panel_inventory_filter_type_alcohols";
		case EACIT_Quest 			: return "panel_button_worldmap_showquests";
		default	     				: return "";
	}
}

function AlchemyExceptionToString( result : EAlchemyExceptions ) : string
{
	switch ( result )
	{
		case EAE_NoException:			return "panel_alchemy_exception_item_cooked";
		case EAE_MissingIngredient:		return "panel_alchemy_exception_missing_ingridient";
		case EAE_NotEnoughIngredients:	return "panel_alchemy_exception_missing_ingridients";
		case EAE_NoRecipe:				return "panel_alchemy_exception_no_recipie";
		case EAE_CannotCookMore:		return "panel_alchemy_exception_already_cooked";	
		case EAE_CookNotAllowed:		return "panel_alchemy_exception_cook_not_allowed";
		case EAE_InCombat:				return "panel_hud_message_actionnotallowed_combat";
		case EAE_Mounted:				return "menu_cannot_perform_action_now";
	}
	return "";
}

function IsAlchemyRecipe(recipeName : name) : bool
{
	var dm : CDefinitionsManagerAccessor;
	var main : SCustomNode;
	var recipeNode : SCustomNode;
	var i, tmpInt : int;
	var tmpName : name;

	if(!IsNameValid(recipeName))
		return false;

	dm = theGame.GetDefinitionsManager();
	if ( dm.GetSubNodeByAttributeValueAsCName( recipeNode, 'alchemy_recipes', 'name_name', recipeName ) )
	{
		return true;
	}
	
	return false;
}