class XTFinishersDefaultCamShakeModule extends XTFinishersObject {
	// action end
	public const var DEFAULT_CAMSHAKE_HANDLER_PRIORITY : int;
		default DEFAULT_CAMSHAKE_HANDLER_PRIORITY = 0;
		
	public var params : XTFinishersDefaultCamShakeParams;
	
	public function Init() {
		params = new XTFinishersDefaultCamShakeParams in this;
		
		theGame.xtFinishersMgr.eventMgr.RegisterEventListener(theGame.xtFinishersMgr.consts.ACTION_END_EVENT_ID, GetNewCamShakeHandlerInstance());
	}
	
	protected function GetNewCamShakeHandlerInstance() : XTFinishersAbstractActionEndEventListener {
		return new XTFinishersDefaultCamShakeHandler in this;
	}
}

// listeners

class XTFinishersDefaultCamShakeHandler extends XTFinishersAbstractActionEndEventListener {
	public function GetPriority() : int {
		return theGame.xtFinishersMgr.camshakeModule.DEFAULT_CAMSHAKE_HANDLER_PRIORITY;
	}
	
	public function OnActionEndTriggered(context : XTFinishersActionContext) {
		var playerAttacker : CR4Player;
		var attackAction : W3Action_Attack;
		var actorVictim : CActor;
		
		playerAttacker = (CR4Player)context.action.attacker;
		attackAction = (W3Action_Attack)context.action;
		actorVictim = (CActor)context.action.victim;
		
		if (context.dismember.active && attackAction && (CActor)context.action.attacker) {
			PreprocessDismember(context);
		} else if (playerAttacker && attackAction && actorVictim) {
			if (SkillNameToEnum(attackAction.GetAttackTypeName()) == S_Sword_s02) {
				PreprocessRend(context);
			} else if (attackAction.IsCriticalHit() && context.action.DealtDamage()) {
				PreprocessCriticalHit(context);
			} else if (attackAction.IsActionMelee() && !actorVictim.IsAlive()) {
				PreprocessFatalHit(context);
			} else if (attackAction.IsActionMelee()) {
				if (playerAttacker.IsLightAttack(attackAction.GetAttackName())) {
					PreprocessFastAttack(context);
				} else if (playerAttacker.IsHeavyAttack(attackAction.GetAttackName())) {
					PreprocessStrongAttack(context);
				}
			}
		}
		
	}
	
	protected function PreprocessFastAttack(context : XTFinishersActionContext) {
		var attackAction : W3Action_Attack;
		
		if (context.camShake.active) {
			return;
		}
		
		attackAction = (W3Action_Attack)context.action;
		
		if (attackAction.IsParried()) {
			if (RandRangeF(100) < theGame.xtFinishersMgr.camshakeModule.params.CAMERA_SHAKE_FAST_PARRIED_CHANCE) {
				context.camShake.active = true;
				context.camShake.strength = theGame.xtFinishersMgr.camshakeModule.params.CAMERA_SHAKE_FAST_PARRIED_STRENGTH;
			}
		} else {
			if (RandRangeF(100) < theGame.xtFinishersMgr.camshakeModule.params.CAMERA_SHAKE_FAST_CHANCE) {
				context.camShake.active = true;
				context.camShake.strength = theGame.xtFinishersMgr.camshakeModule.params.CAMERA_SHAKE_FAST_STRENGTH;
			}
		}
		
		if (context.camShake.active) {
			context.camShake.type = XTF_CAMSHAKE_TYPE_FAST;
			context.camShake.useExtraOpts = true;
			context.camShake.epicenter = ((CActor)context.action.attacker).GetWorldPosition();
			context.camShake.maxDistance = 10;
		}
	}
	
	protected function PreprocessStrongAttack(context : XTFinishersActionContext) {
		var attackAction : W3Action_Attack;
		
		if (context.camShake.active) {
			return;
		}
		
		attackAction = (W3Action_Attack)context.action;
		
		if (attackAction.IsParried()) {
			if (RandRangeF(100) < theGame.xtFinishersMgr.camshakeModule.params.CAMERA_SHAKE_STRONG_PARRIED_CHANCE) {
				context.camShake.active = true;
				context.camShake.strength = theGame.xtFinishersMgr.camshakeModule.params.CAMERA_SHAKE_STRONG_PARRIED_STRENGTH;
			}
		} else {
			if (RandRangeF(100) < theGame.xtFinishersMgr.camshakeModule.params.CAMERA_SHAKE_STRONG_CHANCE) {
				context.camShake.active = true;
				context.camShake.strength = theGame.xtFinishersMgr.camshakeModule.params.CAMERA_SHAKE_STRONG_STRENGTH;
			}
		}
		
		if (context.camShake.active) {
			context.camShake.type = XTF_CAMSHAKE_TYPE_STRONG;
			context.camShake.useExtraOpts = true;
			context.camShake.epicenter = ((CActor)context.action.attacker).GetWorldPosition();
			context.camShake.maxDistance = 10;
		}
	}
	
