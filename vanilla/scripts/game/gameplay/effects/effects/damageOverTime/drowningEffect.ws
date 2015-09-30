﻿/*
Copyright © CD Projekt RED 2015
*/




class W3Effect_Drowning extends W3DamageOverTimeEffect
{
	var m_NoSaveLockInt : int;
	
	default effectType = EET_Drowning;
	default resistStat = CDS_None;
	
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		target.PlayEffectSingle('underwater_drowning');
		target.PauseHPRegenEffects('drowning');
		theGame.CreateNoSaveLock( "player_drowning", m_NoSaveLockInt );
	}
	
	event OnUpdate(dt : float)
	{
		super.OnUpdate(dt);
		
		
		if( target.GetStat(BCS_Air) > 0 || ( isOnPlayer && !thePlayer.OnCheckDiving() ) )
		{
			isActive = false;
			return false;
		}
	}
	
	event OnEffectRemoved()
	{
		target.StopEffect('underwater_drowning');
		super.OnEffectRemoved();
		target.ResumeHPRegenEffects('drowning');
		theGame.ReleaseNoSaveLock( m_NoSaveLockInt );
	}
	
	protected function CalculateDuration(optional setInitialDuration : bool)
	{
		super.CalculateDuration(setInitialDuration);
		
		duration = -1;
	}
}
