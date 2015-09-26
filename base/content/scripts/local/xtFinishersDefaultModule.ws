// module

class XTFinishersDefaultModule {
	public var params : XTFinishersDefaultParams;
	
	public function InitAllComponents() {
		InitBaseComponents();
		InitFinisherComponents();
		InitDismemberComponents();
		InitFinisherCamComponents();
		InitSlowdownComponents();
		InitCamShakeComponents();
	}
	
	public function InitBaseComponents() {
		params = new XTFinishersDefaultParams in this;
		params.Init();
		
		theGame.xtFinishersMgr.SetSlowdownManager(new XTFinishersDefaultSlowdownManager in this);
		theGame.xtFinishersMgr.slowdownMgr.Init();
	}
	
	public function InitFinisherComponents() {
		theGame.xtFinishersMgr.queryMgr.LoadFinisherResponder(new XTFinishersDefaultFinisherQueryResponder in this);
		
		theGame.xtFinishersMgr.eventMgr.RegisterReactionListener(new XTFinishersDefaultFinisherQueryDispatcher in this);
	}
	
	public function InitDismemberComponents() {
		theGame.xtFinishersMgr.queryMgr.LoadDismemberResponder(new XTFinishersDefaultDismemberQueryResponder in this);
		
		theGame.xtFinishersMgr.eventMgr.RegisterReactionListener(new XTFinishersDefaultDismemberQueryDispatcher in this);
	}
	
	public function InitFinisherCamComponents() {
		theGame.xtFinishersMgr.queryMgr.LoadFinisherCamResponder(new XTFinishersDefaultFinisherCamQueryResponder in this);
		
		theGame.xtFinishersMgr.eventMgr.RegisterFinisherListener(new XTFinishersDefaultFinisherCamQueryDispatcher in this);
	}
	
	public function InitSlowdownComponents() {
		theGame.xtFinishersMgr.queryMgr.LoadSlowdownResponder(new XTFinishersDefaultSlowdownQueryResponder in this);
		
		theGame.xtFinishersMgr.eventMgr.RegisterFinisherListener(new XTFinishersDefaultSlowdownFinisherQueryDispatcher in this);
		theGame.xtFinishersMgr.eventMgr.RegisterDismemberListener(new XTFinishersDefaultSlowdownDismemberQueryDispatcher in this);
	}
	
	public function InitCamShakeComponents() {
		theGame.xtFinishersMgr.eventMgr.RegisterActionEndListener(new XTFinishersDefaultCamShakeHandler in this);
	}
}

// listeners

class XTFinishersDefaultFinisherQueryDispatcher extends XTFinishersAbstractReactionEventListener {
	public function GetPriority() : int {
		return 0;
	}
	
	public function OnReactionStartTriggered(out context : XTFinishersActionContext) {
		theGame.xtFinishersMgr.queryMgr.FireFinisherQuery(context);
	}
	
	public function OnReactionEndTriggered(out context : XTFinishersActionContext) {}
}

class XTFinishersDefaultDismemberQueryDispatcher extends XTFinishersAbstractReactionEventListener {
	public function GetPriority() : int {
		return 10;
	}
	
	public function OnReactionStartTriggered(out context : XTFinishersActionContext) {
		theGame.xtFinishersMgr.queryMgr.FireDismemberQuery(context);
	}
	
	public function OnReactionEndTriggered(out context : XTFinishersActionContext) {}
}

class XTFinishersDefaultFinisherCamQueryDispatcher extends XTFinishersAbstractFinisherEventListener {
	public function GetPriority() : int {
		return 0;
	}
	
	public function OnFinisherTriggered(out context : XTFinishersActionContext) {
		theGame.xtFinishersMgr.queryMgr.FireFinisherCamQuery(context);
	}
}

class XTFinishersDefaultSlowdownFinisherQueryDispatcher extends XTFinishersAbstractFinisherEventListener {
	public function GetPriority() : int {
		return 10;
	}
	
	public function OnFinisherTriggered(out context : XTFinishersActionContext) {
		if (context.slowdown.active) {
			return;
		}
		
		context.slowdown.type = theGame.xtFinishersMgr.consts.SLOWDOWN_TYPE_FINISHER;
		if (!context.finisherCam.active) {
			theGame.xtFinishersMgr.queryMgr.FireSlowdownQuery(context);
		}
		
		if (context.slowdown.active) {
			theGame.xtFinishersMgr.slowdownMgr.TriggerSlowdown(context);
		}
	}
}

