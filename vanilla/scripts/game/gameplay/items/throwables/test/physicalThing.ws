﻿/*
Copyright © CD Projekt RED 2015
*/

class W3PhysicalThing extends CProjectileTrajectory
{
	private var dmg : float;
	private var big : bool;

	function ExtInit( caster : CActor, damage : float)
	{
		Init(caster);
		
		dmg = damage;
	}
	
	function ThrowAt( target : CActor )
	{
		this.ShootProjectileAtNode( 3.0f, 3.0f,  thePlayer);
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
			

			
			Destroy();
		}
	}	

	event OnRangeReached()
	{
		Destroy();
	}
}