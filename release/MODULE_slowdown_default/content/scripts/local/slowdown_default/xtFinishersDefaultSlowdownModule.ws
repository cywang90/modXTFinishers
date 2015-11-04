class XTFinishersDefaultSlowdownModule extends XTFinishersObject {
	public const var DEFAULT_SLOWDOWN_HANDLER_PRIORITY, DEFAULT_SLOWDOWN_FINISHER_HANDLER_PRIORITY, DEFAULT_CAMSHAKE_HANDLER_PRIORITY : int;
		// action end
		default DEFAULT_SLOWDOWN_HANDLER_PRIORITY = 0;
		
		// finisher
		default DEFAULT_SLOWDOWN_FINISHER_HANDLER_PRIORITY = 10;
		
		// camshake
		default DEFAULT_CAMSHAKE_HANDLER_PRIORITY = 0;
		
	public var params : XTFinishersDefaultSlowdownParams;
	
	public function Init() {
		params = new XTFinishersDefaultSlowdownParams in this;
		
		theGame.xtFinishersMgr.SetSlowdownManager(GetNewSlowdownManagerInstance());
		
		theGame.xtFinishersMgr.eventMgr.RegisterEventListener(theGame.xtFinishersMgr.consts.ACTION_END_EVENT_ID, GetNewSlowdownHandlerInstance());
		theGame.xtFinishersMgr.eventMgr.RegisterEventListener(theGame.xtFinishersMgr.consts.FINISHER_EVENT_ID, GetNewSlowdownFinisherHandlerInstance());
		theGame.xtFinishersMgr.eventMgr.RegisterEventListener(theGame.xtFinishersMgr.consts.CAMSHAKE_PRE_EVENT_ID, GetNewCamshakeHandlerInstance());
	}
	
	protected function GetNewSlowdownManagerInstance() : XTFinishersSlowdownManager {
		var mgr : XTFinishersDefaultSlowdownManager;
		
		mgr = new XTFinishersDefaultSlowdownManager in this;
		mgr.Init();
		
		return mgr;
	}
	
	protected function GetNewSlowdownHandlerInstance() : XTFinishersAbstractActionEndEventListener {
		return new XTFinishersDefaultSlowdownHandler in this;
	}
	
	protected function GetNewSlowdownFinisherHandlerInstance() : XTFinishersAbstractFinisherEventListener {
		return new XTFinishersDefaultSlowdownFinisherHandler in this;
	}
	
	protected function GetNewCamshakeHandlerInstance() : XTFinishersAbstractCamshakePretriggerEventListener {
		return new XTFinishersDefaultCamshakeHandler in this;
	}
}

// listeners

class XTFinishersDefaultSlowdownHandler extends XTFinishersAbstractActionEndEventListener {
	public function GetPriority() : int {
		return theGame.xtFinishersMgr.slowdownModule.DEFAULT_SLOWDOWN_HANDLER_PRIORITY;
	}
	
	public function OnActionEndTriggered(context : XTFinishersActionContext) {
		var attackAction : W3Action_Attack;
		var actorVictim : CActor;
		
		attackAction = (W3Action_Attack)context.action;
		actorVictim = (CActor)context.action.victim;
		
		if (context.finisher.active) {
			PreprocessSlowdownFinisher(context);
		} else if (context.dismember.active) {
			PreprocessSlowdownDismember(context);
		} else if ((CR4Player)context.action.attacker && attackAction && attackAction.IsActionMelee()) {
			if (attackAction.IsCriticalHit()) {
				PreprocessSlowdownCrit(context);
			} else if (actorVictim && !actorVictim.IsAlive()) {
				PreprocessSlowdownFatal(context);
			}
		}
		
		if (context.slowdown.active) {
			if (context.slowdown.type != XTF_SLOWDOWN_TYPE_FINISHER) {
				theGame.xtFinishersMgr.slowdownMgr.TriggerSlowdown(context);
			}
		}
	}
	
	protected function PreprocessSlowdownFatal(context : XTFinishersActionContext) {
		if (!context.slowdown.active && RandRangeF(100) < theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FATAL_CHANCE) {
			context.slowdown.active = true;
			context.slowdown.type = XTF_SLOWDOWN_TYPE_FATAL;
		}
	}
	
	protected function PreprocessSlowdownCrit(context : XTFinishersActionContext) {
		var chance : float;
		
		if (context.slowdown.active) {
			return;
		}
		
		if (context.action.victim.IsAlive()) {
			chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_CRIT_CHANCE_NONFATAL;
		} else {
			if (context.CountEnemiesNearPlayer() <= 1) {
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_CRIT_CHANCE_FATAL_LAST_ENEMY;
			} else {
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_CRIT_CHANCE_FATAL;
			}
		}
		
		if (RandRangeF(100) < chance) {
			context.slowdown.active = true;
			context.slowdown.type = XTF_SLOWDOWN_TYPE_CRIT;
		}
	}
	
