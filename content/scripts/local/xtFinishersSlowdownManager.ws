
/*
	Controls slow-motion.
	
	Use TriggerSlowdown() to start a slow-motion sequence.
*/
class XTFinishersSlowdownManager {
	public function Init() {}
	public function IsActive() : bool {return false;}
	public function TriggerSlowdown(context : XTFinishersSlowdownContext) {}
}

class XTFinishersAbstractSlowdownManager extends XTFinishersSlowdownManager {
	private var active : bool;
	private var id : string;
	
	public function Init() {
		active = false;
		id = "";
	}
	
	public final function IsActive() : bool {
		return active;
	}
	
	public final function TriggerSlowdown(context : XTFinishersSlowdownContext) {
		OnSlowdownTriggered(context);
		theGame.xtFinishersMgr.eventMgr.FireSlowdownTriggerEvent(context);
	}
	
	// factor : time factor
	// duration : duration of slowdown
	// id : identifier string that will be assigned to the slowdown session.
	public function StartSlowdown(factor : float, duration : float, id : string) : bool {
		if (IsActive()) {
			return false;
		}
	
		if (!thePlayer.IsCameraControlDisabled('Finisher')) { // make sure finisher cam is not active
			theGame.SetTimeScale(factor, theGame.GetTimescaleSource(ETS_CFM_On), theGame.GetTimescalePriority(ETS_CFM_On), true, true);
			thePlayer.AddTimer('XTFinishersSlowdownTimerCallback', duration, false);
			active = true;
			this.id = id;
			theGame.xtFinishersMgr.eventMgr.FireSlowdownStartEvent(factor, duration, id);
			return true;
		}
		return false;
	}
	
	// success : if the slowdown session timed out as intended (i.e. it was not terminated prematurely)
	public function EndSlowdown(success : bool) {
		var id : string;
		
		theGame.RemoveTimeScale(theGame.GetTimescaleSource(ETS_CFM_On));
		active = false;
		id = this.id;
		this.id = "";
		theGame.xtFinishersMgr.eventMgr.FireSlowdownEndEvent(success, id);
	}
	
	protected function OnSlowdownTriggered(context : XTFinishersSlowdownContext) {}
}