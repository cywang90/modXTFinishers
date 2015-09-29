﻿/*
Copyright © CD Projekt RED 2015
*/





enum ETutorialMessageType		
{
	ETMT_Undefined,
	ETMT_Hint,
	ETMT_Message
}


reward function TutorialLevelUp()
{
	var witcher : W3PlayerWitcher;
	
	witcher = GetWitcherPlayer();
	witcher.AddPoints(EExperiencePoint, 50, false);
	if(witcher.GetLevel() == FactsQuerySum('tutorial_starting_level'))
	{
		witcher.AddPoints(EExperiencePoint, witcher.GetMissingExpForNextLevel(), true);
	}
}

struct SUITutorial
{
	editable saved var menuName 							: name;
	editable saved var tutorialStateName 					: name;
	editable saved var triggerCondition 					: EUITutorialTriggerCondition;
	editable saved var requiredGameplayFactName 			: string;
	editable saved var requiredGameplayFactValueInt 		: int;
	editable saved var requiredGameplayFactComparator 	: ECompareOp;
	editable saved var priority							: int;				
	editable saved var abortOnMenuClose					: bool;
	editable saved var sourceName							: string;		
	
	hint priority = "Lesser values are MORE important";
};

enum EUITutorialTriggerCondition
{
	EUITTC_OnMenuOpen
	
	
}