﻿/*
Copyright © CD Projekt RED 2015
*/

class W3MagicalThing extends CProjectileTrajectory
{
	private var dmg : float;

	function ExtInit( caster : CActor, damage : float )
	{
		Init(caster);
		
		dmg = -damage;
	}
	
	function ThrowAt( target : CActor )
	{
		this.ShootProjectileAtNode( 3.0f, 3.0f,  thePlayer);
		PlayEffect( 'concentration' );
	}


	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		var victim : CActor;
		
		if(collidingComponent)
			victim = (CActor)collidingComponent.GetEntity();
		
		
		if( victim && victim != caster )
		{
			LogChannel( 'CustomCustom', " I collided :) " + victim );
		
			StopProjectile();
			

			
			StopAllEffects();
			
			Destroy();
		}
	}	

	event OnRangeReached()
	{
		Destroy();
	}
}