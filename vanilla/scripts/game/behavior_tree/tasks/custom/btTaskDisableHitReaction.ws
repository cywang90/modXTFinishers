/*
Copyright © CD Projekt RED 2015
*/





class CBTTaskDisableHitReaction extends IBehTreeTask
{
	var onActivate 				: bool;
	var onDeactivate 			: bool;
	var overrideForThisTask 	: bool;
	
	function OnActivate() : EBTNodeStatus
	{
		if ( overrideForThisTask || onActivate )
			GetNPC().SetCanPlayHitAnim( false );
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if ( overrideForThisTask )
			GetNPC().SetCanPlayHitAnim( true );
		else if ( onDeactivate )
			GetNPC().SetCanPlayHitAnim( false );
	}
};

class CBTTaskDisableHitReactionDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskDisableHitReaction';

	editable var onActivate 			: bool;
	editable var onDeactivate 			: bool;
	editable var overrideForThisTask 	: bool;
	
	default overrideForThisTask = true;
};


class CBTTaskSetUnstoppable extends IBehTreeTask
{
	var onActivate 				: bool;
	var onDeactivate 			: bool;
	var overrideForThisTask 	: bool;
	var makeUnpushable			: bool;
	
	var m_savedPriority			: EInteractionPriority;
	
	function OnActivate() : EBTNodeStatus
	{
		
		if ( onActivate || overrideForThisTask )
		{
			GetNPC().SetUnstoppable( true );
			if( makeUnpushable )
			{
				m_savedPriority  = GetNPC().GetInteractionPriority();
				GetNPC().SetInteractionPriority( IP_Max_Unpushable );
			}
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if ( overrideForThisTask )
		{
			GetNPC().SetUnstoppable( false );
			if( makeUnpushable )
			{
				GetNPC().SetInteractionPriority( m_savedPriority );
			}
		}
		else if ( onDeactivate )
		{
			GetNPC().SetUnstoppable( true );
		}
	}
};

class CBTTaskSetUnstoppableDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskSetUnstoppable';

	editable var onActivate 			: bool;
	editable var onDeactivate 			: bool;
	editable var overrideForThisTask 	: bool;
	editable var makeUnpushable			: bool;
	
	hint makeUnpushable = "increase interaction priority to make the npc unpushable";
	
	default overrideForThisTask = true;
};
