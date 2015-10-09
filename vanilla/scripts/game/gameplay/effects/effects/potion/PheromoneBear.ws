﻿/*
Copyright © CD Projekt RED 2015
*/











class  W3Potion_PheromoneBear extends W3Potion_Pheromone
{
	default effectType = EET_PheromoneBear;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		theGame.SetGlobalAttitude( 'AG_bear_berserker', 'player', AIA_Friendly );
		theGame.SetGlobalAttitude( 'q201_cage_bear', 'player', AIA_Friendly );
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		
		theGame.SetGlobalAttitude( 'AG_bear_berserker', 'player', AIA_Hostile );
		theGame.SetGlobalAttitude( 'q201_cage_bear', 'player', AIA_Hostile );
	}
}