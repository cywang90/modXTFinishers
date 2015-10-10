/***********************************************************************/
/** Copyright © 2014
/** Author : Tomek Kozera
/***********************************************************************/

class W3ExplosiveBolt extends W3BoltProjectile
{
	editable var explosionRange : float;
	private var insideToxicClouds : array<W3ToxicCloud>;
	
	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		var ents : array<CGameplayEntity>;
		var i : int;
		var waterZ : float;
		var victim, actor : CActor;
		
		//if bolt was shot underwater then ignore water collision
		if(wasShotUnderWater && hitCollisionsGroups.Contains( 'Water' ) )
			return true;
		
		victim = (CActor)collidingComponent.GetEntity();
		SetVictim( victim );
		
		if ( !CanCollideWithVictim( victim ) )
			return true;
		
		if ( !ProcessProjectileRepulsion( pos, normal ) )
		{			
			//underwater collisions
			if(wasShotUnderWater)
			{
				waterZ = theGame.GetWorld().GetWaterLevel(pos, true);
				if(waterZ >= pos.Z)
				{
					//if hit actor underwater, do normal hit (without explosion)
					if(victim)
					{
						super.OnProjectileCollision(pos, normal, collidingComponent, hitCollisionsGroups, actorIndex, shapeIndex);
					}
					else
					{
						StopProjectile();
						isActive = false;
						DestroyAfter(20);
					}
					
					return true;				//bolt was fired underwater and it collides underwater - no effect, just stick it for a while if not hit actor
				}
			}
			
			StopProjectile();
			isActive = false;
			
			//fx
			if ( hitCollisionsGroups.Contains( 'Water' ) && ! hitCollisionsGroups.Contains( 'Terrain' ) )
				PlayEffect('explode_water');
			else
				PlayEffect('explosion');
				
			//find targets in area
			pos.Z += 0.1f;
			FindGameplayEntitiesInSphere(ents, pos, explosionRange, 100000, , FLAG_TestLineOfSight);
			
			//pos is usually too low (under terrain) so we need to manually adjust it. Second test is if we hit ceiling, so then we need to make a test downwards
			if(ents.Size() == 0)
			{
				pos.Z -= 0.2f;
				FindGameplayEntitiesInSphere(ents, pos, explosionRange, 100000, , FLAG_TestLineOfSight);
			}
			
			//hit
			for(i=0; i<ents.Size(); i+=1)
			{
				if(ents[i] == this)
					continue;
				
				actor = (CActor)ents[i];
				if(actor && !actor.IsAlive())
					continue;
				
				super.ProcessDamageAction(ents[i], Vector(0,0,0), '');
			}
			
			//explosive gas
			for(i=0; i<insideToxicClouds.Size(); i+=1)
			{
				if(insideToxicClouds[i] && insideToxicClouds[i].GetCurrentStateName() == 'Armed')
				{
					((W3ToxicCloudStateArmed)(insideToxicClouds[i].GetCurrentState())).Explode(this);
				}
			}
			
			DestroyAfter(5);	//so fx finishes
		}
	}
	
	public final function AddToxicCloud(gas : W3ToxicCloud)
	{
		if(gas)
		{
			insideToxicClouds.PushBack(gas);
		}
	}
	public final function RemoveToxicCloud(gas : W3ToxicCloud)
	{
		if(gas)
		{
			insideToxicClouds.Remove(gas);
		}
	}
}