﻿/*
Copyright © CD Projekt RED 2015
*/




class W3QuestCond_TutorialIsInitialized extends CQuestScriptedCondition
{
	function Evaluate() : bool
	{
		return theGame.GetTutorialSystem() && theGame.GetTutorialSystem().IsRunning();
	}
}