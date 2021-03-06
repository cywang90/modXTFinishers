class XTFinishersVanillaModule extends XTFinishersObject {
	public const var VANILLA_FINISHER_QUERY_DISPATCHER_PRIORITY, VANILLA_DISMEMBER_QUERY_DISPATCHER_PRIORITY : int;
		default VANILLA_FINISHER_QUERY_DISPATCHER_PRIORITY = 0;
		default VANILLA_DISMEMBER_QUERY_DISPATCHER_PRIORITY = 10;
		
	public const var VANILLA_CAMSHAKE_HANDLER_PRIORITY : int;
		default VANILLA_CAMSHAKE_HANDLER_PRIORITY = 0;
	
	public const var VANILLA_FINISHER_CAM_QUERY_DISPATCHER_PRIORITY : int;
		default VANILLA_FINISHER_CAM_QUERY_DISPATCHER_PRIORITY = 0;
		
	public function InitFinisherComponents() {
		theGame.xtFinishersMgr.eventMgr.RegisterEventListener(theGame.xtFinishersMgr.consts.REACTION_START_EVENT_ID, new XTFinishersVanillaFinisherHandler in this);
		theGame.xtFinishersMgr.eventMgr.RegisterEventListener(theGame.xtFinishersMgr.consts.FINISHER_EVENT_ID, new XTFinishersVanillaFinisherCamHandler in this);
	}
	
	public function InitDismemberComponents() {
		theGame.xtFinishersMgr.eventMgr.RegisterEventListener(theGame.xtFinishersMgr.consts.REACTION_START_EVENT_ID, new XTFinishersVanillaDismemberHandler in this);
	}
	
	public function InitCamShakeComponents() {
		theGame.xtFinishersMgr.eventMgr.RegisterEventListener(theGame.xtFinishersMgr.consts.ACTION_END_EVENT_ID, new XTFinishersVanillaCamShakeHandler in this);
	}
}

// listeners

class XTFinishersVanillaFinisherHandler extends XTFinishersAbstractReactionStartEventListener {
	public function GetPriority() : int {
		return theGame.xtFinishersMgr.vanillaModule.VANILLA_FINISHER_QUERY_DISPATCHER_PRIORITY;
	}
	
