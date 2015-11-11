class XTFinishersDefaultFinisherModule extends XTFinishersObject {
	public const var DEFAULT_FINISHER_HANDLER_PRIORITY, DEFAULT_FINISHER_CAMSHAKE_DISABLE_HANDLER_PRIORITY : int;
		default DEFAULT_FINISHER_HANDLER_PRIORITY = 0;
		default DEFAULT_FINISHER_CAMSHAKE_DISABLE_HANDLER_PRIORITY = 0;
	
	public var params : XTFinishersDefaultFinisherParams;
	
	private var defaultPreset, userPreset : XTFinishersDefaultFinisherParamsPreset;
	
	public function Init() {
		// initialize parameters
		params = new XTFinishersDefaultFinisherParams in this;
		params.Init();
		
		// initialize default preset file and load settings into params
		defaultPreset = new XTFinishersDefaultFinisherDefaultPreset in this;
		defaultPreset.Init();
		params.LoadParamsFromList(defaultPreset);
		
		// initialize user preset file and load settings into params
		userPreset = new XTFinishersDefaultFinisherUserPreset in this;
		userPreset.Init();
		params.LoadParamsFromList(userPreset);
		
		// register listeners
		theGame.xtFinishersMgr.eventMgr.RegisterEventListener(theGame.xtFinishersMgr.consts.REACTION_START_EVENT_ID, GetNewFinisherHandlerInstance());
		theGame.xtFinishersMgr.eventMgr.RegisterEventListener(theGame.xtFinishersMgr.consts.CAMSHAKE_PRE_EVENT_ID, GetNewFinisherCamshakeDisableHandlerInstance());
	}
	
	protected function GetNewFinisherHandlerInstance() : XTFinishersAbstractReactionStartEventListener {
		return new XTFinishersDefaultFinisherHandler in this;
	}
	
	protected function GetNewFinisherCamshakeDisableHandlerInstance() : XTFinishersAbstractCamshakePretriggerEventListener {
		return new XTFinishersDefaultFinisherCamshakeDisableHandler in this;
	}
}

// listeners

class XTFinishersDefaultFinisherHandler extends XTFinishersAbstractReactionStartEventListener {
	public function GetPriority() : int {
		return theGame.xtFinishersMgr.finisherModule.DEFAULT_FINISHER_HANDLER_PRIORITY;
	}
	
	public function OnReactionStartTriggered(context : XTFinishersActionContext) {
		PreprocessFinisher(context);
		if (context.finisher.active) {
			PreprocessFinisherCam(context);
		}
	}
	
