class XTFinishersManager extends XTFinishersObject {
	public var consts : XTFinishersConsts;
	
	public var queryMgr : XTFinishersQueryManager;
	public var eventMgr : XTFinishersEventManager;
	public var slowdownMgr : XTFinishersSlowdownManager;
	
	public var vanillaModule : XTFinishersVanillaModule;
	
	//========================
	// DEFINE MODULE VARS HERE
	//========================
	
	
	public function Init() {
		// base mod components (don't mess with these unless you know what you are doing)
		consts = new XTFinishersConsts in this;
		
		queryMgr = new XTFinishersQueryManager in this;
		
		eventMgr = new XTFinishersEventManager in this;
		
		vanillaModule = new XTFinishersVanillaModule in this;
		
		//=================================================================
		// COMMENT LINES BELOW TO SELECTIVELY DISABLE VANILLA FUNCTIONALITY
		//=================================================================
		
		vanillaModule.InitFinisherComponents();		// finishers and cinematic finishers
		vanillaModule.InitDismemberComponents();	// dismemberments
		vanillaModule.InitCamShakeComponents();		// camera shake
		
		//==================
		// LOAD MODULES HERE
		//==================
		
	}
	
	public function SetSlowdownManager(mgr : XTFinishersSlowdownManager) {
		slowdownMgr = mgr;
	}
}