class XTFinishersDefaultSlowdownDismemberQueryDispatcher extends XTFinishersAbstractDismemberEventListener {
	public function GetPriority() : int {
		return 0;
	}
	
	public function OnDismemberTriggered(out context : XTFinishersActionContext) {
		if (context.slowdown.active) {
			return;
		}
		
		context.slowdown.type = theGame.xtFinishersMgr.consts.SLOWDOWN_TYPE_DISMEMBER;
		theGame.xtFinishersMgr.queryMgr.FireSlowdownQuery(context);
		
		if (context.slowdown.active) {
			theGame.xtFinishersMgr.slowdownMgr.TriggerSlowdown(context);
		}
	}
}

class XTFinishersDefaultCamShakeHandler extends XTFinishersAbstractActionEndEventListener {
	public function GetPriority() : int {
		return 0;
	}
	
	protected function ProcessNormalStrike(out context : XTFinishersActionContext) {
		var playerAttacker : CR4Player;
		var attackAction : W3Action_Attack;
		
		playerAttacker = (CR4Player)context.action.attacker;
		attackAction = (W3Action_Attack)context.action;
		
		if (playerAttacker && attackAction && attackAction.IsActionMelee()) {
			if (playerAttacker.IsLightAttack(attackAction.GetAttackName())) {
				context.camShake.active = true;
				context.camShake.strength = 0.1;
				context.camShake.useExtraOpts = true;
				context.camShake.epicenter = playerAttacker.GetWorldPosition();
				context.camShake.maxDistance = 10;
			} else if (SkillNameToEnum(attackAction.GetAttackTypeName()) == S_Sword_s02) {
				context.camShake.active = true;
				context.camShake.strength = thePlayer.GetSpecialAttackTimeRatio() / 3.333 + 0.2;
				context.camShake.useExtraOpts = true;
				context.camShake.epicenter = playerAttacker.GetWorldPosition();
				context.camShake.maxDistance = 10;
			} else if (playerAttacker.IsHeavyAttack(attackAction.GetAttackName())) {
				context.camShake.active = true;
				if (attackAction.IsParried()) {
					context.camShake.strength = 0.2;
				} else {
					context.camShake.strength = 0.1;
				}
				context.camShake.useExtraOpts = true;
				context.camShake.epicenter = playerAttacker.GetWorldPosition();
				context.camShake.maxDistance = 10;
			}
		}
	}
	
	protected function ProcessCriticalHit(out context : XTFinishersActionContext) {
		var attackAction : W3Action_Attack;
		var actorVictim : CActor;
		
		attackAction = (W3Action_Attack)context.action;
		actorVictim = (CActor)context.action.victim;
		
		if((CR4Player)context.action.attacker && attackAction && actorVictim && attackAction.IsCriticalHit() && context.action.DealtDamage() && !actorVictim.IsAlive()) {
			context.camShake.active = true;
			context.camShake.strength = 0.5;
			context.camShake.useExtraOpts = false;
		}
	}
	
	protected function ProcessDismember(out context : XTFinishersActionContext) {
		var actorAttacker : CActor;
		
		actorAttacker = (CActor)context.action.attacker;
		
		if (context.dismember.active && (W3Action_Attack)context.action && actorAttacker && theGame.xtFinishersMgr.defaultModule.params.DISMEMBER_CAMERA_SHAKE) {
			context.camShake.active = true;
			context.camShake.strength = 0.5;
			context.camShake.useExtraOpts = true;
			context.camShake.epicenter = actorAttacker.GetWorldPosition();
			context.camShake.maxDistance = 10;
		}
	}
	
	protected function ProcessSlowdown(out context : XTFinishersActionContext) {
		if (context.slowdown.active && theGame.xtFinishersMgr.defaultModule.params.SLOWDOWN_DISABLE_CAMERA_SHAKE) {
			context.camShake.forceOff = true;
		}
	}
	
