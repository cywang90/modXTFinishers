/*
Copyright © CD Projekt RED 2015
*/

class W3QuestCond_IsOnGround extends CQCActorScriptedCondition
{
	function Evaluate(act : CActor ) : bool
	{		
		return act.IsOnGround();
	}
}