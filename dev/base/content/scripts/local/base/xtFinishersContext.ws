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
	
	public function HasEffects(types : array<EEffectType>, optional requireAll : bool) : bool {
		var i : int;
		
		if (requireAll) {
			for (i = 0; i < types.Size(); i += 1) {
				if (!HasEffect(types[i])) {
					return false;
				}
			}
			return true;
		} else {
			for (i = 0; i < types.Size(); i += 1) {
				if (HasEffect(types[i])) {
					return true;
				}
			}
			return false;
		}
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
	
	public function CountEnemiesNearPlayer() : int {
		var tempMoveTargets : array<CActor>;
		
		thePlayer.FindMoveTarget();
		tempMoveTargets = thePlayer.GetMoveTargets();
		if (!thePlayer.IsThreat(tempMoveTargets[0])) {
			return 0;
		} else {
			return tempMoveTargets.Size();
		}
	}
}

struct XTFinishersFinisherContext {
	var active : bool;										// will finisher be performed
	var type : XTFinishersFinisherType;						// type of finisher
	var forced : bool;										// is FORCED finisher
	var animName : name;
};

struct XTFinishersDismemberContext {
	var active : bool;										// will dismember be performed
	var type : XTFinishersDismemberType;					// type of dismember
	var explosion : bool;									// is dismember explosion
	var forced : bool;										// is FORCED dismember
};

struct XTFinishersFinisherCamContext {
	var active : bool;										// will cinematic camera be activated
};

struct XTFinishersSlowdownContext {
	var active : bool;										// will slowdown be performed
	var type : XTFinishersSlowdownType;						// type of finisher
};

struct XTFinishersCamShakeContext {
	var active : bool;
	var type : XTFinishersCamshakeType;
	var forceOff, forceOn : bool;							// deprecated
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