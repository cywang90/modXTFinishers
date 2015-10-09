﻿/*
Copyright © CD Projekt RED 2015
*/




class W3QuestCond_UIAnyMenuOpened extends CQuestScriptedCondition
{
	editable var inverted : bool;

	public function Evaluate() : bool
	{
		var anyMenu : bool;
		
		anyMenu = theGame.GetGuiManager().IsAnyMenu();
		
		if(inverted)
			return !anyMenu;
			
		return anyMenu;
	}
}