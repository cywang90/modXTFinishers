/*
Copyright © CD Projekt RED 2015
*/





struct SCraftsman
{
	editable var type : ECraftsmanType;
	editable var level : ECraftsmanLevel;
	editable var noCraftingCost : Bool;
}

class W3CraftsmanComponent extends W3MerchantComponent
{
	editable var craftsmanData : array<SCraftsman>;
	var owner : W3MerchantNPC;

	public function GetCraftsmanLevel( type : ECraftsmanType ) : ECraftsmanLevel
	{
		var i, size : int;		
		
		size = craftsmanData.Size();

		for ( i = 0; i < size; i += 1 )
		{
			if ( craftsmanData[i].type == type )
			{
				return craftsmanData[i].level;
			}
			else if ( ECT_Crafter == type && ( craftsmanData[i].type == ECT_Smith || craftsmanData[i].type == ECT_Armorer ) )
			{
				return craftsmanData[i].level;
			}
		}
		return ECL_Undefined;
	}

	public function IsCraftsmanType( type : ECraftsmanType ) : bool
	{
		var i, size : int;		
		
		size = craftsmanData.Size();

		for ( i = 0; i < size; i += 1 )
		{
			if ( craftsmanData[i].type == type )
			{
				return true;
			}
			else if ( ECT_Crafter == type && ( craftsmanData[i].type == ECT_Smith || craftsmanData[i].type == ECT_Armorer ) )
			{
				return true;
			}
		}
	
		return false;
	}

	public function CalculateCostOfCrafting(basePrice : int) : int
	{
		var i, size : int;		

		if ( craftsmanData.Size() > 0 )
		{
			if ( true == craftsmanData[0].noCraftingCost )
			{
				return 0;
			}
		}

		return (int)(basePrice * 0.3f);
	}

	event OnComponentAttachFinished()
	{
		
		var crafterType : ECraftsmanType;
		var crafterLevel : ECraftsmanLevel;
		
		owner = (W3MerchantNPC) this.GetEntity();
		
		
		owner.RemoveTag( 'Blacksmith' );
		owner.RemoveTag( 'Armorer' );
		owner.RemoveTag( 'Apprentice' );
		owner.RemoveTag( 'Specialist' );
		owner.RemoveTag( 'Master' );
		
		if( owner )
		{
			if( IsCraftsmanType( ECT_Smith ) )
			{
				owner.AddTag( 'Blacksmith' );
				SetCrafterLevelTag( ECT_Smith );
			}
			
			if( IsCraftsmanType( ECT_Armorer ) )
			{
				owner.AddTag( 'Armorer' );
				SetCrafterLevelTag( ECT_Armorer );
			}
		}
		
	}
	
	function SetCrafterLevelTag( type : ECraftsmanType )
	{
		var level :  ECraftsmanLevel;
		
		level = GetCraftsmanLevel( type );
		
		switch( level )
		{
			case ECL_Journeyman:
				owner.AddTag('Apprentice');
			break;
			
			case ECL_Master:
				owner.AddTag('Specialist');
			break;
			
			case ECL_Grand_Master:
				owner.AddTag('Master');
			break;
		}
	}
	
}