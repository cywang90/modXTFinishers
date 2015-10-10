//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class W3AardProjectile extends W3SignProjectile
{
	protected var staminaDrainPerc : float;
	
	protected function ProcessCollision( collider : CGameplayEntity, pos, normal : Vector )
	{
		var dmgVal : float;
		var sp : SAbilityAttributeValue;
	
		if ( hitEntities.FindFirst( collider ) != -1 )
		{
			return;
		}
		hitEntities.PushBack( collider );
	
		super.ProcessCollision( collider, pos, normal );
		
		action.SetHitAnimationPlayType(EAHA_ForceNo);
		action.SetProcessBuffsIfNoDamage(true);
		
		//add skill bonus damage
		if ( owner.CanUseSkill(S_Magic_s06) )
		{			
			dmgVal = GetWitcherPlayer().GetSkillLevel(S_Magic_s06) * CalculateAttributeValue( owner.GetSkillAttributeValue( S_Magic_s06, theGame.params.DAMAGE_NAME_FORCE, false, true ) );
			action.AddDamage( theGame.params.DAMAGE_NAME_FORCE, dmgVal );
		}
		
		//HAXXOR
		if ( !owner.IsPlayer() )
		{
			action.AddEffectInfo( EET_KnockdownTypeApplicator );
		}
		
		//action.SetHitEffect('aard_hit', false, false);
		//action.SetHitEffect('aard_hit_back', true, false);
		//action.SetHitEffect('aard_hit_parried', false, true);
		//action.SetHitEffect('aard_hit_back_parried', true, true);
		
		theGame.damageMgr.ProcessAction( action );
		
		collider.OnAardHit( this );		
	}
	
	event OnAttackRangeHit( entity : CGameplayEntity )
	{
		entity.OnAardHit( this );
	}
	
	public final function GetStaminaDrainPerc() : float
	{
		return staminaDrainPerc;
	}
	
	public final function SetStaminaDrainPerc(p : float)
	{
		staminaDrainPerc = p;
	}
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class W3AxiiProjectile extends W3SignProjectile
{
	protected function ProcessCollision( collider : CGameplayEntity, pos, normal : Vector )
	{
		DestroyAfter( 3.f );
		
		collider.OnAxiiHit( this );	
		//Destroy();
	}
	
	protected function ShouldCheckAttitude() : bool
	{
		return false;
	}
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class W3IgniProjectile extends W3SignProjectile
{
	private var channelCollided : bool;
	private var dt : float;	
	private var isUsed : bool;
	
	default channelCollided = false;
	default isUsed = false;
	
	public function SetDT(d : float)
	{
		dt = d;
	}

	public function IsUsed() : bool
	{
		return isUsed;
	}

	public function SetIsUsed( used : bool )
	{
		isUsed = used;
	}

	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		var rot, rotImp : EulerAngles;
		var v, posF, pos2, n : Vector;
		var igniEntity : W3IgniEntity;
		var ent, colEnt : CEntity;
		var template : CEntityTemplate;
		var f : float;
		var test : bool;
		var postEffect : CGameplayFXSurfacePost;
		
		channelCollided = true;
		
		//show collision fx at the place of impact
		igniEntity = (W3IgniEntity)signEntity;
		
		if(signEntity.IsAlternateCast())
		{			
			//igni burn fx left on objects and terrain
			test = (!collidingComponent && hitCollisionsGroups.Contains( 'Terrain' ) ) || (collidingComponent && !((CActor)collidingComponent.GetEntity()));
			
			colEnt = collidingComponent.GetEntity();
			if( (W3BoltProjectile)colEnt || (W3SignEntity)colEnt || (W3SignProjectile)colEnt )
				test = false;
			
			if(test)
			{
				f = theGame.GetEngineTimeAsSeconds();
				
				if(f - igniEntity.lastFxSpawnTime >= 1)
				{
					igniEntity.lastFxSpawnTime = f;
					
					template = (CEntityTemplate)LoadResource( "igni_object_fx" );
					
					//set rotation to normal of terrain
					rot.Pitch	= AcosF( VecDot( Vector( 0, 0, 0 ), normal ) );
					rot.Yaw		= this.GetHeading();
					rot.Roll	= 0.0f;
					
					//trace
					posF = pos + VecNormalize(pos - signEntity.GetWorldPosition());
					if(theGame.GetWorld().StaticTrace(pos, posF, pos2, n, igniEntity.projectileCollision))
					{					
						ent = theGame.CreateEntity(template, pos2, rot );
						ent.AddTimer('TimerStopVisualFX', 5, , , , true);
						
						postEffect = theGame.GetSurfacePostFX();
						postEffect.AddSurfacePostFXGroup( pos2, 0.5f, 8.0f, 10.0f, 0.3f, 1 );
					}
				}				
			}
			
			//collision fx
			if ( !hitCollisionsGroups.Contains( 'Water' ) )
			{
				//show collision fx at the place of impact
				v = GetWorldPosition() - signEntity.GetWorldPosition();
				rot = MatrixGetRotation(MatrixBuildFromDirectionVector(-v));
				
				igniEntity.ShowChannelingCollisionFx(GetWorldPosition(), rot, -v);
			}
		}
		
		return super.OnProjectileCollision(pos, normal, collidingComponent, hitCollisionsGroups, actorIndex, shapeIndex);
	}

	protected function ProcessCollision( collider : CGameplayEntity, pos, normal : Vector )
	{
		var signPower, channelDmg : SAbilityAttributeValue;
		var burnChance : float;					// chance to apply burn effect (NPC only)
		var maxArmorReduction : float;			// by how much the armor can be reduced
		var applyNbr : int;						// how many times base armor reduction has to be applied
		var i : int;
		var npc : CNewNPC;
		var armorRedAblName : name;
		var currentReduction : int;
		var actorVictim : CActor;
		var ownerActor : CActor;
		var dmg : float;
		var performBurningTest : bool;
		var igniEntity : W3IgniEntity;
		var postEffect : CGameplayFXSurfacePost = theGame.GetSurfacePostFX();
		
		postEffect.AddSurfacePostFXGroup( pos, 0.5f, 8.0f, 10.0f, 2.5f, 1 );
		
		// this condition prevents from hitting actor twice by the same projectile
		if ( hitEntities.Contains( collider ) )
		{
			return;
		}
		hitEntities.PushBack( collider );		
		
		super.ProcessCollision( collider, pos, normal );	
			
		ownerActor = owner.GetActor();
		actorVictim = ( CActor ) action.victim;
		npc = (CNewNPC)collider;
				
		//igni burning
		if(signEntity.IsAlternateCast())		
		{
			igniEntity = (W3IgniEntity)signEntity;
			performBurningTest = igniEntity.UpdateBurningChance(actorVictim, dt);
			
			// if target was already hit then skip initial damage, also skip the hit particle
			// this condition prevents from hitting actor twice by the the whole igni entity
			if( igniEntity.hitEntities.Contains( collider ) )
			{
				channelCollided = true;
				action.SetHitEffect('');
				action.SetHitEffect('', true );
				action.SetHitEffect('', false, true);
				action.SetHitEffect('', true, true);
				action.ClearDamage();
				
				//add channeling damage
				channelDmg = owner.GetSkillAttributeValue(signSkill, 'channeling_damage', false, true);
				dmg = channelDmg.valueAdditive + channelDmg.valueMultiplicative * actorVictim.GetMaxHealth();
				dmg *= dt;
				action.AddDamage(theGame.params.DAMAGE_NAME_FIRE, dmg);
				action.SetIsDoTDamage(dt);
				
				if(!collider)	//if no target (just showing impact fx) then exit
					return;
			}
			else
			{
				igniEntity.hitEntities.PushBack( collider );
			}
			
			if(!performBurningTest)
			{
				action.ClearEffects();
			}
		}
		
		//if npc is shielded do not take any dmg
		if ( npc && npc.IsShielded( ownerActor ) )
		{
			collider.OnIgniHit( this );	
			return;
		}
		
		// Claculate sign spellpower, taking target resistances into consideration
		signPower = signEntity.GetOwner().GetTotalSignSpellPower(signEntity.GetSkill());

		// a piece of custom code for calculating burning effect
		if ( !owner.IsPlayer() )
		{
			//NPCs
			burnChance = signPower.valueMultiplicative;
			if ( RandF() < burnChance )
			{
				action.AddEffectInfo(EET_Burning);
			}
			
			dmg = CalculateAttributeValue(signPower);
			if ( dmg <= 0 )
			{
				dmg = 20;
			}			
			action.AddDamage( theGame.params.DAMAGE_NAME_FIRE, dmg);
		}
		
		if(signEntity.IsAlternateCast())
		{
			action.SetHitAnimationPlayType(EAHA_ForceNo);
		}
		else		
		{
			action.SetHitEffect('igni_cone_hit', false, false);
			action.SetHitEffect('igni_cone_hit', true, false);
			action.SetHitReactionType(EHRT_Igni, false);
		}
		
		theGame.damageMgr.ProcessAction( action );	
		
		// Melt armor
		if ( owner.CanUseSkill(S_Magic_s08) && (CActor)collider)
		{	
			maxArmorReduction = CalculateAttributeValue(owner.GetSkillAttributeValue(S_Magic_s08, 'max_armor_reduction', false, true)) * GetWitcherPlayer().GetSkillLevel(S_Magic_s08);
			applyNbr = RoundMath( 100 * maxArmorReduction * ( signPower.valueMultiplicative / theGame.params.MAX_SPELLPOWER_ASSUMED ) );
			
			armorRedAblName = SkillEnumToName(S_Magic_s08);
			currentReduction = ((CActor)collider).GetAbilityCount(armorRedAblName);
			
			applyNbr -= currentReduction;
			
			for ( i = 0; i < applyNbr; i += 1 )
				action.victim.AddAbility(armorRedAblName, true);
		}	
		collider.OnIgniHit( this );		
	}	

	event OnAttackRangeHit( entity : CGameplayEntity )
	{
		entity.OnIgniHit( this );
	}

	//range fx
	event OnRangeReached()
	{
		var v : Vector;
		var rot : EulerAngles;
				
		//projectile keeps flying e.g. through actors so we need to check if it hit something before or not
		if(!channelCollided)
		{			
			//collision fx
			v = GetWorldPosition() - signEntity.GetWorldPosition();
			rot = MatrixGetRotation(MatrixBuildFromDirectionVector(-v));
			((W3IgniEntity)signEntity).ShowChannelingRangeFx(GetWorldPosition(), rot);
		}
		
		isUsed = false;
		
		super.OnRangeReached();
	}
	
	public function IsProjectileFromChannelMode() : bool
	{
		return signSkill == S_Magic_s02;
	}
}