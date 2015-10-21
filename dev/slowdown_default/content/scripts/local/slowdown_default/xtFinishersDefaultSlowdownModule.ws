class XTFinishersDefaultSlowdownModule extends XTFinishersObject {
	public const var DEFAULT_SLOWDOWN_DISMEMBER_QUERY_DISPATCHER_PRIORITY, DEFAULT_SLOWDOWN_FATAL_QUERY_DISPATCHER_PRIORITY, DEFAULT_SLOWDOWN_CRIT_QUERY_DISPATCHER_PRIORITY, DEFAULT_SLOWDOWN_FINISHER_QUERY_DISPATCHER_PRIORITY : int;
		// action end
		default DEFAULT_SLOWDOWN_FATAL_QUERY_DISPATCHER_PRIORITY = 5;
		default DEFAULT_SLOWDOWN_CRIT_QUERY_DISPATCHER_PRIORITY = 0;
		
		// dismember
		default DEFAULT_SLOWDOWN_DISMEMBER_QUERY_DISPATCHER_PRIORITY = 0;
		
		// finisher
		default DEFAULT_SLOWDOWN_FINISHER_QUERY_DISPATCHER_PRIORITY = 10;
		
	public var params : XTFinishersDefaultSlowdownParams;
	
	public function Init() {
		params = new XTFinishersDefaultSlowdownParams in this;
		
		theGame.xtFinishersMgr.SetSlowdownManager(GetNewSlowdownManagerInstance());
		
		theGame.xtFinishersMgr.eventMgr.RegisterEventListener(theGame.xtFinishersMgr.consts.ACTION_END_EVENT_ID, GetNewSlowdownFatalHandlerInstance());
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
	
	protected function GetNewSlowdownFatalHandlerInstance() : XTFinishersAbstractActionEndEventListener {
		return new XTFinishersDefaultSlowdownFatalHandler in this;
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

class XTFinishersDefaultSlowdownFatalHandler extends XTFinishersAbstractActionEndEventListener {
	public function GetPriority() : int {
		return theGame.xtFinishersMgr.slowdownModule.DEFAULT_SLOWDOWN_FATAL_QUERY_DISPATCHER_PRIORITY;
	}
	
	public function OnActionEndTriggered(context : XTFinishersActionContext) {
		var attackAction : W3Action_Attack;
		var actorVictim : CActor;
		
		attackAction = (W3Action_Attack)context.action;
		actorVictim = (CActor)context.action.victim;
		
		if ((CR4Player)context.action.attacker && attackAction && attackAction.IsActionMelee() && actorVictim && !actorVictim.IsAlive()) {
			PreprocessSlowdownFatal(context);
			
			if (context.slowdown.active) {
				if (context.slowdown.active && theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_DISABLE_CAMERA_SHAKE) {
					context.camShake.forceOff = true;
				}
				
				theGame.xtFinishersMgr.slowdownMgr.TriggerSlowdown(context);
			}
		}
	}
	
	protected function PreprocessSlowdownFatal(context : XTFinishersActionContext) {
		if (context.finisher.active || context.slowdown.active) {
			return;
		}
		
		if (RandRangeF(100) < theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FATAL_CHANCE) {
			context.slowdown.active = true;
			context.slowdown.type = XTF_SLOWDOWN_TYPE_FATAL;
		}
	}
}

class XTFinishersDefaultSlowdownCritHandler extends XTFinishersAbstractActionEndEventListener {
	public function GetPriority() : int {
		return theGame.xtFinishersMgr.slowdownModule.DEFAULT_SLOWDOWN_CRIT_QUERY_DISPATCHER_PRIORITY;
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
			context.slowdown.type = XTF_SLOWDOWN_TYPE_CRIT;
		}
	}
}

class XTFinishersDefaultSlowdownFinisherHandler extends XTFinishersAbstractFinisherEventListener {
	public function GetPriority() : int {
		return theGame.xtFinishersMgr.slowdownModule.DEFAULT_SLOWDOWN_FINISHER_QUERY_DISPATCHER_PRIORITY;
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
			switch (context.finisher.type) {
			case XTF_FINISHER_TYPE_AUTO:
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_AUTO_CHANCE_LAST_ENEMY;
				break;
			case XTF_FINISHER_TYPE_INSTANTKILL:
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_INSTANTKILL_CHANCE_LAST_ENEMY;
				break;
			case XTF_FINISHER_TYPE_KNOCKDOWN:
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_KNOCKDOWN_CHANCE_LAST_ENEMY;
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
			case XTF_FINISHER_TYPE_KNOCKDOWN:
				chance = theGame.xtFinishersMgr.slowdownModule.params.SLOWDOWN_FINISHER_KNOCKDOWN_CHANCE;
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

class XTFinishersDefaultSlowdownDismemberHandler extends XTFinishersAbstractDismemberEventListener {
	public function GetPriority() : int {
		return theGame.xtFinishersMgr.slowdownModule.DEFAULT_SLOWDOWN_DISMEMBER_QUERY_DISPATCHER_PRIORITY;
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