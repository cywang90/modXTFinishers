class XTFinishersDefaultSlowdownModule {
	public var params : XTFinishersDefaultSlowdownParams;
	
	public function Init() {
		params = new XTFinishersDefaultSlowdownParams in this;
		
		theGame.xtFinishersMgr.SetSlowdownManager(GetNewSlowdownManagerInstance());
		
		theGame.xtFinishersMgr.queryMgr.LoadSlowdownResponder(GetNewSlowdownQueryResponderInstance());
		
		theGame.xtFinishersMgr.eventMgr.RegisterEventListener(theGame.xtFinishersMgr.consts.ACTION_END_EVENT_ID, GetNewSlowdownCritQueryDispatcher());
		theGame.xtFinishersMgr.eventMgr.RegisterEventListener(theGame.xtFinishersMgr.consts.FINISHER_EVENT_ID, GetNewSlowdownFinisherQueryDispatcher());
		theGame.xtFinishersMgr.eventMgr.RegisterEventListener(theGame.xtFinishersMgr.consts.DISMEMBER_EVENT_ID, GetNewSlowdownDismemberQueryDispatcher());
	}
	
	protected function GetNewSlowdownManagerInstance() : XTFinishersSlowdownManager {
		var mgr : XTFinishersDefaultSlowdownManager;
		
		mgr = new XTFinishersDefaultSlowdownManager in this;
		mgr.Init();
		
		return mgr;
	}
	
	protected function GetNewSlowdownQueryResponderInstance() : XTFinishersSlowdownQueryResponder {
		return new XTFinishersDefaultSlowdownQueryResponder in this;
	}
	
	protected function GetNewSlowdownCritQueryDispatcher() : XTFinishersAbstractActionEndEventListener {
		return new XTFinishersDefaultSlowdownCritQueryDispatcher in this;
	}
	
	protected function GetNewSlowdownFinisherQueryDispatcher() : XTFinishersAbstractFinisherEventListener {
		return new XTFinishersDefaultSlowdownFinisherQueryDispatcher in this;
	}
	
	protected function GetNewSlowdownDismemberQueryDispatcher() : XTFinishersAbstractDismemberEventListener {
		return new XTFinishersDefaultSlowdownDismemberQueryDispatcher in this;
	}
}

// listeners

class XTFinishersDefaultSlowdownCritQueryDispatcher extends XTFinishersAbstractActionEndEventListener {
	public function GetPriority() : int {
		return theGame.xtFinishersMgr.consts.DEFAULT_SLOWDOWN_CRIT_QUERY_DISPATCHER_PRIORITY;
	}
	
	public function OnActionEndTriggered(out context : XTFinishersActionContext) {
		var attackAction : W3Action_Attack;
		
		if (context.finisher.active || context.slowdown.active) {
			return;
		}
		
		attackAction = (W3Action_Attack)context.action;
		if ((CR4Player)context.action.attacker && attackAction && attackAction.IsActionMelee() && attackAction.IsCriticalHit()) {
			context.slowdown.type = theGame.xtFinishersMgr.consts.SLOWDOWN_TYPE_CRIT;
			
			if (context.slowdown.active) {
				if (context.slowdown.active && theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_DISABLE_CAMERA_SHAKE) {
					context.camShake.forceOff = true;
				}
				
				theGame.xtFinishersMgr.slowdownMgr.TriggerSlowdown(context);
			}
		}
	}
}

class XTFinishersDefaultSlowdownFinisherQueryDispatcher extends XTFinishersAbstractFinisherEventListener {
	public function GetPriority() : int {
		return theGame.xtFinishersMgr.consts.DEFAULT_SLOWDOWN_FINISHER_QUERY_DISPATCHER_PRIORITY;
	}
	
	public function OnFinisherTriggered(out context : XTFinishersActionContext) {
		if (context.slowdown.active) {
			return;
		}
		
		context.slowdown.type = theGame.xtFinishersMgr.consts.SLOWDOWN_TYPE_FINISHER;
		if (!context.finisherCam.active) {
			theGame.xtFinishersMgr.queryMgr.FireSlowdownQuery(context);
		}
		
		if (context.slowdown.active) {
			theGame.xtFinishersMgr.slowdownMgr.TriggerSlowdown(context);
		}
	}
}

class XTFinishersDefaultSlowdownDismemberQueryDispatcher extends XTFinishersAbstractDismemberEventListener {
	public function GetPriority() : int {
		return theGame.xtFinishersMgr.consts.DEFAULT_SLOWDOWN_DISMEMBER_QUERY_DISPATCHER_PRIORITY;
	}
	