	protected function PreprocessFatalHit(context : XTFinishersActionContext) {
		if (!context.camShake.active && RandRangeF(100) < theGame.xtFinishersMgr.camshakeModule.params.CAMERA_SHAKE_FATAL_CHANCE) {
			context.camShake.active = true;
			context.camShake.type = XTF_CAMSHAKE_TYPE_FATAL;
			context.camShake.strength = theGame.xtFinishersMgr.camshakeModule.params.CAMERA_SHAKE_FATAL_STRENGTH;
			context.camShake.useExtraOpts = false;
		}
	}
	
	protected function PreprocessCriticalHit(context : XTFinishersActionContext) {
		if (context.camShake.active) {
			return;
		}
		
		if (((CActor)context.action.victim).IsAlive()) {
			if (RandRangeF(100) < theGame.xtFinishersMgr.camshakeModule.params.CAMERA_SHAKE_CRIT_NONFATAL_CHANCE) {
				context.camShake.active = true;
				context.camShake.type = XTF_CAMSHAKE_TYPE_CRIT;
				context.camShake.strength = theGame.xtFinishersMgr.camshakeModule.params.CAMERA_SHAKE_CRIT_NONFATAL_STRENGTH;
				context.camShake.useExtraOpts = false;
			}
		} else {
			if (context.CountEnemiesNearPlayer(true) == 0) {
				if (RandRangeF(100) < theGame.xtFinishersMgr.camshakeModule.params.CAMERA_SHAKE_CRIT_FATAL_CHANCE_LAST_ENEMY) {
					context.camShake.active = true;
					context.camShake.type = XTF_CAMSHAKE_TYPE_CRIT;
					context.camShake.strength = theGame.xtFinishersMgr.camshakeModule.params.CAMERA_SHAKE_CRIT_FATAL_STRENGTH_LAST_ENEMY;
					context.camShake.useExtraOpts = false;
				}
			} else {
				if (RandRangeF(100) < theGame.xtFinishersMgr.camshakeModule.params.CAMERA_SHAKE_CRIT_FATAL_CHANCE) {
					context.camShake.active = true;
					context.camShake.type = XTF_CAMSHAKE_TYPE_CRIT;
					context.camShake.strength = theGame.xtFinishersMgr.camshakeModule.params.CAMERA_SHAKE_CRIT_FATAL_STRENGTH;
					context.camShake.useExtraOpts = false;
				}
			}
		}
	}
	
	protected function PreprocessRend(context : XTFinishersActionContext) {
		if (!context.camShake.active && RandRangeF(100) < theGame.xtFinishersMgr.camshakeModule.params.CAMERA_SHAKE_REND_CHANCE) {
			context.camShake.active = true;
			context.camShake.type = XTF_CAMSHAKE_TYPE_REND;
			context.camShake.strength = thePlayer.GetSpecialAttackTimeRatio() / 3.333 + 0.2;
			context.camShake.useExtraOpts = true;
			context.camShake.epicenter = thePlayer.GetWorldPosition();
			context.camShake.maxDistance = 10;
		}
	}
	
	protected function PreprocessDismember(context : XTFinishersActionContext) {
		if (context.CountEnemiesNearPlayer(true) == 0) {
			if (RandRangeF(100) < theGame.xtFinishersMgr.camshakeModule.params.CAMERA_SHAKE_DISMEMBER_CHANCE_LAST_ENEMY) {
				context.camShake.active = true;
				context.camShake.type = XTF_CAMSHAKE_TYPE_DISMEMBER;
				context.camShake.strength = theGame.xtFinishersMgr.camshakeModule.params.CAMERA_SHAKE_DISMEMBER_STRENGTH_LAST_ENEMY;
				context.camShake.useExtraOpts = true;
				context.camShake.epicenter = ((CActor)context.action.attacker).GetWorldPosition();
				context.camShake.maxDistance = 10;
			}
		} else {
			if (RandRangeF(100) < theGame.xtFinishersMgr.camshakeModule.params.CAMERA_SHAKE_DISMEMBER_CHANCE) {
				context.camShake.active = true;
				context.camShake.type = XTF_CAMSHAKE_TYPE_DISMEMBER;
				context.camShake.strength = theGame.xtFinishersMgr.camshakeModule.params.CAMERA_SHAKE_DISMEMBER_STRENGTH;
				context.camShake.useExtraOpts = true;
				context.camShake.epicenter = ((CActor)context.action.attacker).GetWorldPosition();
				context.camShake.maxDistance = 10;
			}
		}
	}
}