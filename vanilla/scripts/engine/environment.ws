﻿/*
Copyright © CD Projekt RED 2015
*/






import class CEnvironmentDefinition extends CResource {}



import function ActivateEnvironmentDefinition( environmentDefinition : CEnvironmentDefinition, priority : int, blendFactor : float, blendInTime : float ) : int;



import function DeactivateEnvironment( environmentID : int , blendOutTime : float );



import function ActivateQuestEnvironmentDefinition( environmentDefinition : CEnvironmentDefinition, priority : int, blendFactor : float, blendTime : float );







import function GetRainStrength() : float;
import function GetSnowStrength() : float;
import function IsSkyClear() : bool;
	
function AreaIsCold() : bool
{
	var l_currentArea  : EAreaName;		
	l_currentArea = theGame.GetCommonMapManager().GetCurrentArea();		
	if( l_currentArea == AN_Prologue_Village_Winter ||  l_currentArea == AN_Skellige_ArdSkellig ||  l_currentArea == AN_Island_of_Myst )
	{
		return true;
	}
	return false;
}


import function SetUnderWaterBrightness(val : float);

import function GetWeatherConditionName() : name;
import function RequestWeatherChangeTo( weatherName : name, blendTime : float ) : bool;
import function RequestRandomWeatherChange( blendTime : float ) : bool;

import function ForceFakeEnvTime( hour : float );
import function DisableFakeEnvTime();