	protected function PreprocessSlowdownDismember(context : XTFinishersActionContext) {
		var chance : float;
		
		if (context.slowdown.active) {
			return;
		}
		
		if (context.CountEnemiesNearPlayer() <= 1) {
			switch (context.dismember.type) {
			case XTF_DISMEMBER_TYPE_FROZEN:
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_DISMEMBER_FROZEN_CHANCE_LAST_ENEMY;
				break;
			case XTF_DISMEMBER_TYPE_BOMB:
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_DISMEMBER_BOMB_CHANCE_LAST_ENEMY;
				break;
			case XTF_DISMEMBER_TYPE_BOLT:
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_DISMEMBER_BOLT_CHANCE_LAST_ENEMY;
				break;
			case XTF_DISMEMBER_TYPE_YRDEN:
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_DISMEMBER_YRDEN_CHANCE_LAST_ENEMY;
				break;
			case XTF_DISMEMBER_TYPE_TOXICCLOUD:
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_DISMEMBER_TOXICCLOUD_CHANCE_LAST_ENEMY;
				break;
			case XTF_DISMEMBER_TYPE_AUTO:
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_DISMEMBER_AUTO_CHANCE_LAST_ENEMY;
				break;
			default:
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_DISMEMBER_CHANCE_LAST_ENEMY;
			}
		} else {
			switch (context.dismember.type) {
			case XTF_DISMEMBER_TYPE_FROZEN:
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_DISMEMBER_FROZEN_CHANCE;
				break;
			case XTF_DISMEMBER_TYPE_BOMB:
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_DISMEMBER_BOMB_CHANCE;
				break;
			case XTF_DISMEMBER_TYPE_BOLT:
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_DISMEMBER_BOLT_CHANCE;
				break;
			case XTF_DISMEMBER_TYPE_YRDEN:
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_DISMEMBER_YRDEN_CHANCE;
				break;
			case XTF_DISMEMBER_TYPE_TOXICCLOUD:
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_DISMEMBER_TOXICCLOUD_CHANCE;
				break;
			case XTF_DISMEMBER_TYPE_AUTO:
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_DISMEMBER_AUTO_CHANCE;
				break;
			default:
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_DISMEMBER_CHANCE;
			}
		}
		
		if (RandRangeF(100) < chance) {
			context.slowdown.active = true;
			context.slowdown.type = XTF_SLOWDOWN_TYPE_DISMEMBER;
		}
	}
	
	protected function PreprocessSlowdownFinisher(context : XTFinishersActionContext) {
		var chance : float;
		
		if (context.slowdown.active || context.finisherCam.active) {
			return;
		}
		
		if (context.CountEnemiesNearPlayer() <= 1) {
			switch (context.finisher.type) {
			case XTF_FINISHER_TYPE_AUTO:
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_AUTO_CHANCE_LAST_ENEMY;
				break;
			case XTF_FINISHER_TYPE_INSTANTKILL:
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_INSTANTKILL_CHANCE_LAST_ENEMY;
				break;
			default:
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_CHANCE_LAST_ENEMY;
			}
		} else {
			switch (context.finisher.type) {
			case XTF_FINISHER_TYPE_AUTO:
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_AUTO_CHANCE;
				break;
			case XTF_FINISHER_TYPE_INSTANTKILL:
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_INSTANTKILL_CHANCE;
				break;
			default:
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_CHANCE;
			}
		}
		
		if (RandRangeF(100) < chance) {
			context.slowdown.active = true;
			context.slowdown.type = XTF_SLOWDOWN_TYPE_FINISHER;
		}
	}
}

class XTFinishersDefaultSlowdownFinisherHandler extends XTFinishersAbstractFinisherEventListener {
	public function GetPriority() : int {
		return theGame.xtFinishersMgr.slowdownModule.DEFAULT_SLOWDOWN_FINISHER_HANDLER_PRIORITY;
	}
	
	public function OnFinisherTriggered(context : XTFinishersActionContext) {
		if (context.finisher.type == XTF_FINISHER_TYPE_KNOCKDOWN) {
			PreprocessKnockdownFinisher(context);
		}
		
		if (context.slowdown.active && context.slowdown.type == XTF_SLOWDOWN_TYPE_FINISHER) {
			theGame.xtFinishersMgr.slowdownMgr.TriggerSlowdown(context);
		}
	}
	
	protected function PreprocessKnockdownFinisher(context : XTFinishersActionContext) {
		var chance : float;
		
		if (context.slowdown.active) {
			return;
		}
		
		if (context.CountEnemiesNearPlayer() <= 1) {
			chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_KNOCKDOWN_CHANCE_LAST_ENEMY;
		} else {
			chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_KNOCKDOWN_CHANCE;
		}
		
		if (RandRangeF(100) < chance) {
			context.slowdown.active = true;
			context.slowdown.type = XTF_SLOWDOWN_TYPE_FINISHER;
		}
	}
}

class XTFinishersDefaultCamshakeHandler extends XTFinishersAbstractCamshakePretriggerEventListener {
	public function GetPriority() : int {
		return theGame.xtFinishersMgr.slowdownModule.DEFAULT_CAMSHAKE_HANDLER_PRIORITY;
	}
	