	protected function PreprocessFinisher(context : XTFinishersActionContext) {
		var actorVictim				: CActor;
		var attackAction			: W3Action_Attack;
		var finisherChance 			: float;
		var areEnemiesAttacking		: bool;
		var i						: int;
		var victimToPlayerVector, playerPos	: Vector;
		var item 					: SItemUniqueId;
		var moveTargets				: array<CActor>;
		var result					: bool;
		var size					: int;
		var npc						: CNewNPC;
		var autoFinisherEffectTypes : array<EEffectType>;
		var hasEffect				: bool;
		var levelDelta				: int;
		var areEnemiesAttackingModifier, navCheckModifier : bool;
		
		actorVictim = (CActor)context.action.victim;
		attackAction = (W3Action_Attack)context.action;
		
		if ((W3ReplacerCiri)thePlayer || (CR4Player)context.action.victim || thePlayer.isInFinisher) {
			return;
		}
		
		context.finisher.type = XTF_FINISHER_TYPE_REGULAR;
		
		playerPos = thePlayer.GetWorldPosition();
		moveTargets = thePlayer.GetMoveTargets();	
		size = moveTargets.Size();
		if (size > 0) {
			areEnemiesAttacking = false;			
			for(i = 0; i < size; i += 1) {
				npc = (CNewNPC)moveTargets[i];
				if(npc && VecDistanceSquared(playerPos, moveTargets[i].GetWorldPosition()) < 7 && npc.IsAttacking() && npc != actorVictim ) {
					areEnemiesAttacking = true;
					break;
				}
			}
		}
		
		victimToPlayerVector = actorVictim.GetWorldPosition() - playerPos;
		
		if (actorVictim.IsAlive()) {
			if (CanPerformInstantKillFinisher(context)) {
				context.finisher.type = XTF_FINISHER_TYPE_INSTANTKILL;
				finisherChance = 100;
			} else {
				return;
			}
		} else {
			context.finisher.forced = actorVictim.HasTag('ForceFinisher');
				
			if (!context.finisher.forced) {
				if (actorVictim.IsHuman()) {
					if (CanPerformAutoFinisher(context)) {
						context.finisher.type = XTF_FINISHER_TYPE_AUTO;
						finisherChance = 100;
					} else {
						npc = (CNewNPC)actorVictim;
						if (( size <= 1 && theGame.params.FINISHER_ON_DEATH_CHANCE > 0) || (actorVictim.HasAbility('ForceFinisher'))) {
							finisherChance = 100;
						} else if (theGame.xtFinishersMgr.finisherModule.params.FINISHER_CHANCE_OVERRIDE) {
							finisherChance = theGame.xtFinishersMgr.finisherModule.params.FINISHER_CHANCE_BASE;
							levelDelta = thePlayer.GetLevel() - npc.currentLevel;
							if (levelDelta >= 0) {
								finisherChance += theGame.xtFinishersMgr.finisherModule.params.FINISHER_CHANCE_LEVEL_BONUS * levelDelta;
							} else {
								finisherChance += theGame.xtFinishersMgr.finisherModule.params.FINISHER_CHANCE_LEVEL_PENALTY * levelDelta;
							}
						} else {
							if (npc.currentLevel - thePlayer.GetLevel() < -5) {
								finisherChance = theGame.params.FINISHER_ON_DEATH_CHANCE + (-(npc.currentLevel - thePlayer.GetLevel()));
							} else {
								finisherChance = theGame.params.FINISHER_ON_DEATH_CHANCE;
							}
						}
					}
					finisherChance = ClampF(finisherChance, 0, 100);
				} else {
					finisherChance = 0;
				}
			}
		}
		
		if (thePlayer.forceFinisher && actorVictim.IsHuman()) {
			context.finisher.active = true;
			context.finisher.type = XTF_FINISHER_TYPE_DEBUG;
			return;
		}
		
		switch (context.finisher.type) {
		case XTF_FINISHER_TYPE_AUTO :
			areEnemiesAttackingModifier = !theGame.xtFinishersMgr.finisherModule.params.FINISHER_AUTO_REQUIRE_NO_AGGRO;
			navCheckModifier = !theGame.xtFinishersMgr.finisherModule.params.FINISHER_AUTO_REQUIRE_NAV_CHECK;
			break;
		case XTF_FINISHER_TYPE_INSTANTKILL :
			areEnemiesAttackingModifier = !theGame.xtFinishersMgr.finisherModule.params.FINISHER_INSTANTKILL_REQUIRE_NO_AGGRO;
			navCheckModifier = !theGame.xtFinishersMgr.finisherModule.params.FINISHER_INSTANTKILL_REQUIRE_NAV_CHECK;
			break;
		default :
			areEnemiesAttackingModifier = !theGame.xtFinishersMgr.finisherModule.params.FINISHER_REQUIRE_NO_AGGRO;
			navCheckModifier = !theGame.xtFinishersMgr.finisherModule.params.FINISHER_REQUIRE_NAV_CHECK;
		}
		
			
		item = thePlayer.inv.GetItemFromSlot('l_weapon');	

		result = ((CR4Player)context.action.attacker) && attackAction && attackAction.IsActionMelee();
		result = result && (actorVictim.IsHuman() && !actorVictim.IsWoman());
		result = result && RandRangeF(100) < finisherChance;
		result = result && (areEnemiesAttackingModifier || !areEnemiesAttacking);
		result = result && (context.finisher.type == XTF_FINISHER_TYPE_DEBUG || AbsF(victimToPlayerVector.Z) < 0.4f);
		result = result && !thePlayer.IsInAir();
		result = result && (thePlayer.IsWeaponHeld('steelsword') || thePlayer.IsWeaponHeld('silversword'));
		result = result && !thePlayer.IsSecondaryWeaponHeld();
		result = result && !thePlayer.inv.IsIdValid(item);
		result = result && !actorVictim.IsKnockedUnconscious();
		result = result && !context.effectsSnapshot.HasEffect(EET_Knockdown);
		result = result && !context.effectsSnapshot.HasEffect(EET_Ragdoll);
		result = result && !context.effectsSnapshot.HasEffect(EET_Frozen);
		result = result && (context.finisher.type == XTF_FINISHER_TYPE_DEBUG || !actorVictim.HasAbility('DisableFinishers'));
		result = result && (context.finisher.type == XTF_FINISHER_TYPE_DEBUG || actorVictim.GetAttitude(thePlayer) == AIA_Hostile);
		result = result && !thePlayer.IsUsingVehicle();
		result = result && thePlayer.IsAlive();
		result = result && !thePlayer.IsCurrentSignChanneled();
		result = result && (navCheckModifier || theGame.GetWorld().NavigationCircleTest(actorVictim.GetWorldPosition(), 2.f)) ;
		
		if (result) {
			if (!actorVictim.IsAlive()) {
				actorVictim.AddAbility('DisableFinishers', false);
			}
			context.finisher.active = true;
			context.finisher.animName = SelectFinisherAnimName(context);
		}
	}
	
