class XTFinishersDefaultSlowdownModule extends XTFinishersObject {
	public var params : XTFinishersDefaultSlowdownParams;
	
	public function Init() {
		params = new XTFinishersDefaultSlowdownParams in this;
		
		theGame.xtFinishersMgr.SetSlowdownManager(GetNewSlowdownManagerInstance());
		
		theGame.xtFinishersMgr.eventMgr.RegisterEventListener(theGame.xtFinishersMgr.consts.ACTION_END_EVENT_ID, GetNewSlowdownCritHandlerInstance());
		theGame.xtFinishersMgr.eventMgr.RegisterEventListener(theGame.xtFinishersMgr.consts.FINISHER_EVENT_ID, GetNewSlowdownFinisherHandlerInstance());
		theGame.xtFinishersMgr.eventMgr.RegisterEventListener(theGame.xtFinishersMgr.consts.DISMEMBER_EVENT_ID, GetNewSlowdownDismemberHandlerInstance());
	}
	
	protected function GetNewSlowdownManagerInstance() : XTFinishersSlowdownManager {
		var mgr : XTFinishersDefaultSlowdownManager;
		
		mgr = new XTFinishersDefaultSlowdownManager in this;
		mgr.Init();
		
		return mgr;
	}
	
	protected function GetNewSlowdownCritHandlerInstance() : XTFinishersAbstractActionEndEventListener {
		return new XTFinishersDefaultSlowdownCritHandler in this;
	}
	
	protected function GetNewSlowdownFinisherHandlerInstance() : XTFinishersAbstractFinisherEventListener {
		return new XTFinishersDefaultSlowdownFinisherHandler in this;
	}
	
	protected function GetNewSlowdownDismemberHandlerInstance() : XTFinishersAbstractDismemberEventListener {
		return new XTFinishersDefaultSlowdownDismemberHandler in this;
	}
}

// listeners

class XTFinishersDefaultSlowdownCritHandler extends XTFinishersAbstractActionEndEventListener {
	public function GetPriority() : int {
		return theGame.xtFinishersMgr.consts.DEFAULT_SLOWDOWN_CRIT_QUERY_DISPATCHER_PRIORITY;
	}
	
	public function OnActionEndTriggered(context : XTFinishersActionContext) {
		var attackAction : W3Action_Attack;
		
		attackAction = (W3Action_Attack)context.action;
		if ((CR4Player)context.action.attacker && attackAction && attackAction.IsActionMelee() && attackAction.IsCriticalHit()) {
			PreprocessSlowdownCrit(context);
			
			if (context.slowdown.active) {
				if (context.slowdown.active && theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_DISABLE_CAMERA_SHAKE) {
					context.camShake.forceOff = true;
				}
				
				theGame.xtFinishersMgr.slowdownMgr.TriggerSlowdown(context);
			}
		}
	}
	
	protected function PreprocessSlowdownCrit(context : XTFinishersActionContext) {
		var chance : float;
		
		if (context.finisher.active || context.slowdown.active) {
			return;
		}
		
		if (context.action.victim.IsAlive()) {
			chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_CRIT_CHANCE_NONFATAL;
		} else {
			if (thePlayer.IsLastEnemyKilled()) {
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_CRIT_CHANCE_FATAL_LAST_ENEMY;
			} else {
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_CRIT_CHANCE_FATAL;
			}
		}
		
		if (RandRangeF(100) < chance) {
			context.slowdown.active = true;
			context.slowdown.type = theGame.xtFinishersMgr.consts.SLOWDOWN_TYPE_CRIT;
		}
	}
}

class XTFinishersDefaultSlowdownFinisherHandler extends XTFinishersAbstractFinisherEventListener {
	public function GetPriority() : int {
		return theGame.xtFinishersMgr.consts.DEFAULT_SLOWDOWN_FINISHER_QUERY_DISPATCHER_PRIORITY;
	}
	
	public function OnFinisherTriggered(context : XTFinishersActionContext) {
		PreprocessSlowdownFinisher(context);
		
		if (context.slowdown.active) {
			theGame.xtFinishersMgr.slowdownMgr.TriggerSlowdown(context);
		}
	}
	
