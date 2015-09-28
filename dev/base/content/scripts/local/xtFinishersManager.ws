class XTFinishersManager {
	public var consts : XTFinishersConsts;
	
	public var queryMgr : XTFinishersQueryManager;
	public var eventMgr : XTFinishersEventManager;
	public var slowdownMgr : XTFinishersSlowdownManager;
	
	//========================
	// DEFINE MODULE VARS HERE
	//========================
	
	
	public function Init() {
		var vanilla : XTFinishersVanillaModule;
		
		// base mod components (don't mess with these unless you know what you are doing)
		consts = new XTFinishersConsts in this;
		
		queryMgr = new XTFinishersQueryManager in this;
		
		eventMgr = new XTFinishersEventManager in this;
		
		vanilla = new XTFinishersVanillaModule in this;
		
		//=================================================================
		// COMMENT LINES BELOW TO SELECTIVELY DISABLE VANILLA FUNCTIONALITY
		//=================================================================
		
		vanilla.InitFinisherComponents();	// finishers and cinematic finishers
		vanilla.InitDismemberComponents();	// dismemberments
		vanilla.InitCamShakeComponents();	// camera shake
		
		//==================
		// LOAD MODULES HERE
		//==================
		
	}
	
	public function SetSlowdownManager(mgr : XTFinishersSlowdownManager) {
		slowdownMgr = mgr;
	}
	
	public function CreateActionContext(action : W3DamageAction, effectsSnapshot : XTFinishersEffectsSnapshot) : XTFinishersActionContext {
		var context : XTFinishersActionContext;
		
		context.action = action;
		context.effectsSnapshot = effectsSnapshot;
		
		return context;
	}
}

class XTFinishersEffectsSnapshot {
	private var effectsTable : array<bool>;
	
	public function Initialize(actor : CActor) {
		var effects : array<CBaseGameplayEffect>;
		var i : int;
		
		effectsTable.Grow(EnumGetMax('EEffectType') + 1);
		for (i=0; i<effectsTable.Size(); i+=1) {
			effectsTable[i] = false;
		}
		
		effects = actor.GetBuffs();
		for (i=0; i<effects.Size(); i+=1) {
			effectsTable[effects[i].GetEffectType()] = true;
		}
	}
	
	public function HasEffect(type : EEffectType) : bool {
		return effectsTable[type];
	}
}

struct XTFinishersActionContext {
	var action : W3DamageAction;
	var effectsSnapshot : XTFinishersEffectsSnapshot;
	var finisher : XTFinishersFinisherContext;
	var dismember : XTFinishersDismemberContext;
	var finisherCam : XTFinishersFinisherCamContext;
	var slowdown : XTFinishersSlowdownContext;
	var camShake : XTFinishersCamShakeContext;
}

struct XTFinishersFinisherContext {
	var active : bool;										// will finisher be performed
	var auto : bool;										// is AUTOMATIC finisher
	var instantKill : bool;									// is INSTANT-KILL finisher
	var forced : bool;										// is FORCED finisher
};

struct XTFinishersDismemberContext {
	var active : bool;										// will dismember be performed
	var explosion : bool;									// is dismember explosion
	var auto : bool;										// is AUTOMATIC finisher
	var forced : bool;										// is FORCED dismember
};

struct XTFinishersFinisherCamContext {
	var active : bool;										// will cinematic camera be activated
};

struct XTFinishersSlowdownContext {
	var type : int;
	var active : bool;										// will slowdown be performed
};

struct XTFinishersCamShakeContext {
	var active : bool;
	var forceOff, forceOn : bool;
	var strength : float;
	var useExtraOpts : bool;
	var epicenter : Vector;
	var maxDistance : float;
};