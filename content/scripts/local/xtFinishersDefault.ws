// responders

class XTFinishersDefaultFinisherQueryResponder extends XTFinishersFinisherQueryResponder {
	protected function CanPerformAutoFinisher(context : XTFinishersFinisherContext) : bool {
		var attackAction : W3Action_Attack;
		var result : bool;
		var hasEffect : bool;
		var autoFinisherEffectTypes : array<EEffectType>;
		var i : int;
		
		result = false;
		attackAction = (W3Action_Attack)context.action;
		
		if (attackAction) {
			if (attackAction.IsCriticalHit() && RandRangeF(100) < theGame.xtFinishersMgr.params.FINISHER_AUTO_CHANCE_CRIT) {
				result = true;
			} else if (SkillNameToEnum(attackAction.GetAttackTypeName()) == S_Sword_s02 && RandRangeF(100) < theGame.xtFinishersMgr.params.FINISHER_AUTO_CHANCE_REND) {
				result = true;
			} else if (thePlayer.IsLastEnemyKilled() && RandRangeF(100) < theGame.xtFinishersMgr.params.FINISHER_AUTO_CHANCE_LAST_ENEMY) {
				result = true;
			} else {
				hasEffect = false;
				autoFinisherEffectTypes = theGame.xtFinishersMgr.params.autoFinisherEffectTypes;
				for (i = 0; i < autoFinisherEffectTypes.Size(); i += 1) {
					hasEffect = context.effectsSnapshot.HasEffect(autoFinisherEffectTypes[i]);
					if (hasEffect) {
						break;
					}
				}
				result = hasEffect && RandRangeF(100) < theGame.xtFinishersMgr.params.FINISHER_AUTO_CHANCE_EFFECTS;
			}
		}
		
		return result;
	}
	
