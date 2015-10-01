class XTFinishersDefaultDismemberModule extends XTFinishersObject {
	public var params : XTFinishersDefaultDismemberParams;
	
	public function Init() {
		params = new XTFinishersDefaultDismemberParams in this;
		
		theGame.xtFinishersMgr.queryMgr.LoadDismemberResponder(GetNewDismemberQueryResponderInstance());
		
		theGame.xtFinishersMgr.eventMgr.RegisterEventListener(theGame.xtFinishersMgr.consts.REACTION_START_EVENT_ID, GetNewDismemberQueryDispatcherInstance());
	}
	
	protected function GetNewDismemberQueryResponderInstance() : XTFinishersDismemberQueryResponder {
		return new XTFinishersDefaultDismemberQueryResponder in this;
	}
	
	protected function GetNewDismemberQueryDispatcherInstance() : XTFinishersAbstractReactionStartEventListener {
		return new XTFinishersDefaultDismemberQueryDispatcher in this;
	}
}

// listeners

class XTFinishersDefaultDismemberQueryDispatcher extends XTFinishersAbstractReactionStartEventListener {
	public function GetPriority() : int {
		return theGame.xtFinishersMgr.consts.DEFAULT_DISMEMBER_QUERY_DISPATCHER_PRIORITY;
	}
	
	public function OnReactionStartTriggered(context : XTFinishersActionContext) {
		theGame.xtFinishersMgr.queryMgr.FireDismemberQuery(context);
	}
}

// responders

class XTFinishersDefaultDismemberQueryResponder extends XTFinishersDismemberQueryResponder {
	public function CanPerformDismember(context : XTFinishersActionContext) {
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
		var isRend, isWhirl		: bool;
		
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
					isRend = SkillNameToEnum(attackAction.GetAttackTypeName()) == S_Sword_s02;
					isWhirl = (W3PlayerWitcher)playerAttacker && playerAttacker.GetBehaviorVariable('combatActionType') == (int)CAT_SpecialAttack && playerAttacker.GetBehaviorVariable('playerAttackType') == 0;
					
					
					if (attackAction.IsCriticalHit() && RandRangeF(100) < theGame.xtFinishersMgr.dismemberModule.params.DISMEMBER_AUTO_CHANCE_CRIT) {
						context.dismember.explosion = RandRangeF(100) < theGame.xtFinishersMgr.dismemberModule.params.DISMEMBER_AUTO_EXPLOSION_CHANCE_CRIT;
						context.dismember.auto = true;
						result = true;
					} else if (isRend && RandRangeF(100) < theGame.xtFinishersMgr.dismemberModule.params.DISMEMBER_AUTO_CHANCE_REND) {
						context.dismember.explosion = RandRangeF(100) < theGame.xtFinishersMgr.dismemberModule.params.DISMEMBER_AUTO_EXPLOSION_CHANCE_REND;
						context.dismember.auto = true;
						result = true;
					} else if (isWhirl && RandRangeF(100) < theGame.xtFinishersMgr.dismemberModule.params.DISMEMBER_AUTO_CHANCE_WHIRL) {
						context.dismember.explosion = RandRangeF(100) < theGame.xtFinishersMgr.dismemberModule.params.DISMEMBER_AUTO_EXPLOSION_CHANCE_WHIRL;
						context.dismember.auto = true;
						result = true;
					} else if (!isRend && playerAttacker.IsHeavyAttack(attackAction.GetAttackName()) && RandRangeF(100) < theGame.xtFinishersMgr.dismemberModule.params.DISMEMBER_AUTO_CHANCE_STRONG) {
						context.dismember.explosion = RandRangeF(100) < theGame.xtFinishersMgr.dismemberModule.params.DISMEMBER_AUTO_EXPLOSION_CHANCE_STRONG;
						context.dismember.auto = true;
						result = true;
					} else if (!isWhirl && playerAttacker.IsLightAttack(attackAction.GetAttackName()) && RandRangeF(100) < theGame.xtFinishersMgr.dismemberModule.params.DISMEMBER_AUTO_CHANCE_FAST) {
						context.dismember.explosion = RandRangeF(100) < theGame.xtFinishersMgr.dismemberModule.params.DISMEMBER_AUTO_EXPLOSION_CHANCE_FAST;
						context.dismember.auto = true;
						result = true;
					} else if (thePlayer.IsLastEnemyKilled() && RandRangeF(100) < theGame.xtFinishersMgr.dismemberModule.params.DISMEMBER_AUTO_CHANCE_LAST_ENEMY) {
						context.dismember.explosion = RandRangeF(100) < theGame.xtFinishersMgr.dismemberModule.params.DISMEMBER_AUTO_EXPLOSION_CHANCE_LAST_ENEMY;
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