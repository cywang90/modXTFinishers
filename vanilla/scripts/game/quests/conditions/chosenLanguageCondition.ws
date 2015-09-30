/*
Copyright © CD Projekt RED 2015
*/





class W3QuestCond_chosenLanguage extends CQuestScriptedCondition
{
	editable var chosenLanguage : string;

	function Evaluate() : bool
	{
		if( theGame.GetCurrentLocale() == chosenLanguage )
		{
			return true;
		}
		
		return false;
	}
}