	public function OnActionEndTriggered(out context : XTFinishersActionContext) {
		ProcessNormalStrike(context);
		ProcessCriticalHit(context);
		ProcessDismember(context);
		ProcessSlowdown(context);
		
		theGame.witcherLog.AddCombatMessage("active: " + context.camShake.active, context.action.attacker, NULL);
		theGame.witcherLog.AddCombatMessage("force off: " + context.camShake.forceOff, context.action.attacker, NULL);
		
		if (!context.camShake.forceOff && (context.camShake.forceOn || context.camShake.active)) {
			if (context.camShake.useExtraOpts) {
				GCameraShake(context.camShake.strength, false, context.camShake.epicenter, context.camShake.maxDistance);
			} else {
				GCameraShake(context.camShake.strength);
			}
		}
	}
}



// responders

class XTFinishersDefaultFinisherQueryResponder extends XTFinishersFinisherQueryResponder {
	protected function CanPerformAutoFinisher(context : XTFinishersActionContext) : bool {
		var attackAction : W3Action_Attack;
		var result : bool;
		var hasEffect : bool;
		var autoFinisherEffectTypes : array<EEffectType>;
		var i : int;
		
		result = false;
		attackAction = (W3Action_Attack)context.action;
		
		if (attackAction) {
			if (attackAction.IsCriticalHit() && RandRangeF(100) < theGame.xtFinishersMgr.defaultModule.params.FINISHER_AUTO_CHANCE_CRIT) {
				result = true;
			} else if (SkillNameToEnum(attackAction.GetAttackTypeName()) == S_Sword_s02 && RandRangeF(100) < theGame.xtFinishersMgr.defaultModule.params.FINISHER_AUTO_CHANCE_REND) {
				result = true;
			} else if (thePlayer.IsLastEnemyKilled() && RandRangeF(100) < theGame.xtFinishersMgr.defaultModule.params.FINISHER_AUTO_CHANCE_LAST_ENEMY) {
				result = true;
			} else {
				hasEffect = false;
				autoFinisherEffectTypes = theGame.xtFinishersMgr.defaultModule.params.autoFinisherEffectTypes;
				for (i = 0; i < autoFinisherEffectTypes.Size(); i += 1) {
					hasEffect = context.effectsSnapshot.HasEffect(autoFinisherEffectTypes[i]);
					if (hasEffect) {
						break;
					}
				}
				result = hasEffect && RandRangeF(100) < theGame.xtFinishersMgr.defaultModule.params.FINISHER_AUTO_CHANCE_EFFECTS;
			}
		}
		
		return result;
	}
	
	protected function CanPerformInstantKillFinisher(context : XTFinishersActionContext) : bool {
		var actorVictim : CActor;
		var attackAction : W3Action_Attack;
		var result : bool;
		var hasEffect : bool;
		var instantKillFinisherEffectTypes : array<EEffectType>;
		var i : int;
		
		result = false;
		actorVictim = (CActor)context.action.victim;
		attackAction = (W3Action_Attack)context.action;
		
		if (actorVictim.IsVulnerable() && !actorVictim.HasAbility('InstantKillImmune')) {
			if (attackAction) {
				if (attackAction.IsCriticalHit() && RandRangeF(100) < theGame.xtFinishersMgr.defaultModule.params.FINISHER_INSTANTKILL_CHANCE_CRIT) {
					result = true;
				} else if (thePlayer.IsLastEnemyKilled() && RandRangeF(100) < theGame.xtFinishersMgr.defaultModule.params.FINISHER_INSTANTKILL_CHANCE_LAST_ENEMY) {
					result = true;
				} else {
					hasEffect = false;
					instantKillFinisherEffectTypes = theGame.xtFinishersMgr.defaultModule.params.instantKillFinisherEffectTypes;
					for (i = 0; i < instantKillFinisherEffectTypes.Size(); i += 1) {
						hasEffect = context.effectsSnapshot.HasEffect(instantKillFinisherEffectTypes[i]);
						if (hasEffect) {
							break;
						}
					}
					result = hasEffect && RandRangeF(100) < theGame.xtFinishersMgr.defaultModule.params.FINISHER_INSTANTKILL_CHANCE_EFFECTS;
				}
			}
		}
		
		return result;
	}
	
