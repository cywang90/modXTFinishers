/*
Copyright © CD Projekt RED 2015
*/




class W3QuestCond_PlayerLevel extends CQuestScriptedCondition
{
	editable var level : int;

	function Evaluate() : bool
	{
		var witcher : W3PlayerWitcher;
		
		if(level <= 0)
		{
			LogQuest("W3QuestCond_PlayerLevel: level must be at least 1, aborting");
			return false;
		}
		
		witcher = GetWitcherPlayer();
		if(!witcher)
		{
			return false;
		}
		
		if(level > witcher.levelManager.GetMaxLevel())
		{
			LogQuest("W3QuestCond_PlayerLevel: level cannot be higher than max possible character leve (" + witcher.levelManager.GetMaxLevel() + ")");
			return false;
		}
		
		return witcher.levelManager.GetLevel() >= level;
	}
}