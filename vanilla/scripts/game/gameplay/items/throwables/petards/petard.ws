/***********************************************************************/
/** Copyright © 2012-2014
/** Author : ?, Tomek Kozera
/***********************************************************************/

/*
	When using proximity make sure to set proximity activation range smaller than the blast range. In other case 
	if a group of enemies enters the trigger only the first in line would get hit - we don't want that.
*/
class W3Petard extends CThrowable
{
	//-----------------------------   EDITABLES  -----------------------------------------
	protected editable var cameraShakeStrMin 				: float;
	protected editable var cameraShakeStrMax 				: float;
	protected editable var cameraShakeRange 				: float;
	protected editable var hitReactionType 					: EHitReactionType;
	protected editable var noLoopEffectIfHitWater			: bool;
	protected editable var dismemberOnKill 					: bool;
	protected editable var componentsEnabledOnLoop 			: array<name>;
	protected editable var friendlyFire						: bool;
	protected editable var impactParams						: SPetardParams;
	protected editable var loopParams						: SPetardParams;
	protected editable var dodgeable						: bool;
	protected editable var audioImpactName					: name;
	
		hint initialBlastRadius = "Radius in which targets are collected when petard explodes";
		hint loopEffectRadius = "Radius for the lasting effect";
		hint cameraShakeRange = "Max range at which camera shake will occur";
		hint cameraShakeStrMin = "Min strength of camera shake (at max distance from center)";
		hint cameraShakeStrMax = "Max strength of camera shake (at the center of explosion)";
		hint hitReactionType = "Type of hit animation to play on target when hit by bomb. Ignored if Knockdown/Stagger used";
		hint noLoopEffectIfHitWater = "If petard hit water then there will be no loop effect or FX";
		hint dismemberOnKill = "If set then if Actor is killed by this petard it will dismember";
		hint clusterFX = "Name of FX to play when bomb cleaves into clusters";
		hint friendlyFire = "If set then the one who created bomb explosion will also be affected by it";
	
	//-----------------------------   NON - EDITABLES  -----------------------------------------
	private const var FX_TRAIL 						: name;						//name of trail fx
	private const var FX_CLUSTER 					: name;						//name of cluster cleave-explosion fx
	
	protected var itemName							: name;						//thrown petard's item name
	private var targetPos 							: Vector;					//vector of target, need to store it as the projectiles must be released with 1-frame delay (entity attaching)
	private var isProximity							: bool;						//if true then the bomb will work in proximity mode
	private var isInWater							: bool;						//set if bomb is in water
	private var isInDeepWater  						: bool;						//set when bomb is in 'deep water' (>1m)
	private var isStuck								: bool;						//set to true when proximity bomb has stuck onto something
	protected var isCluster							: bool;						//set to true if given instance is from cluster skill
	private var justPlayingFXs						: array<name>;				//set after petard is processed but still plays fx - holds array of names of FX played
	protected var loopDuration						: float;					//duration of loop effect
	protected var snapCollisionGroupNames 			: array<name>;				//array of collision group names to use when snapping FXs
	protected var stopCollisions					: bool;						//set after collision is processed to stop further collision events
	protected var previousTargets					: array<CGameplayEntity>;	//array of targets hit in previous tick
	protected var targetsSinceLastCheck				: array<CGameplayEntity>;	//array of targets found in current tick - updates ONLY when the loop updates!
	private var	wasInTutorialTrigger				: bool;						//needed for aim mode tutorial
	
		default isStuck = false;
		default isCluster = false;
		default isProximity = false;
		default isInWater = false;
		default isInDeepWater = false;
		default stopCollisions = false;
		default FX_TRAIL = 'fx_trail';
		default FX_CLUSTER = 'fx_cluster_cleave';
		default dodgeable = true;
		
	//////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////  THROWING  /////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////
	event OnDestroyed()
	{
		ProcessPetardDestruction();
	}
	event OnProcessThrowEvent( animEventName : name )
	{
		var throwPos : Vector;
		var boneIndex : int;
		var orientationTarget	: EOrientationTarget;
		var slideTargetActor : CActor;
		
		if ( animEventName == 'ProjectileThrow' )
		{
			if ( GetOwner() == thePlayer )
			{
				if ( thePlayer.GetDisplayTarget() )
					throwPos = thePlayer.GetLookAtPosition();
				else
				{
					orientationTarget = thePlayer.GetOrientationTarget();
					
					if (!GetOwner().HasBuff(EET_Hypnotized) && (orientationTarget == OT_Camera || orientationTarget == OT_CameraOffset) )
						throwPos = theCamera.GetCameraDirection() * 8 + GetOwner().GetWorldPosition();
					else
						throwPos = GetOwner().GetWorldForward() * 8 + GetOwner().GetWorldPosition();		//else 8m in front of the player						
				}
			}			
			else
			{
				slideTargetActor = (CActor)( GetOwner().slideTarget );
			
				// Throw at target's pelvis, if not found then at target in general. If no target or has hypnotize throw 8m in front of character
				if( GetOwner().slideTarget && !GetOwner().HasBuff(EET_Hypnotized) &&
					( !slideTargetActor || ( slideTargetActor && GetAttitudeBetween(GetOwner(), GetOwner().slideTarget) == AIA_Hostile ) ) )
				{
					boneIndex = GetOwner().slideTarget.GetBoneIndex( 'pelvis' );
					if ( boneIndex > -1 )
						throwPos = MatrixGetTranslation( GetOwner().slideTarget.GetBoneWorldMatrixByIndex( boneIndex ) );
					else
						throwPos = GetOwner().slideTarget.GetWorldPosition();
				}
				else
				{
					orientationTarget = thePlayer.GetOrientationTarget();
					
					if (!GetOwner().HasBuff(EET_Hypnotized) && (orientationTarget == OT_Camera || orientationTarget == OT_CameraOffset) )
						throwPos = theCamera.GetCameraDirection() * 8 + GetOwner().GetWorldPosition();
					else
						throwPos = GetOwner().GetWorldForward() * 8 + GetOwner().GetWorldPosition();		//else 8m in front of the player						
				}
			}
			
			ThrowProjectile( throwPos );
		}
		
		return super.OnProcessThrowEvent( animEventName );
	}
	
