﻿/*
Copyright © CD Projekt RED 2015
*/











class BTCondIsPackLeader extends IBehTreeTask
{
	
	
	
	
	
	
	function IsAvailable() : bool
	{
		if ( GetNPC().isPackLeader )
			return true;
		else 
			return false;
	}

}



class BTCondIsPackLeaderDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondIsPackLeader';	
}