	protected function CanPerformAutoFinisher(context : XTFinishersActionContext) : bool {
		var attackAction : W3Action_Attack;
		var result : bool;
		
		result = false;
		attackAction = (W3Action_Attack)context.action;
		
		if (attackAction) {
			if (attackAction.IsCriticalHit() && RandRangeF(100) < theGame.xtFinishersMgr.finisherModule.params.FINISHER_AUTO_CHANCE_CRIT) {
				result = true;
			} else if (SkillNameToEnum(attackAction.GetAttackTypeName()) == S_Sword_s02 && RandRangeF(100) < theGame.xtFinishersMgr.finisherModule.params.FINISHER_AUTO_CHANCE_REND) {
				result = true;
			} else if (context.CountEnemiesNearPlayer() <= 1 && RandRangeF(100) < theGame.xtFinishersMgr.finisherModule.params.FINISHER_AUTO_CHANCE_LAST_ENEMY) {
				result = true;
			} else if (context.effectsSnapshot.HasEffects(theGame.xtFinishersMgr.finisherModule.params.autoFinisherEffectTypes) && RandRangeF(100) < theGame.xtFinishersMgr.finisherModule.params.FINISHER_AUTO_CHANCE_EFFECTS) {
				result = true;
			}
		}
		
		return result;
	}
	
	protected function CanPerformInstantKillFinisher(context : XTFinishersActionContext) : bool {
		var actorVictim : CActor;
		var attackAction : W3Action_Attack;
		var result : bool;
		var hasEffect : bool;
		var instantKillFinisherEffectTypes : array<EEffectType>;
		var i : int;
		
		result = false;
		actorVictim = (CActor)context.action.victim;
		attackAction = (W3Action_Attack)context.action;
		
		if (actorVictim.IsHuman() && actorVictim.IsVulnerable() && !actorVictim.HasAbility('InstantKillImmune')) {
			if (attackAction) {
				if (attackAction.IsCriticalHit() && RandRangeF(100) < theGame.xtFinishersMgr.finisherModule.params.FINISHER_INSTANTKILL_CHANCE_CRIT) {
					result = true;
				} else if (context.CountEnemiesNearPlayer() <= 1 && RandRangeF(100) < theGame.xtFinishersMgr.finisherModule.params.FINISHER_INSTANTKILL_CHANCE_LAST_ENEMY) {
					result = true;
				} else if (context.effectsSnapshot.HasEffects(theGame.xtFinishersMgr.finisherModule.params.instantKillFinisherEffectTypes) && RandRangeF(100) < theGame.xtFinishersMgr.finisherModule.params.FINISHER_INSTANTKILL_CHANCE_EFFECTS) {
					result = true;
				}
			}
		}
		
		return result;
	}
	
	protected function SelectFinisherAnimName(context : XTFinishersActionContext) : name {
		var animNames : array<name>;
		
		if (thePlayer.forceFinisher && thePlayer.forceFinisherAnimName != '') {
			return thePlayer.forceFinisherAnimName;
		}
		
		if (thePlayer.GetCombatIdleStance() <= 0.f) {
			animNames = theGame.xtFinishersMgr.finisherModule.params.allowedLeftSideFinisherAnimNames;
		} else {
			animNames = theGame.xtFinishersMgr.finisherModule.params.allowedRightSideFinisherAnimNames;
		}
		
		return animNames[RandRange(animNames.Size(), 0)];
	}
	
