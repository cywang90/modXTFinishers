﻿/*
Copyright © CD Projekt RED 2015
*/





class W3SE_PlayEffectOnSwitch extends W3SwitchEvent
{
	editable var effectName : name;
	editable var play : bool;
	
	default play = true;
	
	hint effectName = "Effect name (defined in entity), use 'all' and play=no to stop all effects";
	hint play		= "if set to true then plays effect, else stops it";
	
	public function Perform( parnt : CEntity )
	{
		var sw : W3Switch;
		
		LogChannel('Switch',"W3SE_PlayEffectOnSwitch.Activate: called for switch <<"+sw.GetReadableName()+">>, effect <<"+effectName+">>, isPlay="+play);

		sw = ( W3Switch )parnt;
		if ( !sw )
		{
			return;
		}
		
		if ( play )
		{
			sw.PlayEffect( effectName );
		}
		else
		{
			if ( effectName == 'all' )
			{
				sw.StopAllEffects();
			}
			else
			{
				sw.StopEffect( effectName );
			}
		}
	}
}