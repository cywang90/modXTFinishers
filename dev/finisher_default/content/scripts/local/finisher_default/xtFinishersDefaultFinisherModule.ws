class XTFinishersDefaultFinisherModule extends XTFinishersObject {
	public const var DEFAULT_FINISHER_HANDLER_PRIORITY, DEFAULT_FINISHER_CAMSHAKE_DISABLE_HANDLER_PRIORITY : int;
		default DEFAULT_FINISHER_HANDLER_PRIORITY = 0;
		default DEFAULT_FINISHER_CAMSHAKE_DISABLE_HANDLER_PRIORITY = 0;
	
	public var params : XTFinishersDefaultFinisherParams;
	
	public function Init() {
		params = new XTFinishersDefaultFinisherParams in this;
		params.Init();
		
		theGame.xtFinishersMgr.eventMgr.RegisterEventListener(theGame.xtFinishersMgr.consts.REACTION_START_EVENT_ID, GetNewFinisherHandlerInstance());
		theGame.xtFinishersMgr.eventMgr.RegisterEventListener(theGame.xtFinishersMgr.consts.CAMSHAKE_PRE_EVENT_ID, GetNewFinisherCamshakeDisableHandlerInstance());
	}
	
	protected function GetNewFinisherHandlerInstance() : XTFinishersAbstractReactionStartEventListener {
		return new XTFinishersDefaultFinisherHandler in this;
	}
	
	protected function GetNewFinisherCamshakeDisableHandlerInstance() : XTFinishersAbstractCamshakePretriggerEventListener {
		return new XTFinishersDefaultFinisherCamshakeDisableHandler in this;
	}
}

// listeners

class XTFinishersDefaultFinisherHandler extends XTFinishersAbstractReactionStartEventListener {
	public function GetPriority() : int {
		return theGame.xtFinishersMgr.finisherModule.DEFAULT_FINISHER_HANDLER_PRIORITY;
	}
	
	public function OnReactionStartTriggered(context : XTFinishersActionContext) {
		PreprocessFinisher(context);
		if (context.finisher.active) {
			PreprocessFinisherCam(context);
		}
	}
	
