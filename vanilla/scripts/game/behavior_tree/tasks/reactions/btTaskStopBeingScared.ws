/*
Copyright © CD Projekt RED 2015
*/

class CBTTaskStopBeingScared extends IBehTreeTask
{
	function OnDeactivate()
	{
		GetNPC().SignalGameplayEvent('AI_StopBeingScared');
	}
}

class CBTTaskStopBeingScaredDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTTaskStopBeingScared';
}