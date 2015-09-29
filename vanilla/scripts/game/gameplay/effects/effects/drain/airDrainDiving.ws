﻿/*
Copyright © CD Projekt RED 2015
*/





class W3Effect_AirDrainDive extends CBaseGameplayEffect
{
	private var effectValueMultInIdle 			: SAbilityAttributeValue;			
	private var effectValueMultWhileSprinting 	: SAbilityAttributeValue;			

	default effectType = EET_AirDrainDive;
	default attributeName = 'airDrain';
	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	
	event OnUpdate(deltaTime : float)
	{
		var drain : float;
		var statee : CR4PlayerStateSwimming;
		var val : SAbilityAttributeValue;
		
		super.OnUpdate(deltaTime);
			
		
		if ( isOnPlayer && !thePlayer.OnCheckDiving() )
		{
			isActive = false;
			return false;
		}
		
		if(target.GetStat(BCS_Air) <= 0)
		{
			if ( !target.HasBuff(EET_Drowning) )
				target.AddEffectDefault(EET_Drowning,target,"NoAir");
		}
		else
		{
			val = effectValue;
		
			
			drain = MaxF(0, deltaTime * ( val.valueAdditive + val.valueMultiplicative * target.GetStatMax(BCS_Air) ) );
			
			
			if ( isOnPlayer )
				statee = (CR4PlayerStateSwimming)thePlayer.GetCurrentState();
				
			if( statee )
			{
				
				if(statee.CheckIdle())
				{
					drain *= effectValueMultInIdle.valueAdditive;
				}
			}
			else
			{
				drain *= effectValueMultInIdle.valueAdditive;
			}
			
			effectManager.CacheStatUpdate(BCS_Air, -drain);
		}
	}
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var min, max : SAbilityAttributeValue;
		
		super.OnEffectAdded(customParams);
		
		if(!isOnPlayer)
		{
			isActive = false;
			return true;
		}
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'airDrainMultInIdle', min, max);
		effectValueMultInIdle = GetAttributeRandomizedValue(min, max);
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'airDrainMultWhileSprinting', min, max);
		effectValueMultWhileSprinting = GetAttributeRandomizedValue(min, max);
		
		target.PauseEffects(EET_AutoAirRegen, 'AirDrainDiving');
	}
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		var min, max : SAbilityAttributeValue;
		
		super.OnLoad(t, eff);
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'airDrainMultInIdle', min, max);
		effectValueMultInIdle = GetAttributeRandomizedValue(min, max);
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'airDrainMultWhileSprinting', min, max);
		effectValueMultWhileSprinting = GetAttributeRandomizedValue(min, max);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		
		target.ResumeEffects(EET_AutoAirRegen, 'AirDrainDiving');
	}
	
	protected function CalculateDuration(optional setInitialDuration : bool)
	{
		super.CalculateDuration(setInitialDuration);
		
		duration = -1;
	}
}