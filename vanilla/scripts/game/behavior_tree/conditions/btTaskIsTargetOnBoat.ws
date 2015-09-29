/*
Copyright © CD Projekt RED 2015
*/


class CBTCondIsTargetOnBoat extends IBehTreeTask
{
	
	function IsAvailable() : bool
	{
		if ( GetCombatTarget() == thePlayer && thePlayer.IsSailing() )
			return true;
			
		return false;
	}
};

class CBTCondIsTargetOnBoatDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondIsTargetOnBoat';
};