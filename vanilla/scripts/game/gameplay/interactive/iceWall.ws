﻿/*
Copyright © CD Projekt RED 2015
*/




class W3IceWall extends CGameplayEntity
{
	event OnFireHit(source : CGameplayEntity)
	{
		super.OnFireHit(source);
		
		
		PlayEffect('break_force');
	}
}