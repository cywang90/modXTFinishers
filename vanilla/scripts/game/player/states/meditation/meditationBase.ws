﻿/*
Copyright © CD Projekt RED 2015
*/





abstract state MeditationBase in W3PlayerWitcher extends ExtendedMovable
{
	event OnGameCameraTick( out moveData : SCameraMovementData, dt : float )
	{
		DampVectorSpring( moveData.cameraLocalSpaceOffset, moveData.cameraLocalSpaceOffsetVel, Vector( -1.5, 0.f, 0.f ), 0.5f, dt );

		return true;
	}
	
	
	public function StopRequested(optional closeUI : bool);
	
	event OnReactToBeingHit( damageAction : W3DamageAction )
	{
		var ret : bool;
		var tox : W3Effect_Toxicity;
		
		ret = virtual_parent.OnReactToBeingHit(damageAction);
		
		
		tox = (W3Effect_Toxicity)damageAction.causer;
		if(!tox)		
			StopRequested(true);
			
		return ret;
	}
}