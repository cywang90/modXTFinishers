class XTFinishersDefaultCamShakeModule {
	public var params : XTFinishersDefaultCamShakeParams;
	
	public function Init() {
		params = new XTFinishersDefaultCamShakeParams in this;
		
		theGame.xtFinishersMgr.eventMgr.RegisterEventListener(theGame.xtFinishersMgr.consts.ACTION_END_EVENT_ID, new XTFinishersDefaultCamShakeHandler in this);
	}
}

// listeners

class XTFinishersDefaultCamShakeHandler extends XTFinishersAbstractActionEndEventListener {
	public function GetPriority() : int {
		return theGame.xtFinishersMgr.consts.DEFAULT_CAMSHAKE_HANDLER_PRIORITY;
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
		
		if (context.dismember.active && (W3Action_Attack)context.action && actorAttacker && theGame.xtFinishersMgr.camshakeModule.params.DISMEMBER_CAMERA_SHAKE) {
			context.camShake.active = true;
			context.camShake.strength = 0.5;
			context.camShake.useExtraOpts = true;
			context.camShake.epicenter = actorAttacker.GetWorldPosition();
			context.camShake.maxDistance = 10;
		}
	}
	
	public function OnActionEndTriggered(out context : XTFinishersActionContext) {
		ProcessNormalStrike(context);
		ProcessCriticalHit(context);
		ProcessDismember(context);
	}
}