	public function GetAudioImpactName() : name
	{
		return audioImpactName;
	}
	
	protected function LoadDataFromItemXMLStats()
	{
		var atts, abs : array<name>;
		var j, i, iSize, jSize : int;
		var disabledAbility : SBlockedAbility;
		var dm : CDefinitionsManagerAccessor;
		var buff : SEffectInfo;
		var isLoopAbility : bool;
		var dmgRaw : SRawDamage;
		var type : EEffectType;
		var customAbilityName : name;
		var inv : CInventoryComponent;
		var abilityDisableDuration : float;
		var min, max : SAbilityAttributeValue;
		
		inv = GetOwner().GetInventory();
		
		if(!inv)
		{
			LogAssert(false, "W3Petard.LoadDataFromItemXMLStats: owner <<" + GetOwner() + ">> has no InventoryComponent!!!");
			return;
		}
		
		loopDuration = CalculateAttributeValue(inv.GetItemAttributeValue(itemId, 'duration'));
		itemName = inv.GetItemName(itemId);
		
		inv.GetItemAbilities(itemId, abs);
		dm = theGame.GetDefinitionsManager();
		iSize = abs.Size();		
		for( i = 0; i < iSize; i += 1 )
		{
			isLoopAbility = dm.AbilityHasTag(abs[i], 'PetardLoopParams');
			if(!isLoopAbility)
				if(!dm.AbilityHasTag(abs[i], 'PetardImpactParams'))
					continue;
			
			dm.GetAbilityAttributeValue(abs[i], 'ability_disable_duration', min, max);
			abilityDisableDuration = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
			dm.GetContainedAbilities(abs[i], atts);
			jSize = atts.Size();
			for( j = 0; j < jSize; j += 1 )
			{
				//buff
				if( IsEffectNameValid( atts[j] ) )
				{
					EffectNameToType(atts[j], type, customAbilityName);
					
					buff.effectType = type;
					buff.effectAbilityName = customAbilityName;					
					dm.GetAbilityAttributeValue(abs[i], atts[j], min, max);
					buff.applyChance = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
					
					if(isLoopAbility)
						loopParams.buffs.PushBack(buff);
					else
						impactParams.buffs.PushBack(buff);
				}
				else
				{
					disabledAbility.abilityName = atts[j];
					disabledAbility.timeWhenEnabledd = abilityDisableDuration;
					
					//if not set then inf
					if(disabledAbility.timeWhenEnabledd == 0)
						disabledAbility.timeWhenEnabledd = -1;
					
					if(isLoopAbility)
						loopParams.disabledAbilities.PushBack(disabledAbility);
					else
						impactParams.disabledAbilities.PushBack(disabledAbility);
				}
			}
			
			dm.GetAbilityAttributes(abs[i], atts);
			jSize = atts.Size();
			for( j = 0; j < jSize; j += 1 )
			{
				//damage
				if(IsDamageTypeNameValid(atts[j]))
				{				
					dmgRaw.dmgVal = CalculateAttributeValue(inv.GetItemAttributeValue(itemId, atts[j]));
					if(dmgRaw.dmgVal == 0)
						continue;
					
					dmgRaw.dmgType = atts[j];
					
					if(isLoopAbility)
						loopParams.damages.PushBack(dmgRaw);
					else
						impactParams.damages.PushBack(dmgRaw);						
				}
			}
			
			//ignore armor, if has any damage
			if(isLoopAbility && loopParams.damages.Size() > 0)
			{
				loopParams.ignoresArmor = atts.Contains('ignoreArmor');
			}
			else if(!isLoopAbility && impactParams.damages.Size() > 0)
			{
				impactParams.ignoresArmor = atts.Contains('ignoreArmor');
			}
		}
	}
	
