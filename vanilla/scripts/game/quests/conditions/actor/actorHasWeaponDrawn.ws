/*
Copyright © CD Projekt RED 2015
*/




class W3QuestCond_HasWeaponDrawn extends CQCActorScriptedCondition
{
	editable var treatFistsAsWeapon : bool;
	
	default treatFistsAsWeapon = true;
	
	function Evaluate(act : CActor ) : bool
	{	
		return act.HasWeaponDrawn(treatFistsAsWeapon);
	}
}