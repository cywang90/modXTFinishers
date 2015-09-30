﻿/*
Copyright © CD Projekt RED 2015
*/




class W3Mutagen14_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen14;
	default dontAddAbilityOnTarget = true;

	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		if(target.IsInCombat())
			target.AddTimer('Mutagen14Timer', 2, true);
	}

	event OnEffectRemoved()
	{
		GetWitcherPlayer().RemoveTimer('Mutagen14Timer');
		
		super.OnEffectRemoved();
	}
}