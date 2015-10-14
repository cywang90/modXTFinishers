class XTFinishersDefaultCamShakeModule extends XTFinishersObject {
	// action end
	public const var DEFAULT_CAMSHAKE_HANDLER_PRIORITY : int;
		default DEFAULT_CAMSHAKE_HANDLER_PRIORITY = 10;
		
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
	
	protected function PreprocessNormalStrike(out context : XTFinishersActionContext) {
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
			} else if (SkillNameToEnum(attackAction.GetAttackTypeName()) == S_Sword_s02 && theGame.xtFinishersMgr.camshakeModule.params.CAMERA_SHAKE_ON_REND) {
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
	
	protected function PreprocessCriticalHit(out context : XTFinishersActionContext) {
		var attackAction : W3Action_Attack;
		var actorVictim : CActor;
		
		attackAction = (W3Action_Attack)context.action;
		actorVictim = (CActor)context.action.victim;
		
		if((CR4Player)context.action.attacker && attackAction && actorVictim && attackAction.IsCriticalHit() && context.action.DealtDamage()) {
			if (actorVictim.IsAlive() && theGame.xtFinishersMgr.camshakeModule.params.CAMERA_SHAKE_ON_CRIT_NONFATAL) {
				context.camShake.active = true;
				context.camShake.type = XTF_CAMSHAKE_TYPE_CRIT;
				context.camShake.strength = theGame.xtFinishersMgr.camshakeModule.params.CAMERA_SHAKE_CRIT_NONFATAL_STRENGTH;
				context.camShake.useExtraOpts = false;
			} else if (!actorVictim.IsAlive() && theGame.xtFinishersMgr.camshakeModule.params.CAMERA_SHAKE_ON_CRIT_FATAL) {
				context.camShake.active = true;
				context.camShake.type = XTF_CAMSHAKE_TYPE_CRIT;
				context.camShake.strength = theGame.xtFinishersMgr.camshakeModule.params.CAMERA_SHAKE_CRIT_FATAL_STRENGTH;
				context.camShake.useExtraOpts = false;
			}
		}
	}
	
	protected function PreprocessDismember(out context : XTFinishersActionContext) {
		var actorAttacker : CActor;
		
		actorAttacker = (CActor)context.action.attacker;
		
		if (context.dismember.active && (W3Action_Attack)context.action && actorAttacker && theGame.xtFinishersMgr.camshakeModule.params.CAMERA_SHAKE_ON_DISMEMBER) {
			context.camShake.active = true;
			context.camShake.type = XTF_CAMSHAKE_TYPE_DISMEMBER;
			context.camShake.strength = theGame.xtFinishersMgr.camshakeModule.params.CAMERA_SHAKE_DISMEMBER_STRENGTH;
			context.camShake.useExtraOpts = true;
			context.camShake.epicenter = actorAttacker.GetWorldPosition();
			context.camShake.maxDistance = 10;
		}
	}
	
	public function OnActionEndTriggered(out context : XTFinishersActionContext) {
		PreprocessNormalStrike(context);
		PreprocessCriticalHit(context);
		PreprocessDismember(context);
	}
}