	protected function PreprocessFinisher(context : XTFinishersActionContext) {
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
		var areEnemiesAttackingModifier, navCheckModifier, ignoreImmunityModifier : bool;
		
		actorVictim = (CActor)context.action.victim;
		attackAction = (W3Action_Attack)context.action;
		
		if ((W3ReplacerCiri)thePlayer || (CR4Player)context.action.victim || thePlayer.isInFinisher) {
			return;
		}
		
		context.finisher.type = XTF_FINISHER_TYPE_REGULAR;
		
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
			if (CanPerformInstantKillFinisher(context)) {
				context.finisher.type = XTF_FINISHER_TYPE_INSTANTKILL;
				finisherChance = 100;
			} else {
				return;
			}
		} else {
			context.finisher.forced = actorVictim.HasTag('ForceFinisher');
				
			if (!context.finisher.forced) {
				if (actorVictim.IsHuman()) {
					if (CanPerformAutoFinisher(context)) {
						context.finisher.type = XTF_FINISHER_TYPE_AUTO;
						finisherChance = 100;
					} else {
						npc = (CNewNPC)actorVictim;
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
			context.finisher.type = XTF_FINISHER_TYPE_DEBUG;
			return;
		}
		
		switch (context.finisher.type) {
		case XTF_FINISHER_TYPE_AUTO :
			areEnemiesAttackingModifier = !theGame.xtFinishersMgr.finisherModule.params.FINISHER_AUTO_REQUIRE_NO_AGGRO;
			navCheckModifier = !theGame.xtFinishersMgr.finisherModule.params.FINISHER_AUTO_REQUIRE_NAV_CHECK;
			ignoreImmunityModifier = theGame.xtFinishersMgr.finisherModule.params.FINISHER_AUTO_IGNORE_IMMUNITY;
			break;
		case XTF_FINISHER_TYPE_INSTANTKILL :
			areEnemiesAttackingModifier = !theGame.xtFinishersMgr.finisherModule.params.FINISHER_INSTANTKILL_REQUIRE_NO_AGGRO;
			navCheckModifier = !theGame.xtFinishersMgr.finisherModule.params.FINISHER_INSTANTKILL_REQUIRE_NAV_CHECK;
			ignoreImmunityModifier = theGame.xtFinishersMgr.finisherModule.params.FINISHER_INSTANTKILL_IGNORE_IMMUNITY;
			break;
		default :
			areEnemiesAttackingModifier = !theGame.xtFinishersMgr.finisherModule.params.FINISHER_REQUIRE_NO_AGGRO;
			navCheckModifier = !theGame.xtFinishersMgr.finisherModule.params.FINISHER_REQUIRE_NAV_CHECK;
			ignoreImmunityModifier = theGame.xtFinishersMgr.finisherModule.params.FINISHER_IGNORE_IMMUNITY;
		}
		
			
		item = thePlayer.inv.GetItemFromSlot('l_weapon');	

		result = ((CR4Player)context.action.attacker) && attackAction && attackAction.IsActionMelee();
		result = result && (actorVictim.IsHuman() && !actorVictim.IsWoman());
		result = result && RandRangeF(100) < finisherChance;
		result = result && (areEnemiesAttackingModifier || !areEnemiesAttacking);
		result = result && (context.finisher.type == XTF_FINISHER_TYPE_DEBUG || AbsF(victimToPlayerVector.Z) < 0.4f);
		result = result && !thePlayer.IsInAir();
		result = result && (thePlayer.IsWeaponHeld('steelsword') || thePlayer.IsWeaponHeld('silversword'));
		result = result && !thePlayer.IsSecondaryWeaponHeld();
		result = result && !thePlayer.inv.IsIdValid(item);
		result = result && !actorVictim.IsKnockedUnconscious();
		result = result && !context.effectsSnapshot.HasEffect(EET_Knockdown);
		result = result && !context.effectsSnapshot.HasEffect(EET_Ragdoll);
		result = result && !context.effectsSnapshot.HasEffect(EET_Frozen);
		result = result && (context.finisher.type == XTF_FINISHER_TYPE_DEBUG || ignoreImmunityModifier || !actorVictim.HasAbility('DisableFinishers'));
		result = result && (context.finisher.type == XTF_FINISHER_TYPE_DEBUG || actorVictim.GetAttitude(thePlayer) == AIA_Hostile);
		result = result && !thePlayer.IsUsingVehicle();
		result = result && thePlayer.IsAlive();
		result = result && !thePlayer.IsCurrentSignChanneled();
		result = result && (navCheckModifier || theGame.GetWorld().NavigationCircleTest(actorVictim.GetWorldPosition(), 2.f)) ;
		
		if (result) {
			if (!actorVictim.IsAlive()) {
				actorVictim.AddAbility('DisableFinishers', false);
			}
			context.finisher.active = true;
			context.finisher.animName = SelectFinisherAnimName(context);
		}
	}
	
	protected function CanPerformAutoFinisher(context : XTFinishersActionContext) : bool {
		var attackAction : W3Action_Attack;
		var result : bool;
		
		result = false;
		attackAction = (W3Action_Attack)context.action;
		
		if (attackAction) {
			if (attackAction.IsCriticalHit() && RandRangeF(100) < theGame.xtFinishersMgr.finisherModule.params.FINISHER_AUTO_CHANCE_CRIT) {
				result = true;
			} else if (SkillNameToEnum(attackAction.GetAttackTypeName()) == S_Sword_s02 && RandRangeF(100) < theGame.xtFinishersMgr.finisherModule.params.FINISHER_AUTO_CHANCE_REND) {
				result = true;
			} else if (context.CountEnemiesNearPlayer(true) == 0 && RandRangeF(100) < theGame.xtFinishersMgr.finisherModule.params.FINISHER_AUTO_CHANCE_LAST_ENEMY) {
				result = true;
			} else if (context.effectsSnapshot.HasEffects(theGame.xtFinishersMgr.finisherModule.params.autoFinisherEffectTypes) && RandRangeF(100) < theGame.xtFinishersMgr.finisherModule.params.FINISHER_AUTO_CHANCE_EFFECTS) {
				result = true;
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
				} else if (context.CountEnemiesNearPlayer(true) == 0 && RandRangeF(100) < theGame.xtFinishersMgr.finisherModule.params.FINISHER_INSTANTKILL_CHANCE_LAST_ENEMY) {
					result = true;
				} else if (context.effectsSnapshot.HasEffects(theGame.xtFinishersMgr.finisherModule.params.instantKillFinisherEffectTypes) && RandRangeF(100) < theGame.xtFinishersMgr.finisherModule.params.FINISHER_INSTANTKILL_CHANCE_EFFECTS) {
					result = true;
				}
			}
		}
		
		return result;
	}
	
	protected function SelectFinisherAnimName(context : XTFinishersActionContext) : name {
		var actorVictim : CActor;
		var animNames : array<name>;
		
		actorVictim = (CActor)context.action.victim;
		
		if(actorVictim.WillBeUnconscious()) { // nonlethal finisher
			if (thePlayer.GetCombatIdleStance() <= 0.f) {
				if (actorVictim.HasAbility('ForceHiltFinisher')) {
					return theGame.xtFinishersMgr.consts.FINISHER_NONLETHAL_STANCE_LEFT_HILT;
				} else if (actorVictim.HasAbility('ForceHeadbuttFinisher' )) {
					return theGame.xtFinishersMgr.consts.FINISHER_NONLETHAL_STANCE_LEFT_HEAD;
				} else {
					animNames = theGame.xtFinishersMgr.finisherModule.params.allowedLeftSideNonLethalFinisherAnimNames;
				}
			} else {
				if (actorVictim.HasAbility('ForceHiltFinisher')) {
					return theGame.xtFinishersMgr.consts.FINISHER_NONLETHAL_STANCE_RIGHT_HILT;
				} else if (actorVictim.HasAbility('ForceHeadbuttFinisher')) {
					return theGame.xtFinishersMgr.consts.FINISHER_NONLETHAL_STANCE_RIGHT_HEAD;
				} else {
					animNames = theGame.xtFinishersMgr.finisherModule.params.allowedRightSideNonLethalFinisherAnimNames;
				}
			}
		} else { // lethal finisher
			if (thePlayer.forceFinisher && thePlayer.forceFinisherAnimName != '') {
				return thePlayer.forceFinisherAnimName;
			}
			
			if (thePlayer.GetCombatIdleStance() <= 0.f) {
				animNames = theGame.xtFinishersMgr.finisherModule.params.allowedLeftSideFinisherAnimNames;
			} else {
				animNames = theGame.xtFinishersMgr.finisherModule.params.allowedRightSideFinisherAnimNames;
			}
		}

		return animNames[RandRange(animNames.Size(), 0)];
	}
	
	protected function PreprocessFinisherCam(context : XTFinishersActionContext) {
		var chance : float;
		
		if (context.CountEnemiesNearPlayer(true) == 0) {
			chance = theGame.xtFinishersMgr.finisherModule.params.FINISHER_CAM_CHANCE_LAST_ENEMY;
		} else {
			chance = theGame.xtFinishersMgr.finisherModule.params.FINISHER_CAM_CHANCE;
		}
	
		context.finisherCam.active = RandRangeF(100) < chance
				&& (!theGame.xtFinishersMgr.finisherModule.params.FINISHER_CAM_REQUIRE_NAV_CHECK || theGame.GetWorld().NavigationCircleTest(thePlayer.GetWorldPosition(), 3.f));
	}
}

class XTFinishersDefaultFinisherCamshakeDisableHandler extends XTFinishersAbstractCamshakePretriggerEventListener {
	public function GetPriority() : int {
		return theGame.xtFinishersMgr.finisherModule.DEFAULT_FINISHER_CAMSHAKE_DISABLE_HANDLER_PRIORITY;
	}
	
	public function OnCamshakePretrigger(context : XTFinishersActionContext) {
		context.camShake.active = context.camShake.active && (!context.finisherCam.active || !theGame.xtFinishersMgr.finisherModule.params.FINISHER_CAM_DISABLE_CAMERA_SHAKE);
	}
}