	public function CanPerformFinisher(out context : XTFinishersActionContext) {
		var actorVictim				: CActor;
		var attackAction			: W3Action_Attack;
		var finisherChance 			: float;
		var areEnemiesAttacking		: bool;
		var i						: int;
		var victimToPlayerVector, playerPos	: Vector;
		var item 					: SItemUniqueId;
		var moveTargets				: array<CActor>;
		var result					: bool;
		var size					: int;
		var npc						: CNewNPC;
		var autoFinisherEffectTypes : array<EEffectType>;
		var hasEffect				: bool;
		var levelDelta				: int;
		var areEnemiesAttackingModifier, navCheckModifier : bool;
		
		actorVictim = (CActor)context.action.victim;
		attackAction = (W3Action_Attack)context.action;
		
		if ((W3ReplacerCiri)thePlayer || (CR4Player)context.action.victim || thePlayer.isInFinisher) {
			return;
		}
		
		playerPos = thePlayer.GetWorldPosition();
		moveTargets = thePlayer.GetMoveTargets();	
		size = moveTargets.Size();
		if (size > 0) {
			areEnemiesAttacking = false;			
			for(i = 0; i < size; i += 1) {
				npc = (CNewNPC)moveTargets[i];
				if(npc && VecDistanceSquared(playerPos, moveTargets[i].GetWorldPosition()) < 7 && npc.IsAttacking() && npc != actorVictim ) {
					areEnemiesAttacking = true;
					break;
				}
			}
		}
		
		victimToPlayerVector = actorVictim.GetWorldPosition() - playerPos;
		
		context.finisher.forced = actorVictim.HasTag('ForceFinisher');
			
		if (!context.finisher.forced) {
			if (actorVictim.IsHuman()) {
				if (actorVictim.IsAlive()) {
					context.finisher.instantKill = CanPerformInstantKillFinisher(context);
				} else {
					context.finisher.auto = CanPerformAutoFinisher(context);
					
					npc = (CNewNPC)actorVictim;
					if (!context.finisher.forced && !context.finisher.auto) {
						if (( size <= 1 && theGame.params.FINISHER_ON_DEATH_CHANCE > 0) || (actorVictim.HasAbility('ForceFinisher'))) {
							finisherChance = 100;
						} else if (theGame.xtFinishersMgr.defaultModule.params.FINISHER_CHANCE_OVERRIDE) {
							finisherChance = theGame.xtFinishersMgr.defaultModule.params.FINISHER_CHANCE_BASE;
							levelDelta = thePlayer.GetLevel() - npc.currentLevel;
							if (levelDelta >= 0) {
								finisherChance += theGame.xtFinishersMgr.defaultModule.params.FINISHER_CHANCE_LEVEL_BONUS * levelDelta;
							} else {
								finisherChance += theGame.xtFinishersMgr.defaultModule.params.FINISHER_CHANCE_LEVEL_PENALTY * levelDelta;
							}
						} else {
							if (npc.currentLevel - thePlayer.GetLevel() < -5) {
								finisherChance = theGame.params.FINISHER_ON_DEATH_CHANCE + (-(npc.currentLevel - thePlayer.GetLevel()));
							} else {
								finisherChance = theGame.params.FINISHER_ON_DEATH_CHANCE;
							}
						}
					}
				}
				finisherChance = ClampF(finisherChance, 0, 100);
			} else {
				finisherChance = 0;
			}
		}
		
		if (context.finisher.auto) {
			finisherChance = 100;
		} else if (context.finisher.instantKill) {
			finisherChance = 100;
		}
		
		if (context.finisher.auto) {
			areEnemiesAttackingModifier = !theGame.xtFinishersMgr.defaultModule.params.FINISHER_AUTO_REQUIRE_NO_AGGRO;
			navCheckModifier = !theGame.xtFinishersMgr.defaultModule.params.FINISHER_AUTO_REQUIRE_NAV_CHECK;
		} else if (context.finisher.instantKill) {
			areEnemiesAttackingModifier = !theGame.xtFinishersMgr.defaultModule.params.FINISHER_INSTANTKILL_REQUIRE_NO_AGGRO;
			navCheckModifier = !theGame.xtFinishersMgr.defaultModule.params.FINISHER_INSTANTKILL_REQUIRE_NAV_CHECK;
		} else {
			areEnemiesAttackingModifier = !theGame.xtFinishersMgr.defaultModule.params.FINISHER_REQUIRE_NO_AGGRO;
			navCheckModifier = !theGame.xtFinishersMgr.defaultModule.params.FINISHER_REQUIRE_NAV_CHECK;
		}
		
			
		item = thePlayer.inv.GetItemFromSlot('l_weapon');	

		result = ((CR4Player)context.action.attacker) && attackAction && attackAction.IsActionMelee();
		result = result && (actorVictim.IsHuman() && !actorVictim.IsWoman());
		result = result && RandRangeF(100) < finisherChance;
		result = result && (!areEnemiesAttacking || areEnemiesAttackingModifier);
		result = result && AbsF(victimToPlayerVector.Z) < 0.4f;
		result = result && !thePlayer.IsInAir();
		result = result && (thePlayer.IsWeaponHeld('steelsword') || thePlayer.IsWeaponHeld('silversword'));
		result = result && !thePlayer.IsSecondaryWeaponHeld();
		result = result && !thePlayer.inv.IsIdValid(item);
		result = result && !actorVictim.IsKnockedUnconscious();
		result = result && !context.effectsSnapshot.HasEffect(EET_Knockdown);
		result = result && !context.effectsSnapshot.HasEffect(EET_Ragdoll);
		result = result && !context.effectsSnapshot.HasEffect(EET_Frozen);
		result = result && !actorVictim.HasAbility('DisableFinishers');
		result = result && actorVictim.GetAttitude(thePlayer) == AIA_Hostile;
		result = result && !thePlayer.IsUsingVehicle();
		result = result && thePlayer.IsAlive();
		result = result && !thePlayer.IsCurrentSignChanneled();
		result = result && (theGame.GetWorld().NavigationCircleTest(actorVictim.GetWorldPosition(), 2.f) || navCheckModifier) ;
		
		if (context.finisher.forced || (thePlayer.forceFinisher && actorVictim.IsHuman())) {
			context.finisher.active = true;
		} else if (result) {
			if (!actorVictim.IsAlive()) {
				actorVictim.AddAbility('DisableFinishers', false);
			}
			context.finisher.active = true;
		}
	}
}

