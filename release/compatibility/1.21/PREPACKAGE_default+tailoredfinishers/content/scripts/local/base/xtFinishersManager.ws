class XTFinishersManager extends XTFinishersObject {
	public var consts : XTFinishersConsts;
	
	public var queryMgr : XTFinishersQueryManager;
	public var eventMgr : XTFinishersEventManager;
	public var slowdownMgr : XTFinishersSlowdownManager;
	
	public var vanillaModule : XTFinishersVanillaModule;
	
	//========================
	// DEFINE MODULE VARS HERE
	//========================
	public var finisherModule : XTFinishersDefaultFinisherModule;
	public var dismemberModule : XTFinishersDefaultDismemberModule;
	public var slowdownModule : XTFinishersDefaultSlowdownModule;
	public var camshakeModule : XTFinishersDefaultCamShakeModule;
	
	public function Init() {
		// base mod components (don't mess with these unless you know what you are doing)
		consts = new XTFinishersConsts in this;
		
		queryMgr = new XTFinishersQueryManager in this;
		
		eventMgr = new XTFinishersEventManager in this;
		
		//=================================================================
		// COMMENT LINES BELOW TO SELECTIVELY DISABLE VANILLA FUNCTIONALITY
		//=================================================================
		
		//vanillaModule.InitFinisherComponents();		// finishers and cinematic finishers
		//vanillaModule.InitDismemberComponents();	// dismemberments
		//vanillaModule.InitCamShakeComponents();		// camera shake
		
		//==================
		// LOAD MODULES HERE
		//==================
		
		// load finisher module
		finisherModule = new XTFinishersDefaultFinisherModule in this;
		finisherModule.Init();
		
		// load dismember module
		dismemberModule = new XTFinishersDefaultDismemberModule in this;
		dismemberModule.Init();
		
		// load slowdown module
		slowdownModule = new XTFinishersTailoredFinishersSlowdownModule in this;
		slowdownModule.Init();
		
		// load camshake module
		camshakeModule = new XTFinishersDefaultCamShakeModule in this;
		camshakeModule.Init();
	}
	
	public function SetSlowdownManager(mgr : XTFinishersSlowdownManager) {
		slowdownMgr = mgr;
	}
}