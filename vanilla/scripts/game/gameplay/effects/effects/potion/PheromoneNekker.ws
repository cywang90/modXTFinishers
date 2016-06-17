﻿/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/










class  W3Potion_PheromoneNekker extends W3Potion_Pheromone
{
	default effectType = EET_PheromoneNekker;

	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		theGame.SetGlobalAttitude( 'AG_nekker', 'player', AIA_Friendly );
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		theGame.SetGlobalAttitude( 'AG_nekker', 'player', AIA_Hostile );
	}
}