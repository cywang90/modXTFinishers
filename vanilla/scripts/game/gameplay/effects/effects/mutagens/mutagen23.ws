﻿/*
Copyright © CD Projekt RED 2015
*/





class W3Mutagen23_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen23;
	default dontAddAbilityOnTarget = true;
	
	event OnUpdate(dt : float)
	{
		var currentHour, currentMinutes, i : int;
		var gameTime : GameTime;
		var params : SCustomEffectParams;
		var shrineBuffs : array<EEffectType>;
		var addBuff : bool;
		var shrineParams : W3ShrineEffectParams;
		
		super.OnUpdate(dt);
		
		if(effectManager.HasAnyMutagen23ShrineBuff())
			return true;
		
		gameTime = theGame.GetGameTime();
		currentHour = GameTimeHours(gameTime);
		currentMinutes = GameTimeMinutes(gameTime);	

		if( (currentHour == GetHourForDayPart(EDP_Dawn) && currentMinutes < 15) || ( (currentHour == (GetHourForDayPart(EDP_Dawn) - 1)) && currentMinutes > 45) )
		{
			addBuff = true;
		}
		else
		{
			if( (currentHour == GetHourForDayPart(EDP_Dusk) && currentMinutes < 15) || ( ( currentHour == (GetHourForDayPart(EDP_Dusk) - 1)) && currentMinutes > 45) )
				addBuff = true;
			else
				addBuff = false;
		}
		
		if(addBuff)
		{			
			shrineBuffs = GetMinorShrineBuffs();
			
			
			for(i=shrineBuffs.Size()-1; i>=0; i-=1)
			{
				if(target.HasBuff(shrineBuffs[i]))
					shrineBuffs.Erase(i);
			}
			
			
			if(shrineBuffs.Size() == 0)
				shrineBuffs = GetMinorShrineBuffs();
			
			params.effectType = shrineBuffs[ RandRange(shrineBuffs.Size()) ];
			params.sourceName = 'Mutagen23';
			params.duration = ConvertGameSecondsToRealTimeSeconds(60 * 60 * 6);
			shrineParams = new W3ShrineEffectParams in theGame;
			shrineParams.isFromMutagen23 = true;
			params.buffSpecificParams = shrineParams;
			
			target.AddEffectCustom(params);
			
			delete shrineParams;
		}
	}
}