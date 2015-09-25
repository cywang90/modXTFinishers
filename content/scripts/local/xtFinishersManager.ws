class XTFinishersManager {
	public var params : XTFinishersParams;
	
	public var queryMgr : XTFinishersQueryManager;
	public var eventMgr : XTFinishersEventManager;
	public var slowdownMgr : XTFinishersSlowdownManager;
	
	public function Init() {
		// base mod components (don't mess with these unless you know what you are doing)
		queryMgr = new XTFinishersQueryManager in this;
		
		eventMgr = new XTFinishersEventManager in this;
		eventMgr.Init();
		
		// load default mod components (replace these to define custom behavior)
		params = new XTFinishersParams in this;
		params.Init();
		
		slowdownMgr = new XTFinishersDefaultSlowdownManager in this;
		slowdownMgr.Init();
		
		queryMgr.LoadFinisherResponder(new XTFinishersDefaultFinisherQueryResponder in this);
		queryMgr.LoadDismemberResponder(new XTFinishersDefaultDismemberQueryResponder in this);
		queryMgr.LoadFinisherCamResponder(new XTFinishersDefaultFinisherCamQueryResponder in this);
		queryMgr.LoadSlowdownResponder(new XTFinishersDefaultSlowdownQueryResponder in this);
		
		eventMgr.RegisterReactionListener(new XTFinishersDefaultFinisherQueryDispatcher in this);
		eventMgr.RegisterReactionListener(new XTFinishersDefaultDismemberQueryDispatcher in this);
	}
	
	public function CreateActionContext(action : W3DamageAction, effectsSnapshot : XTFinishersEffectsSnapshot) : XTFinishersActionContext {
		var context : XTFinishersActionContext;
		
		context.action = action;
		context.effectsSnapshot = effectsSnapshot;
		
		return context;
	}
}