﻿/*
Copyright © CD Projekt RED 2015
*/

class W3Effect_SlowdownFrost extends CBaseGameplayEffect
{
	private saved var slowdownCauserId : int;

	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	default effectType = EET_SlowdownFrost;
	default attributeName = 'slowdownFrost';
		
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		slowdownCauserId = target.SetAnimationSpeedMultiplier( 0.7 );		
	}
	
	event OnEffectRemoved()
	{
		target.ResetAnimationSpeedMultiplier(slowdownCauserId);
		super.OnEffectRemoved();			
	}
}