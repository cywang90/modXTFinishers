﻿/*
Copyright © CD Projekt RED 2015
*/





state CombatSilver in W3PlayerWitcher extends CombatSword
{	
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		parent.OnEquipMeleeWeapon( PW_Silver, true );
		
		this.CombatSilverInit( prevStateName );
	}
	
	
	event OnLeaveState( nextStateName : name )
	{ 
		
		this.CombatSilverDone( nextStateName );
		
		
		super.OnLeaveState(nextStateName);
	}
	
	public function GetSwordType() : name
	{ 
		return 'silversword';
	}

	
	entry function CombatSilverInit( prevStateName : name )
	{
		parent.OnEquipMeleeWeapon( PW_Silver, false );
		
		parent.SetBIsCombatActionAllowed( true );
		
		
		BuildComboPlayer();
		
		super.ProcessStartupAction( startupAction );		
		
		CombatSilverLoop();
	}

	
	entry function CombatSilverDone( nextStateName : name )
	{
		if ( nextStateName != 'AimThrow' && nextStateName != 'CombatSteel' && nextStateName != 'CombatFists' )
			parent.SetBehaviorVariable( 'playerCombatStance', (float)( (int)PCS_Normal ) );
	}

	
	private latent function CombatSilverLoop()
	{
		while( true )
		{
			Sleep( 0.5 );
		}
		
	}	
}