	protected function PreprocessFinisherCam(context : XTFinishersActionContext) {
		var chance : float;
		
		if (context.CountEnemiesNearPlayer() <= 1) {
			chance = theGame.xtFinishersMgr.finisherModule.params.FINISHER_CAM_CHANCE_LAST_ENEMY;
		} else {
			chance = theGame.xtFinishersMgr.finisherModule.params.FINISHER_CAM_CHANCE;
		}
	
		context.finisherCam.active = RandRangeF(100) < chance
				&& (!theGame.xtFinishersMgr.finisherModule.params.FINISHER_CAM_REQUIRE_NAV_CHECK || theGame.GetWorld().NavigationCircleTest(thePlayer.GetWorldPosition(), 3.f));
	}
}

class XTFinishersDefaultFinisherCamshakeDisableHandler extends XTFinishersAbstractCamshakePretriggerEventListener {
	public function GetPriority() : int {
		return theGame.xtFinishersMgr.finisherModule.DEFAULT_FINISHER_CAMSHAKE_DISABLE_HANDLER_PRIORITY;
	}
	
	public function OnCamshakePretrigger(context : XTFinishersActionContext) {
		context.camShake.active = context.camShake.active && (!context.finisherCam.active || !theGame.xtFinishersMgr.finisherModule.params.FINISHER_CAM_DISABLE_CAMERA_SHAKE);
	}
}

//=======
// PARAMS
//=======

class XTFinishersDefaultFinisherParams extends XTFinishersParams {
	//==================
	// FINISHER SETTINGS
	//==================
	public var FINISHER_REQUIRE_NO_AGGRO, FINISHER_REQUIRE_NAV_CHECK : bool;
	public var FINISHER_CHANCE_OVERRIDE : bool;
	public var FINISHER_CHANCE_BASE, FINISHER_CHANCE_LEVEL_BONUS, FINISHER_CHANCE_LEVEL_PENALTY : float;
	
	public var FINISHER_AUTO_CHANCE_EFFECTS, FINISHER_AUTO_CHANCE_CRIT, FINISHER_AUTO_CHANCE_REND, FINISHER_AUTO_CHANCE_LAST_ENEMY : float;
	public var FINISHER_AUTO_REQUIRE_NO_AGGRO, FINISHER_AUTO_REQUIRE_NAV_CHECK : bool;
	
	public var FINISHER_INSTANTKILL_CHANCE_EFFECTS, FINISHER_INSTANTKILL_CHANCE_CRIT, FINISHER_INSTANTKILL_CHANCE_LAST_ENEMY : float;
	public var FINISHER_INSTANTKILL_REQUIRE_NO_AGGRO, FINISHER_INSTANTKILL_REQUIRE_NAV_CHECK : bool;
	
	//======================
	// FINISHER CAM SETTINGS
	//======================
	
	public var FINISHER_CAM_DISABLE_CAMERA_SHAKE : bool;
	
	public var FINISHER_CAM_CHANCE, FINISHER_CAM_CHANCE_LAST_ENEMY : float;
	public var FINISHER_CAM_REQUIRE_NAV_CHECK : bool;
	
	
	public var autoFinisherEffectTypes, instantKillFinisherEffectTypes : array<EEffectType>;
	
	public var allowedLeftSideFinisherAnimNames, allowedRightSideFinisherAnimNames : array<name>;
	
