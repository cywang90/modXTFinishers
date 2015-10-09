/*
Copyright © CD Projekt RED 2015
*/




class CBTCondIsBeingHitByIgni extends IBehTreeTask
{	
	function IsAvailable() : bool
	{
		return GetNPC().IsBeingHitByIgni();
	}
};


class CBTCondIsBeingHitByIgniDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondIsBeingHitByIgni';
};


