class XTFinishersDefaultDismemberQueryResponder extends XTFinishersDismemberQueryResponder {
	public function CanPerformDismember(out context : XTFinishersActionContext) {
		var playerAttacker		: CR4Player;
		var actorAttacker		: CActor;
		var actorVictim			: CActor;
		var attackAction		: W3Action_Attack;
		var weaponId			: SItemUniqueId;
		var weaponName			: name;
		var result				: bool;
		var dismemberChance 	: float;
		var petard 				: W3Petard;
		var bolt 				: W3BoltProjectile;
		var arrow 				: W3ArrowProjectile;
		var inv					: CInventoryComponent;
		var toxicCloud			: W3ToxicCloud;
		var witcher				: W3PlayerWitcher;
		var i					: int;
		var secondaryWeapon		: bool;
		
		if (context.finisher.active || context.action.victim.IsAlive()) {
			return;
		}
		
		playerAttacker = (CR4Player)context.action.attacker;
		actorAttacker = (CActor)context.action.attacker;
		actorVictim = (CActor)context.action.victim;
		attackAction = (W3Action_Attack)context.action;
		
		petard = (W3Petard)context.action.causer;
		bolt = (W3BoltProjectile)context.action.causer;
		arrow = (W3ArrowProjectile)context.action.causer;
		toxicCloud = (W3ToxicCloud)context.action.causer;
		
		if (attackAction) {
			weaponId = attackAction.GetWeaponId();
		}
		
		if(playerAttacker) {
			secondaryWeapon = playerAttacker.inv.ItemHasTag(weaponId, 'SecondaryWeapon') || playerAttacker.inv.ItemHasTag(weaponId, 'Wooden');
		}
		
		if(actorVictim.HasAbility('DisableDismemberment')) {
			result = false;
		} else if (actorVictim.HasTag('DisableDismemberment')) {
			result = false;
		} else if (actorVictim.WillBeUnconscious()) {
			result = false;		
		} else if (playerAttacker && secondaryWeapon) {
			result = false;
		} else if (arrow) {
			result = false;
		} else if (actorAttacker.HasAbility('ForceDismemberment')) {
			context.dismember.forced = true;
			result = true;
		} else if (context.effectsSnapshot.HasEffect(EET_Frozen)) {
			result = true;
		} else if ((petard && petard.DismembersOnKill()) || (bolt && bolt.DismembersOnKill())) {
			result = true;
		} else if ((W3Effect_YrdenHealthDrain)context.action.causer) {
			context.dismember.explosion = true;
			result = true;
		} else if (toxicCloud && toxicCloud.HasExplodingTargetDamages()) {
			context.dismember.explosion = true;
			result = true;
		} else {
			inv = actorAttacker.GetInventory();
			weaponName = inv.GetItemName(weaponId);
			
			if(attackAction && !inv.IsItemSteelSwordUsableByPlayer(weaponId) && !inv.IsItemSilverSwordUsableByPlayer(weaponId) 
					&& weaponName != 'polearm'
					&& weaponName != 'fists_lightning' 
					&& weaponName != 'fists_fire') {
				result = false;
			} else {
				if (attackAction && attackAction.IsActionMelee()) {
					if (attackAction.IsCriticalHit() && RandRangeF(100) < theGame.xtFinishersMgr.defaultModule.params.DISMEMBER_AUTO_CHANCE_CRIT) {
						context.dismember.explosion = RandRangeF(100) < theGame.xtFinishersMgr.defaultModule.params.DISMEMBER_AUTO_EXPLOSION_CHANCE_CRIT;
						context.dismember.auto = true;
						result = true;
					} else if (SkillNameToEnum(attackAction.GetAttackTypeName()) == S_Sword_s02 && RandRangeF(100) < theGame.xtFinishersMgr.defaultModule.params.DISMEMBER_AUTO_CHANCE_REND) {
						context.dismember.explosion = RandRangeF(100) < theGame.xtFinishersMgr.defaultModule.params.DISMEMBER_AUTO_EXPLOSION_CHANCE_REND;
						context.dismember.auto = true;
						result = true;
					} else if ((W3PlayerWitcher)playerAttacker && playerAttacker.GetBehaviorVariable('combatActionType') == (int)CAT_SpecialAttack && playerAttacker.GetBehaviorVariable('playerAttackType') == 0 && RandRangeF(100) < theGame.xtFinishersMgr.defaultModule.params.DISMEMBER_AUTO_CHANCE_WHIRL) {
						context.dismember.explosion = RandRangeF(100) < theGame.xtFinishersMgr.defaultModule.params.DISMEMBER_AUTO_EXPLOSION_CHANCE_WHIRL;
						context.dismember.auto = true;
						result = true;
					} else if (playerAttacker.IsHeavyAttack(attackAction.GetAttackName()) && RandRangeF(100) < theGame.xtFinishersMgr.defaultModule.params.DISMEMBER_AUTO_CHANCE_STRONG) {
						context.dismember.explosion = RandRangeF(100) < theGame.xtFinishersMgr.defaultModule.params.DISMEMBER_AUTO_EXPLOSION_CHANCE_STRONG;
						context.dismember.auto = true;
						result = true;
					} else if (playerAttacker.IsLightAttack(attackAction.GetAttackName()) && RandRangeF(100) < theGame.xtFinishersMgr.defaultModule.params.DISMEMBER_AUTO_CHANCE_FAST) {
						context.dismember.explosion = RandRangeF(100) < theGame.xtFinishersMgr.defaultModule.params.DISMEMBER_AUTO_EXPLOSION_CHANCE_FAST;
						context.dismember.auto = true;
						result = true;
					} else if (thePlayer.IsLastEnemyKilled() && RandRangeF(100) < theGame.xtFinishersMgr.defaultModule.params.DISMEMBER_AUTO_CHANCE_LAST_ENEMY) {
						context.dismember.explosion = RandRangeF(100) < theGame.xtFinishersMgr.defaultModule.params.DISMEMBER_AUTO_EXPLOSION_CHANCE_LAST_ENEMY;
						context.dismember.auto = true;
						result = true;
					}
				}
				
				if (!result) {
					dismemberChance = theGame.params.DISMEMBERMENT_ON_DEATH_CHANCE;
					
					if (playerAttacker && playerAttacker.forceDismember) {
						dismemberChance = thePlayer.forceDismemberChance;
						context.dismember.explosion = thePlayer.forceDismemberExplosion;
					}
					
					if (attackAction) {
						dismemberChance += RoundMath(100 * CalculateAttributeValue(inv.GetItemAttributeValue(weaponId, 'dismember_chance')));
						context.dismember.explosion = attackAction.HasForceExplosionDismemberment();
					}
						
					witcher = (W3PlayerWitcher)actorAttacker;
					if (witcher && witcher.CanUseSkill(S_Perk_03)) {
						dismemberChance += RoundMath(100 * CalculateAttributeValue(witcher.GetSkillAttributeValue(S_Perk_03, 'dismember_chance', false, true)));
					}
					
					dismemberChance = ClampF(dismemberChance, 0, 100);
					
					if (RandRangeF(100) < dismemberChance) {
						result = true;
					} else {
						result = false;
					}
				}
			}
		}
		
		context.dismember.active = result;
	}
}

