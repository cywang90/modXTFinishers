/*
Copyright © CD Projekt RED 2015
*/






class CBTTaskManageBuffImmunity extends IBehTreeTask
{
	var effects 		: array<EEffectType>;
	var onActivate 		: bool;
	var onDeactivate 	: bool;
	var bRemove			: bool;
	
	function IsAvailable() : bool
	{
		return true;
	}

	function OnActivate() : EBTNodeStatus
	{
		var npc		: CActor = GetActor();
		var i		: int;
		
		if( onActivate )
		{
			for ( i = 0; i < effects.Size(); i += 1 )
			{
				if( bRemove )
				{
					npc.RemoveBuffImmunity( effects[i], 'CBTTaskManageBuffImmunity' );
				}
				else
				{
					npc.AddBuffImmunity( effects[i], 'CBTTaskManageBuffImmunity', true );
				}
			}
		}

		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		var npc		: CActor = GetActor();
		var i		: int;
		
		if( onDeactivate )
		{
			for ( i = 0; i < effects.Size(); i += 1 )
			{
				if( bRemove )
				{
					npc.RemoveBuffImmunity( effects[i], 'CBTTaskManageBuffImmunity' );
				}
				else
				{
					npc.AddBuffImmunity( effects[i], 'CBTTaskManageBuffImmunity', true );
				}
			}
		}
	}
}

class CBTTaskManageBuffImmunityDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskManageBuffImmunity';

	editable var effects 			: array<EEffectType>;
	editable var onActivate 		: bool;
	editable var onDeactivate 		: bool;
	editable var bRemove			: bool;
	
	default onActivate = true;
	
	hint bRemove = "false - adding immunities, true - removing immunities";
}