	public function OnReactionStartTriggered(context : XTFinishersActionContext) {
		PreprocessFinisher(context);
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
		var areEnemiesAttackingModifier, navCheckModifier : bool;
		
		actorVictim = (CActor)context.action.victim;
		attackAction = (W3Action_Attack)context.action;
		npc = (CNewNPC)actorVictim;
		
		if ((W3ReplacerCiri)thePlayer || (CR4Player)context.action.victim || thePlayer.isInFinisher) {
			return;
		}
		
		context.finisher.type = XTF_FINISHER_TYPE_REGULAR;
		
		playerPos = thePlayer.GetWorldPosition();
		moveTargets = thePlayer.GetMoveTargets();	
		size = moveTargets.Size();
		if (size > 0) {
			areEnemiesAttacking = false;			
			for (i = 0; i < size; i += 1) {
				npc = (CNewNPC)moveTargets[i];
				if (npc && VecDistanceSquared(playerPos, moveTargets[i].GetWorldPosition()) < 7 && npc.IsAttacking() && npc != actorVictim) {
					areEnemiesAttacking = true;
					break;
				}
			}
		}
		
		victimToPlayerVector = actorVictim.GetWorldPosition() - playerPos;
		
		if (actorVictim.IsAlive()) {
			if (CanPerformInstantKillFinisher(context)) {
				context.finisher.type = XTF_FINISHER_TYPE_INSTANTKILL;
				finisherChance = 75 - (npc.currentLevel - thePlayer.GetLevel());
			} else {
				return;
			}
		} else {
			context.finisher.forced = actorVictim.HasTag('ForceFinisher');
			
			if (!context.finisher.forced) {
				if (actorVictim.IsHuman()) {
					if (context.effectsSnapshot.HasEffect(EET_Confusion) || context.effectsSnapshot.HasEffect(EET_AxiiGuardMe)) {
						finisherChance = 75 - (npc.currentLevel - thePlayer.GetLevel());
					} else if ((size <= 1 && theGame.params.FINISHER_ON_DEATH_CHANCE > 0) || (actorVictim.HasAbility('ForceFinisher'))) {
						finisherChance = 100;
					} else {
						if (npc.currentLevel - thePlayer.GetLevel() < -5) {
							finisherChance = theGame.params.FINISHER_ON_DEATH_CHANCE - (npc.currentLevel - thePlayer.GetLevel());
						} else {
							finisherChance = theGame.params.FINISHER_ON_DEATH_CHANCE;
						}
					}
					finisherChance = ClampF(finisherChance, 0, 100);
				} else {
					finisherChance = 0;
				}
			}
		}
		
		if (thePlayer.forceFinisher && actorVictim.IsHuman()) {
			context.finisher.type = XTF_FINISHER_TYPE_DEBUG;
			context.finisher.active = true;
			return;
		}
		
		if (context.finisher.forced) {
			finisherChance = 100;
		}
			
		item = thePlayer.inv.GetItemFromSlot('l_weapon');	

		result = ((CR4Player)context.action.attacker) && attackAction && attackAction.IsActionMelee();
		result = result && (actorVictim.IsHuman() && !actorVictim.IsWoman());
		result = result && RandRangeF(100) < finisherChance;
		result = result && (context.finisher.forced || !areEnemiesAttacking);
		result = result && (context.finisher.type == XTF_FINISHER_TYPE_DEBUG || AbsF(victimToPlayerVector.Z) < 0.4f);
		result = result && !thePlayer.IsInAir();
		result = result && (thePlayer.IsWeaponHeld('steelsword') || thePlayer.IsWeaponHeld('silversword'));
		result = result && !thePlayer.IsSecondaryWeaponHeld();
		result = result && !thePlayer.inv.IsIdValid(item);
		result = result && !actorVictim.IsKnockedUnconscious();
		result = result && !context.effectsSnapshot.HasEffect(EET_Knockdown);
		result = result && !context.effectsSnapshot.HasEffect(EET_Ragdoll);
		result = result && !context.effectsSnapshot.HasEffect(EET_Frozen);
		result = result && (context.finisher.type == XTF_FINISHER_TYPE_DEBUG || !actorVictim.HasAbility('DisableFinishers'));
		result = result && (context.finisher.type == XTF_FINISHER_TYPE_DEBUG || actorVictim.GetAttitude(thePlayer) == AIA_Hostile);
		result = result && !thePlayer.IsUsingVehicle();
		result = result && thePlayer.IsAlive();
		result = result && !thePlayer.IsCurrentSignChanneled();
		result = result && (context.finisher.forced || theGame.GetWorld().NavigationCircleTest(actorVictim.GetWorldPosition(), 2.f)) ;
		
		if (result) {
			if (!actorVictim.IsAlive()) {
				actorVictim.AddAbility('DisableFinishers', false);
			}
			context.finisher.active = true;
			context.finisher.animName = SelectFinisherAnimName(context);
		}
	}
	
	protected function CanPerformInstantKillFinisher(context : XTFinishersActionContext) : bool {
		var actorVictim : CActor;
		var attackAction : W3Action_Attack;
		var hasEffect : bool;
		var instantKillFinisherEffectTypes : array<EEffectType>;
		var i : int;
		
		actorVictim = (CActor)context.action.victim;
		attackAction = (W3Action_Attack)context.action;
		
		return attackAction && actorVictim.IsHuman() && actorVictim.IsVulnerable() && !actorVictim.HasAbility('InstantKillImmune')
				&& (context.effectsSnapshot.HasEffect(EET_Confusion) || context.effectsSnapshot.HasEffect(EET_AxiiGuardMe));
	}
	