class XTFinishersDefaultFinisherCamQueryResponder extends XTFinishersFinisherCamQueryResponder {
	public function CanPerformFinisherCam(out context : XTFinishersActionContext) {
		var chance : float;
		
		if (thePlayer.IsLastEnemyKilled()) {
			chance = theGame.xtFinishersMgr.defaultModule.params.FINISHER_CAM_CHANCE_LAST_ENEMY;
		} else {
			chance = theGame.xtFinishersMgr.defaultModule.params.FINISHER_CAM_CHANCE;
		}
	
		context.finisherCam.active = RandRangeF(100) < chance
				&& (!theGame.xtFinishersMgr.defaultModule.params.FINISHER_CAM_REQUIRE_NAV_CHECK || theGame.GetWorld().NavigationCircleTest(thePlayer.GetWorldPosition(), 3.f));
	}
}

class XTFinishersDefaultSlowdownQueryResponder extends XTFinishersSlowdownQueryResponder {
	protected function CanPerformSlowdownFinisher(out context : XTFinishersActionContext) {
		var chance : float;
		
		if (thePlayer.IsLastEnemyKilled()) {
			if (context.finisher.auto) {
				chance = theGame.xtFinishersMgr.defaultModule.params.SLOWDOWN_FINISHER_AUTO_CHANCE_LAST_ENEMY;
			} else {
				chance = theGame.xtFinishersMgr.defaultModule.params.SLOWDOWN_FINISHER_CHANCE_LAST_ENEMY;
			}
		} else {
			if (context.finisher.auto) {
				chance = theGame.xtFinishersMgr.defaultModule.params.SLOWDOWN_FINISHER_AUTO_CHANCE;
			} else {
				chance = theGame.xtFinishersMgr.defaultModule.params.SLOWDOWN_FINISHER_CHANCE;
			}
		}
		
		context.slowdown.active = RandRangeF(100) < chance;
	}
	