	public function LoadParam(paramDef : XTFinishersParamDefinition) {
		switch (paramDef.GetId()) {
		case "FINISHER_REQUIRE_NO_AGGRO": FINISHER_REQUIRE_NO_AGGRO = ((XTFinishersBool)paramDef.GetData()).value; break;
		case "FINISHER_REQUIRE_NAV_CHECK": FINISHER_REQUIRE_NAV_CHECK = ((XTFinishersBool)paramDef.GetData()).value; break;
		case "FINISHER_CHANCE_OVERRIDE": FINISHER_CHANCE_OVERRIDE = ((XTFinishersBool)paramDef.GetData()).value; break;
		case "FINISHER_CHANCE_BASE": FINISHER_CHANCE_BASE = ((XTFinishersFloat)paramDef.GetData()).value; break;
		case "FINISHER_CHANCE_LEVEL_BONUS": FINISHER_CHANCE_LEVEL_BONUS = ((XTFinishersFloat)paramDef.GetData()).value; break;
		case "FINISHER_CHANCE_LEVEL_PENALTY": FINISHER_CHANCE_LEVEL_PENALTY = ((XTFinishersFloat)paramDef.GetData()).value; break;
		case "FINISHER_AUTO_CHANCE_EFFECTS": FINISHER_AUTO_CHANCE_EFFECTS = ((XTFinishersFloat)paramDef.GetData()).value; break;
		case "FINISHER_AUTO_CHANCE_CRIT": FINISHER_AUTO_CHANCE_CRIT = ((XTFinishersFloat)paramDef.GetData()).value; break;
		case "FINISHER_AUTO_CHANCE_REND": FINISHER_AUTO_CHANCE_REND = ((XTFinishersFloat)paramDef.GetData()).value; break;
		case "FINISHER_AUTO_CHANCE_LAST_ENEMY": FINISHER_AUTO_CHANCE_LAST_ENEMY = ((XTFinishersFloat)paramDef.GetData()).value; break;
		case "FINISHER_AUTO_REQUIRE_NO_AGGRO": FINISHER_AUTO_REQUIRE_NO_AGGRO = ((XTFinishersBool)paramDef.GetData()).value; break;
		case "FINISHER_AUTO_REQUIRE_NAV_CHECK": FINISHER_AUTO_REQUIRE_NAV_CHECK = ((XTFinishersBool)paramDef.GetData()).value; break;
		case "FINISHER_INSTANTKILL_CHANCE_EFFECTS": FINISHER_INSTANTKILL_CHANCE_EFFECTS = ((XTFinishersFloat)paramDef.GetData()).value; break;
		case "FINISHER_INSTANTKILL_CHANCE_CRIT": FINISHER_INSTANTKILL_CHANCE_CRIT = ((XTFinishersFloat)paramDef.GetData()).value; break;
		case "FINISHER_INSTANTKILL_CHANCE_LAST_ENEMY": FINISHER_INSTANTKILL_CHANCE_LAST_ENEMY = ((XTFinishersFloat)paramDef.GetData()).value; break;
		case "FINISHER_INSTANTKILL_REQUIRE_NO_AGGRO": FINISHER_INSTANTKILL_REQUIRE_NO_AGGRO = ((XTFinishersBool)paramDef.GetData()).value; break;
		case "FINISHER_INSTANTKILL_REQUIRE_NAV_CHECK": FINISHER_INSTANTKILL_REQUIRE_NAV_CHECK = ((XTFinishersBool)paramDef.GetData()).value; break;
		case "FINISHER_CAM_DISABLE_CAMERA_SHAKE": FINISHER_CAM_DISABLE_CAMERA_SHAKE = ((XTFinishersBool)paramDef.GetData()).value; break;
		case "FINISHER_CAM_CHANCE": FINISHER_CAM_CHANCE = ((XTFinishersFloat)paramDef.GetData()).value; break;
		case "FINISHER_CAM_CHANCE_LAST_ENEMY": FINISHER_CAM_CHANCE_LAST_ENEMY = ((XTFinishersFloat)paramDef.GetData()).value; break;
		case "FINISHER_CAM_REQUIRE_NAV_CHECK": FINISHER_CAM_REQUIRE_NAV_CHECK = ((XTFinishersBool)paramDef.GetData()).value; break;
		case "autoFinisherEffectTypes": autoFinisherEffectTypes = ((XTFinishersDefaultFinisherEffectTypeArray)paramDef.GetData()).value; break;
		case "instantKillFinisherEffectTypes": instantKillFinisherEffectTypes = ((XTFinishersDefaultFinisherEffectTypeArray)paramDef.GetData()).value; break;
		case "allowedLeftSideFinisherAnimNames": allowedLeftSideFinisherAnimNames = ((XTFinishersDefaultFinisherNameArray)paramDef.GetData()).value; break;
		case "allowedRightSideFinisherAnimNames": allowedRightSideFinisherAnimNames = ((XTFinishersDefaultFinisherNameArray)paramDef.GetData()).value; break;
		}
	}
}

// wrapper classes

class XTFinishersDefaultFinisherEffectTypeArray extends XTFinishersObject {
	public var value : array<EEffectType>;
	
	public function Init(value : array<EEffectType>) {
		this.value = value;
	}
}

class XTFinishersDefaultFinisherNameArray extends XTFinishersObject {
	public var value : array<name>;
	
	public function Init(value : array<name>) {
		this.value = value;
	}
}

// convenience constructors

function CreateXTFinishersDefaultFinisherEffectTypeArray(owner : XTFinishersObject, value : array<EEffectType>) : XTFinishersDefaultFinisherEffectTypeArray {
	var obj : XTFinishersDefaultFinisherEffectTypeArray;
	
	obj = new XTFinishersDefaultFinisherEffectTypeArray in owner;
	obj.Init(value);
	return obj;
}

