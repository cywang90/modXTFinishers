class XTFinishersCustomSlowdownModule {
	public var params : XTFinishersCustomSlowdownParams;
	
	public function InitAllComponents() {
		InitBaseComponents();
		InitSlowdownComponents();
	}
	
	public function InitBaseComponents() {
		params = new XTFinishersCustomSlowdownParams in this;
	}
	
	public function InitSlowdownComponents() {
		theGame.xtFinishersMgr.SetSlowdownManager(new XTFinishersCustomSlowdownManager in this);
		theGame.xtFinishersMgr.slowdownMgr.Init();
		
		theGame.xtFinishersMgr.queryMgr.LoadSlowdownResponder(new XTFinishersCustomSlowdownQueryResponder in this);
		
		theGame.xtFinishersMgr.eventMgr.RegisterFinisherListener(new XTFinishersCustomSlowdownFinisherQueryDispatcher in this);
		theGame.xtFinishersMgr.eventMgr.RegisterDismemberListener(new XTFinishersCustomSlowdownDismemberQueryDispatcher in this);
	}
}

// listeners

class XTFinishersCustomSlowdownFinisherQueryDispatcher extends XTFinishersAbstractFinisherEventListener {
	public function GetPriority() : int {
		return theGame.xtFinishersMgr.consts.CUSTOM_SLOWDOWN_FINISHER_QUERY_DISPATCHER_PRIORITY;
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

class XTFinishersCustomSlowdownDismemberQueryDispatcher extends XTFinishersAbstractDismemberEventListener {
	public function GetPriority() : int {
		return theGame.xtFinishersMgr.consts.CUSTOM_SLOWDOWN_DISMEMBER_QUERY_DISPATCHER_PRIORITY;
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

class XTFinishersCustomSlowdownQueryResponder extends XTFinishersSlowdownQueryResponder {
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

class XTFinishersCustomSlowdownManager extends XTFinishersAbstractSlowdownManager {
	private var finisherSeqDef, dismemberSeqDef : XTFinishersSlowdownSequenceDef;
	
	public function Init() {
		var temp : XTFinishersSlowdownSegment;
		
		super.Init();
		
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
		case theGame.xtFinishersMgr.consts.SLOWDOWN_TYPE_FINISHER :
			seqDef = finisherSeqDef;
			break;
		case theGame.xtFinishersMgr.consts.SLOWDOWN_TYPE_DISMEMBER :
			seqDef = dismemberSeqDef;
			break;
		}
		
		if (seqDef) {
			StartSlowdownSequence(seqDef);
		}
	}
}