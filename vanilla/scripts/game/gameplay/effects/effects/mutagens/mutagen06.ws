/*
Copyright © CD Projekt RED 2015
*/




class W3Mutagen06_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen06;
	default dontAddAbilityOnTarget = true;
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		
		target.RemoveAbilityAll(abilityName);
	}
}