	protected function CanPerformSlowdownDismember(out context : XTFinishersActionContext) {
		var chance : float;
		
		if (thePlayer.IsLastEnemyKilled()) {
			if (context.dismember.auto) {
				chance = theGame.xtFinishersMgr.defaultModule.params.SLOWDOWN_DISMEMBER_AUTO_CHANCE_LAST_ENEMY;
			} else {
				chance = theGame.xtFinishersMgr.defaultModule.params.SLOWDOWN_DISMEMBER_CHANCE_LAST_ENEMY;
			}
		} else {
			if (context.dismember.auto) {
				chance = theGame.xtFinishersMgr.defaultModule.params.SLOWDOWN_DISMEMBER_AUTO_CHANCE;
			} else {
				chance = theGame.xtFinishersMgr.defaultModule.params.SLOWDOWN_DISMEMBER_CHANCE;
			}
		}
		
		context.slowdown.active = RandRangeF(100) < chance;
	}
	
	public function CanPerformSlowdown(out context : XTFinishersActionContext) {
		if (thePlayer.IsCameraControlDisabled('Finisher')) {
			return;
		}
		
		switch (context.slowdown.type) {
		case theGame.xtFinishersMgr.consts.SLOWDOWN_TYPE_FINISHER :
			CanPerformSlowdownFinisher(context);
			break;
		case theGame.xtFinishersMgr.consts.SLOWDOWN_TYPE_DISMEMBER :
			CanPerformSlowdownDismember(context);
			break;
		}
	}
}

