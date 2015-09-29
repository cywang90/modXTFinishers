/*
Copyright © CD Projekt RED 2015
*/

class W3VisualFx extends CEntity
{
	editable var effectName : name;
	editable var destroyEffectTime : float;
	
	private var timedFxDestroyName : name;			
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		if(IsNameValid(effectName))
			PlayEffect( effectName );
		
		if(destroyEffectTime > 0)
			AddTimer('TimerStopVisualFX', destroyEffectTime, false, , , true);
			
		super.OnSpawned( spawnData );
	}
	
	public function SetDestroyTime( time : float )
	{
		RemoveTimer('TimerStopVisualFX');
		RemoveTimer('DestroyVisualFX');
		
		destroyEffectTime = time;
		
		if(destroyEffectTime > 0)
			AddTimer('TimerStopVisualFX', destroyEffectTime, false, , , true);
	}
		
	public function DestroyOnFxEnd(fxName : name)
	{
		if(timedFxDestroyName == '')
		{
			timedFxDestroyName = fxName;
			AddTimer('TimerDestroyOnFxEnd', 0.2, true, , , true);
		}
	}
	
	timer function TimerDestroyOnFxEnd(dt : float, id : int)
	{
		if(!IsEffectActive(timedFxDestroyName))
			Destroy();
	}
	
	timer function TimerStopVisualFX( td : float , id : int)
	{
		FunctionStopVisualFX();		
	}
	
	protected function FunctionStopVisualFX()
	{
		StopEffect( effectName );
		AddTimer( 'DestroyVisualFX', 5.0, false, , , true );
	}
	
	timer function DestroyVisualFX( td : float , id : int)
	{
		Destroy();
	}
}