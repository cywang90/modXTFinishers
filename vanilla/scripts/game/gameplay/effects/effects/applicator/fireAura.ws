﻿/*
Copyright © CD Projekt RED 2015
*/







class W3FireAura extends W3Effect_Aura
{
	default effectType = EET_FireAura;	
	
	protected function ApplySpawnsOn( entityGE : CGameplayEntity)
	{
		
		if( (CActor)entityGE )
			super.ApplySpawnsOn( entityGE );
		else
			entityGE.OnFireHit( GetCreator() );
	}
}