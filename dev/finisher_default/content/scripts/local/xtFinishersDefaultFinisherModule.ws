class XTFinishersDefaultFinisherModule {
	public var params : XTFinishersDefaultFinisherParams;
	
	public function Init() {
		params = new XTFinishersDefaultFinisherParams in this;
		params.Init();
		
		theGame.xtFinishersMgr.queryMgr.LoadFinisherResponder(GetNewFinisherQueryResponderInstance());
		theGame.xtFinishersMgr.queryMgr.LoadFinisherCamResponder(GetNewFinisherCamQueryResponderInstance());
		
		theGame.xtFinishersMgr.eventMgr.RegisterEventListener(theGame.xtFinishersMgr.consts.REACTION_START_EVENT_ID, GetNewFinisherQueryDispatcherInstance());
		theGame.xtFinishersMgr.eventMgr.RegisterEventListener(theGame.xtFinishersMgr.consts.FINISHER_EVENT_ID, GetNewFinisherCamQueryDispatcherInstance());
	}
	
	protected function GetNewFinisherQueryResponderInstance() : XTFinishersFinisherQueryResponder {
		return new XTFinishersDefaultFinisherQueryResponder in this;
	}
	
	protected function GetNewFinisherCamQueryResponderInstance() : XTFinishersFinisherCamQueryResponder {
		return new XTFinishersDefaultFinisherCamQueryResponder in this;
	}
	
	protected function GetNewFinisherQueryDispatcherInstance() : XTFinishersAbstractReactionStartListener {
		return new XTFinishersDefaultFinisherQueryDispatcher in this;
	}
	
	protected function GetNewFinisherCamQueryDispatcherInstance() : XTFinishersAbstractFinisherListener {
		return new XTFinishersDefaultFinisherCamQueryDispatcher in this;
	}
}

// listeners

class XTFinishersDefaultFinisherQueryDispatcher extends XTFinishersAbstractReactionStartEventListener {
	public function GetPriority() : int {
		return theGame.xtFinishersMgr.consts.DEFAULT_FINISHER_QUERY_DISPATCHER_PRIORITY;
	}
	
	public function OnReactionStartTriggered(out context : XTFinishersActionContext) {
		theGame.xtFinishersMgr.queryMgr.FireFinisherQuery(context);
	}
}

class XTFinishersDefaultFinisherCamQueryDispatcher extends XTFinishersAbstractFinisherEventListener {
	public function GetPriority() : int {
		return theGame.xtFinishersMgr.consts.DEFAULT_FINISHER_CAM_QUERY_DISPATCHER_PRIORITY;
	}
	