	public function OnCamshakePretrigger(context : XTFinishersActionContext) {
		context.camShake.active = context.camShake.active && (!context.slowdown.active || !theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_DISABLE_CAMERA_SHAKE);
	}
}

// slowdown

class XTFinishersDefaultSlowdownManager extends XTFinishersAbstractSlowdownManager {
	private var fatalSeqDef, critSeqDef, finisherSeqDef, kdFinisherSeqDef, dismemberSeqDef : XTFinishersSlowdownSequenceDef;
	
	public function Init() {
		var temp : XTFinishersSlowdownSegment;
		
		super.Init();
		
		// define fatal hit slowdown sequence
		fatalSeqDef = new XTFinishersSlowdownSequenceDef in this;
		if (theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FATAL_DELAY > 0) {
			fatalSeqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FATAL_DELAY));
		}
		if (theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FATAL_DURATION > 0) {
			fatalSeqDef.AddSegment(CreateXTFinishersSlowdownSession(this, theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FATAL_DURATION, theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FATAL_FACTOR));
		}
		
		// define critical hit slowdown sequence
		critSeqDef = new XTFinishersSlowdownSequenceDef in this;
		if (theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_CRIT_DELAY > 0) {
			critSeqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_CRIT_DELAY));
		}
		if (theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_CRIT_DURATION > 0) {
			critSeqDef.AddSegment(CreateXTFinishersSlowdownSession(this, theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_CRIT_DURATION, theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_CRIT_FACTOR));
		}
		
		// define finisher slowdown sequence
		finisherSeqDef = new XTFinishersSlowdownSequenceDef in this;
		if (theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_A_DELAY > 0) {
			finisherSeqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_A_DELAY));
		}
		if (theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_A_DURATION > 0) {
			finisherSeqDef.AddSegment(CreateXTFinishersSlowdownSession(this, theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_A_DURATION, theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_A_FACTOR));
		}
		if (theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_B_DELAY > 0) {
			finisherSeqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_B_DELAY));
		}
		if (theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_B_DURATION > 0) {
			finisherSeqDef.AddSegment(CreateXTFinishersSlowdownSession(this, theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_B_DURATION, theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_B_FACTOR));
		}
		
		// define knockdown finisher slowdown sequence
		kdFinisherSeqDef = new XTFinishersSlowdownSequenceDef in this;
		if (theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_KNOCKDOWN_DELAY > 0) {
			kdFinisherSeqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_KNOCKDOWN_DELAY));
		}
		if (theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_KNOCKDOWN_DURATION > 0) {
			kdFinisherSeqDef.AddSegment(CreateXTFinishersSlowdownSession(this, theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_KNOCKDOWN_DURATION, theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_KNOCKDOWN_FACTOR));
		}
		
		// define dismember slowdown sequence
		dismemberSeqDef = new XTFinishersSlowdownSequenceDef in this;
		if (theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_DISMEMBER_DELAY > 0) {
			dismemberSeqDef.AddSegment(CreateXTFinishersSlowdownDelay(this, theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_DISMEMBER_DELAY));
		}
		if (theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_DISMEMBER_DURATION > 0) {
			dismemberSeqDef.AddSegment(CreateXTFinishersSlowdownSession(this, theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_DISMEMBER_DURATION, theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_DISMEMBER_FACTOR));
		}
	}
	
	protected function OnSlowdownSequenceStart(context : XTFinishersActionContext) {
		var seqDef : XTFinishersSlowdownSequenceDef;
		
		seqDef = NULL;
		switch (context.slowdown.type) {
		case XTF_SLOWDOWN_TYPE_FATAL:
			seqDef = GetFatalSequence(context);
			break;
		case XTF_SLOWDOWN_TYPE_CRIT:
			seqDef = GetCritSequence(context);
			break;
		case XTF_SLOWDOWN_TYPE_FINISHER:
			seqDef = GetFinisherSequence(context);
			break;
		case XTF_SLOWDOWN_TYPE_DISMEMBER:
			seqDef = GetDismemberSequence(context);
			break;
		}
		
		if (seqDef) {
			StartSlowdownSequence(seqDef);
		}
	}
	
	protected function GetFatalSequence(context : XTFinishersActionContext) : XTFinishersSlowdownSequenceDef {
		return fatalSeqDef;
	}
	
	protected function GetCritSequence(context : XTFinishersActionContext) : XTFinishersSlowdownSequenceDef {
		return critSeqDef;
	}
	
	protected function GetFinisherSequence(context : XTFinishersActionContext) : XTFinishersSlowdownSequenceDef {
		switch (context.finisher.type) {
		case XTF_FINISHER_TYPE_KNOCKDOWN:
			return kdFinisherSeqDef;
		default:
			return finisherSeqDef;
		}
	}
	
	protected function GetDismemberSequence(context : XTFinishersActionContext) : XTFinishersSlowdownSequenceDef {
		return dismemberSeqDef;
	}
}