function CreateXTFinishersDefaultFinisherNameArray(owner : XTFinishersObject, value : array<name>) : XTFinishersDefaultFinisherNameArray {
	var obj : XTFinishersDefaultFinisherNameArray;
	
	obj = new XTFinishersDefaultFinisherNameArray in owner;
	obj.Init(value);
	return obj;
}

function CreateXTFinishersParamDefDefaultFinisherEffectTypeArray(owner : XTFinishersObject, id : string, value : array<EEffectType>) : XTFinishersParamDefinition {
	var paramDef : XTFinishersConcreteParamDefinition;
	
	paramDef = new XTFinishersConcreteParamDefinition in owner;
	paramDef.Init(id, CreateXTFinishersDefaultFinisherEffectTypeArray(paramDef, value));
	return paramDef;
}

function CreateXTFinishersParamDefDefaultFinisherNameArray(owner : XTFinishersObject, id : string, value : array<name>) : XTFinishersParamDefinition {
	var paramDef : XTFinishersConcreteParamDefinition;
	
	paramDef = new XTFinishersConcreteParamDefinition in owner;
	paramDef.Init(id, CreateXTFinishersDefaultFinisherNameArray(paramDef, value));
	return paramDef;
}

// preset class
abstract class XTFinishersDefaultFinisherParamsPreset extends XTFinishersParamsPreset {
	public function Init();
	
	// convenience functions
	public function AddParamFloat(id : string, value : float) {
		AddParam(CreateXTFinishersParamDefFloat(this, id, value));
	}
	
	public function AddParamBool(id : string, value : bool) {
		AddParam(CreateXTFinishersParamDefBool(this, id, value));
	}
	
	public function AddParamEffectTypeArray(id : string, value : array<EEffectType>) {
		AddParam(CreateXTFinishersParamDefDefaultFinisherEffectTypeArray(this, id, value));
	}
	
	public function AddParamNameArray(id : string, value : array<name>) {
		AddParam(CreateXTFinishersParamDefDefaultFinisherNameArray(this, id, value));
	}
}

// default preset
class XTFinishersDefaultFinisherDefaultPreset extends XTFinishersParamsPreset {
	private var autoFinisherEffectTypes, instantKillFinisherEffectTypes : array<EEffectType>;
	private var allowedLeftSideFinisherAnimNames, allowedRightSideFinisherAnimNames : array<name>;
	private var dlcFinishers : array<CR4FinisherDLC>;
	
