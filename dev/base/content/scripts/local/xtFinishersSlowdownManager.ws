
/*
	Controls slow-motion.
	
	Use StartSlowdownSequence() to start a slow-motion sequence.
*/
abstract class XTFinishersSlowdownManager extends XTFinishersObject {
	public function Init();
	public function IsSequenceActive() : bool;
	public function IsSessionActive() : bool;
	public function TriggerSlowdown(context : XTFinishersActionContext);
}

abstract class XTFinishersAbstractSlowdownManager extends XTFinishersSlowdownManager {
	private var sequenceDef : XTFinishersSlowdownSequenceDef;
	private var currentIndex : int;
	private var sequenceActive: bool;
	private var sequenceContext : XTFinishersActionContext;
	
	public function Init() {
		sequenceDef = NULL;
		sequenceActive = false;
	}
	
	public final function IsSequenceActive() : bool {
		return sequenceActive;
	}
	
	public final function TriggerSlowdown(context : XTFinishersActionContext) {
		if (IsSequenceActive()) {
			return;
		}
		
		sequenceActive = true;
		sequenceContext = context;
		OnSlowdownSequenceStart(context);
	}
	
	protected function StartSlowdownSequence(sequenceDef : XTFinishersSlowdownSequenceDef) {
		var eventData : XTFinishersActionContextData;
		
		eventData = theGame.xtFinishersMgr.eventMgr.CreateActionContextData(sequenceContext);
		theGame.xtFinishersMgr.eventMgr.FireEvent(theGame.xtFinishersMgr.consts.SLOWDOWN_SEQUENCE_START_EVENT_ID, eventData);
		
		this.sequenceDef = sequenceDef;
		this.currentIndex = 0;
		
		TrySlowdownSegment();
	}
	
	protected function EndSlowdownSequence() {
		var eventData : XTFinishersActionContextData;
		
		sequenceActive = false;
		currentIndex = -1;
		OnSlowdownSequenceEnd(sequenceContext);
		
		eventData = theGame.xtFinishersMgr.eventMgr.CreateActionContextData(sequenceContext);
		theGame.xtFinishersMgr.eventMgr.FireEvent(theGame.xtFinishersMgr.consts.SLOWDOWN_SEQUENCE_END_EVENT_ID, eventData);
	}
	
	private function TrySlowdownSegment() {
		if (currentIndex < sequenceDef.Size()) {
			StartSlowdownSegment();
		} else {
			EndSlowdownSequence();
		}
	}
	
	public function StartSlowdownSegment() {
		var segment : XTFinishersSlowdownSegment;
		var eventData : XTFinishersSlowdownSegmentData;
	
		if (!thePlayer.IsCameraControlDisabled('Finisher')) { // make sure finisher cam is not active
			segment = sequenceDef.GetSegment(currentIndex);
			
			segment.Start(sequenceContext);
			
			OnSlowdownSegmentStart(segment);
			
			eventData = theGame.xtFinishersMgr.eventMgr.CreateSlowdownSegmentData(segment);
			theGame.xtFinishersMgr.eventMgr.FireEvent(theGame.xtFinishersMgr.consts.SLOWDOWN_SEGMENT_START_EVENT_ID, eventData);
		}
	}
	
	// success : if the slowdown session timed out as intended (i.e. it was not terminated prematurely)
	public function EndSlowdownSegment(success : bool) {
		var segment : XTFinishersSlowdownSegment;
		var eventData : XTFinishersSlowdownSegmentData;
		
		segment = sequenceDef.GetSegment(currentIndex);
		
		segment.End(success);
		
		OnSlowdownSessionEnd(segment, success);
		
		eventData = theGame.xtFinishersMgr.eventMgr.CreateSlowdownSegmentData(segment, success);
		theGame.xtFinishersMgr.eventMgr.FireEvent(theGame.xtFinishersMgr.consts.SLOWDOWN_SEGMENT_END_EVENT_ID, eventData);
		
		currentIndex += 1;
		TrySlowdownSegment();
	}
	
	protected function OnSlowdownSequenceStart(context : XTFinishersActionContext) {}
	protected function OnSlowdownSequenceEnd(context : XTFinishersActionContext) {}
	
	protected function OnSlowdownSegmentStart(segment : XTFinishersSlowdownSegment) {}
	protected function OnSlowdownSessionEnd(segment : XTFinishersSlowdownSegment, success : bool) {}
}

class XTFinishersSlowdownSequenceDef extends XTFinishersObject {
	private var segments : array<XTFinishersSlowdownSegment>;
	
	public function Size() : int {
		return segments.Size();
	}
	
	public function AddSegment(segment : XTFinishersSlowdownSegment) {
		segments.PushBack(segment);
	}
	
	public function GetSegment(index : int) : XTFinishersSlowdownSegment {
		if (index < segments.Size()) {
			return segments[index];
		} else {
			return NULL;
		}
	}
}

abstract class XTFinishersSlowdownSegment extends XTFinishersObject {
	private var duration : float;
	
	public function Init(duration : float) {
		this.duration = duration;
	}
	
	public function GetDuration() : float {
		return duration;
	}
	
	public function Start(context : XTFinishersActionContext) {
		thePlayer.AddTimer('XTFinishersSlowdownTimerCallback', GetDuration(), false);
	}
	
	public function End(success : bool) {}
}

class XTFinishersSlowdownSession extends XTFinishersSlowdownSegment {
	private var factor : float;
	
	public function Init_Session(duration : float, factor : float) {
		Init(duration);
		this.factor = factor;
	}
	
	public function Start(context : XTFinishersActionContext) {
		super.Start(context);
		theGame.SetTimeScale(factor, theGame.GetTimescaleSource(ETS_CFM_On), theGame.GetTimescalePriority(ETS_CFM_On), true, true);
	}
	
	public function End(success : bool) {
		theGame.RemoveTimeScale(theGame.GetTimescaleSource(ETS_CFM_On));
		super.End(success);
	}
}

class XTFinishersSlowdownDelay extends XTFinishersSlowdownSegment {
}