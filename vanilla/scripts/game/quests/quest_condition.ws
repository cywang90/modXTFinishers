﻿/*
Copyright © CD Projekt RED 2015
*/






import abstract class CQuestScriptedCondition extends IQuestCondition
{
	function Activate();
	function Deactivate();
	function Evaluate() : bool;
};