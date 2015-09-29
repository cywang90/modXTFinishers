/*
Copyright © CD Projekt RED 2015
*/





class W3Effect_WellFed extends W3RegenEffect
{
	private var level : int;

	default effectType = EET_WellFed;
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	protected function GetSelfInteraction( e : CBaseGameplayEffect) : EEffectInteract
	{
		var eff : W3Effect_WellFed;
		
		eff = (W3Effect_WellFed)e;
		if(eff.level >= level)
			return EI_Cumulate;		
		else
			return EI_Deny;
	}
	
	public function CacheSettings()
	{
		var i : int;
		var dm : CDefinitionsManagerAccessor;
		var main : SCustomNode;
		var tmpName, customAbilityName : name;
		var type : EEffectType;		
	
		super.CacheSettings();
		
		dm = theGame.GetDefinitionsManager();
		main = dm.GetCustomDefinition('effects');
		
		for(i=0; i<main.subNodes.Size(); i+=1)
		{
			dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'name_name', tmpName);
			EffectNameToType(tmpName, type, customAbilityName);
			if(effectType == type)
			{
				if(!dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'level', level))
					level = 0;
					
				break;
			}
		}
	}
}