	protected function PreprocessSlowdownFinisher(context : XTFinishersActionContext) {
		var chance : float;
		
		if (context.slowdown.active || context.finisherCam.active) {
			return;
		}
		
		if (thePlayer.IsLastEnemyKilled()) {
			if (context.finisher.auto) {
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_AUTO_CHANCE_LAST_ENEMY;
			} else if (context.finisher.instantKill) {
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_INSTANTKILL_CHANCE_LAST_ENEMY;
			} else {
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_CHANCE_LAST_ENEMY;
			}
		} else {
			if (context.finisher.auto) {
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_AUTO_CHANCE;
			} else if (context.finisher.instantKill) {
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_INSTANTKILL_CHANCE;
			} else {
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_CHANCE;
			}
		}
		
		if (RandRangeF(100) < chance) {
			context.slowdown.active = true;
			context.slowdown.type = theGame.xtFinishersMgr.consts.SLOWDOWN_TYPE_FINISHER;
		}
	}
}

class XTFinishersDefaultSlowdownDismemberHandler extends XTFinishersAbstractDismemberEventListener {
	public function GetPriority() : int {
		return theGame.xtFinishersMgr.consts.DEFAULT_SLOWDOWN_DISMEMBER_QUERY_DISPATCHER_PRIORITY;
	}
	
	public function OnDismemberTriggered(context : XTFinishersActionContext) {
		PreprocessSlowdownDismember(context);
		
		if (context.slowdown.active) {
			if (context.slowdown.active && theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_DISABLE_CAMERA_SHAKE) {
				context.camShake.forceOff = true;
			}
			
			theGame.xtFinishersMgr.slowdownMgr.TriggerSlowdown(context);
		}
	}
	
	protected function PreprocessSlowdownDismember(context : XTFinishersActionContext) {
		var chance : float;
		
		if (context.slowdown.active) {
			return;
		}
		
		if (thePlayer.IsLastEnemyKilled()) {
			if (context.dismember.auto) {
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_DISMEMBER_AUTO_CHANCE_LAST_ENEMY;
			} else {
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_DISMEMBER_CHANCE_LAST_ENEMY;
			}
		} else {
			if (context.dismember.auto) {
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_DISMEMBER_AUTO_CHANCE;
			} else {
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_DISMEMBER_CHANCE;
			}
		}
		
		if (RandRangeF(100) < chance) {
			context.slowdown.active = true;
			context.slowdown.type = theGame.xtFinishersMgr.consts.SLOWDOWN_TYPE_DISMEMBER;
		}
	}
}

// slowdown

class XTFinishersDefaultSlowdownManager extends XTFinishersAbstractSlowdownManager {
	private var critSeqDef, finisherSeqDef, dismemberSeqDef : XTFinishersSlowdownSequenceDef;
	
	public function Init() {
		var temp : XTFinishersSlowdownSegment;
		
		super.Init();
		
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
		case theGame.xtFinishersMgr.consts.SLOWDOWN_TYPE_CRIT :
			seqDef = GetCritSequence(context);
			break;
		case theGame.xtFinishersMgr.consts.SLOWDOWN_TYPE_FINISHER :
			seqDef = GetFinisherSequence(context);
			break;
		case theGame.xtFinishersMgr.consts.SLOWDOWN_TYPE_DISMEMBER :
			seqDef = GetDismemberSequence(context);
			break;
		}
		
		if (seqDef) {
			StartSlowdownSequence(seqDef);
		}
	}
	
	protected function GetCritSequence(context : XTFinishersActionContext) : XTFinishersSlowdownSequenceDef {
		return critSeqDef;
	}
	
	protected function GetFinisherSequence(context : XTFinishersActionContext) : XTFinishersSlowdownSequenceDef {
		return finisherSeqDef;
	}
	
	protected function GetDismemberSequence(context : XTFinishersActionContext) : XTFinishersSlowdownSequenceDef {
		return dismemberSeqDef;
	}
}