	// OVERRIDES PARENT
	// we break attachment when the item is thrown. In this case the throwing
	// is on a delayed timer.
	public function ThrowProjectile( targetPosIn : Vector )
	{		
		var phantom : CPhantomComponent;
		var inv : CInventoryComponent;
			
		//cache snapping collision group names
		phantom = (CPhantomComponent)GetComponent('snappingCollisionGroupNames');
		if(phantom)
		{
			phantom.GetTriggeringCollisionGroupNames(snapCollisionGroupNames);
		}
		else
		{
			snapCollisionGroupNames.PushBack('Terrain');
			snapCollisionGroupNames.PushBack('Static');
		}
		
		//load data from item stats
		LoadDataFromItemXMLStats();		
	
		targetPos = targetPosIn;
		
		isProximity = false;//((W3PlayerWitcher)owner && GetWitcherPlayer().CanUseSkill(PROXIMITY_BOMBS));
		
		// bombs need to be attached first in order to be released (in the next frame)
		AddTimer( 'ReleaseProjectile', 0.01, false, , , true );
		
		//remove item
		if ( GetOwner() != thePlayer )
		{
			inv = GetOwner().GetInventory();
			if(inv)
				inv.RemoveItem( itemId );
		}
		else
		{
			//remove items from inventory
			if(!FactsDoesExist("debug_fact_inf_bombs"))
				thePlayer.inv.SingletonItemRemoveAmmo(itemId, 1);
				
			//clear selected item on HUD if player has no more items
			if( thePlayer.inv.GetItemQuantity(itemId) < 1 )		
				thePlayer.ClearSelectedItemId();
			else
				GetWitcherPlayer().AddBombThrowDelay(itemId);
				
			if(GetOwner() == GetWitcherPlayer())
				GetWitcherPlayer().FailFundamentalsFirstAchievementCondition();
		}
	}
	
	//releases the projectile
	timer function ReleaseProjectile( time : float , id : int)
	{
		var distanceToTarget, projectileFlightTime : float;
		var target : CActor = thePlayer.GetTarget();
		var actorsInAoE : array<CActor>;
		var i : int;

		BreakAttachment();
		ShootProjectileAtPosition( 20.0f, 15.0f, targetPos, theGame.params.MAX_THROW_RANGE );
		
		if(isFromAimThrow && ShouldProcessTutorial('TutorialThrowHold'))
		{
			wasInTutorialTrigger = (FactsQuerySum("tut_aim_in_trigger") > 0);				
		}
		
		actorsInAoE = thePlayer.playerAiming.GetSweptActors();
		
		if ( actorsInAoE.Size() > 0 )
		{
			if( dodgeable )
			{
				for ( i=0 ; i < actorsInAoE.Size() ; i+=1 )
				{
					actorsInAoE[i].SignalGameplayEvent( 'Time2DodgeBombAOE' );
					((CNewNPC)actorsInAoE[i]).OnIncomingProjectile( true );
				}
			}
		}
		else if( target )
		{	
			if( dodgeable )
			{
				distanceToTarget = VecDistance( thePlayer.GetWorldPosition(), target.GetWorldPosition() );	
				
				// used to dodge projectile before it hits
				projectileFlightTime = distanceToTarget / 15;
				target.SignalGameplayEventParamFloat( 'Time2DodgeBomb', projectileFlightTime );
			}
			
			((CNewNPC)target).OnIncomingProjectile( true );
		}
		
		PlayEffectSingle(FX_TRAIL);
		wasThrown = true;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////  TRIGGERING  ///////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////
	
	//if collision then add proximity timer or activate
	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		var depthTestPos, petardPos, collisionPos, collisionNormal : Vector;
		var template : CEntityTemplate;
		var npc : CNewNPC;
		var victim : CActor;
		var entity : CEntity;
		
		if(stopCollisions)
			return true;
			
		if(collidingComponent)
			entity = collidingComponent.GetEntity();
		
		//ignore collision with owner
		if(entity == GetOwner())
			return true;
			
		if(collidingComponent)
		{
			victim = (CActor)entity;
			npc = (CNewNPC)(victim);
		}
			
		if ( !CanCollideWithVictim( victim ) )
			return true;
		
		// for enemies reflectint projectiles
		if ( npc && npc.HasAbility( 'RepulseProjectiles' ) )
		{
			bounceOfVelocityPreserve = 0.8;
			BounceOff( normal, pos );
			victim.PlayEffect( 'lightning', this );
			this.Init( npc );
			return true;
		}
		
		// destroying shield with Grapeshots 2 and 3
		if( itemName == 'Grapeshot 2' || itemName == 'Grapeshot 3' )
		{
			if( npc && npc.IsShielded( thePlayer ) )
			{
				npc.ProcessShieldDestruction();
			}
		}
		
		//vibra if any grapeshot
		//if(StrFindFirst( NameToString(itemName), "Grapeshot" ) >= 0)
		theGame.VibrateControllerVeryHard();	//bombs
			
		//ignore collision with water
		if ( hitCollisionsGroups.Contains( 'Water' ) )
		{
			if(isInWater)
				return true;
				
			isInWater = true;
		
			petardPos = GetWorldPosition();
			depthTestPos = petardPos;
			depthTestPos.Z -= 1;
			
			if ( !theGame.GetWorld().StaticTrace(petardPos, depthTestPos, collisionPos, collisionNormal, snapCollisionGroupNames) )
				isInDeepWater = true;
			
			//create splash fx if petard is in deep water
			if(isInDeepWater)
			{
				template = (CEntityTemplate)LoadResource("water_splash_small");
				theGame.CreateEntity(template, GetWorldPosition(), GetWorldRotation());
				stopCollisions = true;
				DestroyAfter(3);
			}
			
			return true;
		}
		
		//stop flying if hit something other than water
		StopFlying();		
			
		if(isProximity || FactsQuerySum('debug_petards_proximity') > 0)
		{
			PlayEffectSingle('sparks');
			
			GetComponent("ProximityActivationArea").SetEnabled(true);
			AddTimer( 'DetonationTimer', theGame.params.PROXIMITY_PETARD_IDLE_DETONATION_TIME, , , , true );
			isStuck = true;
		}
		else
		{
			ProcessEffect( pos, (CGameplayEntity)entity );
		}
	}
	
