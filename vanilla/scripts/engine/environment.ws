
/////////////////////////////////////////////
// Environment Manager
/////////////////////////////////////////////

import class CEnvironmentDefinition extends CResource {}

// Activate the passed environment definition with the passed priority, blend factor and time
// returns the definition's ID to use with DeactivateEnvironment or -1 if failed
import function ActivateEnvironmentDefinition( environmentDefinition : CEnvironmentDefinition, priority : int, blendFactor : float, blendInTime : float ) : int;

// Deactivate the environment with the given ID
// must be the same returned from ActivateEnvironmentDefinition
import function DeactivateEnvironment( environmentID : int , blendOutTime : float );

// (used by quest blocks) Deactivates the environment previously activated with
// this function and activates the passed one (can be NULL to deactivate only)
import function ActivateQuestEnvironmentDefinition( environmentDefinition : CEnvironmentDefinition, priority : int, blendFactor : float, blendTime : float );


/////////////////////////////////////////////
// Environment
/////////////////////////////////////////////

// Weather
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

//Sets under water/fog brightness level. Default is 0. Values <0 darken, >0 lighten.
import function SetUnderWaterBrightness(val : float);

import function GetWeatherConditionName() : name;
import function RequestWeatherChangeTo( weatherName : name, blendTime : float ) : bool;
import function RequestRandomWeatherChange( blendTime : float ) : bool;

import function ForceFakeEnvTime( hour : float );
import function DisableFakeEnvTime();