	protected function SelectFinisherAnimName(context : XTFinishersActionContext) : name {
		var syncAnimName 	: name;
		var dlcFinishers : array<CR4FinisherDLC>;
		var syncAnimsNames	: array<name>;
		var size 			: int;
		var i 				: int;
		
		if (thePlayer.forceFinisher && thePlayer.forceFinisherAnimName != '') {
			return thePlayer.forceFinisherAnimName;
		}
		
		if (thePlayer.GetCombatIdleStance() <= 0.f) {
			syncAnimsNames.PushBack('man_finisher_02_lp');
			syncAnimsNames.PushBack('man_finisher_04_lp');
			syncAnimsNames.PushBack('man_finisher_06_lp');
			syncAnimsNames.PushBack('man_finisher_07_lp');
			syncAnimsNames.PushBack('man_finisher_08_lp');
			dlcFinishers = theGame.GetSyncAnimManager().dlcFinishersLeftSide;
		} else {
			syncAnimsNames.PushBack('man_finisher_01_rp');
			syncAnimsNames.PushBack('man_finisher_03_rp');
			syncAnimsNames.PushBack('man_finisher_05_rp');
			dlcFinishers = theGame.GetSyncAnimManager().dlcFinishersLeftSide;
		}
		size = dlcFinishers.Size();
		for (i = 0; i < size; i += 1) {
			syncAnimsNames.PushBack(dlcFinishers[i].finisherAnimName);
		}
			
		return syncAnimsNames[RandRange(syncAnimsNames.Size(), 0)];
	}
}

class XTFinishersVanillaDismemberHandler extends XTFinishersAbstractReactionStartEventListener {
	public function GetPriority() : int {
		return theGame.xtFinishersMgr.vanillaModule.VANILLA_DISMEMBER_QUERY_DISPATCHER_PRIORITY;
	}
	
	public function OnReactionStartTriggered(context : XTFinishersActionContext) {
		PreprocessDismember(context);
	}
	