	protected function StopFlying()
	{		
		StopEffect(FX_TRAIL);
		stopCollisions = true;
		StopProjectile();
	}
		
	event OnRangeReached()
	{	
		StopFlying();
		ProcessEffect();
	}
	
	event OnInteractionActivated(interactionComponentName : string, activator : CEntity)
	{
		if((isProximity || FactsQuerySum('debug_petards_proximity') > 0) && interactionComponentName == "ProximityActivationArea" && IsRequiredAttitudeBetween(GetOwner(), activator, true))
			ProcessEffect();	
	}
	
	//if proximity time ended
	timer function DetonationTimer( detlaTime : float , id : int)
	{
		ProcessEffect();
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////  EFFECT PROCESSING  ////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////
		
	// if explosionPosition is equal to 0, the current entity's position is taken
	public function ProcessEffect( optional explosionPosition : Vector, optional collidedTarget : CGameplayEntity )
	{
		var targets : array< CGameplayEntity >;
		var i : int;
		var victimTags, attackerTags : array<name>;
		var dist, camShakeStr, camShakeStrFrac : float;
		var temp : bool;
		var phantom : CPhantomComponent;
		var meshes : array<CComponent>;
		var mesh : CMeshComponent;
		var npc : CNewNPC;
		
		//just destroy if in deep water or in water in general and we don't want effect there
		if(isInDeepWater || (noLoopEffectIfHitWater && isInWater) )
		{
			Destroy();
			return;
		}
		
		//prevent further collisions
		stopCollisions = true;
		
		//hide bomb mesh
		meshes = GetComponentsByClassName('CMeshComponent');
		for(i=0; i<meshes.Size(); i+=1)
		{
			mesh = (CMeshComponent)meshes[i];
			if( !mesh )
			{
				continue;
			}
			
			mesh.SetVisible(false);
			mesh.SetEnabled(false);
		}

		//custom handling for cluster bomb skill
		if(!isCluster && (W3PlayerWitcher)GetOwner() && GetWitcherPlayer().CanUseSkill(S_Alchemy_s11) && !HasTag('Snowball'))
		{
			ProcessClusterBombs();
			return;
		}

		if ( explosionPosition == Vector( 0, 0, 0 ) )
		{
			explosionPosition = this.GetWorldPosition();
		}

		// hack so that gameplay entities is not empty - should not be, because should at least contain the target entity
		explosionPosition = explosionPosition + Vector( 0.0f, 0.0f, 0.1f );
		FindGameplayEntitiesInSphere(targets, explosionPosition, impactParams.range, 1000, '', FLAG_TestLineOfSight);	
		
		if( targets.Size() == 0 )
		{
			explosionPosition = explosionPosition - Vector( 0.0f, 0.0f, 0.2f ); // double of what we've added
			FindGameplayEntitiesInSphere(targets, explosionPosition, impactParams.range, 1000, '', FLAG_TestLineOfSight);	
		}
		
		if(collidedTarget && !targets.Contains(collidedTarget))
			targets.PushBack(collidedTarget);
		
		for( i=targets.Size() - 1; i >= 0; i -= 1)
		{		
			if( !targets[ i ].IsAlive() )
			{
				npc = (CNewNPC)targets[i];
				
				if(npc)
				{
					//abandon agony if target is an npc
					npc.SignalGameplayEvent('AbandonAgony');
					
					// Enable ragdoll if target is an npc
					
					// Ignore the following monsters because we don't have time to make a properly working ragdoll for them
					// Also ignores all the animals because only some have a proper ragdoll
					if( !npc.HasAbility( 'mon_bear_base' )
						&& !npc.HasAbility( 'mon_golem_base' )
						&& !npc.HasAbility( 'mon_endriaga_base' )
						&& !npc.HasAbility( 'mon_gryphon_base' )
						&& !npc.HasAbility( 'q604_shades' )
						&& !npc.IsAnimal()	)
					{
						npc.SetKinematic(false);
					}
				}
				else
				{
					//Some tagged entities need to add facts for quests
					if( !targets[i].HasTag( 'TargetableByBomb' ) )
					{
						targets.Erase(i);
					}
				}
				
			}
			if ( targets[ i ] == this )
			{
				targets.Erase(i);
			}
		}
		
		//snap components
		SnapComponents(true);
				
		//process mechanics (damage, buffs, abilities etc.)
		ProcessMechanicalEffect(targets, true);
		
		//cam shake
		if(cameraShakeStrMin + cameraShakeStrMax > 0)	//if str is set at all
		{
			dist = VecDistance(GetOwner().GetWorldPosition(), GetWorldPosition());
			
			if(dist <= cameraShakeRange)
			{
				camShakeStrFrac = (cameraShakeRange - dist) / cameraShakeRange;
				camShakeStr = cameraShakeStrMin + camShakeStrFrac * (cameraShakeStrMax - cameraShakeStrMin);
				
				//cam shake is between min and max proportionally to how close to the center of blast we are
				GCameraShake(camShakeStr, true, GetWorldPosition(), impactParams.range * 2);
			}
		}
		
		//reaction
		theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( this, 'BombExplosionAction', 10.0, 20.0f, -1, -1, true); //reactionSystemSearch
		
		//fx
		ProcessEffectPlayFXs(true);
				
		if(loopDuration > 0)
		{
			ProcessLoopEffect();
		}
		else
		{
			OnTimeEndedFunction(0);
		}
	}
	
	protected function SnapComponents(isImpact : bool)
	{
		var params : SPetardParams;
		var i : int;
		var pos : Vector;
		
		if(isImpact)
			params = impactParams;
		else
			params = loopParams;
			
		for(i=0; i<params.componentsToSnap.Size(); i+=1)
			SnapComponentByName(params.componentsToSnap[i], 2, 0.25, snapCollisionGroupNames, pos);
	}
	
	protected function ProcessLoopEffect()
	{
		//enable loop components
		LoopComponentsEnable(true);
		
		//snap components
		SnapComponents(false);
		
		//fx
		ProcessEffectPlayFXs(false);
		
		//duration
		AddTimer('OnTimeEnded', loopDuration, false, , , true);
		AddTimer('Loop', 0.05, true, , , true);	//dt needs to be greater than lower buff durations - to reapply the buffs properly
	}
	
	protected function LoopComponentsEnable(enable : bool)
	{
		var i : int;
		var component : CComponent;
		
		for(i=0; i<componentsEnabledOnLoop.Size(); i+=1)
		{
			component = GetComponent(componentsEnabledOnLoop[i]);
			if(component)
				component.SetEnabled(enable);
		}
	}
	
	timer function Loop(dt : float, id : int)
	{
		LoopFunction(dt);
	}
	
	protected function ProcessPetardDestruction ()
	{
		var i : int;
		
		for(i=0; i<previousTargets.Size(); i+=1)
			ProcessTargetOutOfArea(previousTargets[i]);		
	}
	
	protected function LoopFunction(dt : float)
	{
		var i : int;
		var targets : array<CGameplayEntity>;
		var pos : Vector;
	
		pos = GetWorldPosition();
		pos.Z += loopParams.cylinderOffsetZ;
		targetsSinceLastCheck.Clear();
		FindGameplayEntitiesInCylinder(targets, pos, loopParams.range, loopParams.cylinderHeight, 100000);
		
		//remove self
		targets.Remove(this);
		
		//convert to handles
		targetsSinceLastCheck.Resize(targets.Size());
		for(i=0; i<targetsSinceLastCheck.Size(); i+=1)
		{
			targetsSinceLastCheck[i] = targets[i];
		}
		
		for(i=0; i<targetsSinceLastCheck.Size(); i+=1)
			ProcessTargetInArea( targetsSinceLastCheck[i], dt);
		
		for(i=0; i<previousTargets.Size(); i+=1)
			if(!targetsSinceLastCheck.Contains( previousTargets[i] ))
				ProcessTargetOutOfArea( previousTargets[i] );
		
		previousTargets.Clear();
		previousTargets = targetsSinceLastCheck;
		
		//debug - the rand bullshit is to get random name each time to show more than 1 sphere (we need unique name each time and we cannot get name of the Entity. Why? BECAUSE GETNAME() RETURNS STRING BITCH!!!)		
		thePlayer.GetVisualDebug().AddSphere(GetRandomName(), loopParams.range, GetWorldPosition(), true, Color(0,0,255), 0.2);
	}
	
	protected function ProcessTargetInArea(actor : CGameplayEntity, dt : float)
	{	
		var targets : array<CGameplayEntity>;
	
		targets.PushBack(actor);
		ProcessMechanicalEffect(targets, false, dt);
	}
	
	//restore abilities removed permanently
	protected function ProcessTargetOutOfArea(entity : CGameplayEntity)
	{
		var dm : CDefinitionsManagerAccessor;
		var j, k : int;
		var skill : ESkill;
		var successfullUnblock : bool;
		var actor : CActor;

		actor = (CActor)entity;
		if(!actor || !actor.IsAlive())
			return;
			
		//unblock abilities / skills blocked for infinite time
		dm = theGame.GetDefinitionsManager();
		successfullUnblock = false;
		for(j=0; j<loopParams.disabledAbilities.Size(); j+=1)
		{			
			if(loopParams.disabledAbilities[j].timeWhenEnabledd == -1 && dm.IsAbilityDefined(loopParams.disabledAbilities[j].abilityName))
			{
				//check if it's skill
				skill = S_SUndefined;
				if(actor == thePlayer)
					skill = SkillNameToEnum(loopParams.disabledAbilities[j].abilityName);						 
				
				//block skill or ability
				if(skill != S_SUndefined)
					successfullUnblock = thePlayer.BlockSkill(skill, false) || successfullUnblock;
				else
					successfullUnblock = actor.BlockAbility(loopParams.disabledAbilities[j].abilityName, false) || successfullUnblock;
			}
		}
		
		if(successfullUnblock)
		{
			//fx when ability successfully disabled
			for(k=0; k<loopParams.fxPlayedWhenAbilityDisabled.Size(); k+=1)						
				actor.StopEffect(loopParams.fxPlayedWhenAbilityDisabled[k]);
				
			for(k=0; k<loopParams.fxStoppedWhenAbilityDisabled.Size(); k+=1)						
				actor.PlayEffectSingle(loopParams.fxStoppedWhenAbilityDisabled[k]);
		}
	}
		
	timer function OnTimeEnded(dt : float, id : int)
	{
		OnTimeEndedFunction(dt);		
	}
	
	protected function OnTimeEndedFunction(dt : float)
	{
		LoopComponentsEnable(false);
		StopAllEffects();
		AddTimer('DestroyWhenNoFXPlayed', 1, true, , , true);
		RemoveTimer('Loop');
	}
	
	//playes water / non-water FX on impact or loop start
	protected function ProcessEffectPlayFXs(isImpact : bool)
	{
		var params : SPetardParams;
		var i : int;
		var fx : array<name>;
	
		if(isImpact)
			params = impactParams;
		else
			params = loopParams;
			
		//choose fx to use
		if(isInWater)
		{
			if(isCluster && params.fxClusterWater.Size() > 0)
			{
				fx = params.fxClusterWater;
			}
			else
			{
				fx = params.fxWater;
			}
		}
		else
		{
			if(isCluster && params.fxCluster.Size() > 0)
			{
				fx = params.fxCluster;
			}
			else
			{
				fx = params.fx;
			}
		}
		
		//show fx
		for(i=0; i<fx.Size(); i+=1)
			PlayEffectInternal(fx[i]);
	}

	//adds buff, deals damage etc.
	protected function ProcessMechanicalEffect(targets : array<CGameplayEntity>, isImpact : bool, optional dt : float)
	{			
		var i, index, j, k : int;
		var action : W3DamageAction;
		var none : SAbilityAttributeValue;
		var atts : array<name>;
		var newDamage : SRawDamage;
		var params : SPetardParams;
		var attackerTags, allVictimsTags, targetTags : array<name>;
		var dm : CDefinitionsManagerAccessor;
		var actorTarget : CActor;
		var surface	: CGameplayFXSurfacePost;		
		var successfullBlock : bool;
		var hitType : EHitReactionType;
		var npc : CNewNPC;
		
		//ignored entity types & friendly fire cleanup: player gets damaged, npcs only play hit anim
		for(i=targets.Size()-1; i>=0; i-=1)
		{
			//ignored entity types
			if( (CActionPoint)targets[i] || (W3Petard)targets[i] /*|| (W3AnimationInteractionEntity)targets[i]*/)
			{
				targets.Erase(i);
				continue;
			}
			
			if(GetAttitudeBetween(GetOwner(), targets[i]) == AIA_Friendly)
			{
				actorTarget = (CActor)targets[i];
				
				//player hits himself always, non-actors don't concern us
				if(!actorTarget || (targets[i] == GetOwner() && GetOwner() == thePlayer))
					continue;
				
				/* AK: removing friendly fire hit reaction - friendlies will react differently through community reaction
				//play hit
				if(friendlyFire)
				{					
					if(!action)
					{
						action = new W3DamageAction in theGame.damageMgr;
						action.Initialize(owner, actorTarget, this, "petard", EHRT_Heavy, CPS_Undefined, false, false, false, false);
						action.SetHitAnimationPlayType(EAHA_ForceYes);
					}
					actorTarget.ReactToBeingHit(action);
				}
				*/
				targets.Erase(i);
			}
		}
		
		//temp for friendly fire
		if(action)
			delete action;
		
		if(isImpact)
			params = impactParams;
		else
			params = loopParams;
			
		//surface fx
		if(params.surfaceFX.fxType >= 0 && !isInWater)
		{
			surface = theGame.GetSurfacePostFX();
			surface.AddSurfacePostFXGroup(GetWorldPosition(), params.surfaceFX.fxFadeInTime, params.surfaceFX.fxLastingTime, params.surfaceFX.fxFadeOutTime, params.surfaceFX.fxRadius, params.surfaceFX.fxType);
		}	
		
		if(targets.Size() == 0)
			return;				
			
		if(isImpact)
		{
			//debug area - the rand bullshit is to get random name each time to show more than 1 sphere (we need unique name each time and we cannot get name of the Entity. Why? BECAUSE GETNAME() RETURNS STRING BITCH!!!)		
			thePlayer.GetVisualDebug().AddSphere(EffectTypeToName(RandRange(EnumGetMax('EEffectType'))), impactParams.range, GetWorldPosition(), true, Color(255,0,0), 3);
		
			//skill adding flat damage to all bombs			
			if((W3PlayerWitcher)GetOwner() && GetWitcherPlayer().CanUseSkill(S_Alchemy_s10) && !HasTag('Snowball'))
			{
				theGame.GetDefinitionsManager().GetAbilityAttributes(SkillEnumToName(S_Alchemy_s10), atts);
				
				for(j=0; j<atts.Size(); j+=1)
				{
					if(IsDamageTypeNameValid(atts[j]))
					{
						index = -1;
						for(i=0; i<params.damages.Size(); i+=1)
						{
							if(params.damages[i].dmgType == atts[j])
							{
								index = i;
								break;
							}
						}
						
						//add damage with damage already used by bomb or make a new one if not used
						if(index != -1)
						{
							params.damages[index].dmgVal += CalculateAttributeValue(thePlayer.GetSkillAttributeValue(S_Alchemy_s10, atts[j], false, true)) * thePlayer.GetSkillLevel(S_Alchemy_s10);
						}
						else
						{
							newDamage.dmgType = atts[j];
							newDamage.dmgVal = CalculateAttributeValue(thePlayer.GetSkillAttributeValue(S_Alchemy_s10, atts[j], false, true)) * thePlayer.GetSkillLevel(S_Alchemy_s10);
							params.damages.PushBack(newDamage);
						}
					}
				}
			}
		}
		
		dm = theGame.GetDefinitionsManager();
					
		//damage and buffs
		if(isImpact)
			hitType = hitReactionType;
		else
			hitType = EHRT_None;
			
		for(i=0; i<targets.Size(); i+=1)
		{	
			//append tags
			targetTags = targets[i].GetTags();
			ArrayOfNamesAppendUnique(allVictimsTags, targetTags);
			
			//not actors - could get OnFireHit() if applicable
			actorTarget = (CActor)targets[i];
			if(!actorTarget)
			{
				for(j=0; j<params.damages.Size(); j+=1)
				{
					if(params.damages[j].dmgVal > 0)
					{
						if(params.damages[j].dmgType == theGame.params.DAMAGE_NAME_FIRE)
						{
							targets[i].OnFireHit(this);
						}
						else if(params.damages[j].dmgType == theGame.params.DAMAGE_NAME_FROST)						
						{
							targets[i].OnFrostHit(this);
						}
					}
				}
				
				//tutorial custom (aim throwed bomb at dummy while standing in trigger)
				if(isFromAimThrow && wasInTutorialTrigger && ShouldProcessTutorial('TutorialThrowHold'))
				{
					for(j=0; j<targetTags.Size(); j+=1)
					{
						FactsAdd("aimthrowed_" + targetTags[j]);
					}
				}
					
				continue;
			}
			
			//skip dead actors
			if(!actorTarget.IsAlive())
				continue;
			
			//apply action (always as we might want to force hit anims even if no damage is dealt)
			action = new W3DamageAction in theGame.damageMgr;
			action.Initialize(GetOwner(), actorTarget, this, 'petard', hitType, CPS_Undefined, false, true, false, false);
			action.SetHitAnimationPlayType(params.playHitAnimMode);
			action.SetIgnoreArmor(params.ignoresArmor);
			action.SetProcessBuffsIfNoDamage(true);
			action.SetIsDoTDamage(dt);
			
			for(j=0; j<params.damages.Size(); j+=1)
			{
				if(dt > 0)
					action.AddDamage(params.damages[j].dmgType, params.damages[j].dmgVal * dt);
				else
					action.AddDamage(params.damages[j].dmgType, params.damages[j].dmgVal);
			}

			for(j=0; j<params.buffs.Size(); j+=1)
				action.AddEffectInfo(params.buffs[j].effectType, params.buffs[j].effectDuration, params.buffs[j].effectCustomValue, params.buffs[j].effectAbilityName, params.buffs[j].effectCustomParam, params.buffs[j].applyChance);
									
			theGame.damageMgr.ProcessAction(action);
			delete action;
						
			//block abilities / skills
			successfullBlock = false;
			for(j=0; j<params.disabledAbilities.Size(); j+=1)
				if(dm.IsAbilityDefined(params.disabledAbilities[j].abilityName))
					successfullBlock = BlockTargetsAbility(actorTarget, params.disabledAbilities[j].abilityName, params.disabledAbilities[j].timeWhenEnabledd) || successfullBlock;					
			
			//regular fx
			for(k=0; k<params.fxPlayedOnHit.Size(); k+=1)
				actorTarget.PlayEffectSingle(params.fxPlayedOnHit[k]);
			
			//block skill fx if at least one 
			if(successfullBlock)
			{
				//fx when ability successfully disabled
				for(k=0; k<params.fxPlayedWhenAbilityDisabled.Size(); k+=1)						
					actorTarget.PlayEffectSingle(params.fxPlayedWhenAbilityDisabled[k]);
					
				for(k=0; k<params.fxStoppedWhenAbilityDisabled.Size(); k+=1)						
					actorTarget.StopEffect(params.fxStoppedWhenAbilityDisabled[k]);
			}
				
			//reaction for guards being hit in the face with a non-damaging bomb (if it's damaging, damage will trigger their reactions)
			npc = (CNewNPC)actorTarget;
			if(npc && npc.GetNPCType() == ENGT_Guard && !npc.IsInCombat() )
			{
				npc.SignalGameplayEventParamObject('BeingHitAction', GetOwner());
				theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( npc, 'BeingHitAction', 8.0, 1.0f, 999.0f, 1, false); //reactionSystemSearch	
			}
		}

		//add fact
		if(allVictimsTags.Size() > 0)
		{
			attackerTags = GetOwner().GetTags();
			
			AddHitFacts( allVictimsTags, attackerTags, "_weapon_hit" );
			AddHitFacts( allVictimsTags, attackerTags, "_bomb_hit" );
			AddHitFacts( allVictimsTags, attackerTags, "_bomb_hit_type_" + PrintFactFriendlyPetardName() );
		}			
	}
	
	//blocks player skill or NPCs ability. Returns true if it was blocked.
	protected function BlockTargetsAbility(target : CActor, abilityName : name, blockDuration : float, optional unlock : bool) : bool
	{
		var skill : ESkill;
	
		//check if it's skill
		skill = S_SUndefined;
		if(target == thePlayer)					
			skill = SkillNameToEnum(abilityName);						 
		
		//block skill or ability
		if(skill != S_SUndefined)
			return thePlayer.BlockSkill(skill, !unlock, blockDuration);
		else
			return target.BlockAbility(abilityName, true, blockDuration);
	}
	
	timer function DelayedRestoreCollisions(dt : float, id : int)
	{
		stopCollisions = false;
	}
	
	//Handles cluster skill - additional 3 cluster bombs spawn on explosion
	private function ProcessClusterBombs()
	{
		var target : CActor = thePlayer.GetTarget();
		var i, clusterNbr : int;
		var cluster : W3Petard;
		var targetPosCluster, clusterInitPos : Vector;
		var angle, velocity, distLen : float;
		var clusterTemplate : CEntityTemplate;
		var dmgRaw : SRawDamage;
		var cachedDamages : array<SRawDamage>;
		var atts : array<name>;
		var distanceToTarget : float;
		var projectileFlightTime : float;
	
		clusterInitPos = GetWorldPosition();
		clusterInitPos.Z += radius + 0.15;
		
		clusterNbr = thePlayer.GetSkillLevel(S_Alchemy_s11) + 1;
		
		for(i=0; i<clusterNbr; i+=1)
		{			
			cluster = (W3Petard)Duplicate();
			cluster.Init(GetOwner());
			cluster.isCluster = true;
			cluster.isProximity = false;					//clusters are not affected by proximity
			cluster.AddTimer('DelayedRestoreCollisions', 0.2);	//parent has them disabled since it already exploded but if we enable it here they collide with whatever the parent collided with
			
			//set cluster's random displacement position (+/- 1..4 meters in x and y)
			targetPosCluster.X = SgnF(RandF()-0.5) * (1+RandF()*3);
			targetPosCluster.Y = SgnF(RandF()-0.5) * (1+RandF()*3);
			targetPosCluster.Z = 0;
			
			distLen = VecLength2D(targetPosCluster);	//2D distance from impact point
			
			targetPosCluster += GetWorldPosition();		//cluster's target position
			
			angle = (9 - distLen) * 10;					//angle: the smaller the further away
			velocity = 4 + distLen/2;					//speed: the higher the further
			
			//shoot cluster
			cluster.ShootProjectileAtPosition( angle, velocity, targetPosCluster, theGame.params.MAX_THROW_RANGE );
			cluster.PlayEffectSingle(FX_TRAIL);
			
			if ( dodgeable )
			{
				distanceToTarget = VecDistance( thePlayer.GetWorldPosition(), target.GetWorldPosition() );		
				
				// used to dodge projectile before it hits
				projectileFlightTime = distanceToTarget / velocity;
				target.SignalGameplayEventParamFloat('Time2DodgeBomb', projectileFlightTime );
			}
		}
		
		//fx in impact point
		PlayEffect(FX_CLUSTER);		
		justPlayingFXs.PushBack(FX_CLUSTER);
		
		AddTimer('DestroyWhenNoFXPlayed', 1, true, , , true);
		stopCollisions = true;
	}
	
	timer function DestroyWhenNoFXPlayed(dt : float, id : int)
	{
		DestroyWhenNoFXPlayedFunction(dt);
	}
	
	//returns true if DestroyAfter() has been scheduled
	protected function DestroyWhenNoFXPlayedFunction(dt : float) : bool
	{
		var i : int;
	
		for(i=0; i<justPlayingFXs.Size(); i+=1)
			if(IsEffectActive(justPlayingFXs[i]))
				return false;
				
		RemoveTimer('DestroyWhenNoFXPlayed');
		DestroyAfter( 0.1f ); // don't destroy immediately, this might cause crashes
		return true;
	}
	
	protected function PlayEffectInternal(fx : name)
	{
		//play fx
		PlayEffectSingle(fx);
		
		//add to played array
		justPlayingFXs.PushBack(fx);
	}
	
	public function DismembersOnKill() : bool
	{
		return dismemberOnKill;
	}
	
	public function GetImpactRange() : float			{return impactParams.range;}
	public function GetAoERange() : float				{return loopParams.range;}
	public function IsStuck() : bool					{return isStuck;}
	public function DisableProximity()					{isProximity = false;}
	public function IsProximity() : bool				{return isProximity;}
	
	
	//Used for converting item name to a fact database friendly format
	private function PrintFactFriendlyPetardName() : string
	{
		return StrLower(StrReplaceAll( NameToString(itemName) , " ", "_" ));
	}
	
	
}
