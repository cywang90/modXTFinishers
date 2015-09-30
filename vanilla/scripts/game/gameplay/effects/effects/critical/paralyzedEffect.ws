﻿/*
Copyright © CD Projekt RED 2015
*/




class W3Effect_Paralyzed extends W3ImmobilizeEffect
{
	default effectType = EET_Paralyzed;
	default resistStat = CDS_ShockRes;
	default criticalStateType = ECST_Paralyzed;
	default isDestroyedOnInterrupt = true;
}