// slowdown

class XTFinishersDefaultSlowdownManager extends XTFinishersAbstractSlowdownManager {
	private var finisherSeqDef, dismemberSeqDef : XTFinishersSlowdownSequenceDef;
	
	public function Init() {
		var temp : XTFinishersSlowdownSegment;
		
		super.Init();
		
		// define finisher slowdown sequence
		finisherSeqDef = new XTFinishersSlowdownSequenceDef in this;
		if (theGame.xtFinishersMgr.defaultModule.params.SLOWDOWN_FINISHER_A_DELAY > 0) {
			temp = new XTFinishersSlowdownDelay in this;
			temp.Init(theGame.xtFinishersMgr.defaultModule.params.SLOWDOWN_FINISHER_A_DELAY);
			finisherSeqDef.AddSegment(temp);
		}
		if (theGame.xtFinishersMgr.defaultModule.params.SLOWDOWN_FINISHER_A_DURATION > 0) {
			temp = new XTFinishersSlowdownSession in this;
			((XTFinishersSlowdownSession)temp).Init_Session(theGame.xtFinishersMgr.defaultModule.params.SLOWDOWN_FINISHER_A_DURATION, theGame.xtFinishersMgr.defaultModule.params.SLOWDOWN_FINISHER_A_FACTOR);
			finisherSeqDef.AddSegment(temp);
		}
		if (theGame.xtFinishersMgr.defaultModule.params.SLOWDOWN_FINISHER_B_DELAY > 0) {
			temp = new XTFinishersSlowdownDelay in this;
			temp.Init(theGame.xtFinishersMgr.defaultModule.params.SLOWDOWN_FINISHER_B_DELAY);
			finisherSeqDef.AddSegment(temp);
		}
		if (theGame.xtFinishersMgr.defaultModule.params.SLOWDOWN_FINISHER_B_DURATION > 0) {
			temp = new XTFinishersSlowdownSession in this;
			((XTFinishersSlowdownSession)temp).Init_Session(theGame.xtFinishersMgr.defaultModule.params.SLOWDOWN_FINISHER_B_DURATION, theGame.xtFinishersMgr.defaultModule.params.SLOWDOWN_FINISHER_B_FACTOR);
			finisherSeqDef.AddSegment(temp);
		}
		
		// define dismember slowdown sequence
		dismemberSeqDef = new XTFinishersSlowdownSequenceDef in this;
		if (theGame.xtFinishersMgr.defaultModule.params.SLOWDOWN_DISMEMBER_DELAY > 0) {
			temp = new XTFinishersSlowdownDelay in this;
			temp.Init(theGame.xtFinishersMgr.defaultModule.params.SLOWDOWN_DISMEMBER_DELAY);
			dismemberSeqDef.AddSegment(temp);
		}
		if (theGame.xtFinishersMgr.defaultModule.params.SLOWDOWN_DISMEMBER_DURATION > 0) {
			temp = new XTFinishersSlowdownSession in this;
			((XTFinishersSlowdownSession)temp).Init_Session(theGame.xtFinishersMgr.defaultModule.params.SLOWDOWN_DISMEMBER_DURATION, theGame.xtFinishersMgr.defaultModule.params.SLOWDOWN_DISMEMBER_FACTOR);
			dismemberSeqDef.AddSegment(temp);
		}
	}
	
	protected function OnSlowdownSequenceStart(context : XTFinishersActionContext) {
		var seqDef : XTFinishersSlowdownSequenceDef;
		
		seqDef = NULL;
		switch (context.slowdown.type) {
		case theGame.xtFinishersMgr.consts.SLOWDOWN_TYPE_FINISHER :
			seqDef = finisherSeqDef;
			break;
		case theGame.xtFinishersMgr.consts.SLOWDOWN_TYPE_DISMEMBER :
			seqDef = dismemberSeqDef;
			break;
		}
		
		if (seqDef) {
			StartSlowdownSequence(seqDef);
		}
	}
}