﻿/*
Copyright © CD Projekt RED 2015
*/




class W3Dimeritium extends W3Petard
{
	editable var affectedFX : name;	
	private var disableTimerCalled : bool;
	
		hint affectedFX = "Additional FX that is added when there are affected targets in the area";
		
		default disableTimerCalled = false;

	protected function ProcessMechanicalEffect(targets : array<CGameplayEntity>, isImpact : bool, optional dt : float)
	{
		var i : int;
		var witcher : W3PlayerWitcher;
		var rift : CRiftEntity;
	
		super.ProcessMechanicalEffect(targets, isImpact, dt);
			
		
		witcher = GetWitcherPlayer();
		if(targets.Contains(witcher) && witcher.GetCurrentlyCastSign() == ST_Quen)
			witcher.CastSignAbort();
			
		
		
		
		
		for(i=0; i<targets.Size(); i+=1)
		{
			rift = (CRiftEntity)targets[i];
			if(rift)
			{	
				rift.PlayEffect( 'rift_dimeritium' );
				rift.DeactivateRiftIfPossible();
			}
		}
	}
	
	protected function LoopFunction(dt : float)
	{
		var skill : ESkill;
		var i, j : int;
		var blocked, isPlayer : bool;
		var actor : CActor;
		
		super.LoopFunction(dt);
		
		
		blocked = false;
		for(i=0; i<targetsSinceLastCheck.Size(); i+=1)
		{
			actor = (CActor)targetsSinceLastCheck[i];
			if(!actor)
				continue;
				
			if(actor == thePlayer)
				isPlayer = true;
			else
				isPlayer = false;
				
			for(j=0; j<loopParams.disabledAbilities.Size(); j+=1)
			{
				
				if(isPlayer)
					skill = SkillNameToEnum(loopParams.disabledAbilities[j].abilityName);
				else
					skill = S_SUndefined;
				
				
				if(skill != S_SUndefined)
					blocked = thePlayer.IsSkillBlocked(skill);
				else
					blocked = actor.IsAbilityBlocked(loopParams.disabledAbilities[j].abilityName);
					
				if(blocked)
					break;
			}
			
			if(blocked)
				break;
		}	
		
		
		if(blocked)
		{
			PlayEffectInternal(affectedFX);
			RemoveTimer('DisableAffectedFx');
			disableTimerCalled = false;
		}
		else if(!disableTimerCalled)
		{
			disableTimerCalled = true;
			AddTimer('DisableAffectedFx', 0.5);
		}
	}
	
	timer function DisableAffectedFx(dt : float, id : int)
	{
		StopEffect('activate');
	}
	
	
	protected function ProcessTargetOutOfArea(entity : CGameplayEntity)
	{
		var bombLevel, i : int;
		var duration : float;
		var target : CActor;
		var min, max : SAbilityAttributeValue;
		
		if(GetOwner() == thePlayer)
		{
			target = (CActor)entity;
			
			if(target && target.IsAlive())
			{
				theGame.GetDefinitionsManager().GetItemAttributeValueNoRandom(itemName, true, 'level', min, max);
				bombLevel = RoundMath(CalculateAttributeValue(min));
				
				
				if(GetAttitudeBetween(GetOwner(), target) == AIA_Friendly && !friendlyFire)
				{
					for(i=0; i<loopParams.disabledAbilities.Size(); i+=1)
					{
						BlockTargetsAbility(target, loopParams.disabledAbilities[i].abilityName, 0.f, true);
					}
				}
				
				else if(bombLevel == 3)
				{
					theGame.GetDefinitionsManager().GetItemAttributeValueNoRandom(itemName, true, 'duration_out_of_cloud', min, max);
					duration = CalculateAttributeValue(min);
					
					for(i=0; i<loopParams.disabledAbilities.Size(); i+=1)
					{
						target.BlockAbility(loopParams.disabledAbilities[i].abilityName, true, duration);
					}
				}					
			}
		}
	}
}