	public function OnFinisherTriggered(out context : XTFinishersActionContext) {
		theGame.xtFinishersMgr.queryMgr.FireFinisherCamQuery(context);
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
			if (attackAction.IsCriticalHit() && RandRangeF(100) < theGame.xtFinishersMgr.finisherModule.params.FINISHER_AUTO_CHANCE_CRIT) {
				result = true;
			} else if (SkillNameToEnum(attackAction.GetAttackTypeName()) == S_Sword_s02 && RandRangeF(100) < theGame.xtFinishersMgr.finisherModule.params.FINISHER_AUTO_CHANCE_REND) {
				result = true;
			} else if (thePlayer.IsLastEnemyKilled() && RandRangeF(100) < theGame.xtFinishersMgr.finisherModule.params.FINISHER_AUTO_CHANCE_LAST_ENEMY) {
				result = true;
			} else {
				hasEffect = false;
				autoFinisherEffectTypes = theGame.xtFinishersMgr.finisherModule.params.autoFinisherEffectTypes;
				for (i = 0; i < autoFinisherEffectTypes.Size(); i += 1) {
					hasEffect = context.effectsSnapshot.HasEffect(autoFinisherEffectTypes[i]);
					if (hasEffect) {
						break;
					}
				}
				result = hasEffect && RandRangeF(100) < theGame.xtFinishersMgr.finisherModule.params.FINISHER_AUTO_CHANCE_EFFECTS;
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
		
		if (actorVictim.IsHuman() && actorVictim.IsVulnerable() && !actorVictim.HasAbility('InstantKillImmune')) {
			if (attackAction) {
				if (attackAction.IsCriticalHit() && RandRangeF(100) < theGame.xtFinishersMgr.finisherModule.params.FINISHER_INSTANTKILL_CHANCE_CRIT) {
					result = true;
				} else if (thePlayer.IsLastEnemyKilled() && RandRangeF(100) < theGame.xtFinishersMgr.finisherModule.params.FINISHER_INSTANTKILL_CHANCE_LAST_ENEMY) {
					result = true;
				} else {
					hasEffect = false;
					instantKillFinisherEffectTypes = theGame.xtFinishersMgr.finisherModule.params.instantKillFinisherEffectTypes;
					for (i = 0; i < instantKillFinisherEffectTypes.Size(); i += 1) {
						hasEffect = context.effectsSnapshot.HasEffect(instantKillFinisherEffectTypes[i]);
						if (hasEffect) {
							break;
						}
					}
					result = hasEffect && RandRangeF(100) < theGame.xtFinishersMgr.finisherModule.params.FINISHER_INSTANTKILL_CHANCE_EFFECTS;
				}
			}
		}
		
		return result;
	}
	
	protected function SelectFinisherAnimName(context : XTFinishersActionContext) : name {
		var animNames : array<name>;
		
		if (thePlayer.forceFinisher && thePlayer.forceFinisherAnimName != '') {
			return thePlayer.forceFinisherAnimName;
		}
		
		if (thePlayer.GetCombatIdleStance() <= 0.f) {
			animNames = theGame.xtFinishersMgr.finisherModule.params.allowedLeftSideFinisherAnimNames;
		} else {
			animNames = theGame.xtFinishersMgr.finisherModule.params.allowedRightSideFinisherAnimNames;
		}
		return animNames[RandRange(animNames.Size(), 0)];
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
		
		if (actorVictim.IsAlive()) {
			context.finisher.instantKill = CanPerformInstantKillFinisher(context);
			if (!context.finisher.instantKill) {
				return;
			}
		} else {
			context.finisher.forced = actorVictim.HasTag('ForceFinisher');
				
			if (!context.finisher.forced) {
				if (actorVictim.IsHuman()) {
					context.finisher.auto = CanPerformAutoFinisher(context);
					
					npc = (CNewNPC)actorVictim;
					if (!context.finisher.auto) {
						if (( size <= 1 && theGame.params.FINISHER_ON_DEATH_CHANCE > 0) || (actorVictim.HasAbility('ForceFinisher'))) {
							finisherChance = 100;
						} else if (theGame.xtFinishersMgr.finisherModule.params.FINISHER_CHANCE_OVERRIDE) {
							finisherChance = theGame.xtFinishersMgr.finisherModule.params.FINISHER_CHANCE_BASE;
							levelDelta = thePlayer.GetLevel() - npc.currentLevel;
							if (levelDelta >= 0) {
								finisherChance += theGame.xtFinishersMgr.finisherModule.params.FINISHER_CHANCE_LEVEL_BONUS * levelDelta;
							} else {
								finisherChance += theGame.xtFinishersMgr.finisherModule.params.FINISHER_CHANCE_LEVEL_PENALTY * levelDelta;
							}
						} else {
							if (npc.currentLevel - thePlayer.GetLevel() < -5) {
								finisherChance = theGame.params.FINISHER_ON_DEATH_CHANCE + (-(npc.currentLevel - thePlayer.GetLevel()));
							} else {
								finisherChance = theGame.params.FINISHER_ON_DEATH_CHANCE;
							}
						}
					}
					finisherChance = ClampF(finisherChance, 0, 100);
				} else {
					finisherChance = 0;
				}
			}
		}
		
		if (thePlayer.forceFinisher && actorVictim.IsHuman()) {
			context.finisher.active = true;
			context.finisher.forced = true;
			return;
		}
		
		if (context.finisher.auto) {
			finisherChance = 100;
		} else if (context.finisher.instantKill) {
			finisherChance = 100;
		}
		
		if (context.finisher.auto) {
			areEnemiesAttackingModifier = !theGame.xtFinishersMgr.finisherModule.params.FINISHER_AUTO_REQUIRE_NO_AGGRO;
			navCheckModifier = !theGame.xtFinishersMgr.finisherModule.params.FINISHER_AUTO_REQUIRE_NAV_CHECK;
		} else if (context.finisher.instantKill) {
			areEnemiesAttackingModifier = !theGame.xtFinishersMgr.finisherModule.params.FINISHER_INSTANTKILL_REQUIRE_NO_AGGRO;
			navCheckModifier = !theGame.xtFinishersMgr.finisherModule.params.FINISHER_INSTANTKILL_REQUIRE_NAV_CHECK;
		} else {
			areEnemiesAttackingModifier = !theGame.xtFinishersMgr.finisherModule.params.FINISHER_REQUIRE_NO_AGGRO;
			navCheckModifier = !theGame.xtFinishersMgr.finisherModule.params.FINISHER_REQUIRE_NAV_CHECK;
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
		
		if (result) {
			if (!actorVictim.IsAlive()) {
				actorVictim.AddAbility('DisableFinishers', false);
			}
			context.finisher.active = true;
		}
	}
}

class XTFinishersDefaultFinisherCamQueryResponder extends XTFinishersFinisherCamQueryResponder {
	public function CanPerformFinisherCam(out context : XTFinishersActionContext) {
		var chance : float;
		
		if (thePlayer.IsLastEnemyKilled()) {
			chance = theGame.xtFinishersMgr.finisherModule.params.FINISHER_CAM_CHANCE_LAST_ENEMY;
		} else {
			chance = theGame.xtFinishersMgr.finisherModule.params.FINISHER_CAM_CHANCE;
		}
	
		context.finisherCam.active = RandRangeF(100) < chance
				&& (!theGame.xtFinishersMgr.finisherModule.params.FINISHER_CAM_REQUIRE_NAV_CHECK || theGame.GetWorld().NavigationCircleTest(thePlayer.GetWorldPosition(), 3.f));
	}
}