
/*
	Controls slow-motion.
	
	Use StartSlowdownSequence() to start a slow-motion sequence.
*/
class XTFinishersSlowdownManager {
	public function Init() {}
	public function IsSequenceActive() : bool {return false;}
	public function IsSessionActive() : bool {return false;}
	public function StartSlowdownSequence(context : XTFinishersActionContext) {}
	public function EndSlowdownSequence() {}
}

class XTFinishersAbstractSlowdownManager extends XTFinishersSlowdownManager {
	private var sequenceActive, sessionActive : bool;
	private var sequenceContext : XTFinishersActionContext;
	
	private var sessionId : string;
	
	public function Init() {
		sequenceActive = false;
		sessionActive = false;
		sessionId = "";
	}
	
	public final function IsSequenceActive() : bool {
		return sequenceActive;
	}
	
	public final function IsSessionActive() : bool {
		return sessionActive;
	}
	
	public final function StartSlowdownSequence(context : XTFinishersActionContext) {
		if (IsSequenceActive()) {
			return;
		}
		
		sequenceActive = true;
		sequenceContext = context;
		OnSlowdownSequenceStart(context);
		theGame.xtFinishersMgr.eventMgr.FireSlowdownSequenceStartEvent(context);
	}
	
	public final function EndSlowdownSequence() {
		sequenceActive = false;
		OnSlowdownSequenceEnd(sequenceContext);
		theGame.xtFinishersMgr.eventMgr.FireSlowdownSequenceEndEvent(sequenceContext);
	}
	
	// factor : time factor
	// duration : duration of slowdown
	// id : identifier string that will be assigned to the slowdown session.
	// endSeqOnInterrupt : whether to end the sequence if the session is interrupted
	// endSeqOnTimeout : whether to end the sequence if the session times out
	public function StartSlowdownSession(factor : float, duration : float, id : string) : bool {
		if (IsSessionActive()) {
			return false;
		}
	
		if (!thePlayer.IsCameraControlDisabled('Finisher')) { // make sure finisher cam is not active
			theGame.SetTimeScale(factor, theGame.GetTimescaleSource(ETS_CFM_On), theGame.GetTimescalePriority(ETS_CFM_On), true, true);
			thePlayer.AddTimer('XTFinishersSlowdownTimerCallback', duration, false);
			sessionActive = true;
			this.sessionId = id;
			OnSlowdownSessionStart(factor, duration, id);
			theGame.xtFinishersMgr.eventMgr.FireSlowdownSessionStartEvent(factor, duration, id);
			return true;
		}
		return false;
	}
	
	// success : if the slowdown session timed out as intended (i.e. it was not terminated prematurely)
	public function EndSlowdownSession(success : bool) {
		var id : string;
		
		theGame.RemoveTimeScale(theGame.GetTimescaleSource(ETS_CFM_On));
		active = false;
		id = this.sessionId;
		this.sessionId = "";
		OnSlowdownSessionEnd(success, id);
		theGame.xtFinishersMgr.eventMgr.FireSlowdownSessionEndEvent(success, id);
	}
	
	protected function OnSlowdownSequenceStart(context : XTFinishersActionContext) {}
	protected function OnSlowdownSequenceEnd(context : XTFinishersActionContext) {}
	
	protected function OnSlowdownSessionStart(factor : float, duration : float, id : string) {}
	protected function OnSlowdownSessionEnd(success : bool, id : string) {}
}