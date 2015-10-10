class XTFinishersEffectsSnapshot {
	private var effectsTable : array<bool>;
	
	public function Init(actor : CActor) {
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

class XTFinishersActionContext extends XTFinishersObject {
	public var action : W3DamageAction;
	public var effectsSnapshot : XTFinishersEffectsSnapshot;
	public var finisher : XTFinishersFinisherContext;
	public var dismember : XTFinishersDismemberContext;
	public var finisherCam : XTFinishersFinisherCamContext;
	public var slowdown : XTFinishersSlowdownContext;
	public var camShake : XTFinishersCamShakeContext;
}

struct XTFinishersFinisherContext {
	var active : bool;										// will finisher be performed
	var auto : bool;										// is AUTOMATIC finisher
	var instantKill : bool;									// is INSTANT-KILL finisher
	var forced : bool;										// is FORCED finisher
	var debug : bool;										// is DEBUG finisher (i.e. forced thru dev console)
	var animName : name;
};

struct XTFinishersDismemberContext {
	var active : bool;										// will dismember be performed
	var explosion : bool;									// is dismember explosion
	var auto : bool;										// is AUTOMATIC finisher
	var forced : bool;										// is FORCED dismember
	var debug : bool;										// is DEBUG dismember (i.e. forced thru dev console)
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

// constructors

function CreateXTFinishersActionContext(owner : XTFinishersObject, action : W3DamageAction) : XTFinishersActionContext {
	var effectsSnapshot : XTFinishersEffectsSnapshot;
	var newInstance : XTFinishersActionContext;
	var actorVictim : CActor;
	
	newInstance = new XTFinishersActionContext in owner;
	
	effectsSnapshot = new XTFinishersEffectsSnapshot in newInstance;
	actorVictim = (CActor)action.victim;
	if (actorVictim) {
		effectsSnapshot.Init(actorVictim);
	}
	
	newInstance.action = action;
	newInstance.effectsSnapshot = effectsSnapshot;
	
	return newInstance;
}