	public function Init() {
		AddParamBool("FINISHER_REQUIRE_NO_AGGRO", true);
		AddParamBool("FINISHER_REQUIRE_NAV_CHECK", true);
		AddParamBool("FINISHER_CHANCE_OVERRIDE", false);

		AddParamFloat("FINISHER_CHANCE_BASE", 0.0);
		AddParamFloat("FINISHER_CHANCE_LEVEL_BONUS", 0.0);
		AddParamFloat("FINISHER_CHANCE_LEVEL_PENALTY", 0.0);

		AddParamFloat("FINISHER_AUTO_CHANCE_EFFECTS", 100.0);
		AddParamFloat("FINISHER_AUTO_CHANCE_CRIT", 0.0);
		AddParamFloat("FINISHER_AUTO_CHANCE_REND", 0.0);
		AddParamFloat("FINISHER_AUTO_CHANCE_LAST_ENEMY", 100.0);
		
		AddParamBool("FINISHER_AUTO_REQUIRE_NO_AGGRO", false);
		AddParamBool("FINISHER_AUTO_REQUIRE_NAV_CHECK", false);

		AddParamFloat("FINISHER_INSTANTKILL_CHANCE_EFFECTS", 100.0);
		AddParamFloat("FINISHER_INSTANTKILL_CHANCE_CRIT", 0.0);
		AddParamFloat("FINISHER_INSTANTKILL_CHANCE_LAST_ENEMY", 0.0);
		
		AddParamBool("FINISHER_INSTANTKILL_REQUIRE_NO_AGGRO", false);
		AddParamBool("FINISHER_INSTANTKILL_REQUIRE_NAV_CHECK", false);
		
		AddParamBool("FINISHER_CAM_DISABLE_CAMERA_SHAKE", true);
		
		AddParamFloat("FINISHER_CAM_CHANCE", 0.0);
		AddParamFloat("FINISHER_CAM_CHANCE_LAST_ENEMY", 100.0);
		
		AddParamBool("FINISHER_CAM_REQUIRE_NAV_CHECK", false);
		
		autoFinisherEffectTypes.PushBack(EET_Confusion);					// Axii stun
		autoFinisherEffectTypes.PushBack(EET_AxiiGuardMe);					// Axii mind control
		autoFinisherEffectTypes.PushBack(EET_Blindness);					// Blindness
		autoFinisherEffectTypes.PushBack(EET_Burning);						// Burning
		
		instantKillFinisherEffectTypes.PushBack(EET_Confusion);				// Axii stun
		instantKillFinisherEffectTypes.PushBack(EET_AxiiGuardMe);			// Axii mind control
		
		allowedLeftSideFinisherAnimNames.PushBack(theGame.xtFinishersMgr.consts.FINISHER_STANCE_LEFT_HEAD_ONE);
		allowedLeftSideFinisherAnimNames.PushBack(theGame.xtFinishersMgr.consts.FINISHER_STANCE_LEFT_HEAD_TWO);
		allowedLeftSideFinisherAnimNames.PushBack(theGame.xtFinishersMgr.consts.FINISHER_STANCE_LEFT_NECK);
		allowedLeftSideFinisherAnimNames.PushBack(theGame.xtFinishersMgr.consts.FINISHER_STANCE_LEFT_THRUST_ONE);
		allowedLeftSideFinisherAnimNames.PushBack(theGame.xtFinishersMgr.consts.FINISHER_STANCE_LEFT_THRUST_TWO);
		
		allowedRightSideFinisherAnimNames.PushBack(theGame.xtFinishersMgr.consts.FINISHER_STANCE_RIGHT_HEAD);
		allowedRightSideFinisherAnimNames.PushBack(theGame.xtFinishersMgr.consts.FINISHER_STANCE_RIGHT_THRUST_ONE);
		allowedRightSideFinisherAnimNames.PushBack(theGame.xtFinishersMgr.consts.FINISHER_STANCE_RIGHT_THRUST_TWO);
		
		dlcFinishers = theGame.GetSyncAnimManager().dlcFinishersRightSide;
		if (dlcFinishers.Size() > 0) {
			allowedLeftSideFinisherAnimNames.PushBack(theGame.xtFinishersMgr.consts.FINISHER_DLC_STANCE_LEFT_ARM);
			allowedLeftSideFinisherAnimNames.PushBack(theGame.xtFinishersMgr.consts.FINISHER_DLC_STANCE_LEFT_LEGS);
			allowedLeftSideFinisherAnimNames.PushBack(theGame.xtFinishersMgr.consts.FINISHER_DLC_STANCE_LEFT_TORSO);
			
			allowedRightSideFinisherAnimNames.PushBack(theGame.xtFinishersMgr.consts.FINISHER_DLC_STANCE_RIGHT_ARM);
			allowedRightSideFinisherAnimNames.PushBack(theGame.xtFinishersMgr.consts.FINISHER_DLC_STANCE_RIGHT_LEGS);
			allowedRightSideFinisherAnimNames.PushBack(theGame.xtFinishersMgr.consts.FINISHER_DLC_STANCE_RIGHT_TORSO);
			allowedRightSideFinisherAnimNames.PushBack(theGame.xtFinishersMgr.consts.FINISHER_DLC_STANCE_RIGHT_HEAD);
			allowedRightSideFinisherAnimNames.PushBack(theGame.xtFinishersMgr.consts.FINISHER_DLC_STANCE_RIGHT_NECK);
		}
		
		AddParam(CreateXTFinishersParamDefDefaultFinisherEffectTypeArray(this, "autoFinisherEffectTypes", autoFinisherEffectTypes));
		AddParam(CreateXTFinishersParamDefDefaultFinisherEffectTypeArray(this, "instantKillFinisherEffectTypes", instantKillFinisherEffectTypes));
		AddParam(CreateXTFinishersParamDefDefaultFinisherNameArray(this, "allowedLeftSideFinisherAnimNames", allowedLeftSideFinisherAnimNames));
		AddParam(CreateXTFinishersParamDefDefaultFinisherNameArray(this, "allowedRightSideFinisherAnimNames", allowedRightSideFinisherAnimNames));
	}
}