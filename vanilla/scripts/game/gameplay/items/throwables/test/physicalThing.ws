﻿class W3PhysicalThing extends CProjectileTrajectory
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
		this.ShootProjectileAtNode( 3.0f, 3.0f, /*1000.0f,*/ thePlayer);
	}


	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		var victim : CActor;
		
		if(collidingComponent)
			victim = (CActor)collidingComponent.GetEntity();
		
		// by default we dont collide with caster
		if( victim && victim != caster )
		{
			LogChannel( 'CustomCustom', " I collided :) " + victim );
		
			StopProjectile();
			
//			victim.TakeDamage( dmg, NULL, GetDamageType('W3NoneDamageType'), NULL, pos );
			
			Destroy();
		}
	}	

	event OnRangeReached()
	{
		Destroy();
	}
}