	public function OnDismemberTriggered(out context : XTFinishersActionContext) {
		if (context.slowdown.active) {
			return;
		}
		
		context.slowdown.type = theGame.xtFinishersMgr.consts.SLOWDOWN_TYPE_DISMEMBER;
		theGame.xtFinishersMgr.queryMgr.FireSlowdownQuery(context);
		
		if (context.slowdown.active) {
			if (context.slowdown.active && theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_DISABLE_CAMERA_SHAKE) {
				context.camShake.forceOff = true;
			}
			
			theGame.xtFinishersMgr.slowdownMgr.TriggerSlowdown(context);
		}
	}
}

// responders

class XTFinishersDefaultSlowdownQueryResponder extends XTFinishersSlowdownQueryResponder {
	protected function CanPerformSlowdownCrit(out context : XTFinishersActionContext) {
		var chance : float;
		
		if (context.action.victim.IsAlive()) {
			chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_CRIT_CHANCE_NONFATAL;
		} else {
			if (thePlayer.IsLastEnemyKilled()) {
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_CRIT_CHANCE_FATAL_LAST_ENEMY;
			} else {
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_CRIT_CHANCE_FATAL;
			}
		}
		
		context.slowdown.active = RandRangeF(100) < chance;
	}
	
	protected function CanPerformSlowdownFinisher(out context : XTFinishersActionContext) {
		var chance : float;
		
		if (thePlayer.IsLastEnemyKilled()) {
			if (context.finisher.auto) {
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_AUTO_CHANCE_LAST_ENEMY;
			} else {
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_CHANCE_LAST_ENEMY;
			}
		} else {
			if (context.finisher.auto) {
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_AUTO_CHANCE;
			} else {
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_CHANCE;
			}
		}
		
		context.slowdown.active = RandRangeF(100) < chance;
	}
	
	protected function CanPerformSlowdownDismember(out context : XTFinishersActionContext) {
		var chance : float;
		
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
		
		context.slowdown.active = RandRangeF(100) < chance;
	}
	
	public function CanPerformSlowdown(out context : XTFinishersActionContext) {
		if (thePlayer.IsCameraControlDisabled('Finisher')) {
			return;
		}
		
		switch (context.slowdown.type) {
		case theGame.xtFinishersMgr.consts.SLOWDOWN_TYPE_CRIT :
			CanPerformSlowdownCrit(context);
			break;
		case theGame.xtFinishersMgr.consts.SLOWDOWN_TYPE_FINISHER :
			CanPerformSlowdownFinisher(context);
			break;
		case theGame.xtFinishersMgr.consts.SLOWDOWN_TYPE_DISMEMBER :
			CanPerformSlowdownDismember(context);
			break;
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
			temp = new XTFinishersSlowdownDelay in this;
			temp.Init(theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_CRIT_DELAY);
			critSeqDef.AddSegment(temp);
		}
		if (theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_CRIT_DURATION > 0) {
			temp = new XTFinishersSlowdownSession in this;
			((XTFinishersSlowdownSession)temp).Init_Session(theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_CRIT_DURATION, theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_CRIT_FACTOR);
			critSeqDef.AddSegment(temp);
		}
		
		// define finisher slowdown sequence
		finisherSeqDef = new XTFinishersSlowdownSequenceDef in this;
		if (theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_A_DELAY > 0) {
			temp = new XTFinishersSlowdownDelay in this;
			temp.Init(theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_A_DELAY);
			finisherSeqDef.AddSegment(temp);
		}
		if (theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_A_DURATION > 0) {
			temp = new XTFinishersSlowdownSession in this;
			((XTFinishersSlowdownSession)temp).Init_Session(theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_A_DURATION, theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_A_FACTOR);
			finisherSeqDef.AddSegment(temp);
		}
		if (theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_B_DELAY > 0) {
			temp = new XTFinishersSlowdownDelay in this;
			temp.Init(theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_B_DELAY);
			finisherSeqDef.AddSegment(temp);
		}
		if (theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_B_DURATION > 0) {
			temp = new XTFinishersSlowdownSession in this;
			((XTFinishersSlowdownSession)temp).Init_Session(theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_B_DURATION, theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_B_FACTOR);
			finisherSeqDef.AddSegment(temp);
		}
		
		// define dismember slowdown sequence
		dismemberSeqDef = new XTFinishersSlowdownSequenceDef in this;
		if (theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_DISMEMBER_DELAY > 0) {
			temp = new XTFinishersSlowdownDelay in this;
			temp.Init(theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_DISMEMBER_DELAY);
			dismemberSeqDef.AddSegment(temp);
		}
		if (theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_DISMEMBER_DURATION > 0) {
			temp = new XTFinishersSlowdownSession in this;
			((XTFinishersSlowdownSession)temp).Init_Session(theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_DISMEMBER_DURATION, theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_DISMEMBER_FACTOR);
			dismemberSeqDef.AddSegment(temp);
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