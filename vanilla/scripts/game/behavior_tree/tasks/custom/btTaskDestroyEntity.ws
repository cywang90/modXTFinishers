/*
Copyright © CD Projekt RED 2015
*/

class CBTTaskDestroyEntity extends IBehTreeTask
{
	var entityTag : name;
	
	function OnActivate() : EBTNodeStatus
	{
		if( entityTag != '' )
		{
			FindAndDestoryEntity();
		}
		
		return BTNS_Active;
	}
	
	private function FindAndDestoryEntity()
	{
		var entity : CEntity; 

		entity = theGame.GetEntityByTag( entityTag );
			
		if( entity )
		{
			entity.Destroy();
		}
	}
};

class CBTTaskDestroyEntityDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskDestroyEntity';
	editable var entityTag : name;
};