	protected function PreprocessDismember(context : XTFinishersActionContext) {
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
		
		context.dismember.type = XTF_DISMEMBER_TYPE_REGULAR;
		
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
		
		if (playerAttacker) {
			secondaryWeapon = playerAttacker.inv.ItemHasTag(weaponId, 'SecondaryWeapon') || playerAttacker.inv.ItemHasTag(weaponId, 'Wooden');
		}
		
		if (actorVictim.HasAbility('DisableDismemberment')) {
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
			context.dismember.type = XTF_DISMEMBER_TYPE_FROZEN;
			result = true;
		} else if (petard && petard.DismembersOnKill()) {
			context.dismember.type = XTF_DISMEMBER_TYPE_BOMB;
			result = true;
		} else if (bolt && bolt.DismembersOnKill()) {
			context.dismember.type = XTF_DISMEMBER_TYPE_BOLT;
			result = true;
		} else if ((W3Effect_YrdenHealthDrain)context.action.causer) {
			context.dismember.type = XTF_DISMEMBER_TYPE_YRDEN;
			context.dismember.explosion = true;
			result = true;
		} else if (toxicCloud && toxicCloud.HasExplodingTargetDamages()) {
			context.dismember.type = XTF_DISMEMBER_TYPE_TOXICCLOUD;
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
			} else if (attackAction && attackAction.IsCriticalHit()) {
				result = true;
				context.dismember.explosion = attackAction.HasForceExplosionDismemberment();
			} else {
				dismemberChance = theGame.params.DISMEMBERMENT_ON_DEATH_CHANCE;
				
				if (playerAttacker && playerAttacker.forceDismember) {
					dismemberChance = thePlayer.forceDismemberChance;
					context.dismember.explosion = thePlayer.forceDismemberExplosion;
					context.dismember.type = XTF_DISMEMBER_TYPE_DEBUG;
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
		
		context.dismember.active = result;
	}
}

class XTFinishersVanillaFinisherCamHandler extends XTFinishersAbstractFinisherEventListener {
	public function GetPriority() : int {
		return theGame.xtFinishersMgr.vanillaModule.VANILLA_FINISHER_CAM_QUERY_DISPATCHER_PRIORITY;
	}
	
	public function OnFinisherTriggered(context : XTFinishersActionContext) {
		PreprocessFinisherCam(context);
	}
	
	protected function PreprocessFinisherCam(context : XTFinishersActionContext) {
		context.finisherCam.active = thePlayer.IsLastEnemyKilled() && theGame.GetWorld().NavigationCircleTest(thePlayer.GetWorldPosition(), 3.f);
	}
}

class XTFinishersVanillaCamShakeHandler extends XTFinishersAbstractActionEndEventListener {
	public function GetPriority() : int {
		return theGame.xtFinishersMgr.vanillaModule.VANILLA_CAMSHAKE_HANDLER_PRIORITY;
	}
	
	public function OnActionEndTriggered(context : XTFinishersActionContext) {
		PreprocessNormalStrike(context);
		PreprocessCriticalHit(context);
		PreprocessDismember(context);
	}
	
	protected function PreprocessNormalStrike(context : XTFinishersActionContext) {
		var playerAttacker : CR4Player;
		var attackAction : W3Action_Attack;
		
		playerAttacker = (CR4Player)context.action.attacker;
		attackAction = (W3Action_Attack)context.action;
		
		if (playerAttacker && attackAction && attackAction.IsActionMelee()) {
			if (playerAttacker.IsLightAttack(attackAction.GetAttackName())) {
				context.camShake.active = true;
				context.camShake.type = XTF_CAMSHAKE_TYPE_FAST;
				context.camShake.strength = 0.1;
				context.camShake.useExtraOpts = true;
				context.camShake.epicenter = playerAttacker.GetWorldPosition();
				context.camShake.maxDistance = 10;
			} else if (SkillNameToEnum(attackAction.GetAttackTypeName()) == S_Sword_s02) {
				context.camShake.active = true;
				context.camShake.type = XTF_CAMSHAKE_TYPE_REND;
				context.camShake.strength = thePlayer.GetSpecialAttackTimeRatio() / 3.333 + 0.2;
				context.camShake.useExtraOpts = true;
				context.camShake.epicenter = playerAttacker.GetWorldPosition();
				context.camShake.maxDistance = 10;
			} else if (playerAttacker.IsHeavyAttack(attackAction.GetAttackName())) {
				context.camShake.active = true;
				context.camShake.type = XTF_CAMSHAKE_TYPE_STRONG;
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
	
	protected function PreprocessCriticalHit(context : XTFinishersActionContext) {
		var attackAction : W3Action_Attack;
		var actorVictim : CActor;
		
		attackAction = (W3Action_Attack)context.action;
		actorVictim = (CActor)context.action.victim;
		
		if((CR4Player)context.action.attacker && attackAction && actorVictim && attackAction.IsCriticalHit() && context.action.DealtDamage() && !actorVictim.IsAlive()) {
			context.camShake.active = true;
			context.camShake.type = XTF_CAMSHAKE_TYPE_CRIT;
			context.camShake.strength = 0.5;
			context.camShake.useExtraOpts = false;
		}
	}
	
	protected function PreprocessDismember(context : XTFinishersActionContext) {
		var actorAttacker : CActor;
		
		actorAttacker = (CActor)context.action.attacker;
		
		if (context.dismember.active) {
			context.camShake.active = true;
			context.camShake.type = XTF_CAMSHAKE_TYPE_DISMEMBER;
			context.camShake.strength = 0.5;
			context.camShake.useExtraOpts = true;
			context.camShake.epicenter = actorAttacker.GetWorldPosition();
			context.camShake.maxDistance = 10;
		}
	}
}