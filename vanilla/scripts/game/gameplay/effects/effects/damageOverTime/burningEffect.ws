/*
Copyright © CD Projekt RED 2015
*/




class W3Effect_Burning extends W3CriticalDOTEffect
{
	private var cachedMPAC : CMovingPhysicalAgentComponent;

		default criticalStateType = ECST_BurnCritical;
		default effectType = EET_Burning;
		default powerStatType = CPS_SpellPower;
		default resistStat = CDS_BurningRes;
		default canBeAppliedOnDeadTarget = true;
	
	public function CacheSettings()
	{
		super.CacheSettings();
		
		allowedHits[EHRT_Igni] = false;
		
		
		blockedActions.PushBack(EIAB_CallHorse);
		blockedActions.PushBack(EIAB_Jump);
		blockedActions.PushBack(EIAB_ThrowBomb);			
		blockedActions.PushBack(EIAB_UsableItem);
		blockedActions.PushBack(EIAB_Parry);
		blockedActions.PushBack(EIAB_Counter);
		
		
		vibratePadLowFreq = 0.1;
		vibratePadHighFreq = 0.2;
	}
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		if ( this.IsOnPlayer() && thePlayer.IsUsingVehicle() )
		{
			if ( blockedActions.Contains( EIAB_Crossbow ) )
				blockedActions.Remove(EIAB_Crossbow);
		}
		else
			blockedActions.PushBack(EIAB_Crossbow);
	
		super.OnEffectAdded(customParams);
		cachedMPAC = ((CMovingPhysicalAgentComponent)target.GetMovingAgentComponent());
		
		if (isOnPlayer )
		{
			if ( thePlayer.playerAiming.GetCurrentStateName() == 'Waiting' )
				thePlayer.AddCustomOrientationTarget(OT_CustomHeading, 'BurningEffect');
		}
			
		
		if(!target.IsAlive())
			timeLeft = 10;
		
		
		if(EntityHandleGet(creatorHandle) == thePlayer && !isSignEffect)
			powerStatType = CPS_Undefined;
	}
	
	event OnEffectAddedPost()
	{
		super.OnEffectAddedPost();
		
		target.AddTag(theGame.params.TAG_OPEN_FIRE);
	}
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		super.OnLoad(t, eff);
		
		cachedMPAC = ((CMovingPhysicalAgentComponent)target.GetMovingAgentComponent());
	}
	
	event OnUpdate(deltaTime : float)
	{
		var player : CR4Player = thePlayer;	
	
		if ( this.isOnPlayer )
		{
			if ( player.bLAxisReleased )
				player.SetOrientationTargetCustomHeading( player.GetHeading(), 'BurningEffect' );
			else if ( player.GetPlayerCombatStance() == PCS_AlertNear )
				player.SetOrientationTargetCustomHeading( VecHeading( player.moveTarget.GetWorldPosition() - player.GetWorldPosition() ), 'BurningEffect' );
			else
				player.SetOrientationTargetCustomHeading( VecHeading( theCamera.GetCameraDirection() ), 'BurningEffect' );
		}
	
		
		if(cachedMPAC && cachedMPAC.GetSubmergeDepth() <= -1)
			target.RemoveAllBuffsOfType(effectType);
		else
			super.OnUpdate(deltaTime);
	}
	
	event OnEffectRemoved()
	{
		if ( isOnPlayer )	
			thePlayer.RemoveCustomOrientationTarget('BurningEffect');	
	
		target.RemoveTag(theGame.params.TAG_OPEN_FIRE);
		
		super.OnEffectRemoved();		
	}
	
	
	public function OnTargetDeath()
	{
		
		timeLeft = 10;
	}
	
	
	public function OnTargetDeathAnimFinished()
	{
		
		timeLeft = 10;
	}
}