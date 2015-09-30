/*
Copyright © CD Projekt RED 2015
*/

statemachine class W3WitchesCage extends CEntity
{
	default autoState = 'TurnedOff';
}

state TurnedOff in W3WitchesCage
{
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		parent.ApplyAppearance("roots_off");
	}
}

state TurnedOn in W3WitchesCage
{
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		parent.ApplyAppearance("roots_on");
	}
}