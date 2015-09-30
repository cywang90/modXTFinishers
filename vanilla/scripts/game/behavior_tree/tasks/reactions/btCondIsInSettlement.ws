﻿/*
Copyright © CD Projekt RED 2015
*/

class CBTCondIsInSettlement extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		return GetActor().TestIsInSettlement();
	}
	
	function OnActivate() : EBTNodeStatus
	{
		return BTNS_Active;
	}
}

class CBTCondIsInSettlementDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTCondIsInSettlement';
}
