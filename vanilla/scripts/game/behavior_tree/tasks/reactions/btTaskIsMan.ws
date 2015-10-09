/*
Copyright © CD Projekt RED 2015
*/
class CBTCondIsMan extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		if ( GetActor().IsMan() )
			return true;
		
		return false;
	}
}

class CBTCondIsManDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTCondIsMan';
};