﻿/*
Copyright © CD Projekt RED 2015
*/

class W3Rat extends CNewNPC
{
	editable saved var hasCollision : bool; default hasCollision = false;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{		
		super.OnSpawned( spawnData );
		SetInteractionPriority(IP_Prio_0);
		EnableCharacterCollisions(hasCollision);
	}
	
	
	
	event OnChangeDyingInteractionPriorityIfNeeded()
	{
		this.EnableCollisions(false);
	}
}