	protected function CanPerformInstantKillFinisher(context : XTFinishersFinisherContext) : bool {
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
				if (attackAction.IsCriticalHit() && RandRangeF(100) < theGame.xtFinishersMgr.params.FINISHER_INSTANTKILL_CHANCE_CRIT) {
					result = true;
				} else if (thePlayer.IsLastEnemyKilled() && RandRangeF(100) < theGame.xtFinishersMgr.params.FINISHER_INSTANTKILL_CHANCE_LAST_ENEMY) {
					result = true;
				} else {
					hasEffect = false;
					instantKillFinisherEffectTypes = theGame.xtFinishersMgr.params.instantKillFinisherEffectTypes;
					for (i = 0; i < instantKillFinisherEffectTypes.Size(); i += 1) {
						hasEffect = context.effectsSnapshot.HasEffect(instantKillFinisherEffectTypes[i]);
						if (hasEffect) {
							break;
						}
					}
					result = hasEffect && RandRangeF(100) < theGame.xtFinishersMgr.params.FINISHER_INSTANTKILL_CHANCE_EFFECTS;
				}
			}
		}
		
		return result;
	}
	
	public function CanPerformFinisher(out context : XTFinishersFinisherContext) {
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
		
		context.forced = actorVictim.HasTag('ForceFinisher');
			
		if (!context.forced) {
			if (actorVictim.IsHuman()) {
				if (actorVictim.IsAlive()) {
					context.instantKill = CanPerformInstantKillFinisher(context);
				} else {
					context.auto = CanPerformAutoFinisher(context);
					
					npc = (CNewNPC)actorVictim;
					if (!context.forced && !context.auto) {
						if (( size <= 1 && theGame.params.FINISHER_ON_DEATH_CHANCE > 0) || (actorVictim.HasAbility('ForceFinisher'))) {
							finisherChance = 100;
						} else if (theGame.xtFinishersMgr.params.FINISHER_CHANCE_OVERRIDE) {
							finisherChance = theGame.xtFinishersMgr.params.FINISHER_CHANCE_BASE;
							levelDelta = thePlayer.GetLevel() - npc.currentLevel;
							if (levelDelta >= 0) {
								finisherChance += theGame.xtFinishersMgr.params.FINISHER_CHANCE_LEVEL_BONUS * levelDelta;
							} else {
								finisherChance += theGame.xtFinishersMgr.params.FINISHER_CHANCE_LEVEL_PENALTY * levelDelta;
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
		
		if (context.auto) {
			finisherChance = 100;
		} else if (context.instantKill) {
			finisherChance = 100;
		}
		
		if (context.auto) {
			areEnemiesAttackingModifier = !theGame.xtFinishersMgr.params.FINISHER_AUTO_REQUIRE_NO_AGGRO;
			navCheckModifier = !theGame.xtFinishersMgr.params.FINISHER_AUTO_REQUIRE_NAV_CHECK;
		} else if (context.instantKill) {
			areEnemiesAttackingModifier = !theGame.xtFinishersMgr.params.FINISHER_INSTANTKILL_REQUIRE_NO_AGGRO;
			navCheckModifier = !theGame.xtFinishersMgr.params.FINISHER_INSTANTKILL_REQUIRE_NAV_CHECK;
		} else {
			areEnemiesAttackingModifier = !theGame.xtFinishersMgr.params.FINISHER_REQUIRE_NO_AGGRO;
			navCheckModifier = !theGame.xtFinishersMgr.params.FINISHER_REQUIRE_NAV_CHECK;
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
		
		if (context.forced || (thePlayer.forceFinisher && actorVictim.IsHuman())) {
			context.active = true;
		} else if (result) {
			if (!actorVictim.IsAlive()) {
				actorVictim.AddAbility('DisableFinishers', false);
			}
			context.active = true;
		}
	}
}

class XTFinishersDefaultDismemberQueryResponder extends XTFinishersDismemberQueryResponder {
	public function CanPerformDismember(out context : XTFinishersDismemberContext) {
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
			context.forced = true;
			result = true;
		} else if (context.effectsSnapshot.HasEffect(EET_Frozen)) {
			context.forced = true;
			result = true;
		} else if ((petard && petard.DismembersOnKill()) || (bolt && bolt.DismembersOnKill())) {
			context.forced = true;
			result = true;
		} else if ((W3Effect_YrdenHealthDrain)context.action.causer) {
			context.explosion = true;
			context.forced = true;
			result = true;
		} else if (toxicCloud && toxicCloud.HasExplodingTargetDamages()) {
			context.explosion = true;
			context.forced = true;
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
					if (attackAction.IsCriticalHit() && RandRangeF(100) < theGame.xtFinishersMgr.params.DISMEMBER_AUTO_CHANCE_CRIT) {
						context.explosion = RandRangeF(100) < theGame.xtFinishersMgr.params.DISMEMBER_AUTO_EXPLOSION_CHANCE_CRIT;
						context.auto = true;
						result = true;
					} else if (SkillNameToEnum(attackAction.GetAttackTypeName()) == S_Sword_s02 && RandRangeF(100) < theGame.xtFinishersMgr.params.DISMEMBER_AUTO_CHANCE_REND) {
						context.explosion = RandRangeF(100) < theGame.xtFinishersMgr.params.DISMEMBER_AUTO_EXPLOSION_CHANCE_REND;
						context.auto = true;
						result = true;
					} else if ((W3PlayerWitcher)playerAttacker && playerAttacker.GetBehaviorVariable('combatActionType') == (int)CAT_SpecialAttack && playerAttacker.GetBehaviorVariable('playerAttackType') == 0 && RandRangeF(100) < theGame.xtFinishersMgr.params.DISMEMBER_AUTO_CHANCE_WHIRL) {
						context.explosion = RandRangeF(100) < theGame.xtFinishersMgr.params.DISMEMBER_AUTO_EXPLOSION_CHANCE_WHIRL;
						context.auto = true;
						result = true;
					} else if (playerAttacker.IsHeavyAttack(attackAction.GetAttackName()) && RandRangeF(100) < theGame.xtFinishersMgr.params.DISMEMBER_AUTO_CHANCE_STRONG) {
						context.explosion = RandRangeF(100) < theGame.xtFinishersMgr.params.DISMEMBER_AUTO_EXPLOSION_CHANCE_STRONG;
						context.auto = true;
						result = true;
					} else if (playerAttacker.IsLightAttack(attackAction.GetAttackName()) && RandRangeF(100) < theGame.xtFinishersMgr.params.DISMEMBER_AUTO_CHANCE_FAST) {
						context.explosion = RandRangeF(100) < theGame.xtFinishersMgr.params.DISMEMBER_AUTO_EXPLOSION_CHANCE_FAST;
						context.auto = true;
						result = true;
					} else if (thePlayer.IsLastEnemyKilled() && RandRangeF(100) < theGame.xtFinishersMgr.params.DISMEMBER_AUTO_CHANCE_LAST_ENEMY) {
						context.explosion = RandRangeF(100) < theGame.xtFinishersMgr.params.DISMEMBER_AUTO_EXPLOSION_CHANCE_LAST_ENEMY;
						context.auto = true;
						result = true;
					}
				}
				
				if (!result) {
					dismemberChance = theGame.params.DISMEMBERMENT_ON_DEATH_CHANCE;
					
					if (playerAttacker && playerAttacker.forceDismember) {
						dismemberChance = thePlayer.forceDismemberChance;
						context.explosion = thePlayer.forceDismemberExplosion;
					}
					
					if (attackAction) {
						dismemberChance += RoundMath(100 * CalculateAttributeValue(inv.GetItemAttributeValue(weaponId, 'dismember_chance')));
						context.explosion = attackAction.HasForceExplosionDismemberment();
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
		context.camShake = theGame.xtFinishersMgr.params.DISMEMBER_CAMERA_SHAKE;
		context.active = result;
	}
}

class XTFinishersDefaultFinisherCamQueryResponder extends XTFinishersFinisherCamQueryResponder {
	public function CanPerformFinisherCam(out context : XTFinishersFinisherCamContext) {
		var chance : float;
		
		if (thePlayer.IsLastEnemyKilled()) {
			chance = theGame.xtFinishersMgr.params.FINISHER_CAM_CHANCE_LAST_ENEMY;
		} else {
			chance = theGame.xtFinishersMgr.params.FINISHER_CAM_CHANCE;
		}
	
		context.active = RandRangeF(100) < chance
				&& (!theGame.xtFinishersMgr.params.FINISHER_CAM_REQUIRE_NAV_CHECK || theGame.GetWorld().NavigationCircleTest(thePlayer.GetWorldPosition(), 3.f));
	}
}

class XTFinishersDefaultSlowdownQueryResponder extends XTFinishersSlowdownQueryResponder {
	public function CanPerformSlowdownFinisher(out context : XTFinishersSlowdownContext) {
		var chance : float;
		
		if (thePlayer.IsCameraControlDisabled('Finisher')) {
			context.active = false;
			return;
		}
		
		if (thePlayer.IsLastEnemyKilled()) {
			if (context.finisherContext.auto) {
				chance = theGame.xtFinishersMgr.params.SLOWDOWN_FINISHER_AUTO_CHANCE_LAST_ENEMY;
			} else {
				chance = theGame.xtFinishersMgr.params.SLOWDOWN_FINISHER_CHANCE_LAST_ENEMY;
			}
		} else {
			if (context.finisherContext.auto) {
				chance = theGame.xtFinishersMgr.params.SLOWDOWN_FINISHER_AUTO_CHANCE;
			} else {
				chance = theGame.xtFinishersMgr.params.SLOWDOWN_FINISHER_CHANCE;
			}
		}
		
		context.active = RandRangeF(100) < chance;
	}
	
	public function CanPerformSlowdownDismember(out context : XTFinishersSlowdownContext) {
		var chance : float;
		
		if (thePlayer.IsCameraControlDisabled('Finisher')) {
			context.active = false;
			return;
		}
		
		if (thePlayer.IsLastEnemyKilled()) {
			if (context.dismemberContext.auto) {
				chance = theGame.xtFinishersMgr.params.SLOWDOWN_DISMEMBER_AUTO_CHANCE_LAST_ENEMY;
			} else {
				chance = theGame.xtFinishersMgr.params.SLOWDOWN_DISMEMBER_CHANCE_LAST_ENEMY;
			}
		} else {
			if (context.dismemberContext.auto) {
				chance = theGame.xtFinishersMgr.params.SLOWDOWN_DISMEMBER_AUTO_CHANCE;
			} else {
				chance = theGame.xtFinishersMgr.params.SLOWDOWN_DISMEMBER_CHANCE;
			}
		}
		
		context.active = RandRangeF(100) < chance;
		if (context.active && theGame.xtFinishersMgr.params.SLOWDOWN_DISMEMBER_DISABLE_CAMERA_SHAKE) {
			context.dismemberContext.camShake = false;
		}
	}
}

// slowdown

class XTFinishersDefaultSlowdownManager extends XTFinishersAbstractSlowdownManager {
	public function Init() {
		var listener : XTFinishersSlowdownFinisherAListener;
		
		super.Init();
		
		listener = new XTFinishersSlowdownFinisherAListener in this;
		listener.Init(0);
		theGame.xtFinishersMgr.eventMgr.RegisterSlowdownListener(listener);
	}
	
	protected function OnSlowdownTriggered(context : XTFinishersSlowdownContext) {
		var listener : XTFinishersSlowdownFinisherAListener;
		
		if (context.isFinisher) {
			PrepSlowdownFinisher(context);
		} else {
			PrepSlowdownDismember(context);
		}
	}
	
	protected function PrepSlowdownFinisher(context : XTFinishersSlowdownContext) {
		if (theGame.xtFinishersMgr.params.SLOWDOWN_FINISHER_A_DELAY <= 0) {
			DoSlowdownFinisherA();
		} else {
			thePlayer.AddTimer('XTFinishersDefaultSlowdownFinisherADelayCallback', theGame.xtFinishersMgr.params.SLOWDOWN_FINISHER_A_DELAY, false);
		}
	}
	
	public function DoSlowdownFinisherA() {
		StartSlowdown(theGame.xtFinishersMgr.params.SLOWDOWN_FINISHER_A_FACTOR, theGame.xtFinishersMgr.params.SLOWDOWN_FINISHER_A_DURATION, "finisher_A");
	}
	
	public function DoSlowdownFinisherB() {
		StartSlowdown(theGame.xtFinishersMgr.params.SLOWDOWN_FINISHER_B_FACTOR, theGame.xtFinishersMgr.params.SLOWDOWN_FINISHER_B_DURATION, "finisher_B");
	}
	
	protected function PrepSlowdownDismember(context : XTFinishersSlowdownContext) {
		if (theGame.xtFinishersMgr.params.SLOWDOWN_DISMEMBER_DELAY <= 0) {
			DoSlowdownDismember();
		} else {
			thePlayer.AddTimer('XTFinishersDefaultSlowdownDismemberDelayCallback', theGame.xtFinishersMgr.params.SLOWDOWN_DISMEMBER_DELAY, false);
		}
	}
	
	public function DoSlowdownDismember() {
		StartSlowdown(theGame.xtFinishersMgr.params.SLOWDOWN_DISMEMBER_FACTOR, theGame.xtFinishersMgr.params.SLOWDOWN_DISMEMBER_DURATION, "dismember");
	}
}

class XTFinishersSlowdownFinisherAListener extends XTFinishersAbstractSlowdownEventListener {
	public function OnSlowdownEnd(success : bool, id : string) {
		if (success && id == "finisher_A") {
			if (theGame.xtFinishersMgr.params.SLOWDOWN_FINISHER_B_DELAY <= 0) {
				((XTFinishersDefaultSlowdownManager)theGame.xtFinishersMgr.slowdownMgr).DoSlowdownFinisherB();
			} else {
				thePlayer.AddTimer('XTFinishersDefaultSlowdownFinisherBDelayCallback', theGame.xtFinishersMgr.params.SLOWDOWN_FINISHER_B_DELAY, false);
			}
		}
	}
}